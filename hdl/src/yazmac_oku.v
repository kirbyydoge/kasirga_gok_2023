`timescale 1ns/1ps

`include "mikroislem.vh"
`include "sabitler.vh"

module yazmac_oku(
    input                           clk_i,
    input                           rstn_i,

    input   [`VERI_BIT-1:0]         geriyaz_veri_i,
    input   [`YAZMAC_BIT-1:0]       geriyaz_adres_i,
    input   [`UOP_TAG_BIT-1:0]      geriyaz_etiket_i,
    input                           geriyaz_gecerli_i,

    input                           cek_bosalt_i,
    input                           cek_duraklat_i,
    output                          duraklat_o,

    input   [`UOP_BIT-1:0]          yo_uop_i,
    output  [`UOP_BIT-1:0]          yurut_uop_o
);

wire uop_gecerli_w;

reg     [`UOP_BIT-1:0]          uop_r;
reg     [`UOP_BIT-1:0]          uop_ns;

wire    [`YAZMAC_BIT-1:0]       oku_adres1_w;
wire                            oku_adres1_gecerli_w;
wire    [`YAZMAC_BIT-1:0]       oku_adres2_w;
wire                            oku_adres2_gecerli_w;

wire                            okuma_hatasi_w;

wire    [`VERI_BIT-1:0]         oku_veri1_w;
wire                            oku_veri1_gecerli_w;
wire    [`VERI_BIT-1:0]         oku_veri2_w;
wire                            oku_veri2_gecerli_w;

wire    [`VERI_BIT-1:0]         yaz_veri_w;
wire    [`YAZMAC_BIT-1:0]       yaz_adres_w;
wire    [`UOP_TAG_BIT-1:0]      yaz_etiket_w;
wire                            yaz_gecerli_w;

wire    [`UOP_TAG_BIT-1:0]      etiket_w;
wire    [`YAZMAC_BIT-1:0]       etiket_adres_w;
wire                            etiket_gecerli_w;

always @* begin
    uop_ns = yo_uop_i;
    uop_ns[`UOP_VALID] = uop_gecerli_w && !okuma_hatasi_w;
    uop_ns[`UOP_RS1] = oku_veri1_w;
    uop_ns[`UOP_RS2] = oku_veri2_w;
end

always @(posedge clk_i) begin
    if (!rstn_i) begin
        uop_r <= {`UOP_BIT{`LOW}};
    end
    else begin
        uop_r <= uop_ns;
    end
end

yazmac_obegi rf (
    .clk_i               ( clk_i                  ),
    .rstn_i              ( rstn_i                 ),
    .oku_adres1_i        ( oku_adres1_w           ),
    .oku_adres2_i        ( oku_adres2_w           ),
    .oku_veri1_o         ( oku_veri1_w            ),
    .oku_veri1_gecerli_o ( oku_veri1_gecerli_w    ),
    .oku_veri2_o         ( oku_veri2_w            ),
    .oku_veri2_gecerli_o ( oku_veri2_gecerli_w    ),
    .yaz_veri_i          ( yaz_veri_w             ),
    .yaz_adres_i         ( yaz_adres_w            ),
    .yaz_etiket_i        ( yaz_etiket_w           ),
    .yaz_gecerli_i       ( yaz_gecerli_w          ),
    .etiket_i            ( etiket_w               ),
    .etiket_adres_i      ( etiket_adres_w         ),
    .etiket_gecerli_i    ( etiket_gecerli_w       )
);

assign uop_gecerli_w = yo_uop_i[`UOP_VALID];

assign oku_adres1_w = yo_uop_i[`UOP_RS1];
assign oku_adres1_gecerli_w = yo_uop_i[`UOP_RS1_EN];
assign oku_adres2_w = yo_uop_i[`UOP_RS2];
assign oku_adres2_gecerli_w = yo_uop_i[`UOP_RS2_EN];

assign okuma_hatasi_w = !(oku_adres1_gecerli_w && !oku_veri1_gecerli_w) || !(oku_adres2_gecerli_w && !oku_veri2_gecerli_w);

assign etiket_w = yo_uop_i[`UOP_TAG];
assign etiket_adres_w = yo_uop_i[`UOP_RD];
assign etiket_gecerli_w = yo_uop_i[`UOP_RD_ALLOC];

assign yaz_veri_w = geriyaz_veri_i; 
assign yaz_adres_w = geriyaz_adres_i; 
assign yaz_etiket_w = geriyaz_etiket_i; 
assign yaz_gecerli_w = geriyaz_gecerli_i; 

assign duraklat_o = okuma_hatasi_w;

endmodule