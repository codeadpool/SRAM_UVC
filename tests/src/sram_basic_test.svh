`ifndef SRAM_BASIC_TEST 
`define SRAM_BASIC_TEST
class sram_basic_test extends uvm_test;
  
  `uvm_component_utils(sram_basic_test)
  sram_env env;

  function new(string name = "sram_basic_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = sram_env::type_id::create("env", this);
  endfunction : build_phase

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();  
  endfunction : end_of_elaboration_phase  

  virtual function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), {"Start of the simulation for", get_full_name()}, UVM_HIGH)
  endfunction : start_of_simulation_phase

  virtual task run_phase(uvm_phase phase);
    // uvm_objection is a class and get_objection gets us the access to the
    // objection mechanism 
    uvm_objection obj = phase.get_objection();
    obj.set_drain_time(this, 200ns);
  endtask : run_phase

  virtual function void check_phase(uvm_phase phase);
    check_config_phase();  
  endfunction: check_phase
endclass
`endif
