# Compile C64 midi monitor cartridge that will read input from UserPort MIDI

DASM=dasm
CARTCONV=cartconv
SRC=main.asm
TARGET=monitor
NAME=C64 UserPort Midi Monitor

all:
	${DASM} ${SRC} -o${TARGET}.prg -f3 -v5
	${CARTCONV} -i "${TARGET}.prg" -o "${TARGET}.crt" -t normal -n "${NAME}"

test:
	x64 ${TARGET}.crt

clean:
	rm -f *.prg *.crt
