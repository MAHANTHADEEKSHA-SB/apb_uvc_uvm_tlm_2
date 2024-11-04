

// Project name : APB UVC
// Component name : APB Environment 


// APB environment class
class apb_env extends uvm_env;
   apb_agent agt;         // Handle to apb_agent class
   apb_scoreboard sco;    // Handle to apb_scoreboard class
   apb_fcoverage fcov;    // Handle to functional coverage subscriber
   // Factory registration
   `uvm_component_utils(apb_env);


   // Constructor
   function new(string name = "apb_env", uvm_component parent = null);
      super.new(name, parent);

   endfunction : new
   
   // Build phase of environment
   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      // To create apb_agent object
      agt = apb_agent ::type_id :: create ("agt", this);
      sco = apb_scoreboard :: type_id :: create("sco", this);
      fcov = apb_fcoverage :: type_id :: create ("fcov", this);

   endfunction : build_phase



   function void connect_phase(uvm_phase phase);
     super.connect_phase(phase);
      // Connecting monitor with scoreboard using TLM ports
     agt.mon.item_collect_port.connect(sco.mon_item_collect_export);
     //agt.mon.item_collect_port.connect(fcov.analysis_export);

   endfunction : connect_phase

endclass : apb_env

//*************************EOF****************************************//
