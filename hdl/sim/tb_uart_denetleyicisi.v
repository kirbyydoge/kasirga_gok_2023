`timescale 1ns/1ps

`include "sabitler.vh"

module tb_uart_denetleyicisi();

reg                      clk;
reg                      resetn;
reg  [`ADRES_BIT-1:0]    cek_adres_r;
reg  [`VERI_BIT-1:0]     cek_veri_r;
reg                      cek_yaz_r;
reg                      cek_gecerli_r;
wire                     cek_hazir_w;
wire [`VERI_BIT-1:0]     uart_veri_w;
wire                     uart_gecerli_w;
reg                      uart_hazir_r;
reg                      rx_r;
wire                     tx_w;


uart_denetleyicisi denetleyici (
    .clk_i               ( clk ),
    .rstn_i              ( resetn ),
    .cek_adres_i         ( cek_adres_r ),
    .cek_veri_i          ( cek_veri_r ),
    .cek_yaz_i           ( cek_yaz_r ),
    .cek_gecerli_i       ( cek_gecerli_r ),
    .cek_hazir_o         ( cek_hazir_w ),
    .uart_veri_o         ( uart_veri_w ),
    .uart_gecerli_o      ( uart_gecerli_w ),
    .uart_hazir_i        ( uart_hazir_r ),
    .rx_i                ( rx_r ),
    .tx_o                ( tx_w )
);


always begin
    clk = 1'b0;
    #5;
    clk = 1'b1;
    #5;
end

initial begin
    resetn = `LOW;
    #200;
    resetn = `HIGH;
    #5;

    cek_adres_r = 32'h2000_0000;
    cek_veri_r = 32'b0000_0000_1111_1111_0000_0000_0000_0011; //rx etkinleştir
    cek_yaz_r = `HIGH;
    cek_gecerli_r = `HIGH;
    uart_hazir_r = `HIGH;


    cek_adres_r = 32'h20000004;
    cek_veri_r = 32'b0000_0000_1111_1111_0000_0000_0000_0011; 
    cek_yaz_r = `LOW;
    cek_gecerli_r = `HIGH;
    uart_hazir_r = `HIGH; #5;

    cek_adres_r = 32'h2000000c;
    cek_veri_r = 32'b0000_0000_1111_1111_0000_0000_0000_0011; 
    cek_yaz_r = `HIGH;
    cek_gecerli_r = `HIGH;
    uart_hazir_r = `HIGH; #5;
    rx_r = 1'b0; #5; //start
    rx_r = 1'b1; #5;
    rx_r = 1'b0; #5;
    rx_r = 1'b1; #5;
    rx_r = 1'b0; #5;
    rx_r = 1'b1; #5;
    rx_r = 1'b0; #5;
    rx_r = 1'b1; #5;
    rx_r = 1'b0; #5;
    rx_r = 1'b1; #5; // stop


    // cek_adres_r = 32'h20000008;
    // cek_veri_r = 32'b0000_0000_1111_1111_0000_0000_0000_0011; 
    // cek_yaz_r = `LOW;
    // cek_gecerli_r = `HIGH;
    // uart_hazir_r = `HIGH; #5;
    // rx_r = 1'b0; #5; //start
    // rx_r = 1'b1; #5;
    // rx_r = 1'b0; #5;
    // rx_r = 1'b1; #5;
    // rx_r = 1'b0; #5;
    // rx_r = 1'b1; #5;
    // rx_r = 1'b0; #5;
    // rx_r = 1'b1; #5;
    // rx_r = 1'b0; #5;
    // rx_r = 1'b1; #5; // stop
    // #5;
  
end
endmodule