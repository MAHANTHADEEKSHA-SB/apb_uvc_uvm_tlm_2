//------------------------------------------------------------------------------
//APB_MULTI_READ_AFTR_WRITE_SEQ 
//THIS SEQUENCE CAN BE USED TO DO MULTIPLE READ AFTER WRITE TRANSACTIONS BY DEFAULT IS TRANSACTION
//------------------------------------------------------------------------------
class apb_multi_read_aftr_write_seq extends apb_base_seq;
    //-------------------------------------------------------------------
    rand bit [`ADDR_WIDTH - 1 : 0] slave_start_addr;    //to indicate the start addr
    rand bit [`ADDR_WIDTH - 1 : 0] slave_end_addr;      //to indicate the end address
    rand int delay;                                     //delay between transfers
    rand int count;                                     //no of read after write transactions
   //-------------------------------------------------------------------
    constraint dely {soft delay >= 0; soft delay <= 100;}//control the delay between transactions
    constraint cnt  {soft count == 1;}                   //control the no of read after write transactions 
   //UVM macro registration
    `uvm_object_utils(apb_multi_read_aftr_write_seq)
   
   uvm_tlm_generic_payload  apb_wr_txn;//write transaction item
   uvm_tlm_generic_payload  apb_rd_txn;//read  transaction item

   //constructor
    function new(string name = "apb_multi_read_aftr_write_seq");
       super.new(name);
    endfunction : new
  //-------------------------------------------------------------------
   task body();//body task for read after write sequence
      `uvm_info(get_type_name(),"Starting READ AFTER WRITE SEQUENCE",UVM_MEDIUM)
      //-------------------------------------------------------------------
      repeat(count) begin
      //write transaction
         apb_wr_txn = uvm_tlm_generic_payload :: type_id :: create("apb_wr_txn");          //write txn item creation
         start_item(apb_wr_txn);                                                     //write txn item starting
         assert(apb_wr_txn.randomize() with                                          //write txn item randomisation with inlinem constraints
                      {apb_wr_txn.m_address inside {[slave_start_addr : slave_end_addr]}; // address configuration
                       apb_wr_txn.m_streaming_width == delay;
                       apb_wr_txn.m_command         == UVM_TLM_WRITE_COMMAND;
                       apb_wr_txn.m_data.size()     == 1;
                       }
                   );
         finish_item(apb_wr_txn);                                                   //finishing write_txn item
         get_response(rsp);                                                         //receiving response from driver
         `uvm_info(get_type_name(),$psprintf("WRITE_TXN : addr : 32'h%0h data : 32'h%0h",apb_wr_txn.m_address,apb_wr_txn.m_data[0]),UVM_MEDIUM)
      //-------------------------------------------------------------------
      //read transaction
         apb_rd_txn = uvm_tlm_generic_payload :: type_id :: create("apb_rd_txn");//read txn item creation
         start_item(apb_rd_txn);                                           //read txn item starting
         assert(apb_rd_txn.randomize() with        
                      {
                       apb_rd_txn.m_streaming_width == delay;                          //randomising read txn with inline constraints
                       apb_rd_txn.m_command         == UVM_TLM_READ_COMMAND;
                       apb_rd_txn.m_address         == apb_wr_txn.m_address;                //to pick the same write txn address
                       apb_rd_txn.m_data.size()     == 1; 
                      }
                   );
          finish_item(apb_rd_txn);                                         //finishing read txn item
          get_response(rsp);                                               //receiving response from driver
          `uvm_info(get_type_name(),$psprintf("READ_TXN  : addr : 32'h%0h data : 32'h%0h",apb_rd_txn.m_address,apb_rd_txn.m_data[0]),UVM_MEDIUM)
      end
      `uvm_info(get_type_name(),"End of READ AFTER WRITE SEQUENCE",UVM_MEDIUM)
   endtask : body

endclass : apb_multi_read_aftr_write_seq
