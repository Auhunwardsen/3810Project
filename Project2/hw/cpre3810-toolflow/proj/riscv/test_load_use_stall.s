# Load-Use Hazard Stall Test
# Tests detection and stalling for load-use data hazards
.text
.globl _start

_start:
    # Set up some data in memory first
    addi x1, x0, 0x100 # x1 = address 0x100
    addi x2, x0, 42    # x2 = data value 42
    sw   x2, 0(x1)     # Store 42 at address 0x100
    
    # Load-use hazard scenario - should cause 1 cycle stall
    lw   x3, 0(x1)     # Load from memory into x3 (MEM stage result)
    add  x4, x3, x2    # Use x3 immediately - HAZARD! Should stall
    
    # Another load-use hazard
    addi x5, x0, 0x104 # x5 = address 0x104  
    addi x6, x0, 100   # x6 = data value 100
    sw   x6, 0(x5)     # Store 100 at address 0x104
    lw   x7, 0(x5)     # Load from memory into x7
    sub  x8, x7, x6    # Use x7 immediately - HAZARD! Should stall
    
    # Test multiple register dependencies
    lw   x9, 0(x1)     # Load 42 into x9
    add  x10, x9, x9   # Both operands depend on load - should stall
    
    # End program
    halt:
        beq x0, x0, halt