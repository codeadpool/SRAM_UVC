`ifndef SRAM_TX_DRIVER
`define SRAM_TX_DRIVER

class sram_tx_driver extends uvm_driver#(sram_packet);
  int num_sent;
  virtual interface sram_if vif;

  `uvm_object_utils_begin(sram_tx_driver)
    `uvm_field_int(num_sent, UVM_ALL_ON)
  `uvm_object_utils_end 

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // checking the interface in build phase is common practice
  // not sure but may be because of we get early detection and 
  // reduces the time wasted for .....
  // build phase comes before the connect phase, so we wont waste creating 
  function void build_phase (uvm_phase phase);
    if (!uvm_config_db#(virtual sram_if)::get(this, "", "vif", vif)) begin
      `uvm_error("NOVIF", $sformatf("Virtual interface hasn't been set up for: %s.vif", get_full_name()))
    end
  endfunction

  function void start_of_simulation_phase (uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Start of the simulation phase: %s", get_full_name()), UVM_HIGH)
  endfunction

  virtual task run_phase(uvm_phase phase);
    fork
      reset_signals();
      get_and_drive();
    join
  endtask

  task get_and_drive();
    // wait(!vif.rstn);
    // wait(vif.rstn) or (timeout == 100);
    @(negedge vif.rstn);
    @(posedge vif.rstn);
    `uvm_info(get_type_name(), "Reset dropped", UVM_MEDIUM);

    forever begin
      @(posedge vif.clk);
      seq_item_port.get(req); 
      `uvm_info(get_type_name(), $sformatf("Sending Packet:\n%s", req.sprint()), UVM_HIGH)

      fork
        vif.send_to_dut(req.addr, req.din, req.wen, req.packet_delay);
        //recheck this tx_valid
        @(posedge vif.tx_valid); 
        begin_tr(req, "Driver_SRAM_Packet");
      join
      end_tr(req);
      num_sent++;

      seq_item_port.item_done();
    end
  endtask

  task reset_signals();
    begin
      vif.rstn = 'b0;
      @(posedge vif.clk);
      vif.sram_reset();
      @(posedge vif.clk);
    end
  endtask

  function void report_phase (uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Report: SRAM_TX_DRIVER sent %d packets", num_sent), UVM_LOW)  
  endfunction
endclass

`endif
