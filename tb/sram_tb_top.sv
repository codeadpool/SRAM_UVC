`ifndef SRAM_TB_TOP
`define SRAM_TB_TOP
`include "uvm_macros.svh"
`include "sram_if.sv"
import uvm_pkg::*;

module sram_tb_tob; 
  parameter cycle = 10;
  bit clk;
  bit rstn;

  initial begin
    clk = 0;
    forever #(cycle/2) clk = ~clk;
  end
  
  // look for rst
  initial begin
    rstn = 0;
    #(cycle*5) rstn = 1;
  end

  sram_if intf(clk, rstn);
  sram_memory_array DUT(
    .addr(intf.addr),
    .din (intf.din ),
    .dout(intf.dout),
    .we  (intf.we  )
    );

    initial begin
      uvm_config_db#(virtual sram_if)::set(uvm_root::get(), "*", "intf", sram_if);
      run_test();
    end

endmodule
