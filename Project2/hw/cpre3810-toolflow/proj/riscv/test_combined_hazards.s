# Test: Combined Hazards
# Expected: Forwarding + stalls + flushes together

.data
test_data: .word 10, 20

.text
.globl main

main:
    lui  x28, 0x10010       # Base address
    
    # Test 1: Forward then branch
    addi x1, x0, 10         # x1 = 10
    add  x2, x1, x1         # Forward x1, x2 = 20
    bne  x2, x0, target1    # Branch on forwarded result
    addi x3, x0, 999        # FLUSHED
target1:
    addi x3, x0, 100        # x3 = 100
    
    # Test 2: Load-use then branch
    lw   x4, 0(x28)         # Load x4 = 10
    beq  x4, x1, equal      # Stall then branch (taken)
    addi x5, x0, 999        # FLUSHED
equal:
    addi x5, x0, 200        # x5 = 200
    
    # Test 3: Store with forwarding
    addi x6, x0, 77         # x6 = 77
    sw   x6, 8(x28)         # Forward x6 to store
    
    # Expected: x1=10, x2=20, x3=100, x4=10, x5=200, x6=77
    
    # Halt with wait for interrupt
    wfi
