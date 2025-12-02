# Software Scheduling Rules for Pure Software-Scheduled Pipeline

Based on the PDF requirements, our processor has:
- No hazard detection hardware
- No stalling logic  
- No forwarding logic
- Software must insert NOPs to avoid ALL hazards

## Required NOP Patterns:

### 1. Data Hazards (RAW - Read After Write)
```
addi x1, x0, 5    # Writes x1
nop               # Cycle 1
nop               # Cycle 2  
nop               # Cycle 3
nop               # Cycle 4
add x2, x1, x1    # Reads x1 - now safe
```

### 2. Load-Use Hazards  
```
lw x1, 0(x2)      # Load instruction
nop               # Cycle 1
nop               # Cycle 2
nop               # Cycle 3  
nop               # Cycle 4
add x3, x1, x1    # Use loaded value - now safe
```

### 3. Control Hazards (Branches/Jumps)
```
beq x1, x2, label # Branch instruction
nop               # Branch delay slot 1
nop               # Branch delay slot 2
nop               # Branch delay slot 3
addi x3, x0, 999  # This may or may not execute
```

### 4. No Pseudo-Instructions
- Replace `li` with explicit `lui`/`addi`
- Replace `la` with explicit `auipc`/`addi` or simple addresses
- Replace `j` with explicit `jal x0, target`

## Current Test Status:
- ✅ minimal_debug_test.s - Follows all rules, passes
- ✅ simple_scheduled_test.s - Follows all rules, passes  
- ❌ mergesort - Has pseudo-instructions, fails
- ❌ grendel - Has pseudo-instructions, fails