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

localparam PATH_TO_TEST_LIST = "C:/Users/aqwog/Documents/GitHub/kasirga-teknofest-2023/kaynaklar/rv32test/rv32imc-hex";
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
integer success_file_fd;
integer code;
integer i;
integer stall_ctr;
integer cur_test;

// 0 yapilirsa test kontrolu ve otomatik sonlanma yapilmaz
localparam RISCV_TEST = 1;
localparam STANDALONE_PATH = "C:/Users/aqwog/Documents/GitHub/kasirga-teknofest-2023/kaynaklar/coremark/core_main.hex";
initial begin
    if (RISCV_TEST) begin
        test_passed = 0;
        test_list_fd = $fopen({PATH_TO_TEST_LIST, "/test_names.txt"}, "r");
        while (!$feof(test_list_fd)) begin
            code = $fscanf(test_list_fd, "%s\n", test_name);
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
    end
end

endmodule

