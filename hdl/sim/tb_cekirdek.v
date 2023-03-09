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
wire    [7:0]                   l1v_istek_maske_o;
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
    .l1v_istek_maske_o       ( l1v_istek_maske_o ),
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

localparam PATH_TO_TEST = "/home/kirbyydoge/GitHub/kasirga-teknofest-2023/kaynaklar/coremark/core_main.hex";
localparam BUYRUK_BELLEK_LEN = 'h40000;
reg [31:0] bellek [0:BUYRUK_BELLEK_LEN-1];
reg l1b_yanitla_r;

always @* begin
    buyruk_istek_hazir_i = !buyruk_full_o;
    buyruk_data_i = bellek[(buyruk_istek_adres_o & 32'h000f_ffff) >> 2];
    buyruk_wr_en_i = buyruk_istek_gecerli_o;
    buyruk_yanit_veri_i = buyruk_data_o;
    buyruk_yanit_gecerli_i = !buyruk_empty_o;
    buyruk_rd_en_i = buyruk_yanit_hazir_o;
end

reg  [31:0]     buyruk_data_i;
reg             buyruk_wr_en_i;
wire [31:0]     buyruk_data_o;
reg             buyruk_rd_en_i;
wire            buyruk_full_o;
wire            buyruk_empty_o;

fifo #(
    .DATA_WIDTH (32),
    .DATA_DEPTH (3)
) buyruk_resp (
    .clk_i   ( clk_i    ),
    .rstn_i  ( rstn_i   ),
    .data_i  ( buyruk_data_i   ),
    .wr_en_i ( buyruk_wr_en_i  ),
    .data_o  ( buyruk_data_o   ),
    .rd_en_i ( buyruk_rd_en_i  ),
    .full_o  ( buyruk_full_o   ),
    .empty_o ( buyruk_empty_o  )
);

always @* begin
    l1v_istek_hazir_i = !l1v_full_o;
    l1v_data_i = bellek[(l1v_istek_adres_o & 32'h000f_ffff) >> 2];
    l1v_wr_en_i = l1v_istek_gecerli_o && !l1v_istek_yaz_o;
    l1v_yanit_veri_i = l1v_data_o;
    l1v_yanit_gecerli_i = !l1v_empty_o;
    l1v_rd_en_i = l1v_yanit_hazir_o;
end

always @(posedge clk_i) begin
    if (l1v_istek_gecerli_o && l1v_istek_yaz_o) begin
        for (i = 0; i < 8; i = i + 1) begin
            if (l1v_istek_maske_o[i]) begin
                bellek[(l1v_istek_adres_o & 32'h000f_ffff) >> 2][8 * i +: 8] <= l1v_istek_veri_o[8 * i +: 8];
            end
        end
    end
end

reg  [31:0]     l1v_data_i;
reg             l1v_wr_en_i;
wire [31:0]     l1v_data_o;
reg             l1v_rd_en_i;
wire            l1v_full_o;
wire            l1v_empty_o;

fifo #(
    .DATA_WIDTH (32),
    .DATA_DEPTH (3)
) veri_resp (
    .clk_i   ( clk_i    ),
    .rstn_i  ( rstn_i   ),
    .data_i  ( l1v_data_i   ),
    .wr_en_i ( l1v_wr_en_i  ),
    .data_o  ( l1v_data_o   ),
    .rd_en_i ( l1v_rd_en_i  ),
    .full_o  ( l1v_full_o   ),
    .empty_o ( l1v_empty_o  )
);

integer i;
initial begin
    for (i = 0; i < BUYRUK_BELLEK_LEN; i = i+1) begin
        bellek[i] = 0;
    end
    $readmemh(PATH_TO_TEST, bellek);
    rstn_i = 0;
    repeat(20) @(posedge clk_i) #COMB_DELAY;
    rstn_i = 1;

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