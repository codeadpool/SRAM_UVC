`ifndef SRAM_PACKAGE 
`define SRAM_PACKAGE

package sram_package;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `include "sram_packet.sv"
  `include "sram_if.sv"

  `include "sram_tx_monitor.sv"
  `include "sram_tx_sequencer.sv"
  `include "sram_tx_seqs.sv"
  `include "sram_tx_driver.sv"
  `include "sram_tx_agent_config.sv"
  `include "sram_tx_agent.sv"
  
  `include "sram_env.sv"
endpackage
`endif
