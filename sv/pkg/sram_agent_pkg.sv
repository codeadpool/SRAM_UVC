package sram_agent_pkg;

  parameter ADDR_WIDTH = 4;
  parameter DATA_WIDTH = 8;

  import uvm_pkg::*;
  `include "../agents/sram_packet.svh"
  `include "../agents/sram_agent_cfg.svh"
  `include "../agents/sram_driver.svh"
  `include "../agents/sram_monitor.svh"
  `include "../agents/sram_tx_agent.svh"
endpackage
