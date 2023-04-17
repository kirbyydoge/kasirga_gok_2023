`timescale 1ns / 1ps

`include "mikroislem.vh"
`include "sabitler.vh"

module uart_alici (
    input                   clk_i,
    input                   rstn_i,

    input                   rx_en_i,
    output [7:0]            alinan_veri_o,
    output                  alinan_gecerli_o,
    input [15:0]            baud_div_i,
    
    input                   rx_i
    
);

localparam BOSTA = 0;
localparam START_AL = 1;
localparam VERI_AL = 2;
localparam BITTI = 3;

reg [7:0] alinan_veri_ns;
reg [7:0] alinan_veri_r;

reg [1:0] durum_r;
reg [1:0] durum_ns;

reg [15:0] sayac_r;
reg [15:0] sayac_ns;

reg [3:0] alinan_veri_biti_r;
reg [3:0] alinan_veri_biti_ns;

reg sample0_aktif_cmb;
reg sample1_aktif_cmb;
reg sample2_aktif_cmb;

reg sample0_r;
reg sample0_ns;

reg sample1_r;
reg sample1_ns;

reg sample2_r;
reg sample2_ns;

reg rx_past0_r;
reg rx_past0_ns;

reg rx_past1_r;
reg rx_past1_ns;

reg hazir_cmb;
reg saat_aktif_cmb;
reg alinan_veri_gecerli_cmb;
reg sample_maj_cmb;

always @* begin
   rx_past0_ns = rx_i;
   rx_past1_ns = rx_past0_r;

   hazir_cmb = `LOW;
   saat_aktif_cmb = `LOW;
   alinan_veri_gecerli_cmb = `LOW;
   durum_ns = durum_r;
   sayac_ns = sayac_r;
   alinan_veri_biti_ns = alinan_veri_biti_r;
   alinan_veri_ns = alinan_veri_r;

   sayac_ns = sayac_r + 1;

   saat_aktif_cmb = sayac_r == baud_div_i;
   sample0_aktif_cmb = sayac_r == (baud_div_i / 20 * 9);
   sample1_aktif_cmb = sayac_r == (baud_div_i / 20 * 10);
   sample2_aktif_cmb = sayac_r == (baud_div_i / 20 * 11);

   if (saat_aktif_cmb) begin
      sayac_ns = 0;
   end

   if (sample0_aktif_cmb) begin
      sample0_ns = rx_past1_r;
   end

   if (sample1_aktif_cmb) begin
      sample1_ns = rx_past1_r;
   end

   if (sample2_aktif_cmb) begin
      sample2_ns = rx_past1_r;
   end

   sample_maj_cmb = (sample0_r && sample1_r) || (sample1_r && sample2_r) || (sample0_r && sample2_r);

   case (durum_r) 
      BOSTA: begin
         if (rx_i == `LOW && rx_en_i) begin 
            durum_ns = START_AL;
            sayac_ns = 16'd0;
            alinan_veri_biti_ns = 0;
         end    
      end
      START_AL: begin
         if (saat_aktif_cmb) begin
            durum_ns = sample_maj_cmb ? BOSTA : VERI_AL;
         end
      end
      VERI_AL: begin
         if (saat_aktif_cmb) begin
            alinan_veri_ns[alinan_veri_biti_r] = sample_maj_cmb;
            if (alinan_veri_biti_r == 4'd7) begin
               durum_ns = BITTI;
            end
         end
      end
      BITTI: begin
         if (sample2_aktif_cmb) begin
            alinan_veri_gecerli_cmb = `HIGH;
            durum_ns = BOSTA;
            hazir_cmb = `HIGH;
         end
      end
   endcase
end

always @ (posedge clk_i) begin
   if (!rstn_i) begin
      durum_r <= BOSTA;
      sayac_r <= 16'd0;
      alinan_veri_biti_r <= 0; 
      rx_past0_r <= 0;
      rx_past1_r <= 0;
      sample0_r <= 0;
      sample1_r <= 0;
      sample2_r <= 0;
   end
   else begin
      durum_r <= durum_ns; 
      sayac_r <= sayac_ns;
      alinan_veri_biti_r <= alinan_veri_biti_ns;
      alinan_veri_r <= alinan_veri_ns;
      rx_past0_r <= rx_past0_ns;
      rx_past1_r <= rx_past1_ns;
      sample0_r <= sample0_ns;
      sample1_r <= sample1_ns;
      sample2_r <= sample2_ns;
   end
end

assign alinan_veri_o = alinan_veri_r;
assign alinan_gecerli_o = alinan_veri_gecerli_cmb;

endmodule