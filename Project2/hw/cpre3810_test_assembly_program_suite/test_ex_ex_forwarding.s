
# EX-EX Data Forwarding Debug Test
# Enhanced for step-by-step debugging and value tracing
.text
.globl main

main:
    # EX-EX forwarding scenario
    addi x1, x0, 0x64    # x1 = 100
    addi x2, x0, 0x32    # x2 = 50
    add  x3, x1, x2      # x3 = 150
    sub  x4, x3, x1      # x4 = 50 (should forward x3 from EX/MEM)
    # Debug: Write x4 to x10 for tracing
    addi x10, x4, 0      # x10 = 50

    # Another EX-EX forwarding
    slli x5, x4, 1       # x5 = 100
    add  x6, x5, x2      # x6 = 150 (should forward x5 from EX/MEM)
    # Debug: Write x6 to x11 for tracing
    addi x11, x6, 0      # x11 = 150

    # Multiple forwarding
    addi x7, x0, 1       # x7 = 1
    add  x8, x6, x7      # x8 = 151 (should forward x6 from EX/MEM)
    add  x9, x8, x7      # x9 = 152 (should forward x8 from EX/MEM)
    # Debug: Write x8 and x9 to x12 and x13 for tracing
    addi x12, x8, 0      # x12 = 151
    addi x13, x9, 0      # x13 = 152

    # End program
    wfi   # WFI instruction to halt processor