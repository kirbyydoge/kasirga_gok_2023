`timescale 1ns / 1ps

`include "mikroislem.vh"
`include "sabitler.vh"

module uart_verici (
    input                   clk_i,
    input                   rstn_i,
    
    input                   tx_en_i,              // tx_en
    input                   veri_gecerli_i, // !fifo_empty
    output                  consume_o,

    input [7:0]             gelen_veri_i,
    input [15:0]            baud_div_i,
    
    output                  tx_o,
    output                  hazir_o
);

localparam BOSTA = 0;
localparam BASLA = 1;
localparam VERI_GONDER = 2;
localparam BITTI = 3;

reg [1:0] durum_r;
reg [1:0] durum_ns;

reg [15:0] sayac_r;
reg [15:0] sayac_ns;

reg [2:0] gonderilecek_veri_biti_r;
reg [2:0] gonderilecek_veri_biti_ns;

reg [7:0] buf_veri_r;
reg [7:0] buf_veri_ns;

reg tx_cmb;
reg hazir_cmb;
reg saat_aktif_cmb;

reg consume_cmb;

always @* begin
    tx_cmb = `HIGH;
    hazir_cmb = `LOW;
    saat_aktif_cmb = `LOW;
    durum_ns = durum_r;
    gonderilecek_veri_biti_ns = gonderilecek_veri_biti_r;
    consume_cmb = `LOW;
    buf_veri_ns = buf_veri_r;

    sayac_ns = sayac_r + 1;
    saat_aktif_cmb = sayac_r == baud_div_i - 1;
    if (sayac_r == baud_div_i - 1) begin
        sayac_ns = 0;
    end

    case (durum_r) 
        BOSTA: begin
            if (tx_en_i && veri_gecerli_i) begin
                consume_cmb = `HIGH;
                durum_ns = BASLA;
                sayac_ns = 16'd0;
                buf_veri_ns = gelen_veri_i;
                gonderilecek_veri_biti_ns = 0;
            end    
        end
        BASLA: begin
            tx_cmb = `LOW;
            if (saat_aktif_cmb) begin
                durum_ns = VERI_GONDER;
            end
        end
        VERI_GONDER: begin
            tx_cmb = buf_veri_r[gonderilecek_veri_biti_r];
            if (saat_aktif_cmb) begin
                gonderilecek_veri_biti_ns = gonderilecek_veri_biti_r + 1;
                if (gonderilecek_veri_biti_r == 3'd7) begin
                    durum_ns = BITTI;
                end
            end
        end
        BITTI: begin
            tx_cmb = `HIGH;
            if (saat_aktif_cmb) begin
                durum_ns = BOSTA;
                hazir_cmb = `HIGH;
            end        
        end
    endcase
end

always @ (posedge clk_i) begin
    if (!rstn_i) begin
        durum_r <= BOSTA;
        sayac_r <= 0;
        gonderilecek_veri_biti_r <= 0; // En anlamsız bitten yollamaya başlanır.
        buf_veri_r <= 0;
    end
    else begin
        durum_r <= durum_ns; 
        sayac_r <= sayac_ns;
        gonderilecek_veri_biti_r <= gonderilecek_veri_biti_ns;
        buf_veri_r <= buf_veri_ns;
    end
end

assign tx_o = tx_cmb;
assign hazir_o = hazir_cmb;
assign consume_o = consume_cmb;

endmodule