.equ MIDI_RX = PB1
.equ MIDI_DELAY_BIT = 101 ; 307 cycles (3 counter + 3*101 delay + 2 read)

.def delay = r21
.def counter = r22

MidiInit:
    cli

    rcall MidiClear

    ; Set as input
    cbi DDRB, MIDI_RX

    ; Enable internal pull-up resistor
    sbi PORTB, MIDI_RX

    ; Configure external interrupt as falling edge
    in tmp, MCUCR
    cbr tmp, (1<<ISC00)
    sbr tmp, (1<<ISC01)
    out MCUCR, tmp

    ; Enable external interrupt
    in tmp, GIMSK
    sbr tmp, (1<<INT0)
    cbr tmp, (1<<PCIE)
    out GIMSK, tmp

    sei
    ret

MidiReceive:                        ; 3 for init
    cli                             ; 1
    ldi counter, 0x80               ; 1
    ldi delay, (MIDI_DELAY_BIT)     ; 1

MidiReceive_bit:                    ; 3 for every iteration
    dec delay                       ; 1
    brne MidiReceive_bit            ; 2 (1 if false)
    ldi delay, (MIDI_DELAY_BIT)     ; 1

MidiReceive_read:                   ; 2 for read
    sbic PORTB, MIDI_RX             ; Skip next instruction if pin is low
    sec                             ; 2 (skip + sec)

    ror counter                     ; 1
    brcc MidiReceive_bit            ; 2 (1 if false)
MidiReceive_stop: ; Wait until high for stop bit
    sbis PORTB, MIDI_RX ; Skip next instruction if pin is high
    rjmp MidiReceive_stop

    ; Store in buffer
    st Y, counter
    inc YL

    sei
    reti

MidiClear:
    ; Reset buffer index to beginning of SRAM
    ldi YH, HIGH(SRAM_START)
    ldi YL, LOW(SRAM_START)
    ret

MidiRead:
    ; Wait until a byte is in the buffer, uses XH/XL as relative address
    inc XL
MidiRead_wait:
    cp XL, YL
    brsh MidiRead_wait
    ret
