`ifndef EDGE_SEQ_TEST
`define EDGE_SEQ_TEST
class edge_seq_test extends sram_basic_test;
  
  `uvm_component_utils(edge_seq_test)

  function new(string name = "edge_seq_test", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    edge_case_seq seq = edge_seq_test::type_id::create("seq", this);
    seq.start(env.agent.m_seqr0);
  endfunction : build_phase
endclass
`endif
