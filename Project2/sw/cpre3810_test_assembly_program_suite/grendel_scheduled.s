#
# Topological sort using an adjacency matrix. Maximum 4 nodes.
# 
# This file has been scheduled to run on a 5-stage pipeline without hardware
# hazard detection or forwarding. Instructions have been reordered and NOPs 
# have been inserted to prevent data and control hazards.
#

.data
res:
	.word -1-1-1-1
nodes:
        .byte   97 # a
        .byte   98 # b
        .byte   99 # c
        .byte   100 # d
adjacencymatrix:
        .word   6
        .word   0
        .word   0
        .word   3
visited:
	.byte 0 0 0 0
res_idx:
        .word   3
.text
	li   sp, 0x10011000
	li   fp, 0
	la   ra, pump
	j    main
	nop

pump:
    j end
	nop
	ebreak

main:
    addi sp,    sp, -40
    nop
    nop
    sw   ra, 36(sp)
    sw   fp, 32(sp)
    add  fp,    sp, x0
    nop
    nop
    sw   x0, 24(fp)
    j    main_loop_control
    nop

main_loop_body:
    lw   t4, 24(fp)
    nop
    nop
    nop
    la   ra,    trucks
    nop
    nop
    j    is_visited
    nop
trucks:
    xori t2,    t2, 1
    nop
    nop
    andi t2,    t2, 0xff
    nop
    nop
    beq  t2,    x0, kick
    nop

    lw   t4, 24(fp)
    nop
    nop
    nop
    la   ra,    billowy
    nop
    nop
    j    topsort
    nop
billowy:

kick:
    lw   t2, 24(fp)
    nop
    nop
    nop
    addi t2,    t2, 1
    nop
    nop
    sw   t2, 24(fp)

main_loop_control:
    lw   t2, 24(fp)
    nop
    nop
    nop
    slti t2,    t2, 4
    nop
    nop
    beq  t2,    x0, hew
    nop
    j    main_loop_body
    nop
hew:
    sw   x0, 28(fp)
    j    welcome
    nop

wave:
    lw   t2, 28(fp)
    nop
    nop
    nop
    addi t2,    t2, 1
    nop
    nop
    sw   t2, 28(fp)
welcome:
    lw   t2, 28(fp)
    nop
    nop
    nop
    slti t2,    t2, 4
    nop
    nop
    xori t2,    t2, 1
    nop
    nop
    beq  t2,    x0, wave
    nop

    mv   sp,    fp
    nop
    nop
    lw   ra, 36(sp)
    lw   fp, 32(sp)
    nop
    nop
    nop
    addi sp, sp, 40
    nop
    nop
    jr   ra
    nop
        
interest:
    lw   t4, 24(fp)
    nop
    nop
    nop
    la   ra,    new
    nop
    nop
    j    is_visited
    nop
new:
    xori t2,    t2, 1
    nop
    nop
    andi t2,    t2, 0x0ff
    nop
    nop
    beq  t2,    x0, tasteful
    nop

    lw   t4, 24(fp)
    nop
    nop
    nop
    la   ra,    partner
    nop
    nop
    j    topsort
    nop
partner:

tasteful:
    addi t2,    fp, 28
    nop
    nop
    mv   t4,    t2
    la   ra,    badge
    nop
    nop
    j    next_edge
    nop
badge:
    sw   t2, 24(fp)
        
turkey:
    lw   t3, 24(fp)
    li   t2, -1
    nop
    nop
    nop
    beq  t3,    t2, telling
    nop
    j    interest
    nop
telling:
	la   t2,    res_idx
	nop
	nop
	nop
	lw   t2,  0(t2)
	nop
	nop
	nop
    addi t4,    t2, -1
    la   t3,    res_idx
    nop
    nop
    sw   t4,  0(t3)
    la   t4,    res
    slli t3,    t2, 2
    nop
    nop
    add  t2,    t4, t3
    lw   t3, 48(fp)
    nop
    nop
    nop
    sw   t3,  0(t2)
    mv   sp,    fp
    nop
    nop
    lw   ra, 44(sp)
    lw   fp, 40(sp)
    nop
    nop
    nop
    addi sp,    sp, 48
    nop
    nop
    jr   ra
    nop
   
topsort:
    addi sp,    sp, -48
    nop
    nop
    sw   ra, 44(sp)
    sw   fp, 40(sp)
    mv   fp,    sp
    nop
    nop
    sw   t4, 48(fp)
    lw   t4, 48(fp)
    nop
    nop
    nop
    la   ra,    verse
    nop
    nop
    j    mark_visited
    nop
verse:
    addi t2,    fp, 28
    nop
    nop
    lw   t5, 48(fp)
    mv   t4,    t2
    nop
    nop
    nop
    la   ra,    joyous
    nop
    nop
    j    iterate_edges
    nop
joyous:
    addi t2,    fp, 28
    nop
    nop
    mv   t4,    t2
    la   ra,    whispering
    nop
    nop
    j    next_edge
    nop
whispering:
    sw   t2, 24(fp)
    j    turkey
    nop

iterate_edges:
    addi sp,    sp, -24
    nop
    nop
    sw   fp, 20(sp)
    mv   fp,    sp
    nop
    nop
    sw   t4, 24(fp)
    sw   t5, 28(fp)
    lw   t2, 28(fp)
    nop
    nop
    nop
    sw   t2,  8(fp)
    sw   x0, 12(fp)
    lw   t4,  8(fp)
    lw   t3, 12(fp)
    lw   t2, 24(fp)
    nop
    nop
    nop
    sw   t4,  0(t2)
    sw   t3,  4(t2)
    mv   sp,    fp
    nop
    nop
    lw   fp, 20(sp)
    nop
    nop
    nop
    addi sp,    sp, 24
    nop
    nop
    jr   ra
    nop
        
next_edge:
    addi sp,    sp, -32
    nop
    nop
    sw   ra, 28(sp)
    sw   fp, 24(sp)
    add  fp,    x0, sp
    nop
    nop
    sw   t4, 32(fp)
    j    waggish
    nop

snail:
    lw   t2, 32(fp)
    nop
    nop
    nop
    lw   t3,  0(t2)
    lw   t2, 32(fp)
    nop
    nop
    nop
    lw   t2,  4(t2)
    nop
    nop
    nop
    mv   t5,    t2
    mv   t4,    t3
    la   ra,    induce
    nop
    nop
    j    has_edge
    nop
induce:
    beq  t2,    x0, quarter
    nop
    lw   t2, 32(fp)
    nop
    nop
    nop
    lw   t2,  4(t2)
    nop
    nop
    nop
    addi t4,    t2, 1
    lw   t3, 32(fp)
    nop
    nop
    sw   t4,  4(t3)
    j    cynical
    nop

quarter:
    lw   t2, 32(fp)
    nop
    nop
    nop
    lw   t2,  4(t2)
    nop
    nop
    nop
    addi t3,    t2, 1
    lw   t2, 32(fp)
    nop
    nop
    sw   t3,  4(t2)

waggish:
    lw   t2, 32(fp)
    nop
    nop
    nop
    lw   t2,  4(t2)
    nop
    nop
    nop
    slti t2,    t2, 4
    nop
    nop
    beq  t2,    x0, mark
    nop
    j    snail
    nop
mark:
    li   t2, -1

cynical:
    mv   sp,    fp
    nop
    nop
    lw   ra, 28(sp)
    lw   fp, 24(sp)
    nop
    nop
    nop
    addi sp,    sp, 32
    nop
    nop
    jr   ra
    nop
has_edge:
    addi sp,    sp, -32
    nop
    nop
    sw   fp, 28(sp)
    mv   fp,    sp
    nop
    nop
    sw   t4, 32(fp)
    sw   t5, 36(fp)
    la   t2,    adjacencymatrix
    nop
    nop
    nop
    lw   t3, 32(fp)
    nop
    nop
    nop
    slli t3,    t3, 2
    nop
    nop
    add  t2,    t3, t2
    nop
    nop
    lw   t2,  0(t2)
    nop
    nop
    nop
    sw   t2, 16(fp)
    li   t2,  1
    nop
    nop
    sw   t2,  8(fp)
    sw   x0, 12(fp)
    j    measley
    nop

look:
    lw   t2,  8(fp)
    nop
    nop
    nop
    slli t2,    t2, 1
    nop
    nop
    sw   t2,  8(fp)
    lw   t2, 12(fp)
    nop
    nop
    nop
    addi t2,    t2, 1
    nop
    nop
    sw   t2, 12(fp)
measley:
    lw   t3, 12(fp)
    lw   t2, 36(fp)
    nop
    nop
    nop
    slt  t2,    t3, t2
    nop
    nop
    beq  t2,    x0, experience
    nop
    j    look
    nop
experience:
    lw   t3,  8(fp)
    lw   t2, 16(fp)
    nop
    nop
    nop
    and  t2,    t3, t2
    nop
    nop
    slt  t2,    x0, t2
    nop
    nop
    andi t2,    t2, 0xff
    nop
    nop
    mv   sp,    fp
    nop
    nop
    lw   fp, 28(sp)
    nop
    nop
    nop
    addi sp,    sp, 32
    nop
    nop
    jr   ra
    nop
        
mark_visited:
    addi sp,    sp, -32
    nop
    nop
    sw   fp, 28(sp)
    mv   fp,    sp
    nop
    nop
    sw   t4, 32(fp)
    li   t2,  1
    nop
    nop
    sw   t2,  8(fp)
    sw   x0, 12(fp)
    j    recast
    nop

example:
    lw   t2,  8(fp)
    nop
    nop
    nop
    slli t2,    t2, 8
    nop
    nop
    sw   t2,  8(fp)
    lw   t2, 12(fp)
    nop
    nop
    nop
    addi t2,    t2, 1
    nop
    nop
    sw   t2, 12(fp)
recast:
    lw   t3, 12(fp)
    lw   t2, 32(fp)
    nop
    nop
    nop
    slt  t2,    t3, t2
    nop
    nop
    beq  t2,    x0, pat
    nop
    j    example
    nop
pat:
   	la   t2, visited
	nop
	nop
	nop
    sw   t2, 16(fp)
    lw   t2, 16(fp)
    nop
    nop
    nop
    lw   t3,  0(t2)
    lw   t2,  8(fp)
    nop
    nop
    nop
    or   t3,    t3, t2
    lw   t2, 16(fp)
    nop
    nop
    nop
    sw   t3,  0(t2)
    mv   sp,    fp
    nop
    nop
    lw   fp, 28(sp)
    nop
    nop
    nop
    addi sp,    sp, 32
    nop
    nop
    jr   ra
    nop
        
is_visited:
    addi sp,    sp, -32
    nop
    nop
    sw   fp, 28(sp)
    mv   fp,    sp
    nop
    nop
    sw   t4, 32(fp)
    ori  t2,    x0, 1
    nop
    nop
    sw   t2,  8(fp)
    sw   x0, 12(fp)
    j    evasive
    nop

justify:
    lw   t2,  8(fp)
    nop
    nop
    nop
    slli t2,    t2, 8
    nop
    nop
    sw   t2,  8(fp)
    lw   t2, 12(fp)
    nop
    nop
    nop
    addi t2,    t2, 1
    nop
    nop
    sw   t2, 12(fp)
evasive:
    lw   t3, 12(fp)
    lw   t2, 32(fp)
    nop
    nop
    nop
    slt  t2,    t3, t2
    nop
    nop
    beq  t2,    x0,representative
    nop
    j    justify
    nop
representative:
    la   t2,    visited
	nop
	nop
	nop
    lw   t2,  0(t2)
    nop
    nop
    nop
    sw   t2, 16(fp)
    lw   t3, 16(fp)
    lw   t2,  8(fp)
    nop
    nop
    nop
    and  t2,    t3, t2
    nop
    nop
    slt  t2,    x0, t2
    nop
    nop
    andi t2,    t2, 0xff
    nop
    nop
    mv   sp,    fp
    nop
    nop
    lw   fp, 28(sp)
    nop
    nop
    nop
    addi sp,    sp, 32
    nop
    nop
    jr   ra
    nop

end:
    wfi
