
## Descriptions

- **`src/`**: Contains source files for the UVC.
  - **`sram_if.sv`**: SystemVerilog interface defining SRAM signals.
  - **`sram_driver.sv`**: UVM driver for generating and driving transactions to the SRAM.
  - **`sram_monitor.sv`**: UVM monitor for observing SRAM activity.
  - **`sram_sequencer.sv`**: UVM sequencer managing transaction sequences.
  - **`sram_scoreboard.sv`**: UVM scoreboard comparing actual results to expected results.
  - **`sram_cov.sv`**: Coverage collector for gathering functional and code coverage metrics.
  - **`sram_agent.sv`**: UVM agent that integrates the driver, monitor, and sequencer.
  - **`sram_env.sv`**: UVM environment that includes the UVC and other verification components.
  - **`sram_seq.sv`**: Sequences defining high-level transaction patterns for SRAM.
  - **`sram_seq_item.sv`**: Sequence items representing individual transactions.

- **`tb/`**: Contains the top-level testbench module.
  - **`sram_tb.sv`**: The top-level module that connects the UVC to the DUT.

- **`doc/`**: Contains documentation related to the UVC.

- **`sram_config.sv`**: Configuration parameters for the UVC and testbench.

- **`sram_utils.sv`**: Utility functions and classes used throughout the testbench.

