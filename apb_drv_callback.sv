// Callback classes

typedef class apb_driver;

class driver_cb extends uvm_callback;
  
  // Factory registration
  `uvm_object_utils(driver_cb)

  //constructor method
  function new(string name = "driver_cb");
    super.new(name);
  endfunction
  
  //definition of callback method
  virtual task data_capture(apb_driver drv, uvm_tlm_generic_payload req);
  endtask
 
endclass : driver_cb

//----------------------------------------------------------------

class data_collect_cb extends driver_cb;
  
  //Factory registration
  `uvm_object_utils(data_collect_cb)

  // Constructor
  function new (string name="data_collect_cb");
    super.new(name);
  endfunction : new

  //adding logic to call back method
  task data_capture(apb_driver drv, uvm_tlm_generic_payload req);
    if(req.m_command == UVM_TLM_READ_COMMAND)  // For read operation, packet with prdata is sent as response
    begin
      @(posedge drv.vif.pclk);
      req.m_data[0] = drv.vif.prdata;
     end  
  endtask : data_capture
  
endclass : data_collect_cb

//**********************EOF*****************************//
