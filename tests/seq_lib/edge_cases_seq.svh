`ifndef EDGE_CASES_SEQ
`define EDGE_CASES_SEQ
class edge_cases_seq extends sram_basic_seq;

  `uvm_object_utils(edge_cases_seq)
  rand bit [31:0] num_iterations;

  function new(string name = "edge_cases_seq");
    super.new(name);
    num_iterations = 10;
  endfunction
  
  virtual task body();
    `uvm_info(get_type_name(), "Executing EDGE_CASES_SEQ", UVM_MEDIUM)

    for (int i = 0; i < num_iterations; i++) begin
      assert(req.randomize() with {
        req.addr == 14'b0 or req.addr == 14'h3FFF or 
        req.addr == 14'h1FFF or req.addr == 14'h0FFF or 
        req.addr == 14'h7FFF or req.addr == 14'hFFFF;
        req.din == $urandom_range(0, 255); // Random data for write
        req.we_n == (i % 2); // Alternate between write and read
      }) else begin
        `uvm_fatal("RANDOMIZATION_FAILURE", "Failed to randomize req for edge cases")
      end

      `uvm_info(get_type_name(), $sformatf("Randomized address: %h, we_n: %b, din: %h", req.addr, req.we_n, req.din), UVM_MEDIUM)
      `uvm_do(req)
    end
  endtask
endclass
`endif
