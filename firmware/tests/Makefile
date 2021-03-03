# Compile communication tests for ATtiny13

MCU=attiny13
FUSE_L=0x6A
FUSE_H=0xFF
CC=avr-gcc
LD=avr-ld
OBJCOPY=avr-objcopy
SIZE=avr-size
AVRDUDE=avrdude
ISP_DEVICE=arduino
ISP_PORT=/dev/ttyACM0
ISP_BAUDRATE=19200
CFLAGS=-std=c99 -Wall -g -Os -mmcu=${MCU} -I.
SHIFT_TARGET=shift_test
MIDI_TARGET=midi_test
TARGETS=${SHIFT_TARGET} ${MIDI_TARGET}
DEPS=../shift.c ../uart.c

all: $(TARGETS)

$(TARGETS):
	${CC} ${CFLAGS} -o $@.o $@.c ${DEPS}
	${LD} -o $@.elf $@.o
	${OBJCOPY} -j .text -j .data -O ihex $@.o $@.hex
	${SIZE} -C --mcu=${MCU} $@.elf

flash_shift:
	${AVRDUDE} -C../avrdude.conf -v -p${MCU} -c${ISP_DEVICE} -P${ISP_PORT} -b${ISP_BAUDRATE} -Uflash:w:${SHIFT_TARGET}.hex:i

flash_midi:
	${AVRDUDE} -C../avrdude.conf -v -p${MCU} -c${ISP_DEVICE} -P${ISP_PORT} -b${ISP_BAUDRATE} -Uflash:w:${MIDI_TARGET}.hex:i

fuse:
	${AVRDUDE} -Cavrdude.conf -v -p${MCU} -c${ISP_DEVICE} -P${ISP_PORT} -b${ISP_BAUDRATE} -Uhfuse:w:${FUSE_H}:m -Ulfuse:w:${FUSE_L}:m

clean:
	rm -f *.c~ *.o *.elf *.hex
