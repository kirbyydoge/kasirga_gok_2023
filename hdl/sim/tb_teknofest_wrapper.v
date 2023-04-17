`timescale 1ns/1ps

module tb_teknofest_wrapper();
reg  clk_i;
reg  rst_ni;
reg  program_rx_i;
wire prog_mode_led_o;
wire uart_tx_o;
wire uart_rx_i;
wire spi_cs_o;
wire spi_sck_o;
wire spi_mosi_o;
wire spi_miso_i;
wire pwm0_o;
wire pwm1_o;


teknofest_wrapper tw (
`ifdef VCU108
.clk_p (clk_i),
.clk_n (~clk_i),
`else
.clk_i (clk_i),
`endif
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

wire o_RX_DV_w;
wire [7:0] o_RX_Byte;
reg  i_TX_DV_r;
reg [7:0] i_TX_Byte;
wire o_SPI_MISO;

SPI_Slave #(
  .SPI_MODE(0)
) slave (
    .i_Rst_L (rst_ni),
    .i_Clk (clk_i),
    .o_RX_DV (o_RX_DV_w),
    .o_RX_Byte (o_RX_Byte),
    .i_TX_DV (i_TX_DV_r),
    .i_TX_Byte (i_TX_Byte),
    .i_SPI_Clk (spi_sck_o),
    .o_SPI_MISO (spi_miso_i),
    .i_SPI_MOSI (spi_mosi_o),
    .i_SPI_CS_n (spi_cs_o)
);

always begin
    clk_i = 1'b0;
    #5;
    clk_i = 1'b1;
    #5;
end

localparam PATH_TO_TEST_LIST = "/home/kirbyydoge/GitHub/kasirga-teknofest-2023/kaynaklar/rv32test/rv32imc-hex";
localparam GP = 'd3;
localparam A7 = 'd17;
localparam MAX_TEST_COUNT = 64;
localparam MAX_STALL_CYCLES = 10000;
reg [31:0] test_indexes [0:MAX_TEST_COUNT-1];
reg [31:0] uut_indexes [0:MAX_TEST_COUNT-1];
reg [64*8-1:0] test_name;
reg [64*8-1:0] success_file_path;
reg [63:0] past_gp;
reg [31:0] failed_idx;
reg test_passed;

integer test_list_fd;
integer log_fd;
integer uart_fd;
integer success_file_fd;
integer code;
integer i;
integer stall_ctr;
integer cur_test;
integer last_inst;
integer last_uart;

reg [10:0] uart_msg;
localparam CPU_HZ = 100_000_000;
localparam BAUD_RATE = 115200;
localparam BAUD_DIV = CPU_HZ / BAUD_RATE;
integer uart_baud_ctr;
integer uart_ctr;

always @(posedge clk_i) begin
    if (!rst_ni) begin
        uart_ctr <= 0;
        uart_baud_ctr <= 0;
    end
    else if (tw.soc.uartd.rx_en_w) begin
        uart_baud_ctr <= uart_baud_ctr + 1;
        if (uart_baud_ctr == BAUD_DIV - 1) begin
            uart_baud_ctr <= 0;
            uart_ctr <= (uart_ctr + 1) % 11;
        end
    end 
end

assign uart_rx_i = uart_msg[10 - uart_ctr];

// 0 yapilirsa test kontrolu ve otomatik sonlanma yapilmaz
localparam RISCV_TEST = 0;
//localparam STANDALONE_PATH = "/home/kirbyydoge/GitHub/kasirga-teknofest-2023/kaynaklar/coremark/core_main.hex";
localparam STANDALONE_PATH = "/home/kirbyydoge/GitHub/TEKNOFEST_2023_Cip_Tasarim_Yarismasi/baremetal-tekno-sw/outputs/tekno_example.hex";
localparam LOG_PATH = "/home/kirbyydoge/GitHub/kasirga-teknofest-2023/vivado.txt";
localparam UART_PATH = "/home/kirbyydoge/GitHub/kasirga-teknofest-2023/uart.txt";
initial begin
    uart_msg = 11'b10_10110011_1;
    if (RISCV_TEST) begin
        test_passed = 0;
        test_list_fd = $fopen({PATH_TO_TEST_LIST, "/test_names.txt"}, "r");
        while (!$feof(test_list_fd)) begin
            code = $fscanf(test_list_fd, "%s/n", test_name);
            for (i = 0; i < MAX_TEST_COUNT; i = i+1) begin
                test_indexes[i] = 1;
                uut_indexes[i] = 1;
            end
            $readmemh({PATH_TO_TEST_LIST, "/", test_name, ".hex"}, tw.main_memory.ram);
            $readmemh({PATH_TO_TEST_LIST, "/", test_name, ".idx"}, test_indexes);
            stall_ctr = 0;
            cur_test = 0;
            rst_ni = 0;
            repeat (10) @(posedge clk_i);
            rst_ni = 1;
            past_gp = 0;
            while (stall_ctr < MAX_STALL_CYCLES) begin
                @(posedge clk_i) #2;
                stall_ctr = stall_ctr + RISCV_TEST;
                if (past_gp != tw.soc.cekirdek.yo.rf.yazmac_r[GP]) begin
                    uut_indexes[cur_test] = tw.soc.cekirdek.yo.rf.yazmac_r[GP];
                    past_gp = tw.soc.cekirdek.yo.rf.yazmac_r[GP];
                    cur_test = cur_test + 1;
                    stall_ctr = 0;
                end
                if (tw.soc.cekirdek.yo.rf.yazmac_r[A7] == 93) begin
                    stall_ctr = MAX_STALL_CYCLES * RISCV_TEST;
                end
            end
            test_passed = 1;
            for (i = 0; i < MAX_TEST_COUNT; i = i + 1) begin
                if (uut_indexes[i] != test_indexes[i] && test_passed) begin
                    failed_idx = i-1;
                    test_passed = 0;
                end
            end
            if (test_passed) begin
                $display("%0s passed.", test_name);
            end
            else begin
                $display("%0s failed at %d.", test_name, test_indexes[failed_idx]);
            end
        end
        $finish();
    end
    else begin
        $readmemh(STANDALONE_PATH, tw.main_memory.ram);
        rst_ni = 0;
        repeat(100) @(posedge clk_i);
        rst_ni = 1;
        log_fd = $fopen(LOG_PATH, "w");
        uart_fd = $fopen(UART_PATH, "w");
        stall_ctr = 0;
        last_inst = -1;
        last_uart = -1;
        while(stall_ctr < 1000000) begin
            @(posedge clk_i); #2;
            stall_ctr = stall_ctr + 1;
            if (tw.soc.cekirdek.gy.uop_gy_gecerli_w && last_inst != tw.soc.cekirdek.gy.inst_ctr_r) begin
                last_inst = tw.soc.cekirdek.gy.inst_ctr_r;
                stall_ctr = 0;
                if (tw.soc.cekirdek.gy.uop_gy_veri_gecerli_w) begin
                    $fwrite(log_fd, "core   0: 3 0x%08x (0x0000) x%2d 0x%08x\n", tw.soc.cekirdek.gy.uop_ps_w, tw.soc.cekirdek.gy.uop_gy_adres_w, tw.soc.cekirdek.gy.uop_gy_veri_w);
                end
                else begin
                    $fwrite(log_fd, "core   0: 3 0x%08x (0x0000)\n", tw.soc.cekirdek.gy.uop_ps_w);
                end
            end
            if (tw.soc.uartd.consume_w && last_uart != tw.soc.uartd.tx_ctr_r) begin
                last_uart = tw.soc.uartd.tx_ctr_r;
                $fwrite(uart_fd, "%c", tw.soc.uartd.tx_fifo_rd_data_w[7:0]);
            end
            $fflush(log_fd);
            $fflush(uart_fd);
        end
        $fclose(log_fd);
        $fclose(uart_fd);
        $finish;
    end
end

endmodule

