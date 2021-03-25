; C64 UserPort MIDI Monitor
; Created by D Cooper Dalrymple 2021 - dcdalrymple.com
; Licensed under GNU LGPL V3.0
; Created: 25-02-2021
; Last revision: 24-03-2021

    processor 6502
    include "c64.h"

DEBUG   = 0

;===================
; Program Constants
;===================

; Data Printing
HEX_LINE_MAX    = #10
DEC_LINE_MAX    = #8

; MIDI Parsing
COMM_NOTE_OFF       = #$08
COMM_NOTE_ON        = #$09
COMM_PRESSURE       = #$0A
COMM_CC             = #$0B
COMM_PC             = #$0C
COMM_CHAN_PRESSURE  = #$0D
COMM_PITCH_BEND     = #$0E
;COMM_SYSTEM         = #$0F

COMM_NOTE_OFF_LEN       = #2
COMM_NOTE_ON_LEN        = #2
COMM_PRESSURE_LEN       = #2
COMM_CC_LEN             = #2
COMM_PC_LEN             = #1
COMM_CHAN_PRESSURE_LEN  = #1
COMM_PITCH_BEND_LEN     = #2


; Variables in RAM

    SEG.U zp_vars
    org $00FB ; Only 4 bytes available in zero page

temp    ds 4

    SEG.U zp_vars2
    org $02A7 ; 88 bytes of zero page

hexstr  ds 5
buflen  ds 1
buffer  ds 16
index   ds 1
mode    ds 1 ; Bit #6 & #7: %00 = hex, %01 = dec, %10 = midi

linelen ds 1

mcomm   ds 1 ; Midi Command
mchan   ds 1 ; Midi Channel
mlen    ds 1 ; Midi Data Length
mdata   ds 2 ; Midi Data

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

    ; Start buffer at 0
    lda #0
    sta buflen

    ; Set interrupt handler address
    lda #<flag_handler
    sta NMIVEC+0
    lda #>flag_handler
    sta NMIVEC+1

    ; Disable all other interrupts
    lda #%01111111 ; Bit #7 is fill bit
    sta CIA1ICR
    sta CIA2ICR
    lda #0
    sta $D01A ; Raster Interrupts

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

;=================
; Keyboard Config
;=================

key_init:

    ; Keyboard buffer of 1 (kinda disable)
    lda #1
    sta KEYLEN

    ; Disable key repeats
    lda #%01000000
    sta KEYREP

    ; Set initial mode (hex)
    lda #%00000000
    sta mode

    lda #0
    sta buflen

#if DEBUG == 1
    ; Test buffer data
    lda #%10000000
    sta mode
    lda #14
    sta buflen
    lda #$9B
    sta buffer+0
    lda #$47
    sta buffer+1
    lda #$9B
    sta buffer+2
    lda #$00
    sta buffer+3
    lda #$7B
    sta buffer+4
    lda #$9B
    sta buffer+5
    lda #$48
    sta buffer+6
    lda #$9B
    sta buffer+7
    lda #$00
    sta buffer+8
    lda #$7B
    sta buffer+9

    lda #$BB
    sta buffer+10
    lda #$7F
    sta buffer+11
    lda #$BB
    sta buffer+12
    lda #$00
    sta buffer+13
#endif

;=====================
; Program Info Header
;=====================

screen_init:

    ; Set my preferred colors ;)
    lda #COL_BLACK
    sta BDCOL
    sta BKCOL
    lda #COL_GREEN
    sta CHCOL

    ; Set cursor to 0x0
    lda #0
    sta CURCOL
    sta CURROW

    ; Reset line length
    lda #0
    sta linelen

screen_clear:
    lda #SPACE
    ldx #0 ; loops around to $FF as decrementing
screen_clear_loop:
    sta $0400,x
    sta $0500,x
    sta $0600,x
    sta $0700,x
    dex
    bne screen_clear_loop

print_info:
    ; Print info header data
    ldx #<info_str
    ldy #>info_str
    jsr Print

    bit mode
    bvs print_mode_dec
    bmi print_mode_midi

print_mode_hex:
    ldx #<mode_hex_str
    ldy #>mode_hex_str
    jmp print_mode

print_mode_dec:
    ldx #<mode_dec_str
    ldy #>mode_dec_str
    jmp print_mode

print_mode_midi:
    ldx #<mode_midi_str
    ldy #>mode_midi_str

print_mode:
    jsr Print

;=====================
; Keyboard Processing
;=====================

key_check:
    jsr SCNKEY
    jsr GETIN

    cmp #KEY_NA
    beq buffer_check

    cmp #KEY_F1
    beq mode_hex
    cmp #KEY_F3
    beq mode_dec
    cmp #KEY_F5
    beq mode_midi

    jmp buffer_check

mode_hex:
    lda #0
    jmp mode_set
mode_dec:
    lda #%01000000
    jmp mode_set
mode_midi:
    lda #%10000000
mode_set:
    sta mode
    jmp screen_init ; Reset screen

;========================
; MIDI Buffer Processing
;========================

buffer_check:
    lda buflen
    beq key_check

    bit mode
    bvs buffer_dec
    bmi buffer_midi

buffer_hex:
    ldy #0
    sty index
buffer_hex_loop:

    ; Ignore system messages
    lda buffer,y
    and #$f0
    cmp #$f0
    beq buffer_hex_skip

    lda buffer,y
    jsr PrintHex

buffer_hex_skip:
    inc index
    ldy index
    cpy buflen
    bne buffer_hex_loop

    jmp buffer_reset

buffer_dec:
    ldy #0
    sty index
buffer_dec_loop:

    ; Ignore system messages
    lda buffer,y
    and #$f0
    cmp #$f0
    beq buffer_dec_skip

    lda buffer,y
    jsr PrintDec

buffer_dec_skip:
    inc index
    ldy index
    cpy buflen
    bne buffer_dec_loop

    jmp buffer_reset

buffer_midi:
    ldy #0
    sty index
buffer_midi_loop:
    lda buffer,y
    and #%10000000
    beq buffer_midi_skip

buffer_midi_status:
    ; command
    lda buffer,y
    and #%01110000 ; remove msb status flag
    REPEAT 4
    lsr
    REPEND
    sta mcomm

    ; channel
    lda buffer,y
    and #$0f
    sta mchan

    ldy mcomm
    lda midi_comm_len,y
    sta mlen

    clc
    adc index
buffer_midi_wait:
    cmp buflen
    bcs buffer_midi_wait

    ldx #0
buffer_midi_data:
    inc index
    ldy index

    lda buffer,y
    sta mdata,x

    inx
    cpx mlen
    bne buffer_midi_data

    jsr PrintMidi

buffer_midi_skip:
    inc index
    ldy index
    cpy buflen
    bne buffer_midi_loop

    ;jmp buffer_reset

buffer_reset:
    lda #0
    sta buflen

    jmp key_check ; Go back to keyboard loop after flushing out buffer

;========================
; Flag Interrupt Handler
;========================

flag_handler:

    ; Save registers (only a & y)
    pha
    tya
    pha

    ; Read User Port GPIO byte
    lda CIA2B

    ; Store in buffer
    ldy buflen
    sta buffer,y

    ; Increment buffer length
    inc buflen

    ; Restore registers
    pla
    tay
    pla

    bit CIA2ICR ; Tell interrupt to reset
    rti ; Return to main process

;====================
; String & Midi Data
;====================

info_str:
    .byte $0E,#CLS ; Change case & cls
    dc.b "c64 uSERpORT mIDI mONITOR",#EOL
    dc.b "d cOOPER dALRYMPLE",#EOL
    dc.b "v0.2 - 2021.03.24",#EOL,#EOL
    .byte #EOF

mode_hex_str:
    dc.b "hEX mODE",#EOL,#EOL
    .byte #EOF

mode_dec_str:
    dc.b "dECIMAL mODE",#EOL,#EOL
    .byte #EOF

mode_midi_str:
    dc.b "mIDI mODE",#EOL,#EOL
    .byte #EOF

hex_prepend:
    dc.b "$"
hex_data:
    dc.b "0123456789abcdef"

midi_comm_len:
    .byte #COMM_NOTE_OFF_LEN
    .byte #COMM_NOTE_ON_LEN
    .byte #COMM_PRESSURE_LEN
    .byte #COMM_CC_LEN
    .byte #COMM_PC_LEN
    .byte #COMM_CHAN_PRESSURE_LEN
    .byte #COMM_PITCH_BEND_LEN

midi_comm_strs:
    .byte #<midi_comm_note_off_str
    .byte #>midi_comm_note_off_str
    .byte #<midi_comm_note_on_str
    .byte #>midi_comm_note_on_str
    .byte #<midi_comm_pressure_str
    .byte #>midi_comm_pressure_str
    .byte #<midi_comm_cc_str
    .byte #>midi_comm_cc_str
    .byte #<midi_comm_pc_str
    .byte #>midi_comm_pc_str
    .byte #<midi_comm_chan_pressure_str
    .byte #>midi_comm_chan_pressure_str
    .byte #<midi_comm_pitch_bend_str
    .byte #>midi_comm_pitch_bend_str
midi_comm_note_off_str:
    dc.b "nOTE oFF        ",#EOF
midi_comm_note_on_str:
    dc.b "nOTE oN         ",#EOF
midi_comm_pressure_str:
    dc.b "pRESSURE        ",#EOF
midi_comm_cc_str:
    dc.b "cONTROL cHANGE  ",#EOF
midi_comm_pc_str:
    dc.b "pROGRAM cHANGE  ",#EOF
midi_comm_chan_pressure_str:
    dc.b "cHANNEL pRESSURE",#EOF
midi_comm_pitch_bend_str:
    dc.b "pITCH bEND      ",#EOF

midi_chan_str:
    dc.b "c: ",#EOF

midi_data_str:
    dc.b "d: ",#EOF

    include "routines.asm"

    org (HIROM-1) ; Lo: $8000, Hi: $A000
    .byte $00
    END
