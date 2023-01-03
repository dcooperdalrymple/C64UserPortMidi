; Title: C64 UserPort MIDI - Midi Input Test
; Author: D Cooper Dalrymple
; Website: https://dcdalrymple.com/C64UserPortMidi/
; Created: 02/03/2021
; Updated: 03/01/2023
; HW Version: v1.0 RevA

; MIDI reference: https://www.midi.org/specifications-old/item/table-1-summary-of-midi-message

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
.def command = r21
.def channel = r22
.def note = r23
.def velocity = r24

.org $0000 ; Hard Reset
    rjmp init

.org $000A

.include "midi.inc"

init:
    ; Set Stack Pointer to top of RAM
    ldi tmp, low(RAMEND)
    out SPL, tmp

    ; Configure led output
    sbi DDRD, LED
    sbi LED_PORT, LED ; Start high to indicate initialization

    ; Initialize components
    rcall MidiInit

    cbi LED_PORT, LED ; Initialization process complete

Process:
    ; Get first byte of midi message
    rcall MidiReceive ; blocking

    ; Make sure that the 7th-bit is set to indicate status byte
    sbrs data, 7
    rjmp Process

    ; Extract command and channel
    mov command, data
    andi command, 0xF0
    mov channel, data
    andi channel, 0x0F

    ; Check the type of command
    cpi command, 0x90
    breq Midi_NoteOn

    cpi command, 0x80
    breq Midi_NoteOff

    ; Start over if we don't recognize the command
    rjmp Process

Midi_NoteOn:
    ; Get note
    rcall MidiReceive
    mov note, data

    ; Get velocity
    rcall MidiReceive
    mov velocity, data

    cpi velocity, 0
    breq Midi_NoteOff_process

Midi_NoteOn_process:
    sbi LED_PORT, LED

    rjmp Midi_Complete

Midi_NoteOff:
    ; Get note
    rcall MidiReceive
    mov note, data

    ; Get velocity
    rcall MidiReceive
    mov velocity, data

Midi_NoteOff_process:
    cbi LED_PORT, LED

    ;rjmp Midi_Complete

Midi_Complete:
    rjmp Process
