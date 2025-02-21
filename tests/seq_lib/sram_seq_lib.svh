//======================================================
// Base Sequence with Objection Handling
//======================================================
class sram_base_seq extends uvm_sequence #(sram_packet);
  `uvm_object_utils(sram_base_seq)

  function new(string name = "sram_base_seq");
    super.new(name);
  endfunction

  virtual task pre_body();
    uvm_phase phase = get_starting_phase();
    if (phase != null) begin
      phase.raise_objection(this);
      `uvm_info(get_type_name(), "Raised objection", UVM_MEDIUM)
    end
  endtask

  virtual task post_body();
    uvm_phase phase = get_starting_phase();
    if (phase != null) begin
      phase.drop_objection(this);
      `uvm_info(get_type_name(), "Dropped objection", UVM_MEDIUM)
    end
  endtask
endclass



//======================================================
// Random Read/Write Sequence
//======================================================
class sram_random_seq extends sram_base_seq;
  `uvm_object_utils(sram_random_seq)

  rand int num_transactions = 200;
  rand bit we_n_weight = 0; // 0: More writes, 1: More reads

  function new(string name = "sram_random_seq");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), $sformatf("Starting %0d random transactions", num_transactions), UVM_LOW)

    for (int i = 0; i < num_transactions; i++) begin
      req = sram_packet::type_id::create("req");
      start_item(req);

      if (!req.randomize() with {
        if (we_n_weight) { op dist {WRITE := 2, READ := 8}; }       // More READS
        else { op dist {WRITE := 8, READ := 2}; }                   // More WRITES

        addr inside {[0: (1<<DATA_WIDTH)-1]};
        din inside {[0: (1<<ADDR_WIDTH)-1]};
      })
        `uvm_error("SEQ/XTN", "Randomization failed")
      
      finish_item(req);
      
      `uvm_info("SEQ/PKT#", $sformatf("Packet #%0d: %s @ 0x%0h Data: 0x%0h", i, req.we_n ? "READ" : "WRITE", req.addr, req.din), UVM_MEDIUM)
    end
  endtask
endclass



//======================================================
// Edge case sequence
//======================================================
class sram_edge_cases_seq extends sram_base_seq;
  `uvm_object_utils(sram_edge_cases_seq)

  function new(string name = "sram_edge_cases_seq");
    super.new(name);
  endfunction

  task body();
    bit [ADDR_WIDTH-1:0] edge_addrs[] = {
      0,
      (1 << ADDR_WIDTH) - 1,
      (1 << (ADDR_WIDTH-1)),
      (1 << (ADDR_WIDTH-1)) - 1
    };

    bit [DATA_WIDTH-1:0] edge_data[] = {
      0,
      (1 << DATA_WIDTH) - 1,
      'hAAAA,
      'h5555,
      'hF0F0,
      'h0F0F
    };

    `uvm_info(get_type_name(), "Starting edge case verification", UVM_LOW)
    
    // Address boundary tests with edge addresses and data patterns
    foreach (edge_addrs[i]) begin
      foreach (edge_data[j]) begin
        sram_packet wr_req, rd_req;

        // Create fresh transactions for each write/read pair
        wr_req = sram_packet::type_id::create("wr_req");
        rd_req = sram_packet::type_id::create("rd_req");

        // Write transaction
        start_item(wr_req);
        
        if (!wr_req.randomize() with {op == WRITE; addr == edge_addrs[i]; din == edge_data[j];}) 
          `uvm_error(get_type_name(), "Write randomization failed")

        `uvm_info("SEQ/WRITE", $sformatf("Addr: 0x%0h Data: 0x%0h", wr_req.addr, wr_req.din), UVM_MEDIUM)
        finish_item(wr_req);

        // Read transaction
        start_item(rd_req);
        
        if (!rd_req.randomize() with {op == READ; addr == edge_addrs[i];})         
          `uvm_error(get_type_name(), "Read randomization failed")

        `uvm_info("SEQ/READ", $sformatf("Addr: 0x%0h", rd_req.addr), UVM_MEDIUM)
        finish_item(rd_req);
      end
    end

    // Rapid WE toggle test
    // repeat (10) begin
    //   req = sram_packet::type_id::create("req");
    //   start_item(req);

    //   if (!req.randomize() with {addr == 0; op dist {WRITE:/50, READ:/50};}) begin
    //     `uvm_error(get_type_name(), "Randomization failed")
    //   end
    //   finish_item(req);
    // end
  endtask
endclass



//======================================================
// Stress Sequence
//======================================================
class sram_stress_seq extends sram_base_seq;
  `uvm_object_utils(sram_stress_seq)

  function new(string name = "sram_stress_seq");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), "Starting stress test with 100 transactions", UVM_LOW)

    for (int i = 0; i < 100; i++) begin
      req = sram_packet::type_id::create("req");
      start_item(req);

      if (!req.randomize() with {
        we_n dist {0:/50, 1:/50};
        addr dist {
          0                  :/10,
          (1<<ADDR_WIDTH)-1  :/10,
          [1:(1<<ADDR_WIDTH)-2] :/80
        };
        din dist {
          0                  :/10,
          (1<<DATA_WIDTH)-1  :/10,
          [1:(1<<DATA_WIDTH)-2] :/80
        };
      }) begin
        `uvm_error(get_type_name(), "Randomization failed")
      end
      finish_item(req);
      
      `uvm_info("SEQ/PKT#", $sformatf("Packet #%0d: %s @ 0x%0h Data: 0x%0h", i, req.we_n ? "READ" : "WRITE", req.addr, req.din), UVM_MEDIUM)
    end
  endtask
endclass



//======================================================
// Same address sequence
//======================================================
class sram_same_addr_seq extends sram_base_seq;
  `uvm_object_utils(sram_same_addr_seq)

  rand bit [ADDR_WIDTH-1:0] target_addr;

  function new(string name = "sram_same_addr_seq");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), $sformatf("Stress testing address 0x%0h", target_addr), UVM_LOW)

    // Write-read pattern
    repeat (20) begin
      sram_packet wr_req, rd_req;

      // Fresh write transaction
      wr_req = sram_packet::type_id::create("wr_req");
      start_item(wr_req);
      if (!wr_req.randomize() with {
        addr == target_addr;
        op == WRITE;
        din inside {[0:(1<<DATA_WIDTH)-1]};
      }) begin
        `uvm_error(get_type_name(), "Write randomization failed")
      end
      `uvm_info("SEQ/WRITE", $sformatf("Addr: 0x%0h Data: 0x%0h", 
                wr_req.addr, wr_req.din), UVM_MEDIUM)
      finish_item(wr_req);

      // Fresh read transaction
      rd_req = sram_packet::type_id::create("rd_req");
      start_item(rd_req);
      if (!rd_req.randomize() with {
        addr == target_addr;
        op == READ;
      }) begin
        `uvm_error(get_type_name(), "Read randomization failed")
      end
      `uvm_info("SEQ/READ", $sformatf("Addr: 0x%0h", rd_req.addr), UVM_MEDIUM)
      finish_item(rd_req);
    end

    // Back-to-back writes
    repeat (10) begin
      req = sram_packet::type_id::create("req");
      start_item(req);

      if (!req.randomize() with {addr == target_addr; op == WRITE; din inside {[0:(1<<DATA_WIDTH)-1]};}) begin
        `uvm_error(get_type_name(), "Randomization failed")
      end
      finish_item(req);
    end

    // Back-to-back reads
    repeat (10) begin
      req = sram_packet::type_id::create("req");
      start_item(req);

      if (!req.randomize() with {addr == target_addr; op == READ;}) begin
        `uvm_error(get_type_name(), "Randomization failed")
      end
      finish_item(req);
    end
  endtask
endclass
