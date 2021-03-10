# Compile C64 midi monitor cartridge that will read input from UserPort MIDI

DASM=dasm
CARTCONV=cartconv
SRC=main.asm
TARGET=monitor
NAME=C64 UserPort Midi Monitor

all:
	${DASM} ${SRC} -o${TARGET}.bin -f3 -v5 -l${TARGET}.lst -s${TARGET}.sym
	${CARTCONV} -t normal -n "${NAME}" -i "${TARGET}.bin" -o "${TARGET}.crt"

test:
	x64 ${TARGET}.crt

clean:
	rm -f *.bin *.crt
