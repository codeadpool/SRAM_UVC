`ifndef RD_WR_SEQ
`define RD_WR_SEQ
class rd_wr_seq extends sram_basic_seq;
  
  `uvm_object_utils(rd_wr_seq)

  function new(string name = "rd_wr_seq");
    super.new(name);
  endfunction

  virtual task body();
    req = sram_packet::type_id::create("req", this);
    assert(req.randomize() with { req.we_in == 1 }) else begin
      `uvm_fatal("RANDOMIZATION FAILURE", "Failed to randomize req for rd_wr_seq")
    end
    `uvm_do(req)
    `uvm_do_with(req, {req.we_in == 0;})
  endtask
  
endclass
`endif 
