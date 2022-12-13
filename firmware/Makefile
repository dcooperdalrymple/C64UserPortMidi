# Compile ATtiny2313 Firmware for C64 UserPort MIDI

MCU=attiny2313
# Internal 8MHz CLK / 8 = 1MHz, Preserve EEPROM, BOD Detect at 4.3V, SPI Programming Enabled
# Fuse Calculator: http://eleccelerator.com/fusecalc/fusecalc.php?chip=attiny2313
FUSE_L=0x44
FUSE_H=0x99
F_CPU=1000000 # 1 MHz
UART_BAUDRATE=31250
TARGET=firmware

ISP_DEVICE=arduino
ISP_PORT=/dev/ttyACM0
ISP_BAUDRATE=19200

AS=avra
AVRDUDE=avrdude
ASFLAGS=-I ./include

SRC=main

all: compile

compile:
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
