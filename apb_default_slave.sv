//---------------------------------------------------------------------//
// File : apb_slave.sv
// Date : May-13
//---------------------------------------------------------------------//
//typedef enum bit[1:0] { SETUP ,W_ENABLE,R_ENABLE} apb_slave_state_t; 
// Already defined in apb_slave

module apb_default_slave
#(
  parameter addrWidth = 32,
  parameter dataWidth = 32
)
(
  input                        clk,
  input                        rst_n,
  input        [addrWidth-1:0] paddr,
  input                        pwrite,
  input                        psel,
  input                        penable,
  input        [dataWidth-1:0] pwdata,
  output logic [dataWidth-1:0] prdata,
  output                       pready,
  output                       pslverr
);
  
 
  
  //parameter Depth = 1 << dataWidth;
  
  bit [dataWidth-1:0] mem [256];
apb_slave_state_t apb_st;

assign pready = 1'b1;
assign pslverr = 1'b1;

// SETUP -> ENABLE
always @(negedge rst_n or posedge clk) begin
  if (rst_n == 0) begin
    apb_st <= apb_slave_state_t'(0);
    prdata <= 0;
  end

  else begin
    case (apb_st)
      SETUP : begin
        // clear the prdata
        prdata <= 0;

        // Move to ENABLE when the psel is asserted
        if (psel && !penable) begin
          if (pwrite) begin
            apb_st <= W_ENABLE;
          end

          else begin
            apb_st <= R_ENABLE;
          end
        end
      end

      W_ENABLE : begin
        // write pwdata to memory
        if (psel && penable && pwrite) begin
          mem[paddr[7:0]] <= pwdata;
        end

        // return to SETUP
        apb_st <= SETUP;
      end

      R_ENABLE : begin
        // read prdata from memory
        if (psel && penable && !pwrite) begin
          prdata <= mem[paddr[7:0]];
        end

        // return to SETUP
        apb_st <= SETUP;
      end
    endcase
  end
end 


endmodule : apb_default_slave
