# Test: Branch Taken (Control Hazard)
# Expected: IFID_Flush=1, IDEX_Flush=1

.text
.globl main

main:
    # Test 1: BEQ taken
    addi x1, x0, 10         # x1 = 10
    addi x2, x0, 10         # x2 = 10
    beq  x1, x2, target1    # Taken -> flush 2 instructions
    addi x3, x0, 999        # FLUSHED
    addi x4, x0, 999        # FLUSHED
target1:
    addi x5, x0, 100        # x5 = 100
    
    # Test 2: BNE taken
    addi x6, x0, 5          # x6 = 5
    addi x7, x0, 10         # x7 = 10
    bne  x6, x7, target2    # Taken -> flush
    addi x8, x0, 999        # FLUSHED
target2:
    addi x9, x0, 200        # x9 = 200
    
    # Test 3: JAL (unconditional)
    jal  x10, target3       # Jump -> flush
    addi x11, x0, 999       # FLUSHED
target3:
    addi x12, x0, 300       # x12 = 300
    
    # Expected: x1=10, x2=10, x3=0, x4=0, x5=100
    # x6=5, x7=10, x8=0, x9=200, x11=0, x12=300
    
    # Halt with wait for interrupt
    wfi
