`ifndef SRAM_MEMORY_ARRAY
`define SRAM_MEMORY_ARRAY

module sram #(
    parameter DATA_WIDTH = 8,       
    parameter ADDR_WIDTH = 4
) (
    input  logic                  clk,     // Clock signal
    input  logic                  rstn,    // Active-low reset (resets output register)
    input  logic                  we_n,    // Active-low write enable
    
    input  logic [ADDR_WIDTH-1:0] addr,    // Address input
    input  logic [DATA_WIDTH-1:0] din,     // Data input
    output logic [DATA_WIDTH-1:0] dout     // Data output (registered)
);

    localparam DEPTH = 2**ADDR_WIDTH;
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    always_ff @(posedge clk) begin
        if (!we_n) begin
            mem[addr] <= din;
        end
    end

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            dout <= '0;           
        end else begin
            dout <= mem[addr];
        end
    end
endmodule

`endif
