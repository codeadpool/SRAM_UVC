class sram_tx_driver extends uvm_driver#(sram_packet);

  `uvm_object_utils_begin(sram_tx_driver)
    `uvm_field_int(num_sent, UVM_ALL_ON)
  `uvm_object_utils_end 

  int num_sent; // int default to 0
  virtual interface sram_if vif;

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void connect_phase (uvm_phase phase);
    if (!uvm_config_db#(virtual interface sram_if)::get(this, "", "vif", vif)) begin
      `uvm_error("NOVIF", $sformatf("Virtual interface hasn't been set up for: %s.vif", get_full_name()))
    end
  endfunction

  function void start_of_simulation_phase (uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Start of the simulation phase: %s", get_full_name()), UVM_HIGH)
  endfunction

  task run_phase(uvm_phase phase);
    fork
      reset_signals();
      get_and_drive();
    join
  endtask

  task get_and_drive();
    @(negedge vif.rstn);
    @(posedge vif.rstn);
    `uvm_info(get_type_name(), "Reset dropped", UVM_MEDIUM);

    forever begin
      seq_item_port.get(req); 
      `uvm_info(get_type_name(), $sformatf("Sending Packet:\n%s", req.sprint()), UVM_HIGH)

      fork
        vif.send_to_dut(req.addr, req.din, req.wen, req.packet_delay);
        @(posedge vif.tx_valid); 
        begin_tr(req, "Driver_SRAM_Packet");
      join

      end_tr(req);
      num_sent++;

      seq_item_port.item_done();
    end
  endtask

  task reset_signals();
    forever begin
      vif.sram_reset();
      @(posedge vif.clk); 
    end
  endtask

  function void report_phase (uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Report: SRAM_TX_DRIVER sent %d packets", num_sent), UVM_LOW)  
  endfunction
endclass
