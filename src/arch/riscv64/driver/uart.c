#include "uart.h"

#define UART_BASE 0x10000000
#define RHR 0
#define THR 0
#define IER 1
#define FCR 2
#define ISR 2
#define LCR 3
#define MCR 4
#define LSR 5
#define MSR 6
#define SCR 7

#define LCR_BAUD_LATCH (1<<7)
#define LCR_EIGHT_BITS (3<<0)
#define FCR_FIFO_ENABLE (1<<0)
#define FCR_FIFO_CLEAR (3<<1)

#define io_write(reg, val) (*(volatile unsigned char *)(UART_BASE + reg) = (unsigned char)val)
#define io_read(reg) (*(volatile unsigned char *)(UART_BASE + reg))

void uart_init(void) {
  io_write(IER, 0x00);
  io_write(LCR, LCR_BAUD_LATCH);
  io_write(RHR, 0x03);
  io_write(RHR, 0x00);
  io_write(IER, 0x00);
  io_write(LCR, LCR_EIGHT_BITS);
  io_write(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
  return;
}

static int uart_writable(void) {
    return (io_read(LSR) & 0x20) == 1;
} 

void uart_putc(char c) {
    while (uart_writable());
    io_write(THR, c);
}
