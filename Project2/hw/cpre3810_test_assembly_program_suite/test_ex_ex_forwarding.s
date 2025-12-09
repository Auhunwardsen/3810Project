# EX-EX Data Forwarding Test
# Tests forwarding from EX/MEM stage to EX stage
.text
.globl _start

_start:
    # EX-EX forwarding scenario
    addi x1, x0, 100   # x1 = 100
    addi x2, x0, 50    # x2 = 50
    add  x3, x1, x2    # x3 = 150 (EX stage)
    sub  x4, x3, x1    # x4 = 50 (needs x3 from previous EX, forward from EX/MEM)
    
    # Another EX-EX forwarding
    slli x5, x4, 1     # x5 = 100 (EX stage)
    add  x6, x5, x2    # x6 = 150 (needs x5 from previous EX, forward from EX/MEM)
    
    # Multiple forwarding
    addi x7, x0, 1     # x7 = 1
    add  x8, x6, x7    # x8 = 151 (needs x6 from EX/MEM)
    add  x9, x8, x7    # x9 = 152 (needs x8 from EX/MEM)
    
    # End program
    halt:
        beq x0, x0, halt