; Title: C64 UserPort MIDI - C64 Shift & Flag Speed Test
; Author: D Cooper Dalrymple
; Created: 22/03/2021
; Updated: 25/03/2021
; https://dcooperdalrymple.com/

.nolist
.include "tn13Adef.inc"
.list

.equ LOAD_DELAY = 5000 ; milliseconds
.equ ROW_DELAY = 2000 ; milliseconds

.def tmp = r16
.def i = r17
.def j = r18
.def k = r19

.org $0000 ; Hard Reset
    rjmp init

.org $000A

.include "delay.inc"
.include "shift.inc"

init:
    rcall ShiftInit

    ldi MH, HIGH(LOAD_DELAY)
    ldi ML, LOW(LOAD_DELAY)
    rcall DelayMilliseconds

loop:
    ; Indicator
    ldi data, $0F
    rcall ShiftByte

    ldi data, $70
    rcall ShiftByte

    ; Flip-flop bits for rest of row
    ldi k, 4
loop_data:
    ldi data, $AA
    rcall ShiftByte
    ldi data, $55
    rcall ShiftByte
    dec k
    brne loop_data

    ldi MH, HIGH(ROW_DELAY)
    ldi ML, LOW(ROW_DELAY)
    rcall DelayMilliseconds

    rjmp loop
