/**
 * Title: C64 UserPort MIDI - UART Echo Test
 * Author: D Cooper Dalrymple
 * Created: 02/03/2021
 * Updated: 02/03/2021
 * https://dcooperdalrymple.com/
 */

#define UART_BAUDRATE 115200

#include <avr/io.h>
#include <util/delay.h>

// Software UART settings
#define UART_TX_ENABLED 1
#define UART_TX PB0
#define	UART_RX_ENABLED 1
#define UART_RX PB1
#ifndef UART_BAUDRATE
#define UART_BAUDRATE (115200UL)
#endif

#include "../uart.h"

int main(void) {
    uart_puts("Testing 1, 2, 3...");
    char s;
    while (1) {
        s = uart_getc();
        uart_putc(s);
    }
}
