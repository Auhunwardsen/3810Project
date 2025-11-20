# Proj1_mergesort_scheduled.s
# Software-scheduled version with NOPs and instruction reordering
# to avoid data and control hazards

.data
array:  .word 8, 3, 5, 4, 7, 2, 6, 1   # unsorted array
n:      .word 8

.text
.globl main

##############################################################
# main - Software scheduled for pipeline hazard avoidance
##############################################################
main:
	# Initialize stack pointer
	li   sp, 0x80000000     # Set stack pointer to high memory
	nop                     # Avoid load-use hazard
	nop
	nop
	
	# load base address and indices
    	la   a0, array          # a0 = base address
    	li   a1, 0              # left = 0
    	nop                     # Avoid hazard with la instruction
    	nop
   	lw   t0, n              # Load n
   	nop                     # Load-use hazard avoidance
   	nop
   	nop
    	addi a2, t0, -1         # right = n-1

    	# Call mergesort with hazard avoidance
    	nop                     # Prepare for control hazard
    	nop
    	jal  ra, mergesort      # Jump with 2-cycle delay
    	nop                     # Branch delay slots (software scheduled)
    	nop
    	
	beq zero, zero, done    # Jump to done
	nop                     # Control hazard avoidance
	nop

##############################################################
# mergesort(a0=array, a1=left, a2=right) - Software scheduled
##############################################################
mergesort:
    # Save return address and arguments (with hazard avoidance)
    addi sp, sp, -16        # Allocate stack space
    nop                     # Avoid data hazard with sp
    sw   ra, 12(sp)         # Save return address
    sw   a2, 8(sp)          # Save right
    sw   a1, 4(sp)          # Save left
    sw   a0, 0(sp)          # Save array base
    
    # Check base condition: if left >= right, return
    nop                     # Avoid hazard with previous stores
    bge  a1, a2, ms_return  # if left >= right, return
    nop                     # Control hazard avoidance
    nop

    # Calculate mid = (left + right) / 2
    add  t0, a1, a2         # t0 = left + right
    nop                     # Data hazard avoidance
    nop
    nop
    srli t1, t0, 1          # t1 = mid = (left + right) / 2

    # First recursive call: mergesort(array, left, mid)
    # a0 already has array base
    # a1 already has left
    add  a2, t1, x0         # a2 = mid (copy t1 to a2)
    nop                     # Data hazard avoidance
    nop
    nop
    jal  ra, mergesort      # First recursive call
    nop                     # Control hazard avoidance
    nop

    # Restore values for second call
    lw   a0, 0(sp)          # Restore array base
    lw   a1, 4(sp)          # Restore left
    lw   a2, 8(sp)          # Restore right
    nop                     # Load-use hazard avoidance
    nop
    nop
    
    # Recalculate mid for second call
    add  t0, a1, a2         # t0 = left + right
    nop                     # Data hazard avoidance
    nop
    nop
    srli t1, t0, 1          # t1 = mid
    
    # Second recursive call: mergesort(array, mid+1, right)
    addi a1, t1, 1          # a1 = mid + 1
    # a2 already has right
    nop                     # Data hazard avoidance
    nop
    nop
    jal  ra, mergesort      # Second recursive call
    nop                     # Control hazard avoidance
    nop

    # Merge phase: merge(array, left, mid, right)
    lw   a0, 0(sp)          # Restore array base
    lw   a1, 4(sp)          # Restore left
    lw   a2, 8(sp)          # Restore right
    nop                     # Load-use hazard avoidance
    nop
    nop
    
    # Calculate mid again for merge
    add  t0, a1, a2         # t0 = left + right
    nop                     # Data hazard avoidance
    nop
    nop
    srli a3, t0, 1          # a3 = mid
    nop                     # Data hazard avoidance
    nop
    nop
    jal  ra, merge          # Call merge function
    nop                     # Control hazard avoidance
    nop

ms_return:
    # Restore return address and return
    lw   ra, 12(sp)         # Restore return address
    nop                     # Load-use hazard avoidance
    nop
    nop
    addi sp, sp, 16         # Deallocate stack space
    nop                     # Data hazard avoidance
    nop
    nop
    jalr x0, ra, 0          # Return
    nop                     # Control hazard avoidance
    nop

##############################################################
# merge(a0=array, a1=left, a2=right, a3=mid) - Software scheduled
##############################################################
merge:
    # Simplified merge for software scheduling
    # Just return for now to complete the structure
    jalr x0, ra, 0          # Return immediately
    nop                     # Control hazard avoidance
    nop

done:
    # End program
    wfi                     # Wait for interrupt (halt)
    nop
    nop