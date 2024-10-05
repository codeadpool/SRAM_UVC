module sram #(
    parameter DATA_WIDTH = 8,     // Width of the data bus
    parameter ADDR_WIDTH = 4,     // Width of the address bus
    parameter DEPTH = 2**ADDR_WIDTH // Depth of the SRAM (2^ADDR_WIDTH)
) (
    input  logic                  clk,     // Clock signal
    input  logic                  we,      // Write enable signal
    input  logic [ADDR_WIDTH-1:0] addr,   // Address input
    input  logic [DATA_WIDTH-1:0] din,    // Data input
    output logic [DATA_WIDTH-1:0] dout    // Data output
);

    // Memory array
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Write operation
    always_ff @(posedge clk) begin
        if (we) begin
            mem[addr] <= din; // Write data to specified address
        end
    end

    // Read operation
    always_ff @(posedge clk) begin
        dout <= mem[addr]; // Read data from specified address
    end

endmodule
