`timescale 1ns/1ps

module tb_teknofest_wrapper();
reg  clk_i;
reg  rst_ni;
reg  program_rx_i;
wire prog_mode_led_o;
wire uart_tx_o;
reg  uart_rx_i;
wire spi_cs_o;
wire spi_sck_o;
wire spi_mosi_o;
reg  spi_miso_i;
wire pwm0_o;
wire pwm1_o;


teknofest_wrapper tw (
.clk_p (clk_i),
.clk_n (~clk_i),
.rst_ni (rst_ni),
.program_rx_i (program_rx_i),
.prog_mode_led_o (prog_mode_led_o),
.uart_tx_o (uart_tx_o),
.uart_rx_i (uart_rx_i),
.spi_cs_o (spi_cs_o),
.spi_sck_o (spi_sck_o),
.spi_mosi_o (spi_mosi_o),
.spi_miso_i (spi_miso_i),
.pwm0_o (pwm0_o),
.pwm1_o (pwm1_o)    
);

always begin
    clk_i = 1'b0;
    #5;
    clk_i = 1'b1;
    #5;
end

localparam PATH_TO_TEST_FILE = "/home/kirbyydoge/GitHub/kasirga-teknofest-2023/kaynaklar/rv32test/rv32imc-hex/rv32um-p-mul.hex";

initial begin
    $readmemh(PATH_TO_TEST_FILE, tw.main_memory.ram);
    rst_ni = 0;
    #200;
    rst_ni = 1;
    #5;
end

endmodule

