# Compile ATtiny13 Firmware for C64 UserPort MIDI

MCU=attiny13
FUSE_L=0x7A#0x6A for 9.6Mhz/8=1.2Mhz, 0x79 for 4.8Mhz (no clock div), 0x7A for 9.6Mhz (no clock div)
FUSE_H=0xFF
F_CPU=9600000
UART_BAUDRATE=31250
CC=avr-gcc
LD=avr-ld
OBJCOPY=avr-objcopy
SIZE=avr-size
AVRDUDE=avrdude
ISP_DEVICE=arduino
ISP_PORT=/dev/ttyACM0
ISP_BAUDRATE=19200
CFLAGS=-std=c99 -Wall -g -Os -mmcu=${MCU} -DF_CPU=${F_CPU} -DUART_BAUDRATE=${UART_BAUDRATE} -I.
TARGET=firmware

SRCS=main.c shift.c uart.c

all:
	${CC} ${CFLAGS} -o ${TARGET}.o ${SRCS}
	${LD} -o ${TARGET}.elf ${TARGET}.o
	${OBJCOPY} -j .text -j .data -O ihex ${TARGET}.o ${TARGET}.hex
	${SIZE} -C --mcu=${MCU} ${TARGET}.elf

flash:
	${AVRDUDE} -Cavrdude.conf -v -p${MCU} -c${ISP_DEVICE} -P${ISP_PORT} -b${ISP_BAUDRATE} -Uflash:w:${TARGET}.hex:i

fuse:
	${AVRDUDE} -Cavrdude.conf -v -p${MCU} -c${ISP_DEVICE} -P${ISP_PORT} -b${ISP_BAUDRATE} -Uhfuse:w:${FUSE_H}:m -Ulfuse:w:${FUSE_L}:m

clean:
	rm -f *.c~ *.o *.elf *.hex
