// OpenRAM SRAM model
// Words: 128
// Word size: 336
// Write size: 8

(* blackbox *)
module sram_336x128(
`ifdef USE_POWER_PINS
      vccd1,
      vssd1,
`endif
// Port 0: RW
      clk0,csb0,web0,wmask0,spare_wen0,addr0,din0,dout0
   );

   parameter NUM_WMASKS = 42 ;
   parameter DATA_WIDTH = 337 ;
   parameter ADDR_WIDTH = 8 ;
   parameter RAM_DEPTH = 1 << ADDR_WIDTH;
   // FIXME: This delay is arbitrary.
   parameter DELAY = 3 ;
   parameter VERBOSE = 1 ; //Set to 0 to only display warnings
   parameter T_HOLD = 1 ; //Delay to hold dout value after posedge. Value is arbitrary

`ifdef USE_POWER_PINS
      inout vccd1;
      inout vssd1;
`endif
   input  clk0; // clock
   input   csb0; // active low chip select
   input  web0; // active low write control
   input [ADDR_WIDTH-1:0]  addr0;
   input [NUM_WMASKS-1:0]   wmask0; // write mask
   input           spare_wen0; // spare mask
   input [DATA_WIDTH-1:0]  din0;
   output [DATA_WIDTH-1:0] dout0;
endmodule
