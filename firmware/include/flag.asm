.equ FLAG = PB3
.equ FLAG_DELAY = (50/3)

FlagInit: ; Set up C64 User Port flag

    ; Set i/o as output
    sbi DDRB, FLAG

    ; Start flag high, active on low
    sbi PORTB, FLAG

    ret

FlagClear:
    sbi PORTB, FLAG
    ret

FlagTrigger:
    cbi PORTB, FLAG
    ret
