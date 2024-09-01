interface sram_interface(
  input logic clk,
  input logic rstn
);
  // Signals to SRAM
  logic [14:0]  addr;
  logic [255:0] din;
  logic [255:0] dout;
  logic we;
  
  // Signals for Monitoring
  logic valid_tx;    

  task sram_reset();
    @(negedge rstn);
    din  <= 'hz;
    addr <= 'hz;
    we   <= 1'b0;
    valid_tx <= 1'b0;
  endtask

  task write_to_sram(
    input logic [14:0] address,
    input logic [255:0] datain,
    input bit write_enable
  );
    @(negedge clk);
    addr <= address;
    din  <= datain;
    we   <= write_enable;
    valid_tx <= 1'b1;

    // Wait for completion of the write operation
    @(negedge clk);   
    valid_tx <= 1'b0; 
  endtask

  task read_from_sram(
    input logic [14:0] address,
    output logic [255:0] data_out
  );
    @(negedge clk);
    addr <= address;
    we   <= 1'b0;    
    valid_tx <= 1'b1;

    // Wait for the read data to become valid
    @(posedge clk);
    data_out = dout;  // Capture the output data
    valid_tx <= 1'b0; 
  endtask

endinterface
