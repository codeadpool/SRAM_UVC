`ifndef TB_TOP
`define TB_TOP
module tb_top;
  import uvm_pkg::*;
  import sram_pkg::*;
  `include "uvm_macros.svh"
  `include "hw_top.sv"
  `include "sram_test_lib.svh"

  initial begin
    uvm_config_db#(virtual sram_if)::set(null, "*.tb.sram_env.agent.*", "vif", hw_top.sram_if); 
    run_test();
  end
endmodule
`endif
