`timescale 1ns / 1ps

`include "sabitler.vh"

module tb_getir1();

reg                         clk_i;
reg                         rstn_i;
reg                         l1b_istek_hazir_i;
wire    [`PS_BIT-1:0]       l1b_istek_adres_o;
wire                        l1b_istek_gecerli_o;
wire                        g2_istek_yapildi_o;
wire    [`PS_BIT-1:0]       g2_ps_o;
reg                         g2_ps_hazir_i;
wire                        g2_ps_gecerli_o;
reg                         cek_duraklat_i;
reg     [`PS_BIT-1:0]       cek_ps_i;
reg                         cek_ps_gecerli_i;

getir1 g1 (
    .clk_i               ( clk_i ),
    .rstn_i              ( rstn_i ),     
    .l1b_istek_hazir_i   ( l1b_istek_hazir_i ),
    .l1b_istek_adres_o   ( l1b_istek_adres_o ),
    .l1b_istek_gecerli_o ( l1b_istek_gecerli_o ),
    .g2_istek_yapildi_o  ( g2_istek_yapildi_o ),
    .g2_ps_o             ( g2_ps_o ),
    .g2_ps_hazir_i       ( g2_ps_hazir_i ),
    .g2_ps_gecerli_o     ( g2_ps_gecerli_o ),
    .cek_duraklat_i      ( cek_duraklat_i ),
    .cek_ps_i            ( cek_ps_i ),
    .cek_ps_gecerli_i    ( cek_ps_gecerli_i )
);

always begin
    clk_i = 1'b1;
    #5;
    clk_i = 1'b0;
    #5;
end

localparam PS_BASE = 32'h4000_0000;

localparam NO_STALL_TEST_LEN = 16;
localparam L1B_STALL_TEST_LEN = 16;
localparam G2_STALL_TEST_LEN = 16;

integer i;
reg flag_test;

task reset;
    begin
        rstn_i = `LOW;
        flag_test = `HIGH;
        l1b_istek_hazir_i = `HIGH;
        g2_ps_hazir_i = `HIGH;
        cek_duraklat_i = `LOW;
        cek_ps_gecerli_i = `LOW;
        cek_ps_i = 32'h4000_0000;
        repeat (10) @(posedge clk_i) #2;
        rstn_i = `HIGH;
    end
endtask
initial begin
    // No stall
    reset();
    for (i = 0; i < NO_STALL_TEST_LEN; i = i + 1) begin
        if (!l1b_istek_gecerli_o) begin
            $display("[SIM] NO STALL sequence read FAILED at %0d. Wasted cycle.", i);
            flag_test = `LOW;
        end
        if (l1b_istek_adres_o != (PS_BASE + i * 3'h4)) begin
            $display("[SIM] NO STALL sequence read FAILED at %0d. Expected L1 PS: %8x, Current L1 PS: %8x.", i, (PS_BASE + i * 3'h4), l1b_istek_adres_o);
            flag_test = `LOW;
        end
        @(posedge clk_i) #2;
        if (!g2_ps_gecerli_o) begin
            $display("[SIM] NO STALL sequence read FAILED at %0d. G2 not valid.", i);
        end
        if (g2_ps_o != (PS_BASE + i * 3'h4)) begin
            $display("[SIM] NO STALL sequence read FAILED at %0d. Expected G2 PS: %8x, Current G2 PS: %8x.", i, (PS_BASE + i * 3'h4), g2_ps_o);
            flag_test = `LOW;
        end
    end
    if (flag_test) begin
        $display("[SIM] NO STALL sequence read PASS.");
    end

    // L1B stall
    reset();
    for (i = 0; i < L1B_STALL_TEST_LEN; i = i + 1) begin
        if (!l1b_istek_gecerli_o) begin
            $display("[SIM] L1B STALL sequence read FAILED at %0d. Wasted cycle.", i);
            flag_test = `LOW;
        end
        l1b_istek_hazir_i = `LOW;
        repeat (i) @(posedge clk_i) #2;
        l1b_istek_hazir_i = `HIGH;
        if (l1b_istek_adres_o != (PS_BASE + i * 3'h4)) begin
            $display("[SIM] L1B STALL sequence read FAILED at %0d. Expected PS: %8x, Current PS: %8x.", i, (PS_BASE + i * 3'h4), l1b_istek_adres_o);
            flag_test = `LOW;
        end
        @(posedge clk_i) #2;
        if (!g2_ps_gecerli_o) begin
            $display("[SIM] L1B STALL sequence read FAILED at %0d. G2 not valid.", i);
            flag_test = `LOW;
        end
        if (g2_ps_o != (PS_BASE + i * 3'h4)) begin
            $display("[SIM] L1B STALL sequence read FAILED at %0d. Expected G2 PS: %8x, Current G2 PS: %8x.", i, (PS_BASE + i * 3'h4), g2_ps_o);
            flag_test = `LOW;
        end
        if (l1b_istek_adres_o != (PS_BASE + (i+1) * 3'h4)) begin
            $display("[SIM] L1B STALL sequence read FAILED at %0d. Expected PS: %8x, Current PS: %8x.", i, (PS_BASE + i * 3'h4), l1b_istek_adres_o);
            flag_test = `LOW;
        end
    end
    if (flag_test) begin
        $display("[SIM] L1B STALL sequence read PASS.");
    end

    // G2 stall
    reset();
    @(posedge clk_i) #2; // First request
    for (i = 0; i < G2_STALL_TEST_LEN; i = i + 1) begin
        g2_ps_hazir_i = `LOW;
        repeat (i) begin
            if (g2_ps_o != (PS_BASE + i * 3'h4)) begin
                $display("[SIM] G2 STALL sequence read FAILED at %0d. Expected G2 PS: %8x, Current G2 PS: %8x.", i, (PS_BASE + i * 3'h4), g2_ps_o);
                flag_test = `LOW;
            end
            if (l1b_istek_gecerli_o && l1b_istek_adres_o != (PS_BASE + (i+1) * 3'h4)) begin
                $display("[SIM] G2 STALL sequence read FAILED at %0d. Expected L1B PS: %8x, Current L1B PS: %8x.", i, (PS_BASE + i * 3'h4), g2_ps_o);
                flag_test = `LOW;
            end
            @(posedge clk_i) #2;
            if (l1b_istek_gecerli_o) begin
                $display("[SIM] G2 STALL sequence read FAILED at %0d. Unnecessary request.", i, (PS_BASE + i * 3'h4), g2_ps_o);
                flag_test = `LOW;
            end
        end
        g2_ps_hazir_i = `HIGH;
        @(posedge clk_i) #2;
    end
    if (flag_test) begin
        $display("[SIM] G2 STALL sequence read PASS.");
    end
end

endmodule