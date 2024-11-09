`ifndef SRAM_MONITOR 
`define SRAM_MONITOR

// typedef enum {COV_ENABLE, COV_DISABLE} cover_t;

class sram_tx_monitor extends uvm_monitor;
  
  //collected data handle
  sram_packet write_pkt;
  sram_packet read_pkt;

  virtual sram_if vif;
  int num_pkt_cltd;
  //cover_t coverage_toggle = COV_ENABLE;

  // uvm_analysis_port is used to broadcast the collected packet to others.
  uvm_analysis_port #(sram_packet) ap; 

  `uvm_component_utils_begin(sram_tx_monitor)
    `uvm_field_int(num_pkt_cltd, UVM_ALL_ON)
    //`uvm_field_enum(cover_t, coverage_toggle, UVM_ALL_ON)
  `uvm_component_utils_end  

  /*
  covergroup cg_cltd_pkts#(
    parameter int ADDR_WIDTH = 10,
    parameter int DATA_WIDTH = 8
  );
    option.instance = 1;
    option.goal = 100;

    // Coverpoint for address signal
    coverpoint addr {
      bins addr_bins[] = { [0:(1<<ADDR_WIDTH)-1] };
      bins addr_low    = { [0:(1<<(ADDR_WIDTH-1))-1] };
      bins addr_high   = { [(1<<(ADDR_WIDTH-1)):(1<<ADDR_WIDTH)-1] };
      bins addr_edge   = { 0, (1<<ADDR_WIDTH)-1 };
    }
    
    // Coverpoint for data signal
    coverpoint data {
      bins data_bins[] = { [0:(1<<DATA_WIDTH)-1] };
      bins data_low    = { [0:(1<<(DATA_WIDTH-1))-1] };
      bins data_high   = { [(1<<(DATA_WIDTH-1)):(1<<DATA_WIDTH)-1] };
      bins data_edge   = { 0, (1<<DATA_WIDTH)-1 };
    }
    
    // Coverpoint for write enable signal
    coverpoint wen {
      bins wen_bins[] = { 0, 1 };
      bins wen_enable  = { 1 };
      bins wen_disable = { 0 };
    }
    
    // Cross coverage for address and data
    cross addr, data {
      bins addr_data_cross[] = { addr_bins, data_bins };
    }
    
    // Cross coverage for address and write enable
    cross addr, wen {
      bins addr_wen_cross[] = { addr_bins, wen_bins };
    }
    
    // Cross coverage for data and write enable
    cross data, wen {
      bins data_wen_cross[] = { data_bins, wen_bins };
    }
  endgroup
  */
  function new (string name, uvm_component parent);
    super.new(name, parent);
    
    ap = new("ap", this);
    // we are using normal new to create this rather than create, cause 
    // TLM Connection objects are tightly associated with specifically
    // named communication methods. 

    // using new() ties specific communication methods to the like write()
    // directly to the object, reducing the risk of replacing it with an
    // incompatible type 
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(virtual sram_if)::get(this, get_full_name(), "vif", vif))
     `uvm_error("NOVIF", {"virtual interface must be set for:", get_full_name(); ".vif"}, UVM_LOW)
    /*
    if(coverage_toggle == COV_ENABLE) begin
     `uvm_info(get_type_name(), "SRAM MONITOR COVERAGE CREATED", UVM_LOW)
      cg_cltd_pkts = new();
      cg_cltd_pkts.set_inst_name({get_full_name(), ".monitor_pkt"});
    end
    */
  endfunction : build_phase

  virtual task run_phase(uvm_phase phase);
    forever begin
      @(posedge vif.clk) 
      if(vif.wen)begin
        //creating a write packet
        write_pkt = sram_packet::type_id::create("write_pkt");
        write_pkt.addr = vif.addr;
        write_pkt.din = vif.din;
        //sending the packet to the scoreboard
        ap.write(write_pkt);
      end
      if(!vif.wen)begin
        //creating a read packet
        read_pkt = sram_packet::type_id::create("read_pkt");
        read_pkt. addr = vif.addr;
        read_pkt. dout = vif.dout;
        //sending the packet to the scoreboard
        ap.write(read_pkt);
      end
    end
  endtask : run_phase

  virtual function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Report: SRAM Monitor collected %d packets", num_pkt_cltd), UVM_LOW)
  endfunction: report_phase
endclass
`endif

