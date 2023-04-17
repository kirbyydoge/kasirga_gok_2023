`timescale 1ns/1ps

module csa64 (
   input  [63:0] op0_i,
   input  [63:0] op1_i,
   input  [63:0] op2_i,
   output [63:0] sum_o,
   output [63:0] carry_o
);

assign sum_o = op0_i ^ op1_i ^ op2_i;
assign carry_o = {(op0_i & op1_i) | (op1_i & op2_i) | (op0_i & op2_i), 1'b0};

endmodule