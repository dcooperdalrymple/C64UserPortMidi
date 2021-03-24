/**
 * Title: C64 UserPort MIDI - C64 Shift & Flag Speed Test
 * Author: D Cooper Dalrymple
 * Created: 22/03/2021
 * Updated: 22/03/2021
 * https://dcooperdalrymple.com/
 */

#include <avr/io.h>
#include <util/delay.h>
#include "../shift.h"

#define FLAG PB3

#define LOAD_DELAY 5000
#define ROW_DELAY 2000

static void data_write(uint8_t data);

int main(void) {
    shift_init();

    // Set up C64 User Port flag
    DDRB |= (1<<FLAG);
    PORTB |= (1<<FLAG); // Keep flag high, active on low

    // Wait for c64 to load
    _delay_ms(LOAD_DELAY);

    uint8_t i;
    while (1) {

        // 200us delay
        data_write(0x0F);
        _delay_us(200);
        data_write(200);
        _delay_us(200);
        for (i = 0; i < 4; i++) {
            data_write(0xAA);
            _delay_us(200);
            data_write(0x55);
            _delay_us(200);
        }
        _delay_ms(ROW_DELAY);

        // 100us delay
        data_write(0x0F);
        _delay_us(100);
        data_write(100);
        _delay_us(100);
        for (i = 0; i < 4; i++) {
            data_write(0xAA);
            _delay_us(100);
            data_write(0x55);
            _delay_us(100);
        }
        _delay_ms(ROW_DELAY);

        // 50us delay (if 9.6Mhz, use 50us delay; I think the delay is due to the speed of the interrupt on the C64)
        data_write(0x0F);
        _delay_us(50);
        data_write(50);
        _delay_us(50);
        for (i = 0; i < 4; i++) {
            data_write(0xAA);
            _delay_us(50);
            data_write(0x55);
            _delay_us(50);
        }
        _delay_ms(ROW_DELAY);

        // 20us delay
        data_write(0x0F);
        _delay_us(20);
        data_write(20);
        _delay_us(20);
        for (i = 0; i < 4; i++) {
            data_write(0xAA);
            _delay_us(20);
            data_write(0x55);
            _delay_us(20);
        }
        _delay_ms(ROW_DELAY);

        // 15us delay
        data_write(0x0F);
        _delay_us(15);
        data_write(15);
        _delay_us(15);
        for (i = 0; i < 4; i++) {
            data_write(0xAA);
            _delay_us(15);
            data_write(0x55);
            _delay_us(15);
        }
        _delay_ms(ROW_DELAY);

        // 10us delay
        data_write(0x0F);
        _delay_us(10);
        data_write(10);
        _delay_us(10);
        for (i = 0; i < 4; i++) {
            data_write(0xAA);
            _delay_us(10);
            data_write(0x55);
            _delay_us(10);
        }
        _delay_ms(ROW_DELAY);

        // 5us delay
        data_write(0x0F);
        _delay_us(5);
        data_write(5);
        _delay_us(5);
        for (i = 0; i < 4; i++) {
            data_write(0xAA);
            _delay_us(5);
            data_write(0x55);
            _delay_us(5);
        }
        _delay_ms(ROW_DELAY);

        // no delay (if 1.2Mhz, use no delay)
        data_write(0x0F);
        data_write(0);
        for (i = 0; i < 4; i++) {
            data_write(0xAA);
            data_write(0x55);
        }
        _delay_ms(ROW_DELAY);

    }
}

void data_write(uint8_t data) {
    // Ensure that flag is high
    PORTB |= (1<<FLAG);

    // Write data to register
    shift_write(data);

    // Set flag low to signal to C64 that data is ready
    PORTB &= ~(1<<FLAG);
}
