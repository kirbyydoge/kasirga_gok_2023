`timescale 1ns / 1ps

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