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

.include "flag.asm"
.include "shift.asm"
.include "midi.asm"

init:

    rcall FlagInit
    rcall ShiftInit
    rcall MidiInit

buffer:
buffer_wait:
    cpi YL, LOW(SRAM_START)
    breq buffer_wait

    ldi i, LOW(SRAM_START)
buffer_write:

    ; Ensure that flag is high
    rcall FlagClear

    ; Load current data byte and shift into register
    ld data, Y
    rcall ShiftByte

    ; Set flag low to signal to C64 that data is ready
    rcall FlagTrigger

    ; Load up next byte if we still haven't hit index
    inc i
    cp i, YL
    brne buffer_write

buffer_clear:
    rcall MidiClear
    rjmp buffer
