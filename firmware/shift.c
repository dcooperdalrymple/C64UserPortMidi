// 74HC595 Data Bus Shift Register Output
// Written by D Cooper Dalrymple 2021

#include <avr/io.h>
#include <util/delay.h>
#include "shift.h"

void shift_init(void) {
    DDRB |= (1<<SHIFT_DATA) | (1<<SHIFT_CLOCK) | (1<<SHIFT_LATCH); // Set all as output
    PORTB |= (1<<SHIFT_LATCH); // Keep latch high, active on low
    PORTB &= ~(1<<SHIFT_CLOCK); // Start clock low
}

void shift_write(uint8_t data) {
    PORTB &= ~(1<<SHIFT_LATCH); // Set latch low
    #ifdef SHIFT_DELAY
    _delay_us(1);
    #endif

    uint8_t i;
    for (i = 0; i < 8; i++) {
        if (!!(data & (1 << (7 - i)))) {
            PORTB |= (1<<SHIFT_DATA);
        } else {
            PORTB &= ~(1<<SHIFT_DATA);
        }
        PORTB |= (1<<SHIFT_CLOCK);
        #ifdef SHIFT_DELAY
        _delay_us(1);
        #endif
        PORTB &= ~(1<<SHIFT_CLOCK);
        #ifdef SHIFT_DELAY
        _delay_us(1);
        #endif
    }

    PORTB |= (1<<SHIFT_LATCH); // Set latch high
    #ifdef SHIFT_DELAY
    _delay_us(1);
    #endif

    PORTB &= ~(1<<SHIFT_DATA); // Set data low for led
}
