# Combined Hazards Test
# Tests multiple types of hazards occurring together
.text
.globl _start

_start:
    # Setup data
    addi x1, x0, 0x100 # x1 = memory address
    addi x2, x0, 42    # x2 = test value
    sw   x2, 0(x1)     # Store test value
    
    # Scenario 1: Load-use hazard followed by EX-EX forwarding
    lw   x3, 0(x1)     # Load (will cause stall for next instruction)
    add  x4, x3, x2    # Load-use hazard - stall
    sub  x5, x4, x2    # EX-EX forwarding from previous add
    
    # Scenario 2: Multiple forwarding dependencies
    addi x6, x0, 10    # x6 = 10
    add  x7, x6, x2    # x7 = 52 (10 + 42)
    sub  x8, x7, x6    # x8 = 42 (EX-EX forward x7, normal x6)
    add  x9, x8, x7    # x9 = 94 (MEM-EX forward x8, MEM-EX forward x7)
    
    # Scenario 3: Branch with data dependencies
    addi x10, x0, 42   # x10 = 42
    beq  x3, x10, branch_target # Compare loaded value with 42
    add  x11, x10, x10 # Should be flushed if branch taken
    
branch_target:
    # Scenario 4: Load followed by branch (control + data hazard)
    lw   x12, 0(x1)    # Load 42
    beq  x12, x2, end_test # Branch on loaded value (potential hazard)
    addi x13, x0, 99   # Should be flushed
    
end_test:
    # Scenario 5: Store with forwarded data
    add  x14, x3, x4   # x14 = 84 (42 + 42) with possible forwarding
    sw   x14, 4(x1)    # Store forwarded result
    
    # End program
    halt:
        beq x0, x0, halt