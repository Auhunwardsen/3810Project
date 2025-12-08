# Test: Load-Use Hazard Stall
# Expected: PCWrite=0, IFID_Write=0, ControlMux=1

.data
test_data: .word 10, 20, 30, 40

.text
.globl main

main:
    lui  x28, 0x10010       # Base address
    
    # Test 1: Immediate use (STALL)
    lw   x1, 0(x28)         # Load x1 = 10
    add  x2, x1, x1         # Stall 1 cycle, then forward
    
    # Test 2: Load with gap (NO STALL)
    lw   x3, 4(x28)         # Load x3 = 20
    nop                     # Gap
    add  x4, x3, x0         # Forward from MEM/WB
    
    # Test 3: Branch use (STALL)
    lw   x5, 8(x28)         # Load x5 = 30
    beq  x5, x0, skip       # Stall for branch comparison
    addi x6, x0, 100        # Execute (not taken)
    
skip:
    # Expected: x1=10, x2=20, x3=20, x4=20, x5=30, x6=100
    
    # Halt with wait for interrupt
    wfi
