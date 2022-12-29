`timescale 1ns / 1ps

`include "sabitler.vh"

module tb_memory_model();

reg                             clk_i;
reg     [`ADRES_BIT-1:0]        cmd_addr;
wire    [`VERI_BIT-1:0]         rd_data;
reg     [`VERI_BIT-1:0]         wr_data;
reg                             wr_enable;
reg                             cmd_valid;

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
    .cmd_addr       ( cmd_addr ),
    .rd_data        ( rd_data ),
    .wr_data        ( wr_data ),
    .wr_enable      ( wr_enable ),
    .cmd_valid      ( cmd_valid )
);

localparam TEST_LEN = 16; // `BELLEK_BOYUT / `VERI_BIT;

integer i;
initial begin
    for (i = 0; i < TEST_LEN; i = i + 1) begin
        wr_data = i + 1;
        wr_enable = `HIGH;
        cmd_valid = `HIGH;
        cmd_addr = `BELLEK_BASLANGIC + i * `VERI_BYTE;
        @(posedge clk_i) #2;
    end
    wr_data = `ALL_ONES_256;
    for (i = 0; i < TEST_LEN; i = i + 1) begin
        wr_enable = `LOW;
        cmd_valid = `HIGH;
        cmd_addr = `BELLEK_BASLANGIC + i * `VERI_BYTE;
        @(posedge clk_i) #2;
        if (rd_data != (i + 1)) begin
            $display("[SIM] Test failed at i = %0d.", i);
            $display("[SIM] ACTUAL: %0x\tEXPECTED: %0x", rd_data, (i + 1));
            $finish;
        end
    end
    $display("[SIM] All tests passed.");
    $finish;
end

endmodule