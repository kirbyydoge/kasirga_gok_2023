`timescale 1ns/1ps

`include "sabitler.vh"

module getir1 (
    input                       clk_i,
    input                       rstn_i,

    input                       l1b_istek_hazir_i,
    output  [`PS_BIT-1:0]       l1b_istek_adres_o,
    output                      l1b_istek_gecerli_o,

    output                      g2_istek_yapildi_o,

    output  [`PS_BIT-1:0]       g2_ps_o,
    input                       g2_ps_hazir_i,
    output                      g2_ps_gecerli_o,

    input                       cek_duraklat_i,
    input   [`PS_BIT-1:0]       cek_ps_i,
    input                       cek_ps_gecerli_i
);

reg [`PS_BIT-1:0]       ps_r;
reg [`PS_BIT-1:0]       ps_ns;

reg                     ps_gecerli_r;
reg                     ps_gecerli_ns;

reg [`PS_BIT-1:0]       ps_cmb;
reg                     ps_gecerli_cmb;

reg [`PS_BIT-1:0]       g2_ps_r;
reg [`PS_BIT-1:0]       g2_ps_ns;

reg                     g2_ps_gecerli_r;
reg                     g2_ps_gecerli_ns;

reg                     g2_istek_yapildi_cmb;

always @* begin
    ps_ns = ps_r;
    ps_gecerli_ns = ps_gecerli_r;
    g2_ps_ns = g2_ps_r;
    g2_ps_gecerli_ns = g2_ps_gecerli_r;
    g2_istek_yapildi_cmb = `LOW;
    
    ps_cmb = ps_r;
    ps_gecerli_cmb = ps_gecerli_r && !cek_duraklat_i;

    if (g2_ps_hazir_i && g2_ps_gecerli_r) begin // Getir2 kabul etmeye hazir
        g2_ps_ns = ps_r;
        if (ps_gecerli_r) begin // Siradaki buyruk kabul edilmemis
            g2_ps_gecerli_ns = `LOW;
        end
        else begin // Siradaki buyruk kabul edilmis
            g2_ps_gecerli_ns = `HIGH;
            ps_ns = ps_r + 3'd4;
            ps_gecerli_ns = `HIGH;
        end
    end

    if (cek_ps_gecerli_i) begin // Cekirdek Getir1'i bosaltiyor
        ps_cmb = cek_ps_i;
        ps_gecerli_cmb = `HIGH;
        ps_ns = cek_ps_i;
        ps_gecerli_ns = `HIGH;
        g2_ps_gecerli_ns = `LOW;
    end

    if (l1b_istek_hazir_i && l1b_istek_gecerli_o) begin // L1B istegi kabul ediyor
        g2_istek_yapildi_cmb = `HIGH;
        if (g2_ps_gecerli_r && !g2_ps_hazir_i) begin // Getir2'yi bekleyen buyruk var ve kabul edilmiyor, Getir1'i duraklat
            ps_gecerli_ns = `LOW;
        end
        else begin // Getir2'yi bekleyen buyruk yok ya da var ve su an kabul ediliyor
            g2_ps_ns = ps_cmb;
            g2_ps_gecerli_ns = `HIGH;
            ps_ns = ps_cmb + 3'd4;
            ps_gecerli_ns = `HIGH;
        end
    end
end

always @(posedge clk_i) begin
    if (!rstn_i) begin
        ps_r <= `BELLEK_BASLANGIC;
        ps_gecerli_r <= `HIGH;
        g2_ps_r <= `BELLEK_BASLANGIC;
        g2_ps_gecerli_r <= `LOW;
    end
    else begin
        ps_r <= ps_ns;
        ps_gecerli_r <= ps_gecerli_ns;
        g2_ps_r <= g2_ps_ns;
        g2_ps_gecerli_r <= g2_ps_gecerli_ns;
    end
end

assign l1b_istek_adres_o = ps_cmb;
assign l1b_istek_gecerli_o = ps_gecerli_cmb;
assign g2_ps_o = g2_ps_r;
assign g2_ps_gecerli_o = g2_ps_gecerli_r;
assign g2_istek_yapildi_o = g2_istek_yapildi_cmb;

endmodule