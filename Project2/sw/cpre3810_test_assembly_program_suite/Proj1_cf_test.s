# Proj1_cf_test.s - simple control-flow test 
# Uses: BEQ, BNE, BLT, BGE, JAL, JALR
# Depth: 5 (F1 -> F2 -> F3 -> F4 -> F5)
# Signals to watch: PC, Inst, RegWrite, DMemAddr, DMemData_out, DMemData_in, DMemWr, ALUResult, branch/PC control

    .text
    .globl main
    .globl _start

main:
_start:
    # set up a small stack in safe memory region
    li      sp, 0x80000000  # Set stack pointer to high memory like other tests

    # choose values to make some branches taken
    addi    s0, x0, 10      # s0 = 10
    addi    s1, x0, 10      # s1 = 10

    # call chain to depth 5
    jal     ra, F1
    j       DONE

# -------- F1: BEQ path --------
F1:
    beq     s0, s1, F1_GO
    addi    a0, x0, 1
    jalr    x0, 0(ra)

F1_GO:
    addi    sp, sp, -16
    sw      ra, 12(sp)
    jal     ra, F2
    lw      ra, 12(sp)
    addi    sp, sp, 16
    jalr    x0, 0(ra)

# -------- F2: BNE path --------
F2:
    bne     s0, x0, F2_GO
    addi    a0, x0, 2
    jalr    x0, 0(ra)

F2_GO:
    addi    sp, sp, -16
    sw      ra, 12(sp)
    jal     ra, F3
    lw      ra, 12(sp)
    addi    sp, sp, 16
    jalr    x0, 0(ra)

# -------- F3: BLT path --------
F3:
    addi    t0, x0, 20
    blt     s0, t0, F3_GO
    addi    a0, x0, 3
    jalr    x0, 0(ra)

F3_GO:
    addi    sp, sp, -16
    sw      ra, 12(sp)
    jal     ra, F4
    lw      ra, 12(sp)
    addi    sp, sp, 16
    jalr    x0, 0(ra)

# -------- F4: BGE path --------
F4:
    addi    t1, x0, 10
    bge     s1, t1, F4_GO
    addi    a0, x0, 4
    jalr    x0, 0(ra)

F4_GO:
    addi    sp, sp, -16
    sw      ra, 12(sp)
    jal     ra, F5
    lw      ra, 12(sp)
    addi    sp, sp, 16
    jalr    x0, 0(ra)

# -------- F5: leaf --------
F5:
    addi    a0, x0, 42      # return value
    jalr    x0, 0(ra)

# -------- end --------
DONE:
    wfi
