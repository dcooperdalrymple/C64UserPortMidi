/**
 * Title: C64 UserPort MIDI - Midi Input Test
 * Author: D Cooper Dalrymple
 * Created: 02/03/2021
 * Updated: 02/03/2021
 * https://dcooperdalrymple.com/
 */

#include <avr/io.h>
#include <util/delay.h>

// Software UART settings
#define	UART_RX_ENABLED 1
#define UART_RX PB0
#ifndef UART_BAUDRATE
#define UART_BAUDRATE (31250UL)
#endif

#include "../uart.h"

#define LED PB3

int main(void) {
    // Set Led as output and start low
    DDRB |= (1<<LED);
    PORTB &= ~(1<<LED);

    char s;
    while (1) {
        s = uart_getc();
        switch (s & 0xF0) {
            case 0x90: // Note On
                PORTB |= (1<<LED);
                break;
            case 0x80: // Note Off
                PORTB &= ~(1<<LED);
                break;
        }
        // Data is ignored since MSB is always 0
    }
}
