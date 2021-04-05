.equ SHIFT_DATA = PB0
.equ SHIFT_CLOCK = PB2
.equ SHIFT_LATCH = PB4
.equ SHIFT_RECV = PB3

.equ LATCH_DELAY = 50

.def data = r20

; Set up 74HC595 serial shift register
ShiftInit:

    ; Set all i/o as output
    in tmp, DDRB
    sbr tmp, (1<<SHIFT_DATA)|(1<<SHIFT_CLOCK)|(1<<SHIFT_LATCH)
    out DDRB, tmp

    ; Keep latch low, sets register on rising edge
    cbi PORTB, SHIFT_LATCH

    ; Start clock low
    cbi PORTB, SHIFT_CLOCK

    ; Set receiving pin as input
    cbi DDRB, SHIFT_RECV
    cbi PORTB, SHIFT_RECV ; Disable pull-up

    ret

; Send Byte to 74HC595 (data = byte), uses j
ShiftByte:

    ; Roll out each bit into data line
    ldi j, 8
ShiftByte_bit:
    rol data
    brcc ShiftByte_data_clear
ShiftByte_data_set:
    sbi PORTB, SHIFT_DATA
    rjmp ShiftByte_clock
ShiftByte_data_clear:
    cbi PORTB, SHIFT_DATA

; Pulse clock to store bit
ShiftByte_clock:
    sbi PORTB, SHIFT_CLOCK
    cbi PORTB, SHIFT_CLOCK

ShiftByte_dec:
    dec j
    brne ShiftByte_bit

    ; Wait until PA2 is high to indicate that C64 is ready to receive byte
ShiftByte_ready:
    sbis PINB, SHIFT_RECV
    rjmp ShiftByte_ready

    ; Set latch high to send data to output register (rising edge)
    sbi PORTB, SHIFT_LATCH

    ldi UH, HIGH(LATCH_DELAY)
    ldi UL, LOW(LATCH_DELAY)
    rcall DelayMicroseconds

    ; Return to low to cause c64 interrupt (falling edge)
    cbi PORTB, SHIFT_LATCH

    ; Wait until PA2 is low to indicate that C64 is in middle of interrupt
ShiftByte_receive:
    sbic PINB, SHIFT_RECV
    rjmp ShiftByte_receive

    ; Wait until PA2 is high to indicate that C64 is done processing byte
ShiftByte_complete:
    sbis PINB, SHIFT_RECV
    rjmp ShiftByte_complete

    ; Set data low for led
    cbi PORTB, SHIFT_DATA

    ret
