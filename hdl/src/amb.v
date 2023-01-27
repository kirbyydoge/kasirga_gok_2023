`timescale 1ns / 1ps

`include "mikroislem.vh"
`include "sabitler.vh"
`include "amb.vh"

module amb (
    input                       clk_i,
    input                       rstn_i,

    input   [`UOP_AMB_BIT-1:0]  islem_kod_i,
    input   [`VERI_BIT-1:0]     islem_islec1_i,
    input   [`VERI_BIT-1:0]     islem_islec2_i,

    output                      islem_esittir_o,
    output                      islem_kucuktur_o,
    output                      islem_kucuktur_isaretsiz_o,

    output  [`VERI_BIT-1:0]     islem_sonuc_o,
    output                      islem_gecerli_o
);

reg [`VERI_BIT-1:0] islem_sonuc_cmb;

reg [`VERI_BIT-1:0] islem_sonuc_r;
reg [`VERI_BIT-1:0] islem_sonuc_ns;

reg [`VERI_BIT-1:0] islem_temp0_cmb;
reg [`VERI_BIT-1:0] islem_temp1_cmb;
reg                 islem_flag0_cmb;

reg [5:0]           islem_sayac_r;
reg [5:0]           islem_sayac_ns;

reg                 islem_gecerli_cmb;

integer i;
always @* begin
    islem_sayac_ns = islem_sayac_r;
    islem_sonuc_ns = islem_sonuc_r;
    islem_gecerli_cmb = `HIGH;
    islem_sonuc_cmb = {`VERI_BIT{1'b0}};
    islem_temp0_cmb = {`VERI_BIT{1'b0}};
    islem_temp1_cmb = {`VERI_BIT{1'b0}};
    islem_flag0_cmb = `LOW;

    case (islem_kod_i)
    `UOP_AMB_ADD    : islem_sonuc_cmb = islem_islec1_i + islem_islec2_i;
    `UOP_AMB_SUB    : islem_sonuc_cmb = islem_islec1_i - islem_islec2_i;
    `UOP_AMB_AND    : islem_sonuc_cmb = islem_islec1_i & islem_islec2_i;
    `UOP_AMB_OR     : islem_sonuc_cmb = islem_islec1_i | islem_islec2_i;
    `UOP_AMB_XOR    : islem_sonuc_cmb = islem_islec1_i ^ islem_islec2_i;
    `UOP_AMB_SLL    : islem_sonuc_cmb = islem_islec1_i << islem_islec2_i;
    `UOP_AMB_SLT    : islem_sonuc_cmb = islem_kucuktur_o ? {{`VERI_BIT-1{1'b0}}, 1'b1} : {`VERI_BIT{1'b0}};
    `UOP_AMB_SLTU   : islem_sonuc_cmb = islem_kucuktur_isaretsiz_o ? {{`VERI_BIT-1{1'b0}}, 1'b1}: {`VERI_BIT{1'b0}};
    `UOP_AMB_HMDST: begin
        islem_temp1_cmb = islem_islec1_i ^ islem_islec2_i;
        for (i = 0; i < `HMDST_STEP; i = i + 1) begin
            islem_temp0_cmb = islem_temp0_cmb + islem_temp1_cmb[islem_sayac_r * `HMDST_STEP + i];
        end
        islem_sonuc_ns = islem_sonuc_r + islem_temp0_cmb;
        islem_sayac_ns = islem_sayac_r + 5'b1;
        islem_sonuc_cmb = islem_sonuc_r;
        islem_gecerli_cmb = islem_sayac_r == (`VERI_BIT / `HMDST_STEP);
    end
    `UOP_AMB_PKG: begin
        // assert (`VERI_BIT % 2 == 0)
        islem_sonuc_cmb = {islem_islec2_i[`VERI_BIT/2 +: `VERI_BIT/2], islem_islec1_i[0 +: `VERI_BIT/2]};
    end
    `UOP_AMB_RVRS: begin
        for (i = 0; i < `VERI_BIT; i = i + 1) begin
            islem_sonuc_cmb[i] = islem_islec1_i[`VERI_BIT - i - 1];
        end
    end
    `UOP_AMB_SLADD: begin
        // TODO: Toplama birimi kullanilacak mi?
        islem_sonuc_cmb = {islem_islec1_i[`VERI_BIT-2:0], 1'b0} + islem_islec2_i;
    end
    `UOP_AMB_CNTZ: begin
        // assert (`VERI_BIT % `CNTZ_STEP == 0)
        islem_flag0_cmb = `HIGH;
        for (i = 0; i < `CNTZ_STEP; i = i + 1) begin
            islem_temp0_cmb = islem_temp0_cmb + (~islem_islec1_i[islem_sayac_r * `CNTZ_STEP + i] && islem_flag0_cmb);
            if (islem_islec1_i[islem_sayac_r * `CNTZ_STEP + i]) begin
                islem_flag0_cmb = `LOW;
            end
        end
        islem_sonuc_ns = islem_sonuc_r + islem_temp0_cmb;
        islem_sayac_ns = islem_sayac_r + 5'b1;
        islem_sonuc_cmb = islem_sonuc_r;
        islem_gecerli_cmb = islem_sayac_r == (`VERI_BIT / `CNTZ_STEP);
    end
    `UOP_AMB_CNTP: begin
        // assert (`VERI_BIT % `CNTP_STEP == 0)
        for (i = 0; i < `CNTP_STEP; i = i + 1) begin
            islem_temp0_cmb = islem_temp0_cmb + islem_islec1_i[islem_sayac_r * `CNTP_STEP + i];
        end
        islem_sonuc_ns = islem_sonuc_r + islem_temp0_cmb;
        islem_sayac_ns = islem_sayac_r + 5'b1;
        islem_sonuc_cmb = islem_sonuc_r;
        islem_gecerli_cmb = islem_sayac_r == (`VERI_BIT / `CNTP_STEP);
    end
    endcase
end

always @(posedge clk_i) begin
    if (!rstn_i) begin
        islem_sayac_r <= {`CTR_BIT{1'b0}};
        islem_sonuc_r <= {`VERI_BIT{1'b0}};
    end
    else begin
        islem_sayac_r <= islem_gecerli_o ? {`CTR_BIT{1'b0}} : islem_sayac_ns;
        islem_sonuc_r <= islem_gecerli_o ? {`VERI_BIT{1'b0}} : islem_sonuc_ns;
    end
end

assign islem_sonuc_o = islem_sonuc_cmb;
assign islem_esittir_o = islem_islec1_i == islem_islec2_i;
assign islem_kucuktur_o = $signed(islem_islec1_i) < $signed(islem_islec2_i);
assign islem_kucuktur_isaretsiz_o = islem_islec1_i < islem_islec2_i;
assign islem_gecerli_o = islem_gecerli_cmb;

endmodule