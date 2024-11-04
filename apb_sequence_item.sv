
// Project name   : APB UVC
// Component name : APB sequence item


typedef enum bit {READ, WRITE} apb_wr_rd;
typedef enum {ZERO, LOW, MEDIUM, HIGH} delay_type; // Zero delay in case of Burst transfer


// APB sequence item class definition
class apb_sequence_item extends uvm_sequence_item;
  rand bit [`ADDR_WIDTH-1:0] addr;    // Address field
  rand bit [`DATA_WIDTH-1:0] data;    // Data field
  rand apb_wr_rd wr_rd;
  rand delay_type delay;
  rand int delay_val;
  
  bit is_read;                       // This bit is used during comparison inside scoreboard (predictor)
  
  // Word aligned address
  constraint addr_val {addr % 4 == 0;}

  // If typr of operation is read then data field is not randomised
  constraint rd_data {(wr_rd == READ) -> data == 0;}
  
  // Slaves with different speeds
  constraint c_delay {(delay == ZERO) -> delay_val == 0;
                      (delay == LOW) -> delay_val inside {[1:20]};
                      (delay == MEDIUM) -> delay_val inside {[21:40]};
                      (delay == HIGH) -> delay_val inside {[41:60]};
                     }
 
  
  // With and without field macro automation
  `ifndef FIELD_MACRO
     `uvm_object_utils(apb_sequence_item)
  `else
     `uvm_object_utils_begin(apb_sequence_item)
        `uvm_field_int(addr, UVM_ALL_ON)
        `uvm_field_int(data, UVM_ALL_ON)
        `uvm_field_enum(apb_wr_rd, wr_rd, UVM_ALL_ON)
        `uvm_field_enum(delay_type, delay, UVM_ALL_ON)
        `uvm_field_int (delay_val, UVM_ALL_ON | UVM_DEC)
     `uvm_object_utils_end
  `endif
  
  // Constructor
  function new(string name = "apb_sequence_item");
      super.new(name); 
    
   endfunction
  
  // If field macro automation is not enabled, user defined callbacks are used
`ifndef FIELD_MACRO   
  
  
  
  // Use defined callback of print method
   virtual function void do_print(uvm_printer printer);
     super.do_print(printer);
     printer.print_field("data", data, $bits(data), UVM_HEX);
     printer.print_field("addr", addr, $bits(addr), UVM_HEX);
     printer.print_string("wr_rd", wr_rd.name);
     printer.print_string("delay_type", delay.name);
     printer.print_field("delay_val", delay_val, $bits(delay_val));
                         
    
  endfunction : do_print 
  
  
   // User defined callback of copy method
   virtual function void do_copy(uvm_object rhs);
      apb_sequence_item item;
      super.do_copy(rhs);
      $cast(item, rhs);
      data = item.data;
      addr = item.addr;
      wr_rd = item.wr_rd;
    
   endfunction : do_copy
  
   // User defined callback of compare method
   virtual function bit do_compare (uvm_object rhs, uvm_comparer comparer);
      apb_sequence_item item;
      bit comp;
      $cast(item, rhs);
      comp = super.do_compare(item, comparer) &
     (data == item.data) & (addr == item.addr) & (wr_rd == item.wr_rd);
      return comp;
   endfunction : do_compare
   
  
   // Method to display the fields of sequence item
   virtual function string convert2string();
    
      string contents;
      $sformat(contents, "data = %0d addr = %0d  wr_rd = %0s delay = %0s delay val = %0d", data, addr, wr_rd.name, delay.name, delay_val);
      return contents;
    
   endfunction : convert2string
  `endif
  
   
endclass : apb_sequence_item

//*************************EOF****************************************//
