
// Project name : APB UVC
// Component name : APB sequencer


// APB sequencer
class apb_sequencer extends uvm_sequencer#(uvm_tlm_generic_payload);
  
  // Factory registration
  `uvm_component_utils(apb_sequencer)
 
  // Constructor 
  function new(string name = "apb_sequencer", uvm_component parent = null);
    super.new(name, parent);
    
  endfunction
  
  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
  endfunction
  
  
  
endclass : apb_sequencer

//*********************************EOF****************************************//
