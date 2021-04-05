.def UH = r25
.def UL = r24
.def MH = r31 ; Same as ZH
.def ML = r30 ; Same as ZL

; Use UH/UL pair for number of microseconds, not very accurate especially with lower values
DelayMicroseconds:
    nop
    nop
    nop
    nop
    nop
    sbiw UL, 1
    brne DelayMicroseconds
    ret

; Use MH/ML pair for number of milliseconds, also uses UH/UL for microseconds
DelayMilliseconds:
    ldi UH, HIGH(1000)
    ldi UL, LOW(1000)
    rcall DelayMicroseconds

    sbiw ML, 1
    brne DelayMilliseconds
    ret
