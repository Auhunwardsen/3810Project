# Control Hazard Branch Test
# Tests detection and flushing for control hazards
.text
.globl _start

_start:
    # Test taken branch - should flush IF/ID and ID/EX
    addi x1, x0, 10    # x1 = 10
    addi x2, x0, 10    # x2 = 10  
    beq  x1, x2, taken_branch  # Branch should be taken, flush following instructions
    addi x3, x0, 99    # This should be flushed
    addi x4, x0, 99    # This should be flushed
    
taken_branch:
    addi x5, x0, 20    # x5 = 20 (first instruction after branch)
    
    # Test not-taken branch - no flushing needed
    addi x6, x0, 15    # x6 = 15
    bne  x1, x6, not_taken # Branch not taken (10 != 15)
    addi x7, x0, 30    # This should execute
    
not_taken:
    # Test JAL instruction - should flush
    addi x8, x0, 40    # x8 = 40
    jal  x9, jump_target   # Jump and link, should flush following
    addi x10, x0, 99   # This should be flushed
    addi x11, x0, 99   # This should be flushed
    
jump_target:
    addi x12, x0, 50   # x12 = 50 (first instruction after jump)
    
    # Test JALR instruction
    addi x13, x0, 0x200 # x13 = target address
    jalr x14, x13, 0    # Jump to address in x13, should flush following
    addi x15, x0, 99    # This should be flushed
    
    # Code at 0x200 would continue here in real system
    # For simulation, just end
    halt:
        beq x0, x0, halt