`ifndef SRAM_COVERAGE_SVH
`define SRAM_COVERAGE_SVH

class sram_coverage#(type T=sram_packet) extends uvm_subscriber#(T);
  `uvm_component_param_utils(sram_coverage#(T))
  
  T t;

  covergroup cg;
    option.per_instance = 1;
    option.cross_auto_bin_max = 16; // Adjusted to a reasonable value

    // Address coverage (4-bit wide)
    addr_cp: coverpoint t.addr {
      bins min_addr   = { 4'h0 };
      bins max_addr   = { 4'hF };
      bins low_addr   = { [4'h1:4'h3] };
      bins mid_addr   = { [4'h4:4'hB] };
      bins high_addr  = { [4'hC:4'hE] };
    }

    // Data coverage (8-bit wide)
    din_cp: coverpoint t.din {
      bins all_zero   = { 8'h00 };
      bins all_one    = { 8'hFF };  // Max 8-bit value
      bins random_spread[] = { [8'h01:8'hFE] };  // Avoiding 0x00 and 0xFF
    }

    // Write Enable coverage (Assuming write = 0, read = 1)
    we_n_cp: coverpoint t.we_n {
      bins write_op   = { 1'b0 };
      bins read_op    = { 1'b1 };
    }

    // Cross coverage
    we_x_din: cross we_n_cp, din_cp;
    we_x_addr: cross we_n_cp, addr_cp;
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    cg = new();
  endfunction

  virtual function void write(T t);
    this.t = t;
    cg.sample();
  endfunction

  function void report_phase(uvm_phase phase);
    `uvm_info("COV_REPORT", 
      $sformatf("Total Coverage: %.2f%%\n Addr: %.2f%%\n Data: %.2f%%\n WE: %.2f%%\n Cross Addr/WE: %.2f%%\n Cross Data/WE: %.2f%%",
        cg.get_coverage(),
        cg.addr_cp.get_coverage(),
        cg.din_cp.get_coverage(),
        cg.we_n_cp.get_coverage(),
        cg.we_x_addr.get_coverage(),
        cg.we_x_din.get_coverage()), 
      UVM_MEDIUM)
  endfunction
endclass

`endif
