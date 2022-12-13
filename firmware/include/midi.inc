; Reference: https://mitxela.com/projects/midi_on_the_attiny

; Indirect address reference, Y, is reserved for MIDI input buffer size

MidiInit:
    cli

    rcall MidiClear

    ; Set USART Baudrate Clock Divider
    ; MIDI requires 31.25kBit/s within 1% error
    ; Baudrate=CLK/16/(UBRR+1)
    ; UBBR=CLK/16/Baudrate-1
    ; Error=((Baudrate/Desired)-1)*100%
    ldi tmp, 0
    out UBRRH, tmp
    ldi tmp, 1 ; 1MHz=1, 8MHz=15
    out UBRRL, tmp

    ; Enable USART receiver and transmission
    ldi tmp, (1<<RXEN)|(1<<TXEN)
    out UCSRB, tmp

    ; Set frame format: 8 data bits, no parity, 1 stop bit
    ldi tmp, (1<<UCSZ1)|(1<<UCSZ0)
    out UCSRC, tmp

    rcall MidiFlush

    sei
    ret

MidiWait: ; Block until we have byte in midi buffer
    sbis UCSRA, RXC
    rjmp MidiWait
    ret

MidiReceive:
    sbis UCSRA, RXC
    ret

MidiReceive_byte:
    cli

    in tmp, UDR

    ; Store in buffer
    st Y, tmp
    inc YL

    ; Receive more bytes if there are any
    sbic UCSRA, RXC
    rjmp MidiReceive_byte

    sei
    ret

MidiTransmit: ; Value to send is stored in data
    cli

MidiTransmit_empty:
    ; Wait for empty transmit buffer
    sbis UCSRA, UDRE
    rjmp MidiTransmit_empty

    ; Put data into buffer and send
    out UDR, data

    sei
    ret

MidiClear:
    ; Reset buffer index to beginning of SRAM
    ldi YH, HIGH(SRAM_START)
    ldi YL, LOW(SRAM_START)

    ; Clear first index
    ldi tmp, 0
    st Y, tmp

    ret

MidiFlush:
    sbis UCSRA, RXC
    ret
    in tmp, UDR
    rjmp MidiFlush
