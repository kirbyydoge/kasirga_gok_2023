`timescale 1ns/1ps

`include "sabitler.vh"

module tb_dallanma_ongorucu();

reg                       clk;
reg                       rstn_r;
reg   [`PS_BIT-1:0]       ps_r;
reg                       ps_gecerli_r;
reg   [`PS_BIT-1:0]       yurut_ps_r;
reg                       yurut_guncelle_r; // dallanma buyruğuysa yürütten güncelleme gelecek
reg                       yurut_atladi_r; // atladı mi bilgisi
reg   [`PS_BIT-1:0]       yurut_atlanan_adres_r; // eğer dallanma atladıysa target neresi bilgisi TODO: yürüte eklenecek
reg                       yurut_hatali_tahmin_r; //hatalı tahmin
wire                      atladi_w; // Branch taken    
wire  [`PS_BIT-1:0]       ongoru_w;  // Nereye atlayacağı --- Getir 1'e giden sinyal

always begin
    clk = 1'b0;
    #5;
    clk = 1'b1;
    #5;
end
dallanma_ongorucu do (
.clk_i (clk),
.rstn_i (rstn_r),
.ps_i (ps_r),
.ps_gecerli_i (ps_gecerli_r),
.yurut_ps_i (yurut_ps_r),
.yurut_guncelle_i (yurut_guncelle_r), // dallanma buyruğuysa yürütten güncelleme gelecek
.yurut_atladi_i (yurut_atladi_r), // atladı mi bilgisi
.yurut_atlanan_adres_i (yurut_atlanan_adres_r), // eğer dallanma atladıysa target neresi bilgisi TODO: yürüte eklenecek
.yurut_hatali_tahmin_i (yurut_hatali_tahmin_r),  // hatalı tahmin
.atladi_o (atladi_w), // Branch taken    
.ongoru_o (ongoru_w)
);

integer i;
initial begin
    rstn_r = 0;
    @(posedge clk); #2;
    @(posedge clk); #2;
    @(posedge clk); #2;
    @(posedge clk); #2;
    rstn_r = 1;
    @(posedge clk); #2;
    for (i = 0; i<10000; i = i + 1) begin
        yurut_ps_r = i;
        yurut_guncelle_r = 1; 
        yurut_atladi_r = 1;
        yurut_atlanan_adres_r = (i+3);
        yurut_hatali_tahmin_r = 1; 
        @(posedge clk); #2;  
    end







    // ps_r = 32'h0101_0101;
    // ps_gecerli_r = 1;

    // @(posedge clk); #2;
    // ps_r = 32'hdead_beef;
    // ps_gecerli_r = 1;

    // @(posedge clk); #2;
    // yurut_ps_r = 32'h0101_0003;
    // yurut_guncelle_r = 1;
    // yurut_atladi_r = 1;
    // yurut_atlanan_adres_r = 32'hbaba_baba;
    // yurut_hatali_tahmin_r = 1;

    // @(posedge clk); #2;
    // yurut_guncelle_r = 0;

    // @(posedge clk); #2;
    // yurut_ps_r = 32'hcccc_abab;
    // yurut_guncelle_r = 1;
    // yurut_atladi_r = 1;
    // yurut_atlanan_adres_r = 32'haaba_aaaa;
    // yurut_hatali_tahmin_r = 1;

    // @(posedge clk); #2;
    // yurut_guncelle_r = 0;
    // ps_r = 32'h0101_0000;
    // ps_gecerli_r = 1;
end
endmodule