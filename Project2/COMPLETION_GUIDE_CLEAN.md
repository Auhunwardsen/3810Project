# Project 2 Completion Checklist and Instructions
# Updated for 11/20 deadline

## CRITICAL - What You've Just Received

### NEW FILES CREATED:
1. **Hardware-Scheduled Pipeline Components:**
   - `src_hw/hazard_detection.vhd` - Detects load-use and control hazards
   - `src_hw/forwarding_unit.vhd` - Implements data forwarding logic  
   - `src_hw/mux3t1_n.vhd` - 3-to-1 mux for forwarding paths
   - Updated `src_hw/RISCV_Processor.vhd` with hazard detection components

2. **Comprehensive Test Programs:**
   - `riscv/data_hazard_test1.s` - Tests all data forwarding scenarios
   - `riscv/control_hazard_test1.s` - Tests branch/jump hazard flushing
   - `riscv/combined_hazard_test.s` - Tests simultaneous hazards
   - `riscv/simple_scheduled_test.s` - Software-scheduled with NOPs
   - `riscv/Proj1_mergesort_scheduled.s` - Mergesort with hazard avoidance

3. **Test Verification:**
   - `test/tb_hazard_forwarding.vhd` - Unit tests for hazard detection
   - `Documentation/Test_Coverage_Analysis.md` - Complete test coverage matrix

## IMMEDIATE ACTIONS NEEDED (Today - 11/19)

### Step 1: Test Your Software-Scheduled Pipeline
```bash
# Navigate to toolflow directory
cd Project1/cpre3810-toolflow

# Test simple program first
./3810_tf.sh test ../../Project2/riscv/simple_scheduled_test.s ../../Project2/src_sw/

# If successful, test mergesort
./3810_tf.sh test ../../Project2/riscv/Proj1_mergesort_scheduled.s ../../Project2/src_sw/
```

### Step 2: Complete the Missing Grendel Program
The project requires a modified grendel program. You need to:
```bash
# Copy original grendel to Project2
cp Project1/cpre3810_test_assembly_program_suite/grendel.s Project2/riscv/grendel_original.s

# Create software-scheduled version
# (The grendel_scheduled.s already exists but may need completion)
```

### Step 3: Integrate Hardware-Scheduled Pipeline
Your `src_hw/RISCV_Processor.vhd` needs to be completed with:
- Instantiate hazard_detection unit
- Instantiate forwarding_unit  
- Add mux3t1_n components for forwarding paths
- Wire up stall and flush signals

### Step 4: Test Hardware-Scheduled Pipeline
```bash
# Test data hazard detection
./3810_tf.sh test ../../Project2/riscv/data_hazard_test1.s ../../Project2/src_hw/

# Test control hazard detection  
./3810_tf.sh test ../../Project2/riscv/control_hazard_test1.s ../../Project2/src_hw/

# Test combined hazards
./3810_tf.sh test ../../Project2/riscv/combined_hazard_test.s ../../Project2/src_hw/
```

## FINAL DELIVERABLES CHECKLIST

### Software-Scheduled Pipeline (src_sw):
- [x] Pipeline registers with stall/flush capability
- [x] 5-stage datapath implementation
- [x] Software-scheduled test programs with NOPs
- [ ] **NEED**: Waveform showing 2 iterations of mergesort
- [ ] **NEED**: Synthesis report and critical path analysis

### Hardware-Scheduled Pipeline (src_hw):
- [x] Hazard detection unit implemented
- [x] Forwarding unit implemented  
- [x] Pipeline register updates for stall/flush
- [ ] **NEED**: Complete processor integration
- [ ] **NEED**: Comprehensive testing and waveforms
- [ ] **NEED**: Synthesis report and critical path analysis

### Testing Requirements:
- [x] Unit tests for pipeline registers
- [x] Unit tests for hazard detection/forwarding
- [x] Comprehensive test programs created
- [x] Test coverage matrix documented
- [ ] **NEED**: Execute all tests and capture waveforms
- [ ] **NEED**: Verify single-cycle programs work unmodified

### Documentation:
- [x] Test coverage analysis completed
- [ ] **NEED**: Complete project report (Proj2_report.doc)
- [ ] **NEED**: Annotated waveforms for key test cases
- [ ] **NEED**: Performance analysis and synthesis results

## MISSING COMPONENTS ANALYSIS

### Critical Missing Items:
1. **Grendel Program**: Complete software-scheduled version required
2. **Hardware Processor Integration**: RISCV_Processor.vhd needs hazard unit instantiations
3. **Pipeline Register Components**: Need to ensure all registers support stall/flush properly
4. **Branch Prediction**: May need basic branch prediction logic
5. **Register File Bypass**: May need register file with bypass capability

### Verification Missing:
1. **Waveform Files**: .wlf files for demonstrating operation
2. **Synthesis Results**: Timing reports and critical path analysis
3. **Performance Comparison**: Software vs Hardware scheduled performance metrics

## INTEGRATION STEPS FOR HARDWARE PIPELINE

### 1. Complete RISCV_Processor.vhd Integration:
Add these instantiations to your processor:

```vhdl
-- Hazard Detection Unit
HAZARD_DETECT: hazard_detection
  port map(
    i_IDEX_MemRead  => s_IDEX_MemRead,
    i_IDEX_RD       => s_IDEX_RD,
    i_IFID_RS1      => s_IFID_Instr(19 downto 15),
    i_IFID_RS2      => s_IFID_Instr(24 downto 20),
    i_Branch        => s_Branch,
    i_Jump          => s_Jump,
    o_PCWrite       => s_PCWrite,
    o_IFID_Write    => s_IFID_Write,
    o_ControlMux    => s_ControlMux,
    o_IFID_Flush    => s_IFID_Flush,
    o_IDEX_Flush    => s_IDEX_Flush
  );

-- Forwarding Unit  
FORWARD_UNIT: forwarding_unit
  port map(
    i_IDEX_RS1      => s_IDEX_RS1,
    i_IDEX_RS2      => s_IDEX_RS2,
    i_EXMEM_RD      => s_EXMEM_RD,
    i_MEMWB_RD      => s_MEMWB_RD,
    i_EXMEM_RegWrite => s_EXMEM_RegWrite,
    i_MEMWB_RegWrite => s_MEMWB_RegWrite,
    o_Forward_A     => s_Forward_A,
    o_Forward_B     => s_Forward_B
  );
```

### 2. Add Forwarding Multiplexers:
```vhdl  
-- Forwarding mux for ALU input A
FORWARD_MUX_A: mux3t1_n
  port map(
    i_S   => s_Forward_A,
    i_D0  => s_IDEX_RS1Data,        -- From register file
    i_D1  => s_MEMWB_WriteData,     -- From MEM/WB stage
    i_D2  => s_EXMEM_ALUResult,     -- From EX/MEM stage
    o_O   => s_ALU_Input_A
  );
```

## QUICK TESTING STRATEGY

### Minimum Viable Testing (if time is short):
1. **Priority 1**: Get simple_scheduled_test.s working on both pipelines
2. **Priority 2**: Verify data_hazard_test1.s shows proper forwarding
3. **Priority 3**: Verify control_hazard_test1.s shows proper flushing
4. **Priority 4**: Get basic mergesort working

### Waveform Requirements:
- Show 5-stage pipeline operation with valid instructions in each stage
- Demonstrate forwarding paths in action (EX/MEM->EX, MEM/WB->EX)
- Show stall cycles for load-use hazards
- Show flush cycles for control hazards

## FINAL SUBMISSION PREP

### Generate Submissions:
```bash
# Software-scheduled submission
./3810_tf.sh submit sw

# Hardware-scheduled submission  
./3810_tf.sh submit hw
```

### Required Files:
- `submit_proj2_sw.zip` (software-scheduled implementation)
- `submit_proj2_hw.zip` (hardware-scheduled implementation)  
- `Proj2_report.pdf` (complete project report)

### Critical Path Analysis:
Use synthesis tools to identify:
- Maximum frequency for each pipeline
- Critical path components
- Resource utilization comparison

## IF YOU'RE REALLY BEHIND

### Absolute Minimum to Submit:
1. Working software-scheduled pipeline with basic test
2. Hardware pipeline with hazard detection (even if not fully integrated)
3. Documentation of what you implemented
4. Test coverage showing your testing approach

### Get Help:
- Talk to instructor about partial credit options
- Focus on demonstrating understanding rather than completeness
- Document what you learned and what you would do differently

## SUCCESS METRICS

By end of 11/20, you should have:
- [x] Both pipelines compile without errors
- [ ] Basic test programs execute correctly  
- [ ] Waveforms showing pipeline operation
- [ ] Synthesis reports with timing analysis
- [ ] Complete project report
- [ ] All submission files generated

Remember: It's better to have a working simple implementation than a complex broken one!