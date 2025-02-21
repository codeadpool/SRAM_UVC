`ifndef SRAM_DRIVER_SVH
`define SRAM_DRIVER_SVH

class sram_driver extends uvm_driver #(sram_packet);
    `uvm_component_utils(sram_driver)

    virtual sram_if base_vif;
    virtual sram_if.DRIVER vif;
    sram_agent_cfg cfg;

    uvm_analysis_port #(sram_packet) drv_ap;
    uvm_tlm_analysis_fifo #(sram_packet) txn_fifo;

    function new(string name, uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual sram_if)::get(this, "", "vif", base_vif))
            `uvm_fatal(get_type_name(), "Failed to retrieve Interface");
        vif = base_vif.DRIVER;

        if (!uvm_config_db #(sram_agent_cfg)::get(this, "", "agent_cfg", cfg))
            `uvm_fatal("CFG", "Failed to retrieve configuration object");

        txn_fifo = new("txn_fifo");
        drv_ap = new("drv_ap", this);
    endfunction

    task run_phase(uvm_phase phase);
        fork
            reset_handler();
            process_sequencer();
            process_pipeline();
        join
    endtask

    task reset_handler();
        forever begin
            @(negedge vif.rstn);
            `uvm_info(get_type_name(), "Reset asserted", UVM_MEDIUM);
            txn_fifo.flush();
            vif.drive_reset_task();

            @(posedge vif.rstn);
            `uvm_info(get_type_name(), "Reset deasserted", UVM_MEDIUM);
        end
    endtask

    task process_sequencer();
        forever begin
            seq_item_port.get_next_item(req);

            `uvm_info("DRV/SEQ", $sformatf("Transaction added to FIFO: Addr=0x%0h, Data=0x%0h, WE=%0b", req.addr, req.din, req.we_n), UVM_MEDIUM);

            void'(txn_fifo.try_put(req)); // Always succeeds

            drv_ap.write(req);
            seq_item_port.item_done();
        end
    endtask

    task process_pipeline();
        sram_packet trans;
        forever begin
            // Use non-blocking check for reset
            wait(vif.rstn === 1'b1);
            @(vif.driver_cb);

            // Process transactions continuously
            while (1) begin
                txn_fifo.get(trans);
                drive_transfer(trans);  // Assumes drive_transfer has flow control
            end
        end
    endtask

    task drive_transfer(sram_packet trans);
        logic [DATA_WIDTH - 1:0] rd_data; // Local declaration
        // `uvm_info("DRV/XFR", $sformatf("STARTED DRIVING:\n%s", trans.sprint()), UVM_MEDIUM)
        case (trans.op)
            trans.WRITE: begin
                vif.drive_write_task(trans.addr, trans.din);
            end
            trans.READ: begin
                vif.drive_read_task(trans.addr, rd_data);
                trans.dout = rd_data;
            end
            default: `uvm_error("DRV", "Invalid operation");
        endcase
        trans.trans_time = $time;
        `uvm_info("DRV/XFR", $sformatf("DRIVING ENDED AT %0t", $time), UVM_MEDIUM);
        // `uvm_info("DRV/XFR", $sformatf("Completed:\n%s", trans.sprint()), UVM_MEDIUM)
    endtask
endclass : sram_driver

`endif
