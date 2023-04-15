`timescale 1ns/1ps

`include "sabitler.vh"
`include "mikroislem.vh"

module cekirdek(
    input                           clk_i,
    input                           rstn_i,
    
    // Cekirdek <> L1 Buyruk Onbellek Denetleyici
    input   [`L1_BLOK_BIT-1:0]      buyruk_yanit_veri_i,
    input                           buyruk_yanit_gecerli_i,
    output                          buyruk_yanit_hazir_o,

    output  [`ADRES_BIT-1:0]        buyruk_istek_adres_o,
    output                          buyruk_istek_gecerli_o,
    input                           buyruk_istek_hazir_i,

    // Cekirdek <> L1 Veri Onbellek Denetleyicisi
    input   [`VERI_BIT-1:0]         l1v_yanit_veri_i,
    input                           l1v_yanit_gecerli_i,
    output                          l1v_yanit_hazir_o,

    output  [`VERI_BIT-1:0]         l1v_istek_veri_o,
    output  [`ADRES_BIT-1:0]        l1v_istek_adres_o,
    output                          l1v_istek_yaz_o,
    output                          l1v_istek_gecerli_o,
    output                          l1v_istek_onbellekleme_o,
    input                           l1v_istek_hazir_i
);

// ---- GETIR1 ----
wire                            io_g1_clk_w;
wire                            io_g1_rstn_w;
wire                            io_g1_l1b_istek_hazir_w;
wire    [`PS_BIT-1:0]           io_g1_l1b_istek_adres_w;
wire                            io_g1_l1b_istek_gecerli_w;
wire                            io_g1_g2_istek_yapildi_w;
wire    [`PS_BIT-1:0]           io_g1_g2_ps_w;
wire                            io_g1_g2_ps_hazir_w;
wire                            io_g1_g2_ps_gecerli_w;
wire                            io_g1_cek_bosalt_w;
wire                            io_g1_cek_duraklat_w;
wire    [`PS_BIT-1:0]           io_g1_cek_ps_w;
wire                            io_g1_cek_ps_gecerli_w;

getir1 getir1 (
    .clk_i                      ( io_g1_clk_w ),
    .rstn_i                     ( io_g1_rstn_w ),
    .l1b_istek_hazir_i          ( io_g1_l1b_istek_hazir_w ),
    .l1b_istek_adres_o          ( io_g1_l1b_istek_adres_w ),
    .l1b_istek_gecerli_o        ( io_g1_l1b_istek_gecerli_w ),
    .g2_istek_yapildi_o         ( io_g1_g2_istek_yapildi_w ),
    .g2_ps_o                    ( io_g1_g2_ps_w ),
    .g2_ps_hazir_i              ( io_g1_g2_ps_hazir_w ),
    .g2_ps_gecerli_o            ( io_g1_g2_ps_gecerli_w ),
    .cek_bosalt_i               ( io_g1_cek_bosalt_w ),
    .cek_duraklat_i             ( io_g1_cek_duraklat_w ),
    .cek_ps_i                   ( io_g1_cek_ps_w ),
    .cek_ps_gecerli_i           ( io_g1_cek_ps_gecerli_w )
);

// ---- GETIR2 ----
wire                            io_g2_clk_w;
wire                            io_g2_rstn_w;
wire                            io_g2_g1_istek_yapildi_w;
wire    [`PS_BIT-1:0]           io_g2_g1_ps_w;
wire                            io_g2_g1_ps_gecerli_w;
wire                            io_g2_g1_ps_hazir_w;
wire    [`PS_BIT-1:0]           io_g2_g1_dallanma_ps_w;
wire                            io_g2_g1_dallanma_gecerli_w;
wire    [`PS_BIT-1:0]           io_g2_yurut_ps_w;
wire    [`PS_BIT-1:0]           io_g2_yurut_hedef_ps_w;
wire                            io_g2_yurut_guncelle_w;
wire                            io_g2_yurut_atladi_w;
wire                            io_g2_yurut_hatali_tahmin_w;
wire    [`VERI_BIT-1:0]         io_g2_l1b_buyruk_w;
wire                            io_g2_l1b_buyruk_gecerli_w;
wire                            io_g2_l1b_buyruk_hazir_w;
wire    [`BUYRUK_BIT-1:0]       io_g2_coz_buyruk_w;
wire    [`PS_BIT-1:0]           io_g2_coz_buyruk_ps_w;
wire                            io_g2_coz_buyruk_gecerli_w;
wire                            io_g2_coz_buyruk_atladi_w;
wire                            io_g2_coz_buyruk_rvc_w;
wire                            io_g2_cek_bosalt_w;
wire                            io_g2_cek_duraklat_w;

getir2 getir2 (
    .clk_i                      ( io_g2_clk_w ),
    .rstn_i                     ( io_g2_rstn_w ),
    .g1_istek_yapildi_i         ( io_g2_g1_istek_yapildi_w ),
    .g1_ps_i                    ( io_g2_g1_ps_w ),
    .g1_ps_gecerli_i            ( io_g2_g1_ps_gecerli_w ),
    .g1_ps_hazir_o              ( io_g2_g1_ps_hazir_w ),
    .g1_dallanma_ps_o           ( io_g2_g1_dallanma_ps_w ),
    .g1_dallanma_gecerli_o      ( io_g2_g1_dallanma_gecerli_w ),
    .yurut_ps_i                 ( io_g2_yurut_ps_w ),
    .yurut_hedef_ps_i           ( io_g2_yurut_hedef_ps_w ),
    .yurut_guncelle_i           ( io_g2_yurut_guncelle_w ),
    .yurut_atladi_i             ( io_g2_yurut_atladi_w ),
    .yurut_hatali_tahmin_i      ( io_g2_yurut_hatali_tahmin_w ),
    .l1b_buyruk_i               ( io_g2_l1b_buyruk_w ),
    .l1b_buyruk_gecerli_i       ( io_g2_l1b_buyruk_gecerli_w ),
    .l1b_buyruk_hazir_o         ( io_g2_l1b_buyruk_hazir_w ),
    .coz_buyruk_o               ( io_g2_coz_buyruk_w ),
    .coz_buyruk_ps_o            ( io_g2_coz_buyruk_ps_w ),
    .coz_buyruk_gecerli_o       ( io_g2_coz_buyruk_gecerli_w ),
    .coz_buyruk_atladi_o        ( io_g2_coz_buyruk_atladi_w ),
    .coz_buyruk_rvc_o           ( io_g2_coz_buyruk_rvc_w ),
    .cek_bosalt_i               ( io_g2_cek_bosalt_w ),
    .cek_duraklat_i             ( io_g2_cek_duraklat_w )
);

// ---- COZ ----
wire                            io_coz_clk_w;
wire                            io_coz_rstn_w;
wire                            io_coz_cek_bosalt_w;
wire                            io_coz_cek_duraklat_w;
wire                            io_coz_duraklat_w;
wire                            io_coz_gecersiz_buyruk_w;
wire    [`PS_BIT-1:0]           io_coz_getir_buyruk_w;
wire    [`PS_BIT-1:0]           io_coz_getir_ps_w;
wire                            io_coz_getir_gecerli_w;
wire                            io_coz_getir_atladi_w;
wire                            io_coz_getir_rvc_w;
wire    [`UOP_BIT-1:0]          io_coz_yo_uop_w;

coz coz (
    .clk_i                      ( io_coz_clk_w ),
    .rstn_i                     ( io_coz_rstn_w ),
    .cek_bosalt_i               ( io_coz_cek_bosalt_w ),
    .cek_duraklat_i             ( io_coz_cek_duraklat_w ),
    .duraklat_o                 ( io_coz_duraklat_w ),
    .gecersiz_buyruk_o          ( io_coz_gecersiz_buyruk_w ),
    .getir_buyruk_i             ( io_coz_getir_buyruk_w ),
    .getir_ps_i                 ( io_coz_getir_ps_w ),
    .getir_gecerli_i            ( io_coz_getir_gecerli_w ),
    .getir_atladi_i             ( io_coz_getir_atladi_w ),
    .getir_rvc_i                ( io_coz_getir_rvc_w ),
    .yo_uop_o                   ( io_coz_yo_uop_w )
);

// ---- YAZMAC OKU ----
wire                            io_yo_clk_w;
wire                            io_yo_rstn_w;
wire    [`VERI_BIT-1:0]         io_yo_geriyaz_veri_w;
wire    [`YAZMAC_BIT-1:0]       io_yo_geriyaz_adres_w;
wire    [`UOP_TAG_BIT-1:0]      io_yo_geriyaz_etiket_w;
wire                            io_yo_geriyaz_gecerli_w;
wire    [`VERI_BIT-1:0]         io_yo_bellek_veri_w;
wire    [`YAZMAC_BIT-1:0]       io_yo_bellek_adres_w;
wire    [`UOP_TAG_BIT-1:0]      io_yo_bellek_etiket_w;
wire                            io_yo_bellek_gecerli_w;
wire    [`VERI_BIT-1:0]         io_yo_yurut_veri_w;
wire    [`YAZMAC_BIT-1:0]       io_yo_yurut_adres_w;
wire    [`UOP_TAG_BIT-1:0]      io_yo_yurut_etiket_w;
wire                            io_yo_yurut_gecerli_w;
wire    [`VERI_BIT-1:0]         io_yo_csr_adres_w;
wire    [`UOP_TAG_BIT-1:0]      io_yo_csr_etiket_w;
wire                            io_yo_csr_etiket_gecerli_w;
wire    [`VERI_BIT-1:0]         io_yo_csr_veri_w;
wire                            io_yo_csr_veri_gecerli_w;
wire                            io_yo_cek_bosalt_w;
wire                            io_yo_cek_duraklat_w;
wire                            io_yo_duraklat_w;
wire    [`UOP_BIT-1:0]          io_yo_yo_uop_w;
wire    [`UOP_BIT-1:0]          io_yo_yurut_uop_w;

yazmac_oku yo (
    .clk_i                      ( io_yo_clk_w ),
    .rstn_i                     ( io_yo_rstn_w ),
    .geriyaz_veri_i             ( io_yo_geriyaz_veri_w ),
    .geriyaz_adres_i            ( io_yo_geriyaz_adres_w ),
    .geriyaz_etiket_i           ( io_yo_geriyaz_etiket_w ),
    .geriyaz_gecerli_i          ( io_yo_geriyaz_gecerli_w ),
    .bellek_veri_i              ( io_yo_bellek_veri_w ),   
    .bellek_adres_i             ( io_yo_bellek_adres_w ),   
    .bellek_etiket_i            ( io_yo_bellek_etiket_w ),       
    .bellek_gecerli_i           ( io_yo_bellek_gecerli_w ),       
    .yurut_veri_i               ( io_yo_yurut_veri_w ),
    .yurut_adres_i              ( io_yo_yurut_adres_w ),
    .yurut_etiket_i             ( io_yo_yurut_etiket_w ),
    .yurut_gecerli_i            ( io_yo_yurut_gecerli_w ),
    .csr_adres_o                ( io_yo_csr_adres_w ),
    .csr_etiket_o               ( io_yo_csr_etiket_w ),
    .csr_etiket_gecerli_o       ( io_yo_csr_etiket_gecerli_w ),
    .csr_veri_i                 ( io_yo_csr_veri_w ),
    .csr_veri_gecerli_i         ( io_yo_csr_veri_gecerli_w ),
    .cek_bosalt_i               ( io_yo_cek_bosalt_w ),
    .cek_duraklat_i             ( io_yo_cek_duraklat_w ),
    .duraklat_o                 ( io_yo_duraklat_w ),
    .yo_uop_i                   ( io_yo_yo_uop_w ),
    .yurut_uop_o                ( io_yo_yurut_uop_w )
);

// ---- YURUT ----
wire                            io_yurut_clk_w;
wire                            io_yurut_rstn_w;
wire                            io_yurut_cek_bosalt_w;
wire                            io_yurut_cek_duraklat_w;
wire                            io_yurut_duraklat_w;
wire                            io_yurut_bosalt_w;
wire    [`PS_BIT-1:0]           io_yurut_ddb_odd_ps_w;
wire    [`EXC_CODE_BIT-1:0]     io_yurut_ddb_odd_kod_w;
wire    [`MXLEN-1:0]            io_yurut_ddb_odd_bilgi_w;
wire                            io_yurut_ddb_odd_gecerli_w;
wire    [`PS_BIT-1:0]           io_yurut_g1_ps_w;
wire                            io_yurut_g1_ps_gecerli_w;
wire    [`PS_BIT-1:0]           io_yurut_g2_ps_w;
wire    [`PS_BIT-1:0]           io_yurut_g2_hedef_ps_w;
wire                            io_yurut_g2_guncelle_w;
wire                            io_yurut_g2_atladi_w;
wire                            io_yurut_g2_hatali_tahmin_w;
wire    [`VERI_BIT-1:0]         io_yurut_yo_veri_w;
wire    [`YAZMAC_BIT-1:0]       io_yurut_yo_adres_w;
wire    [`UOP_TAG_BIT-1:0]      io_yurut_yo_etiket_w;
wire                            io_yurut_yo_gecerli_w;
wire    [`UOP_BIT-1:0]          io_yurut_yurut_uop_w;
wire    [`UOP_BIT-1:0]          io_yurut_bellek_uop_w;

yurut yurut(
    .clk_i                      ( io_yurut_clk_w ),
    .rstn_i                     ( io_yurut_rstn_w ),
    .cek_bosalt_i               ( io_yurut_cek_bosalt_w ),
    .cek_duraklat_i             ( io_yurut_cek_duraklat_w ),
    .duraklat_o                 ( io_yurut_duraklat_w ),
    .bosalt_o                   ( io_yurut_bosalt_w ),
    .ddb_odd_ps_o               ( io_yurut_ddb_odd_ps_w ),
    .ddb_odd_kod_o              ( io_yurut_ddb_odd_kod_w ),
    .ddb_odd_bilgi_o            ( io_yurut_ddb_odd_bilgi_w ),
    .ddb_odd_gecerli_o          ( io_yurut_ddb_odd_gecerli_w ),
    .g1_ps_o                    ( io_yurut_g1_ps_w ),
    .g1_ps_gecerli_o            ( io_yurut_g1_ps_gecerli_w ),
    .g2_ps_o                    ( io_yurut_g2_ps_w ),
    .g2_hedef_ps_o              ( io_yurut_g2_hedef_ps_w ),
    .g2_guncelle_o              ( io_yurut_g2_guncelle_w ),
    .g2_atladi_o                ( io_yurut_g2_atladi_w ),
    .g2_hatali_tahmin_o         ( io_yurut_g2_hatali_tahmin_w ),
    .yo_veri_o                  ( io_yurut_yo_veri_w ),
    .yo_adres_o                 ( io_yurut_yo_adres_w ),
    .yo_etiket_o                ( io_yurut_yo_etiket_w ),
    .yo_gecerli_o               ( io_yurut_yo_gecerli_w ),
    .yurut_uop_i                ( io_yurut_yurut_uop_w ),
    .bellek_uop_o               ( io_yurut_bellek_uop_w )
);

// ---- BELLEK ----
wire                            io_bellek_clk_w;
wire                            io_bellek_rstn_w;
wire    [`ADRES_BIT-1:0]        io_bellek_l1v_istek_adres_w;
wire                            io_bellek_l1v_istek_gecerli_w;
wire                            io_bellek_l1v_istek_onbellekleme_w;
wire                            io_bellek_l1v_istek_yaz_w;
wire    [`VERI_BIT-1:0]         io_bellek_l1v_istek_veri_w;
wire    [`VERI_BYTE-1:0]        io_bellek_l1v_istek_maske_w; 
wire                            io_bellek_l1v_istek_hazir_w;
wire    [`VERI_BIT-1:0]         io_bellek_l1v_veri_w;
wire                            io_bellek_l1v_veri_gecerli_w;
wire                            io_bellek_l1v_veri_hazir_w;
wire    [`VERI_BIT-1:0]         io_bellek_yo_veri_w;
wire    [`YAZMAC_BIT-1:0]       io_bellek_yo_adres_w;
wire    [`UOP_TAG_BIT-1:0]      io_bellek_yo_etiket_w;
wire                            io_bellek_yo_gecerli_w;
wire                            io_bellek_duraklat_w;
wire  [`UOP_BIT-1:0]            io_bellek_bellek_uop_w;
wire  [`UOP_BIT-1:0]            io_bellek_gy_uop_w;

bellek bellek (
    .clk_i                      ( io_bellek_clk_w ),
    .rstn_i                     ( io_bellek_rstn_w ),
    .l1v_istek_adres_o          ( io_bellek_l1v_istek_adres_w ),
    .l1v_istek_gecerli_o        ( io_bellek_l1v_istek_gecerli_w ),
    .l1v_istek_onbellekleme_o   ( io_bellek_l1v_istek_onbellekleme_w ),
    .l1v_istek_yaz_o            ( io_bellek_l1v_istek_yaz_w ),
    .l1v_istek_veri_o           ( io_bellek_l1v_istek_veri_w ),
    .l1v_istek_maske_o          ( io_bellek_l1v_istek_maske_w ),
    .l1v_istek_hazir_i          ( io_bellek_l1v_istek_hazir_w ),
    .l1v_veri_i                 ( io_bellek_l1v_veri_w ),
    .l1v_veri_gecerli_i         ( io_bellek_l1v_veri_gecerli_w ),
    .l1v_veri_hazir_o           ( io_bellek_l1v_veri_hazir_w ),
    .yo_veri_o                  ( io_bellek_yo_veri_w ),
    .yo_adres_o                 ( io_bellek_yo_adres_w ),
    .yo_etiket_o                ( io_bellek_yo_etiket_w ),    
    .yo_gecerli_o               ( io_bellek_yo_gecerli_w ),    
    .duraklat_o                 ( io_bellek_duraklat_w ),
    .bellek_uop_i               ( io_bellek_bellek_uop_w ),
    .geri_yaz_uop_o             ( io_bellek_gy_uop_w )
);

// ---- GERI YAZ ----
wire                            io_gy_clk_w;
wire                            io_gy_rstn_w;
wire    [`UOP_BIT-1:0]          io_gy_gy_uop_w;
wire    [`VERI_BIT-1:0]         io_gy_yo_veri_w;
wire    [`YAZMAC_BIT-1:0]       io_gy_yo_adres_w;
wire    [`UOP_TAG_BIT-1:0]      io_gy_yo_etiket_w;
wire                            io_gy_yo_gecerli_w;
wire    [`VERI_BIT-1:0]         io_gy_csr_veri_w;
wire    [`CSR_ADRES_BIT-1:0]    io_gy_csr_adres_w;
wire    [`UOP_TAG_BIT-1:0]      io_gy_csr_etiket_w;
wire                            io_gy_csr_gecerli_w;       

geri_yaz gy (
    .clk_i                      ( io_gy_clk_w ),
    .rstn_i                     ( io_gy_rstn_w ),
    .gy_uop_i                   ( io_gy_gy_uop_w ),
    .yo_veri_o                  ( io_gy_yo_veri_w ),
    .yo_adres_o                 ( io_gy_yo_adres_w ),
    .yo_etiket_o                ( io_gy_yo_etiket_w ),
    .yo_gecerli_o               ( io_gy_yo_gecerli_w ),
    .csr_veri_o                 ( io_gy_csr_veri_w ),
    .csr_adres_o                ( io_gy_csr_adres_w ),
    .csr_etiket_o               ( io_gy_csr_etiket_w ),
    .csr_gecerli_o              ( io_gy_csr_gecerli_w )
);

// ---- DENETIM DURUM BIRIMI ----
wire                            io_ddb_clk_w;
wire                            io_ddb_rstn_w;
wire    [`PS_BIT-1:0]           io_ddb_coz_odd_ps_w;
wire    [`EXC_CODE_BIT-1:0]     io_ddb_coz_odd_kod_w;
wire                            io_ddb_coz_odd_gecerli_w;
wire    [`PS_BIT-1:0]           io_ddb_yurut_odd_ps_w;
wire    [`EXC_CODE_BIT-1:0]     io_ddb_yurut_odd_kod_w;
wire    [`MXLEN-1:0]            io_ddb_yurut_odd_bilgi_w;
wire                            io_ddb_yurut_odd_gecerli_w;
wire    [`PS_BIT-1:0]           io_ddb_bellek_odd_ps_w;
wire    [`EXC_CODE_BIT-1:0]     io_ddb_bellek_odd_kod_w;
wire                            io_ddb_bellek_odd_gecerli_w;
wire    [`CSR_ADRES_BIT-1:0]    io_ddb_oku_istek_adres_w;
wire    [`UOP_TAG_BIT-1:0]      io_ddb_oku_istek_etiket_w;
wire                            io_ddb_oku_istek_etiket_gecerli_w;
wire    [`MXLEN-1:0]            io_ddb_yaz_istek_veri_w;
wire    [`CSR_ADRES_BIT-1:0]    io_ddb_yaz_istek_adres_w;
wire    [`UOP_TAG_BIT-1:0]      io_ddb_yaz_istek_etiket_w;
wire                            io_ddb_yaz_istek_gecerli_w;
wire    [`MXLEN-1:0]            io_ddb_csr_veri_w;
wire                            io_ddb_csr_gecerli_w;
wire                            io_ddb_bosalt_w;
wire                            io_ddb_duraklat_w;
wire    [`PS_BIT-1:0]           io_ddb_getir_ps_w;
wire                            io_ddb_getir_ps_gecerli_w;

denetim_durum_birimi ddb (
    .clk_i                      ( io_ddb_clk_w ),
    .rstn_i                     ( io_ddb_rstn_w ),
    .coz_odd_ps_i               ( io_ddb_coz_odd_ps_w ),
    .coz_odd_kod_i              ( io_ddb_coz_odd_kod_w ),
    .coz_odd_gecerli_i          ( io_ddb_coz_odd_gecerli_w ),
    .yurut_odd_ps_i             ( io_ddb_yurut_odd_ps_w ),
    .yurut_odd_kod_i            ( io_ddb_yurut_odd_kod_w ),
    .yurut_odd_bilgi_i          ( io_ddb_yurut_odd_bilgi_w ),
    .yurut_odd_gecerli_i        ( io_ddb_yurut_odd_gecerli_w ),
    .bellek_odd_ps_i            ( io_ddb_bellek_odd_ps_w ),
    .bellek_odd_kod_i           ( io_ddb_bellek_odd_kod_w ),
    .bellek_odd_gecerli_i       ( io_ddb_bellek_odd_gecerli_w ),
    .oku_istek_adres_i          ( io_ddb_oku_istek_adres_w ),
    .oku_istek_etiket_i         ( io_ddb_oku_istek_etiket_w ),
    .oku_istek_etiket_gecerli_i ( io_ddb_oku_istek_etiket_gecerli_w ),
    .yaz_istek_veri_i           ( io_ddb_yaz_istek_veri_w ),
    .yaz_istek_adres_i          ( io_ddb_yaz_istek_adres_w ),
    .yaz_istek_etiket_i         ( io_ddb_yaz_istek_etiket_w ),
    .yaz_istek_gecerli_i        ( io_ddb_yaz_istek_gecerli_w ),
    .csr_veri_o                 ( io_ddb_csr_veri_w ),
    .csr_gecerli_o              ( io_ddb_csr_gecerli_w ),
    .bosalt_o                   ( io_ddb_bosalt_w ),
    .duraklat_o                 ( io_ddb_duraklat_w ),
    .getir_ps_o                 ( io_ddb_getir_ps_w ),
    .getir_ps_gecerli_o         ( io_ddb_getir_ps_gecerli_w )
);

// ---- CEKIRDEK BAGLANTILARI ----
wire cekirdek_getir1_duraklat_w;
wire cekirdek_getir2_duraklat_w;
wire cekirdek_coz_duraklat_w;
wire cekirdek_yo_duraklat_w;
wire cekirdek_yurut_duraklat_w;
wire cekirdek_bellek_duraklat_w;

wire cekirdek_bosalt_w;

reg    [`PS_BIT-1:0]   cekirdek_ps_cmb;
reg                    cekirdek_ps_gecerli_cmb;

assign cekirdek_bellek_duraklat_w = `LOW;
assign cekirdek_yurut_duraklat_w = io_bellek_duraklat_w || io_ddb_duraklat_w;
assign cekirdek_yo_duraklat_w = cekirdek_yurut_duraklat_w || io_yurut_duraklat_w;
assign cekirdek_coz_duraklat_w = cekirdek_yo_duraklat_w || io_yo_duraklat_w;
assign cekirdek_getir2_duraklat_w = cekirdek_coz_duraklat_w || io_coz_duraklat_w;
assign cekirdek_getir1_duraklat_w = cekirdek_getir2_duraklat_w;

assign cekirdek_bosalt_w = io_yurut_bosalt_w || io_ddb_bosalt_w;

always @* begin
    cekirdek_ps_gecerli_cmb =   io_ddb_getir_ps_gecerli_w
                            ||  io_yurut_g1_ps_gecerli_w
                            ||  io_g2_g1_dallanma_gecerli_w;
    cekirdek_ps_cmb = {`PS_BIT{1'b0}};
    if (io_ddb_getir_ps_gecerli_w) begin
        cekirdek_ps_cmb = io_ddb_getir_ps_w;
    end
    else if (io_yurut_g1_ps_gecerli_w) begin
        cekirdek_ps_cmb = io_yurut_g1_ps_w;
    end
    else if (io_g2_g1_dallanma_gecerli_w) begin
        cekirdek_ps_cmb = io_g2_g1_dallanma_ps_w;
    end
end

// Getir1 < Cekirdek
assign io_g1_clk_w = clk_i;
assign io_g1_rstn_w = rstn_i;
assign io_g1_cek_bosalt_w = cekirdek_bosalt_w;
assign io_g1_cek_duraklat_w = cekirdek_getir1_duraklat_w;
assign io_g1_cek_ps_w = cekirdek_ps_cmb;
assign io_g1_cek_ps_gecerli_w = cekirdek_ps_gecerli_cmb;

// Getir2 < Cekirdek
assign io_g2_clk_w = clk_i;
assign io_g2_rstn_w = rstn_i;
assign io_g2_cek_bosalt_w = cekirdek_bosalt_w;
assign io_g2_cek_duraklat_w = cekirdek_getir2_duraklat_w;

// Coz < Cekirdek
assign io_coz_clk_w = clk_i;
assign io_coz_rstn_w = rstn_i;
assign io_coz_cek_bosalt_w = cekirdek_bosalt_w;
assign io_coz_cek_duraklat_w = cekirdek_coz_duraklat_w;

// Yazmac Oku < Cekirdek
assign io_yo_clk_w = clk_i;
assign io_yo_rstn_w = rstn_i;
assign io_yo_cek_bosalt_w = cekirdek_bosalt_w;
assign io_yo_cek_duraklat_w = cekirdek_yo_duraklat_w;

// Yurut < Cekirdek
assign io_yurut_clk_w = clk_i;
assign io_yurut_rstn_w = rstn_i;
assign io_yurut_cek_bosalt_w = cekirdek_bosalt_w && !io_yurut_bosalt_w;
assign io_yurut_cek_duraklat_w = cekirdek_yurut_duraklat_w;

// Bellek < Cekirdek
assign io_bellek_clk_w = clk_i;
assign io_bellek_rstn_w = rstn_i;
// assign io_bellek_cek_bosalt_w = cekirdek_bosalt_w;
// assign io_bellek_cek_duraklat_w = cekirdek_yurut_duraklat_w;

// Geri Yaz < Cekirdek
assign io_gy_clk_w = clk_i;
assign io_gy_rstn_w = rstn_i;

// Denetim Durum Birimi < Cekirdek
assign io_ddb_clk_w = clk_i;
assign io_ddb_rstn_w = rstn_i;

// Getir1 < Getir2
assign io_g1_g2_ps_hazir_w = io_g2_g1_ps_hazir_w;

// Getir2 < Getir1
assign io_g2_g1_istek_yapildi_w = io_g1_g2_istek_yapildi_w;
assign io_g2_g1_ps_w = io_g1_g2_ps_w;
assign io_g2_g1_ps_gecerli_w = io_g1_g2_ps_gecerli_w;

// Getir1 < L1B
assign io_g1_l1b_istek_hazir_w = buyruk_istek_hazir_i;

// L1B < Getir1
assign buyruk_istek_adres_o = io_g1_l1b_istek_adres_w;
assign buyruk_istek_gecerli_o = io_g1_l1b_istek_gecerli_w;

// Getir2 < Yurut
assign io_g2_yurut_ps_w = io_yurut_g2_ps_w;
assign io_g2_yurut_hedef_ps_w = io_yurut_g2_hedef_ps_w;
assign io_g2_yurut_guncelle_w = io_yurut_g2_guncelle_w;
assign io_g2_yurut_atladi_w = io_yurut_g2_atladi_w;
assign io_g2_yurut_hatali_tahmin_w = io_yurut_g2_hatali_tahmin_w;

// Getir2 < L1B
assign io_g2_l1b_buyruk_w = buyruk_yanit_veri_i;
assign io_g2_l1b_buyruk_gecerli_w = buyruk_yanit_gecerli_i;

// L1B < Getir2
assign buyruk_yanit_hazir_o = io_g2_l1b_buyruk_hazir_w;

// Coz < Getir2
assign io_coz_getir_buyruk_w = io_g2_coz_buyruk_w;
assign io_coz_getir_ps_w = io_g2_coz_buyruk_ps_w;
assign io_coz_getir_gecerli_w = io_g2_coz_buyruk_gecerli_w;
assign io_coz_getir_atladi_w = io_g2_coz_buyruk_atladi_w;
assign io_coz_getir_rvc_w = io_g2_coz_buyruk_rvc_w;

// Yazmac Oku < Coz
assign io_yo_yo_uop_w = io_coz_yo_uop_w;

// Yazmac Oku < Geri Yaz
assign io_yo_geriyaz_veri_w = io_gy_yo_veri_w;
assign io_yo_geriyaz_adres_w = io_gy_yo_adres_w;
assign io_yo_geriyaz_etiket_w = io_gy_yo_etiket_w;
assign io_yo_geriyaz_gecerli_w = io_gy_yo_gecerli_w;

// Yazmac Oku < Bellek
assign io_yo_bellek_veri_w = io_bellek_yo_veri_w;
assign io_yo_bellek_adres_w = io_bellek_yo_adres_w;
assign io_yo_bellek_etiket_w = io_bellek_yo_etiket_w;
assign io_yo_bellek_gecerli_w = io_bellek_yo_gecerli_w;

// Yazmac Oku < Denetim Durum Birimi
assign io_yo_csr_veri_w = io_ddb_csr_veri_w;
assign io_yo_csr_veri_gecerli_w = io_ddb_csr_gecerli_w;

// Yazmac Oku < Yurut
assign io_yo_yurut_veri_w = io_yurut_yo_veri_w;
assign io_yo_yurut_adres_w = io_yurut_yo_adres_w;
assign io_yo_yurut_etiket_w = io_yurut_yo_etiket_w;
assign io_yo_yurut_gecerli_w = io_yurut_yo_gecerli_w;

// Yurut < Yazmac Oku
assign io_yurut_yurut_uop_w = io_yo_yurut_uop_w;

// Bellek < Yurut
assign io_bellek_bellek_uop_w = io_yurut_bellek_uop_w;

// Bellek < L1V
assign io_bellek_l1v_veri_w = l1v_yanit_veri_i;
assign io_bellek_l1v_veri_gecerli_w = l1v_yanit_gecerli_i;
assign io_bellek_l1v_istek_hazir_w = l1v_istek_hazir_i;

// L1V < Bellek
// assign l1v_istek_veri_o = ?? @Sevval burayi duzelt
assign l1v_yanit_hazir_o = io_bellek_l1v_veri_hazir_w;
assign l1v_istek_adres_o = io_bellek_l1v_istek_adres_w;
// assign l1v_istek_yaz_o = ?? @Sevval burayi duzelt
assign l1v_istek_gecerli_o = io_bellek_l1v_istek_gecerli_w;
assign l1v_istek_onbellekleme_o = io_bellek_l1v_istek_onbellekleme_w;

// Geri Yaz < Bellek
assign io_gy_gy_uop_w = io_bellek_gy_uop_w;

// Denetim Durum Birimi < Coz
assign io_ddb_coz_odd_ps_w = 0;
assign io_ddb_coz_odd_kod_w = 0;
assign io_ddb_coz_odd_gecerli_w = 0;

// Denetim Durum Birimi < Yazmac Oku
assign io_ddb_oku_istek_adres_w = io_yo_csr_adres_w;
assign io_ddb_oku_istek_etiket_w = io_yo_csr_etiket_w;
assign io_ddb_oku_istek_etiket_gecerli_w = io_yo_csr_etiket_gecerli_w;

// Denetim Durum Birimi < Yurut
assign io_ddb_yurut_odd_ps_w = io_yurut_ddb_odd_ps_w;
assign io_ddb_yurut_odd_kod_w = io_yurut_ddb_odd_kod_w;
assign io_ddb_yurut_odd_bilgi_w = io_yurut_ddb_odd_bilgi_w;
assign io_ddb_yurut_odd_gecerli_w = io_yurut_ddb_odd_gecerli_w;

// Denetim Durum Birimi < Bellek
assign io_ddb_bellek_odd_ps_w = 0;
assign io_ddb_bellek_odd_kod_w = 0;
assign io_ddb_bellek_odd_gecerli_w = 0;

// Denetim Durum Birimi < Geri Yaz
assign io_ddb_yaz_istek_veri_w = io_gy_csr_veri_w;
assign io_ddb_yaz_istek_adres_w = io_gy_csr_adres_w;
assign io_ddb_yaz_istek_etiket_w = io_gy_csr_etiket_w;
assign io_ddb_yaz_istek_gecerli_w = io_gy_csr_gecerli_w;


endmodule