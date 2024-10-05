`ifndef N_PKT_SEQ
`define N_PKT_SEQ
class n_pkt_seq extends sram_basic_seq;
  
  `uvm_object_utils(n_pkt_seq);

  function new(string name = "n_pkt_seq");
    super.new(name);
  endfunction
  
  virtual task body();
    `uvm_info(get_type_name(), "Executing N_PKT_SEQ", UVM_MEDIUM)
    repeat (5) begin
      `uvm_do(req)
    end 
  endtask
  
endclass
`endif

