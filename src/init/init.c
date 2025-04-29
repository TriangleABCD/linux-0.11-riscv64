#include <stdio.h>
#include <string.h>

int kern_init(void) __attribute__((noreturn));

int kern_init(void) {
  extern char edata[], end[]; 
  memset(edata, 0, end - edata); 

  const char *message = "kernel is loading ...\n";
  printf("%s\n\n", message);
  while (1)
    ;
}
