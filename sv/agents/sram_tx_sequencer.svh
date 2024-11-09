`ifndef SRAM_SEQUENCER 
`define SRAM_SEQUENCER

class sram_tx_sequencer extends uvm_sequencer #(sram_packet);
  
  `uvm_component_utils(sram_tx_sequencer)

  function new(string name = "sram_tx_sequencer", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), {"Start of simulation phase for", get_full_name()}, UVM_HIGH) 
  endfunction : start_of_simulation_phase
  
endclass
`endif
