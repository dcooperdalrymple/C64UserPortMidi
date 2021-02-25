/**
 * Title: C64 UserPort MIDI
 * Author: D Cooper Dalrymple
 * Created: 24/02/2021
 * Updated: 24/02/2021
 * https://dcooperdalrymple.com/
 */

#ifndef F_CPU
#define F_CPU (9600000UL)
#endif

// Software UART settings
#define	UART_RX_ENABLED (1)
#define UART_RX PB0
#ifndef UART_BAUDRATE
#define UART_BAUDRATE (31250)
#endif

// Setup libraries
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include "uart.h"

// Midi
#define BUFFER 3

// Data Bus
#define SER DDB1
#define SRCLK DDB2
#define FLAG DDB3
#define OE DDB4

//static void midi_init();
//static uint8_t midi_read();

static void bus_init();
static void bus_write(uint8_t data);

int main(void) {
    bus_init();

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
        bus_write(s);
        p = buff;
        while (*(p) != -1) {
            bus_write(*(p++));
        }
    }
}

// 74HC595 Data Bus Shift Register

void bus_init() {
    DDRB |= (1<<SER) | (1<<SRCLK) | (1<<FLAG) | (1<<OE); // Set all as output
    PORTB |= (1<<OE) | (1<<FLAG); // Keep output latch & flag high, active on low
    PORTB &= ~(1<<SRCLK); // Start clock low
}

void bus_write(uint8_t data) {
    PORTB &= ~(1<<OE); // Set latch low

    uint8_t i;
    for (i = 0; i < 8; i++) {
        if (!!(data & (1 << (7 - i)))) {
            PORTB |= 1<<SER;
        } else {
            PORTB &= ~(1<<SER);
        }
        PORTB |= 1<<SRCLK;
        PORTB &= ~(1<<SRCLK);
    }

    PORTB |= 1<<OE; // Set latch high

    // Trigger C64 UserPort flag interrupt
    PORTB &= ~(1<<FLAG);
    _delay_us(20); // arbitrary delay
    PORTB |= 1<<FLAG;
}
