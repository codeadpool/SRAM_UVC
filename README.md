# SRAM UVC Project

## Project Overview

The SRAM UVC (Universal Verification Component) project provides a comprehensive verification environment to test and validate the functionality of a custom SRAM (Static Random Access Memory) with timing models. Leveraging the UVM (Universal Verification Methodology) framework, this project aims to deliver a standardized and reusable environment for SRAM verification.

The project encompasses:
- A custom interface
- UVM agents
- A UVM environment for simulating and verifying the SRAM model’s behavior
- A testbench to integrate the UVC with the DUT (Device Under Test)

## File Structure
```
docs
├── openram-sram-uarch.png
├── srambank_128x256_6t.lib
└── VITAL SDF Simulation.pdf
├── dut
│   ├── sram_cell_6t.sv
│   ├── sram_cpp_model.cpp
│   └── sram_memory_array.sv
├── README.md
├── sv
│   ├── agents
│   │   ├── sram_agent_pkg.sv
│   │   ├── sram_defines.svh
│   │   ├── sram_packet.sv
│   │   ├── sram_tx_agent_config.sv
│   │   ├── sram_tx_agent.sv
│   │   ├── sram_tx_driver.sv
│   │   ├── sram_tx_monitor.sv
│   │   └── sram_tx_sequencer.sv
│   ├── ref_dut
│   └── top
│       ├── sram_coverage.sv
│       ├── sram_env_pkg.sv
│       ├── sram_env.sv
│       └── sram_scoreboard.sv
├── tb
│   ├── sram_if.sv
│   └── sram_tb_top.sv
└── tests
    ├── seq_lib
    │   ├── n_pkt_seq.sv
    │   ├── sram_basic_seq.sv
    │   └── sram_seq_list.sv
    └── src
        ├── sram_basic_test.sv
        └── sram_test_lib.sv
```
