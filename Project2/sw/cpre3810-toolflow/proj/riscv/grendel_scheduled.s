#
# Topological sort using an adjacency matrix. Maximum 4 nodes.
# 
# The expected output of this program is that the 1st 4 addresses of the data segment
# are [4,0,3,2]. should take ~2000 cycles in a single cycle procesor.
#

# Adapted to RISC-V by Connor J. Link (3.1.2025)
# Per testing [3, 0, 2, 1] is the expected output (matches the original grendel.s in MARS)

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
	# NEW RISCV                # ORIGINAL MIPS  
	#li   sp, 0x10011000        # li $sp, 0x10011000
        lui   sp, 0x10011
	nop                        # NOPs after pseudo-instruction (expands to lui+addi)
	nop
        addi  sp, sp, 0
	nop
	nop
	li   fp, 0                 # li $fp, 0
	nop                        # NOPs after pseudo-instruction
	nop
	#la   ra, pump              # la $ra pump
        lui   ra, %hi(pump)
	nop                        # NOPs after pseudo-instruction
	nop
        addi  ra, ra, %lo(pump)
	nop
	nop
	j    main
	nop
	nop
pump:
        j end
        nop
        nop
        nop
	ebreak                     # halt
        nop
        nop


main:
        addi sp,    sp, -40        # addiu   $sp,$sp,-40
        nop
        nop
        sw   ra, 36(sp)            # sw      $31,36($sp)
        nop
        nop
        sw   fp, 32(sp)            # sw      $fp,32($sp)
        nop
        nop
        add  fp,    sp, x0         # add     $fp,$sp,$zero
        nop
        nop
        sw   x0, 24(sp)            # sw      $0,24($fp)
        nop
        nop
        j    main_loop_control
        nop
        nop
        nop

main_loop_body:
        lw   t4, 24(fp)            # lw      $4,24($fp)
        nop                        # NOPs after load
        nop
        #la   ra,    trucks         # la      $ra, trucks
        lui  ra, %hi(trucks)
        nop                        # NOPs after pseudo-instruction
        nop
        addi  ra, ra, %lo(trucks)
        nop
        nop
        j    is_visited
        nop
        nop
        nop
trucks:

        xori t2,    t2, 1          # xori    $2,$2,0x1
        nop
        nop
        andi t2,    t2, 0xff       # andi    $2,$2,0x00ff
        nop
        nop
        beq  t2,    x0, kick       # beq     $2,$0,kick
        nop
        nop
        nop
        lw   t4, 24(fp)            # lw      $4,24($fp)
        nop                        # NOPs after load
        nop
                                   # ; addi    $k0, $k0,1# breakpoint
        #la   ra,    billowy        # la      $ra, billowy
        lui  ra, %hi(billowy)
        nop                        # NOPs after pseudo-instruction
        nop
        addi  ra, ra, %lo(billowy)
        nop
        nop
        j    topsort
        nop
        nop
        nop
billowy:

kick:
        lw   t2, 24(fp)            # lw      $2,24($fp)
        nop                        # NOPs after load
        nop
        addi t2,    t2, 1          # addiu   $2,$2,1
        nop
        nop
        sw   t2, 24(fp)            # sw      $2,24($fp)
        nop
        nop
main_loop_control:
        lw   t2, 24(fp)            # lw      $2,24($fp)
        nop
        nop
        slti t2,    t2, 4          # slti    $2,$2, 4
        nop
        nop
        beq  t2,    x0, hew        # beq     $2, $zero, hew # beq, j to simulate bne 
        nop
        nop
        nop
        j    main_loop_body
        nop
        nop
        nop
hew:
        sw   x0, 28(fp)            # sw      $0,28($fp)
        nop
        nop
        j    welcome
        nop
        nop
        nop

wave:
        lw   t2, 28(fp)            # lw      $2,28($fp)
        nop
        nop
        addi t2,    t2, 1          # addiu   $2,$2,1
        nop
        nop
        sw   t2, 28(fp)            # sw      $2,28($fp)
        nop
        nop
welcome:
        lw   t2, 28(fp)            # lw      $2,28($fp)
        nop
        nop
        slti t2,    t2, 4          # slti    $2,$2,4
        nop
        nop
        xori t2,    t2, 1          # xori    $2,$2,1 # xori 1, beq to simulate bne where val in [0,1]
        nop
        nop
        beq  t2,    x0, wave       # beq     $2,$0,wave
        nop
        nop
        nop
        mv   t2,    x0             # move    $2,$0
        nop
        nop
        mv   sp,    fp             # move    $sp,$fp
        nop
        nop
        lw   ra, 36(sp)            # lw      $31,36($sp)
        nop
        nop
        lw   fp, 32(sp)            # lw      $fp,32($sp)
        nop
        nop
        addi sp, sp, 40            # addiu   $sp,$sp,40
        nop
        nop
        jr   ra                    # jr      $ra
        nop
        nop
        nop
        
interest:
        lw   t4, 24(fp)            # lw      $4,24($fp)
        nop
        nop
        #la   ra,    new            # la      $ra, new
        lui  ra, %hi(new)
        nop                        # NOPs after pseudo-instruction
        nop
        addi  ra, ra, %lo(new)
        nop
        nop
        j    is_visited
        nop
        nop
        nop
new:
        xori t2,    t2, 1          # xori    $2,$2,0x1
        nop
        nop
        andi t2,    t2, 0x0ff      # andi    $2,$2,0x00ff
        nop
        nop
        beq  t2,    x0, tasteful   # beq     $2,$0,tasteful
        nop
        nop
        nop
        lw   t4, 24(fp)            # lw      $4,24($fp)
        nop
        nop
        #la   ra,    partner        # la      $ra, partner
        lui  ra, %hi(partner)
        nop                        # NOPs after pseudo-instruction
        nop
        addi  ra, ra, %lo(partner)
        nop
        nop
        j    topsort
        nop
        nop
        nop
partner:

tasteful:
        addi t2,    fp, 28         # addiu   $2,$fp,28
        nop
        nop
        mv   t4,    t2             # move    $4,$2
        nop
        nop
        #la   ra,    badge          # la      $ra, badge
        lui  ra, %hi(badge)
        nop                        # NOPs after pseudo-instruction
        nop
        addi  ra, ra, %lo(badge)
        nop
        nop
        j    next_edge
        nop
        nop
        nop
badge:
        sw   t2, 24(fp)            # sw      $2,24($fp)
        nop
        nop
        
turkey:
        lw   t3, 24(fp)            # lw      $3,24($fp)
        nop                        # NOPs after load
        nop
        li   t2, -1                # li      $2,-1
        nop                        # NOPs after pseudo-instruction
        nop
        beq  t3,    t2, telling    # beq     $3,$2,telling # beq, j to simulate bne
        nop
        nop
        nop
        j    interest
        nop
        nop
        nop
telling:
        # NOTE: $v0 === $2
	#la   t2,    res_idx        # la      $v0, res_idx
        lui  t2, %hi(res_idx)
        nop                        # NOPs after pseudo-instruction
        nop
        addi  t2, t2, %lo(res_idx)
        nop
        nop
	lw   t2,  0(t2)            # lw      $v0, 0($v0)
        nop
        nop
        addi t4,    t2, -1         # addiu   $4,$2,-1
        nop
        nop
        #la   t3,    res_idx        # la      $3, res_idx
        lui  t3, %hi(res_idx)
        nop                        # NOPs after pseudo-instruction
        nop
        addi  t3, t3, %lo(res_idx)
        nop
        nop
        sw   t4,  0(t3)            # sw      $4, 0($3)
        nop
        nop
        #la   t4,    res            # la      $4, res
        lui  t4, %hi(res)
        nop                        # NOPs after pseudo-instruction
        nop
        addi  t4, t4, %lo(res)
        nop
        nop
                                   # ; lui     $3,%hi(res_idx)
                                   # ; sw      $4,%lo(res_idx)($3)
                                   # ; lui     $4,%hi(res)
        slli t3,    t2, 2          # sll     $3,$2,2
        nop
        nop
        srli t3,    t3, 1          # srl     $3,$3,1
        nop
        nop
        srai t3,    t3, 1          # sra     $3,$3,1
        nop
        nop
        slli t3,    t3, 2          # sll     $3,$3,2
        nop
        nop       
       	xor  t6,    ra, t2         # xor     $at, $ra, $2 # does nothing 
        or   t6,    ra, t2         # nor     $at, $ra, $2 # does nothing 
        neg  t6,    t6
        
        #la   t2,    res            # la      $2, res
        lui  t2, %hi(res)
        nop                        # NOPs after pseudo-instruction
        nop
        addi  t2, t2, %lo(res)
        nop                        # NOPs after pseudo-instruction
        nop
        #li   a1,    0x0000ffff     # li with 16-bit constant
        lui   a1, 0x1
        nop                        # NOPs after pseudo-instruction
        nop
        addi  a1, a1, -1
        nop                        # NOPs after pseudo-instruction
        nop
        and  t6,    t2, a1         # andi    $at, $2, 0xffff # -1 will sign extend (according to assembler), but 0xffff won't
        nop
        nop
        add  t2,    t4, t6         # addu    $2, $4, $at
        nop
        nop
        add  t2,    t3, t2         # addu    $2,$3,$2
        nop
        nop
        lw   t3, 48(fp)            # lw      $3,48($fp)
        nop
        nop
        sw   t3,  0(t2)            # sw      $3,0($2)
        nop
        nop
        mv   sp,    fp             # move    $sp,$fp
        nop
        nop
        lw   ra, 44(sp)            # lw      $31,44($sp)
        lw   fp, 40(sp)            # lw      $fp,40($sp)
        addi sp,    sp, 48         # addiu   $sp,$sp,48
        jr   ra                    # jr      $ra
        nop
        nop
        nop
   
topsort:
        addi sp,    sp, -48        # addiu   $sp,$sp,-48
        nop
        nop
        sw   ra, 44(sp)            # sw      $31,44($sp)
        sw   fp, 40(sp)            # sw      $fp,40($sp)
        nop
        nop
        mv   fp,    sp             # move    $fp,$sp
        nop
        nop
        sw   t4, 48(fp)            # sw      $4,48($fp)
        nop
        nop
        lw   t4, 48(fp)            # lw      $4,48($fp)
        #la   ra,    verse          # la      $ra, verse
        lui   ra, %hi(verse)
        nop                        # NOPs after pseudo-instruction
        nop
        addi  ra, ra, %lo(verse)
        nop
        nop
        j    mark_visited
        nop
        nop
        nop
verse:

        addi t2,    fp, 28         # addiu   $2,$fp,28
        nop
        nop
        lw   t5, 48(fp)            # lw      $5,48($fp)
        mv   t4,    t2             # move    $4,$2
        #la   ra,    joyous         # la      $ra, joyous
        lui   ra, %hi(joyous)
        nop                        # NOPs after pseudo-instruction
        nop
        addi  ra, ra, %lo(joyous)
        nop
        nop
        j    iterate_edges
        nop
        nop
        nop
joyous:

        addi t2,    fp, 28         # addiu   $2,$fp,28
        nop
        nop
        mv   t4,    t2             # move    $4,$2
        #la   ra,    whispering     # la      $ra, whispering
        lui   ra, %hi(whispering)
        nop                        # NOPs after pseudo-instruction
        nop
        addi  ra, ra, %lo(whispering)
        nop
        nop
        j    next_edge
        nop
        nop
        nop
whispering:

        sw   t2, 24(fp)            # sw      $2,24($fp)
        j    turkey
        nop
        nop
        nop

iterate_edges:
        addi sp,    sp, -24        # addiu   $sp,$sp,-24
        nop
        nop
        sw   fp, 20(sp)            # sw      $fp,20($sp)
        nop
        nop
        mv   fp,    sp             # move    $fp,$sp
        nop
        nop
        sub  t6,    fp, sp         # subu    $at, $fp, $sp
        sw   t4, 24(fp)            # sw      $4,24($fp)
        sw   t5, 28(fp)            # sw      $5,28($fp)
        lw   t2, 28(fp)            # lw      $2,28($fp)
        nop
        nop
        sw   t2,  8(fp)            # sw      $2,8($fp)
        nop
        nop
        sw   x0, 12(fp)            # sw      $0,12($fp)
        lw   t2, 24(fp)            # lw      $2,24($fp)
        lw   t4,  8(fp)            # lw      $4,8($fp)
        nop
        nop
        lw   t3, 12(fp)            # lw      $3,12($fp)
        nop
        nop
        sw   t4,  0(t2)            # sw      $4,0($2)
        sw   t3,  4(t2)            # sw      $3,4($2)
        lw   t2, 24(fp)            # lw      $2,24($fp)
        mv   sp,    fp             # move    $sp,$fp
        nop
        nop
        lw   fp, 20(sp)            # lw      $fp,20($sp)
        addi sp,    sp, 24         # addiu   $sp,$sp,24
        jr   ra                    # jr      $ra
        nop
        nop
        nop
        
next_edge:
        addi sp,    sp, -32        # addiu   $sp,$sp,-32
        nop
        nop
        sw   ra, 28(sp)            # sw      $31,28($sp)
        sw   fp, 24(sp)            # sw      $fp,24($sp)
        nop
        nop
        add  fp,    x0, sp         # add     $fp,$zero,$sp
        nop
        nop
        sw   t4, 32(fp)            # sw      $4,32($fp)
        j    waggish
        nop
        nop
        nop

snail:
        lw   t2, 32(fp)            # lw      $2,32($fp)
        nop
        nop
        lw   t3,  0(t2)            # lw      $3,0($2)
        lw   t2, 32(fp)            # lw      $2,32($fp)
        nop
        nop
        lw   t2,  4(t2)            # lw      $2,4($2)
        nop
        nop
        mv   t5,    t2             # move    $5,$2
        mv   t4,    t3             # move    $4,$3
        #la   ra,    induce         # la      $ra,induce
        lui   ra, %hi(induce)
        nop                        # NOPs after pseudo-instruction
        nop
        addi  ra, ra, %lo(induce)
        nop
        nop
        j    has_edge
        nop
        nop
        nop
induce:
        beq  t2,    x0, quarter    # beq     $2,$0,quarter
        nop
        nop
        nop
        lw   t2, 32(fp)            # lw      $2,32($fp)
        nop
        nop
        lw   t2,  4(t2)            # lw      $2,4($2)
        nop
        nop
        addi t4,    t2, 1          # addiu   $4,$2,1
        nop
        nop
        lw   t3, 32(fp)            # lw      $3,32($fp)
        nop
        nop
        sw   t4,  4(t3)            # sw      $4,4($3)
        j    cynical
        nop
        nop
        nop

quarter:
        lw   t2, 32(fp)            # lw      $2,32($fp)
        nop
        nop
        lw   t2,  4(t2)            # lw      $2,4($2)
        nop
        nop
        addi t3,    t2, 1          # addiu   $3,$2,1
        nop
        nop
        lw   t2, 32(fp)            # lw      $2,32($fp)
        nop
        nop
        sw   t3,  4(t2)            # sw      $3,4($2)

waggish:
        lw   t2, 32(fp)            # lw      $2,32($fp)
        nop
        nop
        lw   t2,  4(t2)            # lw      $2,4($2)
        nop
        nop
        slti t2,    t2, 4          # slti    $2,$2,4
        nop
        nop
        beq  t2,    x0, mark       # beq     $2,$zero,mark # beq, j to simulate bne 
        nop
        nop
        nop
        j    snail
        nop
        nop
        nop
mark:
        li   t2, -1                # li      $2,-1
        nop                        # NOPs after pseudo-instruction
        nop

cynical:
        mv   sp,    fp             # move    $sp,$fp
        nop
        nop
        lw   ra, 28(sp)            # lw      $31,28($sp)
        lw   fp, 24(sp)            # lw      $fp,24($sp)
        nop
        nop
        addi sp,    sp, 32         # addiu   $sp,$sp,32
        jr   ra     
        nop
        nop
        nop               # jr      $ra
has_edge:
        addi sp,    sp, -32        # addiu   $sp,$sp,-32
        nop
        nop
        sw   fp, 28(sp)            # sw      $fp,28($sp)
        mv   fp,    sp             # move    $fp,$sp
        nop
        nop
        sw   t4, 32(fp)            # sw      $4,32($fp)
        sw   t5, 36(fp)            # sw      $5,36($fp)
        #la   t2,    adjacencymatrix# la      $2,adjacencymatrix
        lui   t2, %hi(adjacencymatrix)
        nop                        # NOPs after pseudo-instruction
        nop
        addi  t2, t2, %lo(adjacencymatrix)
        nop
        nop
        lw   t3, 32(fp)            # lw      $3,32($fp)
        nop
        nop
        slli t3,    t3, 2          # sll     $3,$3,2
        nop
        nop
        add  t2,    t3, t2         # addu    $2,$3,$2
        nop
        nop
        lw   t2,  0(t2)            # lw      $2,0($2)
        nop
        nop
        sw   t2, 16(fp)            # sw      $2,16($fp)
        li   t2,  1                # li      $2,1
        nop                        # NOPs after pseudo-instruction
        nop
        sw   t2,  8(fp)            # sw      $2,8($fp)
        sw   x0, 12(fp)            # sw      $0,12($fp)
        nop
        nop
        j    measley
        nop
        nop
        nop

look:
        lw   t2,  8(fp)            # lw      $2,8($fp)
        nop
        nop
        slli t2,    t2, 1          # sll     $2,$2,1
        nop
        nop
        sw   t2,  8(fp)            # sw      $2,8($fp)
        nop
        nop
        lw   t2, 12(fp)            # lw      $2,12($fp)
        nop
        nop
        addi t2,    t2, 1          # addiu   $2,$2,1
        nop
        nop
        sw   t2, 12(fp)            # sw      $2,12($fp)
        nop
        nop
measley:
        lw   t3, 12(fp)            # lw      $3,12($fp)
        lw   t2, 36(fp)            # lw      $2,36($fp)
        nop
        nop
        slt  t2,    t3, t2         # slt     $2,$3,$2
        nop
        nop
        beq  t2,    x0, experience # beq     $2,$0,experience # beq, j to simulate bne 
        nop
        nop
        nop
        j    look
        nop
        nop
        nop
experience:
        lw   t3,  8(fp)            # lw      $3,8($fp)
        lw   t2, 16(fp)            # lw      $2,16($fp)
        nop
        nop
        and  t2,    t3, t2         # and     $2,$3,$2
        nop
        nop
        slt  t2,    x0, t2         # slt     $2,$0,$2
        nop
        nop
        andi t2,    t2, 0xff       # andi    $2,$2,0x00ff
        nop
        nop
        mv   sp,    fp             # move    $sp,$fp
        nop
        nop
        lw   fp, 28(sp)            # lw      $fp,28($sp)
        addi sp,    sp, 32         # addiu   $sp,$sp,32
        nop
        nop
        jr   ra                    # jr      $ra
        nop
        nop
        nop
        
mark_visited:
        addi sp,    sp, -32        # addiu   $sp,$sp,-32
        nop
        nop
        sw   fp, 28(sp)            # sw      $fp,28($sp)
        mv   fp,    sp             # move    $fp,$sp
        nop
        nop
        sw   t4, 32(fp)            # sw      $4,32($fp)
        li   t2,  1                # li      $2,1
        nop                        # NOPs after pseudo-instruction
        nop
        sw   t2,  8(fp)            # sw      $2,8($fp)
        sw   x0, 12(fp)            # sw      $0,12($fp)
        nop
        nop
        j    recast
        nop
        nop
        nop

example:
        lw   t2,  8(fp)            # lw      $2,8($fp)
        nop
        nop
        slli t2,    t2, 8          # sll     $2,$2,8
        nop
        nop
        sw   t2,  8(fp)            # sw      $2,8($fp)
        nop
        nop
        lw   t2, 12(fp)            # lw      $2,12($fp)
        nop
        nop
        addi t2,    t2, 1          # addiu   $2,$2,1
        nop
        nop
        sw   t2, 12(fp)            # sw      $2,12($fp)
        nop
        nop
recast:
        lw   t3, 12(fp)            # lw      $3,12($fp)
        lw   t2, 32(fp)            # lw      $2,32($fp)
        nop
        nop
        slt  t2,    t3, t2         # slt     $2,$3,$2
        nop
        nop
        beq  t2,    x0, pat        # beq     $2,$zero,pat # beq, j to simulate bne
        nop
        nop
        nop
        j    example
        nop
        nop
        nop
pat:

       	#la   t2, visited             # la      $2, visited
        lui   t2, %hi(visited)
        nop                        # NOPs after pseudo-instruction
        nop
        addi  t2, t2, %lo(visited)
        nop
        nop
        sw   t2, 16(fp)              # sw      $2,16($fp)
        nop
        nop
        lw   t2, 16(fp)              # lw      $2,16($fp)
        nop
        nop
        lw   t3,  0(t2)              # lw      $3,0($2)
        lw   t2,  8(fp)              # lw      $2,8($fp)
        nop
        nop
        or   t3,    t3, t2           # or      $3,$3,$2
        lw   t2, 16(fp)              # lw      $2,16($fp)
        nop
        nop
        sw   t3,  0(t2)              # sw      $3,0($2)
        mv   sp,    fp               # move    $sp,$fp
        nop
        nop
        lw   fp, 28(sp)              # lw      $fp,28($sp)
        addi sp,    sp, 32           # addiu   $sp,$sp,32
        jr   ra                      # jr      $ra
        nop
        nop
        nop
is_visited:
        addi sp,    sp, -32          # addiu   $sp,$sp,-32
        nop
        nop
        sw   fp, 28(sp)              # sw      $fp,28($sp)
        nop
        nop
        mv   fp,    sp               # move    $fp,$sp
        nop
        nop
        sw   t4, 32(fp)              # sw      $4,32($fp)
        ori  t2,    x0, 1            # ori     $2,$zero,1
        nop
        nop
        sw   t2,  8(fp)              # sw      $2,8($fp)
        sw   x0, 12(fp)              # sw      $0,12($fp)
        nop
        nop
        j    evasive
        nop
        nop
        nop

justify:
        lw   t2,  8(fp)              # lw      $2,8($fp)
        nop
        nop
        slli t2,    t2, 8            # sll     $2,$2,8
        nop
        nop
        sw   t2,  8(fp)              # sw      $2,8($fp)
        nop
        nop
        lw   t2, 12(fp)              # lw      $2,12($fp)
        nop
        nop
        addi t2,    t2, 1            # addiu   $2,$2,1
        nop
        nop
        sw   t2, 12(fp)              # sw      $2,12($fp)
        nop
        nop
evasive:
        lw   t3, 12(fp)              # lw      $3,12($fp)
        lw   t2, 32(fp)              # lw      $2,32($fp)
        nop
        nop
        slt  t2,    t3, t2           # slt     $2,$3,$2
        nop
        nop
        beq  t2,    x0,representative# beq $2,$0,representitive # beq, j to simulate bne
        nop
        nop
        nop
        j    justify
        nop
        nop
        nop
representative:

        #la   t2,    visited          # la      $2,visited
        lui   t2, %hi(visited)
        nop                        # NOPs after pseudo-instruction
        nop
        addi  t2, t2, %lo(visited)
        nop
        nop
        lw   t2,  0(t2)              # lw      $2,0($2)
        nop
        nop
        sw   t2, 16(fp)              # sw      $2,16($fp)
        nop
        nop
        lw   t3, 16(fp)              # lw      $3,16($fp)
        lw   t2,  8(fp)              # lw      $2,8($fp)
        nop
        nop
        and  t2,    t3, t2           # and     $2,$3,$2
        nop
        nop
        slt  t2,    x0, t2           # slt     $2,$0,$2
        nop
        nop
        andi t2,    t2, 0xff         # andi    $2,$2,0x00ff
        nop
        nop
        mv   sp,    fp               # move    $sp,$fp
        nop
        nop
        lw   fp, 28(sp)              # lw      $fp,28($sp)
        addi sp,    sp, 32           # addiu   $sp,$sp,32
        jr   ra                      # jr      $ra
        nop
        nop
        nop

end:
        wfi
