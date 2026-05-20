# Simple RISC-V assembly test program
# This program tests basic instructions: add, addi, lw, sw, beq
    .globl _start
_start:
    li x5, 9                # x5 = 9
    addi x6, x5, 41         # x6 = 50 
    add x7, x5, x6          # x7 = 59
    li x20, 16              # x10 = 16
    sw x7, 8(x20)           # Mem[6] = 59
    lw x28, 8(x20)          # x28 = Mem[6] = 59
    li x8, 59               # x8=59
    beq x28, x8, my_label   # branch taken
    addi x28, x28, 10       # instruction skipped, x28=59
my_label: 
    nop
    beq x0, x0, my_label


