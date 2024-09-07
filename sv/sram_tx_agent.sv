class sram_tx_agent extends uvm_agent;
  uvm_active_passive_enum is_active = UMV_ACTIVE;
  
  `uvm_component_utils_begin(sram_tx_agent)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
  `uvm_component_utils_end

  sram_tx_monitor   monitor;
  sram_tx_sequencer sequencer;
  sram_tx_driver    driver;

  function new(string name = "sram_tx_agent", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    monitor = sram_tx_monitor::type_id::create("monitor",this); 
    if(is_active == UVM_ACTIVE) begin
      sequencer = sram_tx_sequencer::type_id::create("sequencer", this);
      driver    = sram_tx_driver::type_id::create("driver", this);
    end
  endfunction : build_phase

  virtual function void connect_phase(uvm_phase phase);
    if(is_active == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.item_export);
    end 
  endfunction : connect_phase

  virtual function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_full_name(), {"Start of the simulation for", get_full_name()}, UVM_HIGH)
  endfunction : start_of_simulation_phase

  function void assign_vi (virtual interface sram_if vif);
    monitor.vif = vif;
    if(is_active == UVM_ACTIVE)
      driver.vif = vif;
  endfunction      

endclass
