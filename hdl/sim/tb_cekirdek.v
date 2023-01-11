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
reg     [`VERI_BIT-1:0]         vy_yanit_veri_i;
reg                             vy_yanit_gecerli_i;
wire                            vy_yanit_hazir_o;
wire    [`VERI_BIT-1:0]         vy_istek_veri_o;
wire    [`ADRES_BIT-1:0]        vy_istek_adres_o;
wire                            vy_istek_yaz_o;
wire                            vy_istek_gecerli_o;
reg                             vy_istek_hazir_i;

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
    .vy_yanit_veri_i         ( vy_yanit_veri_i ),
    .vy_yanit_gecerli_i      ( vy_yanit_gecerli_i ),
    .vy_yanit_hazir_o        ( vy_yanit_hazir_o ),
    .vy_istek_veri_o         ( vy_istek_veri_o ),
    .vy_istek_adres_o        ( vy_istek_adres_o ),
    .vy_istek_yaz_o          ( vy_istek_yaz_o ),
    .vy_istek_gecerli_o      ( vy_istek_gecerli_o ),
    .vy_istek_hazir_i        ( vy_istek_hazir_i )
);

always begin
    clk_i = 1'b0;
    #5;
    clk_i = 1'b1;
    #5;
end

reg [31:0] buyruklar [0:TEST_LEN-1];

reg [31:0] istek_counter;
reg [31:0] buyruk_counter;

always @* begin
    buyruk_yanit_veri_i = buyruklar[buyruk_counter];
    buyruk_yanit_gecerli_i = buyruk_counter < TEST_LEN;
    buyruk_istek_hazir_i = istek_counter < TEST_LEN;
end

always @(posedge clk_i) begin
    if (!rstn_i) begin
        istek_counter <= 0;
        buyruk_counter <= 0;
    end
    else begin
        if (buyruk_istek_hazir_i && buyruk_istek_gecerli_o) begin
            istek_counter <= istek_counter + 1;
        end
        if (buyruk_yanit_gecerli_i && buyruk_yanit_hazir_o) begin
            buyruk_counter <= buyruk_counter + 1;
        end
    end
end

localparam TEST_LEN = 10;
integer i;
initial begin
    rstn_i = 0;
    repeat(20) @(posedge clk_i) #COMB_DELAY;
    rstn_i = 1;
    vy_yanit_veri_i = 0;
    vy_yanit_gecerli_i = 0;
    vy_istek_hazir_i = 0;

    buyruklar['h000] = 'h00108093; // addi x1, x1, 1
    buyruklar['h001] = 'h00108093; // addi x1, x1, 1
    buyruklar['h002] = 'h00108093; // addi x1, x1, 1
    buyruklar['h003] = 'h00108093; // addi x1, x1, 1
    buyruklar['h004] = 'h00108093; // addi x1, x1, 1
    buyruklar['h005] = 'h00200113; // addi x2, x0, 2
    buyruklar['h006] = 'h00300193; // addi x3, x0, 3
    buyruklar['h007] = 'h00400213; // addi x4, x0, 4
    buyruklar['h008] = 'h00500293; // addi x5, x0, 5
    buyruklar['h009] = 'h00318333; // add x6, x3, x3
end

endmodule