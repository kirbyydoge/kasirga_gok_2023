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


always @* begin
    durum_ns = durum_r;

    case (durum_r)
        BOSTA: begin
            if (cek_uart_istek_w) begin
                case (cek_uart_addr_w) 
                    `UART_CTRL_REG: begin

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
            
        end
        else begin
            durum_r <= durum_ns; 
         
        end
end







fifo #(
    .DATA_WIDTH(8),
    .DATA_DEPTH(32)
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


assign tx_en_w = uart_ctrl_r [0];
assign rx_en_w = uart_ctrl_r [1];

endmodule