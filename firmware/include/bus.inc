; Data output and input from the User Port Bus
; Make sure to set INT0 to BusReceive within main file

.equ RECV = PD2
.equ FLAG = PD5

.equ FLAG_DELAY = 50 ; microseconds

.def data = r20

BusInit:
    ; Configure flag output
    sbi DDRD, FLAG
    cbi PORTD, FLAG ; Keep flag low, sets register on rising edge

    ; Set receiving pin as input
    cbi DDRD, RECV
    cbi PORTD, RECV ; Disable pull-up

    ; Set up receive interrupt for falling edge (INT0/PD2)
    in tmp, MCUCR
    sbr tmp, (1<<ISC01)
    cbr tmp, (1<<ISC00)
    out MCUCR, tmp

    ; Set bus as input and enable interrupt on init
    rcall BusInput

    ret

BusOutput:
    ; Disable INT0 interrupt
    in tmp, GIMSK
    cbr tmp, (1<<INT0)
    out GIMSK, tmp

    ; Set all i/o as output
    ldi tmp, 0xFF ; PB0-7
    out DDRB, tmp

    ret

BusInput:
    ; Set all i/o as input
    ldi tmp, 0x00 ; PB0-7
    out DDRB, tmp

    ; Enable INT0 interrupt
    in tmp, GIMSK
    sbr tmp, (1<<INT0)
    out GIMSK, tmp

    ret

BusTransmit: ; Use data as byte value
    cli

    ; Ensure that flag is low
    cbi PORTD, FLAG

    ; Wait until PA2/RECV is high to indicate that C64 is ready to receive byte
BusTransmit_ready:
    sbis PIND, RECV
    rjmp BusTransmit_ready

    ; Write byte to port
    rcall BusOutput ; Ensure that bus is set to output and interrupt is disabled
    out PORTB, data

    ; Set flag high to send data to output register (rising edge)
    sbi PORTD, FLAG

    ; Delay long enough for C64 to trigger interrupt
    ldi UH, HIGH(FLAG_DELAY)
    ldi UL, LOW(FLAG_DELAY)
    rcall DelayMicroseconds

    ; Return to low to cause c64 interrupt (falling edge)
    cbi PORTD, FLAG

    ; Wait until PA2 is low to indicate that C64 is in middle of interrupt
BusTransmit_receive:
    sbic PIND, RECV
    rjmp BusTransmit_receive

    ; Wait until PA2 is high to indicate that C64 is done processing byte
BusTransmit_complete:
    sbis PIND, RECV
    rjmp BusTransmit_complete

    ; Set bus back as floating input and enable interrupt
    rcall BusInput
    sei

    ret

; Will trigger if
BusReceive:
    cli
    sbi PORTD, LED

    in tmp, PORTB
    ; TODO: Check 8th-bit to indicate control parameter vs MIDI output
    rcall MidiTransmit

    cbi PORTD, LED
    sei
    reti
