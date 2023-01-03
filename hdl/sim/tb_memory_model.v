`timescale 1ns / 1ps

`include "sabitler.vh"

module tb_memory_model();

reg                             clk_i;
reg     [`ADRES_BIT-1:0]        cmd_addr_r;
wire    [`VERI_BIT-1:0]         rd_data_w;
reg     [`VERI_BIT-1:0]         wr_data_r;
reg                             wr_enable_r;
reg                             cmd_valid_r;

always begin
    clk_i = 0;
    #5;
    clk_i = 1;
    #5;
end

memory_model #(
    .BASE_ADDR   (`BELLEK_BASLANGIC), 
    .MEM_DEPTH   (`BELLEK_BOYUT), 
    .DATA_WIDTH  (`VERI_BIT),
    .ADDR_WIDTH  (`ADRES_BIT)
)
mem (
    .clk_i          ( clk_i ),
    .cmd_addr_i     ( cmd_addr_r ),
    .rd_data_o      ( rd_data_w ),
    .wr_data_i      ( wr_data_r ),
    .wr_enable_i    ( wr_enable_r ),
    .cmd_valid_i    ( cmd_valid_r )
);

localparam TEST_LEN = 16; // `BELLEK_BOYUT / `VERI_BIT;

integer i;
initial begin
    for (i = 0; i < TEST_LEN; i = i + 1) begin
        wr_data_r = i + 1;
        wr_enable_r = `HIGH;
        cmd_valid_r = `HIGH;
        cmd_addr_r = `BELLEK_BASLANGIC + i * `VERI_BYTE;
        @(posedge clk_i) #2;
    end
    wr_data_r = `ALL_ONES_256;
    for (i = 0; i < TEST_LEN; i = i + 1) begin
        wr_enable_r = `LOW;
        cmd_valid_r = `HIGH;
        cmd_addr_r = `BELLEK_BASLANGIC + i * `VERI_BYTE;
        @(posedge clk_i) #2;
        if (rd_data_w != (i + 1)) begin
            $display("[SIM] Test failed at i = %0d.", i);
            $display("[SIM] ACTUAL: %0x\tEXPECTED: %0x", rd_data_w, (i + 1));
            $finish;
        end
    end
    $display("[SIM] All tests passed.");
    $finish;
end

endmodule