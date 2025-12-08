# Test: EX to EX Forwarding
# Expected: Forward_A/Forward_B = 10 (EX/MEM forward)

.text
.globl main

main:
    # Test 1: Forward to RS1
    addi x1, x0, 10         # x1 = 10
    add  x2, x1, x0         # Forward x1 to RS1
    
    # Test 2: Forward to both operands
    addi x3, x0, 5          # x3 = 5
    add  x4, x3, x3         # Forward x3 to both inputs
    
    # Test 3: Chain forwarding
    add  x5, x4, x3         # Forward x4 (EX/MEM) and x3 (MEM/WB)
    
    # Expected: x1=10, x2=10, x3=5, x4=10, x5=15
    
    # Halt with wait for interrupt
    wfi
