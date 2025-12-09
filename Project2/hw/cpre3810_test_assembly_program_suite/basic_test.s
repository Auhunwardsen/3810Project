# Basic functionality test
# Tests basic ALU operations without hazards
.text
.globl _start

_start:
    # Test basic arithmetic
    addi x1, x0, 10    # x1 = 10
    addi x2, x0, 20    # x2 = 20
    add  x3, x1, x2    # x3 = 30
    sub  x4, x2, x1    # x4 = 10
    
    # Test logical operations
    addi x5, x0, 0xFF  # x5 = 255
    andi x6, x5, 0x0F  # x6 = 15
    ori  x7, x6, 0xF0  # x7 = 255
    xori x8, x7, 0xFF  # x8 = 0
    
    # Test shifts
    addi x9, x0, 8     # x9 = 8
    slli x10, x9, 2    # x10 = 32
    srli x11, x10, 1   # x11 = 16
    
    # End program
    addi x0, x0, 0     # NOP
    halt:
        beq x0, x0, halt