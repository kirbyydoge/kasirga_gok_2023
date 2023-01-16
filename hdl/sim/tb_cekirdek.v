`timescale 1ns/1ps

`include "sabitler.vh"

module tb_cekirdek();

reg                             clk_i;
reg                             rstn_i;
reg     [`L1_BLOK_BIT-1:0]      buyruk_yanit_veri_i;
reg                             buyruk_yanit_gecerli_i;
wire                            buyruk_yanit_hazir_o;
wire    [`ADRES_BIT-1:0]        buyruk_istek_adres_o;
wire                            buyruk_istek_gecerli_o;
reg                             buyruk_istek_hazir_i;
reg     [`VERI_BIT-1:0]         l1v_yanit_veri_i;
reg                             l1v_yanit_gecerli_i;
wire                            l1v_yanit_hazir_o;
wire    [`VERI_BIT-1:0]         l1v_istek_veri_o;
wire    [`ADRES_BIT-1:0]        l1v_istek_adres_o;
wire                            l1v_istek_yaz_o;
wire                            l1v_istek_gecerli_o;
reg                             l1v_istek_hazir_i;

localparam COMB_DELAY = 2;

cekirdek cekirdek (
    .clk_i                   ( clk_i ),
    .rstn_i                  ( rstn_i ),
    .buyruk_yanit_veri_i     ( buyruk_yanit_veri_i ),
    .buyruk_yanit_gecerli_i  ( buyruk_yanit_gecerli_i ),
    .buyruk_yanit_hazir_o    ( buyruk_yanit_hazir_o ),
    .buyruk_istek_adres_o    ( buyruk_istek_adres_o ),
    .buyruk_istek_gecerli_o  ( buyruk_istek_gecerli_o ),
    .buyruk_istek_hazir_i    ( buyruk_istek_hazir_i ),
    .l1v_yanit_veri_i        ( l1v_yanit_veri_i ),
    .l1v_yanit_gecerli_i     ( l1v_yanit_gecerli_i ),
    .l1v_yanit_hazir_o       ( l1v_yanit_hazir_o ),
    .l1v_istek_veri_o        ( l1v_istek_veri_o ),
    .l1v_istek_adres_o       ( l1v_istek_adres_o ),
    .l1v_istek_yaz_o         ( l1v_istek_yaz_o ),
    .l1v_istek_gecerli_o     ( l1v_istek_gecerli_o ),
    .l1v_istek_hazir_i       ( l1v_istek_hazir_i )
);

always begin
    clk_i = 1'b0;
    #5;
    clk_i = 1'b1;
    #5;
end

localparam PATH_TO_TEST = "/home/kirbyydoge/teknofest_2023_test/rv32ui-p-add.hex";
localparam BUYRUK_BELLEK_LEN = 1024;
reg [31:0] buyruklar [0:BUYRUK_BELLEK_LEN-1];

localparam BELLEK_GECIKMESI = 5;
reg [BELLEK_GECIKMESI:0] istek_counter;
reg [BELLEK_GECIKMESI:0] buyruk_counter;

always @* begin
    buyruk_yanit_gecerli_i = buyruk_counter[BELLEK_GECIKMESI];
    buyruk_istek_hazir_i = !(|istek_counter);
end

always @(posedge clk_i) begin
    if (!rstn_i) begin
        istek_counter <= 0;
        buyruk_counter <= 0;
    end
    else begin
        if (!buyruk_yanit_gecerli_i || buyruk_yanit_hazir_o && buyruk_yanit_gecerli_i) begin
            buyruk_counter <= buyruk_counter << 1;
        end
        if (buyruk_istek_hazir_i && buyruk_istek_gecerli_o) begin
            buyruk_yanit_veri_i <= (('h0000_ffff & buyruk_istek_adres_o) >> 2) < BUYRUK_BELLEK_LEN ? buyruklar[('h0000_ffff & buyruk_istek_adres_o) >> 2] : 0;
            istek_counter <= 1;
            buyruk_counter <= 1;
        end
        else begin
            istek_counter <= istek_counter << 1;
        end
    end
end

integer i;
initial begin
    for (i = 0; i < BUYRUK_BELLEK_LEN; i = i+1) begin
        buyruklar[i] = 0;
    end
    $readmemh(PATH_TO_TEST, buyruklar);
    rstn_i = 0;
    repeat(20) @(posedge clk_i) #COMB_DELAY;
    rstn_i = 1;
    l1v_yanit_veri_i = 0;
    l1v_yanit_gecerli_i = 0;
    l1v_istek_hazir_i = 0;

    // buyruklar['h000] = 'h00500113; // addi x2, x0, 5
    // buyruklar['h001] = 'h00108093; // addi x1, x1, 1
    // buyruklar['h002] = 'hfe209ee3; // bne x1, x2, -4
    // buyruklar['h003] = 'h00200113; // addi x2, x0, 2
    // buyruklar['h004] = 'h00300193; // addi x3, x0, 3
    // buyruklar['h005] = 'h00400213; // addi x4, x0, 4
    // buyruklar['h006] = 'h00500293; // addi x5, x0, 5
    // buyruklar['h007] = 'h00318333; // add x6, x3, x3
    
    // Normalde MISA yazmacinin READONLY olmasi lazim. Simdilik bu izinler yok, degerlerin takaslanmasi yeterli.
    // buyruklar['h000] = 'h00500113; // addi x2, x0, 5
    // buyruklar['h001] = 'h301110f3; // csrrw x1, misa, x2
end

endmodule