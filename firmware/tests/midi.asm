; Title: C64 UserPort MIDI - Midi Input Test
; Author: D Cooper Dalrymple
; Created: 02/03/2021
; Updated: 25/03/2021
; https://dcooperdalrymple.com/

.nolist
.include "tn13Adef.inc"
.list

.equ LED = PB0

.def tmp = r16
.def i = r17
.def j = r18
.def k = r19

.org $0000 ; Hard Reset
    rjmp init

.org $000A

.include "midi.asm"

init:
    ; Set Led as output and start high
    sbi DDRB, LED
    sbi PORTB, LED

    rcall MidiInit

loop:
    cpi index, LOW(SRAM_START)
    breq loop

    in tmp, PORTB
    eor tmp, (1<<LED)
    out PORTB, tmp

    rcall MidiClear
    rjmp loop
