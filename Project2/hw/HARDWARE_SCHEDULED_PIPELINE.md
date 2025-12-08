# Hardware-Scheduled Pipeline Implementation (Part 2)

## Overview
This document describes the hardware-scheduled 5-stage RISC-V pipeline implementation with **hazard detection** and **data forwarding**. Unlike the software-scheduled pipeline (Part 1), this design automatically handles data and control hazards in hardware.

---

## Key Differences from Software-Scheduled Pipeline

| Feature | Software-Scheduled (Part 1) | Hardware-Scheduled (Part 2) |
|---------|----------------------------|----------------------------|
| **Hazard Detection** | None - software inserts NOPs | Hardware unit detects hazards |
| **Data Forwarding** | None - software inserts NOPs | EX→EX and MEM→EX forwarding |
| **Stalling** | None | Load-use hazards cause 1-cycle stall |
| **Branch Resolution** | Software delay slots | Hardware flush (2 cycles penalty) |
| **Pipeline Registers** | Always write | Conditional write (stall support) |
| **CPI** | 1.0 (with proper scheduling) | ~1.2-1.4 (depends on code) |
| **Code Requirements** | Must insert NOPs manually | Unmodified code works correctly |

---

## Hardware Components Added

### 1. **Forwarding Unit** (`forwarding_unit.vhd`)
Detects when a later stage contains data needed by EX stage and generates forwarding control signals.

**Forwarding Paths Implemented:**
- **EX→EX**: ALU result from EX/MEM register forwarded to EX stage
- **MEM→EX**: Write-back data from MEM/WB register forwarded to EX stage

**Forwarding Logic:**
```vhdl
-- Forward from EX/MEM (higher priority)
if (EXMEM_RegWrite = '1' and EXMEM_RD = IDEX_RS1 and EXMEM_RD ≠ 0) then
    Forward_A = "10"  -- Forward from EX/MEM
elsif (MEMWB_RegWrite = '1' and MEMWB_RD = IDEX_RS1 and MEMWB_RD ≠ 0) then
    Forward_A = "01"  -- Forward from MEM/WB
else
    Forward_A = "00"  -- Use register file
end if
```

**Forwarding Mux Select Values:**
- `00`: Use data from ID/EX register (no forwarding)
- `01`: Forward data from MEM/WB register (WB stage)
- `10`: Forward data from EX/MEM register (MEM stage)

### 2. **Hazard Detection Unit** (`hazard_detection.vhd`)
Detects hazards that cannot be resolved by forwarding and generates stall/flush signals.

**Hazards Detected:**

#### A. **Load-Use Hazard**
Occurs when an instruction uses the result of a load instruction immediately.
```
lw x1, 0(x2)      # Loads data into x1
add x3, x1, x4    # Uses x1 immediately - HAZARD!
```

**Why forwarding can't help**: Load data isn't available until MEM stage, but dependent instruction needs it in EX stage (1 cycle too early).

**Solution**: Stall pipeline for 1 cycle:
- Set `PCWrite = 0` (freeze PC)
- Set `IFID_Write = 0` (freeze IF/ID register)
- Set `ControlMux = 1` (insert NOP into ID/EX)

#### B. **Control Hazard (Branches/Jumps)**
Occurs when branch/jump decision changes PC, but wrong instructions already fetched.

**Solution**: Flush pipeline stages:
- Set `IFID_Flush = 1` (clear IF/ID register)
- Set `IDEX_Flush = 1` (clear ID/EX register)
- Correct instruction fetched next cycle

### 3. **3-to-1 Forwarding Muxes** (`mux3t1_n.vhd`)
Two 3-to-1 muxes added in EX stage to select between:
- Register file data (from ID/EX)
- Forwarded data from MEM/WB
- Forwarded data from EX/MEM

---

## Pipeline Data Paths

### Instructions that **PRODUCE** Values (Write to Register File or Memory)

| Instruction Type | Pipeline Stage | Signal Name | Description |
|-----------------|----------------|-------------|-------------|
| **R-type** (add, sub, and, or, etc.) | EX | `s_ALUResult` | ALU computation result |
| **I-type arithmetic** (addi, andi, etc.) | EX | `s_ALUResult` | ALU with immediate |
| **Load** (lw, lh, lb, etc.) | MEM | `s_DMemOut` | Data from memory |
| **U-type** (lui, auipc) | EX | `s_ALUResult` | Upper immediate result |
| **JAL/JALR** | Multiple | `s_IFID_PCplus4` | Return address (PC+4) |
| **All above** | WB | `s_WriteData` | Final write-back data |

### Instructions that **CONSUME** Values (Read from Register File)

| Instruction Type | Reads RS1? | Reads RS2? | When? |
|-----------------|-----------|-----------|-------|
| **R-type** | ✅ | ✅ | EX stage (ALU inputs) |
| **I-type arithmetic** | ✅ | ❌ | EX stage (ALU input A) |
| **Load** | ✅ | ❌ | EX stage (address calc) |
| **Store** | ✅ | ✅ | EX (address), MEM (data) |
| **Branch** | ✅ | ✅ | ID stage (comparison) |
| **JALR** | ✅ | ❌ | ID stage (target calc) |

**Special Case: Store Instructions**
- RS1 consumed in EX stage (for address calculation)
- RS2 consumed in MEM stage (data to store)
- **Both need forwarding!**

---

## Data Hazard Cases

### Case 1: EX→EX Forwarding (Back-to-Back RAW)
```assembly
add x1, x2, x3    # Cycle 1: Writes x1 in EX stage
sub x4, x1, x5    # Cycle 2: Reads x1 in EX stage
```

**Without Forwarding**: Would read stale value from register file  
**With Forwarding**: ALU result forwarded from EX/MEM register → no stall needed  
**Performance**: No stall, CPI = 1.0

### Case 2: MEM→EX Forwarding (1-Instruction Gap)
```assembly
add x1, x2, x3    # Cycle 1: Writes x1
nop               # Cycle 2: (or any instruction)
sub x4, x1, x5    # Cycle 3: Reads x1 in EX stage
```

**Without Forwarding**: Would read stale value  
**With Forwarding**: Write-back data forwarded from MEM/WB register → no stall needed  
**Performance**: No stall, CPI = 1.0

### Case 3: Load-Use Hazard (Requires Stall)
```assembly
lw x1, 0(x2)      # Cycle 1: Load x1 from memory
add x4, x1, x5    # Cycle 2: Tries to use x1
```

**Problem**: Load data not available until MEM stage (Cycle 2), but ADD needs it in EX stage (Cycle 2)  
**Solution**: Stall for 1 cycle, then forward  
**Timeline**:
- Cycle 1: LW in EX, ADD in ID
- Cycle 2: LW in MEM, ADD **stalled in ID** (NOP inserted in EX)
- Cycle 3: LW in WB, ADD in EX (data forwarded from MEM/WB)

**Performance**: 1-cycle stall, CPI increases

### Case 4: Store Data Forwarding
```assembly
add x1, x2, x3    # Writes x1
sw x1, 0(x4)      # Stores x1 to memory
```

**Special handling**: Store needs RS2 data in MEM stage  
**Solution**: Forward RS2 through ALU_B_forwarded signal  
**No stall needed** if forwarding available

---

## Control Hazard Handling

### Branch Resolution in ID Stage
Branches are resolved early (ID stage) to minimize penalty:
1. **ID Stage**: Compare RS1 and RS2, determine if branch taken
2. **If taken**: Flush IF/ID and ID/EX (2 instructions cancelled)
3. **Fetch correct instruction** from target address

**Performance**: 2-cycle penalty per taken branch

### Jump Instructions
- **JAL**: Target = PC + immediate (computed in ID)
- **JALR**: Target = RS1 + immediate (computed in ID, needs RS1 data)

**JALR with Forwarding**:
```assembly
addi x1, x0, 100  # Sets x1
jalr x0, 0(x1)    # Jumps to address in x1
```
If x1 is from a recent instruction, WB→ID forwarding ensures correct jump target.

---

## Hazard Detection Conditions

### Load-Use Hazard Detection
```
if (IDEX_MemRead = '1' and 
    ((IDEX_RD = IFID_RS1 and IFID_RS1 ≠ 0) or
     (IDEX_RD = IFID_RS2 and IFID_RS2 ≠ 0)))
then
    Stall = '1'
end if
```

### Control Hazard Detection
```
if (BranchTaken = '1' or Jump = '1')
then
    Flush_IFID = '1'
    Flush_IDEX = '1'
end if
```

---

## Pipeline Register Behavior

### IF/ID Register
- **Write Enable**: `s_IFID_Write` (from hazard detection)
  - Stalled (`WE=0`) during load-use hazards
- **Flush**: `s_IFID_Flush` (from hazard detection)
  - Flushed (`flush=1`) on taken branches/jumps

### ID/EX Register
- **Write Enable**: Always `1` (no stalling at this stage)
- **Flush**: `s_IDEX_Flush` (from hazard detection)
  - Flushed on taken branches/jumps
  - Effectively inserts NOP when `ControlMux=1` (load-use hazard)

### EX/MEM Register
- **Write Enable**: Always `1`
- **Flush**: Never (no hazards resolved here)

### MEM/WB Register
- **Write Enable**: Always `1`
- **Flush**: Never (no hazards resolved here)

---

## Performance Analysis

### CPI Breakdown
Assuming a typical program mix:

| Scenario | Frequency | Cycles | Impact on CPI |
|----------|-----------|--------|---------------|
| No hazard | 60% | 1 | +0.60 |
| EX→EX forward | 20% | 1 | +0.20 |
| MEM→EX forward | 10% | 1 | +0.10 |
| Load-use stall | 5% | 2 | +0.10 |
| Branch taken | 5% | 3 | +0.15 |
| **Total Estimated CPI** | | | **~1.15** |

### Comparison to Software-Scheduled
- **Software-Scheduled**: CPI = 1.0 (with perfect scheduling), but code size increases due to NOPs
- **Hardware-Scheduled**: CPI = 1.1-1.4 (depends on code), but code size smaller and easier to write

---

## Testing Strategy

### Required Test Programs

#### 1. **Data Forwarding Tests**
Test each forwarding case:
- ✅ EX→EX forwarding (back-to-back dependent instructions)
- ✅ MEM→EX forwarding (1-instruction gap)
- ✅ WB→ID forwarding (for branches)
- ✅ Store data forwarding

#### 2. **Hazard Detection Tests**
Test hazard detection:
- ✅ Load-use hazard (stall insertion)
- ✅ Multiple load-use hazards in sequence
- ✅ Load-use with forwarding after stall

#### 3. **Control Hazard Tests**
Test branches and jumps:
- ✅ Taken branches (all 6 types: BEQ, BNE, BLT, BGE, BLTU, BGEU)
- ✅ Not-taken branches
- ✅ JAL instruction
- ✅ JALR instruction
- ✅ Consecutive branches

#### 4. **Combined Tests**
Test multiple hazards simultaneously:
- ✅ Forwarding + load-use hazard
- ✅ Branch + forwarding
- ✅ Store after load
- ✅ Nested function calls

#### 5. **Edge Cases**
- ✅ Writing to x0 (should be ignored)
- ✅ Reading from x0 (should always be 0)
- ✅ Back-to-back loads
- ✅ Back-to-back stores

---

## Synthesis Considerations

### Critical Path Analysis
The critical path likely includes:
1. **Forwarding Unit** → detects dependencies
2. **3-to-1 Mux** → selects forwarded data
3. **ALU** → performs computation
4. **EX/MEM Register** → latches result

To improve frequency:
- Add pipeline stages (6-stage or 7-stage)
- Optimize forwarding logic (parallel comparisons)
- Use faster muxes

### Resource Utilization
Additional hardware compared to Part 1:
- **Forwarding Unit**: ~100 LEs
- **Hazard Detection**: ~50 LEs
- **2x 3-to-1 Muxes**: ~100 LEs
- **Total overhead**: ~250 LEs (~5% of processor)

---

## Validation Checklist

### Pre-Testing
- [ ] All pipeline registers support stalling (WE signal)
- [ ] All pipeline registers support flushing (flush signal)
- [ ] Forwarding unit instantiated and connected
- [ ] Hazard detection unit instantiated and connected
- [ ] 3-to-1 muxes added in EX stage
- [ ] Control mux added in ID stage

### Functional Testing
- [ ] Testbench shows pipeline register stall/flush behavior
- [ ] All forwarding paths verified in waveform
- [ ] Load-use stalls occur correctly
- [ ] Branch flushes occur correctly
- [ ] All test programs from Part 1 work without modification
- [ ] New hazard test programs work correctly

### Performance Testing
- [ ] CPI measured for various programs
- [ ] Compared to software-scheduled pipeline
- [ ] Critical path identified
- [ ] Maximum frequency achieved

---

## Known Limitations

1. **Branch Prediction**: Not implemented (always predict not-taken)
2. **Delayed Branching**: Not implemented (RISC-V doesn't use delay slots)
3. **Load-Load Hazards**: Require 1-cycle stall (no load forwarding to another load)
4. **Multiple Stalls**: Only handles one hazard at a time
5. **Out-of-Order Execution**: Not implemented (strictly in-order pipeline)

---

## References

- Patterson & Hennessy, "Computer Organization and Design: The Hardware/Software Interface" - Chapter 4
- Zybook 4.7: Data Hazards and Forwarding
- RISC-V Specification: https://riscv.org/specifications/

---

## Implementation Notes

### Why WB→ID Forwarding Only?
Branch comparisons happen in ID stage, so we only need to forward from WB stage (internal register file forwarding handles same-cycle writes).

### Why Store Instructions Need Special Handling?
Store instructions use RS2 data in MEM stage (not EX stage like other instructions), so we forward RS2 through `s_ALU_B_forwarded` to EX/MEM register.

### Why No Branch Prediction?
Adding branch prediction would require:
- Branch history table
- Branch target buffer  
- More complex control logic
- Recovery mechanism for mispredictions

This adds significant complexity and is typically left for advanced processor designs.

---

**Implementation Complete!** ✅
Hardware-scheduled pipeline with full forwarding and hazard detection is ready for testing.
