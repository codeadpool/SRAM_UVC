`ifndef SRAM_INTERFACE_SVH
`define SRAM_INTERFACE_SVH

interface sram_if(
    input logic clk,
    input logic rstn
);
    localparam ADDR_WIDTH = 4;
    localparam DATA_WIDTH = 8;
    
    // Signals to SRAM
    logic [ADDR_WIDTH - 1:0] addr;
    logic [DATA_WIDTH - 1:0] din;
    logic [DATA_WIDTH - 1:0] dout;
    logic we_n;
  
    //-----------------------------------------
    // Clocking Blocks
    //-----------------------------------------
    clocking driver_cb @(posedge clk);
        default input #1step output #2ns; 
        output addr, din, we_n;           
        input dout;                       
    endclocking

    clocking monitor_cb @(posedge clk);
        input addr, din, we_n, dout;      
    endclocking

    //-----------------------------------------
    // Modports
    //-----------------------------------------
    modport DRIVER (
        clocking driver_cb,
        input clk,
        input rstn,
        import drive_reset_task, drive_write_task, drive_read_task
    );

    modport MONITOR (
        clocking monitor_cb,
        input clk,
        input rstn
    );

    //-----------------------------------------
    // Reset Initialization Task
    //-----------------------------------------
    task automatic drive_reset_task();
        wait(rstn == 'b0);                  
        din <= 'z;
        addr <= 'z;
        we_n <= 1'b1;                    // Default to read state
        wait(rstn == 'b1);                   
        @(driver_cb);                      // Align to clkEdge
    endtask

    task drive_write_task(
        input logic [ADDR_WIDTH - 1:0] address,
        input logic [DATA_WIDTH - 1:0] data
    );
        driver_cb.addr <= address; // Drive address
        driver_cb.din <= data;    // Drive data
        
        @(driver_cb);
        driver_cb.we_n <= 1'b0;    // Assert we_n (active-low for WRITE)
        
        @(driver_cb);   		   
        driver_cb.we_n <= 1'bx;    // Deassert we_n
    endtask

    task drive_read_task(
        input logic [ADDR_WIDTH - 1:0] address,
        output logic [DATA_WIDTH - 1:0] data
    );
        driver_cb.addr <= address; // Drive address
        
        @(driver_cb);
        driver_cb.we_n <= 1'b1;    // Assert we_n (active-high for READ)
        
        @(driver_cb);   		   // Wait for 2 clock cycles (adjust as needed)
        driver_cb.we_n <= 'bx;
        data <= driver_cb.dout;    // mon_cb.dout or driver_cb.dout later think
    endtask
    
    // Signal stability during write operations
    // property write_signal_stability;
    //     @(posedge clk) 
    //     !we_n |-> $stable(addr) and $stable(din);
    // endproperty
    // assert property (write_signal_stability) else
    //     $error("Write signal instability: Addr=%h Din=%h", addr, din);

    // Read/write protocol enforcement
    // sequence valid_write;
    //     !we_n ##[1:max_write_cycles] we_n;
    // endsequence

    // sequence valid_read;
    //     we_n ##[1:max_read_cycles] !we_n;
    // endsequence

    // assert property (@(posedge clk) !we_n |-> valid_write) else
    //     $error("Write protocol violation");

    // assert property (@(posedge clk) we_n |-> valid_read) else
    //     $error("Read protocol violation");

    // Data hold time after write
    // assert property (@(negedge clk) 
    //     !we_n |=> ##[0:hold_cycles] $stable(din)) else
    //     $error("Data hold time violation after write");

    // Address setup time
    // assert property (@(posedge clk) 
    //     $changed(addr) |-> $stable(addr) throughout !we_n [*1:$]) else
    //     $error("Address change during active write operation");

endinterface

`endif
