# Test Coverage Analysis for Pipelined RISC-V Processor
# Project Part 2 - Testing Documentation

## Data Hazard Detection and Forwarding Test Coverage

### Test Case Matrix

| Test Case ID | Hazard Type | Source Stage | Destination Stage | Register | Forwarding Required | Test Program | Expected Result |
|--------------|-------------|--------------|-------------------|----------|-------------------|--------------|-----------------|
| DH-01 | RAW | EX/MEM | EX | x1 | Yes (EX/MEM→EX) | data_hazard_test1.s | Forward_A = "10" |
| DH-02 | RAW | MEM/WB | EX | x4 | Yes (MEM/WB→EX) | data_hazard_test1.s | Forward_A = "01" |
| DH-03 | Load-Use | MEM | EX | x7 | No (Stall required) | data_hazard_test1.s | PCWrite = '0', Stall = 1 cycle |
| DH-04 | RAW Chain | EX/MEM, MEM/WB | EX | x9,x10,x11 | Yes (Multiple) | data_hazard_test1.s | Forward_A = "10", Forward_B = "01" |
| DH-05 | No Hazard | - | - | x12,x13,x14 | No | data_hazard_test1.s | Forward_A = "00", Forward_B = "00" |

### Load-Store Hazard Test Cases

| Test Case ID | Hazard Type | Description | Test Program | Expected Result |
|--------------|-------------|-------------|--------------|-----------------|
| LS-01 | Load-Use | Load followed by immediate use | data_hazard_test1.s | 1-cycle stall |
| LS-02 | Store after Load | Load then store same location | combined_hazard_test.s | Forwarding + Memory consistency |
| LS-03 | Load-Store Different | Load/Store different addresses | simple_scheduled_test.s | No hazard |

## Control Hazard Detection Test Coverage

### Branch Instruction Test Cases

| Test Case ID | Instruction | Taken/Not Taken | Pipeline Effect | Test Program | Expected Result |
|--------------|-------------|-----------------|-----------------|--------------|-----------------|
| CH-01 | BEQ | Taken | Flush IF/ID, ID/EX | control_hazard_test1.s | IFID_Flush = '1', IDEX_Flush = '1' |
| CH-02 | BNE | Not Taken | No flush needed | control_hazard_test1.s | No flush signals |
| CH-03 | BLT | Taken | Flush pipeline | control_hazard_test1.s | 2-cycle bubble |
| CH-04 | BGE | Taken | Flush pipeline | control_hazard_test1.s | 2-cycle bubble |

### Jump Instruction Test Cases

| Test Case ID | Instruction | Description | Test Program | Expected Result |
|--------------|-------------|-------------|--------------|-----------------|
| CH-05 | JAL | Unconditional jump | control_hazard_test1.s | Flush 2 instructions |
| CH-06 | JALR | Register-based jump | control_hazard_test1.s | Flush 2 instructions |

## Combined Hazard Test Coverage

### Simultaneous Hazard Cases

| Test Case ID | Hazard Combination | Description | Test Program | Expected Behavior |
|--------------|-------------------|-------------|--------------|-------------------|
| CB-01 | Load-Use + Branch | Load followed by branch on loaded value | combined_hazard_test.s | Stall then flush |
| CB-02 | Forward + Branch | Forward data used in branch condition | combined_hazard_test.s | Forward then flush |
| CB-03 | JAL + Data Dependency | Jump with pending data dependencies | combined_hazard_test.s | Flush + maintain forwarding |

## Software-Scheduled Pipeline Test Coverage  

### Hazard Avoidance Verification

| Test Case ID | Avoidance Method | Description | Test Program | Verification |
|--------------|------------------|-------------|--------------|--------------|
| SS-01 | NOP Insertion | 3 NOPs after load | simple_scheduled_test.s | No stalls |
| SS-02 | Instruction Reordering | Independent instructions between dependencies | Proj1_mergesort_scheduled.s | Optimal scheduling |
| SS-03 | Branch Delay | 2 NOPs after branches | simple_scheduled_test.s | No flush needed |

## Test Program Summary

### Data Hazard Programs
- **data_hazard_test1.s**: Comprehensive RAW hazard testing
- **simple_scheduled_test.s**: Software-scheduled version with hazard avoidance

### Control Hazard Programs  
- **control_hazard_test1.s**: All branch and jump instruction types
- **combined_hazard_test.s**: Mixed data and control hazards

### Application Programs
- **Proj1_mergesort_scheduled.s**: Real application with manual scheduling
- **Proj1_cf_test.s**: Control flow intensive test (to be scheduled)

## Coverage Statistics

### Instruction Coverage
- ✅ R-type instructions: ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU
- ✅ I-type instructions: ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI, SLTI, SLTIU
- ✅ Load instructions: LW, LH, LB, LHU, LBU  
- ✅ Store instructions: SW, SH, SB
- ✅ Branch instructions: BEQ, BNE, BLT, BGE, BLTU, BGEU
- ✅ Jump instructions: JAL, JALR
- ✅ Upper immediate: LUI, AUIPC

### Hazard Coverage
- ✅ EX/MEM to EX forwarding: 100%
- ✅ MEM/WB to EX forwarding: 100%  
- ✅ Load-use stall detection: 100%
- ✅ Control hazard flush: 100%
- ✅ Priority forwarding (EX/MEM over MEM/WB): 100%
- ✅ No forwarding for x0: 100%

### Edge Case Coverage
- ✅ Back-to-back dependencies
- ✅ Multiple register dependencies in single instruction
- ✅ Forwarding with immediate operands
- ✅ Control hazards with data dependencies
- ✅ Pipeline flush during forwarding

## Test Execution Plan

### Phase 1: Unit Testing (Pipeline Registers)
1. Run `tb_pipeline_registers.vhd` - verify stall/flush functionality
2. Run `tb_hazard_forwarding.vhd` - verify hazard detection logic

### Phase 2: Software-Scheduled Testing  
1. Test `simple_scheduled_test.s` - basic instruction verification
2. Test `Proj1_mergesort_scheduled.s` - complex application

### Phase 3: Hardware-Scheduled Testing
1. Test data hazard programs with automatic forwarding
2. Test control hazard programs with automatic flushing  
3. Test combined hazard scenarios

### Phase 4: Integration Testing
1. Verify all single-cycle test programs work unmodified
2. Performance comparison between software and hardware scheduling
3. Synthesis timing analysis

## Success Criteria

### Functional Requirements
- All test programs execute correctly
- Hazard detection catches 100% of hazards
- Forwarding eliminates unnecessary stalls
- Control hazards flush correct pipeline stages

### Performance Requirements  
- Hardware-scheduled pipeline shows improvement over software-scheduled
- No incorrect hazard detections (false positives)
- Minimal stall cycles for unavoidable hazards

### Timing Requirements
- Meet timing constraints for target FPGA
- Critical path identification and optimization
- Maximum frequency documentation