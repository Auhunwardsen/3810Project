# Comprehensive debug test for processor validation
# Tests each component systematically to isolate bugs

.data
test_mem: .word 0x12345678, 0xABCDEF00, 0x11111111, 0x22222222

.text
.globl main

main:
    # ========== PHASE 1: Basic I-Type Instructions ==========
    # Test ADDI with different immediate values
    addi x1, x0, 1      # x1 = 1 (test small positive)
    addi x2, x0, -1     # x2 = -1 (test negative)  
    addi x3, x0, 255    # x3 = 255 (test max 8-bit positive)
    addi x4, x0, -256   # x4 = -256 (test min 9-bit negative)
    addi x5, x0, 0      # x5 = 0 (test zero)
    
    # Wait many cycles before next test
    nop; nop; nop; nop; nop; nop; nop; nop; nop; nop
    
    # ========== PHASE 2: R-Type Instructions ==========  
    # Test ADD operations (should be x1+x2 = 1+(-1) = 0)
    add x6, x1, x2      # x6 = x1 + x2 = 1 + (-1) = 0
    nop; nop; nop; nop; nop; nop; nop; nop; nop; nop
    
    # Test SUB operations (should be x3-x4 = 255-(-256) = 511)
    sub x7, x3, x4      # x7 = x3 - x4 = 255 - (-256) = 511
    nop; nop; nop; nop; nop; nop; nop; nop; nop; nop
    
    # Test AND operations (should be x1&x3 = 1&255 = 1)
    and x8, x1, x3      # x8 = x1 & x3 = 1 & 255 = 1
    nop; nop; nop; nop; nop; nop; nop; nop; nop; nop
    
    # Test OR operations (should be x1|x2 = 1|(-1) = -1)
    or x9, x1, x2       # x9 = x1 | x2 = 1 | (-1) = -1
    nop; nop; nop; nop; nop; nop; nop; nop; nop; nop
    
    # Test XOR operations (should be x1^x1 = 0)
    xor x10, x1, x1     # x10 = x1 ^ x1 = 1 ^ 1 = 0
    nop; nop; nop; nop; nop; nop; nop; nop; nop; nop
    
    # ========== PHASE 3: Shift Instructions ==========
    # Test left shift (should be 1 << 2 = 4)
    slli x11, x1, 2     # x11 = x1 << 2 = 1 << 2 = 4
    nop; nop; nop; nop; nop; nop; nop; nop; nop; nop
    
    # Test right logical shift (should be 255 >> 1 = 127)
    srli x12, x3, 1     # x12 = x3 >> 1 = 255 >> 1 = 127
    nop; nop; nop; nop; nop; nop; nop; nop; nop; nop
    
    # Test right arithmetic shift (should be -1 >>> 1 = -1)
    srai x13, x2, 1     # x13 = x2 >>> 1 = -1 >>> 1 = -1
    nop; nop; nop; nop; nop; nop; nop; nop; nop; nop
    
    # ========== PHASE 4: Comparison Instructions ==========
    # Test set less than (should be 1 < 255 = 1)
    slt x14, x1, x3     # x14 = (x1 < x3) = (1 < 255) = 1
    nop; nop; nop; nop; nop; nop; nop; nop; nop; nop
    
    # Test set less than immediate (should be 255 < 300 = 1)
    slti x15, x3, 300   # x15 = (x3 < 300) = (255 < 300) = 1
    nop; nop; nop; nop; nop; nop; nop; nop; nop; nop
    
    # ========== PHASE 5: U-Type Instructions ==========
    # Test LUI (Load Upper Immediate)
    lui x16, 0x12345    # x16 = 0x12345000
    nop; nop; nop; nop; nop; nop; nop; nop; nop; nop
    
    # Test AUIPC (Add Upper Immediate to PC)
    auipc x17, 0x1000   # x17 = PC + 0x1000000
    nop; nop; nop; nop; nop; nop; nop; nop; nop; nop
    
    # ========== PHASE 6: Memory Instructions ==========
    # Use a simple base address (assume data starts at 0x10000000)
    lui x18, 0x10000    # x18 = 0x10000000 (base data address)
    nop; nop; nop; nop; nop; nop; nop; nop; nop; nop
    
    # Store some test values first
    addi x20, x0, 0x123 # x20 = 0x123 (test value 1)
    nop; nop; nop; nop; nop; nop; nop; nop; nop; nop
    sw x20, 0(x18)      # store 0x123 to mem[0x10000000]
    nop; nop; nop; nop; nop; nop; nop; nop; nop; nop
    
    addi x20, x0, 0x456 # x20 = 0x456 (test value 2)  
    nop; nop; nop; nop; nop; nop; nop; nop; nop; nop
    sw x20, 4(x18)      # store 0x456 to mem[0x10000004]
    nop; nop; nop; nop; nop; nop; nop; nop; nop; nop
    
    # Test load word (should load back what we stored)
    lw x19, 0(x18)      # x19 = mem[0x10000000] = 0x123
    nop; nop; nop; nop; nop; nop; nop; nop; nop; nop
    lw x21, 4(x18)      # x21 = mem[0x10000004] = 0x456
    nop; nop; nop; nop; nop; nop; nop; nop; nop; nop
    
    # ========== PHASE 7: Branch Instructions ==========
    # Test BEQ (should branch)
    beq x1, x1, branch_test1    # x1 == x1, should branch
    addi x22, x0, 0xBAD         # should NOT execute
    
branch_test1:
    addi x22, x0, 0xC001        # x22 = 0xC001 (good value)
    nop; nop; nop; nop; nop; nop; nop; nop; nop; nop
    
    # Test BNE (should branch)
    bne x1, x2, branch_test2    # x1 != x2, should branch  
    addi x23, x0, 0xBAD         # should NOT execute
    
branch_test2:
    addi x23, x0, 0xC002        # x23 = 0xC002 (good value)
    nop; nop; nop; nop; nop; nop; nop; nop; nop; nop
    
    # ========== PHASE 8: Jump Instructions ==========
    # Test JAL
    jal x24, jump_test          # x24 = return address
    addi x25, x0, 0xBAD         # should NOT execute
    
jump_return:
    addi x25, x0, 0xC003        # x25 = 0xC003 (good value)
    nop; nop; nop; nop; nop; nop; nop; nop; nop; nop
    
    # ========== TEST COMPLETE ==========
    # Final signature values for validation:
    # x1=1, x2=-1, x3=255, x6=0, x7=511, x8=1, x9=-1, x10=0
    # x11=4, x12=127, x13=-1, x14=1, x15=1, x19=0x12345678, x21=0x999
    # x22=0xC001, x23=0xC002, x25=0xC003
    wfi
    
jump_test:
    # Simple jump target - return via JALR
    addi x26, x0, 0xC004        # x26 = 0xC004 (mark we were here)
    nop; nop; nop; nop; nop; nop; nop; nop; nop; nop
    jalr x0, x24, 0             # return to jump_return