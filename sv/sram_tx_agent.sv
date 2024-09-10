class sram_tx_agent extends uvm_agent;
  // uvm_active_passive_enum is_active = UVM_PASSIVE;
  // by default this is passive;

  `uvm_component_utils_begin(sram_tx_agent)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
  `uvm_component_utils_end

  sram_tx_monitor        m_mon0;
  sram_tx_driver         m_drv0;
  sram_tx_sequencer     m_seqr0;
  sram_tx_agent_cnfg m_agnt_cfg;

  function new(string name = "sram_tx_agent", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_mon0 = sram_tx_monitor::type_id::create("m_mon0",this); 
    if(is_active == UVM_ACTIVE) begin
      m_seqr0 = sram_tx_sequencer::type_id::create("m_seqr0", this);
      m_drv0  = sram_tx_driver::type_id::create("m_drv0", this);
    end
  endfunction : build_phase

  virtual function void connect_phase(uvm_phase phase);
    if(is_active == UVM_ACTIVE) begin
      m_drv0.seq_item_port.connect(m_seqr0.item_export);
    end 
  endfunction : connect_phase

  virtual function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_full_name(), {"Start of the simulation for", get_full_name()}, UVM_HIGH)
  endfunction : start_of_simulation_phase

  function void assign_vi (virtual interface sram_if vif);
    m_mon0.vif = vif;
    if(is_active == UVM_ACTIVE)
      m_drv0.vif = vif;
  endfunction      

endclass
