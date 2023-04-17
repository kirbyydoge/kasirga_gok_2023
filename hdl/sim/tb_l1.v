`timescale 1ns / 1ps

`include "mikroislem.vh"
`include "sabitler.vh"

module tb_l1();

reg                                             clk_i;
reg                                             rstn_i;

// okuyan birim <> l1 denetleyici istek
reg     [`ADRES_BIT-1:0]                        l1v_port_istek_adres_i;
reg                                             l1v_port_istek_gecerli_i;
reg                                             l1v_port_istek_yaz_i;
reg     [`VERI_BIT-1:0]                         l1v_port_istek_veri_i;
wire                                            l1v_port_istek_hazir_o;

// l1 denetleyici veri <> okuyan birim 
wire    [`VERI_BIT-1:0]                         l1v_port_veri_o;
wire                                            l1v_port_veri_gecerli_o;
reg                                             l1v_port_veri_hazir_i;

// okuyan birim <> l1 denetleyici istek
reg     [`ADRES_BIT-1:0]                        l1b_port_istek_adres_i;
reg                                             l1b_port_istek_gecerli_i;
reg                                             l1b_port_istek_yaz_i;
reg     [`VERI_BIT-1:0]                         l1b_port_istek_veri_i;
wire                                            l1b_port_istek_hazir_o;

// l1 denetleyici veri <> okuyan birim 
wire    [`VERI_BIT-1:0]                         l1b_port_veri_o;
wire                                            l1b_port_veri_gecerli_o;
reg                                             l1b_port_veri_hazir_i;

// l1 denetleyici <> l1 SRAM (BRAM)
wire                                            l1v_istek_gecersiz_o;
wire    [`ADRES_SATIR_BIT-1:0]                  l1v_istek_satir_o;
wire    [`L1V_YOL-1:0]                          l1v_istek_yaz_o;
wire    [(`ADRES_ETIKET_BIT * `L1V_YOL)-1:0]    l1v_istek_etiket_o;
wire    [(`L1_BLOK_BIT * `L1V_YOL)-1:0]         l1v_istek_blok_o;

wire    [(`ADRES_ETIKET_BIT * `L1V_YOL)-1:0]    l1v_veri_etiket_i;
wire    [(`L1_BLOK_BIT * `L1V_YOL)-1:0]         l1v_veri_blok_i;
reg                                             l1v_veri_gecerli_i;

// l1 denetleyici <> l1 SRAM (BRAM)
wire                                            l1b_istek_gecersiz_o;
wire    [`ADRES_SATIR_BIT-1:0]                  l1b_istek_satir_o;
wire    [`L1B_YOL-1:0]                          l1b_istek_yaz_o;
wire    [(`ADRES_ETIKET_BIT * `L1B_YOL)-1:0]    l1b_istek_etiket_o;
wire    [(`L1_BLOK_BIT * `L1B_YOL)-1:0]         l1b_istek_blok_o;

wire    [(`ADRES_ETIKET_BIT * `L1B_YOL)-1:0]    l1b_veri_etiket_i;
wire    [(`L1_BLOK_BIT * `L1B_YOL)-1:0]         l1b_veri_blok_i;
reg                                             l1b_veri_gecerli_i;

// l1 denetleyici <> veri yolu denetleyici
wire    [`ADRES_BIT-1:0]        vy_l1v_istek_adres_o;
wire                            vy_l1v_istek_gecerli_o;
wire                            vy_l1v_istek_hazir_i;
wire                            vy_l1v_istek_yaz_o;
wire    [`L1_BLOK_BIT-1:0]      vy_l1v_istek_veri_o;
wire    [`L1_BLOK_BIT-1:0]      vy_l1v_veri_i;
wire                            vy_l1v_veri_gecerli_i;
wire                            vy_l1v_veri_hazir_o;

wire    [`ADRES_BIT-1:0]        vy_l1b_istek_adres_o;
wire                            vy_l1b_istek_gecerli_o;
wire                            vy_l1b_istek_hazir_i;
wire                            vy_l1b_istek_yaz_o;
wire    [`L1_BLOK_BIT-1:0]      vy_l1b_istek_veri_o;
wire    [`L1_BLOK_BIT-1:0]      vy_l1b_veri_i;
wire                            vy_l1b_veri_gecerli_i;
wire                            vy_l1b_veri_hazir_o;

wire    [`ADRES_BIT-1:0]        mem_istek_adres_o;
wire    [`VERI_BIT-1:0]         mem_istek_veri_o;
wire                            mem_istek_yaz_o;
wire                            mem_istek_gecerli_o;
reg                             mem_istek_hazir_i;
reg     [`VERI_BIT-1:0]         mem_veri_i;
reg                             mem_veri_gecerli_i;
wire                            mem_veri_hazir_o;

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
    .l1b_istek_adres_i      ( vy_l1b_istek_adres_o ),
    .l1b_istek_gecerli_i    ( vy_l1b_istek_gecerli_o ),
    .l1b_istek_veri_i       ( vy_l1b_istek_veri_o ),
    .l1b_istek_yaz_i        ( vy_l1b_istek_yaz_o ),
    .l1b_istek_hazir_o      ( vy_l1b_istek_hazir_i ),
    .l1b_veri_o             ( vy_l1b_veri_i ),
    .l1b_veri_gecerli_o     ( vy_l1b_veri_gecerli_i ),
    .l1b_veri_hazir_i       ( vy_l1b_veri_hazir_o ),
    .l1v_istek_adres_i      ( vy_l1v_istek_adres_o ),
    .l1v_istek_gecerli_i    ( vy_l1v_istek_gecerli_o ),
    .l1v_istek_veri_i       ( vy_l1v_istek_veri_o ),
    .l1v_istek_yaz_i        ( vy_l1v_istek_yaz_o ),
    .l1v_istek_hazir_o      ( vy_l1v_istek_hazir_i ),
    .l1v_veri_o             ( vy_l1v_veri_i ),
    .l1v_veri_gecerli_o     ( vy_l1v_veri_gecerli_i ),
    .l1v_veri_hazir_i       ( vy_l1v_veri_hazir_o )
);

wire [`L1_BLOK_BIT-1:0] l1v_bram_yaz_bloklar [0:`L1V_YOL-1];
wire [`L1_BLOK_BIT-1:0] l1v_bram_oku_bloklar [0:`L1V_YOL-1];
wire [`ADRES_ETIKET_BIT-1:0] l1v_bram_yaz_etiketler [0:`L1V_YOL-1];
wire [`ADRES_ETIKET_BIT-1:0] l1v_bram_oku_etiketler [0:`L1V_YOL-1];

genvar gen_i;
generate
    for (gen_i = 0; gen_i < `L1V_YOL; gen_i = gen_i + 1 ) begin
        assign l1v_bram_yaz_bloklar[gen_i] = l1v_istek_blok_o[gen_i * `L1_BLOK_BIT +: `L1_BLOK_BIT];
        assign l1v_bram_yaz_etiketler[gen_i] = l1v_istek_etiket_o[gen_i * `ADRES_ETIKET_BIT +: `ADRES_ETIKET_BIT];

        assign l1v_veri_blok_i[gen_i * `L1_BLOK_BIT +: `L1_BLOK_BIT] = l1v_bram_oku_bloklar[gen_i];
        assign l1v_veri_etiket_i[gen_i * `ADRES_ETIKET_BIT +: `ADRES_ETIKET_BIT] = l1v_bram_oku_etiketler[gen_i];

        bram_model #(
            .DATA_WIDTH(`ADRES_ETIKET_BIT),
            .BRAM_DEPTH(`L1V_SATIR)
        ) l1v_etiket (
            .clk_i(clk_i), 
            .cmd_en_i(!l1v_istek_gecersiz_o),
            .wr_en_i(l1v_istek_yaz_o[gen_i]), 
            .addr_i(l1v_istek_satir_o), 
            .data_i(l1v_bram_yaz_etiketler[gen_i]), 
            .data_o(l1v_bram_oku_etiketler[gen_i])
        );
        
        bram_model #(
            .DATA_WIDTH(`L1_BLOK_BIT),
            .BRAM_DEPTH(`L1V_SATIR)
        ) l1v_veri (
            .clk_i(clk_i), 
            .cmd_en_i(!l1v_istek_gecersiz_o),
            .wr_en_i(l1v_istek_yaz_o[gen_i]), 
            .addr_i(l1v_istek_satir_o), 
            .data_i(l1v_bram_yaz_bloklar[gen_i]), 
            .data_o(l1v_bram_oku_bloklar[gen_i])
        );
    end
endgenerate

always @(posedge clk_i) begin
    l1v_veri_gecerli_i <=  !l1v_istek_gecersiz_o && (l1v_istek_yaz_o == {`L1V_YOL{`LOW}});
end

l1v_denetleyici l1vd (
    .clk_i                      ( clk_i ),
    .rstn_i                     ( rstn_i ),
    .port_istek_adres_i         ( l1v_port_istek_adres_i ),
    .port_istek_gecerli_i       ( l1v_port_istek_gecerli_i ),
    .port_istek_yaz_i           ( l1v_port_istek_yaz_i ),
    .port_istek_veri_i          ( l1v_port_istek_veri_i ),
    .port_istek_hazir_o         ( l1v_port_istek_hazir_o ),
    .port_veri_o                ( l1v_port_veri_o ),
    .port_veri_gecerli_o        ( l1v_port_veri_gecerli_o ),
    .port_veri_hazir_i          ( l1v_port_veri_hazir_i ),
    .l1_istek_gecersiz_o        ( l1v_istek_gecersiz_o ),
    .l1_istek_satir_o           ( l1v_istek_satir_o ),
    .l1_istek_yaz_o             ( l1v_istek_yaz_o ),
    .l1_istek_etiket_o          ( l1v_istek_etiket_o ),
    .l1_istek_blok_o            ( l1v_istek_blok_o ),
    .l1_veri_etiket_i           ( l1v_veri_etiket_i ),
    .l1_veri_blok_i             ( l1v_veri_blok_i ),
    .l1_veri_gecerli_i          ( l1v_veri_gecerli_i ),
    .vy_istek_adres_o           ( vy_l1v_istek_adres_o ),
    .vy_istek_gecerli_o         ( vy_l1v_istek_gecerli_o ),
    .vy_istek_hazir_i           ( vy_l1v_istek_hazir_i ),
    .vy_istek_yaz_o             ( vy_l1v_istek_yaz_o ),
    .vy_istek_veri_o            ( vy_l1v_istek_veri_o ),
    .vy_veri_i                  ( vy_l1v_veri_i ),
    .vy_veri_gecerli_i          ( vy_l1v_veri_gecerli_i ),
    .vy_veri_hazir_o            ( vy_l1v_veri_hazir_o )
);

////

wire [`L1_BLOK_BIT-1:0] l1b_bram_yaz_bloklar [0:`L1B_YOL-1];
wire [`L1_BLOK_BIT-1:0] l1b_bram_oku_bloklar [0:`L1B_YOL-1];
wire [`ADRES_ETIKET_BIT-1:0] l1b_bram_yaz_etiketler [0:`L1B_YOL-1];
wire [`ADRES_ETIKET_BIT-1:0] l1b_bram_oku_etiketler [0:`L1B_YOL-1];

generate
    for (gen_i = 0; gen_i < `L1B_YOL; gen_i = gen_i + 1 ) begin
        assign l1b_bram_yaz_bloklar[gen_i] = l1b_istek_blok_o[gen_i * `L1_BLOK_BIT +: `L1_BLOK_BIT];
        assign l1b_bram_yaz_etiketler[gen_i] = l1b_istek_etiket_o[gen_i * `ADRES_ETIKET_BIT +: `ADRES_ETIKET_BIT];

        assign l1b_veri_blok_i[gen_i * `L1_BLOK_BIT +: `L1_BLOK_BIT] = l1b_bram_oku_bloklar[gen_i];
        assign l1b_veri_etiket_i[gen_i * `ADRES_ETIKET_BIT +: `ADRES_ETIKET_BIT] = l1b_bram_oku_etiketler[gen_i];

        bram_model #(
            .DATA_WIDTH(`ADRES_ETIKET_BIT),
            .BRAM_DEPTH(`L1B_SATIR)
        ) l1b_etiket (
            .clk_i(clk_i), 
            .cmd_en_i(!l1b_istek_gecersiz_o),
            .wr_en_i(l1b_istek_yaz_o[gen_i]), 
            .addr_i(l1b_istek_satir_o), 
            .data_i(l1b_bram_yaz_etiketler[gen_i]), 
            .data_o(l1b_bram_oku_etiketler[gen_i])
        );
        
        bram_model #(
            .DATA_WIDTH(`L1_BLOK_BIT),
            .BRAM_DEPTH(`L1B_SATIR)
        ) l1b_veri (
            .clk_i(clk_i), 
            .cmd_en_i(!l1b_istek_gecersiz_o),
            .wr_en_i(l1b_istek_yaz_o[gen_i]), 
            .addr_i(l1b_istek_satir_o), 
            .data_i(l1b_bram_yaz_bloklar[gen_i]), 
            .data_o(l1b_bram_oku_bloklar[gen_i])
        );
    end
endgenerate

always @(posedge clk_i) begin
    l1b_veri_gecerli_i <=  !l1b_istek_gecersiz_o && (l1b_istek_yaz_o == {`L1B_YOL{`LOW}});
end

l1b_denetleyici l1bd (
    .clk_i                      ( clk_i ),
    .rstn_i                     ( rstn_i ),
    .port_istek_adres_i         ( l1b_port_istek_adres_i ),
    .port_istek_gecerli_i       ( l1b_port_istek_gecerli_i ),
    .port_istek_yaz_i           ( l1b_port_istek_yaz_i ),
    .port_istek_veri_i          ( l1b_port_istek_veri_i ),
    .port_istek_hazir_o         ( l1b_port_istek_hazir_o ),
    .port_veri_o                ( l1b_port_veri_o ),
    .port_veri_gecerli_o        ( l1b_port_veri_gecerli_o ),
    .port_veri_hazir_i          ( l1b_port_veri_hazir_i ),
    .l1_istek_gecersiz_o        ( l1b_istek_gecersiz_o ),
    .l1_istek_satir_o           ( l1b_istek_satir_o ),
    .l1_istek_yaz_o             ( l1b_istek_yaz_o ),
    .l1_istek_etiket_o          ( l1b_istek_etiket_o ),
    .l1_istek_blok_o            ( l1b_istek_blok_o ),
    .l1_veri_etiket_i           ( l1b_veri_etiket_i ),
    .l1_veri_blok_i             ( l1b_veri_blok_i ),
    .l1_veri_gecerli_i          ( l1b_veri_gecerli_i ),
    .vy_istek_adres_o           ( vy_l1b_istek_adres_o ),
    .vy_istek_gecerli_o         ( vy_l1b_istek_gecerli_o ),
    .vy_istek_hazir_i           ( vy_l1b_istek_hazir_i ),
    .vy_istek_yaz_o             ( vy_l1b_istek_yaz_o ),
    .vy_istek_veri_o            ( vy_l1b_istek_veri_o ),
    .vy_veri_i                  ( vy_l1b_veri_i ),
    .vy_veri_gecerli_i          ( vy_l1b_veri_gecerli_i ),
    .vy_veri_hazir_o            ( vy_l1b_veri_hazir_o )
);

localparam ACCESS_COUNT = 500;
localparam L1V_BASE_ADDR = 'h4000_0000;
localparam L1B_BASE_ADDR = L1V_BASE_ADDR + ACCESS_COUNT * 4;
localparam DATA_WIDTH = 32;
localparam ACCESS_STEP = 1;

reg [7:0] l1v_rep_byte;
reg [7:0] l1b_rep_byte;

reg l1v_istek_handshake;
reg l1b_istek_handshake;

reg l1v_istek_cmd_en;
reg l1b_istek_cmd_en;

reg l1v_veri_handshake;
reg l1b_veri_handshake;

reg flag_test;

integer l1v_i;
integer l1b_i;
`define STRIDE_WRITE_READBACK
initial begin
    rstn_i = `LOW;
    repeat(10) @(posedge clk_i);
    rstn_i = `HIGH;
    l1v_port_istek_yaz_i = `LOW;
    l1v_port_veri_hazir_i = `HIGH;
    l1v_port_istek_veri_i = 0;

    l1b_port_istek_yaz_i = `LOW;
    l1b_port_veri_hazir_i = `HIGH;
    l1b_port_istek_veri_i = 0;

`ifdef STRIDE_READ
    l1v_i = 0;
    l1b_i = 0;
    while (l1v_i < ACCESS_COUNT || l1b_i < ACCESS_COUNT) begin
        // l1v
        l1v_port_istek_adres_i = L1V_BASE_ADDR + ACCESS_STEP * l1v_i * DATA_WIDTH / 8;
        l1v_port_istek_gecerli_i = l1v_i < ACCESS_COUNT;
        l1v_istek_handshake = l1v_port_istek_hazir_o && l1v_port_istek_gecerli_i;

        // l1b
        l1b_port_istek_adres_i = L1B_BASE_ADDR + ACCESS_STEP * l1b_i * DATA_WIDTH / 8;
        l1b_port_istek_gecerli_i = l1b_i < ACCESS_COUNT;
        l1b_istek_handshake = l1b_port_istek_hazir_o && l1b_port_istek_gecerli_i;

        @(posedge clk_i) #2;

        if (l1v_istek_handshake) begin
            l1v_i = l1v_i + 1;
        end
        if (l1b_istek_handshake) begin
            l1b_i = l1b_i + 1;
        end
    end
    l1v_port_istek_gecerli_i = `LOW;
    l1b_port_istek_gecerli_i = `LOW;
`endif

`ifdef STRIDE_WRITE_READBACK
    l1v_i = 0;
    l1b_i = 0;
    flag_test = `HIGH;
    while (l1v_i < ACCESS_COUNT || l1b_i < ACCESS_COUNT) begin
        // l1v
        l1v_rep_byte = l1v_i[7:0] + 1;
        l1v_port_istek_adres_i = L1V_BASE_ADDR + ACCESS_STEP * l1v_i * DATA_WIDTH / 8;
        l1v_port_istek_gecerli_i = l1v_i < ACCESS_COUNT;
        l1v_port_istek_yaz_i = `HIGH;
        l1v_port_istek_veri_i = {`VERI_BYTE{l1v_rep_byte}};
        l1v_istek_handshake = l1v_port_istek_hazir_o && l1v_port_istek_gecerli_i;

        // l1b
        l1b_rep_byte = l1b_i[7:0] + 1;
        l1b_port_istek_adres_i = L1B_BASE_ADDR + ACCESS_STEP * l1b_i * DATA_WIDTH / 8;
        l1b_port_istek_gecerli_i = l1b_i < ACCESS_COUNT;
        l1b_port_istek_yaz_i = `HIGH;
        l1b_port_istek_veri_i = {`VERI_BYTE{l1b_rep_byte}};
        l1b_istek_handshake = l1b_port_istek_hazir_o && l1b_port_istek_gecerli_i;

        @(posedge clk_i) #2;

        if (l1v_istek_handshake) begin
            l1v_i = l1v_i + 1;
        end
        if (l1b_istek_handshake) begin
            l1b_i = l1b_i + 1;
        end
    end

    l1v_port_istek_gecerli_i = `LOW;
    l1v_istek_cmd_en = `HIGH;
    l1b_port_istek_gecerli_i = `LOW;
    l1b_istek_cmd_en = `HIGH;

    l1v_i = 0;
    l1b_i = 0;
    while (l1v_i < ACCESS_COUNT || l1b_i < ACCESS_COUNT) begin
        // l1v
        l1v_rep_byte = l1v_i[7:0] + 1;
        l1v_port_istek_adres_i = L1V_BASE_ADDR + ACCESS_STEP * l1v_i * DATA_WIDTH / 8;
        l1v_port_istek_gecerli_i = l1v_istek_cmd_en && l1v_i < ACCESS_COUNT;
        l1v_port_istek_yaz_i = `LOW;
        l1v_port_istek_veri_i = 0;
        l1v_istek_handshake = l1v_port_istek_hazir_o && l1v_port_istek_gecerli_i;
        l1v_veri_handshake = l1v_port_veri_hazir_i && l1v_port_veri_gecerli_o;

        l1b_rep_byte = l1b_i[7:0] + 1;
        l1b_port_istek_adres_i = L1B_BASE_ADDR + ACCESS_STEP * l1b_i * DATA_WIDTH / 8;
        l1b_port_istek_gecerli_i = l1b_istek_cmd_en && l1b_i < ACCESS_COUNT;
        l1b_port_istek_yaz_i = `LOW;
        l1b_port_istek_veri_i = 0;
        l1b_istek_handshake = l1b_port_istek_hazir_o && l1b_port_istek_gecerli_i;
        l1b_veri_handshake = l1b_port_veri_hazir_i && l1b_port_veri_gecerli_o;

        @(posedge clk_i) #2;
        
        if (l1v_istek_handshake) begin
            l1v_istek_cmd_en = `LOW;
        end
        if (l1v_veri_handshake) begin
            if (l1v_port_veri_o != {`VERI_BYTE{l1v_rep_byte}}) begin
                $display("[SIM] Test STRIDE_WRITE_READBACK failed at i = %0d.", l1v_i);
                $display("[SIM] ACTUAL: %0x\tEXPECTED: %0x", l1v_port_veri_o, {`VERI_BYTE{l1v_rep_byte}});
                flag_test = `LOW;
            end
            l1v_istek_cmd_en = `HIGH;
            l1v_i = l1v_i + 1;
        end
        
        if (l1b_istek_handshake) begin
            l1b_istek_cmd_en = `LOW;
        end
        if (l1b_veri_handshake) begin
            if (l1b_port_veri_o != {`VERI_BYTE{l1b_rep_byte}}) begin
                $display("[SIM] Test STRIDE_WRITE_READBACK failed at i = %0d.", l1b_i);
                $display("[SIM] ACTUAL: %0x\tEXPECTED: %0x", l1b_port_veri_o, {`VERI_BYTE{l1b_rep_byte}});
                flag_test = `LOW;
            end
            l1b_istek_cmd_en = `HIGH;
            l1b_i = l1b_i + 1;
        end
    end
    l1v_port_istek_gecerli_i = `LOW;
    l1b_port_istek_gecerli_i = `LOW;

    if (flag_test) begin
        $display("[SIM] Test STRIDE_WRITE_READBACK passed.");
    end
`endif

`ifdef RANDOM
    //TODO:
`endif

    $display("[SIM] All tests passed.");
    $finish;
end

endmodule