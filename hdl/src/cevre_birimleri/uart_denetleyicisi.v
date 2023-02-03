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

reg [`VERI_BIT-1:0] uart_veri_r;
reg [`VERI_BIT-1:0] uart_veri_ns;
reg uart_gecerli_r;
reg uart_gecerli_ns;
reg [`VERI_BIT-1:0] fifo_buf_veri_r;
reg [`VERI_BIT-1:0] fifo_buf_veri_ns;

localparam BOSTA = 0;
localparam VERI_BEKLE = 1;
localparam YER_BEKLE = 2;

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

    if (uart_gecerli_o && uart_hazir_i) begin
        uart_gecerli_ns = `LOW;
    end

    durum_ns = durum_r;
    uart_veri_ns =uart_veri_r;
    uart_gecerli_ns = uart_gecerli_r;
    fifo_buf_veri_ns = fifo_buf_veri_r;
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
                    end
                    `UART_STATUS_REG: begin
                        if (!cek_yaz_i) begin
                            uart_veri_ns = uart_status_w;
                            uart_gecerli_ns = `HIGH;
                        end

                    end
                    `UART_RDATA_REG: begin
                        if (!cek_yaz_i) begin
                            if (fifo_miso_empty_w) begin
                                durum_ns = VERI_BEKLE;
                            end
                            else begin
                                uart_veri_ns = tx_fifodan_okunan_data_w;
                                uart_gecerli_ns = `HIGH;
                            end
                        end

                    end
                    `UART_WDATA_REG: begin
                         if (cek_yaz_i) begin
                            if (rx_fifo_full_w) begin
                                fifo_buf_veri_ns = cek_veri_i;
                                durum_ns = YER_BEKLE;
                            end
                            else begin
                                rx_fifoya_yazilacak_data_cmb = cek_veri_i;
                                rx_fifo_wr_en_cmb = `HIGH;
                            end
                        end
                    end

                endcase
            end    
        end
        VERI_BEKLE: begin
             if (!tx_fifo_empty) begin
                uart_veri_ns = tx_fifodan_okunan_data_w;
                uart_gecerli_ns = `HIGH;
                durum_ns = DURUM_BOSTA;
            end
        end
        YER_BEKLE: begin
            if (!rx_fifo_full_w) begin
                rx_fifoya_yazilacak_data_cmb = fifo_buf_veri_r;
                rx_fifo_wr_en_cmb = `HIGH;
                durum_ns = DURUM_BOSTA;
            end
        end
    endcase


end

always @ (posedge clk_i) begin
    if (!rstn_i) begin
            durum_r <= BOSTA;
            uart_ctrl_r <= 0;
            uart_veri_r <= 0;
            uart_gecerli_r <= `LOW;
            fifo_buf_veri_r <= 0;
            
        end
        else begin
            durum_r <= durum_ns; 
            uart_ctrl_r <= uart_ctrl_ns;
            uart_veri_r <= uart_veri_ns;
            uart_gecerli_r <= uart_gecerli_ns;
            fifo_buf_veri_r <= fifo_buf_veri_ns;
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
    .rd_en_i  ( consume_o ),         
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
.basla_i                   ( tx_en_w ),
.gelen_veri_gecerli_i      ( !tx_fifo_empty ),
.gelen_veri_i              ( verici_gelen_veri_cmb ),
.baud_div_i                ( verici_baud_div_cmb ),
.tx_o                      ( verici_tx_w ),
.hazir_o                   ( verici_hazir_w ) 
);

assign tx_en_w = uart_ctrl_r [0];
assign rx_en_w = uart_ctrl_r [1];
assign baud_div = uart_ctrl_r [31:16];

assign uart_veri_o = uart_veri_r;
assign uart_gecerli_o = uart_gecerli_r;

endmodule
