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
#define FLAG PB3

#define MODE_SIMPLE 0
#define MODE_PACKET 1
#define MODE        MODE_PACKET

#if MODE == MODE_PACKET
#define FLAG_DELAY 50
#endif

#include "uart.h"
#include "shift.h"

static void data_write(uint8_t data);

int main(void) {
    shift_init();

    // Set up C64 User Port flag
    DDRB |= (1<<FLAG);
    PORTB |= (1<<FLAG); // Keep flag high, active on low

    #if MODE == MODE_SIMPLE
    while (1) {
        data_write(uart_getc());
    }
    #endif

    #if MODE == MODE_PACKET
    uint8_t s[3] = {0,0,0};
    uint8_t c, long_packet;
    while (1) {
        // Read first byte: command type (MSB) and midi channel (LSB)
        s[0] = uart_getc();

        // Wait until command and ignore system messages
        if ((s[0] & 0b10000000) == 0 || (s[0] & 0xf0) == 0xf0) continue;

        // Determine midi packet length
        c = s[0] & 0b01110000;
        long_packet = c != 0b01000000 && c != 0b01010000; // Program Change or Channel Pressure

        // Read data bytes
        s[1] = uart_getc();
        if (long_packet) s[2] = uart_getc();

        // Send packet
        data_write(s[0]);
        data_write(s[1]);
        if (long_packet) data_write(s[2]);
    }
    #endif

}

void data_write(uint8_t data) {
    // Ensure that flag is high
    PORTB |= (1<<FLAG);

    // Write data to register
    shift_write(data);

    // Set flag low to signal to C64 that data is ready
    PORTB &= ~(1<<FLAG);

    #ifdef FLAG_DELAY
    _delay_us(FLAG_DELAY);
    #endif
}
