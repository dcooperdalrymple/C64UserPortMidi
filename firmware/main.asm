; Title: C64 UserPort MIDI
; Author: D Cooper Dalrymple
; Created: 24/02/2021
; Updated: 24/03/2021
; https://dcooperdalrymple.com/

.nolist
.include "tn13Adef.inc"
.list

.def tmp = r16
.def i = r17
.def j = r18
.def k = r19

.dseg
.org SRAM_START
midi_buffer: .byte 64

.org $0000 ; Hard Reset
    rjmp init

.org INT0addr
    rjmp MidiReceive

.org $000A ; Start of program code

.include "delay.inc"
.include "shift.inc"
.include "midi.inc"

init:
    rcall ShiftInit
    rcall MidiInit

buffer:
    nop

    ldi tmp, LOW(SRAM_START)
    cpse YL, tmp ; NOTE: Relative branches aren't working for some reason
    rjmp buffer_process
    rjmp buffer

buffer_process:
    ldi XH, HIGH(SRAM_START)
    ldi XL, LOW(SRAM_START)
buffer_write:

    ; Load current data byte and shift into register
    ld data, X
    rcall ShiftByte

    ; Load up next byte if we still haven't hit index
    inc XL
    cpse XL, YL
    rjmp buffer_write

buffer_clear:
    rcall MidiClear
    rjmp buffer
