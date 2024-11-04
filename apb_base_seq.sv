
// Project name : APB UVC
// Component name : apb_base_seq class


// Encapsulate common properties and methods i.e., required in all the derived sequences
//----------------------------------------------------------------------------------
//APB_BASE_SEQ
//THIS BASE SEQ IS USED AS A PARENT TO ALL THE OTHER SEQUENCES
//----------------------------------------------------------------------------------
class apb_base_seq extends uvm_sequence #(uvm_tlm_generic_payload);
   //UVM FACTORY REGISTRATION
   `uvm_object_utils(apb_base_seq)
   //constructor
   function new(string name = "apb_base_seq");
      super.new(name);
   endfunction : new
   //----------------------------------------------------------------------------
endclass : apb_base_seq
//********************************EOF***********************************//
