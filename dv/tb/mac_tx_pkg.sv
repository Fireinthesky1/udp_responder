package mac_tx_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // ---------------------------------------------------------------------------
  //  Transaction
  // ---------------------------------------------------------------------------
  class rv_tr extends uvm_sequence_item;
    rand logic       ready;
    rand logic       valid;
    rand logic       sof;
    rand logic       eof;
    rand logic [7:0] data;
    // UVM automation macros for general objects
    `uvm_object_utils_begin(rv_seq_item)
      `uvm_field_int(ready, UVM_ALL_ON)
      `uvm_field_int(valid, UVM_ALL_ON)
      `uvm_field_int(sof, UVM_ALL_ON)
      `uvm_field_int(eof, UVM_ALL_ON)
      `uvm_field_int(data, UVM_ALL_ON)
    `uvm_object_utils_end
    //Constructor
    function new (string name = "rv_tr");
      super.new(name);
    endfunction : new
  endclass : rv_tr

  // ---------------------------------------------------------------------------
  //  Sequencer
  // ---------------------------------------------------------------------------



  // ---------------------------------------------------------------------------
  //  Driver
  // ---------------------------------------------------------------------------
  class rv_driver extends uvm_driver #(rv_seq_item);
    rv_seq_item rv_item;
    virtual dut_if.rv_driver_mp vif;
    // automation macros for general components
    `uvm_component_utils(rv_driver)
    // constructor
    function new (string name = "rv_driver", uvm_component parent);
      super.new(name, parent);
    endfunction : new
    function void build_phase(uvm_phase phase);
      string inst_name;
      super.build_phase(phase);
      // TODO(HICKS): Understand what's going on here.
      // Page 34 uvm user guide
      if(!uvm_config_df#(virtual dut_if)::get(this, "","vif",'vif))
        `uvm_fatal("NOVIF", {"virtual interface must be set for: ", get_full_name(), ".vif"});
      end
    endfunction : build_phase
    task run_phase(uvm_phase phase);
      forever begin
        // Get the next sequence item from the sequencer (may block).
        seq_item_ports.get_next_item(rv_item);
        drive_item(rv_item);       // Execute the item.
        seq_item_port.item_done(); // Consume the request
      end
    endtask : run

    // Drives the item to the DUT.
    task drive_item (input rv_seq_item item);
      @ (posedge vif.clk);
      if vif.ready == 1'b1 && vif.valid == 1'b1 begin
        // A handshake has occurred. Drive new data next clock.
        // DUT controls the ready signal.
        vif.valid <= item.valid;
        vif.data  <= item.data;
        vif.sof   <= item.sof;
        vif.eof   <= item.eof;
      end
    endtask : drive_item
  endclass : rv_driver


  // ---------------------------------------------------------------------------
  //  Monitor
  // ---------------------------------------------------------------------------

  // ---------------------------------------------------------------------------
  //  Agent
  // ---------------------------------------------------------------------------

  // ---------------------------------------------------------------------------
  //  Scoreboard
  // ---------------------------------------------------------------------------

  // ---------------------------------------------------------------------------
  //  Environment
  // ---------------------------------------------------------------------------

  // ---------------------------------------------------------------------------
  //  Sequence
  // ---------------------------------------------------------------------------

  // ---------------------------------------------------------------------------
  //  Test
  // ---------------------------------------------------------------------------


// TODO(HICKS): move everything over to this package

endpackage // mac_tx_pkg
