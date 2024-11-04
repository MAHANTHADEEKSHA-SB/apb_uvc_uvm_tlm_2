


// Project name : APB UVC
// COmponent name : APB scoreboard with predictor instance inside


// APB scoreboard class

// Macros for Declaring port to receive item from the driver and monitor

//`uvm_analysis_imp_decl(_mon)
`uvm_blocking_transport_imp_decl(_ptor)

class apb_scoreboard extends uvm_scoreboard;

  // Predictor class handle
  apb_predictor ptor;
  
  // Implementation port to receive item from monitor
  uvm_tlm_b_target_socket #(apb_scoreboard,uvm_tlm_generic_payload) mon_item_collect_export;

  // Implemenation port to receive expected items from predictor
  uvm_blocking_transport_imp_ptor #(uvm_tlm_generic_payload,uvm_tlm_generic_payload,apb_scoreboard) ptor_export;
  
  uvm_tlm_b_transport_port #(uvm_tlm_generic_payload)sco2ptor_port;
  // Analysis port to send items received from monitor to predictor
  
  uvm_tlm_time tlm_delay;

  int no_of_checks;
  int error_count; 
  
  
  uvm_tlm_generic_payload mon_item_q[$];        // Monitored item are stored in this queue
  uvm_tlm_generic_payload drv_item_q[$];        // Driven items are stored in this queue
  uvm_tlm_generic_payload item_arr[int];        // Associative array to compare  written data with read data
  uvm_tlm_generic_payload mon_write_item_q[$];  // Associative array to store only write type monitored items
  
  // Factory registration
  `uvm_component_utils(apb_scoreboard)
 
  // Constructor 
  function new(string name = "apb_scoreboard", uvm_component parent = null);
    super.new(name, parent);
    mon_item_collect_export = new("mon_item_collect_export", this);     // TLM imp port instance for collecting items from monitor
    ptor_export             = new("ptor_export", this);                 // TLM imp port instance for collectimng items from predictor
    sco2ptor_port           = new("sco2ptor_port", this);               // TLM port to send monitored items to predictor
  endfunction : new


  // Build phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tlm_delay = new("tlm_delay", 0);
    ptor = apb_predictor :: type_id :: create ("ptor", this);           // APB predictor class instance      
  endfunction : build_phase

  virtual function void connect_phase(uvm_phase phase);
    // Connecting to predictor port
    ptor.ref_model_port.connect(ptor_export);                 // Connecting exports and ports b/w
    sco2ptor_port.connect(ptor.analysis_export);              // Predictor and scoreboard

  endfunction : connect_phase
  
  // Write method to collect items from monitor
  // Driven items are compared with monitored items incase of write operation
  // In case of read operation, data at adress is read from slave is compared with previously written data to the same address
  virtual task b_transport(uvm_tlm_generic_payload sco_mon_item, uvm_tlm_time tlm_delay);
    
    if(sco_mon_item.m_command == UVM_TLM_READ_COMMAND)
       mon_item_q.push_back(sco_mon_item);                // Actual data item queue, used for comparison with expected items from predictor
    else mon_write_item_q.push_back(sco_mon_item);        // Exclusively for backdoor test
     
    sco2ptor_port.b_transport(sco_mon_item,tlm_delay);
    
  endtask : b_transport  
       
  // Write method to receive expected data item from predictor
  // Expected item from the predictor is compared with actual item received from monitor (If read)
  // If address is read before write, prdata will be default set to 0

  virtual task transport_ptor(uvm_tlm_generic_payload exp_item, uvm_tlm_generic_payload rsp);
    uvm_tlm_generic_payload act_item;
    if(exp_item.m_command == UVM_TLM_WRITE_COMMAND)
      act_item = mon_write_item_q.pop_front();
    else
      act_item = mon_item_q.pop_front();
      
    no_of_checks++;
    //$display("COMPARE");
    act_item.print();
    exp_item.print();
    //$display("COMPARE DONE");
    if((act_item.m_address == exp_item.m_address) && (act_item.m_data[0] == exp_item.m_data[0]))
      `uvm_info("SCO", "Items matched", UVM_LOW) 
    else begin
      error_count++;
      `uvm_info("SCO", "Items mismatch", UVM_LOW)
    end
  endtask : transport_ptor
  
// Report phase
  // Displays no.of matches and mismatches
  function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Test report", UVM_NONE)
    `uvm_info("", $sformatf("Total transactions = %0d", no_of_checks), UVM_NONE)
    `uvm_info("", $sformatf("Pass count = %0d  Fail count = %0d", (no_of_checks - error_count), error_count), UVM_NONE)
  endfunction : report_phase  
endclass : apb_scoreboard

//*****************************EOF*************************************//

