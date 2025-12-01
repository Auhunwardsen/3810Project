# RISC-V Test File Organization

## Software-Scheduled Pipeline (SW)
**Directory:** `sw/cpre3810-toolflow/proj/riscv/`

**Contains ONLY scheduled programs (with NOPs for hazard avoidance):**
- `simple_scheduled_test.s` - Basic scheduled test program
- `Proj1_mergesort_scheduled.s` - Scheduled mergesort (main application)
- `grendel_scheduled.s` - Scheduled grendel program  
- `grendel_complete_scheduled.s` - Enhanced scheduled grendel

**Purpose:** These tests should PASS on software pipeline because hazards are manually avoided.

## Hardware-Scheduled Pipeline (HW)
**Directory:** `hw/cpre3810-toolflow/proj/riscv/`

**Contains hazard detection tests AND comparison programs:**
- `data_hazard_test1.s` - Tests data forwarding requirements
- `control_hazard_test1.s` - Tests branch/jump hazard handling
- `combined_hazard_test.s` - Tests simultaneous hazards
- `Proj1_cf_test.s` - Control flow intensive test (unscheduled)
- `Proj1_mergesort.s` - Original mergesort (unscheduled)
- `Proj1_mergesort_scheduled.s` - Scheduled mergesort (for comparison)
- `grendel_original.s` - Original grendel (unscheduled)
- `grendel_scheduled.s` - Scheduled grendel (for comparison)

**Purpose:** Hardware pipeline should handle BOTH scheduled and unscheduled programs correctly.

## Testing Strategy

### Software Pipeline Testing:
```bash
cd sw/cpre3810-toolflow
./3810_tf.sh test proj/riscv/simple_scheduled_test.s 
./3810_tf.sh test proj/riscv/Proj1_mergesort_scheduled.s 
./3810_tf.sh test proj/riscv/grendel_scheduled.s 
```

### Hardware Pipeline Testing:
```bash
cd hw/cpre3810-toolflow
# Test hazard detection
./3810_tf.sh test proj/riscv/data_hazard_test1.s 
./3810_tf.sh test proj/riscv/control_hazard_test1.s 
./3810_tf.sh test proj/riscv/combined_hazard_test.s 

# Test unscheduled programs (should work with hardware hazard handling)
./3810_tf.sh test proj/riscv/Proj1_mergesort.s 
./3810_tf.sh test proj/riscv/Proj1_cf_test.s 

# Test scheduled programs (should also work)
./3810_tf.sh test proj/riscv/Proj1_mergesort_scheduled.s 
```

## Key Differences

**Software Pipeline:**
- ❌ No hazard detection hardware
- ❌ No data forwarding  
- ❌ No automatic stalling
- ✅ Requires manually scheduled programs
- ✅ Should FAIL on unscheduled programs with hazards

**Hardware Pipeline:**  
- ✅ Has hazard detection unit
- ✅ Has forwarding unit
- ✅ Has automatic stall/flush capability
- ✅ Should handle both scheduled AND unscheduled programs
- ✅ Should show performance benefit on unscheduled code