# RISC-V Pipelined Processor Explanation

## High-Level Overview

This is a **5-stage pipelined RISC-V processor** that executes multiple instructions concurrently:

```
IF → ID → EX → MEM → WB
(Instruction Fetch → Decode → Execute → Memory → Write Back)
```

Each stage processes a different instruction on every clock cycle, achieving **~1 instruction per cycle** throughput.

---

## Pipeline Stages Explained

### Stage 1: IF (Instruction Fetch)
**File**: `fetch.vhd`
**Purpose**: Get the next instruction from instruction memory

**Key Operations**:
- Read instruction at address PC
- Compute PC+4 (next sequential instruction)
- Can be **redirected** (for branches/jumps) or **stalled** (for data hazards)

**Outputs**: PC, PC+4, Instruction

---

### Stage 2: ID (Instruction Decode)
**Location**: `RISCV_Processor.vhd` lines 510-613

**Purpose**: Decode instruction and prepare operands

**Key Components**:
1. **Control Unit** - generates control signals from opcode
2. **Register File** - reads RS1 and RS2 registers
3. **Immediate Generator** - extracts/sign-extends immediate value
4. **ID Forwarding Logic** - forwards data from MEM/WB stages for early branch/JALR resolution

**Special Feature**: **Early branch resolution** - branches and JALRs are resolved here instead of in EX stage, reducing control hazard penalty

---

### Stage 3: EX (Execute)
**Location**: `RISCV_Processor.vhd` lines 660-740

**Purpose**: Perform ALU operations and compute addresses

**Key Components**:
1. **ALU Control** - decodes funct3/funct7 to determine operation
2. **Forwarding Unit** - detects data hazards and generates forward signals
3. **Forward MUXes** - select most recent data for ALU inputs
4. **ALU** - performs computation (add, sub, and, or, slt, shifts, etc.)

**Data Forwarding Paths**:
- **MEM→EX**: Forward from MEM stage (1 instruction ahead)
- **WB→EX**: Forward from WB stage (2 instructions ahead)

---

### Stage 4: MEM (Memory Access)
**Location**: `RISCV_Processor.vhd` lines 845-865

**Purpose**: Access data memory for loads/stores

**Operations**:
- **LOAD**: Read from memory at address (ALU result)
- **STORE**: Write RS2 data to memory at address (ALU result)
- **Others**: Pass ALU result through

**Address Translation**: 0x10000000 → 0x00000000 (RISC-V data segment base)

---

### Stage 5: WB (Write Back)
**Location**: `RISCV_Processor.vhd` lines 870-920

**Purpose**: Write final result to register file

**Data Selection**:
- **LOAD**: Memory data
- **JAL/JALR**: PC+4 (link register)
- **Others**: ALU result

---

## Hazard Handling

### Data Hazards

#### 1. **Forwarding** (No stall needed)
**Example**:
```assembly
add x1, x2, x3   # Cycle 1: EX stage
sub x4, x1, x5   # Cycle 2: EX stage (needs x1)
```
**Solution**: Forward x1 from MEM stage to EX stage (MEM→EX forwarding)

**Types**:
- **MEM→EX**: Forward from EX/MEM register (1 instruction ahead)
- **WB→EX**: Forward from MEM/WB register (2 instructions ahead)
- **MEM→ID**: Forward from EX/MEM register for branches/JALR
- **WB→ID**: Forward from MEM/WB register for branches/JALR

#### 2. **Stalling** (1-cycle bubble)
**Example - Load-Use Hazard**:
```assembly
lw x1, 0(x2)     # Cycle 1: Load x1
add x3, x1, x4   # Cycle 2: Use x1 (NOT READY YET!)
```
**Problem**: Load data not available until MEM stage (cycle 2), but needed in EX stage (cycle 2)
**Solution**: Stall 1 cycle - insert NOP bubble, resume when data reaches MEM stage

**Other Stall Cases**:
- **Branch on EX result**: Branch needs register being computed in EX stage
- **JALR on EX result**: JALR target depends on register in EX stage

### Control Hazards

**Problem**: When branch/jump is taken, we already fetched the wrong next instruction

**Example**:
```assembly
beq x1, x2, Label    # Cycle 1: ID stage (branch taken!)
add x3, x4, x5       # Cycle 2: IF stage (WRONG PATH - should not execute!)
```

**Solution**: **Predict not-taken, flush on mispredict**
- Assume branch not taken, keep fetching sequentially
- When branch IS taken (detected in ID), flush IF/ID register (convert wrong instruction to NOP)
- Redirect PC to branch target

**Advantage of Early Branch Resolution**:
- Resolving in ID instead of EX reduces mispredict penalty from 2 cycles to 1 cycle

---

## Critical Bug Fixes (What We Fixed)

### Bug 1: JALR/Branch Stalling
**Problem**: JALR and branches were executing with wrong values when source registers were in EX stage
**Fix**: Modified hazard detection to **always stall** when data hazard exists (no override for control hazards)

### Bug 2: Control Hazard Flush Timing
**Problem**: Pipeline was flushing even when stalling, causing incorrect behavior
**Fix**: Only flush when `ControlHazard='1' AND DataHazard='0'`

### Bug 3: Load Forwarding to ID Stage
**Problem**: When forwarding LOAD result to ID stage (for branch/JALR), we were forwarding the **memory address** (ALU result) instead of the **loaded data**
**Fix**: Check if instruction in MEM stage is LOAD - if so, forward `s_DMemOut` (memory data) instead of `s_EXMEM_ALUResult`

Similarly for JAL/JALR: forward PC+4 instead of ALU result

---

## Key Design Decisions

### 1. **Early Branch Resolution** (ID stage instead of EX)
**Why?** Reduces control hazard penalty from 2 cycles to 1 cycle
**Tradeoff**: Requires ID→ID forwarding from MEM/WB stages

### 2. **Predict Not-Taken**
**Why?** Simpler hardware, works well for loops (most iterations don't branch)
**Tradeoff**: 1-cycle penalty on every taken branch

### 3. **Hardware Hazard Detection**
**Why?** No compiler support needed, handles all cases automatically
**Tradeoff**: More complex hardware than software-scheduled pipeline

### 4. **Dual Forwarding Paths** (EX and ID stages)
**Why?**
- EX forwarding: handles normal ALU operations
- ID forwarding: handles early branch/JALR resolution
**Tradeoff**: More complex forwarding logic

---

## Performance Analysis

**Ideal CPI**: 1.0 (one instruction per cycle)

**Penalties**:
- Load-use hazard: +1 cycle stall
- Branch misprediction: +1 cycle flush
- JALR with data hazard: +1 cycle stall

**Typical CPI**: ~1.1-1.3 depending on program characteristics

---

## File Organization

```
proj/src/
├── RISCV_Processor.vhd       # Top-level processor (pipeline stages)
├── hazard_detection.vhd      # Detects hazards, generates stall/flush signals
├── forwarding_unit.vhd       # Detects EX→EX and MEM→EX hazards
├── fetch.vhd                 # IF stage (PC logic)
├── control.vhd               # Main control unit (opcode → signals)
├── alu_control.vhd           # ALU control (funct3/7 → ALU operation)
├── alu.vhd                   # ALU implementation
├── regfile.vhd               # Register file (32 registers)
├── immgen.vhd                # Immediate generator
└── [pipeline registers]      # IFID_reg, IDEX_reg, EXMEM_reg, MEMWB_reg
```

## Quick Reference

**Forwarding Priority** (highest to lowest):
1. MEM stage (EX/MEM register)
2. WB stage (MEM/WB register)
3. Register file

**Stall Conditions**:
- Load-use hazard
- Branch depends on EX stage result
- JALR depends on EX stage RS1

**Flush Conditions**:
- Branch taken (misprediction)
- JAL/JALR detected (redirect PC)
