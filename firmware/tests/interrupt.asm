; Title: C64 UserPort MIDI - Simple Interrupt Test
; Author: D Cooper Dalrymple
; Created: 24/03/2021
; Updated: 25/03/2021
; https://dcooperdalrymple.com/

.nolist
.include "tn13Adef.inc"
.list

.equ BTN = PB1
.equ LED = PB0

.def tmp = r16
.def i = r17
.def j = r18
.def k = r19

.org $0000 ; Hard Reset
    rjmp init

.org INT0addr
    rjmp ToggleLED

.org $000A

init:
    ; Set Led as output and start high
    sbi DDRB, (1<<LED)
    sbi PORTB, (1<<LED)

    ; Set button as input and pullup high
    cbi DDRB, (1<<BTN)
    sbi PORTB, (1<<BTN)

    cli
    sbi MCUCR, (1<<ISC01)
    cbi MCUCR, (1<<ISC00)
    cbi GIMSK, (1<<PCIE)
    sbi GIMSK, (1<<INT0)
    sei

loop:
    rjmp loop

ToggleLED:
    in tmp, PORTB
    eor tmp, (1<<LED)
    out PORTB, tmp
    reti
