# SRAM UVC Project
=====================

## Project Overview
-------------------

The SRAM UVC (Universal Verification Component) project is a verification environment designed to test and validate the functionality of a custom SRAM (Static Random Access Memory) with timing models. The project utilizes the UVM (Universal Verification Methodology) framework to provide a standardized and reusable verification environment.

The SRAM UVC project includes a custom interface, UVM agents, and a UVM environment to simulate and verify the SRAM model's behavior. The project also includes a testbench to connect the UVC to the DUT.

## File System
--------------

### Source Files
#### src/

* `sram_if.sv`
* `sram_driver.sv`
* `sram_monitor.sv`
* `sram_sequencer.sv`
* `sram_scoreboard.sv`
* `sram_cov.sv`
* `sram_agent.sv`
* `sram_env.sv`
* `sram_seq.sv`
* `sram_seq_item.sv`

### Testbench
#### tb/

* `sram_tb.sv`

### Documentation
#### doc/

### Configuration and Utilities

* `sram_config.sv`
* `sram_utils.sv`