; i = number of microseconds, not very accurate especially with lower values
DelayMicroseconds:
    ldi i, 2
DelayMicroseconds_loop:
    .rept 6
    nop
    .endr
    dec i
    brne DelayMicroseconds_loop
    ret

; j = number of milliseconds, uses i
DelayMilliseconds:
    ldi i, 19
    clc
DelayMilliseconds_loop:
    nop
    inc i
    brcc DelayMillis_loop

    dec j
    brne DelayMillis
    ret

; tmp = number of seconds, uses i, j, & k
DelaySeconds:
    ldi k, 4
DelaySeconds_loop:
    ldi j, 250
    rcall DelayMillis
    dec k
    brne DelaySeconds_loop

    dec tmp
    brne DelaySeconds
    ret
