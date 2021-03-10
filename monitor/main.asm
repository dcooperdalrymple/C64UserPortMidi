; C64 UserPort MIDI Monitor
; Created by D Cooper Dalrymple 2021 - dcdalrymple.com
; Licensed under GNU LGPL V3.0
; Created: 25-02-2021
; Last revision: 10-03-2021

    processor 6502
    ;include "c64.h"

;===============
; C64 Constants
;===============

LOROM   = $8000
HIROM   = $A000
NMIVEC  = $0318 ; $0318-$0319 Interrupt Vector (2 bytes)

; CIA #1
CIA1A       = $DC00 ; User Port data port A (keyboard matrix columns & joystick/paddle #2)
CIA1B       = $DC01 ; User Port data port B (keyboard matrix rows & joystick/paddle #1)
CIA1DDRA    = $DC02 ; Data direction port A
CIA1DDRB    = $DC03 ; Data direction port B
CIA1ICR     = $DC0D ; Interrupt Control Register

; CIA #2
CIA2A       = $DD00 ; User Port data port A (serial bus access)
CIA2B       = $DD01 ; User Port data port B
CIA2DDRA    = $DD02 ; Data direction port A
CIA2DDRB    = $DD03 ; Data direction port B
CIA2ICR     = $DD0D ; Interrupt Control Register

CHROUT  = $FFD2
EOL     = $0D
EOF     = $03
CLS     = $93

;===================
; Program Constants
;===================

; Variables in RAM

    SEG.U zp_vars
    org $00FB ; Only 4 bytes available in zero page

temp    ds 4

    SEG.U zp_vars2
    org $02A7 ; 88 bytes of zero page

hexstr  ds 6
buflen  ds 1
buffer  ds 16
index   ds 1

;================
; Cart header
;================

    SEG
    org LOROM

    include "autostart.asm"

;====================================
; User Port Flag NMI Interrupt Setup
;====================================

flag_init:
    sei ; Disable interrupts

    ; Set interrupt handler address
    lda #<flag_handler
    sta NMIVEC+0
    lda #>flag_handler
    sta NMIVEC+1

    ; Disable all other interrupts
    lda #%00001111 ; Bit #7 is fill bit
    sta CIA2ICR

    ; Enable Flag Interrupt
    lda #%10010000
    sta CIA2ICR

    cli ; Enable interrupts

;================
; User Port GPIO
;================

port_init:
    lda #0
    sta CIA2DDRB ; Set all as inputs on port b

;=====================
; Program Info Header
;=====================

print_info:
    ldx #<info_data
    ldy #>info_data
    jsr Print

;========================
; MIDI Buffer Processing
;========================

buffer_check:
    lda buflen
    beq buffer_check

    ldy #0
    sty index
buffer_loop:
    lda buffer,y
    jsr PrintHex

    inc index
    ldy index
    cpy buflen
    bne buffer_loop

buffer_reset:
    lda #0
    sta buflen

    jmp buffer_check

;========================
; Flag Interrupt Handler
;========================

flag_handler:

    ; Read User Port GPIO byte
    lda CIA2B

    ; Store in buffer
    ldy buflen
    sta buffer,y

    ; Increment buffer length
    inc buflen

    bit CIA2ICR ; Tell interrupt to reset
    rti ; Return to main process

info_data:
    .byte $0E,#CLS ; Change case & cls
    dc.b "c64 uSERpORT mIDI mONITOR",#EOL
    dc.b "d cOOPER dALRYMPLE",#EOL
    dc.b "v0.1 - 2021.03.10",#EOL,#EOL
    .byte #EOF

hex_prepend:
    dc.b "$"
hex_data:
    dc.b "0123456789abcdef"
hex_append:
    dc.b " "

    include "routines.asm"

    org (HIROM-1) ; Lo: $8000, Hi: $A000
    .byte $00
    END
