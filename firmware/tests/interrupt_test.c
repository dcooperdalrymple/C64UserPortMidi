/**
 * Title: C64 UserPort MIDI - Simple Interrupt Test
 * Author: D Cooper Dalrymple
 * Created: 24/03/2021
 * Updated: 24/03/2021
 * https://dcooperdalrymple.com/
 */

#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>

#define BTN     PB1
#define LED     PB0

int main(void) {
    // Set Led as output and start high
    DDRB |= (1<<LED);
    PORTB |= (1<<LED);

    // Set button as input and pullup high
    DDRB &= ~(1<<BTN);
    PORTB |= (1<<BTN);

    cli();
    MCUCR |= (1<<ISC01);
	MCUCR &= ~(1<<ISC00);
    GIMSK &= ~(1<<PCIE);
    GIMSK |= (1<<INT0);
    sei();

    while (1) { }
}

ISR(INT0_vect) {
	PORTB ^= (1<<LED); // Toggle LED
}
