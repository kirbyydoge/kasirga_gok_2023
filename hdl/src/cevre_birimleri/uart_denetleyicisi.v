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
wire [3:0]  cek_uart_addr_w;

assign cek_uart_istek_w = ((cek_adres_i & ~`UART_MASK_ADDR) == `UART_BASE_ADDR) && cek_gecerli_i;
assign cek_uart_addr_w = cek_adres_i & `UART_MASK_ADDR;


reg [31:0] uart_ctrl_r;
reg [31:0] uart_ctrl_ns;
wire tx_en_w;
wire rx_en_w;
wire [15:0] baud_div;

wire [3:0] uart_status_w;
reg [7:0] uart_rdata;
reg [7:0] uart_wdata;

reg [1:0] durum_r;
reg [1:0] durum_ns;

localparam BOSTA = 0;
localparam VERICI_CALISTIR = 1;
localparam ALICI_CALISTIR = 2;

// ------------ FIFO TX BUFFER I/O-----------------//
reg  [7:0] tx_fifoya_yazilacak_data_cmb;
reg        tx_fifo_wr_en_cmb;
wire [7:0] tx_fifodan_okunan_data_w;
reg        tx_fifo_rd_en_cmb;
wire       tx_fifo_full_w;
wire       tx_fifo_empty;
// ------------ FIFO RX BUFFER I/O-----------------//
reg  [7:0] rx_fifoya_yazilacak_data_cmb;
reg        rx_fifo_wr_en_cmb;
wire [7:0] rx_fifodan_okunan_data_w;
reg        rx_fifo_rd_en_cmb;
wire       rx_fifo_full_w;
wire       rx_fifp_empty;
// ------------ UART ALICI I/O --------------------//
wire [7:0]            alici_alinan_veri_w;
reg [15:0]            alici_baud_div_cmb;
reg                   alici_rx_cmb;
wire                  alici_hazir_w;
wire                  alici_alinan_veri_gecerli_w;
// ------------ UART VERICI I/O -------------------//
reg                   verici_basla_cmb;
reg                   verici_gelen_veri_gecerli_cmb;  
reg [7:0]             verici_gelen_veri_cmb;
reg [15:0]            verici_baud_div_cmb;
wire                  verici_tx_w;
wire                  verici_hazir_w;

always @* begin
    durum_ns = durum_r;
    tx_fifoya_yazilacak_data_cmb = 8'd0;
    tx_fifo_wr_en_cmb = `LOW;
    tx_fifo_rd_en_cmb = `LOW;
    rx_fifoya_yazilacak_data_cmb = 8'd0;
    rx_fifo_wr_en_cmb = `LOW;
    rx_fifo_rd_en_cmb = `LOW;
    
    alici_baud_div_cmb = 16'd0;
    alici_rx_cmb = `HIGH; // baslarken low'a çek
    verici_basla_cmb = `LOW;
    verici_gelen_veri_gecerli_cmb = `LOW;
    verici_gelen_veri_cmb = 8'd0;
    verici_baud_div_cmb = 16'd0;


    case (durum_r)
        BOSTA: begin
            if (cek_uart_istek_w) begin
                case (cek_uart_addr_w) 
                    `UART_CTRL_REG: begin
                        uart_ctrl_ns = cek_veri_i;
                        if (tx_en_w == `HIGH && !tx_fifo_empty) begin
                            verici_basla_cmb = `HIGH;  
                            verici_gelen_veri_gecerli_cmb = `HIGH; 
                            // OĞuzhana SOr
                        end

                    end
                    `UART_STATUS_REG: begin

                    end
                    `UART_RDATA_REG: begin

                    end
                    `UART_WDATA_REG: begin

                    end

                endcase
            end    
        end
        VERICI_CALISTIR: begin

        end
        ALICI_CALISTIR: begin

        end
    endcase


end

always @ (posedge clk_i) begin
    if (!rstn_i) begin
            durum_r <= BOSTA;
            uart_ctrl_r <= 32'd0;
            
        end
        else begin
            durum_r <= durum_ns; 
            uart_ctrl_r <= uart_ctrl_ns;
        end
end

fifo #(
    .DATA_WIDTH(8),
    .DATA_DEPTH(32)
)rx_buffer(
    .clk_i    ( clk_i ),         
    .rstn_i   ( rstn_i ),         
    .data_i   ( rx_fifoya_yazilacak_data_cmb ),         
    .wr_en_i  ( rx_fifo_wr_en_cmb ),         
    .data_o   ( rx_fifodan_okunan_data_w ),         
    .rd_en_i  ( rx_fifo_rd_en_cmb ),         
    .full_o   ( rx_fifo_full_w ),         
    .empty_o  ( rx_fifp_empty )         
);

fifo #(
    .DATA_WIDTH(8),
    .DATA_DEPTH(32)
)tx_buffer(
    .clk_i    ( clk_i ),         
    .rstn_i   ( rstn_i ),         
    .data_i   ( tx_fifoya_yazilacak_data_cmb ),         
    .wr_en_i  ( tx_fifo_wr_en_cmb),         
    .data_o   ( tx_fifodan_okunan_data_w ),         
    .rd_en_i  ( tx_fifo_rd_en_cmb ),         
    .full_o   ( tx_fifo_full_w ),         
    .empty_o  ( tx_fifo_empty )         
);

uart_alici alici (
.clk_i                     ( clk_i ),
.rstn_i                    ( rstn_i ),
.alinan_veri_o             ( alici_alinan_veri_w ),
.baud_div_i                ( alici_baud_div_cmb ),   
.rx_i                      ( alici_rx_cmb ),
.hazir_o                   ( alici_hazir_w ),
.alinan_veri_gecerli_o     ( alici_alinan_veri_gecerli_w )
);

uart_verici verici (
.clk_i                     ( clk_i),
.rstn_i                    ( rstn_i),
.basla_i                   ( verici_basla_cmb ),
.gelen_veri_gecerli_i      ( verici_gelen_veri_gecerli_cmb ),
.gelen_veri_i              ( verici_gelen_veri_cmb ),
.baud_div_i                ( verici_baud_div_cmb ),
.tx_o                      ( verici_tx_w ),
.hazir_o                   ( verici_hazir_w ) 
);

assign tx_en_w = uart_ctrl_r [0];
assign rx_en_w = uart_ctrl_r [1];
assign baud_div = uart_ctrl_r [31:16];

endmodule