
;=======================================
; Print
; -----
; X - Lo byte of string memory location
; Y - Hi byte of string memory location
;
; String data must end with EOF.
; Max length of 40?
;=======================================

Print:
    stx temp+0
    sty temp+1

    ldy #0
.print_chr:
    lda (temp),y
    cmp #EOF
    beq .print_done
    pha
    jsr CHROUT
    pla

    iny
    jmp .print_chr

.print_done:
    rts

;============================================
; PrintHex
; -----
; A - Byte value to be printed as hex string
;============================================

PrintHex:
    tax

    ; Top nibble
    and #%11110000
    REPEAT 4
    lsr
    REPEND
    tay
    lda hex_data,y
    sta hexstr+1

    ; Bottom nibble
    txa
    and #%00001111
    tay
    lda hex_data,y
    sta hexstr+2

    ; Prepare string
    lda hex_prepend
    sta hexstr+0
    lda hex_append
    sta hexstr+3
    ;lda #EOL
    ;sta hexstr+4
    lda #EOF
    sta hexstr+4 ;5

    ldx #<hexstr
    ldy #>hexstr
    jsr Print

    rts
