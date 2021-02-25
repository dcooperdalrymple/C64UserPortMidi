; C64 UserPort MIDI Monitor
; Created by D Cooper Dalrymple 2021 - dcdalrymple.com
; Licensed under GNU LGPL V3.0
; Last revision: 25-02-2021

; Run with SYS32768

    processor 6502
    ;include "c64.h"

;================
; Cart header
;================

    SEG
    org $8000

eol     equ $0d ;Return
eof     equ $03 ;EOF CHR
fillch  equ $20 ;SPACE

buflen  equ 40

chrin   equ $ffcf
chrout  equ $ffd2
temptr  equ $fb

    ;.word initialize ;cold start
    ;.word initialize ;warm start
    ;.byte $c3,$c2,$cd,$38,$30 ;cbm80

    jmp start

hello:
    dc.b "HELLO WORLD!",$0d

print:
    ldy #0
show:
    lda (temptr),y
    cmp #eof
    beq done
    pha
    jsr chrout
    pla
    cmp #eol
    bne next
    jmp done
next:
    iny
    cpy #buflen
    bcc show
done:
    rts

start:
    lda #eol
    jsr chrout
    lda #<hello
    sta temptr
    lda #>hello
    sta temptr+1
    jsr print
    lda #eol
    jsr chrout

loop:
    inc $d020
    jmp loop

    rts

    org ($A000-1) ; Lo: $8000, Hi: $A000

    .byte $00

    END
