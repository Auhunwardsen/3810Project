# Test: Load-Use Hazard Stall
# Expected: PCWrite=0, IFID_Write=0, ControlMux=1

.text
.globl main

main:
    # Set up test data in memory using stores first
    addi x28, x0, 0x400     # Base address (simple offset)
    addi x29, x0, 10        # Test value 1
    sw   x29, 0(x28)        # Store 10 at address 0x400
    addi x29, x0, 20        # Test value 2  
    sw   x29, 4(x28)        # Store 20 at address 0x404
    addi x29, x0, 30        # Test value 3
    sw   x29, 8(x28)        # Store 30 at address 0x408
    
    # Test 1: Immediate use (STALL)
    lw   x1, 0(x28)         # Load x1 = 10
    add  x2, x1, x1         # Stall 1 cycle, then forward
    
    # Test 2: Load with gap (NO STALL)
    lw   x3, 4(x28)         # Load x3 = 20
    nop                     # Gap
    add  x4, x3, x0         # Forward from MEM/WB
    
    # Test 3: Simple operation (no branch complications)
    addi x5, x0, 30         # x5 = 30
    add  x6, x5, x0         # x6 = 30
    
    # Expected: x1=10, x2=20, x3=20, x4=20, x5=30, x6=30
    
    # Halt with wait for interrupt
    wfi