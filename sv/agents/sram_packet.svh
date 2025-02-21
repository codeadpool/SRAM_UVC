`ifndef SRAM_PACKET_SVH
`define SRAM_PACKET_SVH

class sram_packet extends uvm_sequence_item;
    typedef enum { 
        READ  = 0,
        WRITE = 1 
    } op_t;

    rand op_t                   op;        // Transaction operation
    rand logic [ADDR_WIDTH-1:0] addr;      // Memory address
    rand logic [DATA_WIDTH-1:0] din;       // Write data
    rand logic                  we_n;      // Derived from op (not randomized)
    logic [DATA_WIDTH-1:0]       dout;     // Read data
    time                         trans_time; // Transaction timestamp

    // ******************************
    // ** Constraints **
    // ******************************
    constraint valid_operation_c {
        op inside {READ, WRITE};
    }

    constraint addr_constraints {
        addr inside {[0:(2**ADDR_WIDTH)-1]}; 
    }

    constraint data_constraints {
        if(op == READ) {
            din == 0;  // Clear data bus during reads
        }
    }

    constraint operation_distribution {
        op dist { READ :/ 50, WRITE :/ 50 };
    }

    // ******************************
    // ** UVM Automation & Methods **
    // ******************************
    `uvm_object_param_utils_begin(sram_packet)
        `uvm_field_enum(op_t, op,       UVM_ALL_ON)
        `uvm_field_int(addr,            UVM_ALL_ON)
        `uvm_field_int(din,             UVM_ALL_ON)
        `uvm_field_int(we_n,            UVM_ALL_ON)
        `uvm_field_int(dout,            UVM_ALL_ON)
        `uvm_field_int(trans_time,      UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "sram_packet");
        super.new(name);
    endfunction

    // ******************************
    // ** Post-Randomization **
    // ******************************
    function void post_randomize();
        we_n = (op == WRITE) ? 1'b0 : 1'b1;
    endfunction

    // ******************************
    // ** API Methods **
    // ******************************
    function void do_write(
        input logic [ADDR_WIDTH-1:0] address,
        input logic [DATA_WIDTH-1:0] data
    );
        if (address >= (2 ** ADDR_WIDTH)) begin
            `uvm_error("SRAM_PKT", $sformatf("Invalid write address: 0x%0h", address))
        end
        op   = WRITE;
        addr = address;
        din  = data;
        we_n = 1'b0;
    endfunction

    function void do_read(
        input logic [ADDR_WIDTH-1:0] address
    );
        if (address >= (2 ** ADDR_WIDTH)) begin
            `uvm_error("SRAM_PKT", $sformatf("Invalid read address: 0x%0h", address))
        end
        op   = READ;
        addr = address;
        din  = '0;
        we_n = 1'b1;
    endfunction

    // ******************************
    // ** Standard UVM Methods **
    // ******************************
    virtual function string convert2string();
        return $sformatf("%s @ %0t | OP: %s, ADDR: 0x%0h, DIN: 0x%0h, DOUT: 0x%0h",
            get_type_name(), trans_time, op.name(), addr, din, dout);
    endfunction

    virtual function void do_copy(uvm_object rhs);
        sram_packet rhs_pkt;
        if(!$cast(rhs_pkt, rhs)) begin
            `uvm_fatal("DO_COPY", "Type mismatch")
        end
        super.do_copy(rhs);
        op         = rhs_pkt.op;
        addr       = rhs_pkt.addr;
        din        = rhs_pkt.din;
        dout       = rhs_pkt.dout;
        trans_time = rhs_pkt.trans_time;
        we_n       = rhs_pkt.we_n;
    endfunction

    virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        sram_packet rhs_pkt;
        if(!$cast(rhs_pkt, rhs)) return 0;
        return (
            super.do_compare(rhs, comparer) &&
            (op         == rhs_pkt.op)      &&
            (addr       == rhs_pkt.addr)    &&
            (din        == rhs_pkt.din)     &&
            (dout       == rhs_pkt.dout)    &&
            (trans_time == rhs_pkt.trans_time)
        );
    endfunction

    virtual function void do_pack(uvm_packer packer);
        super.do_pack(packer);
        packer.pack_field_int(op,     $bits(op));
        packer.pack_field_int(addr,   ADDR_WIDTH);
        packer.pack_field_int(din,    DATA_WIDTH);
        packer.pack_field_int(dout,   DATA_WIDTH);
        packer.pack_time(trans_time);
    endfunction

    virtual function void do_unpack(uvm_packer packer);
        super.do_unpack(packer);
        op          = op_t'(packer.unpack_field_int($bits(op)));
        addr        = packer.unpack_field_int(ADDR_WIDTH);
        din         = packer.unpack_field_int(DATA_WIDTH);
        dout        = packer.unpack_field_int(DATA_WIDTH);
        trans_time  = packer.unpack_time();
        we_n        = (op == WRITE) ? 1'b0 : 1'b1;
    endfunction
endclass : sram_packet

`endif
