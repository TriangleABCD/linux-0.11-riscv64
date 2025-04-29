#include <console.h>
#include <defs.h>
#include <stdio.h>

/* HIGH level console I/O */

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void putch(int c, int *cnt) {
    cons_putc(c);
    (*cnt)++;
}

/* *
 * vcprintf - format a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int vprintf(const char *fmt, va_list ap) {
    int cnt = 0;
    vprintfmt((void *)putch, &cnt, fmt, ap);
    return cnt;
}

/* *
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int printf(const char *fmt, ...) {
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    cnt = vprintf(fmt, ap);
    va_end(ap);
    return cnt;
}

/* cputchar - writes a single character to stdout */
void putchar(int c) { cons_putc(c); }

/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int puts(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str++) != '\0') {
        putch(c, &cnt);
    }
    putch('\n', &cnt);
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int getchar(void) {
    int c;
    while ((c = cons_getc()) == 0) /* do nothing */;
    return c;
}
