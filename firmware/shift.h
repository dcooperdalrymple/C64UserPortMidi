// 74HC595 Data Bus Shift Register Output
// Written by D Cooper Dalrymple 2021

#ifndef	_SHIFT_H_
#define	_SHIFT_H_

#ifndef SHIFT_DATA
#define SHIFT_DATA PB1
#endif

#ifndef SHIFT_CLOCK
#define SHIFT_CLOCK PB2
#endif

#ifndef SHIFT_LATCH
#define SHIFT_LATCH PB4
#endif

#define SHIFT_DELAY (1)

void shift_init(void);
void shift_write(uint8_t data);

#endif
