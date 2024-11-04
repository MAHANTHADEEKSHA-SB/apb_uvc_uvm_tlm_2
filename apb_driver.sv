// Project name : APB UVC
// Component name : APB driver 

`include "apb_drv_callback.sv"
// APB driver class
class apb_driver extends uvm_driver#(uvm_tlm_generic_payload);
  
  //Factory registration
  `uvm_component_utils(apb_driver);
  
  // Callback registration
  `uvm_register_cb(apb_driver, driver_cb)

  // Virtual interface handle
  virtual apb_if vif;

  // Constructor
  function new(string name = "apb_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new
  
  // Build phase
  // Receives interface from  config db
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    //To get interface from config_db
    if(!uvm_config_db #(virtual apb_if) :: get(this, "", "vif", vif))
       `uvm_fatal(get_full_name(), "Unable to access interface handle from config_db")
  endfunction : build_phase
  
  // Run phase
  task run_phase(uvm_phase phase);

    // Waiting for reset signal assertion
    wait(vif.presetn == 1'b0);

    // Resetting slave signal via interface
    vif.paddr <= 'h0;
    vif.pwdata <= 'h0;
    vif.pwrite <= 'b0;
    vif.penable <= 'b0;
    
    // Wait for reset deassertion
    @(posedge vif.presetn);
    forever begin
      // Alternative: try get and put methods (but not recommended)
      seq_item_port.get_next_item(req); // waiting for the item in sequencer FIFO
      drive_stimulus(req);              // Task to drive stimulus to DUT
      record_response();
      seq_item_port.item_done(req);     // Sending the received item as response
                                        // This is optional
    end
    
  endtask : run_phase


  // Task to drive stimulus to DUT  interface
  task drive_stimulus(uvm_tlm_generic_payload item);
     repeat(item.m_streaming_width) @(posedge vif.pclk);
      //@(posedge vif.psel[$clog2(vif.psel)]);       // To wait until psel is asserted
      //wait(vif.cb.psel == 0);
      // Decoder module inside interconnect will take care of 
      // psel signal generation
      // Driving stimulus on the interface 
     
    while(vif.psel != 0) begin
      @(posedge vif.pclk);end
     
      vif.paddr <= item.m_address;
      if(item.m_command == UVM_TLM_WRITE_COMMAND) vif.pwrite <= 1'b1;
      if(item.m_command == UVM_TLM_READ_COMMAND)  vif.pwrite <= 1'b0;
      //vif.pwrite <= item.wr_rd;
      //int j;
      //foreach(item.m_data[j]) begin
        vif.pwdata <= (item.m_command == UVM_TLM_WRITE_COMMAND) ? item.m_data[0] : 'b0;
      //end
      
      vif.penable <= 'b0;
      @(posedge vif.pclk);
      vif.penable <= 1'b1;
      @(posedge vif.pclk);
      vif.penable <= 'b0;
      @(posedge vif.pclk);
       
  endtask : drive_stimulus

  // Callback method 
  virtual task record_response();
    // Macro to call callback method
    `uvm_do_callbacks(apb_driver, driver_cb, data_capture(this, req))
  endtask : record_response
  
  
endclass : apb_driver

//*************************EOF****************************************//
