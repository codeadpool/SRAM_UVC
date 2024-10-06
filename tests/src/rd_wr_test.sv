`ifndef RD_WR_TEST
`define RD_WR_TEST
class rd_wr_test extends sram_basic_test;
  
  `uvm_component_utils(rd_wr_test)

  function new(string name = "rd_wr_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    rd_wr_seq seq = rd_wr_seq::type_id::create("seq", this);
    seq.start(env.agent.m_seqr0);
  endfunction : build_phase
  
endclass
`endif 
