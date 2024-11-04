// Project name : APB UVC
// Component name : APB Test


// Base test class component

class apb_base_test extends uvm_test;
  apb_env env;               // Environment class handle
  apb_test_config seq_cfg;   // apb_test_config class handle
  
  bit is_backdoor_write;     // This fields are used as knobs to modify the predictor logic
  bit is_backdoor_read;      // whenever backdoor test is selected
  // Factory registration
  `uvm_component_utils(apb_base_test)

  // Constructor
  function new(string name = "apb_base_test", uvm_component parent);
    super.new(name, parent);
    
  endfunction : new
  
   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
     
      // Creating environment class instance
      env = apb_env :: type_id :: create ("env", this);        
     
      // Creating configuration class instance
      seq_cfg = apb_test_config :: type_id :: create ("seq_cfg", this);
      
  endfunction : build_phase
    
    
endclass : apb_base_test

//-----------------------------------
