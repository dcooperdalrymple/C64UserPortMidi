# Compile communication tests for ATtiny2313

MCU=attiny2313
# Internal 8MHz CLK / 8 = 1MHz, Preserve EEPROM, BOD Detect at 4.3V, SPI Programming Enabled
# Fuse Calculator: http://eleccelerator.com/fusecalc/fusecalc.php?chip=attiny2313
FUSE_L=0x44
FUSE_H=0x99
F_CPU=1000000 # 1 MHz
MIDI_BAUDRATE=31250

LED_TARGET=led
MIDI_TARGET=midi
TRANSFER_TARGET=transfer
INTERRUPT_TARGET=interrupt
TARGETS=${LED_TARGET}.hex ${MIDI_TARGET}.hex ${TRANSFER_TARGET}.hex ${INTERRUPT_TARGET}.hex

ISP_DEVICE=arduino
ISP_PORT=/dev/ttyACM0
ISP_BAUDRATE=19200

AS=avra
AVRDUDE=avrdude
ASFLAGS=-I ../include

all: clean ${TARGETS}

%.hex:
	${AS} ${ASFLAGS} -o $(@:.hex=) $(@:.hex=.asm)

flash:
	@if [ "$(p)" = "" ]; then\
		echo "Select a test to flash using name of the test: make flash p=...";\
		exit 1;\
	fi

	@(ls $(p).hex >> /dev/null 2>&1) || (echo "$(p) does not exist to flash to device. Please compile using make or check if the desired test exists." && exit 1)

	@echo "Flashing $(p).hex to ATtiny13A device.";
	${AVRDUDE} -C../avrdude.conf -v -p${MCU} -c${ISP_DEVICE} -P${ISP_PORT} -b${ISP_BAUDRATE} -Uflash:w:$(p).hex:i

fuse:
	${AVRDUDE} -C../avrdude.conf -v -p${MCU} -c${ISP_DEVICE} -P${ISP_PORT} -b${ISP_BAUDRATE} -Uhfuse:w:${FUSE_H}:m -Ulfuse:w:${FUSE_L}:m

clean:
	rm -f *.asm~ *.hex *.obj *.cof *.elf *.o
