
# MEM-EX Data Forwarding Debug Test
# Enhanced for step-by-step debugging and value tracing
.text
.globl _start

_start:
    # MEM-EX forwarding scenario
    addi x1, x0, 0xC8    # x1 = 200 (unique value)
    addi x2, x0, 0x4B    # x2 = 75 (unique value)
    add  x3, x1, x2      # x3 = 275
    addi x4, x0, 0x19    # x4 = 25
    sub  x5, x3, x4      # x5 = 250 (should forward x3 from MEM/WB)
    # Debug: Write x5 to x10 for tracing
    addi x10, x5, 0      # x10 = 250 (should match x5)

    # Another MEM-EX forwarding
    slli x6, x0, 0       # x6 = 0
    addi x7, x0, 0x0A    # x7 = 10
    add  x8, x5, x7      # x8 = 260 (should forward x5 from MEM/WB)
    # Debug: Write x8 to x11 for tracing
    addi x11, x8, 0      # x11 = 260

    # Test with load instruction result forwarding
    ori  x9, x0, 0x100   # x9 = 256
    nop                  # Bubble
    add  x10, x9, x1     # x10 = 456 (should forward x9 from MEM/WB)
    # Debug: Write x10 to x12 for tracing
    addi x12, x10, 0     # x12 = 456

    # End program
    wfi   # WFI instruction to halt processor