`ifndef SRAM_SCOREBOARD
`define SRAM_SCOREBOARD

class sram_scoreboard extends uvm_scoreboard;
  uvm_analysis_imp #(sram_packet, sram_scoreboard) ap;

  logic [14:0] ref_arr [255:0];
  bit error;

  `uvm_component_utils(sram_scoreboard)

  function new(string name = "sram_scoreboard", uvm_component parent);
    super.new(name, parent);
    ap = new("ap",this);
  endfunction
  
  virtual function write(sram_packet packet);
    if(packet.wen)begin
      ref_arr[packet.addr] = packet.din;
      `uvm_info(get_type_name(), $sformat("write to the ref_arr: ADDR: %h, DATA: %h", packet.addr, packet.din), UVM_MEDIUM)
    end else if(!packet.wen)begin
      bit [31:0] exptd_data = ref_arr[packet.addr];
      `uvm_info(get_type_name(), $sformat("read from ref_arr: ADDR = %h, DATA = %h, EXPTD_DATA = %h", packet.addr, packet.din, exptd_data), UVM_MEDIUM)

      if(packet.din !== exptd_data)begin
        `uvm_fatal(get_type_name(), $sformat("DATA-MISMATCH at ADDR = %h, READ = %h, EXPTD_DATA = %h", packet.addr, packet.din, exptd_data))
      end else begin
        // we dont need to say every matched lets see
      end
    end
  endfunction

  virtual function void report_phase(uvm_phase phase);
    
  endfunction: report_phase
endclass
`endif
