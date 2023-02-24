`timescale 1ns/1ps

`include "sabitler.vh"
`include "mikroislem.vh"

module getir2(
    input                       clk_i,
    input                       rstn_i,

    input                       g1_istek_yapildi_i,

    input   [`PS_BIT-1:0]       g1_ps_i,
    input                       g1_ps_gecerli_i,
    output                      g1_ps_hazir_o,

    output  [`PS_BIT-1:0]       g1_dallanma_ps_o,
    output                      g1_dallanma_gecerli_o,

    input   [`PS_BIT-1:0]       yurut_ps_i,
    input                       yurut_guncelle_i,
    input                       yurut_atladi_i,
    input                       yurut_hatali_tahmin_i,

    input   [`VERI_BIT-1:0]     l1b_buyruk_i,
    input                       l1b_buyruk_gecerli_i,
    output                      l1b_buyruk_hazir_o,

    output  [`BUYRUK_BIT-1:0]   coz_buyruk_o,
    output  [`PS_BIT-1:0]       coz_buyruk_ps_o,
    output                      coz_buyruk_gecerli_o,
    output                      coz_buyruk_atladi_o,

    input                       cek_bosalt_i,
    input                       cek_duraklat_i
);

ila_getir2 debug_getir2 (
    .clk (clk_i),
    .probe0 (rstn_i),
    .probe1 (coz_buyruk_o),
    .probe2 (coz_buyruk_ps_o),
    .probe3 (coz_buyruk_gecerli_o),
    .probe4 (g1_ps_i),
    .probe5 (g1_ps_gecerli_i),
    .probe6 (l1b_buyruk_i),
    .probe7 (l1b_buyruk_gecerli_i)
);

localparam                  G2_YAZMAC_BOS   = 2'd0;
localparam                  G2_YAZMAC_YARIM = 2'd1;
localparam                  G2_YAZMAC_DOLU  = 2'd2;
localparam                  G2_CEK_BOSALT   = 2'd3;

reg     [1:0]               l1b_beklenen_sayisi_r;
reg     [1:0]               l1b_beklenen_sayisi_ns;

reg     [1:0]               g2_bos_istek_sayaci_r;
reg     [1:0]               g2_bos_istek_sayaci_ns;

reg     [`BUYRUK_BIT-1:0]   coz_buyruk_r;
reg     [`BUYRUK_BIT-1:0]   coz_buyruk_ns;

reg     [`PS_BIT-1:0]       coz_buyruk_ps_r;
reg     [`PS_BIT-1:0]       coz_buyruk_ps_ns;

reg                         coz_buyruk_gecerli_r;
reg                         coz_buyruk_gecerli_ns;

reg                         l1b_buyruk_hazir_cmb;
reg                         g1_ps_hazir_cmb;

reg     [1:0]               g2_durum_r;
reg     [1:0]               g2_durum_ns;

wire    [`BUYRUK_BIT/2-1:0] l1b_alt_buyruk_w;
wire                        l1b_alt_compressed_w;
wire    [`BUYRUK_BIT/2-1:0] l1b_ust_buyruk_w;
wire                        l1b_ust_compressed_w;
wire                        l1b_alt_gecersiz_w;
wire    [`PS_BIT-1:0]       l1b_obek_ps_w;

wire    [`BUYRUK_BIT/2-1:0] buf_alt_buyruk_w;
wire                        buf_alt_compressed_w;
wire    [`BUYRUK_BIT/2-1:0] buf_ust_buyruk_w;
wire                        buf_ust_compressed_w;

reg     [`BUYRUK_BIT-1:0]   buf_buyruk_r;
reg     [`BUYRUK_BIT-1:0]   buf_buyruk_ns;

reg     [`PS_BIT-1:0]       buf_ps_r;
reg     [`PS_BIT-1:0]       buf_ps_ns;

reg                         ilk_buyruk_r;
reg                         ilk_buyruk_ns;

always @* begin
    l1b_beklenen_sayisi_ns = l1b_beklenen_sayisi_r;
    coz_buyruk_ns = coz_buyruk_r;
    coz_buyruk_ps_ns = coz_buyruk_ps_r;
    coz_buyruk_gecerli_ns = cek_duraklat_i ? coz_buyruk_gecerli_r : `LOW;
    l1b_buyruk_hazir_cmb = `LOW;
    g1_ps_hazir_cmb = `LOW;
    g2_durum_ns = g2_durum_r;
    g2_bos_istek_sayaci_ns = g2_bos_istek_sayaci_r;
    buf_ps_ns = buf_ps_r;
    buf_buyruk_ns = buf_buyruk_r;
    ilk_buyruk_ns = ilk_buyruk_r;

    if (g2_durum_r != G2_CEK_BOSALT) begin
        // Istek yapildiysa ve su an kabul etmiyorsak cevap beklenen istek sayisi 1 artar.
        if (g1_istek_yapildi_i && !(l1b_buyruk_hazir_o && l1b_buyruk_gecerli_i)) begin
            l1b_beklenen_sayisi_ns = l1b_beklenen_sayisi_r + 1;
        end
        // Istek yapilmadiysa ve su an bir istek kabul ediyorsak cevap beklenen istek sayisi 1 azalir.
        if (!g1_istek_yapildi_i && (l1b_buyruk_hazir_o && l1b_buyruk_gecerli_i)) begin
            l1b_beklenen_sayisi_ns = l1b_beklenen_sayisi_r - 1;
        end
        g1_ps_hazir_cmb = l1b_buyruk_gecerli_i && g1_ps_gecerli_i && !cek_duraklat_i;
        l1b_buyruk_hazir_cmb = l1b_buyruk_gecerli_i && g1_ps_gecerli_i && !cek_duraklat_i;
    end

    case(g2_durum_r)
    G2_YAZMAC_BOS: begin
        // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        // ASAGIDAKI 2 SATIRDA, IFTE, GETIR1DE YA DA L1BDE DEGISIKLIK YAPILIRSA HANDSHAKE KONTROLUNE DIKKAT ETMEK ZORUNDASINIZ
        // SU AN HAZIR SINYALLERI COMBINATIONAL OLARAK IKISININ AYNI ANDA GECERLI OLMASINA BAGLI, BILDIGIMIZ AXI HANDSHAKE DEGIL
        // GELECEKTE ICERIYE 2 BUFFER ACARAK BUNLARA GORE BU ISI YAPMAK GEREKEBILIR, SU AN COK SALLANTIDA
        // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        if (l1b_buyruk_gecerli_i && g1_ps_gecerli_i && !cek_duraklat_i) begin
            if (!l1b_alt_gecersiz_w && !l1b_alt_compressed_w) begin
                coz_buyruk_ns = l1b_buyruk_i;
                coz_buyruk_ps_ns = l1b_obek_ps_w;
                coz_buyruk_gecerli_ns = `HIGH;
            end
            else if(!l1b_alt_gecersiz_w && l1b_alt_compressed_w) begin
                coz_buyruk_ns = {16'b0, l1b_alt_buyruk_w};
                coz_buyruk_ps_ns = l1b_obek_ps_w;
                coz_buyruk_gecerli_ns = `HIGH;

                buf_buyruk_ns = {16'b0, l1b_ust_buyruk_w};
                buf_ps_ns = l1b_obek_ps_w + 2'd2;
                g2_durum_ns = G2_YAZMAC_YARIM;
            end
            else if(l1b_alt_gecersiz_w && !l1b_ust_compressed_w) begin
                buf_buyruk_ns = {16'b0, l1b_ust_buyruk_w};
                buf_ps_ns = l1b_obek_ps_w + 2'd2;
                g2_durum_ns = G2_YAZMAC_YARIM;
            end
            else begin // l1b_alt_gecersiz && l1b_ust_compressed
                coz_buyruk_ns = {16'b0, l1b_ust_buyruk_w};
                coz_buyruk_ps_ns = l1b_obek_ps_w + 2'd2;
                coz_buyruk_gecerli_ns = `HIGH;
            end
        end
    end
    G2_YAZMAC_YARIM: begin
        if (!cek_duraklat_i) begin
            if (buf_alt_compressed_w) begin
                g1_ps_hazir_cmb = `LOW;
                l1b_buyruk_hazir_cmb = `LOW;

                coz_buyruk_ns = {16'b0, buf_alt_buyruk_w};
                coz_buyruk_ps_ns = buf_ps_r;
                coz_buyruk_gecerli_ns = `HIGH;
                g2_durum_ns = G2_YAZMAC_BOS;
            end
            else if (l1b_buyruk_gecerli_i && g1_ps_gecerli_i) begin
                buf_buyruk_ns = {16'b0, l1b_ust_buyruk_w};
                buf_ps_ns = l1b_obek_ps_w + 2'd2;

                coz_buyruk_ns = {l1b_alt_buyruk_w, buf_alt_buyruk_w};
                coz_buyruk_ps_ns = buf_ps_r;
                coz_buyruk_gecerli_ns = `HIGH;
                g2_durum_ns = G2_YAZMAC_YARIM;
            end
        end
    end
    G2_YAZMAC_DOLU: begin

    end
    G2_CEK_BOSALT: begin
        // Istek yapildiysa cevap beklenen istek sayisi 1 artar.
        if (g1_istek_yapildi_i) begin
            l1b_beklenen_sayisi_ns = l1b_beklenen_sayisi_r + 1;
        end
        l1b_buyruk_hazir_cmb = `HIGH; // Bunlar zaten gecersiz durakladigimizda umrumuzda olmalilar mi emin degilim
        if (l1b_buyruk_hazir_o && l1b_buyruk_gecerli_i) begin
            g2_bos_istek_sayaci_ns = g2_bos_istek_sayaci_r - 1;
            if (g2_bos_istek_sayaci_r == 1) begin
                g2_durum_ns = G2_YAZMAC_BOS;
            end
        end
    end
    endcase

    ilk_buyruk_ns = ilk_buyruk_r && !coz_buyruk_gecerli_ns;
    if (cek_bosalt_i && !cek_duraklat_i) begin
        ilk_buyruk_ns = `HIGH;
        g2_durum_ns = G2_YAZMAC_BOS;
        l1b_beklenen_sayisi_ns = g1_istek_yapildi_i ? 3'd1 : 3'd0;
        coz_buyruk_gecerli_ns = `LOW;
        g1_ps_hazir_cmb = `LOW;
        if (l1b_beklenen_sayisi_r != 0) begin
            l1b_buyruk_hazir_cmb = `HIGH;
            if (l1b_buyruk_gecerli_i) begin
                g2_bos_istek_sayaci_ns = l1b_beklenen_sayisi_r - 1;
                g2_durum_ns = l1b_beklenen_sayisi_r != 1 ? G2_CEK_BOSALT : G2_YAZMAC_BOS;
            end
            else begin
                g2_bos_istek_sayaci_ns = l1b_beklenen_sayisi_r;
                g2_durum_ns = G2_CEK_BOSALT;
            end
        end
    end
end

always @(posedge clk_i) begin
    if (!rstn_i) begin
        g2_durum_r <= G2_YAZMAC_BOS;
        l1b_beklenen_sayisi_r <= 2'd0;
        g2_bos_istek_sayaci_r <= 2'd0;
        coz_buyruk_r <= 32'h0;
        coz_buyruk_ps_r <= 32'h0;
        coz_buyruk_gecerli_r <= `LOW;
        buf_buyruk_r <= 32'h0;
        buf_ps_r <= 32'h0;
        ilk_buyruk_r <= `HIGH;
    end
    else begin
        g2_durum_r <= g2_durum_ns;
        l1b_beklenen_sayisi_r <= l1b_beklenen_sayisi_ns;
        g2_bos_istek_sayaci_r <= g2_bos_istek_sayaci_ns;
        coz_buyruk_r <= coz_buyruk_ns;
        coz_buyruk_ps_r <= coz_buyruk_ps_ns;
        coz_buyruk_gecerli_r <= coz_buyruk_gecerli_ns;
        buf_buyruk_r <= buf_buyruk_ns;
        buf_ps_r <= buf_ps_ns;
        ilk_buyruk_r <= ilk_buyruk_ns;
    end
end

assign g1_dallanma_ps_o = 32'h0; //TODO: Oguzhan
assign g1_dallanma_gecerli_o = `LOW; //TODO: Oguzhan
assign g1_ps_hazir_o = g1_ps_hazir_cmb;
assign l1b_buyruk_hazir_o = l1b_buyruk_hazir_cmb;
assign coz_buyruk_o = coz_buyruk_r;
assign coz_buyruk_ps_o = coz_buyruk_ps_r;
assign coz_buyruk_gecerli_o = coz_buyruk_gecerli_r;
assign coz_buyruk_atladi_o = `LOW; // Su anki buyruk atlamadi

assign l1b_alt_buyruk_w = l1b_buyruk_i[0 +: `BUYRUK_BIT/2];
assign l1b_alt_compressed_w = l1b_alt_buyruk_w[1:0] != 2'b11;
assign l1b_ust_buyruk_w = l1b_buyruk_i[`BUYRUK_BIT/2 +: `BUYRUK_BIT/2];
assign l1b_ust_compressed_w = l1b_ust_buyruk_w[1:0] != 2'b11;
assign l1b_alt_gecersiz_w = g1_ps_i[1:0] != 2'b00 && ilk_buyruk_r;
assign l1b_obek_ps_w = g1_ps_i & 32'hFFFF_FFFC;

assign buf_alt_buyruk_w = buf_buyruk_r[0 +: `BUYRUK_BIT/2];
assign buf_alt_compressed_w = buf_buyruk_r[1:0] != 2'b11;
assign buf_ust_buyruk_w = buf_buyruk_r[`BUYRUK_BIT/2 +: `BUYRUK_BIT/2];
assign buf_ust_compressed_w = buf_buyruk_r[1:0] != 2'b11;

endmodule