//==============================================
// Base Test
//==============================================

class sram_base_test extends uvm_test;
  `uvm_component_utils(sram_base_test)
  sram_env env;

  function new(string name = "sram_base_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = sram_env::type_id::create("env", this);
  endfunction : build_phase

  function void end_of_elaboration_phase(uvm_phase phase);
    uvm_root::get().print_topology();
  endfunction : end_of_elaboration_phase

  function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), {"start of simulation for ", get_full_name()}, UVM_MEDIUM);
  endfunction : start_of_simulation_phase

  virtual task run_phase(uvm_phase phase);
    uvm_objection obj = phase.get_objection();
    obj.set_drain_time(this, 2000ns);
  endtask : run_phase
endclass


//==============================================
// Read-Write Test
//==============================================

class sram_rand_seq_test extends sram_base_test;
  `uvm_component_utils(sram_rand_seq_test)

  function new(string name = "sram_rand_seq_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  /*virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_object_wrapper)::set(this, "env.agent.m_seqr.main_phase",
                                             "default_sequence", rand_rd_wr_seq::get_type());
  endfunction*/

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    begin
      sram_random_seq seq;
      seq = sram_random_seq::type_id::create("seq");
      `uvm_info("", $sformatf("Inside test"), UVM_MEDIUM)
      seq.start(env.agent.m_seqr);
    end
    phase.get_objection().set_drain_time(this, 2000ns);
    phase.drop_objection(this);
  endtask
endclass


//==============================================
// Edge Case Test
//==============================================

class sram_edge_case_test extends sram_base_test;
  `uvm_component_utils(sram_edge_case_test)

  function new(string name = "sram_edge_case_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  /*virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_object_wrapper)::set(this, "env.agent.m_seqr.main_phase",
                                             "default_sequence", edge_case_seq::get_type());
  endfunction*/

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    begin
      sram_edge_cases_seq seq;
      seq = sram_edge_cases_seq::type_id::create("seq");
      `uvm_info("", $sformatf("Inside test"), UVM_MEDIUM)
      seq.start(env.agent.m_seqr);
    end
    phase.get_objection().set_drain_time(this, 2000ns);
    phase.drop_objection(this);
  endtask
endclass


//==============================================
// Exhaustive Test
//==============================================

class sram_same_addr_test extends sram_base_test;
  `uvm_component_utils(sram_same_addr_test)

  function new(string name = "sram_same_addr_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  /*virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_object_wrapper)::set(this, "env.agent.m_seqr.main_phase",
                                             "default_sequence", exhaustive_seq::get_type());
  endfunction*/

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    begin
      sram_same_addr_seq seq;
      seq = sram_same_addr_seq::type_id::create("seq");
      `uvm_info("", $sformatf("Inside test"), UVM_MEDIUM)
      seq.start(env.agent.m_seqr);
    end
    phase.get_objection().set_drain_time(this, 2000ns);
    phase.drop_objection(this);
  endtask
endclass


//==============================================
// Stress Test
//==============================================

class sram_stress_test extends sram_base_test;
  `uvm_component_utils(sram_stress_test)

  function new(string name = "sram_stress_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  // virtual function void build_phase(uvm_phase phase);
  //   super.build_phase(phase);
  //   uvm_config_db#(uvm_object_wrapper)::set(this, "env.agent.m_seqr.main_phase", "default_sequence", stress_seq::get_type());
  // endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    begin
      sram_stress_seq seq;
      seq = sram_stress_seq::type_id::create("seq");
      `uvm_info("", $sformatf("Inside test"), UVM_MEDIUM)
      seq.start(env.agent.m_seqr);
    end
    phase.get_objection().set_drain_time(this, 2000ns);
    phase.drop_objection(this);
  endtask
endclass
