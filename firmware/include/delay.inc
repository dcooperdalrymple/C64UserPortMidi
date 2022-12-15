; Configured for 1MHz

.def UH = r25
.def UL = r24
.def MH = r31 ; Same as ZH
.def ML = r30 ; Same as ZL

; Use UH/UL pair for number of microseconds, not very accurate especially with lower values
DelayMicroseconds:
    sbiw UH:UL, 4 ; 2
    brpl DelayMicroseconds ; 1(false)/2(true)
    ret ; 4

; Use MH/ML pair for number of milliseconds, also uses UH/UL for microseconds
DelayMilliseconds:
    ldi UH, HIGH(1000)
    ldi UL, LOW(1000)
    rcall DelayMicroseconds

    sbiw MH:ML, 1
    brne DelayMilliseconds
    ret
