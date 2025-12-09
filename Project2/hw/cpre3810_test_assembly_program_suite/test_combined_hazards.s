# Simple Combined Hazards Test
# Tests load-use + forwarding together
.data
test_values: .word 10, 20, 30

.text
.globl main

main:
    # Setup
    lui  x1, 0x10010      # x1 = data base address

    # Scenario 1: Load-use stall followed by forwarding
    lw   x2, 0(x1)        # Load 10 - will cause stall on next instruction
    add  x3, x2, x2       # Use x2 immediately - STALL
    add  x4, x3, x3       # Use x3 - needs EX-EX forwarding

    # Scenario 2: Multiple forwarding paths
    addi x5, x0, 5        # x5 = 5
    add  x6, x5, x5       # x6 = 10 (forward x5 from EX/MEM)
    sub  x7, x6, x5       # x7 = 5 (forward x6 from EX/MEM, x5 from MEM/WB)

    # Scenario 3: Load then branch (branch data hazard)
    lw   x8, 4(x1)        # Load 20
    lw   x9, 8(x1)        # Load 30
    beq  x8, x9, skip     # Branch on loaded values - may need stall
    addi x10, x0, 50      # Should execute if not taken

skip:
    addi x11, x0, 100     # x11 = 100

    # Scenario 4: Store with forwarding
    addi x12, x0, 77      # x12 = 77
    add  x13, x12, x12    # x13 = 154
    sw   x13, 12(x1)      # Store forwarded result

    # End
    wfi
