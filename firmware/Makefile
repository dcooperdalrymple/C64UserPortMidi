# Compile ATtiny13 Firmware for C64 UserPort MIDI

MCU=attiny13
FUSE_L=0x7A#0x6A for 9.6Mhz/8=1.2Mhz, 0x79 for 4.8Mhz (no clock div), 0x7A for 9.6Mhz (no clock div)
FUSE_H=0xFF
F_CPU=9600000
UART_BAUDRATE=31250
TARGET=firmware

ISP_DEVICE=arduino
ISP_PORT=/dev/ttyACM0
ISP_BAUDRATE=19200

AS=avra
AVRDUDE=avrdude
ASFLAGS=-I ./include

SRC=main

all:
	${AS} ${ASFLAGS} -o ${TARGET}.hex -l ${TARGET}.lst -m ${TARGET}.map ${SRC}.asm
	mv ${SRC}.hex ${TARGET}.hex
	mv ${SRC}.eep.hex ${TARGET}.eep.hex
	mv ${SRC}.cof ${TARGET}.cof
	mv ${SRC}.obj ${TARGET}.obj

flash:
	${AVRDUDE} -Cavrdude.conf -v -p${MCU} -c${ISP_DEVICE} -P${ISP_PORT} -b${ISP_BAUDRATE} -Uflash:w:${TARGET}.hex:i

fuse:
	${AVRDUDE} -Cavrdude.conf -v -p${MCU} -c${ISP_DEVICE} -P${ISP_PORT} -b${ISP_BAUDRATE} -Uhfuse:w:${FUSE_H}:m -Ulfuse:w:${FUSE_L}:m

clean:
	rm -f *.asm~ *.hex *.obj *.cof *.elf *.o *.map *.lst
