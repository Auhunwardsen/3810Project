# MEM-EX Data Forwarding Test  
# Tests forwarding from MEM/WB stage to EX stage
.text
.globl _start

_start:
    # MEM-EX forwarding scenario
    addi x1, x0, 200   # x1 = 200
    addi x2, x0, 75    # x2 = 75
    add  x3, x1, x2    # x3 = 275
    addi x4, x0, 25    # x4 = 25 (independent instruction)
    sub  x5, x3, x4    # x5 = 250 (needs x3 from MEM/WB stage)
    
    # Another MEM-EX forwarding
    slli x6, x0, 0     # x6 = 0 (NOP equivalent)
    addi x7, x0, 10    # x7 = 10
    add  x8, x5, x7    # x8 = 260 (needs x5 from MEM/WB)
    
    # Test with load instruction result forwarding  
    # (This would be MEM-EX if we had memory loads)
    ori  x9, x0, 0x100 # x9 = 256
    nop                # Bubble
    add  x10, x9, x1   # x10 = 456 (needs x9 from MEM/WB)
    
    # End program
    halt:
        beq x0, x0, halt