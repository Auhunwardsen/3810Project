# Project 2 Demo Preparation Guide

## Quick Reference for Demo Evaluation

---

## 1. Three Processor Designs Overview

| Design | Type | Max Freq (Fmax) | CPI | Key Feature | Complexity |
|--------|------|-----------------|-----|-------------|------------|
| **Single-Cycle** (Proj1) | Non-pipelined | **24.31 MHz** (85°C)<br>26.33 MHz (0°C) | 1.0 | Simple, one instruction per clock | Low |
| **Software-Scheduled Pipeline** | 5-stage pipeline | **24.31 MHz** (85°C)<br>26.33 MHz (0°C) | ~1.0-1.1 | Compiler inserts NOPs | Medium |
| **Hardware-Scheduled Pipeline** | 5-stage pipeline | **53.12 MHz** (85°C)<br>57.56 MHz (0°C) | ~1.1-1.2 | Forwarding + Stalling | High |

---

## 2. Synthesis Results Summary

### Single-Cycle Processor (Project 1)
- **Fmax**: 24.31 MHz (slow, 85°C) / 26.33 MHz (slow, 0°C)
- **Critical Path**: Instruction Memory → Register File → Branch Comparison → PC Selection → PC Register
- **Performance**: 1 instruction per clock, but very slow clock
- **Bottleneck**: All operations in single cycle (ALU, memory, branches)

### Software-Scheduled Pipeline (Project 2)
- **Fmax**: 24.31 MHz (slow, 85°C) / 26.33 MHz (0°C)
- **Min Clock Period**: 18.78 ns
- **Slack**: 1.22 ns
- **Critical Path**: Instruction Memory → Register File → Branch Comparison → PC Selection → PC Register
- **Key Point**: Same Fmax as single-cycle because branch resolution still happens in one stage (ID)
- **Hazard Handling**: Compiler-inserted NOPs (no hardware hazard detection)
- **Code Size**: Larger due to NOPs

### Hardware-Scheduled Pipeline (Project 2)
- **Fmax**: 53.12 MHz (slow, 85°C) / 57.56 MHz (0°C) **← BEST PERFORMANCE**
- **Min Clock Period**: 18.82 ns
- **Slack**: 1.18 ns
- **Critical Path**: EX/MEM Register → Data Memory → Forwarding Mux → Branch Comparator → PC Mux → PC Register
- **Hazard Handling**: Hardware forwarding + stalling
- **Code Size**: Smaller (no manual NOPs)
- **CPI**: Slightly higher than SW pipeline due to load-use stalls

---

## 3. Pipeline Stages (All Designs)

### Five Pipeline Stages

1. **IF (Instruction Fetch)**: Fetch instruction from memory using PC
2. **ID (Instruction Decode)**: Decode instruction, read registers, generate control signals, **resolve branches**
3. **EX (Execute)**: ALU operations, forwarding
4. **MEM (Memory Access)**: Load/store data memory operations
5. **WB (Write Back)**: Write result to register file

### Key Design Decision: Branch Resolution in ID
- Both pipelined designs resolve branches in **ID stage** (not EX)
- **Advantage**: Only 1-cycle branch penalty instead of 2
- **Tradeoff**: Requires early comparison logic in ID stage

---

## 4. Hazard Handling Comparison

### Data Hazards

| Hazard Type | Software-Scheduled | Hardware-Scheduled |
|-------------|-------------------|-------------------|
| **RAW (Read After Write)** | Compiler inserts 2 NOPs | Forwarding paths (EX→EX, MEM→EX) |
| **Load-Use** | Compiler inserts 3 NOPs | 1-cycle stall + forwarding |
| **WAR/WAW** | Avoided by compiler | Not possible in our in-order pipeline |

### Control Hazards

| Design | Strategy | Penalty | Hardware Cost |
|--------|----------|---------|---------------|
| **Software-Scheduled** | Predict not-taken | 2 NOPs after branch | None (compiler handles it) |
| **Hardware-Scheduled** | Predict not-taken + Flush | **2 cycles** (flush IF/ID and ID/EX) | Hazard detection unit |

**Important**: HW pipeline flushes **both IF/ID and ID/EX** when branch taken (verified in RISCV_Processor.vhd:1044-1045)

---

## 5. Forwarding Paths (Hardware-Scheduled Only)

### Implemented Forwarding Paths

1. **EX→EX (MEM→EX)**: Forward ALU result from MEM stage to EX stage
   - Most common case
   - Avoids 1-cycle stall for back-to-back ALU operations

2. **MEM→EX (WB→EX)**: Forward write-back data to EX stage
   - For dependencies 2 instructions apart

3. **MEM→ID**: Forward to ID stage for branch/JALR operands
   - Handles special cases: PC+4 for JAL/JALR, loaded data for loads

4. **WB→ID**: Forward write-back to ID for branches

5. **WB→MEM**: Store data forwarding for SW instructions

### Load-Use Stall (Cannot Forward)
```
LW  x1, 0(x2)    # Cycle N: Load in MEM
ADD x3, x1, x4   # Cycle N: Dependent in EX ← DATA NOT READY!
```
**Solution**: Stall 1 cycle, then forward from MEM/WB to EX

---

## 6. Base Tests for Each Design

### Single-Cycle
- **Test**: Proj1_base_test.s (unscheduled)
- **Characteristics**: Tests all instruction types, no NOPs needed

### Software-Scheduled Pipeline
- **Test**: simple_scheduled_test.s
- **Characteristics**:
  - Manually inserted NOPs for hazards
  - 2 NOPs after data dependencies
  - 3 NOPs after loads
  - 2 NOPs after branches

### Hardware-Scheduled Pipeline
- **Test**: Proj2_base_test.s (or reuse Proj1_base_test.s)
- **Characteristics**: No NOPs needed, hardware handles hazards

---

## 7. Key Waveform Tests (Hardware-Scheduled)

### Test Coverage

| Test | What It Demonstrates |
|------|---------------------|
| **vsim7 - Branch Taken** | Control hazard, 2-cycle flush penalty |
| **vsim9 - Combined Hazards** | Multiple hazards at once, priority handling |
| **vsim10 - EX-EX Forwarding** | Most common forwarding path |
| **vsim11 - Load Stalls** | Unavoidable 1-cycle stall for load-use |
| **vsim12 - MEM-EX Forwarding** | Forwarding across 2 instructions |
| **vsim2 - Mergesort** | Complex recursive algorithm, real workload |
| **vsim6 - Grendel** | Graph algorithm, sustained execution |

### Waveform Signals
- **CLK**: System clock
- **reset/reset_do**: Reset control
- **alu_out**: ALU output showing computation results
- *Note: Test waveforms only show 4 signals (not full testbench)*

---

## 8. Critical Talking Points for Demo

### Why SW and Single-Cycle Have Same Fmax?
> "Both designs have the same critical path through branch resolution in ID stage. The SW pipeline doesn't speed up the critical path—it speeds up *throughput* by overlapping instructions, not by reducing the longest combinational delay."

### Why HW Pipeline is 2x Faster?
> "The HW pipeline achieves 53 MHz because the critical path is now just through data memory and forwarding muxes, not the entire branch comparison. We trade more complex hardware (forwarding units, hazard detection) for significantly better clock frequency."

### Branch Penalty: 1 Cycle or 2?
> "Our design has a **2-cycle penalty** for taken branches because we flush both IF/ID and ID/EX pipeline registers (lines 1044-1045 in RISCV_Processor.vhd). Branch resolution happens in ID, so we must squash the instruction in IF and the partial work in ID/EX."

### Load-Use Hazards
> "Load-use stalls are unavoidable in a single-cycle memory design. When a load is in MEM stage and the next instruction needs that data in EX stage, the data simply isn't ready yet. We stall 1 cycle to let the load reach WB, then forward. This is a fundamental pipeline limitation."

### Forwarding vs NOPs
> "Hardware forwarding eliminates most stalls. For example, `ADD x1, ...; SUB x2, x1, ...` runs back-to-back with forwarding, but requires 2 NOPs in software-scheduled. This is why HW pipeline has smaller code size despite similar CPI."

---

## 9. Performance Analysis

### Speedup Calculation

**Throughput** = (Instructions / Second)

| Design | Fmax | CPI | Instructions/Second |
|--------|------|-----|---------------------|
| Single-Cycle | 24.31 MHz | 1.0 | 24.31 M inst/s |
| SW-Pipeline | 24.31 MHz | ~1.05 | ~23.15 M inst/s |
| HW-Pipeline | 53.12 MHz | ~1.15 | ~46.19 M inst/s |

**HW Pipeline vs Single-Cycle**: ~1.9x speedup
**HW Pipeline vs SW Pipeline**: ~2.0x speedup

### Why SW Pipeline Isn't Faster Than Single-Cycle?
- Same Fmax (24.31 MHz)
- Slightly worse CPI due to NOP overhead
- **But**: Shows benefit of pipelining concept (would be faster with better branch prediction)

---

## 10. Hazard Coverage Tables

### Data Hazard Coverage (from report spreadsheet [2.e.i])

*Refer to Proj2 Report 2 [2.e.i] table in your report*

### Control Hazard Coverage (from report spreadsheet [2.e.ii])

*Refer to Proj2 Report 2 [2.e.ii] table in your report*

---

## 11. Quick Answers to Common Questions

**Q: Which design is fastest?**
A: Hardware-scheduled pipeline at 53.12 MHz (2x faster than single-cycle)

**Q: Which has best CPI?**
A: Single-cycle has CPI = 1.0 exactly. SW pipeline ~1.0-1.1. HW pipeline ~1.1-1.2.

**Q: Do you have forwarding?**
A: Yes, hardware-scheduled has full forwarding (EX→EX, MEM→EX, MEM→ID, WB→ID, WB→MEM)

**Q: How do you handle load-use hazards?**
A: Software-scheduled: 3 compiler NOPs. Hardware-scheduled: 1-cycle stall + forwarding.

**Q: What's the branch penalty?**
A: **2 cycles** (flush IF/ID and ID/EX registers)

**Q: Where are branches resolved?**
A: **ID stage** (early resolution to minimize penalty)

**Q: What's the critical path in HW pipeline?**
A: EX/MEM → Data Memory → Forwarding Mux → Branch Comparator → PC Mux → PC Register

**Q: Why does SW pipeline have larger code?**
A: Compiler inserts NOPs for every hazard (2 NOPs per data hazard, 3 for load-use, 2 for branches)

**Q: Can you eliminate all stalls?**
A: No. Load-use hazards require at least 1-cycle stall because memory data isn't available until MEM stage.

---

## 12. Files to Have Ready

### Synthesis Reports
- Single-cycle: `Project1/cpre3810-toolflow/internal/QuartusWork/output_files/toolflow.sta.rpt`
- SW-pipeline: `Project2/sw/cpre3810-toolflow/internal/QuartusWork/output_files/toolflow.sta.rpt`
- HW-pipeline: `Project2/hw/cpre3810-toolflow/internal/QuartusWork/output_files/toolflow.sta.rpt`

### Test Programs
- SW base test: `Project2/sw/cpre3810_test_assembly_program_suite/simple_scheduled_test.s`
- HW base test: `Project2/hw/cpre3810-toolflow/proj/riscv/Proj2_base_test.s`
- Mergesort: `Proj1_mergesort_scheduled.s`
- Grendel: `grendel_scheduled.s`

### Processor VHDL
- HW processor: `Project2/hw/cpre3810-toolflow/proj/src/RISCV_Processor.vhd`



