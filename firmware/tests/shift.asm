; Title: C64 UserPort MIDI - Shift Register Test
; Author: D Cooper Dalrymple
; Created: 02/03/2021
; Updated: 25/03/2021
; https://dcooperdalrymple.com/

.nolist
.include "tn13Adef.inc"
.list

.def tmp = r16
.def i = r17
.def j = r18
.def k = r19

.org $0000 ; Hard Reset
    rjmp init

.org $000A

.include "delay.asm"
.include "shift.asm"

init:
    rcall ShiftInit

loop:
    ldi data, $AA
    rcall ShiftByte
    ldi tmp, 1
    rcall DelaySeconds

    ldi data, $55
    rcall ShiftByte
    ldi tmp, 1
    rcall DelaySeconds

    rjmp loop
