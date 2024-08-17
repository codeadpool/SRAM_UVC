typedef enum {COV_ENABLE, COV_DISABLE} cover_t;
class sram_tx_monitor extends uvm_monitor;
  sram_packet pkt;
  virtual sram_if vif;
  int num_pkt_cltd;

  uvm_analysis_port #(sram_packet) mon_analysis_port; 
  // uvm_analysis_port is used to broadcast the collected packet to others.
  cover_t coverage_toggle = COV_ENABLE;

  `uvm_component_utils_begin(sram_tx_monitor)
    `uvm_field_int(num_pkt_cltd, UVM_ALL_ON)
    `uvm_field_enum(cover_t, coverage_toggle, UVM_ALL_ON)
  `uvm_component_utils_end  
  
  covergroup cg_cltd_pkts;
    option.per_instance = 1;
    // if not set or set to 0, coverage data is aggregated across instncs
    coverpoint pkt.addr {
      bins addr_bins[] = {[0:15'h7FFF]};
    } 
    coverpoint data {
      // Bins for specific patterns and ranges of data
      bins small_values[] = [0:7];             // Very small values
      bins medium_values[] = [8:15];           // Small values
      bins larger_values[] = [16:31];          // Larger values
      bins even_larger_values[] = [32:63];     // Even larger values
      bins large_values[] = [64:127];          // Large values
      bins very_large_values[] = [128:255];    // Very large values
      bins extreme_values[] = [256:511];       // Extreme values
      bins ultra_extreme_values[] = [512:1023];// Ultra extreme values

      // Additional bins for specific cases or patterns
      bins all_zeros = {0};                    // All zeros
      bins all_ones = {2**256-1};              // All ones
    }
    coverpoint pkt.wen {
      bins write_bin[] = {1};
      bins read_bin[]  = {0};
    }
  endgroup

  function new (string name, uvm_component parent = NULL);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon_analysis_port = new("mon_analysis_port", this);
    if(coverage_toggle == COV_ENABLE) begin
      `uvm_info(get_type_name(), "SRAM MONITOR COVERAGE CREATED", UVM_LOW)
      cg_cltd_pkts = new();
      cg_cltd_pkts.set_inst_name({get_full_name(), ".monitor_pkt"});
    end
  endfunction : build_phase

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(!uvm_config_db#(virtual sram_if)::get(this, get_full_name(), "vif", vif))
     `uvm_error("NOVIF", {"virtual interface must be set for:", get_full_name(); ".vif"}, UVM_LOW)
  endfunction : connect_phase
  
  virtual task run_phase(uvm_phase phase);
    @(posedge vif.reset);
    @(negedge vif.reset);
    `uvm_info(get_type_name(), "Reset Done", UVM_MEDIUM)

    
  endtask : run_phase
endclass
