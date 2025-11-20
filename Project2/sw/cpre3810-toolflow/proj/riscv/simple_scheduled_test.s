# Simple Software-Scheduled Test Program
# Tests all instruction types with proper hazard avoidance

.data
test_data: .word 10, 20, 30, 40, 50

.text
.globl main

main:
    # Test R-type instructions with data hazards
    addi x1, x0, 5          # x1 = 5
    nop                     # Avoid data hazard
    nop
    nop
    add  x2, x1, x1         # x2 = 10 (uses x1)
    nop                     # Avoid data hazard
    nop
    nop
    sub  x3, x2, x1         # x3 = 5 (uses x2 and x1)
    
    # Test I-type instructions
    nop                     # Hazard avoidance
    nop
    nop
    addi x4, x3, 10         # x4 = 15 (uses x3)
    nop
    nop
    nop
    slli x5, x4, 1          # x5 = 30 (uses x4)
    
    # Test Load/Store with proper scheduling
    la   x6, test_data      # Load address
    nop                     # Avoid hazard with la
    nop
    nop
    lw   x7, 0(x6)          # Load first word (x7 = 10)
    nop                     # Load-use hazard avoidance
    nop
    nop
    add  x8, x7, x5         # x8 = 40 (uses loaded x7)
    nop
    nop
    nop
    sw   x8, 4(x6)          # Store result
    
    # Test Branch instructions with control hazard avoidance
    nop                     # Prepare for branch
    nop
    beq  x1, x1, taken      # Should be taken
    nop                     # Control hazard slot
    nop
    addi x9, x0, 999        # Should not execute
    
taken:
    addi x10, x0, 100       # x10 = 100
    nop
    nop  
    nop
    bne  x10, x1, not_equal # Should be taken
    nop                     # Control hazard slot
    nop
    addi x11, x0, 888       # Should not execute
    
not_equal:
    # Test JAL instruction
    nop                     # Prepare for jump
    nop
    jal  x12, subroutine    # Jump and link
    nop                     # Control hazard slot
    nop
    addi x13, x0, 777       # Should not execute
    
return_here:
    # Final test - JALR
    nop
    nop
    nop
    jalr x0, x12, 0         # Return using saved address
    nop                     # Control hazard slot
    nop
    
subroutine:
    addi x14, x0, 200       # x14 = 200
    nop
    nop
    nop
    j    return_here        # Jump back
    nop                     # Control hazard slot
    nop
    
done:
    wfi                     # End program