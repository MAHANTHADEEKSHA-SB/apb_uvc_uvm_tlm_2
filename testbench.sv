// Code your testbench here
// or browse Examples


// Top testbench module

// To include uvm macros source library file
`include "uvm_macros.svh"

// To import uvm package
import uvm_pkg :: *;

`include "apb_defines.sv"
`include "apb_if.sv"
`include "apb_sequence_item.sv"
`include "apb_base_seq.sv"
`include "apb_multi_read_aftr_write_seq.sv"
`include "apb_read_seq.sv"
`include "apb_write_seq.sv"
`include "apb_sequencer.sv"
`include "apb_driver.sv"
`include "apb_monitor.sv"
`include "apb_agent.sv"
`include "apb_predictor.sv"
`include "apb_scoreboard.sv"
`include "apb_fcoverage.sv"
`include "apb_env.sv"
`include "apb_test_config.sv"
`include "apb_base_test.sv"
`include "apb_directed_slave_test.sv"
//`include "apb_rand_write_test.sv"
//`include "apb_backdoor_write_frontdoor_read_test.sv"
//`include "apb_frontdoor_write_backdoor_read_test.sv"
//`include "apb_burst_mode_test.sv"
//`include "apb_assertions.sv"
//`include "apb_top_dut.sv"


// Top dut
module tb_top;
   bit pclk;
   bit presetn;
   string test_name;
  


   // Interface handle
   apb_if pif(pclk, presetn);

   // Instantiating DUT
  apb_top_dut   DUT (.pclk(pif.pclk),
                                                .presetn(pif.presetn),
                                                .paddr(pif.paddr),
                                                .pwrite(pif.pwrite),
                                                .penable(pif.penable),
                                                .pwdata(pif.pwdata),
                                                .prdata(pif.prdata),
                                                .pready(pif.pready),
                                                .pslverr(pif.pslverr)
                                               ); 

   
   assign pif.psel = DUT.DECOD_MUX.psel;   // To tap intermediate psel signals
  
   // Binding assertions to top apb DUT
 /*  bind apb_top_dut apb_assertion sva ( .pclk(pif.pclk),
                                        .presetn(pif.presetn),
                                        .pready(pif.pready),
                                        .paddr(pif.paddr),
                                        .psel(pif.psel),
                                        .penable(pif.penable),
                                        .pwdata(pif.pwdata),
                                        .pwrite(pif.pwrite),
                                        .pslverr(pif.pslverr)
                                      );
 */
   initial begin
     $dumpfile("dump.vcd");
     $dumpvars(0, tb_top);
      fork
         // Clock generation thread
         begin
            pclk = 0;
            forever #5 pclk = ~pclk;
         end

         // Reset signal generation thread
         // Active low reset signal
         begin
            presetn = 1;
            #2 presetn = 1'b0;
            repeat(2) @(posedge pif.pclk);
            presetn = 1'b1;
         end
      join

   end  


  // For backdoor verification
  // Different APB slave instance memory is updated with data present in external file
  //`ifdef BACKDOOR_WRITE_FRONTDOOR_READ_TEST
    initial begin
      if($value$plusargs("UVM_TESTNAME=%0s", test_name)) begin
        if(test_name == "apb_backdoor_write_frontdoor_read_test") begin
        // Updating few locations of memory of each slave except default slave with same data from a hex_data file
          $readmemh("hex_data.txt", `SLAVE_MEM_PROBE(0));
          $readmemh("hex_data.txt", `SLAVE_MEM_PROBE(1));
          $readmemh("hex_data.txt", `SLAVE_MEM_PROBE(2));
          $readmemh("hex_data.txt", `SLAVE_MEM_PROBE(3));
          $readmemh("hex_data.txt", `SLAVE_MEM_PROBE(4));
          $readmemh("hex_data.txt", `SLAVE_MEM_PROBE(5));
          $readmemh("hex_data.txt", `SLAVE_MEM_PROBE(6));
        end  
      end
    end
  //`endif    


   
   initial begin
      // Setting the virtual interface in config db
      // This interface hanlde can be retireved from any component down the hierarchy
      uvm_config_db #(virtual apb_if) :: set (uvm_root :: get(), "*", "vif", pif);
      run_test ("apb_directed_slave_test");
     $dumpfile("dump.vcd"); 
     $dumpvars();
 
   end

  

endmodule : tb_top

//**************************************EOF******************************************************//