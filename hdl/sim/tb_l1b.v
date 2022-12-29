`timescale 1ns / 1ps

`include "mikroislem.vh"
`include "sabitler.vh"

module tb_l1b();

reg                                             clk_i;
reg                                             rstn_i;

// okuyan birim <> l1 denetleyici istek
reg     [`ADRES_BIT-1:0]                        port_istek_adres_i;
reg                                             port_istek_gecerli_i;
reg                                             port_istek_yaz_i;
reg     [`VERI_BIT-1:0]                         port_istek_veri_i;
wire                                            port_istek_hazir_o;

// l1 denetleyici veri <> okuyan birim 
wire    [`VERI_BIT-1:0]                         port_veri_o;
wire                                            port_veri_gecerli_o;
reg                                             port_veri_hazir_i;

// l1 denetleyici <> l1 SRAM (BRAM)
wire                                            l1_istek_gecersiz_o;
wire    [`ADRES_SATIR_BIT-1:0]                  l1_istek_satir_o;
wire    [`L1_YOL-1:0]                           l1_istek_yaz_o;
wire    [(`ADRES_ETIKET_BIT * `L1_YOL)-1:0]     l1_istek_etiket_o;
wire    [(`L1_BLOK_BIT * `L1_YOL)-1:0]          l1_istek_blok_o;

wire    [(`ADRES_ETIKET_BIT * `L1_YOL)-1:0]     l1_veri_etiket_i;
wire    [(`L1_BLOK_BIT * `L1_YOL)-1:0]          l1_veri_blok_i;
reg                                             l1_veri_gecerli_i;

// l1 denetleyici <> vy denetleyici
wire    [`ADRES_BIT-1:0]        vy_istek_adres_o;
wire                            vy_istek_gecerli_o;
wire                            vy_istek_hazir_i;
wire                            vy_istek_yaz_o;
wire    [`L1_BLOK_BIT-1:0]      vy_istek_veri_o;
wire     [`L1_BLOK_BIT-1:0]     vy_veri_i;
wire                            vy_veri_gecerli_i;
wire                            vy_veri_hazir_o;

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

reg     [`ADRES_BIT-1:0]    cmd_addr;
wire    [`VERI_BIT-1:0]     rd_data;
reg     [`VERI_BIT-1:0]     wr_data;
reg                         wr_enable;
reg                         cmd_valid;

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

always @* begin
    mem_veri_i = rd_data;
    mem_istek_hazir_i = `HIGH;
    cmd_addr = mem_istek_adres_o;
    wr_data = mem_istek_veri_o;
    wr_enable = mem_istek_yaz_o;
    cmd_valid = mem_istek_gecerli_o;
end

localparam BELLEK_GECIKMESI = 1;
always @* begin
    repeat(BELLEK_GECIKMESI) @(posedge clk_i);
    mem_veri_gecerli_i <= mem_istek_gecerli_o;
end

vy_denetleyici abd (
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
    .l1_istek_adres_i       ( vy_istek_adres_o ),
    .l1_istek_gecerli_i     ( vy_istek_gecerli_o ),
    .l1_istek_veri_i        ( vy_istek_veri_o ),
    .l1_istek_yaz_i         ( vy_istek_yaz_o ),
    .l1_istek_hazir_o       ( vy_istek_hazir_i ),
    .l1_veri_o              ( vy_veri_i ),
    .l1_veri_gecerli_o      ( vy_veri_gecerli_i ),
    .l1_veri_hazir_i        ( vy_veri_hazir_o )
);


wire [`L1_BLOK_BIT-1:0] bram_yaz_bloklar [0:`L1_YOL-1];
wire [`L1_BLOK_BIT-1:0] bram_oku_bloklar [0:`L1_YOL-1];
wire [`ADRES_ETIKET_BIT-1:0] bram_yaz_etiketler [0:`L1_YOL-1];
wire [`ADRES_ETIKET_BIT-1:0] bram_oku_etiketler [0:`L1_YOL-1];

genvar gen_i;
generate
    for (gen_i = 0; gen_i < `L1_YOL; gen_i = gen_i + 1 ) begin
        assign bram_yaz_bloklar[gen_i] = l1_istek_blok_o[gen_i * `L1_BLOK_BIT +: `L1_BLOK_BIT];
        assign bram_yaz_etiketler[gen_i] = l1_istek_etiket_o[gen_i * `ADRES_ETIKET_BIT +: `ADRES_ETIKET_BIT];

        assign l1_veri_blok_i[gen_i * `L1_BLOK_BIT +: `L1_BLOK_BIT] = bram_oku_bloklar[gen_i];
        assign l1_veri_etiket_i[gen_i * `ADRES_ETIKET_BIT +: `ADRES_ETIKET_BIT] = bram_oku_etiketler[gen_i];

        l1_etiket_bram l1_etiket (
            .clka(clk_i), 
            .ena(!l1_istek_gecersiz_o),
            .wea(l1_istek_yaz_o[gen_i]), 
            .addra(l1_istek_satir_o), 
            .dina(bram_yaz_etiketler[gen_i]), 
            .douta(bram_oku_etiketler[gen_i])
        );
        l1_veri_bram l1_veri (
            .clka(clk_i), 
            .ena(!l1_istek_gecersiz_o),
            .wea(l1_istek_yaz_o[gen_i]), 
            .addra(l1_istek_satir_o), 
            .dina(bram_yaz_bloklar[gen_i]), 
            .douta(bram_oku_bloklar[gen_i])
        );
    end
endgenerate

always @(posedge clk_i) begin
    l1_veri_gecerli_i <=  !l1_istek_gecersiz_o && (l1_istek_yaz_o == {`L1_YOL{`LOW}});
end

l1b_denetleyici l1b (
    .clk_i                  ( clk_i ),
    .rstn_i                 ( rstn_i ),
    .port_istek_adres_i     ( port_istek_adres_i ),
    .port_istek_gecerli_i   ( port_istek_gecerli_i ),
    .port_istek_yaz_i       ( port_istek_yaz_i ),
    .port_istek_veri_i      ( port_istek_veri_i ),
    .port_istek_hazir_o     ( port_istek_hazir_o ),
    .port_veri_o            ( port_veri_o ),
    .port_veri_gecerli_o    ( port_veri_gecerli_o ),
    .port_veri_hazir_i      ( port_veri_hazir_i ),
    .l1_istek_gecersiz_o    ( l1_istek_gecersiz_o ),
    .l1_istek_satir_o       ( l1_istek_satir_o ),
    .l1_istek_yaz_o         ( l1_istek_yaz_o ),
    .l1_istek_etiket_o      ( l1_istek_etiket_o ),
    .l1_istek_blok_o        ( l1_istek_blok_o ),
    .l1_veri_etiket_i       ( l1_veri_etiket_i ),
    .l1_veri_blok_i         ( l1_veri_blok_i ),
    .l1_veri_gecerli_i      ( l1_veri_gecerli_i ),
    .vy_istek_adres_o       ( vy_istek_adres_o ),
    .vy_istek_gecerli_o     ( vy_istek_gecerli_o ),
    .vy_istek_hazir_i       ( vy_istek_hazir_i ),
    .vy_istek_yaz_o         ( vy_istek_yaz_o ),
    .vy_istek_veri_o        ( vy_istek_veri_o ),
    .vy_veri_i              ( vy_veri_i ),
    .vy_veri_gecerli_i      ( vy_veri_gecerli_i ),
    .vy_veri_hazir_o        ( vy_veri_hazir_o )
);

localparam ACCESS_COUNT = 2000;
localparam DATA_WIDTH = 32;
localparam ACCESS_STEP = 1;

reg [7:0] rep_byte;
reg istek_handshake;
reg istek_enable;
reg veri_handshake;
reg flag_test;

integer i;
`define STRIDE_WRITE_READBACK
initial begin
    rstn_i = `LOW;
    repeat(10) @(posedge clk_i);
    rstn_i = `HIGH;
    port_istek_yaz_i = `LOW;
    port_veri_hazir_i = `HIGH;
    port_istek_veri_i = 0;

`ifdef STRIDE_READ
    for (i = 0; i < ACCESS_COUNT;) begin
        port_istek_adres_i = `BELLEK_BASLANGIC + ACCESS_STEP * i * DATA_WIDTH / 8;
        port_istek_gecerli_i = `HIGH;
        istek_handshake = port_istek_hazir_o && port_istek_gecerli_i;
        @(posedge clk_i) #2;
        if (istek_handshake) begin
            i = i + 1;
        end
    end
    port_istek_gecerli_i = `LOW;
`endif

`ifdef STRIDE_WRITE_READBACK
    flag_test = `HIGH;
    for (i = 0; i < ACCESS_COUNT;) begin
        rep_byte = i[7:0] + 1;
        port_istek_adres_i = `BELLEK_BASLANGIC + ACCESS_STEP * i * DATA_WIDTH / 8;
        port_istek_gecerli_i = `HIGH;
        port_istek_yaz_i = `HIGH;
        port_istek_veri_i = {`VERI_BYTE{rep_byte}};
        istek_handshake = port_istek_hazir_o && port_istek_gecerli_i;
        @(posedge clk_i) #2;
        if (istek_handshake) begin
            i = i + 1;
        end
    end
    port_istek_gecerli_i = `LOW;
    istek_enable = `HIGH;
    for (i = 0; i < ACCESS_COUNT;) begin
        rep_byte = i[7:0] + 1;
        port_istek_adres_i = `BELLEK_BASLANGIC + ACCESS_STEP * i * DATA_WIDTH / 8;
        port_istek_gecerli_i = istek_enable;
        port_istek_yaz_i = `LOW;
        port_istek_veri_i = 0;
        istek_handshake = port_istek_hazir_o && port_istek_gecerli_i;
        veri_handshake = port_veri_hazir_i && port_veri_gecerli_o;
        @(posedge clk_i) #2;
        if (istek_handshake) begin
            istek_enable = `LOW;
        end
        if (veri_handshake) begin
            if (port_veri_o != {`VERI_BYTE{rep_byte}}) begin
                $display("[SIM] Test STRIDE_WRITE_READBACK failed at i = %0d.", i);
                $display("[SIM] ACTUAL: %0x\tEXPECTED: %0x", port_veri_o, {`VERI_BYTE{rep_byte}});
                flag_test = `LOW;
            end
            istek_enable = `HIGH;
            i = i + 1;
        end
    end
    port_istek_gecerli_i = `LOW;

    if (flag_test) begin
        $display("[SIM] Test STRIDE_WRITE_READBACK passed.");
    end
`endif

`ifdef RANDOM
    //TODO:
`endif
end

endmodule