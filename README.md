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
├── **docs**
│   ├── openram-sram-uarch.png       # SRAM microarchitecture diagram
│   ├── srambank_128x256_6t.lib      # Library file for SRAM bank
│   └── VITAL SDF Simulation.pdf     # VITAL SDF simulation documentation
├── **dut**
│   ├── sram_cell_6t.sv              # 6T SRAM cell design
│   ├── sram_cpp_model.cpp           # C++ model for SRAM functionality
│   └── sram_memory_array.sv         # SRAM memory array implementation
├── README.md                        # Project overview and documentation
├── **sv**
│   ├── **agents**                   # Agent components for verification
│   │   ├── sram_defines.svh         # SRAM definitions
│   │   ├── sram_packet.sv           # Packet definition for SRAM transactions
│   │   ├── sram_pkg.sv              # Package for SRAM-related utilities
│   │   ├── sram_tx_agent_config.sv  # Configuration for SRAM transmit agent
│   │   ├── sram_tx_agent.sv         # SRAM transmit agent implementation
│   │   ├── sram_tx_driver.sv        # Driver for transmitting packets
│   │   ├── sram_tx_monitor.sv       # Monitor for tracking transactions
│   │   └── sram_tx_sequencer.sv     # Sequencer for generating test sequences
│   ├── ref_dut                      # Reference DUT files (if applicable)
│   └── **top**                      # Top-level components
│       ├── sram_coverage.sv         # Coverage model for SRAM
│       ├── sram_env_pkg.sv          # Environment package for verification
│       ├── sram_env.sv              # Environment setup for tests
│       └── sram_scoreboard.sv       # Scoreboard for comparing expected vs actual results
├── **tb**
│   ├── hw_top.sv                    # Top-level hardware testbench
│   ├── sram_if.sv                   # Interface definitions for SRAM
│   └── tb_top.sv                    # Testbench top-level module
└── **tests**
    ├── **seq_lib**                  # Sequence libraries for test generation
    │   ├── edge_cases_seq.sv        # Sequence for testing edge cases
    │   ├── n_pkt_seq.sv             # Sequence for testing multiple packets
    │   ├── rd_wr_seq.sv             # Read/Write sequence for SRAM
    │   ├── sram_basic_seq.sv        # Basic sequence for initial tests
    │   └── sram_seq_list.sv         # Collection of sequences for testing
    └── **src**                      # Source files for test cases
        ├── edge_seq_test.sv         # Test for edge sequences
        ├── exhaustive_seq_test.sv   # Exhaustive testing sequences
        ├── rd_wr_test.sv            # Read/Write test cases
        ├── sram_basic_test.sv       # Basic test for SRAM functionality
        └── sram_test_lib.svh        # Test library with shared utilities``
```
