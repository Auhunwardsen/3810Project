
# Proj1_mergesort.s
#   Recursive Merge Sort implementation.
# 
# Expected behavior:
#   Sorts the array in ascending order in-place.
# 
# Registers:
#   a0 - base address of array
#   a1 - left index
#   a2 - right index
#   t0-t6, a3 - temporaries
#   sp - stack pointer (grows downward)

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
	# Initialize stack pointer - use explicit LUI
	lui  sp, 0x80000        # sp = 0x80000000
	nop                     # NOPs after LUI
	nop
	nop
	nop
	
	# load base address - use simple base address
    	lui  a0, 0x10000      # a0 = 0x10000000 (simple base)
    	nop
    	nop
    	nop
    	nop                   # NOPs after LUI
    	addi a1, x0, 0       # left = 0 (explicit ADDI)
    	nop                  # NOPs after instruction
    	nop
    	nop
    	nop
   	# Load n using explicit addressing (n is at base + 32 bytes offset from array)
   	addi t1, a0, 32      # t1 = base + offset to n
   	nop                  # NOPs after instruction
   	nop
   	nop
   	nop
   	lw   t0, 0(t1)       # load n value
   	nop                  # NOPs after load before use
   	nop
   	nop
   	nop
   	nop
    	addi a2, t0, -1      # right = n-1

    	jal  ra, mergesort
    	nop                  # NOPs after jal
    	nop
    	nop
	beq zero, zero, done
	nop
	nop
	nop

##############################################################
# mergesort(a0=array, a1=left, a2=right)
#   if left >= right: return
#   mid = (left + right) / 2
#   mergesort(array, left, mid)
#   mergesort(array, mid+1, right)
#   merge(array, left, mid, right)
##############################################################
mergesort:
    	bge  a1, a2, ms_return      # if left >= right, return
    	nop
    	nop
    	nop

    	add  t0, a1, a2             # t0 = left + right
    	srai t1, t0, 1              # t1 = mid = (left+right)/2

    	# push ra, a1, a2, t1 (mid)
   	addi sp, sp, -16
    	sw   ra, 12(sp)
    	sw   a1, 8(sp)
    	sw   a2, 4(sp)
    	sw   t1, 0(sp)

    	# call mergesort(array, left, mid)
    	mv   a2, t1
    	jal  ra, mergesort
    	nop
    	nop
    	nop

    	# call mergesort(array, mid+1, right)
   	lw   t1, 0(sp)
    	nop                     # NOPs after load before use
    	nop
    	nop
    	nop
    	nop
    	addi a1, t1, 1
    	lw   a2, 4(sp)
    	nop                     # NOPs after load before use
    	nop
    	nop
    	nop
    	nop
    	jal  ra, mergesort
    	nop
    	nop
    	nop

    	# call merge(array, left, mid, right)
    	lw   t1, 0(sp)
    	nop                     # NOPs after load before use
    	nop
    	nop
    	nop
    	nop
    	lw   a1, 8(sp)
    	nop                     # NOPs after load before use
    	nop
    	nop
    	nop
    	nop
    	lw   a2, 4(sp)
    	nop                     # NOPs after load before use
    	nop
    	nop
    	nop
    	nop
    	jal  ra, merge
    	nop
    	nop
    	nop

    	# pop ra and locals
    	lw   ra, 12(sp)
    	nop                     # NOPs after load before use
    	nop
    	nop
    	nop
    	nop
    	addi sp, sp, 16
    	
ms_return:
   	jr   ra


##############################################################
# merge(a0=array, a1=left, a2=right)
# mid stored in t1
#   Uses t0�t6 as temporaries.
#   Creates a local buffer on stack to hold merged elements.
##############################################################
merge:
    	# compute mid+1 and setup temp ptr
	addi sp, sp, -64        # local buffer (enough for 16 ints)
    	mv   t2, sp             # t2 = temp pointer
   	addi t3, t1, 1          # j = mid+1
    	mv   t4, a1             # i = left
    	mv   t5, zero           # k = 0

merge_loop:
    	bgt  t4, t1, copy_right
    	nop
    	nop
    	nop
   	 bgt  t3, a2, copy_left
    	nop
    	nop
    	nop

    	slli t6, t4, 2
    	add  t6, a0, t6
    	lw   s0, 0(t6)          # s0 = arr[i]
    	nop                     # NOPs after load before use
    	nop
    	nop
    	nop
    	nop

    	slli a3, t3, 2
    	add  a3, a0, a3
    	lw   s1, 0(a3)          # s1 = arr[j]
    	nop                     # NOPs after load before use
    	nop
    	nop
    	nop
    	nop

    	ble  s0, s1, take_left
    	nop
    	nop
    	nop
   	# take right
    	sw   s1, 0(t2)
    	addi t3, t3, 1
    	j    next_take
    	nop
    	nop
    	nop
    	
take_left:
    	sw   s0, 0(t2)
    	addi t4, t4, 1
    
next_take:
    	addi t2, t2, 4
    	addi t5, t5, 1
    	j merge_loop
    	nop
    	nop
    	nop

copy_left:
    	bgt  t4, t1, copy_right
    	nop
    	nop
    	nop
    	slli t6, t4, 2
    	add  t6, a0, t6
    	lw   s0, 0(t6)
    	nop                     # NOPs after load before use
    	nop
    	nop
    	nop
    	nop
   	sw   s0, 0(t2)
    	addi t4, t4, 1
    	addi t2, t2, 4
    	j copy_left
    	nop
    	nop
    	nop

copy_right:
    	bgt  t3, a2, write_back
    	nop
    	nop
    	nop
    	slli t6, t3, 2
    	add  t6, a0, t6
    	lw   s0, 0(t6)
    	nop                     # NOPs after load before use
    	nop
    	nop
    	nop
    	nop
    	sw   s0, 0(t2)
    	addi t3, t3, 1
    	addi t2, t2, 4
    	j copy_right
    	nop
    	nop
    	nop

write_back:
    	mv   t2, sp
    	mv   t4, a1
    	
wb_loop:
    	bgt  t4, a2, wb_done
    	nop
    	nop
    	nop
    	lw   s0, 0(t2)
    	nop                     # NOPs after load before use
    	nop
    	nop
    	nop
    	nop
    	slli t6, t4, 2
    	add  t6, a0, t6
    	sw   s0, 0(t6)
    	addi t2, t2, 4
    	addi t4, t4, 1
    	j wb_loop
    	nop
    	nop
    	nop

wb_done:
    	addi sp, sp, 64
   	jr ra

done:
	wfi
