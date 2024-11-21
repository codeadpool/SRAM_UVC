`ifndef SRAM_BASIC_SEQ
`define SRAM_BASIC_SEQ
class sram_basic_seq extends uvm_sequence #(sram_packet);
  
  `uvm_object_utils(sram_basic_seq)

  function new(string name = "sram_basic_seq");
    super.new(name);
  endfunction

  task pre_body();
    uvm_phase phase;
    phase = starting_phase;
    if (phase != null) begin
      phase.raise_objection(this, get_type_name());
      `uvm_info(get_type_name(), "raise objection", UVM_MEDIUM)
    end
  endtask

  task post_body();
    uvm_phase phase;
    phase = starting_phase;
    if (phase != null) begin
      phase.drop_objection(this, get_type_name());
      `uvm_info(get_type_name(), "drop objection", UVM_MEDIUM)
    end
  endtask
endclass
`endif
