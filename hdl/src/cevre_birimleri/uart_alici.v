`timescale 1ns / 1ps

`include "mikroislem.vh"
`include "sabitler.vh"

module uart_alici (
    input                   clk_i,
    input                   rstn_i,

    output [7:0]            alinan_veri_o,
    input [15:0]            baud_div_i,
    
    input                   rx_i,
    output                  hazir_o,
    output                  alinan_veri_gecerli_o
    
);

localparam BOSTA = 0;
localparam VERI_AL = 1;
localparam BITTI = 2;

reg [7:0] alinan_veri;


reg [1:0] durum_r;
reg [1:0] durum_ns;

reg [15:0] sayac_r;
reg [15:0] sayac_ns;

reg [2:0] alinan_veri_biti_r;
reg [2:0] alinan_veri_biti_ns;

reg hazir_cmb;
reg saat_aktif_cmb;
reg alinan_veri_gecerli_cmb;

always @* begin
    hazir_cmb = `LOW;
    saat_aktif_cmb = `LOW;
    alinan_veri_gecerli_cmb = `LOW;
    durum_ns = durum_r;
    sayac_ns = sayac_r;
    alinan_veri_biti_ns = alinan_veri_biti_r;

    saat_aktif_cmb = sayac_r == baud_div_i - 1;
    if (sayac_r == baud_div_i - 1) begin
        sayac_ns = 0;
    end

    case (durum_r) 
        BOSTA: begin
            if (rx_i == `LOW) begin 
                durum_ns = VERI_AL;
                sayac_ns = 16'd0;
            end    
        end
        VERI_AL: begin
            if (saat_aktif_cmb) begin
                alinan_veri [alinan_veri_biti_r] = rx_i;
                alinan_veri_biti_ns = alinan_veri_biti_r + 1;
                if (alinan_veri_biti_r == 3'd7) begin
                    durum_ns = BITTI;
                    alinan_veri_biti_ns = 0;
                end
                else begin
                    durum_ns = VERI_AL;
                end
            end
            else begin
                sayac_ns = sayac_r + 1;
                durum_ns = VERI_AL;
            end
            
        end
        BITTI: begin
            if (saat_aktif_cmb) begin
                alinan_veri_gecerli_cmb = `HIGH;
                durum_ns = BOSTA;
                hazir_cmb = `HIGH;
            end
            else begin
                durum_ns = BITTI;
                sayac_ns = sayac_r + 1;
            end
        end
    endcase
end

always @ (posedge clk_i) begin
    if (!rstn_i) begin
        durum_r <= BOSTA;
        sayac_r <= 0;
        alinan_veri_biti_r <= 0; // En anlamsız bitten yollamaya başlanır.
    end
    else begin
        durum_r <= durum_ns; 
        sayac_r <= sayac_ns;
        alinan_veri_biti_r <= alinan_veri_biti_ns;
    end
end

assign tx = tx_r;
assign hazir_o = hazir_cmb;
assign alinan_veri_o = alinan_veri;
assign alinan_veri_gecerli_o = alinan_veri_gecerli_cmb;



endmodule