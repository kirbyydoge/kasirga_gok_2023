`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/14/2023 05:15:15 PM
// Design Name: 
// Module Name: toplayici_33
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module toplayici_33(
    input   [32:0]  islec0_i,
    input   [32:0]  islec1_i,
    output  [32:0]  toplam_o
);


toplayici utt(
    .islec0_i(islec0_i[32:1]),
    .islec1_i(islec1_i[32:1]),
    .carry_i(islec0_i[0] && islec1_i[0]),
    .toplam_o({toplam_o[32:1]})
    );
 

assign toplam_o[0]=islec0_i[0] ^ islec1_i[0];

endmodule