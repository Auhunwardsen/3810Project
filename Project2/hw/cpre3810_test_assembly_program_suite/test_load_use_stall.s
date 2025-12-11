# Simple Load-Use Stall Test
# Tests load-use hazard detection
.data
test_data: .word 42, 100, 200

.text
.globl main

main:
    # Setup: Load base address
    lui  x1, 0x10010      # x1 = data segment base

    # Test 1: Basic load-use hazard
    lw   x2, 0(x1)        # Load 42 into x2
    addi x3, x2, 10       # Use x2 immediately - STALL

    # Test 2: Load-use with ALU operation
    lw   x4, 4(x1)        # Load 100 into x4
    add  x5, x4, x2       # Use x4 immediately - STALL

    # Test 3: Load without immediate use (no stall)
    lw   x6, 8(x1)        # Load 200 into x6
    nop                   # Delay
    add  x7, x6, x5       # Use x6 after delay - NO STALL

    # Test 4: Back-to-back loads
    lw   x8, 0(x1)        # Load 42
    lw   x9, 4(x1)        # Load 100 (no hazard, different dest)
    add  x10, x8, x9      # Use both - STALL on x8

    # End
    wfi
