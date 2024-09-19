`ifndef SRAM_SCOREBOARD
`define SRAM_SCOREBOARD

class sram_scoreboard extends uvm_scoreboard;
  
  `uvm_component_utils(sram_scoreboard)

  uvm_analysis_export#(sram_packet) mon2sb_export, rm2sb_export;
  uvm_tlm_analysis_fifo #(sram_packet) mon2sb_export_fifo, rm2sb_export_fifo;

  sram_packet exp_pkt, act_pkt;
  sram_packet exp_pkt_fifo, act_pkt_fifo;
  bit error;

  function new(string name = "sram_scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    mon2sb_export = new("mon2sb_export", this);
    rm2sb_export  = new("rm2sb_export" , this);
    mon2sb_export_fifo = new("mon2sb_export_fifo", this);
    rm2sb_export_fifo  = new("rm2sb_export_fifo",  this);
  endfunction : build_phase 
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    mon2sb_export.connect(mon2sb_export_fifo.analysis_export);
    rm2sb_export.connect(rm2sb_export_fifo.analysis_export);
  endfunction : connect_phase

  virtual task run_phase(uvm_phase phase);
    
  endtask : run_phase

  virtual function void report_phase(uvm_phase phase);
    
  endfunction: report_phase
endclass
`endif
