`ifndef SRAM_PACKET 
`define SRAM_PACKET

class sram_packet extends uvm_sequence_item;
  rand bit [14:0] addr;
  rand bit [255:0] din;
  rand  bit we_n;
  
  `uvm_object_utils_begin(sram_packet)
   `uvm_field_int(addr, UVM_ALL_ON)
   `uvm_field_int(din, UVM_ALL_ON)
   `uvm_field_bit(we_n, UVM_ALL_ON);
  `uvm_object_utils_end 

  function new (string name = "sram_packet");
    super.new(name);
  endfunction
  
  constraint data_bias_zero {
    data== 256'b0;
    }
  constraint data_bias_one {  
    data== 256'b1;
    }
  constraint data_bias {
    data inside {[256'b0, 256'b1]}; 
  }
  constraint data_bias_dist {
    data dist {256'b0:= 50, 256'b1:= 50};
  }

endclass
`endif
