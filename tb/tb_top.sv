`ifndef TB_TOP_SV
`define TB_TOP_SV

`include "sram_if.sv"
`include "sram_tests_pkg.sv"
`include "uvm_macros.svh"

module tb_top;
  import uvm_pkg::*;               

  localparam CLOCK_PERIOD = 10;           
  localparam DATA_WIDTH = 8;
  localparam ADDR_WIDTH = 4;
  
  bit clk;                        
  bit rstn;                       

  initial begin
    clk = 0;
    forever #(CLOCK_PERIOD/2) clk = ~clk;
  end

  initial begin
    rstn = 0;                      
    #(CLOCK_PERIOD * 5);
    rstn = 1;
  end

  sram_if intf(clk, rstn);
  sram #(
    .DATA_WIDTH(DATA_WIDTH),                
    .ADDR_WIDTH(ADDR_WIDTH)                 
  ) DUT (
    .clk    (intf.clk),            // Clock input
    .rstn   (intf.rstn),           // Active-low reset
    .we_n   (intf.we_n),           // Write enable (active low)
    .addr   (intf.addr),           // Address input
    .din    (intf.din),            // Data input
    .dout   (intf.dout)            // Data output
  );
	
  initial begin

    // Increase verbosity level
    uvm_root::get().set_report_verbosity_level_hier(UVM_FULL);

    // Set up UVM configurations
//     uvm_config_db#(int)::set(null, "*", "DATA_WIDTH", DATA_WIDTH); 
//     uvm_config_db#(int)::set(null, "*", "ADDR_WIDTH", ADDR_WIDTH);
    uvm_config_db#(virtual sram_if)::set(null, "*", "vif", intf);

    // Run the test
//     run_test("sram_rand_seq_test");
    run_test("sram_edge_case_test");
//     run_test("sram_same_addr_test");
//     run_test("sram_stress_test");
  end
endmodule

`endif
