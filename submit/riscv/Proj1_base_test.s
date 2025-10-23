# Basic RISC-V Test Program

.data
array: .word 5, 10, 15, 20, 25    # Array of 5 values

.text
main:
    # Test addi instructions
    addi x1, x0, 5       # x1 = 5
    addi x2, x0, 10      # x2 = 10
    
    # Test arithmetic operations
    add  x3, x1, x2      # x3 = x1 + x2 = 15
    sub  x4, x3, x1      # x4 = x3 - x1 = 10
    
    # Test logical operations
    and  x5, x3, x4      # x5 = x3 & x4 = 10 (binary: 1111 & 1010 = 1010)
    or   x6, x1, x2      # x6 = x1 | x2 = 15 (binary: 0101 | 1010 = 1111)
    xor  x7, x3, x4      # x7 = x3 ^ x4 = 5  (binary: 1111 ^ 1010 = 0101)
    
    # Test shift operations
    slli x8, x1, 2       # x8 = x1 << 2 = 20
    srli x9, x8, 1       # x9 = x8 >> 1 = 10
    
    # Test memory operations
    la   x10, array      # Load address of array into x10
    lw   x11, 0(x10)     # Load first element (5) into x11
    lw   x12, 4(x10)     # Load second element (10) into x12
    add  x13, x11, x12   # x13 = x11 + x12 = 15
    sw   x13, 20(x10)    # Store x13 at sixth element position
    
    # Test branch operations
    beq  x1, x1, label1  # Should branch to label1 (x1 equals x1)
    addi x14, x0, 100    # Should be skipped
    
label1:
    bne  x1, x2, label2  # Should branch to label2 (x1 doesn't equal x2)
    addi x14, x0, 200    # Should be skipped
    
label2:
    slt  x15, x1, x2     # x15 = (x1 < x2) ? 1 : 0 = 1
    
    # Exit (implementation specific - might be wfi or just halt)
    wfi      