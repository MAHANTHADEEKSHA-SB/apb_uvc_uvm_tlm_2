
// Project name :APB UVC
// Component name :  APB agent 


// APB monitor class 

class apb_monitor extends uvm_monitor;
  
  // Virutal apb interface handle
  virtual apb_if vif;
    
  // Analysis port of monitor
  uvm_tlm_b_initiator_socket #(uvm_tlm_generic_payload) item_collect_port; 
  
  uvm_tlm_time tlm_delay; 
  //Factory registration
  `uvm_component_utils(apb_monitor)
  
  // Constructor
  function new(string name = "apb_monitor", uvm_component parent);
    super.new(name, parent);
    item_collect_port = new("item_collect_port", this);
    
  endfunction : new
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tlm_delay = new("tlm_delay", 0); 
    // To get the interface from config db
    if(!uvm_config_db #(virtual apb_if) :: get (this, "", "vif", vif))
      `uvm_fatal(get_type_name(), "Unable to get interface from config_db")
  endfunction : build_phase
  
 virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
   // $display("Run phase of monitor");
    wait(vif.presetn == 1'b0);
    @(posedge vif.presetn);
    forever begin
      collect_item();   // Task to sample signals of interface
      
    end
    
    
  endtask : run_phase
    
    task collect_item();
      uvm_tlm_generic_payload item_collected;
      while(vif.penable == 1'b0)
        @(posedge vif.pclk);
      
      item_collected = uvm_tlm_generic_payload :: type_id :: create ("item_collected");
      item_collected.m_data = new[1]; 
      item_collected.m_address = vif.paddr;
      if(vif.pwrite == 1'b1) item_collected.m_command = UVM_TLM_WRITE_COMMAND;
      if(vif.pwrite == 1'b0) item_collected.m_command = UVM_TLM_READ_COMMAND;
      //item_collected.wr_rd = apb_wr_rd'(vif.pwrite);
   
      if(item_collected.m_command == UVM_TLM_WRITE_COMMAND)begin
        item_collected.m_data[0] = vif.pwdata;

      end
      
      while(vif.pready == 1'b0)       // Incase of wait states
        @(posedge vif.pclk);
      
      @(posedge vif.pclk)           // Because read is also sequential in this slave
      if(item_collected.m_command == UVM_TLM_READ_COMMAND) begin
        item_collected.m_data[0] = vif.prdata;
        $display("data %0h ",item_collected.m_data[0]);
      end
      item_collect_port.b_transport(item_collected,tlm_delay);
     
    endtask : collect_item
//------------------------------------------------------------------------------
  
endclass : apb_monitor

//***********************EOF************************************//
