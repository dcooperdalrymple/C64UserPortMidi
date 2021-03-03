/**
 * Title: C64 UserPort MIDI - Shift Register Test
 * Author: D Cooper Dalrymple
 * Created: 02/03/2021
 * Updated: 02/03/2021
 * https://dcooperdalrymple.com/
 */

#include <avr/io.h>
#include <util/delay.h>
#include "../shift.h"

int main(void) {
    shift_init();
    while (1) {
        shift_write(0xAA);
        _delay_ms(1000);
        shift_write(0x55);
        _delay_ms(1000);
    }
}
