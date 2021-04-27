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

.include "midi.inc"

init:
    ; Set Led as output and start low
    sbi DDRB, LED
    cbi PORTB, LED

    rcall MidiInit

wait:
    cpi YL, LOW(SRAM_START)
    breq wait

    ldi XH, HIGH(SRAM_START)
    ldi XL, LOW(SRAM_START)

read:

    ; Just check the command byte
    ld tmp, X
    andi tmp, 0xF0

    cpi tmp, 0x90
    breq note_on

    cpi tmp, 0x80
    breq note_off

    rjmp next

note_on:
    ; Read 2 more bytes
    rcall MidiRead ; Note
    rcall MidiRead ; Velocity

    ; Check if velocity is zero (aka note off)
    ld tmp, X
    cpi tmp, 0
    breq note_off_b

    sbi PORTB, LED
    rjmp next

note_off:
    ; Read 2 more bytes
    rcall MidiRead ; Note
    rcall MidiRead ; Velocity

note_off_b:
    cbi PORTB, LED

next:
    inc XL
    cpse XL, YL
    rjmp read

    rcall MidiClear
    rjmp wait
