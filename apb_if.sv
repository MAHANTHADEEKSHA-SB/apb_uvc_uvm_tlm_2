
// Apb slave interface wrt slave

interface apb_if (input pclk, input presetn);
   logic pready;   // Pready signal associated with bus
   logic pwrite;
   logic [`NO_OF_SLAVES-1:0] psel;
   logic [`ADDR_WIDTH-1 : 0] paddr;
   logic penable;
   logic [`DATA_WIDTH-1 : 0] pwdata;
   logic [`DATA_WIDTH-1 :0] prdata;
   logic pslverr;

   // Below task is defined exclusively for frontdoor write backdoor read verification
   logic [31:0] mem_probe [`NO_OF_SLAVES*256];
  
   task slave_mem_probe();
     //As of now the design has 8 slaves
     mem_probe[`SLAVE0_START_ADDR : `SLAVE0_END_ADDR+3] = `SLAVE_MEM_PROBE(0);
     mem_probe[`SLAVE1_START_ADDR : `SLAVE1_END_ADDR+3] = `SLAVE_MEM_PROBE(1);
     mem_probe[`SLAVE2_START_ADDR : `SLAVE2_END_ADDR+3] = `SLAVE_MEM_PROBE(2);
     mem_probe[`SLAVE3_START_ADDR : `SLAVE3_END_ADDR+3] = `SLAVE_MEM_PROBE(3);
     mem_probe[`SLAVE4_START_ADDR : `SLAVE4_END_ADDR+3] = `SLAVE_MEM_PROBE(4);
     mem_probe[`SLAVE5_START_ADDR : `SLAVE5_END_ADDR+3] = `SLAVE_MEM_PROBE(5);
     mem_probe[`SLAVE6_START_ADDR : `SLAVE6_END_ADDR+3] = `SLAVE_MEM_PROBE(6);

   endtask : slave_mem_probe

endinterface : apb_if

//*******************************EOF*****************************************
