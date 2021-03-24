/**
 * Title: C64 UserPort MIDI - Midi Input Test
 * Author: D Cooper Dalrymple
 * Created: 02/03/2021
 * Updated: 02/03/2021
 * https://dcooperdalrymple.com/
 */

#include <avr/io.h>
#include <util/delay.h>

#define UART_RX PB0
#define LED PB1

#include "../uart.h"

int main(void) {
    // Set Led as output and start high
    DDRB |= (1<<LED);
    PORTB |= (1<<LED);

    while (1) {
        uart_getc();
        PORTB ^= (1<<LED); // Toggle every time message is received
    }
}
