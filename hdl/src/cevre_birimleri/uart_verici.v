`timescale 1ns / 1ps

`include "mikroislem.vh"
`include "sabitler.vh"

module uart_verici (
    input                   clk_i,
    input                   rstn_i,
    
    input                   basla_i,
    input [7:0]             gelen_veri_i,
    input [15:0]            baud_div_i,
    
    output                  tx,
    output                  bitti
);

localparam BEKLE = 0;
localparam BASLA = 1;
localparam VERI_GONDER = 2;
localparam BITTI = 3;

reg [1:0] durum_r;
reg [1:0] durum_ns;


always @* begin
    durum_ns = durum_r;
    case (durum_r) 
        BEKLE: begin

        end
        BASLA: begin

        end
        VERI_GONDER: begin

        end
        BITTI: begin

        end
    endcase
end

always @ (posedge clk_i) begin
    if (!rstn_i) begin
        durum_r <= BEKLE;
    end
    else begin
        durum_r <= durum_ns; 
    end
end



endmodule