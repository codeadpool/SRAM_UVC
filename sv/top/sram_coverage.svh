`ifndef SRAM_COVERAGE 
`define SRAM_COVERAGE

class sram_coverage#(type T=sram_packet) extends uvm_subscriber#(T);

  `uvm_component_utils_begin(sram_tx_monitor)

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

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "SRAM MONITOR COVERAGE CREATED", UVM_LOW)

    cg_cltd_pkts = new();
    cg_cltd_pkts.set_inst_name({get_full_name(), ".monitor_pkt"});
  endfunction : build_phase
  
  function void write (T t);
    cg_cltd_pkts.sample(t);
  endfunction
  
`endif

