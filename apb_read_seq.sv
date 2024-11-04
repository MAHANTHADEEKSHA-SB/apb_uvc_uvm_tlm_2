//------------------------------------------------------------------------------
//APB_READ_SEQ
//THIS SEQUENCE WILL GENERATE THE READ TRANSACTION
//------------------------------------------------------------------------------
class apb_read_seq extends apb_base_seq;
   rand int delay;                                                //delay between transactions
   rand int count;                                                //no of transactions
   rand bit [`ADDR_WIDTH - 1 : 0] slave_start_addr,slave_end_addr;//for constrainting the range of address
   //-------------------------------------------------------------------
   constraint delay_limit {delay >= 0; soft delay <= 100;}//controling the delay between transfer
   constraint cnt         {soft count == 1;}              //controling the no of transactions
   //-------------------------------------------------------------------
   //uvm factory registration
   `uvm_object_utils(apb_read_seq)
   
   uvm_tlm_generic_payload trans;//seq item handle 
   //-------------------------------------------------------------------
   //Constructor
   function new(string name = "apb_read_seq");
      super.new(name);
   endfunction : new
   //-------------------------------------------------------------------
   task body();
      repeat(count)begin                                                //body task for the read sequence
         `uvm_info(get_type_name,"Starting read seq",UVM_MEDIUM)
         trans = uvm_tlm_generic_payload :: type_id :: create ("trans");                 //seq item creation
         start_item(trans);                                                        //starting item
         assert(trans.randomize() with                                             //randomising the item with inline constraints
                      { trans.m_address inside {[slave_start_addr : slave_end_addr]};//to constraint the address range for item address
                        trans.m_command == UVM_TLM_READ_COMMAND;
                        trans.m_streaming_width == delay;
                        trans.m_data.size() == 1;
                       }
                   );
         finish_item(trans);                                                       //finishing the item
         get_response(rsp);                                                        //receiving the response from driver
         `uvm_info(get_type_name,$psprintf("trans_addr : h%0h trans_data : h%0h",trans.m_address,trans.m_data[0]),UVM_MEDIUM)
      end
   endtask : body

endclass : apb_read_seq
