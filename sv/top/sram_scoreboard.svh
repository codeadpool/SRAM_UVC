`ifndef SRAM_SCOREBOARD_SVH
`define SRAM_SCOREBOARD_SVH

`uvm_analysis_imp_decl(_drv)
`uvm_analysis_imp_decl(_mon)

class sram_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(sram_scoreboard)

    uvm_analysis_imp_drv#(sram_packet, sram_scoreboard) drv_imp;
    uvm_analysis_imp_mon#(sram_packet, sram_scoreboard) mon_imp;

    sram_agent_cfg cfg;

    logic [DATA_WIDTH-1:0] shadow_mem [logic [ADDR_WIDTH-1:0]];

    typedef struct {
        logic [ADDR_WIDTH-1:0] addr;
        logic [DATA_WIDTH-1:0] data;
        time timestamp;
        int transaction_id;
    } expected_read_t;

    expected_read_t  exp;
    expected_read_t  expected_reads[$];

    sram_packet exp_pkt;
    sram_packet expected_writes[$];

    int unsigned total_writes = 0;
    int unsigned total_reads = 0;
    int unsigned data_mismatches = 0;
    int unsigned protocol_errors = 0;
    int unsigned timeout_errors = 0;
    int transaction_id = 0;

    sram_coverage#(sram_packet) cov;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        drv_imp = new("drv_imp", this);
        mon_imp = new("mon_imp", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(sram_agent_cfg)::get(this, "", "agent_cfg", cfg))
            `uvm_fatal("CFG", "Agent config not found in config_db!")

        cov = sram_coverage#(sram_packet)::type_id::create("cov", this);
    endfunction

    virtual function void write_drv(sram_packet pkt);
        sram_packet cloned_pkt;
        transaction_id++;

        case (pkt.op)
            sram_packet::WRITE: begin
                $cast(cloned_pkt, pkt.clone());
                expected_writes.push_back(cloned_pkt);
                shadow_mem[cloned_pkt.addr] = cloned_pkt.din;
                total_writes++;

                `uvm_info("SB/TRACK", $sformatf("WRITE[%0d] Queued | Addr:0x%0h Data:0x%0h @%0t",
                    transaction_id, cloned_pkt.addr, cloned_pkt.din, $time), UVM_MEDIUM)
            end

            sram_packet::READ: begin
                logic [DATA_WIDTH-1:0] data = shadow_mem.exists(pkt.addr) ? 
                                            shadow_mem[pkt.addr] : '0;
                expected_reads.push_back('{
                    addr: pkt.addr, 
                    data: data, 
                    timestamp: $time,
                    transaction_id: transaction_id
                });
                total_reads++;

                `uvm_info("SB/TRACK", $sformatf("READ[%0d] Expected | Addr:0x%0h @%0t",
                    transaction_id, pkt.addr, $time), UVM_MEDIUM)
            end

            default: `uvm_error("SB/DRV", "Invalid operation from driver")
        endcase
        cov.write(pkt);
    endfunction

    virtual function void write_mon(sram_packet pkt);
        `uvm_info("SB/MON", $sformatf("MON Received %s @%0t", pkt.convert2string(), $time), UVM_MEDIUM)

        case (pkt.op)
            sram_packet::READ:   handle_read(pkt);
            sram_packet::WRITE:  handle_write(pkt);
            default:             `uvm_error("SB/MON", "Invalid operation received")
        endcase

        check_protocol(pkt);
        cov.write(pkt);
    endfunction

    virtual function void handle_read(sram_packet pkt);
        if (expected_reads.size() == 0) begin
            `uvm_error("SB/UNEXP", $sformatf("Unexpected READ | Addr:0x%0h @%0t", pkt.addr, $time))
            return;
        end

        exp = expected_reads.pop_front();

        if (exp.addr != pkt.addr) begin
            `uvm_error("SB/ADDR", $sformatf("READ[%0d] Addr Mismatch | Exp:0x%0h Act:0x%0h @%0t",
                exp.transaction_id, exp.addr, pkt.addr, $time))
            return;
        end

        if (pkt.dout !== exp.data) begin
            data_mismatches++;
            `uvm_error("SB/DATA", $sformatf(
                "READ[%0d] Data Mismatch | Addr:0x%0h Exp:0x%0h Act:0x%0h @%0t",
                exp.transaction_id, exp.addr, exp.data, pkt.dout, $time))
        end
        else begin
            `uvm_info("SB/MATCH", $sformatf("READ[%0d] Verified | Addr:0x%0h Data:0x%0h @%0t",
                exp.transaction_id, pkt.addr, pkt.dout, $time), UVM_MEDIUM)
        end
    endfunction

    virtual function void handle_write(sram_packet pkt);
        if (expected_writes.size() == 0) begin
            `uvm_error("SB/UNEXP", $sformatf("Unexpected WRITE | Addr:0x%0h @%0t", pkt.addr, $time))
            return;
        end

        exp_pkt = expected_writes.pop_front();

        if (exp_pkt.addr !== pkt.addr || exp_pkt.din !== pkt.din) begin
            data_mismatches++;
            `uvm_error("SB/WRITE", $sformatf(
                "WRITE Mismatch | Exp Addr:0x%0h Data:0x%0h | Act Addr:0x%0h Data:0x%0h @%0t",
                exp_pkt.addr, exp_pkt.din, pkt.addr, pkt.din, $time))
        end
        else begin
            `uvm_info("SB/MATCH", $sformatf("WRITE Verified | Addr:0x%0h Data:0x%0h @%0t",
                pkt.addr, pkt.din, $time), UVM_MEDIUM)
        end
    endfunction

    virtual function void check_protocol(sram_packet pkt);
        if ($isunknown(pkt.we_n)) begin
            protocol_errors++;
            `uvm_error("SB/PROTO", $sformatf("X/Z detected on we_n @%0t", $time))
        end

        case (pkt.op)
            sram_packet::WRITE: begin
                if (pkt.we_n !== 0) begin
                    protocol_errors++;
                    `uvm_error("SB/PROTO", $sformatf("Write with we_n=%0b @%0t", pkt.we_n, $time))
                end
            end

            sram_packet::READ: begin
                if (pkt.we_n !== 1) begin
                    protocol_errors++;
                    `uvm_error("SB/PROTO", $sformatf("Read with we_n=%0b @%0t", pkt.we_n, $time))
                end
            end
        endcase
    endfunction

    virtual function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        `uvm_info("SB/STATUS", $sformatf(
            "Current Status @%0t\n  Pending Writes: %0d\n  Pending Reads: %0d\n  Data Mismatches: %0d",
            $time, expected_writes.size(), expected_reads.size(), data_mismatches), UVM_MEDIUM)
    endfunction

    virtual function void report_phase(uvm_phase phase);
        real coverage = cov.cg.get_coverage();
        string report = $sformatf(
            { "\nSRAM SCOREBOARD FINAL REPORT",
              "\n==============================================",
              "\n  Transactions Tested:  %0d (W: %0d, R: %0d)",
              "\n  Data Mismatches:      %0d",
              "\n  Protocol Violations:   %0d",
              "\n  Remaining Expectations: %0d (W: %0d, R: %0d)",
              "\n  Functional Coverage:   %.2f%%",
              "\n==============================================\n"},
            total_writes + total_reads, total_writes, total_reads,
            data_mismatches, protocol_errors,
            expected_writes.size() + expected_reads.size(),
            expected_writes.size(), expected_reads.size(),
            coverage);

        if (data_mismatches > 0 || protocol_errors > 0)
            `uvm_error("SB/REPORT", "Validation failures detected")
        else
            `uvm_info("SB/REPORT", "All transactions validated successfully", UVM_NONE)

        `uvm_info("SB/REPORT", report, UVM_LOW)
    endfunction
endclass : sram_scoreboard

`endif
