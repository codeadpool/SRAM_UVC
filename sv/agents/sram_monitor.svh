`ifndef SRAM_MONITOR_SVH
`define SRAM_MONITOR_SVH

class sram_monitor extends uvm_monitor;
    `uvm_component_utils(sram_monitor)

    virtual sram_if base_vif;
    virtual sram_if.MONITOR vif;
    sram_agent_cfg cfg;

    uvm_analysis_port #(sram_packet) mon_ap;

    function new(string name, uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual sram_if)::get(this, "", "vif", base_vif))
            `uvm_fatal(get_type_name(), "Failed to retrieve Interface")
        vif = base_vif.MONITOR;

        if (!uvm_config_db #(sram_agent_cfg)::get(this, "", "agent_cfg", cfg))
            `uvm_fatal(get_type_name(), "Failed to retrieve configuration object")

        mon_ap = new("mon_ap", this);
    endfunction

    task run_phase(uvm_phase phase);
        fork
            // monitor_reset();
            collect_transactions();
        join
    endtask

    task collect_transactions();
        sram_packet trans;
        // wait (vif.rstn === 'b1);
        // @(vif.monitor_cb);
        
        forever begin
            @(vif.monitor_cb iff vif.rstn === 1'b1 && vif.monitor_cb.we_n !== 'x);
            // && vif.monitor_cb.we_n !== 'x
            trans = sram_packet::type_id::create("trans");
            
            trans.addr = vif.monitor_cb.addr;
            trans.op = (vif.monitor_cb.we_n === 1'b0) ? trans.WRITE : trans.READ;

            if (trans.op == trans.WRITE) begin
                trans.din = vif.monitor_cb.din;
                trans.we_n = 'b0;
                trans.dout = 'x;
            end
            else if (trans.op == trans.READ) begin
                trans.din = 'x;
                trans.we_n = 'b1;
                trans.dout = vif.monitor_cb.dout;
            end

            trans.trans_time = $time;
            // `uvm_info("MON/XFR", $sformatf("Captured:\n%s", trans.sprint()), UVM_MEDIUM)
            mon_ap.write(trans);
        end
    endtask

    // task collect_transactions();
    //     sram_packet trans;
    //     bit write_in_progress = 0;

    //     forever begin
    //         // Wait for valid transaction start (reset inactive, WE stable)
    //         @(vif.monitor_cb iff vif.rstn === 1'b1 && vif.monitor_cb.we_n !== 'x);

    //         if (vif.monitor_cb.we_n === 1'b0 && !write_in_progress) begin
    //             // Start of WRITE transaction
    //             write_in_progress = 1;
    //             trans = sram_packet::type_id::create("trans");
    //             trans.op = trans.WRITE;
    //             trans.addr = vif.monitor_cb.addr;
    //             trans.din = vif.monitor_cb.din;
    //             trans.we_n = 0;
    //             trans.dout = 'x;
    //             trans.trans_time = $time;
    //             `uvm_info("MON/XFR", $sformatf("Captured WRITE:\n%s", trans.sprint()), UVM_MEDIUM)
    //             mon_ap.write(trans);
    //         end
    //         else if (vif.monitor_cb.we_n === 1'b1) begin
    //             // READ transaction: Capture address now, data next cycle
    //             trans = sram_packet::type_id::create("trans");
    //             trans.op = trans.READ;
    //             trans.addr = vif.monitor_cb.addr;
    //             trans.we_n = 1;
    //             trans.din = 'x;
    //             // Wait one cycle for dout to stabilize
    //             @(vif.monitor_cb);
    //             trans.dout = vif.monitor_cb.dout;
    //             trans.trans_time = $time;
    //             `uvm_info("MON/XFR", $sformatf("Captured READ:\n%s", trans.sprint()), UVM_MEDIUM)
    //             mon_ap.write(trans);
    //         end

    //         // Reset write tracking if WE deasserted
    //         if (vif.monitor_cb.we_n === 1'b1) begin
    //             write_in_progress = 0;
    //         end
    //     end
    // endtask

    // task monitor_reset();
    //     forever begin
    //         @(negedge vif.rstn);
    //         `uvm_info(get_type_name(), "Reset detected - pausing monitor", UVM_MEDIUM)
    //     end
    // endtask
endclass : sram_monitor

`endif
