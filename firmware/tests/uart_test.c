/**
 * Title: C64 UserPort MIDI - UART Echo Test
 * Author: D Cooper Dalrymple
 * Created: 02/03/2021
 * Updated: 02/03/2021
 * https://dcooperdalrymple.com/
 */


#include <avr/io.h>
#include <util/delay.h>

#define UART_TX PB1
#define UART_RX PB0

#include "../uart.h"

int main(void) {
    uart_puts("Hello World!"); // Doesn't work for some reason :/
    char s;
    while (1) {
        // Only half-duplex, so single characters work fine, but longer strings will get chopped up.
        s = uart_getc();
        uart_putc(s);
    }
}
