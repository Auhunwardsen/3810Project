# Combined Hazard Test Program: Data and Control Hazards Together
# Tests simultaneous occurrence of multiple hazard types

.data
array: .word 1, 2, 3, 4, 5, 6, 7, 8

.text
.globl main

main:
    # Test 1: Load-use hazard followed by branch
    la   x1, array       # Load array address
    lw   x2, 0(x1)       # Load first element (x2 = 1)
    beq  x2, x0, skip1   # Branch on loaded value (load-use + control hazard)
    addi x3, x2, 10      # x3 = 11 (uses forwarded x2)
    
skip1:
    # Test 2: Forwarding through branch
    addi x4, x0, 20      # x4 = 20
    add  x5, x4, x4      # x5 = 40 (forward x4)
    bne  x5, x0, skip2   # Branch on forwarded result
    addi x6, x0, 999     # Should not execute
    
skip2:
    # Test 3: Load-use with store (memory hazard)
    lw   x7, 4(x1)       # Load second element (x7 = 2)
    sw   x7, 8(x1)       # Store to third position (should stall for load-use)
    
    # Test 4: Multiple dependencies with branch
    addi x8, x0, 5       # x8 = 5
    add  x9, x8, x8      # x9 = 10 (forward x8)
    sub  x10, x9, x8     # x10 = 5 (forward x9, x8)
    beq  x10, x8, equal  # Branch comparing forwarded values
    j    not_equal
    
equal:
    addi x11, x0, 777    # x11 = 777
    j    continue
    
not_equal:
    addi x11, x0, 888    # Should not execute
    
continue:
    # Test 5: JAL with data dependency
    addi x12, x0, 100    # x12 = 100
    jal  x13, subroutine # Jump with data dependency pending
    add  x14, x12, x13   # Use return address and previous value
    
    # End test
    wfi
    
subroutine:
    addi x15, x0, 200    # x15 = 200
    jalr x0, x13, 0      # Return