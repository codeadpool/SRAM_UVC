`include "sram_seqs_pkg.sv"

package sram_env_pkg;

  import uvm_pkg::*;
  import sram_agent_pkg::*;
  import sram_seqs_pkg::*;

  `include "../top/sram_coverage.svh"
  `include "../top/sram_scoreboard.svh"
  `include "../top/sram_env.svh"
endpackage
