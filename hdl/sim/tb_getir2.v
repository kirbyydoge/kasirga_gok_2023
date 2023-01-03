`timescale 1ns / 1ps

`include "sabitler.vh"

module tb_getir2();

reg                       clk_i;
reg                       rstn_i;
reg                       g1_istek_yapildi_i;
reg   [`PS_BIT-1:0]       g1_ps_i;
reg                       g1_ps_gecerli_i;
wire                      g1_ps_hazir_o;
wire  [`PS_BIT-1:0]       g1_dallanma_ps_o;
wire                      g1_dallanma_gecerli_o;
reg   [`VERI_BIT-1:0]     l1b_buyruk_i;
reg                       l1b_buyruk_gecerli_i;
wire                      l1b_buyruk_hazir_o;
wire  [`BUYRUK_BIT-1:0]   coz_buyruk_o;
wire  [`PS_BIT-1:0]       coz_buyruk_ps_o;
wire                      coz_buyruk_gecerli_o;
reg                       cek_duraklat_i;
reg                       cek_bosalt_i;

getir2 g2 (
    .clk_i                 ( clk_i ),
    .rstn_i                ( rstn_i ),
    .g1_istek_yapildi_i    ( g1_istek_yapildi_i ),
    .g1_ps_i               ( g1_ps_i ),
    .g1_ps_gecerli_i       ( g1_ps_gecerli_i ),
    .g1_ps_hazir_o         ( g1_ps_hazir_o ),
    .g1_dallanma_ps_o      ( g1_dallanma_ps_o ),
    .g1_dallanma_gecerli_o ( g1_dallanma_gecerli_o ),
    .l1b_buyruk_i          ( l1b_buyruk_i ),
    .l1b_buyruk_gecerli_i  ( l1b_buyruk_gecerli_i ),
    .l1b_buyruk_hazir_o    ( l1b_buyruk_hazir_o ),
    .coz_buyruk_o          ( coz_buyruk_o ),
    .coz_buyruk_ps_o       ( coz_buyruk_ps_o ),
    .coz_buyruk_gecerli_o  ( coz_buyruk_gecerli_o ),
    .cek_duraklat_i        ( cek_duraklat_i ),
    .cek_bosalt_i          ( cek_bosalt_i )
);

always begin
    clk_i = 1'b0;
    #5;
    clk_i = 1'b1;
    #5;
end


localparam NO_STALL_TEST_LEN = 16;
localparam PS_BASE = 32'h4000_0000;

integer i;
reg flag_test;

task reset;
    begin
        rstn_i = `LOW;
        flag_test = `HIGH;
        g1_istek_yapildi_i = `LOW;
        g1_ps_i = 32'h0;
        g1_ps_gecerli_i = `LOW;
        l1b_buyruk_i = 32'h0;
        l1b_buyruk_gecerli_i = `LOW;
        cek_duraklat_i = `LOW;
        cek_bosalt_i = `LOW;
        repeat (10) @(posedge clk_i) #2;
        rstn_i = `HIGH;
    end
endtask

always @(posedge clk_i) begin
    if (g1_ps_hazir_o && g1_ps_gecerli_i && l1b_buyruk_hazir_o && l1b_buyruk_gecerli_i) begin
        g1_ps_i = g1_ps_i + 4;
    end
end

initial begin
    reset();
    g1_istek_yapildi_i = `HIGH;
    g1_ps_i = PS_BASE;
    g1_ps_gecerli_i = `HIGH;
    l1b_buyruk_gecerli_i = `LOW;
    @(posedge clk_i) #2;
    g1_istek_yapildi_i = `HIGH;
    @(posedge clk_i) #2;
    for (i = 0; i < NO_STALL_TEST_LEN;) begin
        l1b_buyruk_i = i;
        l1b_buyruk_gecerli_i = `HIGH;
        @(posedge clk_i) #2;
        if (coz_buyruk_gecerli_o) begin
            if (coz_buyruk_o != i) begin
                $display("[SIM] NO STALL fetch FAIL at %0d. Expected INTSR: %8x, Current INSTR: %8x", i, i, coz_buyruk_o);
                flag_test = `LOW;
            end
            if (coz_buyruk_ps_o != (PS_BASE + i * 4)) begin
                $display("[SIM] NO STALL fetch FAIL at %0d. Expected PS: %8x, Current PS: %8x", i, (PS_BASE + i * 4), coz_buyruk_ps_o);
                flag_test = `LOW;
            end
            i = i + 1;
        end
    end
    if (flag_test) begin
        $display("[SIM] NO STALL fetch PASS.");
    end
    reset();
    g1_istek_yapildi_i = `HIGH;
    g1_ps_i = PS_BASE;
    l1b_buyruk_i = 32'h0;
    g1_ps_gecerli_i = `HIGH;
    l1b_buyruk_gecerli_i = `LOW;
    @(posedge clk_i) #2;
    g1_istek_yapildi_i = `HIGH;
    @(posedge clk_i) #2;
    g1_istek_yapildi_i = `HIGH;
    @(posedge clk_i) #2;    // 3 outstanding requests
    if (g2.l1b_beklenen_sayisi_r != 2'h3) begin
        $display("[SIM] CORE FLUSH fetch FAILED. Incorrect outstanding counter. Expected CTR: %0x, Current CTR: %0x.", 2'h3, g2.l1b_beklenen_sayisi_r);
        flag_test = `LOW;
    end
    g1_istek_yapildi_i = `LOW; 
    l1b_buyruk_gecerli_i = `HIGH;
    @(posedge clk_i) #2;    // Accept first, 2 outstanding requests remain
    g1_ps_i = 32'hFFFF_FFFF;
    l1b_buyruk_i = 32'hFFFF_FFFF;
    cek_bosalt_i = `HIGH;
    @(posedge clk_i) #2;    // Flush the core. 0 outstanding requests remain. However, the stage should ignore the next response.
                            //  Notice that we have 1 ignored response, since at this cycle stage SHOULD take the opportunity to
                            //  discard a request while flushing.
    cek_bosalt_i = `LOW;
    if (g2.l1b_beklenen_sayisi_r != 2'h0) begin
        $display("[SIM] CORE FLUSH fetch FAILED. Incorrect outstanding counter after flush. Expected CTR: %0x, Current CTR: %0x.", 2'h0, g2.l1b_beklenen_sayisi_r);
        flag_test = `LOW;
    end
    if (g2.g2_bos_istek_sayaci_r != 2'h1) begin
        $display("[SIM] CORE FLUSH fetch FAILED. Incorrect ignore counter after flush. Expected CTR: %0x, Current CTR: %0x.", 2'h1, g2.g2_bos_istek_sayaci_r);
        flag_test = `LOW;
    end
    g1_istek_yapildi_i = `HIGH; // Make a valid request.
    @(posedge clk_i) #2;    // Ignore the last response and transition to fetching normally.
    g1_istek_yapildi_i = `LOW;
    g1_ps_i = PS_BASE;
    l1b_buyruk_i = 32'hAAAA_AAAA;
    if (g2.l1b_beklenen_sayisi_r != 2'h1) begin
        $display("[SIM] CORE FLUSH fetch FAILED. Incorrect outstanding counter. Expected CTR: %0x, Current CTR: %0x.", 2'h1, g2.l1b_beklenen_sayisi_r);
        flag_test = `LOW;
    end
    if (g2.g2_bos_istek_sayaci_r != 2'h0) begin
        $display("[SIM] CORE FLUSH fetch FAILED. Incorrect ignore counter. Expected CTR: %0x, Current CTR: %0x.", 2'h0, g2.g2_bos_istek_sayaci_r);
        flag_test = `LOW;
    end
    if (g2.g2_durum_r != g2.G2_YAZMAC_BOS) begin
        $display("[SIM] CORE FLUSH fetch FAILED. Incorrect state. Expected: %0x, Current: %0x.", g2.G2_YAZMAC_BOS, g2.g2_durum_r);
        flag_test = `LOW;
    end
    @(posedge clk_i) #2;    // Output the first valid program counter, instruction pair after flush.
    if (!coz_buyruk_gecerli_o) begin
        $display("[SIM] CORE FLUSH fetch FAILED. Invalid output.");
        flag_test = `LOW;
    end
    if (coz_buyruk_ps_o != PS_BASE) begin
        $display("[SIM] CORE FLUSH fetch FAILED. Incorrect output. Expecetd PC: %8x, Current PC: %8x.", PS_BASE, coz_buyruk_ps_o);
        flag_test = `LOW;
    end
    if (coz_buyruk_o != 32'hAAAA_AAAA) begin
        $display("[SIM] CORE FLUSH fetch FAILED. Incorrect output. Expecetd INSTR: %8x, Current INSTR: %8x.", 32'hAAAA_AAAA, coz_buyruk_o);
        flag_test = `LOW;
    end
    repeat (10) @(posedge clk_i); // Just for eye candy.
    if (flag_test) begin
        $display("[SIM] CORE FLUSH fetch PASS.");
    end
    $finish;
end

endmodule