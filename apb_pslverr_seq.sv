//------------------------------------------------------------------------------
//APB_PSLVERR SEQUENCE
//GENERATES THE ADDRESS BASED ON THE ADDRESS MACRO VALUES 
//------------------------------------------------------------------------------
class apb_pslverr_seq extends apb_base_seq;
   int  delay;
   rand bit [`DATA_WIDTH - 1 : 0] write_data;
   rand bit [`ADDR_WIDTH - 1 : 0] slave_start_addr,slave_end_addr;//for configuring the address to be sent from the test
   //-------------------------------------------------------------------
 
   constraint pslverr_addr{slave_start_addr  == `SLAVE_END_ADDR;
                           slave_end_addr    == `SLAVE_START_ADDR;//TO GENERATE THE OUT OF BOUND ADDRESS
                           }
   uvm_tlm_generic_payload trans;
   //UVM automation macro
   `uvm_object_utils(apb_pslverr_seq)
   //constructor
   function new(string name = "apb_pslverr_seq");
      super.new(name);
   endfunction : new
   //-------------------------------------------------------------------
   task body();//body task
      `uvm_info(get_type_name(),"starting write sequence",UVM_MEDIUM) //START INDICATION
      trans = uvm_tlm_generic_payload :: type_id :: create ("trans");//SEQ_ITEM CREATION
      start_item(trans);
      assert(trans.randomize() with //RANDMIZING WITH INLINE CONSTRAINTS
                      {trans.m_address > slave_start_addr; trans.m_address > slave_end_addr;//TO PICK THE OUT OF BOUND ADDRESS
                       trans.m_command         == UVM_TLM_WRITE_COMMAND;
                       trans.m_data.size()     == 1; 
                       trans.m_data[0]         == write_data;
                       trans.m_streaming_width == delay;
                       }
                   );                                //will write to the given address or can we used as a sun sequence for traffic sequence
      finish_item(trans);//ENDING THE SENT ITEM
     `uvm_info(get_type_name(),$psprintf("trans_addr : h%0h trans_data : h%0h",trans.m_address,trans.m_data[0]),UVM_MEDIUM)//ENDING INDICATION
   endtask : body
endclass : apb_pslverr_seq
