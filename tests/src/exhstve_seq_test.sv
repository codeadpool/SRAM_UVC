`ifndef EXHSTVE_SEQ_TEST
`define EXHSTVE_SEQ_TEST
class exhstve_seq_test extends sram_basic_test;
  
  `uvm_component_utils(exhstve_seq_test)

  function new(string name = "exhstve_seq_test", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    uvm_config_wrapper::set(this, "env.agent.m_seqr0.run_phase", "default_sequence", n_pkt_seq::get_type());
    super.build_phase(phase);
  endfunction : build_phase
        
endclass
`endif
