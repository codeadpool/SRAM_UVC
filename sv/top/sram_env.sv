`ifndef SRAM_ENV 
`define SRAM_ENV
class sram_env extends uvm_env;

  sram_tx_agent agent;
  sram_coverage cov;
  sram_scoreboard sb;
    
  `uvm_component_utils(sram_env)

  function new(string name = "sram_env", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    agent = sram_tx_agent::type_id::create("agent", this);
    cov   = sram_coverage::type_id::create("cov"  , this);
    sb    = sram_scoreboard::type_id::create("sb" , this);
  endfunction : build_phase

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // ports are always connected to implementations
    agent.m_mon0.ap.connect(sb.ap);
    //coverage is extended by subscriber which has implied analysis_export 
    agent.m_mon0.ap.connect(cov.analysis_export);
  endfunction : connect_phase
endclass
`endif
