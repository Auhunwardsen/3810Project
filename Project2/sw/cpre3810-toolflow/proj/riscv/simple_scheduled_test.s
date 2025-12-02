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
    nop
    nop                     # Need 4 NOPs for actual VHDL timing
    add  x2, x1, x1         # x2 = 10 (uses x1)
    nop
    nop
    nop
    nop                     # Need 4 NOPs for actual VHDL timing
    sub  x3, x2, x1         # x3 = 5 (uses x2 and x1)
    
    # Test I-type instructions
    nop
    nop
    nop
    nop                     # Need 4 NOPs for actual VHDL timing
    addi x4, x3, 10         # x4 = 15 (uses x3)
    nop
    nop
    nop
    nop                     # Need 4 NOPs for actual VHDL timing
    slli x5, x4, 1          # x5 = 30 (uses x4)
    
    # Test Load/Store with proper scheduling - let pseudo-instruction expand
    la   x6, test_data      # Load address (expands to auipc + addi)
    nop                     # U-type hazard avoidance for la expansion
    nop                     # U-type hazard avoidance  
    nop                     # U-type hazard avoidance
    nop                     # U-type hazard avoidance
    nop                     # U-type hazard avoidance
    nop                     # Additional U-type hazard avoidance
    nop                     # Additional U-type hazard avoidance
    nop                     # Additional U-type hazard avoidance
    # Add more delay cycles to ensure la completes fully
    addi x9, x0, 999        # Prepare value for later (independent)
    addi x10, x0, 100       # Prepare value for later (independent)
    addi x11, x0, 888       # Prepare value for later (independent)
    nop                     # Extra safety cycle
    nop                     # Extra safety cycle  
    nop                     # Extra safety cycle
    nop                     # Extra safety cycle
    nop                     # Extra safety cycle
    lw   x7, 0(x6)          # Load first word (x7 = 10) - now safe to use x6
    nop                     # Load-use hazard avoidance
    nop
    nop
    nop                     # Need 4 NOPs for actual VHDL timing
    add  x8, x7, x5         # x8 = 40 (uses loaded x7)
    nop
    nop
    nop
    nop                     # Need 4 NOPs for actual VHDL timing
    sw   x8, 4(x6)          # Store result
    
    # Test Branch instructions with control hazard avoidance
    beq  x1, x1, taken      # Should be taken
    nop                     # Branch delay slot 1
    nop                     # Branch delay slot 2
    nop                     # Branch delay slot 3
    addi x12, x0, 999       # Should not execute (bad value)
    
taken:
    addi x12, x0, 555       # Good value (proves BEQ worked)
    nop
    nop
    nop
    bne  x10, x1, not_equal # Should be taken (x10=100, x1=5)
    nop                     # Branch delay slot 1
    nop                     # Branch delay slot 2
    nop                     # Branch delay slot 3
    addi x13, x0, 999       # Should not execute (bad value)
    
not_equal:
    addi x13, x0, 777       # Good value (proves BNE worked)
    # Test JAL instruction
    jal  x1, subroutine    # Jump and link, x1 = PC+4
    nop                     # Jump delay slot 1
    nop                     # Jump delay slot 2
    nop                     # Jump delay slot 3
    addi x14, x0, 999       # Should not execute (bad value)
    
    # Final test - jump to done
    j done
    nop                     # Jump delay slot 1
    nop                     # Jump delay slot 2
    nop                     # Jump delay slot 3
    addi x15, x0, 999       # Should not execute (bad value)

subroutine:
    addi x16, x0, 444       # Mark that subroutine was reached
    nop
    jalr x0, x1, 0        # Jump back using return address
    nop                     # Jump delay slot 1
    nop                     # Jump delay slot 2
    nop                     # Jump delay slot 3
    addi x17, x0, 999       # Should not execute (bad value)
    
done:
    wfi                     # End program
