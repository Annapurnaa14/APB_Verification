# APB Slave Verification

SystemVerilog / UVM-style testbench for functional and assertion-based verification of an APB Slave with internal memory, simulated using QuestaSim.

---

## Overview
This repository contains the RTL design and a layered SystemVerilog verification environment for an APB Slave device with a configurable internal memory array. 

## Design Under Test (DUT)

`apb_slave` is a parameterized RTL module.

| Parameter | Description | Default |
|---|---|---|
| `ADDR_WIDTH` | Address bus width | 9 |
| `DATA_WIDTH` | Data bus width | 32 |
| `MEM_DEPTH` | Number of memory locations | 256 |

Key behaviour:
- Single-cycle access — `PREADY` is tied high (no wait states).
- Write: `PWDATA` is written to `memory[PADDR]` byte-by-byte, gated by `PSTRB`.
- Read: `PRDATA` is registered from `memory[PADDR]`, or driven to all-1s on an out-of-range read.
- Reset: `PRESETn` (active-low, asynchronous) clears memory and `PRDATA` to zero.
- Error: `PSLVERR` asserts whenever a valid transfer targets an address outside `MEM_DEPTH`.

## Repository Structure

```
.
├── apb_slave.sv          # RTL design (DUT)
├── define.sv             # Shared macro definitions
├── apb_pkg/               # Package: imports/includes all testbench class files
├── apb_interface.sv       # APB interface (signals, clocking blocks, modports)
├── apb_transaction.sv     # Randomizable APB transaction (sequence item)
├── apb_generator.sv       # Stimulus generator
├── apb_driver.sv          # Drives transactions onto the DUT via the interface
├── apb_monitor.sv         # Passively samples DUT interface activity
├── apb_scoreboard.sv      # Checks DUT responses against a reference model
├── apb_coverage.sv        # Functional coverage (covergroups/coverpoints)
├── apb_assertions.sv      # SVA protocol assertions, bound to the interface
├── apb_environment.sv     # Top-level verification environment
├── apb_test.sv            # Top-level test class
└── testbench.sv           # Top-level testbench module (instantiates DUT, interface, test)
```

## Testbench Architecture

```
testbench.sv
 └─ apb_test
     └─ apb_environment
         ├─ apb_generator ──▶ apb_driver ─┐
         ├─ apb_monitor  ◀────────────────┘   (via apb_interface)
         ├─ apb_scoreboard  (checks monitor data vs reference model)
         └─ apb_coverage    (samples functional coverage)

apb_interface ── connects driver / monitor ── apb_slave (DUT)
apb_assertions ── bound directly to apb_interface (independent protocol checks)
```

## Verification Plan

Verification tracking is maintained with three sheets:
- **Verification_Plan** — Functional test list 
- **Assertion_Plan** — SVA protocol assertions 
- **Coverage_Plan** — Functional coverpoints, including state transitions and cross-coverage.

