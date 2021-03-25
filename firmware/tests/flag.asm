; Title: C64 UserPort MIDI - C64 Shift & Flag Speed Test
; Author: D Cooper Dalrymple
; Created: 22/03/2021
; Updated: 25/03/2021
; https://dcooperdalrymple.com/

.nolist
.include "tn13Adef.inc"
.list

.equ LOAD_DELAY = 5 ; seconds
.equ ROW_DELAY = 2 ; seconds

.def tmp = r16
.def i = r17
.def j = r18
.def k = r19

.org $0000 ; Hard Reset
    rjmp init

.org $000A

.include "delay.asm"
.include "flag.asm"
.include "shift.asm"

init:
    rcall FlagInit
    rcall ShiftInit

    ldi tmp, LOAD_DELAY
    rcall DelaySeconds

loop:
    ldi i, 200
    rcall data_test
    ldi i, 100
    rcall data_test
    ldi i, 50
    rcall data_test
    ldi i, 20
    rcall data_test
    ldi i, 15
    rcall data_test
    ldi i, 10
    rcall data_test
    ldi i, 5
    rcall data_test

    ; No delay
    ldi data, $0F
    rcall data_write
    ldi data, 0
    rcall data_write
    ldi k, 4
loop_nodelay:
    ldi data, $AA
    rcall data_write
    ldi data, $55
    rcall data_write
    dec k
    brne loop_nodelay
    ldi tmp, ROW_DELAY
    rcall DelaySeconds

    rjmp loop

; i is us delay
data_test:
    ldi data, $0F
    rcall data_write
    rcall DelayMicroseconds
    ldi data, 200
    rcall data_write
    rcall DelayMicroseconds

    ldi k, 4
data_test_loop:
    ldi data, $AA
    rcall data_write
    rcall DelayMicroseconds
    ldi data, $55
    rcall data_write
    rcall DelayMicroseconds
    dec k
    brne loop_200

    ldi tmp, ROW_DELAY
    rcall DelaySeconds ; messes up i

    ret

data_write:
    rcall FlagClear
    rcall ShiftByte
    rcall FlagTrigger
    ret
