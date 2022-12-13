; Title: C64 UserPort MIDI - Midi Input Test
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
.def data = r20

.org $0000 ; Hard Reset
    rjmp init

.org $000A

.include "midi.inc"

init:
    ; Set Led as output and start low
    sbi LED_DDR, LED
    cbi LED_PORT, LED

    rcall MidiInit

loop:
    cpi YL, LOW(SRAM_START)
    breq wait

    ldi XH, HIGH(SRAM_START)
    ldi XL, LOW(SRAM_START)

loop_read:
    ;ld tmp, X

    ;sbrs tmp, 7
    ;rjmp loop_next

    ; Toggle LED
    ldi k, (1<<LED)
    in tmp, LED_PORT
    eor tmp, k
    out LED_PORT, tmp

loop_next:
    inc XL
    cpse XL, YL
    rjmp loop_read

    rcall MidiClear
    rjmp loop

wait:
    cpi YL, LOW(SRAM_START)
    breq wait

    ldi XH, HIGH(SRAM_START)
    ldi XL, LOW(SRAM_START)

read:

    ; Just check the command byte
    ld tmp, X
    andi tmp, 0xF0

    cpi tmp, 0x90
    breq note_on

    cpi tmp, 0x80
    breq note_off

    rjmp next

note_on:
    ; Read 2 more bytes
    rcall MidiReceive ; Note
    rcall MidiReceive ; Velocity

    ; Check if velocity is zero (aka note off)
    ld tmp, X
    cpi tmp, 0
    breq note_off_b

    sbi LED_PORT, LED
    rjmp next

note_off:
    ; Read 2 more bytes
    rcall MidiReceive ; Note
    rcall MidiReceive ; Velocity

note_off_b:
    cbi LED_PORT, LED

next:
    inc XL
    cpse XL, YL
    rjmp read

    rcall MidiClear
    rjmp wait
