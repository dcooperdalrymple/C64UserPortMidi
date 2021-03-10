
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
Print_chr:
    lda (temp),y
    cmp #EOF
    beq Print_done
    pha
    jsr CHROUT
    pla

    iny
    jmp Print_chr

Print_done:
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
    lda #EOF
    sta hexstr+4

    ldx #<hexstr
    ldy #>hexstr
    jsr Print

    ; Check line length to avoid weird looping
    inc linelen
    lda linelen
    cmp #HEX_LINE_MAX
    bne PrintHex_skip

    jsr PrintLine

PrintHex_skip:
    rts

;================================================
; PrintDec
; -----
; A - Byte value to be printed as decimal string
;================================================

PrintDec:
    sta temp+0

    ; Switch to decimal mode
    clc
    sed

    ; Clear result
    lda #0
    sta temp+1
    sta temp+2

    ldx #8 ; bits
PrintDec_bit:
    asl temp+0 ; shift out bit

    ; add into result
    lda temp+1
    adc temp+1
    sta temp+1

    ; propagate any carry
    lda temp+2
    adc temp+2
    sta temp+2

    ; repeat for next bit
    dex
    bne PrintDec_bit

    ; Back to binary
    cld

    ldy #2
    sty temp+3
PrintDec_loop:

    ; Top nibble
    lda temp,y
    and #$f0
    REPEAT 4
    lsr
    REPEND
    adc #$30
    pha
    jsr CHROUT
    pla

    ; Bottom nibble
    ldy temp+3
    lda temp,y
    and #$0f
    adc #$30
    pha
    jsr CHROUT
    pla

    dec temp+3
    ldy temp+3
    bne PrintDec_loop

    ; Space at the end
    jsr PrintSpace

    ; Check line length
    inc linelen
    lda linelen
    cmp #DEC_LINE_MAX
    bne PrintDec_skip

    jsr PrintLine

PrintDec_skip:
    rts

PrintNibble:
    REPEAT 4
    asl
    REPEND
    sta temp+0

    ; Switch to decimal mode
    clc
    sed

    ; Clear result
    lda #0
    sta temp+1

    ldx #4 ; bits
PrintNibble_bit:
    asl temp+0 ; shift out bit

    ; add into result
    lda temp+1
    adc temp+1
    sta temp+1

    ; repeat for next bit
    dex
    bne PrintNibble_bit

    ; Back to binary
    cld

    ; Top nibble
    lda temp+1
    and #$f0
    REPEAT 4
    lsr
    REPEND
    adc #$30
    pha
    jsr CHROUT
    pla

    ; Bottom nibble
    lda temp+1
    and #$0f
    adc #$30
    pha
    jsr CHROUT
    pla

    ; Space at the end
    jsr PrintSpace

    rts


PrintLine:
    lda #EOL
    pha
    jsr CHROUT
    pla

    lda #0
    sta linelen

    rts

PrintSpace:
    lda #SPACE
    pha
    jsr CHROUT
    pla

    rts

PrintMidi:

    ; Print MIDI command name
    lda mcomm
    asl
    tay
    ldx midi_comm_strs,y
    iny
    lda midi_comm_strs,y
    tay
    jsr Print

    jsr PrintSpace

    ; Print channel nibble
    ldx #<midi_chan_str
    ldy #>midi_chan_str
    jsr Print

    lda mchan
    jsr PrintNibble

    ; Print data
    ldx #<midi_data_str
    ldy #>midi_data_str
    jsr Print

    ldy #0
    sty temp+3
PrintMidi_data:
    lda mdata,y
    jsr PrintHex

    inc temp+3
    ldy temp+3
    cpy mlen
    bne PrintMidi_data

    ; Finish up with a line return
    jsr PrintLine

    rts
