`timescale 1ns/1ps

`include "sabitler.vh"
`include "mikroislem.vh"

module bellek (
    input                       clk_i,
    input                       rstn_i,

    //veri yolu birimi + l1 denetleyici 
    //Okuma girdileri
    input   [`VERI_BIT-1:0]     l1v_veri_i,
    input                       l1v_veri_gecerli_i,
    output                      l1v_veri_hazir_o,
    //Yazma
    input                       l1v_istek_hazir_i,
    output  [`PS_BIT-1:0]       l1v_istek_adres_o,
    output                      l1v_istek_gecerli_o,

    //duraklat
    output                      cek_duraklat_o,

    //mikroişlem giriş çıkışları
    input   [`UOP_BIT-1:0]          bellek_uop_i,
    output  [`UOP_BIT-1:0]          geri_yaz_uop_o

);

reg [`UOP_BIT-1:0]              uop_r;
reg [`UOP_BIT-1:0]              uop_ns;

wire                            uop_gecerli_w;
wire [`UOP_BEL_BIT-1:0]         uop_buyruk_secim_r;
wire [`UOP_RS2_BIT-1:0]         uop_rs1_w;
wire [`UOP_RS1_BIT-1:0]         uop_rs2_w;



//x0'a Load yapmaya kalkarsa exception atmalı
//Bellek sistemi littşe-endian (küçüğü başta)
//12 bit offset sign extended olmalı

always @* begin
    uop_ns = yurut_uop_i;
    uop_ns[`UOP_VALID] = `HIGH; // simdilik her sey tek cevrim
    uop_ns[`UOP_RD] = kaynak_sec(uop_yaz_sec_w);
    duraklat_cmb = `LOW; // asla duraklatma




end

always @(posedge clk_i) begin
    if (!rstn_i) begin
        uop_r <= {`UOP_BIT{`LOW}};
    end
    else begin
        uop_r <= uop_ns;
    end
end




endmodule