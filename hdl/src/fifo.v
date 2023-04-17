`timescale 1ns/1ps
`include "sabitler.vh"

module fifo #(
   parameter DATA_WIDTH = 32,
   parameter DATA_DEPTH = 8
)(
   input                       clk_i,
   input                       rstn_i,

   input   [DATA_WIDTH-1:0]    data_i,
   input                       wr_en_i,

   output  [DATA_WIDTH-1:0]    data_o,
   input                       rd_en_i,
   
   output                      full_o,
   output                      empty_o
);

reg [DATA_WIDTH-1:0] buf_r [0:DATA_DEPTH-1];
reg [DATA_WIDTH-1:0] buf_ns [0:DATA_DEPTH-1];

reg full_r;
reg full_ns;

reg [$clog2(DATA_DEPTH)-1:0] ptr_rd_r;
reg [$clog2(DATA_DEPTH)-1:0] ptr_rd_ns;
reg [$clog2(DATA_DEPTH)-1:0] ptr_wr_r;
reg [$clog2(DATA_DEPTH)-1:0] ptr_wr_ns;

integer i;
always @* begin
   for (i = 0; i < DATA_DEPTH; i = i + 1) begin
      buf_ns[i] = buf_r[i];
   end
   ptr_rd_ns = ptr_rd_r;
   ptr_wr_ns = ptr_wr_r;
   full_ns = full_r;

   if (rd_en_i && !empty_o) begin
      ptr_rd_ns = (ptr_rd_r + 1) % DATA_DEPTH;
      full_ns = `LOW;
   end

   if (wr_en_i && !full_o) begin
      buf_ns[ptr_wr_r] = data_i;
      ptr_wr_ns = (ptr_wr_r + 1) % DATA_DEPTH;
      full_ns = !rd_en_i && ((ptr_wr_r + 1) % DATA_DEPTH) == ptr_rd_r;
   end
end

always @(posedge clk_i) begin
   if (!rstn_i) begin
      ptr_rd_r <= 0;
      ptr_wr_r <= 0;
      full_r <= 0;
   end
   else begin
      for (i = 0; i < DATA_DEPTH; i = i + 1) begin
         buf_r[i] <= buf_ns[i];
      end
      ptr_rd_r <= ptr_rd_ns;
      ptr_wr_r <= ptr_wr_ns;
      full_r <= full_ns;
   end
end

assign data_o = buf_r[ptr_rd_r];
assign full_o = full_r;
assign empty_o = (ptr_rd_r == ptr_wr_r) && !full_r;

endmodule