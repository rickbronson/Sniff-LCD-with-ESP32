PATH:=/home/rick/boards/esp32/esp-idf/components/esptool_py/esptool:/home/rick/boards/esp32/esp-idf/components/espcoredump:/home/rick/boards/esp32/esp-idf/components/partition_table:/home/rick/boards/esp32/esp-idf/components/app_update:/home/rick/.espressif/tools/xtensa-esp32-elf/esp-2021r2-8.4.0/xtensa-esp32-elf/bin:/home/rick/.espressif/tools/esp32ulp-elf/2.28.51-esp-20191205/esp32ulp-elf-binutils/bin:/home/rick/.espressif/tools/openocd-esp32/v0.10.0-esp32-20211111/openocd-esp32/bin:/home/rick/.espressif/python_env/idf5.0_py3.7_env/bin:/home/rick/boards/esp32/esp-idf/tools:$(PATH)
PORT=/dev/ttyUSB0
PWD := $(shell pwd)

INCLUDES=-I/home/rick/boards/esp32/esp-idf/components/esp_ringbuf/include -Iconfig -I/home/rick/boards/esp32/esp-idf/components/newlib/platform_include -I/home/rick/boards/esp32/esp-idf/components/freertos/FreeRTOS-Kernel/include -I/home/rick/boards/esp32/esp-idf/components/freertos/esp_additions/include/freertos -I/home/rick/boards/esp32/esp-idf/components/freertos/FreeRTOS-Kernel/portable/xtensa/include -I/home/rick/boards/esp32/esp-idf/components/freertos/esp_additions/include -I/home/rick/boards/esp32/esp-idf/components/esp_hw_support/include -I/home/rick/boards/esp32/esp-idf/components/esp_hw_support/include/soc -I/home/rick/boards/esp32/esp-idf/components/esp_hw_support/include/soc/esp32 -I/home/rick/boards/esp32/esp-idf/components/esp_hw_support/port/esp32/. -I/home/rick/boards/esp32/esp-idf/components/heap/include -I/home/rick/boards/esp32/esp-idf/components/log/include -I/home/rick/boards/esp32/esp-idf/components/lwip/include/apps -I/home/rick/boards/esp32/esp-idf/components/lwip/include/apps/sntp -I/home/rick/boards/esp32/esp-idf/components/lwip/lwip/src/include -I/home/rick/boards/esp32/esp-idf/components/lwip/port/esp32/include -I/home/rick/boards/esp32/esp-idf/components/lwip/port/esp32/include/arch -I/home/rick/boards/esp32/esp-idf/components/soc/include -I/home/rick/boards/esp32/esp-idf/components/soc/esp32/. -I/home/rick/boards/esp32/esp-idf/components/soc/esp32/include -I/home/rick/boards/esp32/esp-idf/components/hal/esp32/include -I/home/rick/boards/esp32/esp-idf/components/hal/include -I/home/rick/boards/esp32/esp-idf/components/hal/platform_port/include -I/home/rick/boards/esp32/esp-idf/components/esp_rom/include -I/home/rick/boards/esp32/esp-idf/components/esp_rom/include/esp32 -I/home/rick/boards/esp32/esp-idf/components/esp_rom/esp32 -I/home/rick/boards/esp32/esp-idf/components/esp_common/include -I/home/rick/boards/esp32/esp-idf/components/esp_system/include -I/home/rick/boards/esp32/esp-idf/components/esp_system/port/soc -I/home/rick/boards/esp32/esp-idf/components/esp_system/port/include/private -I/home/rick/boards/esp32/esp-idf/components/xtensa/include -I/home/rick/boards/esp32/esp-idf/components/xtensa/esp32/include -I/home/rick/boards/esp32/esp-idf/components/driver/include -I/home/rick/boards/esp32/esp-idf/components/driver/esp32/include -I/home/rick/boards/esp32/esp-idf/components/driver/deprecated -I/home/rick/boards/esp32/esp-idf/components/esp_pm/include -I/home/rick/boards/esp32/esp-idf/components/efuse/include -I/home/rick/boards/esp32/esp-idf/components/efuse/esp32/include -I/home/rick/boards/esp32/esp-idf/components/vfs/include -I/home/rick/boards/esp32/esp-idf/components/esp_wifi/include -I/home/rick/boards/esp32/esp-idf/components/esp_event/include -I/home/rick/boards/esp32/esp-idf/components/esp_netif/include -I/home/rick/boards/esp32/esp-idf/components/esp_eth/include -I/home/rick/boards/esp32/esp-idf/components/tcpip_adapter/include -I/home/rick/boards/esp32/esp-idf/components/esp_phy/include -I/home/rick/boards/esp32/esp-idf/components/esp_phy/esp32/include -I/home/rick/boards/esp32/esp-idf/components/esp_timer/include -I/home/rick/boards/esp32/esp-idf/components/mbedtls/port/include -I/home/rick/boards/esp32/esp-idf/components/mbedtls/mbedtls/include -I/home/rick/boards/esp32/esp-idf/components/mbedtls/esp_crt_bundle/include -I/home/rick/boards/esp32/esp-idf/components/app_update/include -I/home/rick/boards/esp32/esp-idf/components/spi_flash/include -I/home/rick/boards/esp32/esp-idf/components/bootloader_support/include -I/home/rick/boards/esp32/esp-idf/components/nvs_flash/include -I/home/rick/boards/esp32/esp-idf/components/pthread/include -I/home/rick/boards/esp32/esp-idf/components/wpa_supplicant/include -I/home/rick/boards/esp32/esp-idf/components/wpa_supplicant/port/include -I/home/rick/boards/esp32/esp-idf/components/wpa_supplicant/esp_supplicant/include -I/home/rick/boards/esp32/esp-idf/components/app_trace/include -I/home/rick/boards/esp32/esp-idf/components/asio/asio/asio/include -I/home/rick/boards/esp32/esp-idf/components/asio/port/include -I/home/rick/boards/esp32/esp-idf/components/unity/include -I/home/rick/boards/esp32/esp-idf/components/unity/unity/src -I/home/rick/boards/esp32/esp-idf/components/cmock/CMock/src -I/home/rick/boards/esp32/esp-idf/components/coap/port/include -I/home/rick/boards/esp32/esp-idf/components/coap/libcoap/include -I/home/rick/boards/esp32/esp-idf/components/console -I/home/rick/boards/esp32/esp-idf/components/nghttp/port/include -I/home/rick/boards/esp32/esp-idf/components/nghttp/nghttp2/lib/includes -I/home/rick/boards/esp32/esp-idf/components/esp-tls -I/home/rick/boards/esp32/esp-idf/components/esp-tls/esp-tls-crypto -I/home/rick/boards/esp32/esp-idf/components/esp_adc_cal/include -I/home/rick/boards/esp32/esp-idf/components/esp_gdbstub/include -I/home/rick/boards/esp32/esp-idf/components/esp_gdbstub/xtensa -I/home/rick/boards/esp32/esp-idf/components/esp_gdbstub/esp32 -I/home/rick/boards/esp32/esp-idf/components/esp_hid/include -I/home/rick/boards/esp32/esp-idf/components/tcp_transport/include -I/home/rick/boards/esp32/esp-idf/components/esp_http_client/include -I/home/rick/boards/esp32/esp-idf/components/esp_http_server/include -I/home/rick/boards/esp32/esp-idf/components/esp_https_ota/include -I/home/rick/boards/esp32/esp-idf/components/esp_lcd/include -I/home/rick/boards/esp32/esp-idf/components/esp_lcd/interface -I/home/rick/boards/esp32/esp-idf/components/protobuf-c/protobuf-c -I/home/rick/boards/esp32/esp-idf/components/protocomm/include/common -I/home/rick/boards/esp32/esp-idf/components/protocomm/include/security -I/home/rick/boards/esp32/esp-idf/components/protocomm/include/transports -I/home/rick/boards/esp32/esp-idf/components/mdns/include -I/home/rick/boards/esp32/esp-idf/components/esp_local_ctrl/include -I/home/rick/boards/esp32/esp-idf/components/sdmmc/include -I/home/rick/boards/esp32/esp-idf/components/esp_serial_slave_link/include -I/home/rick/boards/esp32/esp-idf/components/esp_websocket_client/include -I/home/rick/boards/esp32/esp-idf/components/espcoredump/include -I/home/rick/boards/esp32/esp-idf/components/espcoredump/include/port/xtensa -I/home/rick/boards/esp32/esp-idf/components/expat/expat/expat/lib -I/home/rick/boards/esp32/esp-idf/components/expat/port/include -I/home/rick/boards/esp32/esp-idf/components/wear_levelling/include -I/home/rick/boards/esp32/esp-idf/components/fatfs/diskio -I/home/rick/boards/esp32/esp-idf/components/fatfs/vfs -I/home/rick/boards/esp32/esp-idf/components/fatfs/src -I/home/rick/boards/esp32/esp-idf/components/freemodbus/common/include -I/home/rick/boards/esp32/esp-idf/components/idf_test/include -I/home/rick/boards/esp32/esp-idf/components/idf_test/include/esp32 -I/home/rick/boards/esp32/esp-idf/components/ieee802154/include -I/home/rick/boards/esp32/esp-idf/components/json/cJSON -I/home/rick/boards/esp32/esp-idf/components/mqtt/esp-mqtt/include -I/home/rick/boards/esp32/esp-idf/components/openssl/include -I/home/rick/boards/esp32/esp-idf/components/perfmon/include -I/home/rick/boards/esp32/esp-idf/components/spiffs/include -I/home/rick/boards/esp32/esp-idf/components/ulp/include -I/home/rick/boards/esp32/esp-idf/components/wifi_provisioning/include -I../main -Ibuild/config

#BUILD=esp-idf/examples/get-started/blink
#BUILD=esp-idf/examples/peripherals/adc/dma_read
BUILD=esp-idf/examples/peripherals/adc/single_read/adc2
#BUILD=esp-idf/examples/peripherals/gpio/generic_gpio

all:
#	cd ${BUILD}; idf.py set-target esp32; idf.py build # cleans any config you've made in menuconfig.
	cd ${BUILD}; idf.py -p $(PORT) flash
	cd ${BUILD}; ${HOME}/.espressif/tools/xtensa-esp32-elf/esp-2021r2-8.4.0/xtensa-esp32-elf/bin/xtensa-esp32-elf-gcc -Wa,-adhln -g ${INCLUDES} -c main/adc2_example_main.c > main/adc2_example_main.lst
#	cd ${BUILD}; idf.py -p $(PORT) monitor

# All examples that built:
cxx/pthread cxx/rtti cxx/experimental/simple_i2c_rw_example cxx/experimental/esp_event_async_cxx cxx/experimental/esp_mqtt_cxx/ssl cxx/experimental/esp_mqtt_cxx/tcp cxx/experimental/esp_timer_cxx cxx/experimental/esp_modem_cxx cxx/experimental/simple_spi_rw_example cxx/experimental/esp_event_cxx cxx/experimental/blink_cxx cxx/exceptions build_system/cmake/import_lib build_system/cmake/import_prebuilt/prebuilt build_system/cmake/component_manager build_system/cmake/multi_config provisioning/legacy/custom_config provisioning/legacy/ble_prov provisioning/legacy/softap_prov provisioning/legacy/console_prov provisioning/wifi_prov_mgr mesh/manual_networking mesh/internal_communication mesh/ip_internal_network protocols/https_x509_bundle protocols/http2_request protocols/https_request protocols/esp_local_ctrl protocols/websocket protocols/https_server/wss_server protocols/https_server/simple protocols/http_server/captive_portal protocols/http_server/restful_server protocols/http_server/file_serving protocols/http_server/ws_echo_server protocols/http_server/simple protocols/http_server/advanced_tests protocols/http_server/persistent_sockets protocols/coap_client protocols/coap_server protocols/sntp protocols/smtp_client protocols/asio/ssl_client_server protocols/asio/asio_chat protocols/asio/async_request protocols/asio/udp_echo_server protocols/asio/tcp_echo_server protocols/icmp_echo protocols/esp_http_client protocols/cbor protocols/static_ip protocols/http_request protocols/modbus/serial/mb_slave protocols/modbus/serial/mb_master protocols/modbus/tcp/mb_tcp_slave protocols/modbus/tcp/mb_tcp_master protocols/slip/slip_udp protocols/https_mbedtls protocols/mqtt/ssl_psk protocols/mqtt/ssl protocols/mqtt/wss protocols/mqtt/ssl_mutual_auth protocols/mqtt/ws protocols/mqtt/tcp protocols/sockets/tcp_client protocols/sockets/tcp_server protocols/sockets/udp_multicast protocols/sockets/tcp_client_multi_net protocols/sockets/udp_client protocols/sockets/udp_server protocols/sockets/non_blocking protocols/mdns ethernet/iperf ethernet/enc28j60 ethernet/basic ethernet/eth2ap storage/partition_api/partition_find storage/partition_api/partition_mmap storage/partition_api/partition_ops storage/sd_card/sdspi storage/sd_card/sdmmc storage/custom_flash_driver storage/semihost_vfs storage/parttool storage/wear_levelling storage/ext_flash_fatfs storage/nvs_rw_value_cxx storage/nvs_rw_value storage/fatfsgen storage/nvs_rw_blob storage/spiffsgen storage/spiffs get-started/blink get-started/sample_project get-started/hello_world openthread/ot_br network/simple_sniffer network/network_tests custom_bootloader/bootloader_hooks custom_bootloader/bootloader_override peripherals/uart/uart_echo_rs485 peripherals/uart/nmea0183_parser peripherals/uart/uart_async_rxtxtasks peripherals/uart/uart_repl peripherals/uart/uart_events peripherals/uart/uart_select peripherals/uart/uart_echo peripherals/timer_group peripherals/i2s/i2s_adc_dac peripherals/i2s/i2s_audio_recorder_sdcard peripherals/i2s/i2s_basic peripherals/i2s/i2s_es8311 peripherals/mcpwm/mcpwm_brushed_dc_control peripherals/mcpwm/mcpwm_bldc_hall_control peripherals/mcpwm/mcpwm_servo_control peripherals/mcpwm/mcpwm_capture_hc_sr04 peripherals/mcpwm/mcpwm_sync_example peripherals/pcnt/pulse_count_event peripherals/pcnt/rotary_encoder peripherals/lcd/gc9a01 peripherals/lcd/lvgl peripherals/lcd/tjpgd peripherals/rmt/led_strip peripherals/rmt/morse_code peripherals/rmt/ir_protocols peripherals/rmt/step_motor peripherals/rmt/musical_buzzer peripherals/ledc/ledc_basic peripherals/ledc/ledc_fade peripherals/gpio/matrix_keyboard peripherals/gpio/generic_gpio peripherals/spi_master/lcd peripherals/spi_master/hd_eeprom peripherals/spi_slave/sender peripherals/spi_slave/receiver peripherals/twai/twai_alert_and_recovery peripherals/twai/twai_network/twai_network_slave peripherals/twai/twai_network/twai_network_master peripherals/twai/twai_network/twai_network_listen_only peripherals/twai/twai_self_test peripherals/temp_sensor peripherals/sdio/slave peripherals/sdio/host peripherals/usb/tusb_serial_device peripherals/usb/host/cdc/cdc_acm_host peripherals/usb/host/cdc/cdc_acm_bg96 peripherals/usb/tusb_sample_descriptor peripherals/usb/tusb_console peripherals/spi_slave_hd/append_mode/slave peripherals/spi_slave_hd/append_mode/master peripherals/spi_slave_hd/segment_mode/seg_master peripherals/spi_slave_hd/segment_mode/seg_slave peripherals/wave_gen peripherals/sigmadelta peripherals/adc/dma_read peripherals/adc/single_read/adc2 peripherals/adc/single_read/single_read peripherals/adc/single_read/adc peripherals/secure_element/atecc608_ecdsa peripherals/i2c/i2c_tools peripherals/i2c/i2c_self_test peripherals/i2c/i2c_simple peripherals/touch_sensor/touch_sensor_v1/touch_pad_read peripherals/touch_sensor/touch_sensor_v1/touch_pad_interrupt peripherals/touch_sensor/touch_sensor_v2/touch_pad_read peripherals/touch_sensor/touch_sensor_v2/touch_pad_interrupt security/flash_encryption wifi/getting_started/softAP wifi/getting_started/station wifi/espnow wifi/wps wifi/ftm wifi/iperf wifi/scan wifi/fast_scan wifi/wifi_eap_fast wifi/roaming wifi/wifi_enterprise wifi/wifi_easy_connect/dpp-enrollee wifi/power_save wifi/smart_config system/ipc/ipc_isr system/gcov system/deep_sleep system/ulp_fsm/ulp_adc system/ulp_fsm/ulp system/himem system/base_mac_address system/eventfd system/ota/otatool system/ota/native_ota_example system/ota/simple_ota_example system/ota/advanced_https_ota system/pthread system/app_trace_to_host system/startup_time system/sysview_tracing system/efuse system/unit_test system/unit_test/test system/gdbstub system/esp_timer system/esp_event/default_event_loop system/esp_event/user_event_loops system/light_sleep system/perfmon system/freertos/real_time_stats system/sysview_tracing_heap_log system/select system/heap_task_tracking system/console/basic system/console/advanced system/task_watchdog bluetooth/esp_ble_mesh/ble_mesh_fast_provision/fast_prov_client bluetooth/esp_ble_mesh/ble_mesh_fast_provision/fast_prov_server bluetooth/esp_ble_mesh/ble_mesh_wifi_coexist bluetooth/esp_ble_mesh/ble_mesh_console bluetooth/esp_ble_mesh/ble_mesh_sensor_model/sensor_client bluetooth/esp_ble_mesh/ble_mesh_sensor_model/sensor_server bluetooth/esp_ble_mesh/ble_mesh_coex_test bluetooth/esp_ble_mesh/ble_mesh_node/onoff_server bluetooth/esp_ble_mesh/ble_mesh_node/onoff_client bluetooth/esp_ble_mesh/aligenie_demo bluetooth/esp_ble_mesh/ble_mesh_provisioner bluetooth/esp_ble_mesh/ble_mesh_vendor_model/vendor_client bluetooth/esp_ble_mesh/ble_mesh_vendor_model/vendor_server bluetooth/hci/controller_hci_uart_esp32c3 bluetooth/hci/controller_hci_uart_esp32 bluetooth/hci/controller_vhci_ble_adv bluetooth/hci/ble_adv_scan_combined bluetooth/nimble/blecent bluetooth/nimble/bleprph_wifi_coex bluetooth/nimble/ble_spp/spp_client bluetooth/nimble/ble_spp/spp_server bluetooth/nimble/blehr bluetooth/nimble/blemesh bluetooth/nimble/bleprph bluetooth/nimble/throughput_app/blecent_throughput bluetooth/nimble/throughput_app/bleprph_throughput bluetooth/blufi bluetooth/esp_hid_host bluetooth/esp_hid_device bluetooth/bluedroid/coex/gattc_gatts_coex bluetooth/bluedroid/coex/a2dp_gatts_coex bluetooth/bluedroid/ble_50/peroidic_sync bluetooth/bluedroid/ble_50/multi-adv bluetooth/bluedroid/ble_50/ble50_security_server bluetooth/bluedroid/ble_50/ble50_security_client bluetooth/bluedroid/ble_50/peroidic_adv bluetooth/bluedroid/classic_bt/hfp_ag bluetooth/bluedroid/classic_bt/a2dp_source bluetooth/bluedroid/classic_bt/bt_spp_acceptor bluetooth/bluedroid/classic_bt/bt_spp_initiator bluetooth/bluedroid/classic_bt/hfp_hf bluetooth/bluedroid/classic_bt/bt_spp_vfs_acceptor bluetooth/bluedroid/classic_bt/a2dp_sink bluetooth/bluedroid/classic_bt/bt_spp_vfs_initiator bluetooth/bluedroid/classic_bt/bt_discovery bluetooth/bluedroid/classic_bt/bt_hid_mouse_device bluetooth/bluedroid/ble/ble_compatibility_test bluetooth/bluedroid/ble/ble_hid_device_demo bluetooth/bluedroid/ble/gatt_server bluetooth/bluedroid/ble/ble_ibeacon bluetooth/bluedroid/ble/gatt_security_server bluetooth/bluedroid/ble/gatt_server_service_table bluetooth/bluedroid/ble/ble_throughput/throughput_client bluetooth/bluedroid/ble/ble_throughput/throughput_server bluetooth/bluedroid/ble/ble_eddystone bluetooth/bluedroid/ble/gatt_security_client bluetooth/bluedroid/ble/gatt_client bluetooth/bluedroid/ble/ble_spp_server bluetooth/bluedroid/ble/ble_spp_client bluetooth/bluedroid/ble/ble_ancs bluetooth/bluedroid/ble/gattc_multi_connect:
	cd esp-idf/examples/$@; if test -e main/Kconfig.projbuild -a test "wifi/getting_started/softAP" != "$@"; then sed -i -e "s/myssid/Solar/" -e "s/mypassword/5414857264/" main/Kconfig.projbuild; fi
	cd esp-idf/examples/$@; if test -e sdkconfig -a test "wifi/getting_started/softAP" != "$@"; then sed -i -e "s/myssid/Solar/" -e "s/mypassword/5414857264/" sdkconfig; fi
	cd esp-idf/examples/$@; idf.py build
	cd esp-idf/examples/$@; idf.py -p $(PORT) flash
#	cd esp-idf/examples/$@; idf.py -p $(PORT) monitor

makeall:
	for subdir in `dirname $$(find esp-idf/examples -name "CMakeLists.txt")`; do \
	  cd $(PWD)/$$subdir; \
    sed -i -e "s/myssid/Solar" -e "s/mypassword/5414857264/" main/Kconfig.projbuild; \
    if grep "cmake_minimum_required" CMakeLists.txt; then echo "Doing $(PWD)/$$subdir"; idf.py build; fi; \
	done; \

monitor:
	cd ${BUILD}; idf.py -p $(PORT) monitor

menuconfig:
	cd ${BUILD}; idf.py menuconfig

cleanall:
	for subdir in `dirname $$(find esp-idf/examples -name "CMakeLists.txt")`; do \
	  cd $(PWD)/$$subdir; if [ -d ../build ]; then rm -rf build/*; fi; \
	done; \

github-init:
	gh repo create 'Sniff LCD with ESP32' --public
	rm -rf .git
	git init
	git add Makefile docs/hardware/clampmeter-hookup1.png docs/hardware/hookup8.png docs/hardware/MT87-board-rear.png docs/hardware/MT87-board-front.png docs/hardware/seven-segment-display.webp docs/hardware/seven-seg-digits.png docs/hardware/MT87-display.png docs/hardware/seven-segment-waveforms.png docs/hardware/traces/trace-bp1-bp2.bmp docs/hardware/traces/trace-bp1-seg.bmp ./README.md 
	git add esp-idf/examples/peripherals/adc/single_read/adc2/main/adc2_example_main.c
	git commit -m "first commit"
	git remote add origin https://github.com/rickbronson/Sniff-LCD-with-ESP32.git
# /snap/bin/gh auth login --with-token < ~/.ssh/id_ed25519.pub 
# go here https://github.com/settings/tokens and get a new tokin and use this as the password on the next step, NOTE: you need to enable several permissions on this page!
#	git push -u origin master

github-update:
	git commit -a -m 'update README'
	git push -u origin master
