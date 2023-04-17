`timescale 1ns / 1ps

`include "mikroislem.vh"
`include "sabitler.vh"
`include "amb.vh"

module amb (
    input                       clk_i,
    input                       rstn_i,

    input   [`UOP_AMB_BIT-1:0]  islem_kod_i,
    input                       islem_kod_gecerli_i,
    input   [`VERI_BIT-1:0]     islem_islec1_i,
    input   [`VERI_BIT-1:0]     islem_islec2_i,

    output                      islem_esittir_o,
    output                      islem_kucuktur_o,
    output                      islem_kucuktur_isaretsiz_o,

    output  [`VERI_BIT-1:0]     islem_sonuc_o,
    output                      islem_gecerli_o
);

localparam KOD_DIV  = 4'h1; 
localparam KOD_DIVU = 4'h2; 
localparam KOD_REM  = 4'h4; 
localparam KOD_REMU = 4'h8;

reg [`VERI_BIT-1:0]     islem_sonuc_cmb;

reg [`VERI_BIT-1:0]     islem_sonuc_r;
reg [`VERI_BIT-1:0]     islem_sonuc_ns;

reg [`VERI_BIT-1:0]     islem_temp0_cmb;
reg [`VERI_BIT-1:0]     islem_temp1_cmb;
reg                     islem_flag0_cmb;

reg                     islem_sflag0_r;
reg                     islem_sflag0_ns;

reg [5:0]               islem_sayac_r;
reg [5:0]               islem_sayac_ns;

reg                     islem_gecerli_cmb;

reg  [`VERI_BIT-1:0]    toplayici_is0_cmb;
reg  [`VERI_BIT-1:0]    toplayici_is1_cmb;
wire [`VERI_BIT-1:0]    toplayici_sonuc_w;

reg  [`VERI_BIT-1:0]    carpici_is0_cmb;
reg                     carpici_is0_isaretli_cmb;
reg  [`VERI_BIT-1:0]    carpici_is1_cmb;
reg                     carpici_is1_isaretli_cmb;
reg                     carpici_gecerli_cmb;
wire [2*`VERI_BIT-1:0]  carpici_sonuc_w;
wire                    carpici_sonuc_gecerli_w;

reg  [3:0]              bolucu_kod_cmb;
reg  [`VERI_BIT-1:0]    bolucu_is0_cmb;
reg  [`VERI_BIT-1:0]    bolucu_is1_cmb;
reg                     bolucu_gecerli_cmb;
wire [`VERI_BIT-1:0]    bolucu_sonuc_w;
wire                    bolucu_sonuc_gecerli_w;

wire [`VERI_BIT-1:0]    negatif_islec2_w;

integer i;
always @* begin
    islem_sayac_ns = islem_sayac_r;
    islem_sonuc_ns = islem_sonuc_r;
    islem_gecerli_cmb = `HIGH;
    islem_sonuc_cmb = {`VERI_BIT{1'b0}};
    islem_temp0_cmb = {`VERI_BIT{1'b0}};
    islem_temp1_cmb = {`VERI_BIT{1'b0}};
    islem_flag0_cmb = `LOW;
    islem_sflag0_ns = islem_sflag0_r;
    toplayici_is0_cmb = islem_islec1_i;
    toplayici_is1_cmb = islem_islec2_i;

    carpici_is0_cmb = islem_islec1_i;
    carpici_is1_cmb = islem_islec2_i;
    carpici_is0_isaretli_cmb = `HIGH;
    carpici_is1_isaretli_cmb = `HIGH;
    carpici_gecerli_cmb = `LOW;

    bolucu_kod_cmb = 0;
    bolucu_is0_cmb = islem_islec1_i;
    bolucu_is1_cmb = islem_islec2_i;
    bolucu_gecerli_cmb = `LOW;

    case (islem_kod_i)
    `UOP_AMB_AND    : islem_sonuc_cmb = islem_islec1_i & islem_islec2_i;
    `UOP_AMB_OR     : islem_sonuc_cmb = islem_islec1_i | islem_islec2_i;
    `UOP_AMB_XOR    : islem_sonuc_cmb = islem_islec1_i ^ islem_islec2_i;
    `UOP_AMB_SLL    : islem_sonuc_cmb = islem_islec1_i << islem_islec2_i[4:0];
    `UOP_AMB_SRA    : islem_sonuc_cmb = $signed(islem_islec1_i) >>> islem_islec2_i[4:0];
    `UOP_AMB_SRL    : islem_sonuc_cmb = islem_islec1_i >> islem_islec2_i[4:0];
    `UOP_AMB_SLT    : islem_sonuc_cmb = islem_kucuktur_o ? {{`VERI_BIT-1{1'b0}}, 1'b1} : {`VERI_BIT{1'b0}};
    `UOP_AMB_SLTU   : islem_sonuc_cmb = islem_kucuktur_isaretsiz_o ? {{`VERI_BIT-1{1'b0}}, 1'b1}: {`VERI_BIT{1'b0}};
    `UOP_AMB_MUL    : begin
        carpici_is0_cmb = islem_islec1_i;
        carpici_is1_cmb = islem_islec2_i;
        carpici_gecerli_cmb = islem_sayac_r == 5'b0 && islem_kod_gecerli_i;
        islem_sonuc_cmb = carpici_sonuc_w[0 +: `VERI_BIT];
        islem_gecerli_cmb = carpici_sonuc_gecerli_w;

        islem_sayac_ns = islem_sayac_r + 5'b1;
    end
    `UOP_AMB_MULH   : begin
        carpici_is0_cmb = islem_islec1_i;
        carpici_is1_cmb = islem_islec2_i;
        carpici_gecerli_cmb = islem_sayac_r == 5'b0 && islem_kod_gecerli_i;
        islem_sonuc_cmb = carpici_sonuc_w[`VERI_BIT +: `VERI_BIT];
        islem_gecerli_cmb = carpici_sonuc_gecerli_w;

        islem_sayac_ns = islem_sayac_r + 5'b1;
    end
    `UOP_AMB_MULHU   : begin
        carpici_is0_cmb = islem_islec1_i;
        carpici_is1_cmb = islem_islec2_i;
        carpici_is0_isaretli_cmb = `LOW;
        carpici_is1_isaretli_cmb = `LOW;
        carpici_gecerli_cmb = islem_sayac_r == 5'b0 && islem_kod_gecerli_i;
        islem_sonuc_cmb = carpici_sonuc_w[`VERI_BIT +: `VERI_BIT];
        islem_gecerli_cmb = carpici_sonuc_gecerli_w;

        islem_sayac_ns = islem_sayac_r + 5'b1;
    end
    `UOP_AMB_MULHSU   : begin
        carpici_is0_cmb = islem_islec1_i;
        carpici_is1_cmb = islem_islec2_i;
        carpici_is0_isaretli_cmb = `HIGH;
        carpici_is1_isaretli_cmb = `LOW;
        carpici_gecerli_cmb = islem_sayac_r == 5'b0 && islem_kod_gecerli_i;
        islem_sonuc_cmb = carpici_sonuc_w[`VERI_BIT +: `VERI_BIT];
        islem_gecerli_cmb = carpici_sonuc_gecerli_w;

        islem_sayac_ns = islem_sayac_r + 5'b1;
    end
    `UOP_AMB_DIV    : begin
        if (islem_islec2_i == 0) begin
            islem_sonuc_cmb = {`VERI_BIT{1'b1}};
            islem_gecerli_cmb = `HIGH;
        end
        else begin
            bolucu_kod_cmb = KOD_DIV;
            bolucu_is0_cmb = islem_islec1_i;
            bolucu_is1_cmb = islem_islec2_i;
            bolucu_gecerli_cmb = islem_sayac_r == 5'b0 && islem_kod_gecerli_i;
            islem_sonuc_cmb = bolucu_sonuc_w;
            islem_gecerli_cmb = bolucu_sonuc_gecerli_w;

            islem_sayac_ns = islem_sayac_r + 5'b1;
        end
    end
    `UOP_AMB_DIVU   : begin
        if (islem_islec2_i == 0) begin
            islem_sonuc_cmb = {`VERI_BIT{1'b1}};
            islem_gecerli_cmb = `HIGH;
        end
        else begin
            bolucu_kod_cmb = KOD_DIVU;
            bolucu_is0_cmb = islem_islec1_i;
            bolucu_is1_cmb = islem_islec2_i;
            bolucu_gecerli_cmb = islem_sayac_r == 5'b0 && islem_kod_gecerli_i;
            islem_sonuc_cmb = bolucu_sonuc_w;
            islem_gecerli_cmb = bolucu_sonuc_gecerli_w;

            islem_sayac_ns = islem_sayac_r + 5'b1;
        end
    end
    `UOP_AMB_REM    : begin
        bolucu_kod_cmb = KOD_REM;
        bolucu_is0_cmb = islem_islec1_i;
        bolucu_is1_cmb = islem_islec2_i;
        bolucu_gecerli_cmb = islem_sayac_r == 5'b0 && islem_kod_gecerli_i;
        islem_sonuc_cmb = bolucu_sonuc_w;
        islem_gecerli_cmb = bolucu_sonuc_gecerli_w;

        islem_sayac_ns = islem_sayac_r + 5'b1;
    end
    `UOP_AMB_REMU   : begin
        bolucu_kod_cmb = KOD_REMU;
        bolucu_is0_cmb = islem_islec1_i;
        bolucu_is1_cmb = islem_islec2_i;
        bolucu_gecerli_cmb = islem_sayac_r == 5'b0 && islem_kod_gecerli_i;
        islem_sonuc_cmb = bolucu_sonuc_w;
        islem_gecerli_cmb = bolucu_sonuc_gecerli_w;

        islem_sayac_ns = islem_sayac_r + 5'b1;
    end
    `UOP_AMB_ADD    : begin
        toplayici_is0_cmb = islem_islec1_i;
        toplayici_is1_cmb = islem_islec2_i;
        islem_sonuc_cmb = toplayici_sonuc_w;
    end
    `UOP_AMB_SUB    : begin 
        toplayici_is0_cmb = islem_islec1_i;
        toplayici_is1_cmb = negatif_islec2_w;
        islem_sonuc_cmb = toplayici_sonuc_w;
    end
    `UOP_AMB_HMDST: begin
        islem_temp1_cmb = islem_islec1_i ^ islem_islec2_i;
        for (i = 0; i < `HMDST_STEP; i = i + 1) begin
            islem_temp0_cmb = islem_temp0_cmb + islem_temp1_cmb[islem_sayac_r * `HMDST_STEP + i];
        end
        toplayici_is0_cmb = islem_sonuc_r;
        toplayici_is1_cmb = islem_temp0_cmb;
        islem_sonuc_ns = toplayici_sonuc_w;
        islem_sayac_ns = islem_sayac_r + 5'b1;
        islem_sonuc_cmb = islem_sonuc_r;
        islem_gecerli_cmb = islem_sayac_r == (`VERI_BIT / `HMDST_STEP);
    end
    `UOP_AMB_PKG: begin
        // assert (`VERI_BIT % 2 == 0)
        islem_sonuc_cmb = {islem_islec2_i[0 +: `VERI_BIT/2], islem_islec1_i[0 +: `VERI_BIT/2]};
    end
    `UOP_AMB_RVRS: begin
        // for (i = 0; i < `VERI_BIT; i = i + 1) begin
        //     islem_sonuc_cmb[i] = islem_islec1_i[`VERI_BIT - i - 1];
        // end
        islem_sonuc_cmb = {islem_islec1_i[7:0], islem_islec1_i[15:8], islem_islec1_i[23:16], islem_islec1_i[31:24]};
    end
    `UOP_AMB_SLADD: begin
        // TODO: Toplama birimi kullanilacak mi?
        islem_sonuc_cmb = {islem_islec1_i[`VERI_BIT-2:0], 1'b0} + islem_islec2_i;
    end
    `UOP_AMB_CNTZ: begin
        // assert (`VERI_BIT % `CNTZ_STEP == 0)
        islem_sflag0_ns = islem_sayac_r == 5'b0 ? `HIGH : islem_sflag0_r;
        for (i = 0; i < `CNTZ_STEP; i = i + 1) begin
            if (islem_islec1_i[islem_sayac_r * `CNTZ_STEP + i]) begin
                islem_sflag0_ns = `LOW;
            end
            islem_temp0_cmb = islem_temp0_cmb + islem_sflag0_ns;
        end
        toplayici_is0_cmb = islem_sonuc_r;
        toplayici_is1_cmb = islem_temp0_cmb;
        islem_sonuc_ns = toplayici_sonuc_w;
        islem_sayac_ns = islem_sayac_r + 5'b1;
        islem_sonuc_cmb = islem_sonuc_r;
        islem_gecerli_cmb = islem_sayac_r == (`VERI_BIT / `CNTZ_STEP);
    end
    `UOP_AMB_CNTP: begin
        // assert (`VERI_BIT % `CNTP_STEP == 0)
        for (i = 0; i < `CNTP_STEP; i = i + 1) begin
            islem_temp0_cmb = islem_temp0_cmb + islem_islec1_i[islem_sayac_r * `CNTP_STEP + i];
        end
        toplayici_is0_cmb = islem_sonuc_r;
        toplayici_is1_cmb = islem_temp0_cmb;
        islem_sonuc_ns = toplayici_sonuc_w;
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
        islem_sflag0_r <= `LOW;
    end
    else begin
        islem_sayac_r <= islem_gecerli_o || !islem_kod_gecerli_i ? {`CTR_BIT{1'b0}} : islem_sayac_ns;
        islem_sonuc_r <= islem_gecerli_o || !islem_kod_gecerli_i ? {`VERI_BIT{1'b0}} : islem_sonuc_ns;
        islem_sflag0_r <= islem_sflag0_ns;
    end
end

toplayici topla (
    .islec0_i ( toplayici_is0_cmb ),
    .islec1_i ( toplayici_is1_cmb ),
    .carry_i  ( 1'b0 ),
    .toplam_o ( toplayici_sonuc_w )
);

`ifdef USE_MUL_PIPE
    carpici_pipe3 carp (
        .clk_i             ( clk_i ),
        .islec0_i          ( carpici_is0_cmb ),
        .islec0_isaretli_i ( carpici_is0_isaretli_cmb ),
        .islec1_i          ( carpici_is1_cmb ),
        .islec1_isaretli_i ( carpici_is1_isaretli_cmb ),
        .islem_gecerli_i   ( carpici_gecerli_cmb ),
        .carpim_o          ( carpici_sonuc_w ),
        .carpim_gecerli_o  ( carpici_sonuc_gecerli_w )
    );
`else
    carpici carp (
        .islec0_i          ( carpici_is0_cmb ),
        .islec0_isaretli_i ( carpici_is0_isaretli_cmb ),
        .islec1_i          ( carpici_is1_cmb ),
        .islec1_isaretli_i ( carpici_is1_isaretli_cmb ),
        .carpim_o          ( carpici_sonuc_w )
    );
    assign carpici_sonuc_gecerli_w = carpici_gecerli_cmb;
`endif

bolucu bol (
    .clk_i             ( clk_i ),
    .rst_i             ( ~rstn_i ),
    .islev_kodu_i      ( bolucu_kod_cmb ),
    .islec0_i          ( bolucu_is0_cmb ),
    .islec1_i          ( bolucu_is1_cmb ),
    .islem_gecerli_i   ( bolucu_gecerli_cmb ),
    .bolum_gecerli_o   ( bolucu_sonuc_gecerli_w ),
    .bolum_o           ( bolucu_sonuc_w )
);

assign islem_sonuc_o = islem_sonuc_cmb;
assign islem_esittir_o = islem_islec1_i == islem_islec2_i;
assign islem_kucuktur_o = $signed(islem_islec1_i) < $signed(islem_islec2_i);
assign islem_kucuktur_isaretsiz_o = islem_islec1_i < islem_islec2_i;
assign islem_gecerli_o = islem_gecerli_cmb;
assign negatif_islec2_w = (~islem_islec2_i) + 1'b1;

endmodule