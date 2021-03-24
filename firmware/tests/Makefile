# Compile communication tests for ATtiny13

MCU=attiny13
FUSE_L=0x7A#0x6A for 9.6Mhz/8=1.2Mhz, 0x79 for 4.8Mhz (no clock div), 0x7A for 9.6Mhz (no clock div)
FUSE_H=0xFF
F_CPU=9600000
UART_BAUDRATE=19200
MIDI_BAUDRATE=31250
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
SHIFT_DEFS=-DF_CPU=${F_CPU}
SHIFT_DEPS=../shift.c

UART_TARGET=uart_test
UART_DEFS=-DF_CPU=${F_CPU} -DUART_BAUDRATE=${UART_BAUDRATE} -DUART_TX_ENABLED=1
UART_DEPS=../uart.c

MIDI_TARGET=midi_test
MIDI_DEFS=-DF_CPU=${F_CPU} -DUART_BAUDRATE=${MIDI_BAUDRATE}
MIDI_DEPS=../uart.c

FLAG_TARGET=flag_test
FLAG_DEFS=-DF_CPU=${F_CPU}
FLAG_DEPS=../shift.c

all: make_shift make_midi make_flag#make_uart

make_shift:
	${CC} ${CFLAGS} ${SHIFT_DEFS} -o ${SHIFT_TARGET}.o ${SHIFT_TARGET}.c ${SHIFT_DEPS}
	${LD} -o ${SHIFT_TARGET}.elf ${SHIFT_TARGET}.o
	${OBJCOPY} -j .text -j .data -O ihex ${SHIFT_TARGET}.o ${SHIFT_TARGET}.hex
	${SIZE} -C --mcu=${MCU} ${SHIFT_TARGET}.elf

make_uart:
	${CC} ${CFLAGS} ${UART_DEFS} -o ${UART_TARGET}.o ${UART_TARGET}.c ${UART_DEPS}
	${LD} -o ${UART_TARGET}.elf ${UART_TARGET}.o
	${OBJCOPY} -j .text -j .data -O ihex ${UART_TARGET}.o ${UART_TARGET}.hex
	${SIZE} -C --mcu=${MCU} ${UART_TARGET}.elf

make_midi:
	${CC} ${CFLAGS} ${MIDI_DEFS} -o ${MIDI_TARGET}.o ${MIDI_TARGET}.c ${MIDI_DEPS}
	${LD} -o ${MIDI_TARGET}.elf ${MIDI_TARGET}.o
	${OBJCOPY} -j .text -j .data -O ihex ${MIDI_TARGET}.o ${MIDI_TARGET}.hex
	${SIZE} -C --mcu=${MCU} ${MIDI_TARGET}.elf

make_flag:
	${CC} ${CFLAGS} ${FLAG_DEFS} -o ${FLAG_TARGET}.o ${FLAG_TARGET}.c ${FLAG_DEPS}
	${LD} -o ${FLAG_TARGET}.elf ${FLAG_TARGET}.o
	${OBJCOPY} -j .text -j .data -O ihex ${FLAG_TARGET}.o ${FLAG_TARGET}.hex
	${SIZE} -C --mcu=${MCU} ${FLAG_TARGET}.elf

flash_shift:
	${AVRDUDE} -C../avrdude.conf -v -p${MCU} -c${ISP_DEVICE} -P${ISP_PORT} -b${ISP_BAUDRATE} -Uflash:w:${SHIFT_TARGET}.hex:i

flash_uart:
	${AVRDUDE} -C../avrdude.conf -v -p${MCU} -c${ISP_DEVICE} -P${ISP_PORT} -b${ISP_BAUDRATE} -Uflash:w:${UART_TARGET}.hex:i

flash_midi:
	${AVRDUDE} -C../avrdude.conf -v -p${MCU} -c${ISP_DEVICE} -P${ISP_PORT} -b${ISP_BAUDRATE} -Uflash:w:${MIDI_TARGET}.hex:i

flash_flag:
	${AVRDUDE} -C../avrdude.conf -v -p${MCU} -c${ISP_DEVICE} -P${ISP_PORT} -b${ISP_BAUDRATE} -Uflash:w:${FLAG_TARGET}.hex:i

fuse:
	${AVRDUDE} -C../avrdude.conf -v -p${MCU} -c${ISP_DEVICE} -P${ISP_PORT} -b${ISP_BAUDRATE} -Uhfuse:w:${FUSE_H}:m -Ulfuse:w:${FUSE_L}:m

clean:
	rm -f *.c~ *.o *.elf *.hex
