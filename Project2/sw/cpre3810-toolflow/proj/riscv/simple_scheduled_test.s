# Simple Software-Scheduled Test Program
# Tests all instruction types with proper hazard avoidance
# 5-Stage Pipeline: IF -> ID -> EX -> MEM -> WB
# Data hazard avoidance: 3 NOPs between dependent instructions
# (instruction writes in WB at cycle N+4, next reads in ID at cycle N+1)

.data
test_data: .word 10, 20, 30, 40, 50

.text
.globl main

main:
    # Test R-type instructions with data hazards
    addi x1, x0, 5          # Cycle 1: x1 = 5 (WB at cycle 5)
    nop                     # Cycle 2: Required NOP 1
    nop                     # Cycle 3: Required NOP 2
    nop                     # Cycle 4: Required NOP 3
    add  x2, x1, x1         # Cycle 5: x2 = 10 (reads x1 safely)
    nop                     # Required NOP 1
    nop                     # Required NOP 2
    nop                     # Required NOP 3
    sub  x3, x2, x1         # x3 = 5 (uses x2 and x1)
    
    # Test I-type instructions
    nop                     # Required NOP 1
    nop                     # Required NOP 2
    nop                     # Required NOP 3
    addi x4, x3, 10         # x4 = 15 (uses x3)
    nop                     # Required NOP 1
    nop                     # Required NOP 2
    nop                     # Required NOP 3
    slli x5, x4, 1          # x5 = 30 (uses x4)
    
    # Test Load/Store with explicit address loading (avoid la pseudo-instruction)
    # Use simple base address that we know works
    lui  x6, 0x10000        # x6 = 0x10000000 (base address)
    nop                     # Required NOP 1
    nop                     # Required NOP 2
    nop                     # Required NOP 3
    
    # Store test data at known addresses first
    addi x9, x0, 10         # Test value 1
    addi x10, x0, 100       # Prepare value for later (independent) 
    addi x11, x0, 888       # Prepare value for later (independent)
    nop                     # Required NOP 1
    nop                     # Required NOP 2
    nop                     # Required NOP 3
    sw   x9, 0(x6)          # Store 10 at base address (uses x9 and x6)
    nop                     # Memory operations don't need extra wait
    nop                     # But we add NOPs for safety
    nop                     # Required NOP 3
    lw   x7, 0(x6)          # Load first word (x7 = 10)
    nop                     # Load-use: LW produces data in MEM stage
    nop                     # So next instruction in EX can't use it
    nop                     # Need 3 NOPs after load
    add  x8, x7, x5         # x8 = 40 (uses loaded x7 and x5)
    nop                     # Required NOP 1
    nop                     # Required NOP 2
    nop                     # Required NOP 3
    sw   x8, 4(x6)          # Store result
    
    # Test Branch instructions with control hazard avoidance
    # Branch decision made in EX stage (cycle 3)
    # Flush happens immediately, so following instructions are cancelled
    beq  x1, x1, taken      # Should be taken (x1 == x1)
    nop                     # Will be flushed (in IF when branch in EX)
    nop                     # Will be flushed (in ID when branch in EX)
    addi x12, x0, 999       # Should not execute (bad value)
    
taken:
    addi x12, x0, 555       # Good value (proves BEQ worked)
    nop                     # Required NOP 1
    nop                     # Required NOP 2
    nop                     # Required NOP 3
    bne  x10, x1, not_equal # Should be taken (x10=100, x1=5)
    nop                     # Will be flushed
    nop                     # Will be flushed
    addi x13, x0, 999       # Should not execute (bad value)
    
not_equal:
    addi x13, x0, 777       # Good value (proves BNE worked)
    # Test JAL instruction
    jal  x1, subroutine    # Jump and link, x1 = PC+4
    nop                     # Will be flushed
    nop                     # Will be flushed
    addi x14, x0, 999       # Should not execute (bad value)
    
    # Final test - jump to done
    j done
    nop                     # Will be flushed
    nop                     # Will be flushed
    addi x15, x0, 999       # Should not execute (bad value)

subroutine:
    addi x16, x0, 444       # Mark that subroutine was reached
    nop                     # Required NOP 1
    nop                     # Required NOP 2 
    nop                     # Required NOP 3
    jalr x0, x1, 0        # Jump back using return address
    nop                     # Will be flushed
    nop                     # Will be flushed
    addi x17, x0, 999       # Should not execute (bad value)
    
done:
    wfi                     # End program
