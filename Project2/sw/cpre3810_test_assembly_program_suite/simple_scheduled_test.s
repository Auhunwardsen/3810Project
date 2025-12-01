# Simple Software-Scheduled Test Program
# Tests all instruction types with proper hazard avoidance
# This file has been corrected for consistent scheduling and logic.

.data
test_data: .word 10, 20, 30, 40, 50

.text
.globl main

main:
    # Test R-type instructions with data hazards
    addi x1, x0, 5          # x1 = 5
    nop
    nop
    add  x2, x1, x1         # x2 = 10 (uses x1)
    nop
    nop
    sub  x3, x2, x1         # x3 = 5 (uses x2 and x1)
    
    # Test I-type instructions
    nop
    nop
    addi x4, x3, 10         # x4 = 15 (uses x3)
    nop
    nop
    slli x5, x4, 1          # x5 = 30 (uses x4)
    
    # Test Load/Store with proper scheduling - use correct RARS values
    auipc x6, 64528         # Load PC + offset (same as RARS)
    nop                     # RAW hazard prevention cycle 1
    nop                     # RAW hazard prevention cycle 2  
    nop                     # RAW hazard prevention cycle 3
    nop                     # Extra safety cycle 4
    nop                     # Extra safety cycle 5
    addi x6, x6, -68        # Add offset (same as RARS) - now safe to read x6
    lw   x7, 0(x6)          # Load first word (x7 = 10)
    nop                     # Load-use hazard avoidance
    nop
    nop
    add  x8, x7, x5         # x8 = 40 (uses loaded x7)
    nop
    nop
    sw   x8, 4(x6)          # Store result
    
    # Test Branch instructions with control hazard avoidance
    beq  x1, x1, taken      # Should be taken
    nop                     # Control hazard slot
    addi x9, x0, 999        # Should not execute
    
taken:
    addi x10, x0, 100       # x10 = 100
    nop
    nop
    bne  x10, x1, not_equal # Should be taken
    nop                     # Control hazard slot
    addi x11, x0, 888       # Should not execute
    
not_equal:
    # Test JAL instruction
    jal  ra, subroutine    # Jump and link, ra = PC+4
    nop                     # Control hazard slot
    addi x13, x0, 777       # Should not execute
    
    # Final test - JALR to end program
    jalr x0, ra, 0         # Return from subroutine
    nop                     # Control hazard slot
    
    # This part of the code is now reached after subroutine returns
    j done
    nop

subroutine:
    addi x14, x0, 200       # x14 = 200
    jr   ra        # Jump back using return address
    nop                     # Control hazard slot
    
done:
    wfi                     # End program
