`timescale 1ns / 1ps

`include "mikroislem.vh"
`include "sabitler.vh"

module amb (
    input                       clk_i,

    input   [`UOP_AMB_BIT-1:0]  islem_kod_i,
    input   [`VERI_BIT-1:0]     islem_islec1_i,
    input   [`VERI_BIT-1:0]     islem_islec2_i,

    output                      islem_esittir_o,
    output                      islem_kucuktur_o,

    output  [`VERI_BIT-1:0]     islem_sonuc_o
);

reg [`VERI_BIT-1:0] islem_sonuc_cmb;
wire                islem_kucuktur_isaretsiz_w;

reg [`VERI_BIT-1:0] islem_temp0_cmb;
reg                 islem_flag0_cmb;

integer i;
always @* begin
    case (islem_kod_i)
    `UOP_AMB_ADD    : islem_sonuc_cmb = islem_islec1_i + islem_islec2_i;
    `UOP_AMB_SUB    : islem_sonuc_cmb = islem_islec1_i - islem_islec2_i;
    `UOP_AMB_AND    : islem_sonuc_cmb = islem_islec1_i & islem_islec2_i;
    `UOP_AMB_OR     : islem_sonuc_cmb = islem_islec1_i | islem_islec2_i;
    `UOP_AMB_XOR    : islem_sonuc_cmb = islem_islec1_i ^ islem_islec2_i;
    `UOP_AMB_SLL    : islem_sonuc_cmb = islem_islec1_i << islem_islec2_i;
    `UOP_AMB_SLT    : islem_sonuc_cmb = islem_kucuktur_o ? {{`VERI_BIT-1{1'b0}}, 1'b1} : {`VERI_BIT{1'b0}};
    `UOP_AMB_SLTU   : islem_sonuc_cmb = islem_kucuktur_isaretsiz_w ? {{`VERI_BIT-1{1'b0}}, 1'b1}: {`VERI_BIT{1'b0}};
    `UOP_AMB_HMDST: begin
        islem_temp0_cmb = islem_islec1_i ^ islem_islec2_i;
        for (i = 0; i < `VERI_BIT; i = i + 1) begin
            islem_sonuc_cmb = islem_sonuc_cmb + islem_temp0_cmb[i];
        end
    end
    `UOP_AMB_PKG: begin
        // assert (`VERI_BIT % 2 == 0)
        islem_sonuc_cmb = {islem_islec2_i[`VERI_BIT/2 +: `VERI_BIT/2], islem_islec1_i[0 +: `VERI_BIT/2]};
    end
    `UOP_AMB_RVRS: begin
        for (i = 0; i < `VERI_BYTE; i = i + 1) begin
            islem_sonuc_cmb[i] = islem_islec1_i[`VERI_BYTE - i - 1];
        end
    end
    `UOP_AMB_SLADD: begin
        // TODO: Toplama birimi kullanilacak mi?
        islem_sonuc_cmb = {islem_islec1_i[`VERI_BIT-2:0], 1'b0} + islem_islec2_i;
    end
    `UOP_AMB_CNTZ: begin
        islem_flag0_cmb = `HIGH;
        for (i = 0; i < `VERI_BIT; i = i + 1) begin
            islem_sonuc_cmb = islem_sonuc_cmb + (~islem_islec1_i[i] && islem_flag0_cmb);
            if (islem_islec1_i[i]) begin
                islem_flag0_cmb = `LOW;
            end
        end
    end
    `UOP_AMB_CNTP: begin
        for (i = 0; i < `VERI_BIT; i = i + 1) begin
            islem_sonuc_cmb = islem_sonuc_cmb + islem_islec1_i[i];
        end
    end
    default         : islem_sonuc_cmb = {`VERI_BIT{1'b0}};
    endcase
end

assign islem_sonuc_o = islem_sonuc_cmb;
assign islem_esittir_o = islem_islec1_i == islem_islec2_i;
assign islem_kucuktur_o = $signed(islem_islec1_i) < $signed(islem_islec2_i);
assign islem_kucuktur_isaretsiz_w = islem_islec1_i < islem_islec2_i;

endmodule