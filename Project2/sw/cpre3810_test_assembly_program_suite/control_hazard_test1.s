# Control Hazard Test Program 1: Branch Hazards
# Tests control hazard detection and pipeline flushing

.data
test_val: .word 10

.text
.globl main

main:
    # Test 1: Taken branch hazard
    addi x1, x0, 5       # x1 = 5
    addi x2, x0, 5       # x2 = 5
    beq  x1, x2, taken1  # Branch taken - should flush IF/ID and ID/EX
    addi x3, x0, 999     # Should be flushed
    addi x4, x0, 999     # Should be flushed
    
taken1:
    addi x5, x0, 100     # x5 = 100 (first valid instruction after branch)
    
    # Test 2: Not taken branch
    addi x6, x0, 10      # x6 = 10
    addi x7, x0, 15      # x7 = 15
    bne  x6, x7, taken2  # Branch not taken - no flush needed
    addi x8, x0, 200     # Should execute normally
    j    continue1
    
taken2:
    addi x8, x0, 300     # Should not execute
    
continue1:
    # Test 3: JAL instruction (unconditional jump)
    jal  x9, jump_target # Jump and link - should flush pipeline
    addi x10, x0, 999    # Should be flushed
    addi x11, x0, 999    # Should be flushed
    
return_point:
    addi x12, x0, 400    # x12 = 400
    
    # Test 4: JALR instruction (register jump)
    la   x13, jalr_target
    jalr x14, x13, 0     # Jump to register address
    addi x15, x0, 999    # Should be flushed
    
jalr_return:
    addi x16, x0, 500    # x16 = 500
    
    # End test
    wfi
    
jump_target:
    addi x17, x0, 600    # x17 = 600
    j    return_point
    
jalr_target:
    addi x18, x0, 700    # x18 = 700
    j    jalr_return