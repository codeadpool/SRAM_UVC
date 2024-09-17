class sram_env extends uvm_env;
  
  `uvm_component_utils(sram_env)

  function new(string name = "sram_env", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
  endfunction : build_phase 
endclass
