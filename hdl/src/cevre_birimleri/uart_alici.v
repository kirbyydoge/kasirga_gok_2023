`timescale 1ns / 1ps

`include "mikroislem.vh"
`include "sabitler.vh"

module uart_alici (
    input                   clk_i,
    input                   rstn_i,
    
    input                   basla_i,
    input                   gelen_veri_gecerli_i,
    
    input [7:0]             gelen_veri_i,
    input [15:0]            baud_div_i,
    
    input                   rx,
    output                  bitti
    
);

endmodule