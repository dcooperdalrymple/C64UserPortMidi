; Title: C64 UserPort MIDI
; Author: D Cooper Dalrymple
; Website: https://dcdalrymple.com/C64UserPortMidi/
; Created: 24/02/2021
; Updated: 13/12/2022
; HW Version: v1.0 RevA
; SW Version: v1.1

.nolist
.include "tn2313def.inc"
.list

.equ LED = PD3

.def tmp = r16
.def i = r17
.def j = r18
.def k = r19
.def data = r20

.dseg
.org SRAM_START

.org $0000 ; Hard Reset
    rjmp Init

.org INT0addr
    rjmp BusReceive

.org $000A ; Start of program code

.include "delay.inc"
.include "bus.inc"
.include "midi.inc"

Init:
    ; Set Stack Pointer to top of RAM
    ldi tmp, low(RAMEND)
    out SPL, tmp

    ; Configure led output
    sbi DDRD, LED
    sbi PORTD, LED ; Start high to indicate initialization

    ; Initialize components
    rcall BusInit
    rcall MidiInit

    cbi PORTD, LED ; Initialization process complete

    ; Enable Interrupts
    sei

Buffer:
    ; Populate buffer with incoming midi bytes
    rcall MidiReceive

    ldi tmp, LOW(SRAM_START)
    cpse YL, tmp ; NOTE: Relative branches aren't working for some reason
    rjmp Buffer_process ; Data in buffer
    rjmp Buffer ; Keep waiting for buffer

    ; TODO: Wait until enough valid midi data to process and check channel, etc.

Buffer_process:
    sbi PORTD, LED

    ldi XH, HIGH(SRAM_START)
    ldi XL, LOW(SRAM_START)
Buffer_write:

    ; Load current data byte and transmit to bus
    ld data, X
    rcall BusTransmit

    ; Load up next byte if we still haven't hit index
    inc XL
    cpse XL, YL
    rjmp Buffer_write

Buffer_clear:
    cbi PORTD, LED
    rcall MidiClear
    rjmp Buffer
