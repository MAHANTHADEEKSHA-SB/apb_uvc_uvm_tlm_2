

// Project name : APB UVC
// component name : APB predictor (extended from uvm subscriber)


// Predictor class
class apb_predictor extends uvm_component;
   
   // UVM analysis port to send expected data back to scoreboard
   //uvm_analysis_port #(apb_sequence_item) ref_model_port;
   uvm_blocking_transport_port #(uvm_tlm_generic_payload) ref_model_port;

   uvm_tlm_b_transport_imp #(uvm_tlm_generic_payload,apb_predictor) analysis_export;   

   uvm_tlm_time tlm_delay;      

   // Factory registration
   `uvm_component_utils(apb_predictor)
  
   virtual apb_if vif;                                    // Virtual interface handle
   
   uvm_tlm_generic_payload sco_item_arr[bit[63 : 0]];                   // Queue to store items of write type
   
   //apb_sequence_item sco_item_arr[int];                   // Queue to store items of write type

   bit is_backdoor_write = 0;                             // These knobs are set in the backdoor tests
   bit is_backdoor_read  = 0;

   bit [`DATA_WIDTH-1 : 0] slave_mem [`NO_OF_SLAVES * 256];  // Each slave has a memory of 32 bit wide and 256 locations

   // Constructor
   function new(string name = "apb_predictor", uvm_component parent);
     super.new(name, parent);
     ref_model_port = new("ref_model_port", this);
     analysis_export = new("analysis_export",this);
   endfunction : new
  
  // Build phase
  // To retrieve interface handle and backdoor test control flags
  function void build_phase(uvm_phase phase);
    if(!uvm_config_db #(virtual apb_if) :: get(this, "", "vif", vif))
      `uvm_fatal(get_full_name(), "Failed to retrieve the interface");
    if(!uvm_config_db #(bit) :: get(this, "", "is_backdoor_write", is_backdoor_write))
      `uvm_info(get_type_name(), "Normal test selected", UVM_LOW)
    uvm_config_db #(bit) :: get(this, "", "is_backdoor_read", is_backdoor_read);
   
    tlm_delay = new("tlm_delay", 0); 
  endfunction : build_phase

  virtual task b_transport(uvm_tlm_generic_payload t, uvm_tlm_time tlm_delay);    
     uvm_tlm_generic_payload rcv_item;
    if(!$cast(rcv_item, t.clone())) `uvm_error(get_type_name(), "Casting failed in predictor")
     //`ifdef BACKDOOR_WRITE_FRONTDOOR_READ_TEST
     if(is_backdoor_write == 1) begin
      // To make sure that only read operation is performed during Backdoor_write_Frontdoor_read_test
       if(rcv_item.m_command == UVM_TLM_READ_COMMAND) begin 
         rcv_item.m_data[0] = slave_mem[rcv_item.m_address];
         //ref_model_port.write(rcv_item);
         ref_model_port.transport(rcv_item,rcv_item);
       end
       else `uvm_error("Back_door_test", "Attempting for write ")
     end
         
      //`elsif FRONTDOOR_WRITE_BACKDOOR_READ_TEST
      else if(is_backdoor_read == 1) begin
         vif.slave_mem_probe();                         // To probe the slave memory
        if (rcv_item.m_command == UVM_TLM_WRITE_COMMAND) begin
          rcv_item.m_data[0] = vif.mem_probe[rcv_item.m_address];
           //ref_model_port.write(rcv_item);
           ref_model_port.transport(rcv_item,rcv_item);
           //$display("Found"); 
           //rcv_item.print();
         end
      end
         
      else begin
        // Checking the type of item received
        // If it is of write type, item stored into queue for future read comparison
        if(rcv_item.m_command == UVM_TLM_WRITE_COMMAND)
          sco_item_arr[rcv_item.m_address] = rcv_item;
      
        // Incase of read operation, if data is previously written
        if(rcv_item.m_command == UVM_TLM_READ_COMMAND) begin
          if(sco_item_arr.exists(rcv_item.m_address)) begin
            rcv_item.m_data[0] = sco_item_arr[rcv_item.m_address].m_data[0];
            //ref_model_port.write(rcv_item);
                ref_model_port.transport(rcv_item,rcv_item);
          end
          else begin
            //rcv_item.is_read = 1;               // By default this bit is 0, indicating previous write operation
            //ref_model_port.write(rcv_item);
                ref_model_port.transport(rcv_item,rcv_item);
          end
        end
      end
    endtask
//------------------------------------------------------------------------------ 
 /*  // Write method to receive items from scoreboard
   function void write (apb_sequence_item t);
     
     apb_sequence_item rcv_item;
     if(!$cast(rcv_item, t.clone())) `uvm_error(get_type_name(), "Casting failed in predictor")
     


     //`ifdef BACKDOOR_WRITE_FRONTDOOR_READ_TEST
     if(is_backdoor_write == 1) begin
      // To make sure that only read operation is performed during Backdoor_write_Frontdoor_read_test
       if(rcv_item.wr_rd == READ) begin 
         rcv_item.data = slave_mem[rcv_item.addr];
         ref_model_port.write(rcv_item);
       end
       else `uvm_error("Back_door_test", "Attempting for write ")
     end
         
      //`elsif FRONTDOOR_WRITE_BACKDOOR_READ_TEST
      else if(is_backdoor_read == 1) begin
         vif.slave_mem_probe();                         // To probe the slave memory
         if (rcv_item.wr_rd == WRITE) begin
           rcv_item.data = vif.mem_probe[rcv_item.addr];
           ref_model_port.write(rcv_item);
         end
      end
         
      else begin
        // Checking the type of item received
        // If it is of write type, item stored into queue for future read comparison
        if(rcv_item.wr_rd == WRITE)
          sco_item_arr[rcv_item.addr] = rcv_item;
      
        // Incase of read operation, if data is previously written
        if(rcv_item.wr_rd == READ) begin
          if(sco_item_arr.exists(rcv_item.addr)) begin
            rcv_item.data = sco_item_arr[rcv_item.addr].data;
            ref_model_port.write(rcv_item);
          end
          else begin
            rcv_item.is_read = 1;               // By default this bit is 0, indicating previous write operation
            ref_model_port.write(rcv_item);
          end
        end
      end
      //`endif
       
   endfunction : write
*/
   //`ifdef BACKDOOR_WRITE_FRONTDOOR_READ_TEST
     // Method to read data from data file into local memory
     function void data_read ();
       for(int i = 0; i < `NO_OF_SLAVES; i++) begin
         $readmemh("$TB/hex_data.txt", slave_mem, 'h100*i, 'h100*i+'hff);
       end   
     endfunction : data_read

     function void end_of_elaboration_phase(uvm_phase phase);
       if(is_backdoor_write == 1)
         data_read();                 // To load the data from data file into local memory before performing
                                      // Frontdoor read
     endfunction : end_of_elaboration_phase
   
   //`endif   

   


endclass : apb_predictor

//*************************************EOF********************************************//
