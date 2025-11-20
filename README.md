# Project 2 - Pipelined RISC-V Processors

### Part 1: Software-Scheduled Pipeline
DONE:
- Pipeline register components with stall/flush (IFID_reg, IDEX_reg, EXMEM_reg, MEMWB_reg) in src_sw
- Pipeline register testbench (tb_pipeline_registers.vhd)
- Software-scheduled processor testbench (tb_processor_sw.vhd)
- Simple scheduled test program (simple_scheduled_test.s)
- Modified mergesort with proper instruction scheduling (Proj1_mergesort_scheduled.s)
- Multiple grendel versions (grendel_original.s, grendel_scheduled.s, grendel_complete_scheduled.s)

NOT DONE:
- Waveform files (.wlf) for all test programs
- Synthesis to DE2 FPGA and critical path analysis for software pipeline
- Complete integration testing of software-scheduled processor

### Part 2: Hardware-Scheduled Pipeline
DONE:
- Hazard detection unit (hazard_detection.vhd)
- Data forwarding unit (forwarding_unit.vhd)
- 3-to-1 mux for forwarding paths (mux3t1_n.vhd)
- All pipeline register components copied to src_hw
- Hardware-scheduled processor testbench (tb_processor_hw.vhd)
- Hazard and forwarding unit testbench (tb_hazard_forwarding.vhd)
- Comprehensive test programs:
  - Data hazard test (data_hazard_test1.s)
  - Control hazard test (control_hazard_test1.s)
  - Combined hazard test (combined_hazard_test.s)

NOT DONE:
- Complete processor integration in src_hw/RISCV_Processor.vhd
- Waveform files (.wlf) for all hardware test programs
- Synthesis to DE2 FPGA and critical path analysis for hardware pipeline
- Complete integration testing of hardware-scheduled processor

### Documentation
DONE:
- Team contract (Proj2_team_contract.pdf)
- Test coverage analysis (Test_Coverage_Analysis.md)
- Project completion guide (COMPLETION_GUIDE_CLEAN.md)
- Missing components analysis (MISSING_ANALYSIS.md)

NOT DONE:
- Complete project report (Proj2.pdf needs completion)
- Annotated waveforms for all test cases
- Performance analysis and comparison between designs
- Synthesis results and critical path documentation




