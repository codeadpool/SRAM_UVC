interface sram_interface(input clk, input rstn);
  
 // Signals to SRAM  
  logic [14:0] addr;
  logic [255:0] din;
  bit wen;

  // Signals for Monitoring
  bit mon_start, drv_start;

  task sram_reset();
    @(negedge rstn);
    din <= 'hz;
    disable send_to_dut;
  endtask

  task send_to_dut(
    input bit [14:0]  address,
    input bit [255:0] datain;
    input bit         write_enable;
    input int         packet_delay;
    );

    repeat(packet_delay) @(posedge clk); 
    // @(posedge clk iff(!busy));
    addr <= address;
    din  <= datain;
    we   <= write_enable;
  endtask

endinterface
