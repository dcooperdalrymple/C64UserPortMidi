# Compile communication tests for ATtiny13A

MCU=attiny13
FUSE_L=0x7A#0x6A for 9.6Mhz/8=1.2Mhz, 0x79 for 4.8Mhz (no clock div), 0x7A for 9.6Mhz (no clock div)
FUSE_H=0xFF
F_CPU=9600000
MIDI_BAUDRATE=31250

SHIFT_TARGET=shift
MIDI_TARGET=midi
FLAG_TARGET=flag
INTERRUPT_TARGET=interrupt

ISP_DEVICE=arduino
ISP_PORT=/dev/ttyACM0
ISP_BAUDRATE=19200

AS=avra
AVRDUDE=avrdude
ASFLAGS=-I ../include

all: shift midi flag interrupt

shift:
	${AS} ${ASFLAGS} -o ${SHIFT_TARGET} ${SHIFT_TARGET}.asm

flash_shift:
	${AVRDUDE} -C../avrdude.conf -v -p${MCU} -c${ISP_DEVICE} -P${ISP_PORT} -b${ISP_BAUDRATE} -Uflash:w:${SHIFT_TARGET}.hex:i

midi:
	${AS} ${ASFLAGS} -o ${MIDI_TARGET} ${MIDI_TARGET}.asm

flash_midi:
	${AVRDUDE} -C../avrdude.conf -v -p${MCU} -c${ISP_DEVICE} -P${ISP_PORT} -b${ISP_BAUDRATE} -Uflash:w:${MIDI_TARGET}.hex:i

flag:
	${AS} ${ASFLAGS} -o ${FLAG_TARGET} ${FLAG_TARGET}.asm

flash_flag:
	${AVRDUDE} -C../avrdude.conf -v -p${MCU} -c${ISP_DEVICE} -P${ISP_PORT} -b${ISP_BAUDRATE} -Uflash:w:${FLAG_TARGET}.hex:i

interrupt:
	${AS} ${ASFLAGS} -o ${INTERRUPT_TARGET} ${INTERRUPT_TARGET}.asm

flash_interrupt:
	${AVRDUDE} -C../avrdude.conf -v -p${MCU} -c${ISP_DEVICE} -P${ISP_PORT} -b${ISP_BAUDRATE} -Uflash:w:${INTERRUPT_TARGET}.hex:i

fuse:
	${AVRDUDE} -C../avrdude.conf -v -p${MCU} -c${ISP_DEVICE} -P${ISP_PORT} -b${ISP_BAUDRATE} -Uhfuse:w:${FUSE_H}:m -Ulfuse:w:${FUSE_L}:m

clean:
	rm -f *.asm~ *.hex *.obj *.cof
