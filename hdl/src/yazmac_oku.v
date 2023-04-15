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

    input   [`VERI_BIT-1:0]         bellek_veri_i,
    input   [`YAZMAC_BIT-1:0]       bellek_adres_i,
    input   [`UOP_TAG_BIT-1:0]      bellek_etiket_i,
    input                           bellek_gecerli_i,

    input   [`VERI_BIT-1:0]         yurut_veri_i,
    input   [`YAZMAC_BIT-1:0]       yurut_adres_i,
    input   [`UOP_TAG_BIT-1:0]      yurut_etiket_i,
    input                           yurut_gecerli_i,

    output  [`VERI_BIT-1:0]         csr_adres_o,
    output  [`UOP_TAG_BIT-1:0]      csr_etiket_o,
    output                          csr_etiket_gecerli_o,

    input   [`VERI_BIT-1:0]         csr_veri_i,
    input                           csr_veri_gecerli_i,

    input                           cek_bosalt_i,
    input                           cek_duraklat_i,
    output                          duraklat_o,

    input   [`UOP_BIT-1:0]          yo_uop_i,
    output  [`UOP_BIT-1:0]          yurut_uop_o
);

wire                            uop_gecerli_w;
wire    [`UOP_PC_BIT-1:0]       uop_ps_w;

reg     [`UOP_BIT-1:0]          uop_r;
reg     [`UOP_BIT-1:0]          uop_ns;

wire    [`YAZMAC_BIT-1:0]       obek_adres1_w;
wire                            obek_adres1_gecerli_w;
wire    [`YAZMAC_BIT-1:0]       obek_adres2_w;
wire                            obek_adres2_gecerli_w;

wire                            csr_oku_gecerli_w;

reg                             okuma_hatasi_cmb;

wire    [`VERI_BIT-1:0]         obek_veri1_w;
wire                            obek_veri1_gecerli_w;
wire    [`UOP_TAG_BIT-1:0]      obek_veri1_etiket_w;
wire    [`VERI_BIT-1:0]         obek_veri2_w;
wire                            obek_veri2_gecerli_w;
wire    [`UOP_TAG_BIT-1:0]      obek_veri2_etiket_w;

reg    [`VERI_BIT-1:0]          oku_veri1_cmb;
reg                             oku_veri1_gecerli_cmb;
reg    [`VERI_BIT-1:0]          oku_veri2_cmb;
reg                             oku_veri2_gecerli_cmb;

wire    [`VERI_BIT-1:0]         yaz_veri_w;
wire    [`YAZMAC_BIT-1:0]       yaz_adres_w;
wire    [`UOP_TAG_BIT-1:0]      yaz_etiket_w;
wire                            yaz_gecerli_w;

wire    [`UOP_TAG_BIT-1:0]      etiket_w;
wire    [`YAZMAC_BIT-1:0]       etiket_adres_w;
wire                            etiket_gecerli_w;

// DEBUG
wire veri_yonlendir_aktif_w;

assign veri_yonlendir_aktif_w =    (!obek_veri1_gecerli_w && oku_veri1_gecerli_cmb)
                                || (!obek_veri2_gecerli_w && oku_veri2_gecerli_cmb);
// DEBUG

always @* begin
    uop_ns = yo_uop_i;

    if (yurut_gecerli_i && yurut_adres_i == obek_adres1_w && yurut_etiket_i == obek_veri1_etiket_w) begin
        oku_veri1_cmb = yurut_veri_i;
        oku_veri1_gecerli_cmb = `HIGH;
    end
    else if (bellek_gecerli_i && bellek_adres_i == obek_adres1_w && bellek_etiket_i == obek_veri1_etiket_w) begin
        oku_veri1_cmb = bellek_veri_i;
        oku_veri1_gecerli_cmb = `HIGH;
    end
    else if (geriyaz_gecerli_i && geriyaz_adres_i == obek_adres1_w && geriyaz_etiket_i == obek_veri1_etiket_w) begin
        oku_veri1_cmb = geriyaz_veri_i;
        oku_veri1_gecerli_cmb = `HIGH;
    end
    else begin
        oku_veri1_cmb = obek_veri1_w;
        oku_veri1_gecerli_cmb = obek_veri1_gecerli_w;
    end

    if (yurut_gecerli_i && yurut_adres_i == obek_adres2_w && yurut_etiket_i == obek_veri2_etiket_w) begin
        oku_veri2_cmb = yurut_veri_i;
        oku_veri2_gecerli_cmb = `HIGH;
    end
    else if (bellek_gecerli_i && bellek_adres_i == obek_adres2_w && bellek_etiket_i == obek_veri2_etiket_w) begin
        oku_veri2_cmb = bellek_veri_i;
        oku_veri2_gecerli_cmb = `HIGH;
    end
    else if (geriyaz_gecerli_i && geriyaz_adres_i == obek_adres2_w && geriyaz_etiket_i == obek_veri2_etiket_w) begin
        oku_veri2_cmb = geriyaz_veri_i;
        oku_veri2_gecerli_cmb = `HIGH;
    end
    else begin
        oku_veri2_cmb = obek_veri2_w;
        oku_veri2_gecerli_cmb = obek_veri2_gecerli_w;
    end

    okuma_hatasi_cmb =  (obek_adres1_gecerli_w && !oku_veri1_gecerli_cmb)
                    ||  (obek_adres2_gecerli_w && !oku_veri2_gecerli_cmb)
                    ||  (csr_oku_gecerli_w    && !csr_veri_gecerli_i);

    uop_ns[`UOP_VALID] = uop_gecerli_w && !okuma_hatasi_cmb;
    uop_ns[`UOP_RS1] = oku_veri1_cmb;
    uop_ns[`UOP_RS2] = oku_veri2_cmb;
    uop_ns[`UOP_CSR] = csr_veri_i;

    if (cek_duraklat_i) begin
        uop_ns = uop_r;
    end
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
    .oku_adres1_i        ( obek_adres1_w          ),
    .oku_adres2_i        ( obek_adres2_w          ),
    .oku_veri1_o         ( obek_veri1_w           ),
    .oku_veri1_gecerli_o ( obek_veri1_gecerli_w   ),
    .oku_veri1_etiket_o  ( obek_veri1_etiket_w    ),
    .oku_veri2_o         ( obek_veri2_w           ),
    .oku_veri2_gecerli_o ( obek_veri2_gecerli_w   ),
    .oku_veri2_etiket_o  ( obek_veri2_etiket_w    ),
    .yaz_veri_i          ( yaz_veri_w             ),
    .yaz_adres_i         ( yaz_adres_w            ),
    .yaz_etiket_i        ( yaz_etiket_w           ),
    .yaz_gecerli_i       ( yaz_gecerli_w          ),
    .etiket_i            ( etiket_w               ),
    .etiket_adres_i      ( etiket_adres_w         ),
    .etiket_gecerli_i    ( etiket_gecerli_w       )
);

assign uop_gecerli_w = yo_uop_i[`UOP_VALID] && !cek_bosalt_i;
assign uop_ps_w = yo_uop_i[`UOP_PC];

assign obek_adres1_w = yo_uop_i[`UOP_RS1];
assign obek_adres1_gecerli_w = yo_uop_i[`UOP_RS1_EN];
assign obek_adres2_w = yo_uop_i[`UOP_RS2];
assign obek_adres2_gecerli_w = yo_uop_i[`UOP_RS2_EN];

assign etiket_w = yo_uop_i[`UOP_TAG];
assign etiket_adres_w = yo_uop_i[`UOP_RD_ADDR];
assign etiket_gecerli_w = yo_uop_i[`UOP_RD_ALLOC] && !okuma_hatasi_cmb && uop_gecerli_w && !cek_duraklat_i;

assign csr_adres_o = yo_uop_i[`UOP_CSR_ADDR];
assign csr_etiket_o = etiket_w;
assign csr_etiket_gecerli_o = yo_uop_i[`UOP_CSR_ALLOC] && !okuma_hatasi_cmb && uop_gecerli_w;

assign csr_oku_gecerli_w = yo_uop_i[`UOP_CSR_EN];

assign yaz_veri_w = geriyaz_veri_i; 
assign yaz_adres_w = geriyaz_adres_i; 
assign yaz_etiket_w = geriyaz_etiket_i; 
assign yaz_gecerli_w = geriyaz_gecerli_i; 

assign duraklat_o = uop_gecerli_w && okuma_hatasi_cmb;

assign yurut_uop_o = uop_r;

endmodule