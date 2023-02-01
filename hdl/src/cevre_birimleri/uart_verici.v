`timescale 1ns / 1ps

`include "mikroislem.vh"
`include "sabitler.vh"

module uart_verici (
    input                   clk_i,
    input                   rstn_i,
    
    input                   basla_i,
    input                   gelen_veri_gecerli_i,
    
    input [7:0]             gelen_veri_i,
    input [15:0]            baud_div_i,
    
    output                  tx,
    output                  hazir_o
);

localparam BOSTA = 0;
localparam VERI_GONDER = 1;
localparam BITTI = 2;

reg [1:0] durum_r;
reg [1:0] durum_ns;

reg [15:0] sayac_r;
reg [15:0] sayac_ns;

reg [2:0] gonderilecek_veri_biti_r;
reg [2:0] gonderilecek_veri_biti_ns;

reg tx_r;
reg hazir_r;
reg saat_aktif;


always @* begin
    durum_ns = durum_r;
    sayac_ns = sayac_r;
    gonderilecek_veri_biti_ns =gonderilecek_veri_biti_r;

    saat_aktif = sayac_r == baud_div_i - 1;
    if (sayac_r == baud_div_i) begin
        sayac_ns = 0;
    end

    case (durum_r) 
        BOSTA: begin
            if (basla_i && gelen_veri_gecerli_i) begin
                tx_r = `LOW;
                durum_ns = VERI_GONDER;
            end    
        end
        VERI_GONDER: begin
            if (saat_aktif) begin
                tx_r = gelen_veri_i [gonderilecek_veri_biti_r];
                gonderilecek_veri_biti_ns = gonderilecek_veri_biti_r + 1;
                if (gonderilecek_veri_biti_r == 3'd7) begin
                    durum_ns = BITTI;
                    gonderilecek_veri_biti_ns = 0;
                end
                else begin
                    durum_ns = VERI_GONDER;
                end
            end
            else begin
                sayac_ns = sayac_r + 1;
                durum_ns = VERI_GONDER;
            end
            
        end
        BITTI: begin
            if (saat_aktif) begin
                tx_r = `HIGH;
                durum_ns = BOSTA;
                hazir_r = `HIGH;
            end
            else begin
                sayac_ns = sayac_r + 1;
            end            
        end
    endcase
end

always @ (posedge clk_i) begin
    if (!rstn_i) begin
        durum_r <= BOSTA;
        sayac_r <= 0;
        gonderilecek_veri_biti_r <= 0; // En anlamsız bitten yollamaya başlanır.
    end
    else begin
        durum_r <= durum_ns; 
        sayac_r <= sayac_ns;
        gonderilecek_veri_biti_r <= gonderilecek_veri_biti_ns;
    end
end

assign tx = tx_r;
assign hazir_o = hazir_r;

endmodule