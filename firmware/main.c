/**
 * Title: C64 UserPort MIDI
 * Author: D Cooper Dalrymple
 * Created: 24/02/2021
 * Updated: 02/03/2021
 * https://dcooperdalrymple.com/
 */

#include <avr/io.h>
#include <util/delay.h>

#define UART_RX PB0
#define BUFFER 3 // Serial buffer (midi package is 3 bytes max)
#define FLAG PB3

#include "uart.h"
#include "shift.h"

static void data_write(uint8_t data);

int main(void) {
    shift_init();

    // Set up C64 User Port flag
    DDRB |= (1<<FLAG);
    PORTB |= (1<<FLAG); // Keep flag high, active on low

    uint8_t s;
    while (1) {
        s = uart_getc();
        data_write(s);
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
