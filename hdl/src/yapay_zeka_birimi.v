`timescale 1ns/1ps

`include "sabitler.vh"
`include "mikroislem.vh"

module yapay_zeka_birimi (
    input                       clk_i,
    input                       rstn_i,

    input   [`UOP_YZB_BIT-1:0]  islem_kod_i,
    input   [`VERI_BIT-1:0]     islem_islec1_i,
    input   [`VERI_BIT-1:0]     islem_islec2_i,

    output  [`VERI_BIT-1:0]     islem_sonuc_o,
    output                      islem_gecerli_o
);

localparam                  HAZIR = 'd0;
localparam                  CARP = 'd1;

integer i;

reg  [`VERI_BIT-1:0]        islem_sonuc_r;
reg  [`VERI_BIT-1:0]        islem_sonuc_ns;

reg                         islem_gecerli_cmb;

reg [`VERI_BIT-1:0]         bellek_x_r [0:`N_CNN_YAZMAC-1];
reg [`VERI_BIT-1:0]         bellek_x_ns [0:`N_CNN_YAZMAC-1];

reg [`VERI_BIT-1:0]         bellek_w_r [0:`N_CNN_YAZMAC-1];
reg [`VERI_BIT-1:0]         bellek_w_ns [0:`N_CNN_YAZMAC-1];

reg [`CNN_YAZMAC_BIT-1:0]   sayac_x_r;
reg [`CNN_YAZMAC_BIT-1:0]   sayac_x_ns;

reg [`CNN_YAZMAC_BIT-1:0]   sayac_w_r;
reg [`CNN_YAZMAC_BIT-1:0]   sayac_w_ns;

reg [`CNN_YAZMAC_BIT-1:0]   sayac_sonuc_r;
reg [`CNN_YAZMAC_BIT-1:0]   sayac_sonuc_ns;

reg [`CNN_YAZMAC_BIT-1:0]   sayac_istek_r;
reg [`CNN_YAZMAC_BIT-1:0]   sayac_istek_ns;

wire [`CNN_YAZMAC_BIT-1:0]  sayac_min_w;

localparam                  DURUM_BOSTA = 'd0;
localparam                  DURUM_ISTEK = 'd1;

reg                         spekulatif_durum_r;
reg                         spekulatif_durum_ns;

reg  [`VERI_BIT-1:0]        toplayici_is0_cmb;
reg  [`VERI_BIT-1:0]        toplayici_is1_cmb;
wire [`VERI_BIT-1:0]        toplayici_sonuc_w;

reg  [`VERI_BIT-1:0]        carpici_is0_cmb;
reg  [`VERI_BIT-1:0]        carpici_is1_cmb;
reg                         carpici_gecerli_cmb;
wire [2*`VERI_BIT-1:0]      carpici_sonuc_w;
wire                        carpici_sonuc_gecerli_w;

always @* begin
    for (i = 0; i < `N_CNN_YAZMAC; i = i + 1) begin
        bellek_x_ns[i] = bellek_x_r[i];
        bellek_w_ns[i] = bellek_w_r[i];
    end
    sayac_x_ns = sayac_x_r;
    sayac_w_ns = sayac_w_r;
    sayac_sonuc_ns = sayac_sonuc_r;
    sayac_istek_ns = sayac_istek_r;
    islem_sonuc_ns = islem_sonuc_r;
    islem_gecerli_cmb = `HIGH;
    toplayici_is0_cmb = islem_sonuc_r;
    toplayici_is1_cmb = carpici_sonuc_w[0 +: `VERI_BIT];
    carpici_is0_cmb = bellek_x_r[sayac_istek_r];
    carpici_is1_cmb = bellek_w_r[sayac_istek_r];
    carpici_gecerli_cmb = `LOW;

    case(islem_kod_i)
    `UOP_YZB_LDX_OP1: begin
        bellek_x_ns[sayac_x_r] = islem_islec1_i;
        sayac_x_ns = sayac_x_r + 1;
    end
    `UOP_YZB_LDX_ALL: begin
        bellek_x_ns[sayac_x_r] = islem_islec1_i;
        bellek_x_ns[sayac_x_r + 1] = islem_islec2_i;
        sayac_x_ns = sayac_x_r + 2;
    end
    `UOP_YZB_LDW_OP1: begin
        bellek_w_ns[sayac_w_r] = islem_islec1_i;
        sayac_w_ns = sayac_w_r + 1;
    end
    `UOP_YZB_LDW_ALL: begin
        bellek_w_ns[sayac_w_r] = islem_islec1_i;
        bellek_w_ns[sayac_w_r + 1] = islem_islec2_i;
        sayac_x_ns = sayac_w_r + 2;
    end
    `UOP_YZB_CLRX: begin
        sayac_x_ns = {`CNN_YAZMAC_BIT{1'b0}};
        sayac_sonuc_ns = {`CNN_YAZMAC_BIT{1'b0}}; // Spekulatif carpimlari geri sar
        sayac_istek_ns = {`CNN_YAZMAC_BIT{1'b0}};
        islem_sonuc_ns = {`VERI_BIT{1'b0}};
    end
    `UOP_YZB_CLRW: begin
        sayac_w_ns = {`CNN_YAZMAC_BIT{1'b0}};
        sayac_sonuc_ns = {`CNN_YAZMAC_BIT{1'b0}}; // Spekulatif carpimlari geri sar
        sayac_istek_ns = {`CNN_YAZMAC_BIT{1'b0}};
        islem_sonuc_ns = {`VERI_BIT{1'b0}};
    end
    `UOP_YZB_RUN: begin
        islem_gecerli_cmb = sayac_sonuc_r == sayac_min_w;
    end
    endcase

    case(spekulatif_durum_r)
    DURUM_BOSTA: begin
        if (sayac_sonuc_r < sayac_min_w) begin
            carpici_gecerli_cmb = `HIGH;
            spekulatif_durum_ns = DURUM_ISTEK;
        end
    end
    DURUM_ISTEK: begin
        if (carpici_sonuc_gecerli_w) begin
            islem_sonuc_ns = toplayici_sonuc_w;
            sayac_sonuc_ns = sayac_sonuc_r + 1;
            if (sayac_istek_r < sayac_min_w) begin
                carpici_gecerli_cmb = `HIGH;
                spekulatif_durum_ns = DURUM_ISTEK;
            end
            else begin
                spekulatif_durum_ns = DURUM_BOSTA;
            end
        end
    end
    endcase
end

always @(posedge clk_i) begin
    if (!rstn_i) begin
        for (i = 0; i < `N_CNN_YAZMAC; i = i + 1) begin
            bellek_x_r[i] <= {`VERI_BIT{1'b0}};
            bellek_w_r[i] <= {`VERI_BIT{1'b0}};
        end
        sayac_x_r <= {`CNN_YAZMAC_BIT{1'b0}};
        sayac_w_r <= {`CNN_YAZMAC_BIT{1'b0}};
        sayac_sonuc_r <= {`CNN_YAZMAC_BIT{1'b0}};
        sayac_istek_r <= {`CNN_YAZMAC_BIT{1'b0}};
        islem_sonuc_r <= {`VERI_BIT{1'b0}};
        spekulatif_durum_r <= DURUM_BOSTA;
    end
    else begin
        for (i = 0; i < `N_CNN_YAZMAC; i = i + 1) begin
            bellek_x_r[i] <= bellek_x_ns[i];
            bellek_w_r[i] <= bellek_w_ns[i];
        end
        sayac_x_r <= sayac_x_ns;
        sayac_w_r <= sayac_w_ns;
        sayac_sonuc_r <= sayac_sonuc_ns;
        sayac_istek_r <= sayac_istek_ns;
        islem_sonuc_r <= islem_sonuc_ns;
        spekulatif_durum_r <= spekulatif_durum_ns;
    end
end

carpici carp (
    .clk_i            ( clk_i ),
    .islec0_i         ( carpici_is0_cmb ),
    .islec1_i         ( carpici_is1_cmb ),
    .islem_gecerli_i  ( carpici_gecerli_cmb ),
    .carpim_o         ( carpici_sonuc_w ),
    .carpim_gecerli_o ( carpici_sonuc_gecerli_w )
);

toplayici topla (
    .islec0_i ( toplayici_is0_cmb ),
    .islec1_i ( toplayici_is1_cmb ),
    .carry_i  ( 1'b0 ),
    .toplam_o ( toplayici_sonuc_w )
);

assign sayac_min_w = sayac_x_r < sayac_w_r ? sayac_x_r : sayac_w_r;
assign islem_sonuc_o = islem_sonuc_r;
assign islem_gecerli_o = islem_gecerli_cmb;

endmodule