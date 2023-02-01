`timescale 1ns/1ps

`include "sabitler.vh"

module uart_denetleyicisi (
    input                       clk_i,
    input                       rstn_i,

    input   [`ADRES_BIT-1:0]    cek_adres_i,
    input   [`VERI_BIT-1:0]     cek_veri_i,
    input                       cek_yaz_i,
    input                       cek_gecerli_i,
    output                      cek_hazir_o,

    output  [`VERI_BIT-1:0]     uart_veri_o,
    output                      uart_gecerli_o,
    input                       uart_hazir_i,

    input                       rx_i,
    output                      tx_o
);

wire        cek_uart_istek_w;
wire [3:0]  cek_uart_addr_w; // niye 4 bit???

assign cek_uart_istek_w = ((cek_adres_i & ~`UART_MASK_ADDR) == `UART_BASE_ADDR) && cek_gecerli_i;
assign cek_uart_addr_w = cek_adres_i & `UART_MASK_ADDR;


reg [31:0] uart_ctr;
reg [3:0] uart_status;
reg [7:0] uart_rdata;
reg [7:0] uart_wdata;


fifo #(
    .DATA_WIDTH(32),
    .DATA_DEPTH(8)
)rx_buffer(
    .clk_i    ( clk_i ),         
    .rstn_i   ( rstn_i ),         
    .data_i   (  ),         
    .wr_en_i  (  ),         
    .data_o   (  ),         
    .rd_en_i  (  ),         
    .full_o   (  ),         
    .empty_o  (  )         
);

fifo tx_buffer (
    
);

endmodule