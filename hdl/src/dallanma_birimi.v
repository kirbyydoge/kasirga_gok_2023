`timescale 1ns/1ps

`include "sabitler.vh"
`include "mikroislem.vh"

module dallanma_birimi (
   input   [`UOP_DAL_BIT-1:0]  islem_kod_i,
   input   [`PS_BIT-1:0]       islem_ps_i,
   input   [`PS_BIT-1:0]       islem_islec_i,
   input   [`VERI_BIT-1:0]     islem_anlik_i,
   input                       islem_atladi_i,
   input                       islem_rvc_i,

   input                       amb_esittir_i,
   input                       amb_kucuktur_i,
   input                       amb_kucuktur_isaretsiz_i,

   output  [`PS_BIT-1:0]       g1_ps_o,
   output                      g1_ps_gecerli_o,

   output  [`PS_BIT-1:0]       g2_ps_o,
   output  [`PS_BIT-1:0]       g2_hedef_ps_o,
   output                      g2_guncelle_o,
   output                      g2_atladi_o,
   output                      g2_hatali_tahmin_o,

   output  [`PS_BIT-1:0]       ps_atlamadi_o
);

reg [`PS_BIT-1:0]   g1_ps_cmb;
reg                 g1_ps_gecerli_cmb;
reg [`PS_BIT-1:0]   g2_ps_cmb;
reg [`PS_BIT-1:0]   g2_hedef_ps_cmb;
reg                 g2_guncelle_cmb;
reg                 g2_atladi_cmb;
reg                 g2_hatali_tahmin_cmb;

reg  [`VERI_BIT-1:0]    toplayici_is0_cmb;
reg  [`VERI_BIT-1:0]    toplayici_is1_cmb;
wire [`VERI_BIT-1:0]    toplayici_sonuc_w;

reg [`PS_BIT-1:0]   ps_atladi_cmb;
reg [`PS_BIT-1:0]   ps_atlamadi_cmb;

always @* begin
   g1_ps_cmb = {`PS_BIT{1'b0}};
   g1_ps_gecerli_cmb = `LOW;
   g2_ps_cmb = {`PS_BIT{1'b0}};
   g2_hedef_ps_cmb = {`PS_BIT{1'b0}};
   g2_guncelle_cmb = `LOW;
   g2_atladi_cmb = `LOW;
   g2_hatali_tahmin_cmb = `LOW;

   toplayici_is0_cmb = islem_islec_i;
   toplayici_is1_cmb = islem_anlik_i;
   ps_atladi_cmb = toplayici_sonuc_w;

   ps_atlamadi_cmb = islem_rvc_i   ? islem_ps_i + {{`VERI_BIT-4{1'b0}}, 4'd2}
                           : islem_ps_i + {{`VERI_BIT-4{1'b0}}, 4'd4};

   case(islem_kod_i)
   `UOP_DAL_BEQ: begin
      g2_ps_cmb = islem_ps_i;
      g2_guncelle_cmb = `HIGH;
      g2_atladi_cmb = amb_esittir_i;
      g2_hatali_tahmin_cmb = amb_esittir_i != islem_atladi_i;

      g1_ps_cmb = g2_atladi_cmb ? ps_atladi_cmb : ps_atlamadi_cmb;
      g1_ps_gecerli_cmb = g2_hatali_tahmin_cmb;
   end
   `UOP_DAL_BNE: begin
      g2_ps_cmb = islem_ps_i;
      g2_guncelle_cmb = `HIGH;
      g2_atladi_cmb = !amb_esittir_i;
      g2_hatali_tahmin_cmb = amb_esittir_i == islem_atladi_i;

      g1_ps_cmb = g2_atladi_cmb ? ps_atladi_cmb : ps_atlamadi_cmb;
      g1_ps_gecerli_cmb = g2_hatali_tahmin_cmb;
   end
   `UOP_DAL_BLT: begin
      g2_ps_cmb = islem_ps_i;
      g2_guncelle_cmb = `HIGH;
      g2_atladi_cmb = amb_kucuktur_i;
      g2_hatali_tahmin_cmb = amb_kucuktur_i != islem_atladi_i;

      g1_ps_cmb = g2_atladi_cmb ? ps_atladi_cmb : ps_atlamadi_cmb;
      g1_ps_gecerli_cmb = g2_hatali_tahmin_cmb;
   end
   `UOP_DAL_BGE: begin
      g2_ps_cmb = islem_ps_i;
      g2_guncelle_cmb = `HIGH;
      g2_atladi_cmb = !amb_kucuktur_i;
      g2_hatali_tahmin_cmb = amb_kucuktur_i == islem_atladi_i;

      g1_ps_cmb = g2_atladi_cmb ? ps_atladi_cmb : ps_atlamadi_cmb;
      g1_ps_gecerli_cmb = g2_hatali_tahmin_cmb;
   end
   `UOP_DAL_BLTU: begin
      g2_ps_cmb = islem_ps_i;
      g2_guncelle_cmb = `HIGH;
      g2_atladi_cmb = amb_kucuktur_isaretsiz_i;
      g2_hatali_tahmin_cmb = amb_kucuktur_isaretsiz_i != islem_atladi_i;

      g1_ps_cmb = g2_atladi_cmb ? ps_atladi_cmb : ps_atlamadi_cmb;
      g1_ps_gecerli_cmb = g2_hatali_tahmin_cmb;
   end
   `UOP_DAL_BGEU: begin
      g2_ps_cmb = islem_ps_i;
      g2_guncelle_cmb = `HIGH;
      g2_atladi_cmb = !amb_kucuktur_isaretsiz_i;
      g2_hatali_tahmin_cmb = amb_kucuktur_isaretsiz_i == islem_atladi_i;

      g1_ps_cmb = g2_atladi_cmb ? ps_atladi_cmb : ps_atlamadi_cmb;
      g1_ps_gecerli_cmb = g2_hatali_tahmin_cmb;
   end
   `UOP_DAL_JAL: begin
      g2_ps_cmb = islem_ps_i;
      g2_guncelle_cmb = `LOW;
      g2_atladi_cmb = `HIGH;
      g2_hatali_tahmin_cmb = `HIGH;

      g1_ps_cmb = ps_atladi_cmb;
      g1_ps_gecerli_cmb = g2_hatali_tahmin_cmb;
   end
   `UOP_DAL_JALR: begin
      g2_ps_cmb = islem_ps_i;
      g2_guncelle_cmb = `LOW;
      g2_atladi_cmb = `HIGH;
      g2_hatali_tahmin_cmb = `HIGH;

      g1_ps_cmb = (ps_atladi_cmb) & ~1;
      g1_ps_gecerli_cmb = g2_hatali_tahmin_cmb;
   end
   `UOP_DAL_CJALR: begin
      g2_ps_cmb = islem_ps_i;
      g2_guncelle_cmb = `LOW;
      g2_atladi_cmb = `HIGH;
      g2_hatali_tahmin_cmb = `HIGH;

      g1_ps_cmb = (ps_atladi_cmb) & ~1;
      g1_ps_gecerli_cmb = g2_hatali_tahmin_cmb;

      ps_atlamadi_cmb = islem_ps_i + {{`VERI_BIT-4{1'b0}}, 4'd2};
   end
   `UOP_DAL_CJAL: begin
      g2_ps_cmb = islem_ps_i;
      g2_guncelle_cmb = `LOW;
      g2_atladi_cmb = `HIGH;
      g2_hatali_tahmin_cmb = `HIGH;

      g1_ps_cmb = ps_atladi_cmb;
      g1_ps_gecerli_cmb = g2_hatali_tahmin_cmb;

      ps_atlamadi_cmb = islem_ps_i + {{`VERI_BIT-4{1'b0}}, 4'd2};
   end
   endcase

   g2_hedef_ps_cmb = g2_atladi_cmb ? ps_atladi_cmb : ps_atlamadi_cmb;
end

assign g1_ps_o = g1_ps_cmb;
assign g1_ps_gecerli_o = g1_ps_gecerli_cmb;
assign g2_ps_o = g2_ps_cmb;
assign g2_hedef_ps_o = g2_hedef_ps_cmb;
assign g2_guncelle_o = g2_guncelle_cmb;
assign g2_atladi_o = g2_atladi_cmb;
assign g2_hatali_tahmin_o = g2_hatali_tahmin_cmb;
assign ps_atlamadi_o = ps_atlamadi_cmb;

toplayici topla (
   .islec0_i ( toplayici_is0_cmb ),
   .islec1_i ( toplayici_is1_cmb ),
   .carry_i  ( 1'b0 ),
   .toplam_o ( toplayici_sonuc_w ),
   .carry_o  ()
);


endmodule