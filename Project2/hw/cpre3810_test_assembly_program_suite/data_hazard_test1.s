# Data Hazard Test Program 1: RAW Hazard with Forwarding
# Tests EX/MEM to EX forwarding (ALU result forwarding)

.data
test_array: .word 1, 2, 3, 4, 5

.text
.globl main

main:
    # Test 1: Basic RAW hazard - EX/MEM to EX forwarding
    addi x1, x0, 10      # x1 = 10
    add  x2, x1, x1      # x2 = x1 + x1 = 20 (should forward x1 from EX/MEM)
    add  x3, x2, x1      # x3 = x2 + x1 = 30 (should forward x2 from EX/MEM)
    
    # Test 2: MEM/WB to EX forwarding  
    addi x4, x0, 5       # x4 = 5
    nop                  # Let x4 reach MEM/WB
    add  x5, x4, x4      # x5 = x4 + x4 = 10 (should forward x4 from MEM/WB)
    
    # Test 3: Load-use hazard (should cause stall)
    la   x6, test_array  # Load address of test_array
    lw   x7, 0(x6)       # Load first element
    add  x8, x7, x7      # Should stall here - load-use hazard
    
    # Test 4: Back-to-back dependencies
    addi x9, x0, 15      # x9 = 15
    add  x10, x9, x9     # x10 = 30 (forward x9)
    sub  x11, x10, x9    # x11 = 15 (forward x10 from EX/MEM, x9 from MEM/WB)
    
    # Test 5: No forwarding needed (different registers)
    addi x12, x0, 100    # x12 = 100
    addi x13, x0, 200    # x13 = 200 (no dependency)
    add  x14, x12, x13   # x14 = 300 (no forwarding needed)
    
    # End test
    wfi