
# Control Hazard Branch Debug Test
# Enhanced for step-by-step debugging and value tracing
.text
.globl main

main:
    # Test taken branch - should flush IF/ID and ID/EX
    addi x1, x0, 0x0A    # x1 = 10
    addi x2, x0, 0x0A    # x2 = 10
    beq  x1, x2, taken_branch  # Branch should be taken, flush following instructions
    addi x3, x0, 99    # This should be flushed
    addi x4, x0, 99    # This should be flushed
    # Debug: Write x1, x2 to x10, x11 for tracing
    addi x10, x1, 0   # x10 = 10
    addi x11, x2, 0   # x11 = 10

taken_branch:
    addi x5, x0, 20    # x5 = 20 (first instruction after branch)
    # Debug: Write x5 to x12 for tracing
    addi x12, x5, 0   # x12 = 20

    # Test not-taken branch - no flushing needed
    addi x6, x0, 15    # x6 = 15
    bne  x1, x6, not_taken # Branch not taken (10 != 15)
    addi x7, x0, 30    # This should execute
    # Debug: Write x7 to x13 for tracing
    addi x13, x7, 0   # x13 = 30

not_taken:
    # Test JAL instruction - should flush
    addi x8, x0, 40    # x8 = 40
    jal  x9, jump_target   # Jump and link, should flush following
    addi x10, x0, 99   # This should be flushed
    addi x11, x0, 99   # This should be flushed

jump_target:
    addi x12, x0, 50   # x12 = 50 (first instruction after jump)
    # Debug: Write x12 to x14 for tracing
    addi x14, x12, 0  # x14 = 50

    # Test JALR instruction
    addi x13, x0, 0x200 # x13 = target address
    jalr x14, x13, 0    # Jump to address in x13, should flush following
    addi x15, x0, 99    # This should be flushed

    # End program
    wfi   # WFI instruction to halt processor