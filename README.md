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
* src
  └── sram_if.sv
  └── sram_driver.sv
  └── sram_monitor.sv
  └── sram_sequencer.sv
  └── sram_scoreboard.sv
  └── sram_cov.sv
  └── sram_agent.sv
  └── sram_env.sv
  └── sram_seq.sv
  └── sram_seq_item.sv
* tb
  └── sram_tb.sv
* doc
  └── Project documentation and related resources
* root
  └── sram_config.sv
  └── sram_utils.sv
```