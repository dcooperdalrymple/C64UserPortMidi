; Title: C64 UserPort MIDI - C64 Shift & Flag Speed Test
; Author: D Cooper Dalrymple
; Website: https://dcdalrymple.com/C64UserPortMidi/
; Created: 22/03/2021
; Updated: 13/12/2022
; HW Version: v1.0 RevA

.nolist
.include "tn2313def.inc"
.list

.equ LOAD_DELAY = 5000 ; milliseconds
.equ ROW_DELAY = 2000 ; milliseconds

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
.include "bus.inc"
.include "midi.inc" ; Just needed for BusReceive

init:
    rcall BusInit

    ; Set Led as output
    sbi LED_DDR, LED
    cbi LED_PORT, LED

    ldi MH, HIGH(LOAD_DELAY)
    ldi ML, LOW(LOAD_DELAY)
    rcall DelayMilliseconds

loop:
    ; Indicator
    ldi data, $0F
    rcall BusTransmit

    ldi data, $70
    rcall BusTransmit

    ; Flip-flop bits for rest of row
    ldi k, 4
loop_data:
    ldi data, $AA
    rcall BusTransmit
    ldi data, $55
    rcall BusTransmit
    dec k
    brne loop_data

    ldi MH, HIGH(ROW_DELAY)
    ldi ML, LOW(ROW_DELAY)
    rcall DelayMilliseconds

    rjmp loop
