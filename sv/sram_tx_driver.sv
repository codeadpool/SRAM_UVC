class sram_tx_driver extends uvm_driver#(sram_packet);
  int num_sent; // int default to 0
  virtual interface sram_if vif;

  `uvm_object_utils_begin(sram_tx_driver)
    `uvm_field_int(num_sent, UVM_ALL_ON)
  `uvm_object_utils_end 

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void connect_phase (uvm_phase phase);
   if(!uvm_config_db#(virtual interface sram_if)::get(this, "", "vif", vif))
     // recheck the parameter for the config db
     `uvm_error("NOVIF", {"virtual interface has't setup for: ", get_full_name(), ".vif"})
  endfunction

  function void start_of_simulation_phase (uvm_phase phase);
    `uvm_info(get_type_name(), "{start of the simulation phase, get_full_name()}", UVM_HIGH)
  endfunction
  
  task run_phase(uvm_phase phase);
    fork
      reset_signals();
      get_and_drive();
    join
    // fork-join: runs parellely and all the processes has to complete
    // fork-join_any: any one processes has to be completed
    // fork-join_none: runs paralelly and doesn't wait for completion use
    // wait_fork for waiting for all the processes to be completed
  endtask

  task get_and_drive();
    @(posedge vif.reset);
    @(negedge vif.reset);

    `uvm_info(get_type_name(), "Reset dropped", UVM_MEDIUM);
    forever begin
      seq_item_port.get(req); 
      // req handle is provided by passing the sequence item as parameter to
      // the class
      `uvm_info(get_type_name(), $sformat("Sending Packet: \n%s", req.sprint()), UVM_HIGH)
      fork
        vif.send_to_dut(req.addr, req.din, req.wen, req.packet_delay);
        @(posedge vif.drv_start) begin_tr(req, "Driver_SRAM_Packet");
      join
      end_tr(req);
      num_sent++;

      seq_item_port.item_done();
    end
  endtask

  task reset_signals();
    forever vif.sram_reset();
  endtask

  function void report_phase (uvm_phase phase);
    `uvm_info(get_type_name(), $sformat("Report: SRAM_TX_DRIVER sent %d packets", num_sent), UVM_LOW)  
  endfunction
endclass
