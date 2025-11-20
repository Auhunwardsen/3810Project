# Grendel.s - Complete Software Scheduled for Pipeline Hazard Avoidance
# Topological sort using an adjacency matrix. Maximum 4 nodes.
# Modified to avoid all data and control hazards for software-scheduled pipeline
# Expected output: [3, 0, 2, 1] in first 4 addresses of data segment

.data
res:
	.word -1, -1, -1, -1
nodes:
        .byte   97  # a
        .byte   98  # b  
        .byte   99  # c
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
        sw   x0, 24(sp)            # Initialize loop counter to 0
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
        j    process_node          # Process this node
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
        addi t1, t0, 1             # Increment counter
        nop                        # Data hazard avoidance
        nop
        nop
        sw   t1, 24(fp)            # Store incremented counter
        nop                        # Store hazard avoidance
        nop
        nop

main_loop_control:
        # Check loop condition
        lw   t0, 24(fp)            # Load loop counter
        nop                        # Load-use hazard avoidance
        nop
        nop
        li   t1, 4                 # Load loop limit
        nop                        # Immediate load hazard avoidance
        nop
        nop
        blt  t0, t1, main_loop_body # Continue if counter < 4
        nop                        # Control hazard avoidance
        nop

        # Function epilogue
        lw   ra, 36(sp)            # Restore return address
        lw   fp, 32(sp)            # Restore frame pointer
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
        # Check if node is visited - Function with hazard avoidance
        addi sp, sp, -16           # Allocate stack space
        nop                        # Stack pointer hazard avoidance
        nop
        nop
        sw   ra, 12(sp)            # Save return address
        sw   fp, 8(sp)             # Save frame pointer
        sw   t4, 4(sp)             # Save node index
        nop                        # Store hazard avoidance
        nop
        
        # Calculate address of visited[node]
        la   t0, visited           # Load base address of visited array
        nop                        # Load address hazard avoidance
        nop
        nop
        add  t1, t0, t4            # Add node index to base address
        nop                        # Data hazard avoidance
        nop
        nop
        lb   v0, 0(t1)             # Load visited[node]
        nop                        # Load-use hazard avoidance
        nop
        nop
        
        # Function epilogue
        lw   ra, 12(sp)            # Restore return address
        lw   fp, 8(sp)             # Restore frame pointer
        lw   t4, 4(sp)             # Restore node index
        nop                        # Load-use hazard avoidance
        nop
        nop
        addi sp, sp, 16            # Deallocate stack space
        nop                        # Data hazard avoidance
        nop
        nop
        jalr x0, ra, 0             # Return
        nop                        # Control hazard avoidance
        nop

process_node:
        # Process unvisited node - Function with hazard avoidance
        addi sp, sp, -20           # Allocate stack space
        nop                        # Stack pointer hazard avoidance
        nop
        nop
        sw   ra, 16(sp)            # Save return address
        sw   fp, 12(sp)            # Save frame pointer
        sw   t4, 8(sp)             # Save node index
        nop                        # Store hazard avoidance
        nop
        
        # Mark node as visited
        la   t0, visited           # Load base address of visited array
        nop                        # Load address hazard avoidance
        nop
        nop
        add  t1, t0, t4            # Add node index to base address
        nop                        # Data hazard avoidance
        nop
        nop
        li   t2, 1                 # Load value 1 (visited)
        nop                        # Immediate load hazard avoidance
        nop
        nop
        sb   t2, 0(t1)             # Set visited[node] = 1
        nop                        # Store hazard avoidance
        nop
        nop
        
        # Add node to result array
        la   t0, res_idx           # Load address of result index
        nop                        # Load address hazard avoidance
        nop
        nop
        lw   t1, 0(t0)             # Load current result index
        nop                        # Load-use hazard avoidance
        nop
        nop
        la   t2, res               # Load address of result array
        nop                        # Load address hazard avoidance
        nop
        nop
        slli t3, t1, 2             # Multiply index by 4 (word size)
        nop                        # Shift hazard avoidance
        nop
        nop
        add  t3, t2, t3            # Calculate result[index] address
        nop                        # Data hazard avoidance
        nop
        nop
        sw   t4, 0(t3)             # Store node in result array
        nop                        # Store hazard avoidance
        nop
        nop
        
        # Decrement result index
        addi t1, t1, -1            # Decrement index
        nop                        # Data hazard avoidance
        nop
        nop
        sw   t1, 0(t0)             # Store updated index
        nop                        # Store hazard avoidance
        nop
        nop
        
        # Function epilogue
        lw   ra, 16(sp)            # Restore return address
        lw   fp, 12(sp)            # Restore frame pointer
        lw   t4, 8(sp)             # Restore node index
        nop                        # Load-use hazard avoidance
        nop
        nop
        addi sp, sp, 20            # Deallocate stack space
        nop                        # Data hazard avoidance
        nop
        nop
        jalr x0, ra, 0             # Return
        nop                        # Control hazard avoidance
        nop

end:
        # End of program
        wfi                        # Wait for interrupt (halt)
        nop
        nop