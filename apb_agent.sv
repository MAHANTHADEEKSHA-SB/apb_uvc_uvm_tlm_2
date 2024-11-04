

// Project name :APB UVC
// Component name :  APB agent 


// APB agent class 
class apb_agent extends uvm_agent;
   apb_driver drv;       // Handle to apb driver component
   apb_sequencer seqr;   // Handle to apb sequencer component
   apb_monitor mon;      // Handle to apb monitor component
  

   // Factory registration
   `uvm_component_utils(apb_agent);
   
   // Constructor
   function new(string name = "apb_agent", uvm_component parent = null);
      super.new(name, parent);

   endfunction : new
   

   // Build phase
   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      // To create instance handles of driver and sequencer
      // In future  use get_is_active method to check whether agent is passive or active
      // iff passive agent, only handle to monitor is required
     if(get_is_active() == UVM_ACTIVE) begin
      drv = apb_driver :: type_id :: create ("drv", this);
      seqr = apb_sequencer :: type_id :: create ("seqr", this);
     end
      mon = apb_monitor :: type_id :: create ("mon", this);

   endfunction : build_phase


   //Connect phase
   function void connect_phase (uvm_phase phase);
      super.connect_phase(phase);
      // This connection is required only for active agent
      drv.seq_item_port.connect(seqr.seq_item_export);
      
   endfunction : connect_phase



endclass :  apb_agent

//*************************EOF****************************************//
