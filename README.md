  Sniff LCD with a ESP32 module
==========================================


NOTE: This project is not for the faint of heart, it requires:

- a fair amount of fine point soldering
- an oscilloscope
- careful analyzing of waveforms to detect backplane and segment lines coming from the LCD controller
- reverse engineering of the segment map of the multiplexed LCD driver

Have you ever wanted to extract info out of an instrument and web enable it?  I've done this a few times using a ESP8266 by using the a/d converter to read an analog value then setting up the ESP8266 in AP mode so I could get to the data.  In this example we will be acutally sending the multiplexed LCD lines to an ESP32 (which has enough a/d lines) and converting them using the a/d converter in the ESP32.  Before you proceed, you should study up on how multiplexed LCD's work and example waveforms.  In a nutshell, they have backplane and segment lines in a multiplexed fashion.  Note that when I talk about "LCD segments" I'm talking about the actual segments that make up a 7-segment LCD display digit, when I talk about segment lines I'm talking about the lines from the LCD controller.  We need to convert all segment lines plus just one backplane line.  We only need one backplane line since the others follow in a round-robin fashion, we just need the one to give a starting point for converting all segment lines.  The code strategy is to look for a zero volt to Vcc transition on the backplane line and then convert all segment lines, then wait for one cycle and repeat until we've done all four backplanes.

In the example here we are using a MT87 v1 [clamp meter](https://www.richmeters.cn/pd.jsp?id=62), bought in 2022.  Note that there are many versions of the MT87 clamp meter going back at least to 2015.  I used an ESP32-CAM which was a mistake as many pins on the actual ESP32 module are very difficult to solder.  It's better to use something like a ESP32-MINI where you can more easily get to all the pins of the ESP32 module.

Here we are using the ESP-IDF github as a starting point and just replacing this file:
esp-idf/examples/peripherals/adc/single_read/adc2/main/adc2_example_main.c

Once you hook everything up and run, you need to figure out the LCD segment mapping, this is the tedious part. For this clamp meter, I hooked up a variable resistor and selected the resistance measurement.  Then I adjusted through 0-9 on a single digit while keeping all other digits the same while looking at the terminal output to see what bits change.  Use this chart to proceed:

```
Technique for finding out mapping between number segments and bits (only need 0-3 and 6-9):
0 -> 8 get LCD segment G
8 -> 9 get LCD segment E
8 -> 6 get LCD segment B
1 -> 7 get LCD segment A
2 -> 3 get LCD segment C
1 -> 0 get LCD segment F
7 -> 3 get LCD segment D
```

Once you get through all the above you can optimize everything by noticing that you don't need all 7 LCD segments to decode the digit.  Only segments G,F,E,B,A are needed so you don't need LCD segments C and D.

```
line
seg:   A   D   E   F   G   H   I   J   K   L
bp 0:  xx  xx  4A  xx  xx  3A DIO  2A  xx  DC
bp 1:  xx  xx  xx  4D  xx  3D  xx  2D  xx ONE
bp 2:  xx  xx  4C  4E  3C  3G  3E  2C  2E  xx
bp 3: DP4  4B  4G  4F  3B  3F  2B  2G  2F  AC
```

So I threw out A and L since I didn't need DP4 (decimal point) and DC, AC, and the far left "1" digit.  That left me only needing 9 channels of a/d.
	
Just so you know what you're up against, here is what I ended up with as far as connections:
![alt text](https://github.com/rickbronson/Sniff-LCD-with-ESP32/blob/master/docs/hardware/clampmeter-hookup1.png "clampmeter-hookup1")

And here is the wiring diagram:

![alt text](https://github.com/rickbronson/Sniff-LCD-with-ESP32/blob/master/docs/hardware/hookup8.png "hookup8")

The MT87 clamp meter circuit board rear LCD pads ((Note: A-L are segment lines [B and C are not used], M-P are the 4 backplane lines, only M is used):

![alt text](https://github.com/rickbronson/Sniff-LCD-with-ESP32/blob/master/docs/hardware/MT87-board-rear.png "MT87-board-rear")

The MT87clamp meter circuit board front chip pads (Note: a-l are segment lines [b and c are not used], m-p are the 4 backplane lines, only m is used):

![alt text](https://github.com/rickbronson/Sniff-LCD-with-ESP32/blob/master/docs/hardware/MT87-board-front.png "MT87-board-front")

Diagram showing the segment labeling of a seven-segment-display

![alt text](https://github.com/rickbronson/Sniff-LCD-with-ESP32/blob/master/docs/hardware/seven-segment-display.webp "seven-segment-display")

Diagram showing the makeup of digits on a seven-segment-display (we are only using 0-9)

![alt text](https://github.com/rickbronson/Sniff-LCD-with-ESP32/blob/master/docs/hardware/seven-seg-digits.png "seven-seg-digits")

All segments lit on a MT87-display

![alt text](https://github.com/rickbronson/Sniff-LCD-with-ESP32/blob/master/docs/hardware/MT87-display.png "MT87-display")

Example waveforms on a 4 backplane LCD driver

![alt text](https://github.com/rickbronson/Sniff-LCD-with-ESP32/blob/master/docs/hardware/seven-segment-waveforms.png "seven-segment-waveforms")

Example scope shot of 2 backplane lines, they are the same execpt offset by one clock cycle

![alt text](https://github.com/rickbronson/Sniff-LCD-with-ESP32/blob/master/docs/hardware/traces/trace-bp1-bp2.bmp "BP1-BP2")

Example scope shot of one backplane line and one segment line

![alt text](https://github.com/rickbronson/Sniff-LCD-with-ESP32/blob/master/docs/hardware/traces/trace-bp1-seg.bmp "BP1-SEG")

