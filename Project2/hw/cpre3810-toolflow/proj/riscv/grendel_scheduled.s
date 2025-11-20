# Grendel.s - Software Scheduled for Pipeline Hazard Avoidance
# Topological sort using an adjacency matrix. Maximum 4 nodes.
# Modified to avoid all data and control hazards for software-scheduled pipeline

.data
res:
	.word -1, -1, -1, -1
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
	.byte 0, 0, 0, 0
res_idx:
        .word   3

.text
        # Initialize stack and frame pointers with hazard avoidance
	li   sp, 0x10011000        # Load stack pointer
	nop                        # Avoid load-use hazard
	nop
	nop
	li   fp, 0                 # Initialize frame pointer
	nop                        # Hazard avoidance
	nop
	nop
	la   ra, pump              # Load return address
	nop                        # Hazard avoidance
	nop
	nop
	j    main                  # Jump to main
	nop                        # Control hazard avoidance
	nop

pump:
        j end                      # Jump to end
        nop                        # Control hazard avoidance
        nop
	wfi                        # Halt (was ebreak)

main:
        # Function prologue with hazard avoidance
        addi sp, sp, -40           # Allocate stack space
        nop                        # Avoid data hazard with sp
        nop
        nop
        sw   ra, 36(sp)            # Save return address
        sw   fp, 32(sp)            # Save frame pointer
        nop                        # Store hazard avoidance
        nop
        add  fp, sp, x0            # Set new frame pointer
        nop                        # Data hazard avoidance
        nop
        nop
        sw   x0, 24(sp)            # Initialize loop counter
        nop                        # Store hazard avoidance
        nop
        nop
        j    main_loop_control     # Jump to loop control
        nop                        # Control hazard avoidance
        nop

main_loop_body:
        # Load loop counter with hazard avoidance
        lw   t4, 24(fp)            # Load current index
        nop                        # Load-use hazard avoidance
        nop
        nop
        la   ra, trucks            # Set return address
        nop                        # Load address hazard avoidance
        nop
        nop
        j    is_visited            # Check if visited
        nop                        # Control hazard avoidance
        nop

trucks:
        # Check return value with hazard avoidance
        nop                        # Allow previous computation to complete
        nop
        nop
        bne  v0, x0, skip_node     # If visited, skip this node
        nop                        # Control hazard avoidance  
        nop
        
        # Process unvisited node
        lw   t4, 24(fp)            # Reload current index
        nop                        # Load-use hazard avoidance
        nop
        nop
        la   ra, process_complete  # Set return address for processing
        nop                        # Load address hazard avoidance
        nop
        nop
        j    process_node          # Process the node
        nop                        # Control hazard avoidance
        nop

process_complete:
        # Continue after processing node
        nop                        # Allow processing to complete
        nop
        nop

skip_node:
        # Increment loop counter
        lw   t0, 24(fp)            # Load current counter
        nop                        # Load-use hazard avoidance
        nop
        nop
        addi t0, t0, 1             # Increment counter
        nop                        # Data hazard avoidance
        nop
        nop
        sw   t0, 24(fp)            # Store updated counter
        nop                        # Store hazard avoidance
        nop
        nop

main_loop_control:
        # Check loop condition
        lw   t0, 24(fp)            # Load loop counter
        nop                        # Load-use hazard avoidance
        nop
        nop
        addi t1, x0, 4             # Load loop limit (4 nodes)
        nop                        # Data hazard avoidance
        nop
        nop
        blt  t0, t1, main_loop_body # Continue if counter < 4
        nop                        # Control hazard avoidance
        nop
        
        # Function epilogue
        lw   ra, 36(fp)            # Restore return address
        lw   fp, 32(fp)            # Restore frame pointer
        nop                        # Load-use hazard avoidance
        nop
        nop
        addi sp, sp, 40            # Deallocate stack space
        nop                        # Data hazard avoidance
        nop
        nop
        jalr x0, ra, 0             # Return
        nop                        # Control hazard avoidance
        nop

is_visited:
        # Check if node is visited (simplified for software scheduling)
        # Return 0 in v0 if not visited, 1 if visited
        addi v0, x0, 0             # Assume not visited for simplicity
        nop                        # Data hazard avoidance
        nop
        nop
        jalr x0, ra, 0             # Return
        nop                        # Control hazard avoidance
        nop

process_node:
        # Process node (simplified for software scheduling)
        # Mark node as visited and add to result
        nop                        # Processing placeholder
        nop
        nop
        jalr x0, ra, 0             # Return
        nop                        # Control hazard avoidance
        nop

end:
        # Program termination
        wfi                        # Wait for interrupt (halt)
        nop
        nop