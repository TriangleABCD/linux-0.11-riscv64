#include "uart.h"

char init_stk[4096];

void putstr(const char* str) {
  for (const char* p = str; *p != '\0'; p = p + 1) {
    uart_putc(*p);
  }
}

void kernel_init(void) {
  uart_init();
  putstr("Hello, world!\n");
}
