# Test: Combined Hazards
# Expected: Forwarding + stalls + flushes together

.text
.globl main

main:
    # Set up test data using stores
    addi x28, x0, 0x400     # Base address
    addi x29, x0, 10        # Test value
    sw   x29, 0(x28)        # Store 10
    addi x29, x0, 20        # Test value
    sw   x29, 4(x28)        # Store 20
    
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
    
    # Test 3: Simple completion
    addi x6, x0, 77         # x6 = 77
    
    # Expected: x1=10, x2=20, x3=100, x4=10, x5=200, x6=77
    
    # Halt with wait for interrupt
    wfi
