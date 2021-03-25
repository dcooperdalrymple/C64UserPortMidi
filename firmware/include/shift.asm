.equ SHIFT_DATA = PB0
.equ SHIFT_CLOCK = PB2
.equ SHIFT_LATCH = PB4

.def data = r20

; Set up 74HC595 serial shift register
ShiftInit:

    ; Set all i/o as output
    in tmp, DDRB
    sbr tmp, (1<<SHIFT_DATA)|(1<<SHIFT_CLOCK)|(1<<SHIFT_LATCH)
    out DDRB, tmp

    ; Keep latch high, active on low
    sbi PORTB, SHIFT_LATCH

    ; Start clock low
    cbi PORTB, SHIFT_CLOCK

    ret

; Send Byte to 74HC595 (data = byte), uses j
ShiftByte:

    ; Start shift out
    cbi PORTB, SHIFT_LATCH

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

    ; Set latch high to send data to output register
    sbi PORTB, SHIFT_LATCH

    ; Set data low for led
    cbi PORTB, SHIFT_DATA

    ret
