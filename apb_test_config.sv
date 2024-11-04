
// Project name :APB UVC
// Component name :  APB Test configuration


// APB Test config class 
// This config class is used to cofigure the sequences

class apb_test_config extends uvm_object;
  
  rand bit [`ADDR_WIDTH-1:0] addr;
  rand bit wr_rd;
  rand int unsigned delay;
  randc bit [$clog2(`NO_OF_SLAVES)-1:0] slave_no;
  rand int count;
  
  // To decide start and end address of slave
  bit [`ADDR_WIDTH-1:0] slave_start_addr, slave_end_addr;
 
  // Factory registration 
  `uvm_object_utils(apb_test_config)
  
  //Constraints 
  constraint c1 {addr % 4 == 0; soft addr inside {[`SLAVE0_START_ADDR : `SLAVE6_END_ADDR]};}
  constraint c2 {soft count inside {[5:10]};}
  constraint c3 {soft slave_no != 7;}
  constraint c4 {soft delay >=0; delay <= 100;}
  
  // Constructor
  function new(string name = "apb_test_config");
    super.new(name);
  endfunction : new
  
  
 
  // Method to select slave address range cnd count value
  function void configure();
    
    case (slave_no)
      0 : begin
            slave_start_addr = `SLAVE0_START_ADDR;
            slave_end_addr   = `SLAVE0_END_ADDR;
          end
      1 : begin
            slave_start_addr = `SLAVE1_START_ADDR;
            slave_end_addr   = `SLAVE1_END_ADDR;
          end
      2 : begin
            slave_start_addr = `SLAVE2_START_ADDR;
            slave_end_addr   = `SLAVE2_END_ADDR;
          end
      3 : begin
            slave_start_addr = `SLAVE3_START_ADDR;
            slave_end_addr   = `SLAVE3_END_ADDR;
          end
      4 : begin
            slave_start_addr = `SLAVE4_START_ADDR;
            slave_end_addr   = `SLAVE4_END_ADDR;
          end
      5 : begin
            slave_start_addr = `SLAVE5_START_ADDR;
            slave_end_addr   = `SLAVE5_END_ADDR;
          end
      6 : begin
            slave_start_addr = `SLAVE6_START_ADDR;
            slave_end_addr   = `SLAVE6_END_ADDR;
          end
      
      default : begin
                  slave_start_addr = `DSLAVE_START_ADDR;
                  slave_end_addr   = `DSLAVE_END_ADDR;
                end
      
    endcase
    
    
  endfunction : configure
  
  
endclass : apb_test_config

//**********************************EOF*****************************************************//
