# RISC-V Pipelined Processor Implementation

## Overview
This project implements two 5-stage pipelined RISC-V processors supporting the RV32I instruction set:
1. **Software-Scheduled Pipeline (SW)**: Relies on software (compiler/programmer) to insert NOPs and reorder instructions to avoid hazards
2. **Hardware-Scheduled Pipeline (HW)**: Uses hardware hazard detection, stalling, and forwarding to handle hazards automatically

Both processors implement the classic 5-stage RISC-V pipeline: **IF → ID → EX → MEM → WB**

---

## Pipeline Stages

### 1. Instruction Fetch (IF)
- **Components**: `fetch.vhd`, `IFID_reg.vhd`
- **Operation**:
  - Fetches instruction from memory at address stored in Program Counter (PC)
  - PC increments by 4 (PC+4) for sequential execution
  - For branches/jumps, PC is updated with target address
  - Instruction and PC+4 passed to IF/ID pipeline register
- **Signals**: `PC`, `Instruction`, `PC+4`

### 2. Instruction Decode (ID)
- **Components**: `control.vhd`, `regfile.vhd`, `immgen.vhd`, `IDEX_reg.vhd`
- **Operation**:
  - Decodes instruction opcode and generates control signals
  - Reads two source registers (RS1, RS2) from register file
  - Generates immediate value from instruction bits
  - All control signals and data passed to ID/EX pipeline register
- **Control Signals Generated**: `RegWrite`, `MemWrite`, `MemRead`, `Branch`, `Jump`, `ALUSrc`, `MemtoReg`, `ALUOp`
- **Data Outputs**: `RS1Data`, `RS2Data`, `Immediate`, `RS1`, `RS2`, `RD`

### 3. Execute (EX)
- **Components**: `alu.vhd`, `alu_control.vhd`, `EXMEM_reg.vhd`
- **Operation**:
  - ALU performs arithmetic/logic operations based on ALUOp control signal
  - Calculates branch target address (PC + Immediate)
  - Compares operands for branch conditions
  - Results passed to EX/MEM pipeline register
- **ALU Operations**: ADD, SUB, AND, OR, XOR, SLT, SLTU, SLL, SRL, SRA
- **Outputs**: `ALUResult`, `Zero flag`, `Branch target address`

### 4. Memory (MEM)
- **Components**: `mem.vhd`, `MEMWB_reg.vhd`
- **Operation**:
  - Accesses data memory for load/store instructions
  - For loads: reads data from memory at address = ALUResult
  - For stores: writes RS2Data to memory at address = ALUResult
  - Passes ALU result and memory data to MEM/WB register
- **Memory Operations**: LW, LH, LB, LHU, LBU, SW, SH, SB
- **Outputs**: `MemData`, `ALUResult`

### 5. Write Back (WB)
- **Components**: `regfile.vhd` (write port)
- **Operation**:
  - Selects data to write back to register file (ALU result or memory data)
  - Writes to destination register (RD) if RegWrite = 1
  - Register x0 always reads as 0 (writes ignored)
- **Write Data Source**: ALU result (R-type, I-type arithmetic) or Memory data (loads)

---

## Software-Scheduled Pipeline (SW)

### Design Philosophy
Assumes **software handles all hazards** by inserting NOPs or reordering instructions. Hardware has no hazard detection, stalling, or forwarding logic.

### Key Features
- ✅ **No Hazard Detection**: No logic to detect RAW, WAW, or control hazards
- ✅ **No Stalling**: Pipeline always advances every cycle (no bubble insertion)
- ✅ **No EX/MEM Forwarding**: No bypass paths from ALU or memory back to ALU inputs
- ✅ **Internal Register File Forwarding**: Register file supports read-during-write (essential for any pipeline)
- ✅ **Software Scheduling**: Assembly programs include NOPs between dependent instructions

### Register File Implementation (`regfile.vhd`)
```vhdl
-- Internal forwarding: if reading same register being written, bypass
o_RS1Data <= i_WriteData when (i_WE = '1' and i_RD = i_RS1 and i_RD /= "00000") 
             else rs1_mux_out;
o_RS2Data <= i_WriteData when (i_WE = '1' and i_RD = i_RS2 and i_RD /= "00000") 
             else rs2_mux_out;
```

**Why Internal Forwarding is Required**:
- In pipelined processors, register write (WB stage) and read (ID stage) occur in the same cycle
- Without forwarding, reads get stale data instead of the value being written
- This is NOT the same as pipeline forwarding—it's standard register file behavior
- Patterson & Hennessy textbook assumes this: "write in first half of cycle, read in second half"

### Example: Software-Scheduled Code
```assembly
# Original code with hazard:
addi x1, x0, 10      # Cycle 1: Write x1
addi x2, x1, 5       # Cycle 2: Read x1 (too soon! RAW hazard)

# Software-scheduled version:
addi x1, x0, 10      # Cycle 1: Write x1
nop                  # Cycle 2: Bubble
nop                  # Cycle 3: Bubble
nop                  # Cycle 4: Bubble
addi x2, x1, 5       # Cycle 5: Read x1 (safe, x1 written back in cycle 5)
```

### Limitations
- ❌ Cannot run arbitrary RISC-V code (requires scheduling)
- ❌ Performance penalty from NOPs (lower IPC)
- ❌ Programmer/compiler responsible for correctness

---

## Hardware-Scheduled Pipeline (HW)

### Design Philosophy
**Hardware detects and resolves all hazards** automatically. Any valid RISC-V program runs correctly without modification.

### Key Features
- ✅ **Hazard Detection Unit**: Detects RAW hazards and load-use hazards
- ✅ **Forwarding Unit**: Implements EX→EX and MEM→EX data forwarding
- ✅ **Stalling Logic**: Stalls pipeline for load-use hazards
- ✅ **Control Hazard Handling**: Flushes pipeline on branches/jumps
- ✅ **Internal Register File Forwarding**: Same as SW pipeline

---

## Hardware Components (HW Pipeline)

### Forwarding Unit (`forwarding_unit.vhd`)

**Purpose**: Detects when EX stage needs data from later pipeline stages and generates forwarding control signals.

**Algorithm**:
```
For ALU Input A (RS1):
  IF (EXMEM.RegWrite AND EXMEM.RD ≠ 0 AND EXMEM.RD = IDEX.RS1)
    Forward from EX/MEM stage (o_Forward_A = "10")
  ELSE IF (MEMWB.RegWrite AND MEMWB.RD ≠ 0 AND MEMWB.RD = IDEX.RS1)
    Forward from MEM/WB stage (o_Forward_A = "01")
  ELSE
    No forwarding (o_Forward_A = "00")

Same logic for ALU Input B (RS2)
```

**Priority**: EX/MEM forwarding takes priority over MEM/WB forwarding (more recent data)

**Implementation**:
- Inputs: RS1/RS2 addresses from ID/EX, RD addresses and RegWrite signals from EX/MEM and MEM/WB
- Outputs: 2-bit control signals `o_Forward_A` and `o_Forward_B`
- Forwarding muxes in processor select between:
  - "00": Register file data (no hazard)
  - "01": MEM/WB result (MEM hazard)
  - "10": EX/MEM result (EX hazard)

### Hazard Detection Unit (`hazard_detection.vhd`)

**Purpose**: Detects hazards that cannot be resolved by forwarding and generates stall/flush signals.

**Load-Use Hazard Detection**:
```
IF (IDEX.MemRead = 1 AND 
    ((IDEX.RD = IFID.RS1 AND IFID.RS1 ≠ 0) OR 
     (IDEX.RD = IFID.RS2 AND IFID.RS2 ≠ 0)))
  THEN stall pipeline (insert bubble in EX stage)
```

**Why Load-Use Requires Stalling**:
- Load instruction reads memory in MEM stage (cycle N+3)
- Next instruction needs loaded data in EX stage (cycle N+4)
- Forwarding alone insufficient—need 1-cycle stall

**Control Hazard Handling**:
```
IF (Branch taken OR Jump instruction)
  THEN flush IF/ID and ID/EX stages (insert 2 bubbles)
```

**Outputs**:
- `o_PCWrite`: Enables/disables PC update (0 = stall PC)
- `o_IFID_Write`: Enables/disables IF/ID register write (0 = stall IF/ID)
- `o_ControlMux`: Selects NOP insertion (1 = insert NOP in ID/EX)
- `o_IFID_Flush`: Flushes IF/ID register on control hazard
- `o_IDEX_Flush`: Flushes ID/EX register on control hazard

### Three-Input Forwarding Mux (`mux3t1_n.vhd`)

**Purpose**: Selects ALU operand source based on forwarding control signals.

**Inputs**:
- `i_D0`: Data from register file (no forwarding)
- `i_D1`: Data from MEM/WB stage (MEM hazard)
- `i_D2`: Data from EX/MEM stage (EX hazard)
- `i_S`: 2-bit select signal from forwarding unit

**Implementation**: Two instances in processor (one for each ALU input)

---

## Example Hazard Scenarios (HW Pipeline)

### Scenario 1: EX Hazard (Forwarding)
```assembly
add x1, x2, x3    # Cycle 1: Writes x1 in EX stage (cycle 4)
sub x4, x1, x5    # Cycle 2: Needs x1 in EX stage (cycle 5)
```

**Resolution**:
- Cycle 4: `add` completes in EX, result in EX/MEM register
- Cycle 5: Forwarding unit detects `EXMEM.RD (x1) = IDEX.RS1 (x1)`
- Forwarding mux selects EX/MEM result instead of register file data
- **No stall required**

### Scenario 2: Load-Use Hazard (Stall + Forwarding)
```assembly
lw  x1, 0(x2)     # Cycle 1: Reads memory in MEM stage (cycle 4)
add x3, x1, x4    # Cycle 2: Needs x1 in EX stage (cycle 5)
```

**Resolution**:
- Cycle 3: Hazard detection detects `IDEX.MemRead=1 AND IDEX.RD=IFID.RS1`
- Cycle 3: Stall PC, stall IF/ID, insert NOP in ID/EX (bubble)
- Cycle 4: `lw` reads memory, result in MEM/WB register
- Cycle 5: `add` executes, forwarding unit forwards MEM/WB result
- **1-cycle stall required**

### Scenario 3: Control Hazard (Flush)
```assembly
beq x1, x2, label # Cycle 1: Branch decision in EX stage (cycle 4)
add x3, x4, x5    # Cycle 2: Should not execute if branch taken
sub x6, x7, x8    # Cycle 3: Should not execute if branch taken
label: ...
```

**Resolution**:
- Cycle 4: Branch decision made in EX stage
- If taken: Hazard detection flushes IF/ID and ID/EX (2 bubbles), updates PC to branch target
- Next valid instruction fetched from target address
- **2-cycle penalty for taken branches**

---

## Pipeline Registers

### IFID_reg.vhd
- **Inputs**: Instruction, PC+4
- **Outputs**: Instruction, PC+4
- **Control**: Write enable (stalled on load-use), Flush (on control hazard)

### IDEX_reg.vhd
- **Inputs**: Control signals, RS1Data, RS2Data, Immediate, RS1, RS2, RD, PC+4
- **Outputs**: All of above signals
- **Control**: Flush (on control hazard or load-use stall)

### EXMEM_reg.vhd
- **Inputs**: ALUResult, RS2Data (for stores), RD, Control signals
- **Outputs**: All of above signals
- **Control**: Always enabled (no stalling at this stage)

### MEMWB_reg.vhd
- **Inputs**: MemData, ALUResult, RD, RegWrite
- **Outputs**: All of above signals
- **Control**: Always enabled (no stalling at this stage)

---

## Control Signals

| Signal | Description | Stages Used |
|--------|-------------|-------------|
| RegWrite | Enable register file write | ID, WB |
| MemWrite | Enable data memory write | ID, MEM |
| MemRead | Enable data memory read | ID, MEM |
| Branch | Branch instruction | ID, EX |
| Jump | Jump instruction | ID, EX |
| ALUSrc | Select ALU operand B (0=RS2, 1=Immediate) | ID, EX |
| MemtoReg | Select write data (0=ALU, 1=Memory) | ID, WB |
| ALUOp | ALU operation code | ID, EX |

---

## Testing Strategy

### SW Pipeline Tests
- All tests are **software-scheduled** with NOPs inserted between dependent instructions
- Tests verify pipeline executes correctly when software handles hazards
- Example tests: `grendel_scheduled.s`, `Proj1_mergesort_scheduled.s`, `simple_scheduled_test.s`

### HW Pipeline Tests
- **Unmodified tests** from single-cycle processor (Project 1)
- Tests contain RAW hazards, load-use hazards, and control hazards
- Verifies hardware correctly detects and resolves all hazard types
- Tests should produce identical results to SW pipeline (when SW has proper scheduling)

### Test Coverage
1. **Data Hazard Tests**: All combinations of RAW hazards (EX, MEM forwarding)
2. **Load-Use Tests**: Load followed immediately by dependent instruction
3. **Control Hazard Tests**: All branch/jump instructions, taken and not-taken cases
4. **Combined Hazards**: Multiple simultaneous hazards in pipeline

---

## Performance Analysis

### Ideal CPI (Cycles Per Instruction)
- **SW Pipeline**: 1.0 CPI (assuming no hazards after scheduling)
- **HW Pipeline**: ~1.0 CPI (depends on hazard frequency)

### Hazard Penalties (HW Pipeline)
- **EX/MEM Hazard**: 0 cycles (resolved by forwarding)
- **Load-Use Hazard**: 1 cycle stall
- **Branch Taken**: 2 cycles (flush IF/ID, ID/EX)
- **Branch Not Taken**: 0 cycles

### Critical Path
The maximum clock frequency is determined by the slowest pipeline stage. Typically:
1. **MEM stage**: Memory access time dominates
2. **EX stage**: ALU + forwarding mux delay
3. **ID stage**: Register file read + control logic

Synthesis results show maximum frequency and critical path components.

---

## Comparison: SW vs HW Pipeline

| Feature | SW Pipeline | HW Pipeline |
|---------|-------------|-------------|
| Hazard Detection | None | Full (RAW, load-use, control) |
| Forwarding | Internal regfile only | Internal + EX/MEM forwarding |
| Stalling | None | Load-use hazards |
| Code Compatibility | Requires scheduling | Runs any RV32I code |
| Complexity | Simple | Complex (more logic, muxes) |
| Performance | Lower (NOPs reduce IPC) | Higher (fewer stalls) |
| Power | Lower (less logic) | Higher (more active logic) |
| Use Case | Embedded/low-power | General-purpose processors |

---

## Design Decisions

### Why Internal Regfile Forwarding in Both?
- **Required for correctness**: Without it, register writes don't appear to reads in same cycle
- **Standard feature**: All textbook pipelined processors assume this
- **Not "cheating" for SW**: This is basic register file behavior, not hazard mitigation

### Why 2-Cycle Branch Penalty (HW)?
- Branch decision made in EX stage (cycle 3 after IF)
- Instructions in IF and ID stages are from wrong path
- Must flush both stages (2 bubbles)
- Alternative: Branch prediction (not required for this project)

### Why Stall for Load-Use Only (HW)?
- Most RAW hazards resolved by forwarding
- Load instructions produce data in MEM stage (1 cycle later than ALU instructions)
- Cannot forward from MEM to EX in same cycle
- 1-cycle stall allows forwarding from MEM/WB in next cycle

---

## Conclusion

Both processors successfully implement the 5-stage RISC-V pipeline with different hazard handling strategies:
- **SW pipeline** demonstrates understanding of pipeline hazards and software scheduling techniques
- **HW pipeline** demonstrates understanding of hardware hazard detection, forwarding, and stalling mechanisms

The internal register file forwarding in both processors is essential for correctness and aligns with standard pipeline design practices described in Patterson & Hennessy's textbook.
