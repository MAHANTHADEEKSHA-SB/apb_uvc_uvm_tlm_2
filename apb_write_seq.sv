//------------------------------------------------------------------------------
//APB_WRITE_SEQ
//THIS SEQUENCE GENERATES THE WRITE TRANSACTION PACKET
//------------------------------------------------------------------------------
class apb_write_seq extends apb_base_seq;
   rand int  delay;                                               //delay between transactions
   rand int  count;                                               //no of transactions
   rand bit [`DATA_WIDTH - 1 : 0] write_data;                     //data for transactions
   rand bit [`ADDR_WIDTH - 1 : 0] slave_start_addr,slave_end_addr;//for constrainting to address range
   //-------------------------------------------------------------------
   constraint delay_limit {delay >= 0; soft delay <= 100;} //controling the delay between transfers
   constraint cnt         {soft count == 1;}               //controling the no of transactions
   uvm_tlm_generic_payload trans;//sequence item instance
   //UVM automation macro
   `uvm_object_utils(apb_write_seq)
   //constructor
   function new(string name = "apb_write_seq");
      super.new(name);
   endfunction : new
   //-------------------------------------------------------------------
   task body();//body task
      repeat(count)begin
         `uvm_info(get_type_name(),"starting write sequence",UVM_MEDIUM)
         trans = uvm_tlm_generic_payload :: type_id :: create ("trans");                  // trans item creation
         start_item(trans);                                                         // starting trans item
         assert(trans.randomize() with                                              //randomising the trans item with inline constraints
                      {trans.m_address inside { [slave_start_addr : slave_end_addr]}; // constrainting the item address range
                       trans.m_command         == UVM_TLM_WRITE_COMMAND;
                       trans.m_data.size()     == 1;
                       //trans.m_data[0]         == write_data;
                       trans.m_streaming_width == delay;
                       } 
                   );                               
         finish_item(trans);                                                        // finishing the trans item
         get_response(rsp);                                                         // receiving the response from the driver
        `uvm_info(get_type_name(),$psprintf("trans_addr : h%0h trans_data : h%0h",trans.m_address,trans.m_data[0]),UVM_MEDIUM)
      end
   endtask : body
endclass : apb_write_seq
