`timescale 1ns / 1ps

`include "sabitler.vh"

module tb_vyd();

reg                             clk_i;
reg                             rstn_i;

wire    [`ADRES_BIT-1:0]        mem_istek_adres_o;
wire    [`VERI_BIT-1:0]         mem_istek_veri_o;
wire                            mem_istek_yaz_o;
wire                            mem_istek_gecerli_o;
reg                             mem_istek_hazir_i;
reg     [`VERI_BIT-1:0]         mem_veri_i;
reg                             mem_veri_gecerli_i;
wire                            mem_veri_hazir_o;

reg     [`ADRES_BIT-1:0]        l1_istek_adres_i;
reg                             l1_istek_gecerli_i;
reg     [`L1_BLOK_BIT-1:0]      l1_istek_veri_i;
reg                             l1_istek_yaz_i;
wire                            l1_istek_hazir_o;
wire     [`L1_BLOK_BIT-1:0]     l1_veri_o;
wire                            l1_veri_gecerli_o;
reg                             l1_veri_hazir_i;

always begin
    clk_i = 0;
    #5;
    clk_i = 1;
    #5;
end

reg     [`ADRES_BIT-1:0]    cmd_addr_r;
wire    [`VERI_BIT-1:0]     rd_data_w;
reg     [`VERI_BIT-1:0]     wr_data_r;
reg                         wr_enable_r;
reg                         cmd_valid_r;

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

always @* begin
    mem_veri_i = rd_data_w;
    mem_istek_hazir_i = `HIGH;
    cmd_addr_r = mem_istek_adres_o;
    wr_data_r = mem_istek_veri_o;
    wr_enable_r = mem_istek_yaz_o;
    cmd_valid_r = mem_istek_gecerli_o;
end

localparam BELLEK_GECIKMESI = 1;
always @* begin
    repeat(BELLEK_GECIKMESI) @(posedge clk_i);
    mem_veri_gecerli_i <= mem_istek_gecerli_o;
end

veri_yolu_denetleyici vyd (
    .clk_i                  ( clk_i ),
    .rstn_i                 ( rstn_i ),
    .mem_istek_adres_o      ( mem_istek_adres_o ),
    .mem_istek_veri_o       ( mem_istek_veri_o ),
    .mem_istek_yaz_o        ( mem_istek_yaz_o ),
    .mem_istek_gecerli_o    ( mem_istek_gecerli_o ),
    .mem_istek_hazir_i      ( mem_istek_hazir_i ),
    .mem_veri_i             ( mem_veri_i ),
    .mem_veri_gecerli_i     ( mem_veri_gecerli_i ),
    .mem_veri_hazir_o       ( mem_veri_hazir_o ),
    .l1_istek_adres_i       ( l1_istek_adres_i ),
    .l1_istek_gecerli_i     ( l1_istek_gecerli_i ),
    .l1_istek_veri_i        ( l1_istek_veri_i ),
    .l1_istek_yaz_i         ( l1_istek_yaz_i ),
    .l1_istek_hazir_o       ( l1_istek_hazir_o ),
    .l1_veri_o              ( l1_veri_o ),
    .l1_veri_gecerli_o      ( l1_veri_gecerli_o ),
    .l1_veri_hazir_i        ( l1_veri_hazir_i )
);

localparam TEST_LEN = 4;
reg [7:0] rep_byte;

reg request_en;
reg istek_handshake;
reg veri_handshake;

integer i;
initial begin
    l1_istek_gecerli_i = `LOW;
    l1_veri_hazir_i = `LOW;
    rstn_i = `LOW;
    repeat(10) @(posedge clk_i);
    rstn_i = `HIGH;
    for (i = 0; i < TEST_LEN;) begin
        rep_byte = i[7:0];
        l1_istek_gecerli_i = `HIGH;
        l1_istek_adres_i = `BELLEK_BASLANGIC + i * `L1_BLOK_BIT / 8;
        l1_istek_veri_i = {{`L1_BLOK_BYTE{rep_byte}}};
        l1_istek_yaz_i = `HIGH;
        istek_handshake = l1_istek_hazir_o && l1_istek_gecerli_i;
        @(posedge clk_i) #2;
        if (istek_handshake) begin
            i = i + 1;
        end
    end
    request_en = `HIGH;
    for (i = 0; i < TEST_LEN;) begin
        l1_istek_gecerli_i = request_en;
        l1_istek_adres_i = `BELLEK_BASLANGIC + i * `L1_BLOK_BIT / 8;
        l1_istek_yaz_i = `LOW;
        l1_veri_hazir_i = `HIGH;
        istek_handshake = l1_istek_hazir_o && l1_istek_gecerli_i;
        veri_handshake = l1_veri_hazir_i && l1_veri_gecerli_o;
        @(posedge clk_i) #2;
        if (istek_handshake) begin
            request_en = `LOW;
        end
        if (veri_handshake) begin
            rep_byte = i[7:0];
            if (l1_veri_o != {{`L1_BLOK_BYTE{rep_byte}}}) begin
                $display("[SIM] Test failed at i = %0d.", i);
                $display("[SIM] ACTUAL: %0x\tEXPECTED: %0x", l1_veri_o, {{`L1_BLOK_BYTE{rep_byte}}});
                $finish;
            end
            request_en = `HIGH;
            i = i + 1;
        end
    end
    $display("[SIM] All tests passed.");
    $finish;
end

endmodule