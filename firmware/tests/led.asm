; Title: C64 UserPort MIDI - Led Blink Test
; Author: D Cooper Dalrymple
; Website: https://dcdalrymple.com/C64UserPortMidi/
; Created: 02/03/2021
; Updated: 13/12/2022
; HW Version: v1.0 RevA

.nolist
.include "tn2313def.inc"
.list

.equ LED = PD3
.equ LED_DDR = DDRD
.equ LED_PORT = PORTD

.def tmp = r16
.def i = r17
.def j = r18
.def k = r19

.org $0000 ; Hard Reset
    rjmp init

.org $000A

.include "delay.inc"

init:
    ; Set Led as output and start high
    sbi LED_DDR, LED
    sbi LED_PORT, LED

loop:
    ldi i, (1<<LED)
    in tmp, LED_PORT
    eor tmp, i
    out LED_PORT, tmp

    ldi MH, HIGH(1000)
    ldi ML, LOW(1000)
    rcall DelayMilliseconds

    rjmp loop
