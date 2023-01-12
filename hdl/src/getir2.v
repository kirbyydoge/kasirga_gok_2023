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

always @* begin
    l1b_beklenen_sayisi_ns = l1b_beklenen_sayisi_r;
    coz_buyruk_ns = coz_buyruk_r;
    coz_buyruk_ps_ns = coz_buyruk_ps_r;
    coz_buyruk_gecerli_ns = cek_duraklat_i ? coz_buyruk_gecerli_r : `LOW;
    l1b_buyruk_hazir_cmb = `LOW;
    g1_ps_hazir_cmb = `LOW;
    g2_durum_ns = g2_durum_r;

    case(g2_durum_r)
    G2_YAZMAC_BOS: begin
        // Istek yapildiysa ve su an kabul etmiyorsak cevap beklenen istek sayisi 1 artar.
        if (g1_istek_yapildi_i && !(l1b_buyruk_hazir_o && l1b_buyruk_gecerli_i)) begin
            l1b_beklenen_sayisi_ns = l1b_beklenen_sayisi_r + 1;
        end
        // Istek yapilmadiysa ve su an bir istek kabul ediyorsak cevap beklenen istek sayisi 1 azalir.
        if (!g1_istek_yapildi_i && (l1b_buyruk_hazir_o && l1b_buyruk_gecerli_i)) begin
            l1b_beklenen_sayisi_ns = l1b_beklenen_sayisi_r - 1;
        end
        // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        // ASAGIDAKI 2 SATIRDA, IFTE, GETIR1DE YA DA L1BDE DEGISIKLIK YAPILIRSA HANDSHAKE KONTROLUNE DIKKAT ETMEK ZORUNDASINIZ
        // SU AN HAZIR SINYALLERI COMBINATIONAL OLARAK IKISININ AYNI ANDA GECERLI OLMASINA BAGLI, BILDIGIMIZ AXI HANDSHAKE DEGIL
        // GELECEKTE ICERIYE 2 BUFFER ACARAK BUNLARA GORE BU ISI YAPMAK GEREKEBILIR, SU AN COK SALLANTIDA
        // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        g1_ps_hazir_cmb = l1b_buyruk_gecerli_i && g1_ps_gecerli_i && !cek_duraklat_i;
        l1b_buyruk_hazir_cmb = l1b_buyruk_gecerli_i && g1_ps_gecerli_i && !cek_duraklat_i;
        if (l1b_buyruk_gecerli_i && g1_ps_gecerli_i && !cek_duraklat_i) begin // Dikkat edin ki yukaridaki 2 satirda bu durumda hep hazir oluyoruz
            coz_buyruk_ns = l1b_buyruk_i;
            coz_buyruk_ps_ns = g1_ps_i;
            coz_buyruk_gecerli_ns = `HIGH;
        end
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

    if (cek_bosalt_i) begin
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
    end
    else begin
        g2_durum_r <= g2_durum_ns;
        l1b_beklenen_sayisi_r <= l1b_beklenen_sayisi_ns;
        g2_bos_istek_sayaci_r <= g2_bos_istek_sayaci_ns;
        coz_buyruk_r <= coz_buyruk_ns;
        coz_buyruk_ps_r <= coz_buyruk_ps_ns;
        coz_buyruk_gecerli_r <= coz_buyruk_gecerli_ns;
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

endmodule