/* ADC2 Example

   This example code is in the Public Domain (or CC0 licensed, at your option.)

   Unless required by applicable law or agreed to in writing, this
   software is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
   CONDITIONS OF ANY KIND, either express or implied.
*/
/* we are progamming the timer interrupt to sample GPI36 as an analog input at 10x the LCD_WAVE_FREQ
  to see when it transitions from a 0 to a 1 then setting the timer interrupt to 1ms
  increments then sampling on the segments on the 1st, 5th, 9th, 13th timer interrupt occurance

 - schedule timer interrupt for 10x LCD_WAVE_FREQ state=0, check for 0 (state=1) to 1 edge state=2
 - schedule timer interrupt for 1/2 of the waveform pulse (1ms)
 - (state=3) starting with the first interrupt and every other one thereafter do analog conversion on all SEG inputs
 - do the above 4 times (one for each segment of the 9 segment lines)
 - unscramble and display
 - wait for ?? and loop

for the MT87 clamp meter (stamped MT87_V1 on the PCB, the segment table looks like:

Segment to GPIO and ADC/channel:
    G    GPIO14    ADC2 6
    D    GPIO0     ADC2 1
    E    GPIO4     ADC2 0
    F    GPIO2     ADC2 2
    H    GPIO15    ADC2 3
    I    GPIO13    ADC2 4
    J    GPIO12    ADC2 5
    K    GPIO34    ADC1 6

Backplane to GPIO and ADC/channel:
    M    GPIO36    ADC2 0

Techinique for sniffing LCD drive

 - Scope connections and find backplane drive lines and segment lines, get frequency
   Backplane lines will have only one cycle high/low
 - Hook up one backplane line and all segment lines to a/d inputs
 - tweek input (use variable resistor for clamp meter) to find which bits are which LCD segments
 - make map of a/d segment bits to LCD segments of numbers

* Segment on LCD: number is digit number left to right, decimal point is on left of digit

Technique for finding out mapping between number segments and bits (only need 0-3 and 6-9):
0 -> 8 get LCD segment G
8 -> 9 get LCD segment E
8 -> 6 get LCD segment B
1 -> 7 get LCD segment A
2 -> 3 get LCD segment C
1 -> 0 get LCD segment F
7 -> 3 get LCD segment D
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/queue.h"
#include "driver/gpio.h"
#include "driver/adc.h"
#include "driver/timer.h"
#include "soc/rtc.h"
#include "esp_system.h"

//#define DEBUG

#define ADC1_FLAG 0x80000000
#define ADC2_CHAN_SEG_J  5  /* relates to GPIO12 (j) */
#define ADC2_CHAN_SEG_I  4  /* relates to GPIO13 (i) */
#define ADC2_CHAN_SEG_H  3  /* relates to GPIO15 (h) */
#define ADC2_CHAN_SEG_G  6  /* relates to GPIO14 (g) */
#define ADC2_CHAN_SEG_F  2  /* relates to GPIO2 (f) */
#define ADC2_CHAN_SEG_E  0  /* relates to GPIO4 (e) */
#define ADC2_CHAN_SEG_D  1  /* relates to GPIO0 (d) */
#define ADC1_CHAN_SEG_K  (6 | ADC1_FLAG)  /* relates to GPIO34 (k) */
#define ADC1_CHAN_BP_A  0  /* relates to GPIO36 (m) */

#if CONFIG_IDF_TARGET_ESP32
#define ADC_WIDTH ADC_WIDTH_BIT_12
#elif CONFIG_IDF_TARGET_ESP32S2
#define ADC_WIDTH ADC_WIDTH_BIT_13
#endif

#define TIMER_DIVIDER   (16)  /*  Hardware timer clock divider */
#define TIMER_FREQ     (TIMER_BASE_CLK / TIMER_DIVIDER)  /* 80M/16 convert counter value to seconds */

#define LCD_WAVE_FREQ 485
#define LCD_WAVE_FREQ4ms (TIMER_FREQ * 2 / LCD_WAVE_FREQ)  /* ~4 ms */
#define LCD_WAVE_SCAN_MULT 10
#define LCD_WAVE_FREQ_SCAN (TIMER_FREQ / LCD_WAVE_FREQ / LCD_WAVE_SCAN_MULT)

#define ARRAY_SIZE(s) (sizeof(s) / sizeof(*s))
#define SEGMENTS_MAX 8  /* number of a/d segment lines */
#define MISSING BIT(31)

enum seg2bit {  /* segment to bit mapping, NOTE: digit 4 is on the right */
LCD_SEG_DC = MISSING,
LCD_SEG_AC = MISSING,
LCD_SEG_ONE = MISSING,
LCD_SEG_DOIDE = BIT(26),

LCD_SEG_DP4 = BIT(23),
LCD_SEG_4A = BIT(29),
LCD_SEG_4B = BIT(6),
LCD_SEG_4C = BIT(13),
LCD_SEG_4D = BIT(20),
LCD_SEG_4E = BIT(12),
LCD_SEG_4F = BIT(4),
LCD_SEG_4G = BIT(5),

LCD_SEG_DP3 = BIT(18),
LCD_SEG_3A = BIT(27),
LCD_SEG_3B = BIT(7),
LCD_SEG_3C = BIT(15),
LCD_SEG_3D = BIT(19),
LCD_SEG_3E = BIT(10),
LCD_SEG_3F = BIT(3),
LCD_SEG_3G = BIT(11),

LCD_SEG_DP2 = MISSING,
LCD_SEG_2A = BIT(25),
LCD_SEG_2B = BIT(2),
LCD_SEG_2C = BIT(9),
LCD_SEG_2D = BIT(17),
LCD_SEG_2E = BIT(8),
LCD_SEG_2F = BIT(0),
LCD_SEG_2G = BIT(1),

LCD_SEG_DP1 = MISSING,
	};
/* 
seg:   G   D   E   F   H   I   J   K 
bp 0:  xx  xx  4A  xx  3A DIO  2A  xx
bp 1:  xx  xx  xx  4D  3D  xx  2D  xx
bp 2:  3C  xx  4C  4E  3G  3E  2C  2E
bp 3:  3B  4B  4G  4F  3F  2B  2G  2F
we don't need LCD segs C,D, or LCD seg's DP4, DIO, DC, ONE, or AC so we can get rid of a/d segments: A, L */

struct ONE_SEG_LINE
	{
	int32_t seg_bit;
	char *seg_str;
	};

#ifdef DEBUG
struct TIMER_DATA
	{
	int64_t timer_time;
	int cause;  /* which interrupt caused */
	};
#endif

struct ANALOG_DATA
	{
	int samples[SEGMENTS_MAX];
	int64_t lapsed_time;
	};

struct ADC_DATA
	{
#define BACKPLANES_MAX 4  /* number of backplanes */
	struct ANALOG_DATA analog_data[BACKPLANES_MAX];
#define LEVELS_MAX 4
	int32_t seg_bits;
	int levels[LEVELS_MAX];
#ifdef DEBUG
#define TIMER_DATA_SZ 400
	struct TIMER_DATA timer_data[TIMER_DATA_SZ];
	struct TIMER_DATA *p_timer_hd;
	struct TIMER_DATA *p_timer_tl;
	gpio_config_t io_conf2;
#endif
	int32_t last1;
	int state;
#define ADC_ST_ZEROS 0  /* the state of searching for zeroe's */
#define ADC_ST_ONES 1  /* the state of searching for one's */
#define ADC_ST_DO_SEGS 2  /* the state of a/d conversions of segments for all backplanes */
	int ana_cntr;
#define ADC_ZERO_MAX (LCD_WAVE_SCAN_MULT / 2)  /* look for half a period of zero's */
#define ADC_ONES_MAX (LCD_WAVE_SCAN_MULT / 5)  /* look for 1/5th a period of one's */
	int tg_timer_cntr;
	int ana_chan_lut[SEGMENTS_MAX];
	timer_config_t tg_timer_config;
	int ana_loop_cntr;  /* loop counter for all analog channels */
	int verbose;
	int seg7_lut[10];
	struct ONE_SEG_LINE seg_lines[32];
	};


enum Levels {  /* voltage levels of the waveform */
	LEVEL1 = 0,
	LEVEL2 = 1343,
	LEVEL3 = 2534,
	LEVEL4 = 4096,
	};

struct ADC_DATA adc_data =
	{
#ifdef DEBUG
#define GPIO_OUTPUT_IO_0    22
	.io_conf2.pin_bit_mask = BIT(GPIO_OUTPUT_IO_0),  /* bit mask of the pins */
	.io_conf2.mode = GPIO_MODE_OUTPUT,  /* set as output mode */
#endif
	.tg_timer_config.divider = TIMER_DIVIDER,
	.tg_timer_config.counter_dir = TIMER_COUNT_UP,
	.tg_timer_config.counter_en = TIMER_PAUSE,
	.tg_timer_config.alarm_en = TIMER_ALARM_EN,
	.tg_timer_config.auto_reload = 1,
	.ana_chan_lut = {ADC2_CHAN_SEG_G, ADC2_CHAN_SEG_D, ADC2_CHAN_SEG_E, ADC2_CHAN_SEG_F,
				ADC2_CHAN_SEG_H, ADC2_CHAN_SEG_I, ADC2_CHAN_SEG_J, ADC1_CHAN_SEG_K, },
	.levels = { LEVEL2 / 2, (LEVEL3 - LEVEL2) / 2 + LEVEL2, (LEVEL4 - LEVEL3) / 2 + LEVEL3, LEVEL4 },

/* 7 segment lookup
Num H G F E D C B A HEX   # one's
0         1 1 1 1 1 0x3F    5
1               1 1 0x06    2
2     1   1 1   1 1 0x5B    5
3     1     1 1 1 1 0x4F    5
4     1 1     1 1   0x66    4
5     1 1   1 1   1 0x6D    5
6     1 1 1 1 1   1 0x7D    6
7             1 1 1 0x07    3
8     1 1 1 1 1 1 1 0x7F    7
9     1 1   1 1 1 1 0x6F    6   */
	.seg7_lut = { 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F, }, /* a seg = LSB, g seg = MSB */
/* uniqueness test yields minimum 5 bits, mask = 0x73 or g,f,e,b,a */

	.seg_lines = {
			{LCD_SEG_2A, "   _"}, {LCD_SEG_3A, "   _"}, {LCD_SEG_4A, "   _\n"},
		{LCD_SEG_ONE, "| "}, {LCD_SEG_2F, "| "}, {LCD_SEG_2B, "| "}, {LCD_SEG_3F, "| "}, {LCD_SEG_3B, "| "}, {LCD_SEG_4F, "| "}, {LCD_SEG_4B, "| \n"},
		{LCD_SEG_2G, "   -"}, {LCD_SEG_3G, "   -"}, {LCD_SEG_4G, "   -\n"},
		{LCD_SEG_ONE, "| "}, {LCD_SEG_2E, "| "}, {LCD_SEG_2C, "| "}, {LCD_SEG_3E, "| "}, {LCD_SEG_3C, "| "}, {LCD_SEG_4E, "| "}, {LCD_SEG_4C, "| \n"},
		{LCD_SEG_DP2, " ."}, {LCD_SEG_2D, " _"}, {LCD_SEG_DP3, " ."}, {LCD_SEG_3D, " _"}, {LCD_SEG_DP4, " ."}, {LCD_SEG_4D, " _\n"},
		{LCD_SEG_2D, "   _"}, {LCD_SEG_3D, "   _"}, {LCD_SEG_4D, "   _\n"},
		{LCD_SEG_DC, "DC "}, {LCD_SEG_AC, "AC "}, {LCD_SEG_DOIDE, " DIODE"},
			},

	};

static inline void trace(struct ADC_DATA *p_data, int cause)
	{
#ifdef DEBUG
	p_data->p_timer_hd->timer_time = esp_timer_get_time();
	p_data->p_timer_hd->cause = cause;
	p_data->p_timer_hd++;
	if (p_data->p_timer_hd >= &p_data->timer_data[TIMER_DATA_SZ])
		p_data->p_timer_hd = p_data->timer_data;
#endif
	}

static void do_analog(struct ADC_DATA *p_data);
static void tg_timer_init(struct ADC_DATA *p_data, int group, int timer, int timer_interval);

#define TIMER_MODULO 4  /* start conversions 1/2th into first pulse and then every 4 thereafter */
static bool IRAM_ATTR timer_group_isr_callback(void *args)
	{
	struct ADC_DATA *p_data = (struct ADC_DATA *) args;
	int val;

	switch (p_data->state) {
	case ADC_ST_ZEROS:
		val = adc1_get_raw(ADC1_CHAN_BP_A);
		if (val < p_data->levels[0]) {
			if (p_data->ana_cntr++ >= ADC_ZERO_MAX) {
				p_data->ana_cntr = 0;
				p_data->state++;
				trace(p_data, 0);  /* debug only */
				}
			}
		else
			p_data->ana_cntr = 0;
		break;
	case ADC_ST_ONES:
		val = adc1_get_raw(ADC1_CHAN_BP_A);
		if (val > p_data->levels[2]) {
			if (p_data->ana_cntr++ >= ADC_ONES_MAX) {
				tg_timer_init(p_data, TIMER_GROUP_0, TIMER_0, LCD_WAVE_FREQ4ms);  /* change timer int freq */
				do_analog(p_data);  /* do first backplane */
				p_data->ana_cntr = 0;
				p_data->state++;
				trace(p_data, 1);  /* debug only */
				}
			}
		else
			p_data->ana_cntr = 0;
		break;
	case ADC_ST_DO_SEGS:
		if (p_data->ana_loop_cntr >= BACKPLANES_MAX) {
			timer_group_set_counter_enable_in_isr(TIMER_GROUP_0, TIMER_0, 0);  /* disable timer */
			p_data->state = ADC_ST_ZEROS;
			trace(p_data, 3);  /* debug only */
			}
		else {
			trace(p_data, 2);  /* debug only */
			do_analog(p_data);  /* do subsequent backplanes */
			}
		break;
	default:
		break;
		}
		
	p_data->tg_timer_cntr++;
	return true; /* return whether we need to yield at the end of ISR */
	}

/**
 * @brief Initialize selected timer of timer group
 *
 * @param group Timer Group number, index from 0
 * @param timer timer ID, index from 0
 * @param auto_reload whether auto-reload on alarm event
 * @param timer_interval interval of alarm
 */
static void tg_timer_init(struct ADC_DATA *p_data, int group, int timer, int timer_interval)
	{
	timer_init(group, timer, &p_data->tg_timer_config);

	/* Timer's counter will initially start from value below.
		 Also, if auto_reload is set, this value will be automatically reload on alarm */
	timer_set_counter_value(group, timer, 0);

	/* Configure the alarm value and the interrupt on alarm. */
	timer_set_alarm_value(group, timer, timer_interval);

	timer_isr_callback_add(group, timer, timer_group_isr_callback, p_data, ESP_INTR_FLAG_LOWMED);
	timer_enable_intr(group, timer);
	timer_start(group, timer);
	}

static void do_analog(struct ADC_DATA *p_data)  /* convert all a/d segments for all backplanes */
	{
	int chan, val;
	esp_err_t err;
	struct ANALOG_DATA *p_ana_data = &p_data->analog_data[p_data->ana_loop_cntr];
	int *p_samples = p_ana_data->samples;
	int64_t time_start;

	time_start = esp_timer_get_time();
#ifdef DEBUG
	gpio_set_level(GPIO_OUTPUT_IO_0, 1);  /* set high */
#endif
	for (chan = 0; chan < SEGMENTS_MAX;) {
		err = 0;
		if (p_data->ana_chan_lut[chan] & ADC1_FLAG) {
			val = adc1_get_raw(p_data->ana_chan_lut[chan] & ~ADC1_FLAG);
			}
		else {
			err = adc2_get_raw(p_data->ana_chan_lut[chan] & ~ADC1_FLAG, ADC_WIDTH, &val);
			}
		if ( err == ESP_OK ) {
			*p_samples++ = val;
			chan++;
			}
		else
			if ( err == ESP_ERR_INVALID_STATE ) {
				printf("%s: ADC2 not initialized yet.\n", esp_err_to_name(err));
				}
			else
				if ( err == ESP_ERR_TIMEOUT ) {
					/* This can not happen in this example. But if WiFi is in use, such error code could be returned. */
					printf("%s: ADC2 is in use by Wi-Fi.\n", esp_err_to_name(err));
					}
				else {
					printf("%s\n", esp_err_to_name(err));
					}
		}
	p_ana_data->lapsed_time = esp_timer_get_time() - time_start;
#ifdef DEBUG
	gpio_set_level(GPIO_OUTPUT_IO_0, 0);  /* set low */
#endif
	p_data->ana_loop_cntr++;
	}

void app_main(void)
	{
	struct ADC_DATA *p_data = &adc_data;
	struct ANALOG_DATA *p_ana_data;
	int *p_samples;
	int cntr, cntr2, level, alpha_level, on_segs;
#ifdef DEBUG
	int32_t current1, last1 = 0;
#endif
	
	printf("Minimum free heap size: %d bytes\n", esp_get_minimum_free_heap_size());
	/* init adc */
	adc1_config_channel_atten(ADC1_CHAN_BP_A, ADC_ATTEN_11db);
	adc_set_data_width(ADC_UNIT_1, ADC_WIDTH);
	for (cntr = 0; cntr < ARRAY_SIZE(p_data->ana_chan_lut); cntr++) {
		adc2_config_channel_atten(p_data->ana_chan_lut[cntr] & ~ADC1_FLAG, ADC_ATTEN_11db);
		}
	esp_timer_init();  /* free running timer, not in Timer Group */
#ifdef DEBUG
	gpio_config(&p_data->io_conf2);
	p_data->p_timer_hd = p_data->p_timer_tl = p_data->timer_data;
#endif
	while(1) {
		rtc_cpu_freq_config_t new_config;

		rtc_clk_cpu_freq_get_config(&new_config);
//		printf("start conversion, clk = %d, apb = %d\n", new_config.freq_mhz, rtc_clk_apb_freq_get());

		p_data->ana_loop_cntr = 0;  /* start off analog loop counter */
		p_data->state = ADC_ST_ZEROS;
		tg_timer_init(p_data, TIMER_GROUP_0, TIMER_0, LCD_WAVE_FREQ_SCAN);  /* kick off searching */
	
		vTaskDelay(1000 / portTICK_RATE_MS);  /* wait for things to happen */
//		printf("conversions done,state = %d, timer ints = %d\n", p_data->state, p_data->tg_timer_cntr);
		p_data->tg_timer_cntr = 0;
#ifdef DEBUG
		while(p_data->p_timer_hd != p_data->p_timer_tl) {
			current1 = p_data->p_timer_tl->timer_time;
//			printf("trace %d us cause = %d\n", (int) (current1 - last1), p_data->p_timer_tl->cause);
			p_data->p_timer_tl++;
			if (p_data->p_timer_tl >= &p_data->timer_data[TIMER_DATA_SZ])
				p_data->p_timer_tl = p_data->timer_data;
			last1 = current1;
			}
#endif
		/* output either analog samples or a/d segment bits on terminal */
		p_data->seg_bits = 0;
		for (cntr = 0; cntr < BACKPLANES_MAX; cntr++) {
			p_ana_data = &p_data->analog_data[cntr];
			p_samples = p_ana_data->samples;
//			printf("bp %d %d: ", cntr, (int) p_ana_data->lapsed_time);
			for (on_segs = 0, cntr2 = 0; cntr2 < SEGMENTS_MAX; cntr2++) {
				alpha_level = 'X';  /* in case of failure */
				p_data->seg_bits <<= 1;
				for (level = 0; level < LEVELS_MAX; level++) {
					if (*p_samples < p_data->levels[level]) {
						alpha_level = 'A' + level;
						if (alpha_level == 'A' || alpha_level == 'D') {
							on_segs++;
							alpha_level = '1';
							p_data->seg_bits |= 1;
							}
						else {
							alpha_level = '0';
							}
						break;
						}
					}
//				printf("%c ", alpha_level);
//				printf("%d ", *p_samples);
				p_samples++;
				}
//			printf(" ON= %d\n", on_segs);
			}
		printf(" bits = 0x%08x\n", p_data->seg_bits);
		/* output LCD char's on terminal */
		for (cntr = 0; cntr < ARRAY_SIZE(p_data->seg_lines); cntr++) {
			if (p_data->seg_lines[cntr].seg_bit & p_data->seg_bits) {
				printf("%s", p_data->seg_lines[cntr].seg_str);
				p_data->seg_bits &= ~p_data->seg_lines[cntr].seg_bit;
				}
			else {  /* just print spaces */
				for (cntr2 = 0; cntr2 < strlen(p_data->seg_lines[cntr].seg_str); cntr2++)
					if (p_data->seg_lines[cntr].seg_str[cntr2] == '\n')
						printf("\n");
					else
						printf(" ");
				}
			}
		printf("\n bits left = 0x%x\n", p_data->seg_bits);
		}
	}
