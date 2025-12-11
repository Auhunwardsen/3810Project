# Simple Branch Test
# Tests basic branch functionality
.text
.globl main

main:
    # Test 1: Taken branch
    addi x1, x0, 5        # x1 = 5
    addi x2, x0, 5        # x2 = 5
    beq  x1, x2, target1  # Should take branch (5 == 5)
    addi x3, x0, 99       # Should NOT execute (flushed)

target1:
    addi x4, x0, 10       # x4 = 10

    # Test 2: Not taken branch
    addi x5, x0, 7        # x5 = 7
    addi x6, x0, 3        # x6 = 3
    beq  x5, x6, target2  # Should NOT take branch (7 != 3)
    addi x7, x0, 15       # Should execute

target2:
    addi x8, x0, 20       # x8 = 20

    # Test 3: JAL instruction
    addi x9, x0, 25       # x9 = 25
    jal  x10, target3     # x10 = return address
    addi x11, x0, 99      # Should NOT execute (flushed)

target3:
    addi x12, x0, 30      # x12 = 30

    # End
    wfi
