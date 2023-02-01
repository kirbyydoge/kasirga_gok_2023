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
    output                  bitti
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

reg tx_r;
reg bitti_r;


always @* begin
    durum_ns = durum_r;
    sayac_ns = sayac_r;
    gonderilecek_veri_biti_ns =gonderilecek_veri_biti_r;
    case (durum_r) 
        BOSTA: begin
            if (basla_i && gelen_veri_gecerli_i) begin
                durum_ns = BASLA;
                tx_r = `LOW;
            end
        end
        BASLA: begin
             if (sayac_r <= baud_div_i - 1)begin
                durum_ns = BASLA;
                sayac_ns = sayac_r + 16'd1;
            end
            else begin
                sayac_ns = 16'd0;
                durum_ns = VERI_GONDER;
            end
        end
        VERI_GONDER: begin
            tx_r = gelen_veri_i [gonderilecek_veri_biti_r];
            gonderilecek_veri_biti_ns = gonderilecek_veri_biti_r + 3'd1;
            if (gonderilecek_veri_biti_r == 3'd7) begin
                durum_ns = BITTI;
                gonderilecek_veri_biti_r = 3'd0;
            end
            else begin
                durum_ns = BASLA;
            end
        end
        BITTI: begin
            if (sayac_r <= baud_div_i - 1)begin
                durum_ns = BITTI;
                sayac_ns = sayac_r + 16'd1;
            end
            else begin
                sayac_ns = 16'd0;
                bitti_r = `HIGH;
                tx_r = `HIGH;
                durum_ns = BOSTA;
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
assign bitti = bitti_r;

endmodule