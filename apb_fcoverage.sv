
// Project name : APB UVC
// Component name : UVM Subscriber (Used for coverage)


// Simple coverage plan to cover address and type of operation
class apb_fcoverage extends uvm_component;
  uvm_tlm_time tlm_delay; 
  uvm_tlm_b_target_socket #(apb_fcoverage,uvm_tlm_generic_payload) analysis_export;
  // Factory registration
  `uvm_component_utils(apb_fcoverage)
  
  uvm_tlm_generic_payload item;

  // Functional coverage group
  // Data is sampled  whenever a item is received from monitor port
  // i.e., whenever a item is received in the write method, covergae sampling is done  
  covergroup cg;
   
    // Coverpoints 
    addr_range :coverpoint item.m_address {
      // Bins to cover indiividual slave address range and def_slv covers the invalid slave addresses
      // i.e., default slave addresses
      bins slv0 = {[`SLAVE0_START_ADDR : `SLAVE0_END_ADDR]};
      bins slv1 = {[`SLAVE1_START_ADDR : `SLAVE1_END_ADDR]};
      bins slv2 = {[`SLAVE2_START_ADDR : `SLAVE2_END_ADDR]};
      bins slv3 = {[`SLAVE3_START_ADDR : `SLAVE3_END_ADDR]};
      bins slv4 = {[`SLAVE4_START_ADDR : `SLAVE4_END_ADDR]};
      bins slv5 = {[`SLAVE5_START_ADDR : `SLAVE5_END_ADDR]};
      bins slv6 = {[`SLAVE6_START_ADDR : `SLAVE6_END_ADDR]};
      bins def_slv = default; 
    }
  
    write_read : coverpoint item.m_command;
 
    addr_X_wr_rd : cross addr_range, write_read;
      
  endgroup
  
  
  
  // Constructor
  function new(string name = "fcoverage", uvm_component parent);
    super.new(name, parent);
    cg = new;
    tlm_delay = new("tlm_delay", 0); 
    analysis_export = new("analysis_export",this);
  endfunction : new
  
  // Write method to receive item from monitor
  virtual task b_transport(uvm_tlm_generic_payload t, uvm_tlm_time tlm_delay);
     this.item = t;
     cg.sample();
  endtask : b_transport
/*
  function void write (apb_sequence_item t);
     this.item = t;
     cg.sample();                      // Coverage sampling task
  endfunction : write
*/
  
  // Report phase to report coverage percentage
  function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Final coverage percentage = %0d", $get_coverage()), UVM_LOW)
  endfunction : report_phase 
  
  
endclass




