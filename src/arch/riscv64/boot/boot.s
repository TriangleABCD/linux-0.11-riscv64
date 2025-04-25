.align 4
.extern kernel_init
.extern init_stk
.section .text
.globl _start
_start:
  csrr a0, mhartid
  beq a0, zero, call_init
  j _spin

call_init:
  la sp, init_stk
  li t0, 4096
  add sp, sp, t0
  call kernel_init

_spin:
  wfi
  j _spin
