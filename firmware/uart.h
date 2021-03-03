/**
 * Copyright (c) 2016, Łukasz Marcin Podkalicki <lpodkalicki@gmail.com>
 * Software UART for ATtiny13
 */

#ifndef	_UART_H_
#define	_UART_H_

#ifndef F_CPU
# define        F_CPU           (1200000UL) // 1.2 MHz
#endif

#ifdef UART_TX_ENABLED
# ifndef UART_TX
#  define        UART_TX         PB1
# endif
#endif

#ifndef UART_RX
# define        UART_RX         PB0
#endif

#ifndef UART_BAUDRATE
# define        UART_BAUDRATE   (19200)
#endif

#ifdef UART_TX_ENABLED
# define	TXDELAY         	(int)(((F_CPU/UART_BAUDRATE)-7 +1.5)/3)
#endif
#define RXDELAY         	(int)(((F_CPU/UART_BAUDRATE)-5 +1.5)/3)
#define RXDELAY2        	(int)((RXDELAY*1.5)-2.5)
#define RXROUNDED       	(((F_CPU/UART_BAUDRATE)-5 +2)/3)
#if RXROUNDED > 127
#error Low baud rates are not supported - use higher, UART_BAUDRATE
#endif

uint8_t uart_getc(void);

#ifdef UART_TX_ENABLED
void uart_putc(char c);
void uart_putu(uint16_t x);
void uart_puts(const char *s);
#endif

#endif	/* !_UART_H_ */
