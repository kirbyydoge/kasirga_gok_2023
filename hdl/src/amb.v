`timescale 1ns / 1ps

`include "mikroislem.vh"
`include "sabitler.vh"

module amb (
    input                       clk_i,

    input   [`UOP_AMB_BIT-1:0]  islem_kod_i,
    input   [`VERI_BIT-1:0]     islem_islec1_i,
    input   [`VERI_BIT-1:0]     islem_islec2_i,

    output                      islem_esittir_o,
    output                      islem_buyuktur_o,

    output  [`VERI_BIT-1:0]     islem_sonuc_o
);

reg [`VERI_BIT-1:0] islem_sonuc_cmb;

always @* begin
    case (islem_kod_i)
    `UOP_AMB_ADD    : islem_sonuc_cmb = islem_islec1_i + islem_islec2_i;
    `UOP_AMB_SUB    : islem_sonuc_cmb = islem_islec1_i - islem_islec2_i;
    `UOP_AMB_AND    : islem_sonuc_cmb = islem_islec1_i & islem_islec2_i;
    `UOP_AMB_OR     : islem_sonuc_cmb = islem_islec1_i | islem_islec2_i;
    `UOP_AMB_XOR    : islem_sonuc_cmb = islem_islec1_i ^ islem_islec2_i;
    `UOP_AMB_SLL    : islem_sonuc_cmb = islem_islec1_i << islem_islec2_i;
    `UOP_AMB_NOP    : islem_sonuc_cmb = {`VERI_BIT{1'b0}};
    endcase
end

assign islem_sonuc_o = islem_sonuc_cmb;
assign islem_esittir_o = islem_islec1_i == islem_islec2_i;
assign islem_buyuktur_o = $signed(islem_islec1_i) > $signed(islem_islec2_i);

endmodule