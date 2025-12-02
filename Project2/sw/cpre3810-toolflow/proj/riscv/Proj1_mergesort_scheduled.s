
# Proj1_mergesort_scheduled.s
#   Recursive Merge Sort implementation.
# 
#   This file has been scheduled to run on a 5-stage pipeline without hardware
#   hazard detection or forwarding. NOPs have been inserted to prevent data and
#   control hazards.

.data
array:  .word 8, 3, 5, 4, 7, 2, 6, 1   # unsorted array
n:      .word 8

.text
.globl main

##############################################################
# main
# - Initializes stack pointer and calls mergesort
##############################################################
main:
	# Initialize stack pointer
	lui  x2, 0x80000        # Load upper 20 bits
	nop                     # RAW hazard prevention
	nop                     # RAW hazard prevention  
	addi x2, x2, 0          # Add lower 12 bits (0)
	
	# load base address and indices - software scheduled with instruction reordering
    	la   x10, array       # x10 = base address (expands to auipc + addi)
    	li   x11, 0           # left = 0 (expands to addi x11, x0, 0)
   	lw   x5, n           # Load array size (expands to auipc + lw)
   	# Use independent instructions to provide scheduling delay
   	addi x2, x2, 0       # Stack pointer already set (no-op for delay)
   	addi x2, x2, 0       # Additional delay
   	addi x2, x2, 0       # Additional delay  
   	addi x2, x2, 0       # Additional delay
   	addi x2, x2, 0       # Additional delay
    	addi x12, x5, -1      # right = n-1 (now safe to use x5)

    jal  x1, mergesort
	nop
	beq zero, zero, done
	nop

##############################################################
# mergesort(x10=array, x11=left, x12=right)
#   if left >= right: return
#   mid = (left + right) / 2
#   mergesort(array, left, mid)
#   mergesort(array, mid+1, right)
#   merge(array, left, mid, right)
##############################################################
mergesort:
    bge  a1, a2, ms_return      # if left >= right, return
    nop

    add  t0, a1, a2             # t0 = left + right
    nop
    nop
    srai t1, t0, 1              # t1 = mid = (left+right)/2

    # push ra, a1, a2, t1 (mid)
   	addi sp, sp, -16
    nop
    nop
    sw   ra, 12(sp)
    sw   a1, 8(sp)
    sw   a2, 4(sp)
    sw   t1, 0(sp)

    # call mergesort(array, left, mid)
    mv   a2, t1
    jal  ra, mergesort
    nop

    # call mergesort(array, mid+1, right)
   	lw   t1, 0(sp)
    nop
    nop
    nop
    add  a1, t1, 1
    lw   a2, 4(sp)
    nop
    nop
    nop
    jal  ra, mergesort
    nop

    # call merge(array, left, mid, right)
    lw   t1, 0(sp)
    lw   a1, 8(sp)
    lw   a2, 4(sp)
    nop
    nop
    nop
    jal  ra, merge
    nop

    # pop ra and locals
    lw   ra, 12(sp)
    nop
    nop
    nop
    addi sp, sp, 16
    nop
    	
ms_return:
   	jr   ra
	nop


##############################################################
# merge(a0=array, a1=left, a2=right)
# mid stored in t1
#   Uses t0t6 as temporaries.
#   Creates a local buffer on stack to hold merged elements.
##############################################################
merge:
    # compute mid+1 and setup temp ptr
	addi sp, sp, -64        # local buffer (enough for 16 ints)
    nop
    nop
    mv   t2, sp             # t2 = temp pointer
   	add  t3, t1, 1          # j = mid+1
    mv   t4, a1             # i = left
    mv   t5, zero           # k = 0

merge_loop:
    bgt  t4, t1, copy_right
    nop
   	bgt  t3, a2, copy_left
    nop

    slli t6, t4, 2
    nop
    nop
    add  t6, a0, t6
    nop
    nop
    lw   s0, 0(t6)          # s0 = arr[i]

    slli a3, t3, 2
    nop
    nop
    add  a3, a0, a3
    nop
    nop
    lw   s1, 0(a3)          # s1 = arr[j]
    nop
    nop
    nop
    ble  s0, s1, take_left
   	nop
    # take right
    sw   s1, 0(t2)
    add  t3, t3, 1
    j    next_take
    nop
    	
take_left:
    sw   s0, 0(t2)
    add  t4, t4, 1
    
next_take:
    add  t2, t2, 4
    add  t5, t5, 1
    j merge_loop
    nop

copy_left:
    bgt  t4, t1, copy_right
    nop
    slli t6, t4, 2
    nop
    nop
    add  t6, a0, t6
    nop
    nop
    lw   s0, 0(t6)
    nop
    nop
    nop
   	sw   s0, 0(t2)
    add  t4, t4, 1
    add  t2, t2, 4
    j copy_left
    nop

copy_right:
    bgt  t3, a2, write_back
    nop
    slli t6, t3, 2
    nop
    nop
    add  t6, a0, t6
    nop
    nop
    lw   s0, 0(t6)
    nop
    nop
    nop
    sw   s0, 0(t2)
    add  t3, t3, 1
    add  t2, t2, 4
    j copy_right
    nop

write_back:
    mv   t2, sp
    mv   t4, a1
    	
wb_loop:
    bgt  t4, a2, wb_done
    nop
    lw   s0, 0(t2)
    slli t6, t4, 2
    nop
    nop
    nop
    add  t6, a0, t6
    nop
    nop
    sw   s0, 0(t6)
    add  t2, t2, 4
    add  t4, t4, 1
    j wb_loop
    nop

wb_done:
    addi sp, sp, 64
    nop
   	jr ra
	nop

done:
	wfi
