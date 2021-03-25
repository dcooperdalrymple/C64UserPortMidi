.equ MIDI_RX = PB1
.equ MIDI_DELAY_START = 101
.equ MIDI_DELAY_BIT = 100

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

MidiReceive:
    cli

    ldi delay, (MIDI_DELAY_START)
    ldi counter, 0x80
MidiReceive_bit:
    subi delay, 1
    brne MidiReceive_bit
    ldi delay, (MIDI_DELAY_BIT)
    sbic PORTB, MIDI_RX ; Skip next instruction if pin is low
    sec
    ror counter
    brcc MidiReceive_bit
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
