/**
 * Title: C64 UserPort MIDI
 * Author: D Cooper Dalrymple
 * Created: 24/02/2021
 * Updated: 02/03/2021
 * https://dcooperdalrymple.com/
 */

#ifndef F_CPU
#define F_CPU (9600000UL)
#endif

#include <avr/io.h>
#include <util/delay.h>

// Software UART settings
#define	UART_RX_ENABLED (1)
#define UART_RX PB0
#ifndef UART_BAUDRATE
#define UART_BAUDRATE (31250)
#endif

#include "uart.h"
#include "shift.h"

#define BUFFER 3 // Serial buffer (midi package is 3 bytes max)
#define FLAG PB3

static void data_write(uint8_t data);

int main(void) {
    shift_init();

    // Set up C64 User Port flag
    DDRB |= (1<<FLAG);
    PORTB |= (1<<FLAG); // Keep flag high, active on low

    char s, l, *p, buff[BUFFER+1];
    while (1) {
        // Read status byte
        s = uart_getc();

        // Message length
        switch (s & 0xF0) {
            case 0xC0: // Program Change
            case 0xD0: // Channel Aftertouch
                l = 1;
                break;
            default:
                l = 2;
                break;
        }

        // Store buffer
        p = buff;
        while (l-- > 0) {
            *(p++) = uart_getc();
        }
        *p = -1;

        // Write buffer to buspin
        data_write(s);
        p = buff;
        while (*(p) != -1) {
            data_write(*(p++));
        }
    }
}

void data_write(uint8_t data) {
    // Write data to register
    shift_write(data);

    // Trigger C64 User Port flag interrupt
    PORTB &= ~(1<<FLAG);
    _delay_us(20); // arbitrary delay
    PORTB |= (1<<FLAG);
}
