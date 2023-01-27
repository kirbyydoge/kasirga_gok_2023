`timescale 1ns/1ps

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

wire [`CNN_YAZMAC_BIT-1:0]   sayac_min_w;

always @* begin
    for (i = 0; i < `N_CNN_YAZMAC; i = i + 1) begin
        bellek_x_ns[i] = bellek_x_r[i];
        bellek_w_ns[i] = bellek_w_r[i];
    end
    sayac_x_ns = sayac_x_r;
    sayac_w_ns = sayac_w_r;
    sayac_sonuc_ns = sayac_sonuc_r;
    islem_sonuc_ns = islem_sonuc_r;
    islem_gecerli_cmb = `HIGH;

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
        islem_sonuc_ns = {`VERI_BIT{1'b0}};
    end
    `UOP_YZB_CLRW: begin
        sayac_w_ns = {`CNN_YAZMAC_BIT{1'b0}};
        sayac_sonuc_ns = {`CNN_YAZMAC_BIT{1'b0}}; // Spekulatif carpimlari geri sar
        islem_sonuc_ns = {`VERI_BIT{1'b0}};
    end
    `UOP_YZB_RUN: begin
        islem_gecerli_cmb = sayac_sonuc_r == sayac_min_w;
    end
    endcase

    if (sayac_sonuc_r < sayac_min_w) begin
        islem_sonuc_ns = bellek_x_r[sayac_sonuc_r] * bellek_w_r[sayac_sonuc_r] + islem_sonuc_r;
        sayac_sonuc_ns = sayac_sonuc_r + 1;
    end
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
        islem_sonuc_r <= {`VERI_BIT{1'b0}};
    end
    else begin
        for (i = 0; i < `N_CNN_YAZMAC; i = i + 1) begin
            bellek_x_r[i] <= bellek_x_ns[i];
            bellek_w_r[i] <= bellek_w_ns[i];
        end
        sayac_x_r <= sayac_x_ns;
        sayac_w_r <= sayac_w_ns;
        sayac_sonuc_r <= sayac_sonuc_ns;
        islem_sonuc_r <= islem_sonuc_ns;
    end
end

assign sayac_min_w = sayac_x_r < sayac_w_r ? sayac_x_r : sayac_w_r;
assign islem_sonuc_o = islem_sonuc_r;
assign islem_gecerli_o = islem_gecerli_cmb;

endmodule