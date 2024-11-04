// Project name : APB UVC
// Component name : APB Directed_Slave_Test


// In this test, write read sequence is configured to target all slaves one after
// another in a sequential order.
// Write followed by read operation to the same address is done random no.of times

class apb_directed_slave_test extends apb_base_test;
  
   apb_multi_read_aftr_write_seq m_rwseq;            // Multiple write read sequence to address in the range
                                             // modified by seq_cfg handle

   // Factory registration
  `uvm_component_utils(apb_directed_slave_test)
   
   // Constructor
  function new(string name = "apb_directed_slave_test", uvm_component parent = null);
      super.new(name, parent);

   endfunction : new
   

   // Build phase
   // To create objects of apb_sequence and apb environment
   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      m_rwseq = apb_multi_read_aftr_write_seq :: type_id :: create("m_rwseq");
     
   endfunction : build_phase
  
    
   // Write read sequence is ran no. of slaves times to select
   // each individual slave once in random order
   task run_phase (uvm_phase phase);
      phase.raise_objection(this);
     //if($value$plusargs("UVM_TEST_NAME=%s",name ))
       //$display(UVM_TEST_NAME);
     for(int i = 0; i < `NO_OF_SLAVES-1; i++) begin
       assert(seq_cfg.randomize()) else `uvm_error(get_type_name(), "seq_cfg randomisation failed");
       seq_cfg.configure();                // Argument to this task represents slave no
       assert(m_rwseq.randomize() with {slave_start_addr == seq_cfg.slave_start_addr;
                                        slave_end_addr   == seq_cfg.slave_end_addr;
                                        count            == 2;
                                        delay            == seq_cfg.delay;
                                       })
       else `uvm_error(get_type_name(), "Sequence randomisation failed")
       m_rwseq.start(env.agt.seqr);
     end
     #20;  // To see prdata
     phase.drop_objection(this);
     `uvm_info (get_full_name(), "Directed slave test ended", UVM_LOW);

   endtask : run_phase
  
  /*
   // Task to randomize and assign the sequence configure values
   task config_seq(input int slave_no);
      seq_cfg.configure(slave_no);
      m_rwseq.slave_start_addr = seq_cfg.slave_start_addr; 
      m_rwseq.slave_end_addr   = seq_cfg.slave_end_addr;
      m_rwseq.count            = seq_cfg.count_c;
            
   endtask : config_seq
  */
  
   
endclass : apb_directed_slave_test

//******************************EOF*************************************//

