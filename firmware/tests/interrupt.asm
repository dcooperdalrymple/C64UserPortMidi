; Title: C64 UserPort MIDI - Simple Interrupt Test
; Author: D Cooper Dalrymple
; Website: https://dcdalrymple.com/C64UserPortMidi/
; Created: 24/03/2021
; Updated: 13/12/2022
; HW Version: v1.0 RevA

.nolist
.include "tn2313def.inc"
.list

.equ BTN = PD2
.equ BTN_DDR = DDRD
.equ BTN_PORT = PORTD

.equ LED = PD3
.equ LED_DDR = DDRD
.equ LED_PORT = PORTD

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
    sbi LED_DDR, LED
    sbi LED_PORT, LED

    ; Set button as input and pullup high
    cbi BTN_DDR, BTN
    sbi BTN_PORT, BTN

    cli

    ; Configure external interrupt as falling edge
    in tmp, MCUCR
    cbr tmp, (1<<ISC00)
    sbr tmp, (1<<ISC01)
    out MCUCR, tmp

    ; Enable external interrupt
    in tmp, GIMSK
    sbr tmp, (1<<INT0)
    cbr tmp, (1<<INT1)|(1<<PCIE)
    out GIMSK, tmp

    sei

loop:
    rjmp loop

ToggleLED:
    ldi k, (1<<LED)
    in tmp, LED_PORT
    eor tmp, k
    out LED_PORT, tmp
    reti
