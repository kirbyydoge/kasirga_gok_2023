`timescale 1ns/1ps

`include "sabitler.vh"

module islemci (
  input                 clk,
  input                 resetn,

  output                iomem_valid,
  input                 iomem_ready,
  output    [3:0]       iomem_wstrb,
  output    [31:0]      iomem_addr,
  output    [31:0]      iomem_wdata,
  input     [31:0]      iomem_rdata,

  output                spi_cs_o,
  output                spi_sck_o,
  output                spi_mosi_o,
  input                 spi_miso_i,

  output                uart_tx_o,
  input                 uart_rx_i,

  output                pwm0_o,
  output                pwm1_o
);

// ---- Cekirdek ----
wire                            io_cek_clk_w;
wire                            io_cek_rstn_w;
wire    [`L1_BLOK_BIT-1:0]      io_cek_buyruk_yanit_veri_w;
wire                            io_cek_buyruk_yanit_gecerli_w;
wire                            io_cek_buyruk_yanit_hazir_w;
wire    [`ADRES_BIT-1:0]        io_cek_buyruk_istek_adres_w;
wire                            io_cek_buyruk_istek_gecerli_w;
wire                            io_cek_buyruk_istek_hazir_w;
wire    [`VERI_BIT-1:0]         io_cek_l1vd_yanit_veri_w;
wire                            io_cek_l1vd_yanit_gecerli_w;
wire                            io_cek_l1vd_yanit_hazir_w;
wire    [`VERI_BIT-1:0]         io_cek_l1vd_istek_veri_w;
wire    [`ADRES_BIT-1:0]        io_cek_l1vd_istek_adres_w;
wire                            io_cek_l1vd_istek_yaz_w;
wire                            io_cek_l1vd_istek_gecerli_w;
wire                            io_cek_l1vd_istek_hazir_w;

cekirdek cekirdek (
    .clk_i                      ( io_cek_clk_w ),
    .rstn_i                     ( io_cek_rstn_w ),
    .buyruk_yanit_veri_i        ( io_cek_buyruk_yanit_veri_w ),
    .buyruk_yanit_gecerli_i     ( io_cek_buyruk_yanit_gecerli_w ),
    .buyruk_yanit_hazir_o       ( io_cek_buyruk_yanit_hazir_w ),
    .buyruk_istek_adres_o       ( io_cek_buyruk_istek_adres_w ),
    .buyruk_istek_gecerli_o     ( io_cek_buyruk_istek_gecerli_w ),
    .buyruk_istek_hazir_i       ( io_cek_buyruk_istek_hazir_w ),
    .l1v_yanit_veri_i           ( io_cek_l1vd_yanit_veri_w ),
    .l1v_yanit_gecerli_i        ( io_cek_l1vd_yanit_gecerli_w ),
    .l1v_yanit_hazir_o          ( io_cek_l1vd_yanit_hazir_w ),
    .l1v_istek_veri_o           ( io_cek_l1vd_istek_veri_w ),
    .l1v_istek_adres_o          ( io_cek_l1vd_istek_adres_w ),
    .l1v_istek_yaz_o            ( io_cek_l1vd_istek_yaz_w ),
    .l1v_istek_gecerli_o        ( io_cek_l1vd_istek_gecerli_w ),
    .l1v_istek_hazir_i          ( io_cek_l1vd_istek_hazir_w )
);

// ---- L1 Buyruk Denetleyicisi ----
wire                                            io_l1bd_clk_w;
wire                                            io_l1bd_rstn_w;
wire    [`ADRES_BIT-1:0]                        io_l1bd_port_istek_adres_w;
wire                                            io_l1bd_port_istek_gecerli_w;
wire                                            io_l1bd_port_istek_yaz_w;
wire    [`VERI_BIT-1:0]                         io_l1bd_port_istek_veri_w;
wire                                            io_l1bd_port_istek_hazir_w;
wire    [`VERI_BIT-1:0]                         io_l1bd_port_veri_w;
wire                                            io_l1bd_port_veri_gecerli_w;
wire                                            io_l1bd_port_veri_hazir_w;
wire                                            io_l1bd_l1_istek_gecersiz_w;
wire    [`ADRES_SATIR_BIT-1:0]                  io_l1bd_l1_istek_satir_w;
wire    [`L1B_YOL-1:0]                          io_l1bd_l1_istek_yaz_w;
wire    [(`ADRES_ETIKET_BIT * `L1B_YOL)-1:0]    io_l1bd_l1_istek_etiket_w;
wire    [(`L1_BLOK_BIT * `L1B_YOL)-1:0]         io_l1bd_l1_istek_blok_w;
wire    [(`ADRES_ETIKET_BIT * `L1B_YOL)-1:0]    io_l1bd_l1_veri_etiket_w;
wire    [(`L1_BLOK_BIT * `L1B_YOL)-1:0]         io_l1bd_l1_veri_blok_w;
wire                                            io_l1bd_l1_veri_gecerli_w;
wire    [`ADRES_BIT-1:0]                        io_l1bd_vy_istek_adres_w;
wire                                            io_l1bd_vy_istek_gecerli_w;
wire                                            io_l1bd_vy_istek_hazir_w;
wire                                            io_l1bd_vy_istek_yaz_w;
wire    [`L1_BLOK_BIT-1:0]                      io_l1bd_vy_istek_veri_w;
wire    [`L1_BLOK_BIT-1:0]                      io_l1bd_vy_veri_w;
wire                                            io_l1bd_vy_veri_gecerli_w;
wire                                            io_l1bd_vy_veri_hazir_w;

l1b_denetleyici l1bd (
    .clk_i                                      ( io_l1bd_clk_w ),
    .rstn_i                                     ( io_l1bd_rstn_w ),
    .port_istek_adres_i                         ( io_l1bd_port_istek_adres_w ),
    .port_istek_gecerli_i                       ( io_l1bd_port_istek_gecerli_w ),
    .port_istek_yaz_i                           ( io_l1bd_port_istek_yaz_w ),
    .port_istek_veri_i                          ( io_l1bd_port_istek_veri_w ),
    .port_istek_hazir_o                         ( io_l1bd_port_istek_hazir_w ),
    .port_veri_o                                ( io_l1bd_port_veri_w ),
    .port_veri_gecerli_o                        ( io_l1bd_port_veri_gecerli_w ),
    .port_veri_hazir_i                          ( io_l1bd_port_veri_hazir_w ),
    .l1_istek_gecersiz_o                        ( io_l1bd_l1_istek_gecersiz_w ),
    .l1_istek_satir_o                           ( io_l1bd_l1_istek_satir_w ),
    .l1_istek_yaz_o                             ( io_l1bd_l1_istek_yaz_w ),
    .l1_istek_etiket_o                          ( io_l1bd_l1_istek_etiket_w ),
    .l1_istek_blok_o                            ( io_l1bd_l1_istek_blok_w ),
    .l1_veri_etiket_i                           ( io_l1bd_l1_veri_etiket_w ),
    .l1_veri_blok_i                             ( io_l1bd_l1_veri_blok_w ),
    .l1_veri_gecerli_i                          ( io_l1bd_l1_veri_gecerli_w ),
    .vy_istek_adres_o                           ( io_l1bd_vy_istek_adres_w ),
    .vy_istek_gecerli_o                         ( io_l1bd_vy_istek_gecerli_w ),
    .vy_istek_hazir_i                           ( io_l1bd_vy_istek_hazir_w ),
    .vy_istek_yaz_o                             ( io_l1bd_vy_istek_yaz_w ),
    .vy_istek_veri_o                            ( io_l1bd_vy_istek_veri_w ),
    .vy_veri_i                                  ( io_l1bd_vy_veri_w ),
    .vy_veri_gecerli_i                          ( io_l1bd_vy_veri_gecerli_w ),
    .vy_veri_hazir_o                            ( io_l1bd_vy_veri_hazir_w )
);

// ---- L1 Buyruk Onbellegi ----
wire                            io_l1bv_clk_w;
wire                            io_l1bv_komut_gecerli_w;
wire [`L1B_YOL-1:0]             io_l1bv_komut_yaz_w;
wire [`ADRES_SATIR_BIT-1:0]     io_l1bv_komut_adres_w;

wire [`ADRES_ETIKET_BIT-1:0]    io_l1bv_yaz_etiket_bw       [0:`L1B_YOL-1];
wire [`L1_BLOK_BIT-1:0]         io_l1bv_yaz_blok_bw         [0:`L1B_YOL-1];

wire [`ADRES_ETIKET_BIT-1:0]    io_l1bv_oku_etiket_bw       [0:`L1B_YOL-1];
wire [`L1_BLOK_BIT-1:0]         io_l1bv_oku_blok_bw         [0:`L1B_YOL-1];

genvar i;
generate
    for (i = 0; i < `L1B_YOL; i = i + 1) begin
        bram_model #(
            .DATA_WIDTH(`ADRES_ETIKET_BIT),
            .BRAM_DEPTH(`L1B_SATIR)
        ) l1b_etiket (
            .clk_i          ( io_l1bv_clk_w ), 
            .cmd_en_i       ( io_l1bv_komut_gecerli_w ),
            .wr_en_i        ( io_l1bv_komut_yaz_w[i] ), 
            .addr_i         ( io_l1bv_komut_adres_w ), 
            .data_i         ( io_l1bv_yaz_etiket_bw[i] ), 
            .data_o         ( io_l1bv_oku_etiket_bw[i] )
        );
        
        bram_model #(
            .DATA_WIDTH(`L1_BLOK_BIT),
            .BRAM_DEPTH(`L1B_SATIR)
        ) l1b_veri (
            .clk_i          ( io_l1bv_clk_w ),
            .cmd_en_i       ( io_l1bv_komut_gecerli_w ),
            .wr_en_i        ( io_l1bv_komut_yaz_w[i] ), 
            .addr_i         ( io_l1bv_komut_adres_w ), 
            .data_i         ( io_l1bv_yaz_blok_bw[i] ), 
            .data_o         ( io_l1bv_oku_blok_bw[i] )
        );
    end
endgenerate

// ---- Veri Yolu Denetleyicisi ----
wire                            io_vyd_clk_w;
wire                            io_vyd_rstn_w;
wire    [`ADRES_BIT-1:0]        io_vyd_mem_istek_adres_w;
wire    [`VERI_BIT-1:0]         io_vyd_mem_istek_veri_w;
wire                            io_vyd_mem_istek_yaz_w;
wire                            io_vyd_mem_istek_gecerli_w;
wire                            io_vyd_mem_istek_hazir_w;
wire    [`VERI_BIT-1:0]         io_vyd_mem_veri_w;
wire                            io_vyd_mem_veri_gecerli_w;
wire                            io_vyd_mem_veri_hazir_w;
wire    [`ADRES_BIT-1:0]        io_vyd_l1_istek_adres_w;
wire                            io_vyd_l1_istek_gecerli_w;
wire    [`L1_BLOK_BIT-1:0]      io_vyd_l1_istek_veri_w;
wire                            io_vyd_l1_istek_yaz_w;
wire                            io_vyd_l1_istek_hazir_w;
wire    [`L1_BLOK_BIT-1:0]      io_vyd_l1_veri_w;
wire                            io_vyd_l1_veri_gecerli_w;
wire                            io_vyd_l1_veri_hazir_w;

veri_yolu_denetleyici vyd (
    .clk_i               ( io_vyd_clk_w ),
    .rstn_i              ( io_vyd_rstn_w ),
    .mem_istek_adres_o   ( io_vyd_mem_istek_adres_w ),
    .mem_istek_veri_o    ( io_vyd_mem_istek_veri_w ),
    .mem_istek_yaz_o     ( io_vyd_mem_istek_yaz_w ),
    .mem_istek_gecerli_o ( io_vyd_mem_istek_gecerli_w ),
    .mem_istek_hazir_i   ( io_vyd_mem_istek_hazir_w ),
    .mem_veri_i          ( io_vyd_mem_veri_w ),
    .mem_veri_gecerli_i  ( io_vyd_mem_veri_gecerli_w ),
    .mem_veri_hazir_o    ( io_vyd_mem_veri_hazir_w ),
    .l1_istek_adres_i    ( io_vyd_l1_istek_adres_w ),
    .l1_istek_gecerli_i  ( io_vyd_l1_istek_gecerli_w ),
    .l1_istek_veri_i     ( io_vyd_l1_istek_veri_w ),
    .l1_istek_yaz_i      ( io_vyd_l1_istek_yaz_w ),
    .l1_istek_hazir_o    ( io_vyd_l1_istek_hazir_w ),
    .l1_veri_o           ( io_vyd_l1_veri_w ),
    .l1_veri_gecerli_o   ( io_vyd_l1_veri_gecerli_w ),
    .l1_veri_hazir_i     ( io_vyd_l1_veri_hazir_w )
);

// Cekirdek < Sistem
assign io_cek_clk_w = clk;
assign io_cek_rstn_w = resetn;

// Cekirdek < Veri Yolu Denetleyicisi
assign io_cek_l1vd_yanit_veri_w = 0;
assign io_cek_l1vd_yanit_gecerli_w = `LOW;
assign io_cek_l1vd_istek_hazir_w = `HIGH;

// L1BD < Sistem
assign io_l1bd_clk_w = clk;
assign io_l1bd_rstn_w = resetn;

// L1BV < Sistem
assign io_l1bv_clk_w = clk;

// Veri yolu denetleyicisi < Sistem
assign io_vyd_clk_w = clk;
assign io_vyd_rstn_w = resetn;

// Cekirdek < L1BD
assign io_cek_buyruk_yanit_veri_w = io_l1bd_port_veri_w;
assign io_cek_buyruk_yanit_gecerli_w = io_l1bd_port_veri_gecerli_w;
assign io_cek_buyruk_istek_hazir_w = io_l1bd_port_istek_hazir_w;

// L1BD < Cekirdek
assign io_l1bd_port_istek_adres_w = io_cek_buyruk_istek_adres_w;
assign io_l1bd_port_istek_gecerli_w = io_cek_buyruk_istek_gecerli_w;
assign io_l1bd_port_istek_yaz_w = `LOW; // Getir asla yazmaz
assign io_l1bd_port_istek_veri_w = {`L1_BLOK_BIT{1'b0}}; // Getir asla yazmaz
assign io_l1bd_port_veri_hazir_w = io_cek_buyruk_yanit_hazir_w;

// L1BD < L1BV Okuma / Yazma Gecikmesi
reg [`L1_ONBELLEK_GECIKME-1:0]  io_sistem_l1bv_istek_r;
wire                            io_sistem_l1bv_gecerli_w;

always @(posedge io_l1bd_clk_w) begin
    if (!resetn) begin
        io_sistem_l1bv_istek_r <= {`L1_ONBELLEK_GECIKME{1'b0}};
    end
    else begin
        io_sistem_l1bv_istek_r <= {io_sistem_l1bv_istek_r[`L1_ONBELLEK_GECIKME-2:0], (!io_l1bd_l1_istek_gecersiz_w && !(|io_l1bd_l1_istek_yaz_w))};
    end
end
assign io_sistem_l1bv_gecerli_w = io_sistem_l1bv_istek_r[`L1_ONBELLEK_GECIKME-1];

// L1BD < L1BV
assign io_l1bd_l1_veri_gecerli_w = io_sistem_l1bv_gecerli_w;

generate
    for (i = 0; i < `L1B_YOL; i = i + 1) begin
        assign io_l1bd_l1_veri_etiket_w[i * `ADRES_ETIKET_BIT +: `ADRES_ETIKET_BIT] = io_l1bv_oku_etiket_bw[i];
        assign io_l1bd_l1_veri_blok_w[i * `L1_BLOK_BIT +: `L1_BLOK_BIT]   = io_l1bv_oku_blok_bw[i];
    end
endgenerate

// L1BV < L1BD
assign io_l1bv_komut_gecerli_w = !io_l1bd_l1_istek_gecersiz_w;
assign io_l1bv_komut_adres_w = io_l1bd_l1_istek_satir_w;
assign io_l1bv_komut_yaz_w = io_l1bd_l1_istek_yaz_w;

generate
    for (i = 0; i < `L1B_YOL; i = i + 1) begin
        assign io_l1bv_yaz_etiket_bw[i] = io_l1bd_l1_istek_etiket_w[i * `ADRES_ETIKET_BIT +: `ADRES_ETIKET_BIT];
        assign io_l1bv_yaz_blok_bw[i] = io_l1bd_l1_istek_blok_w[i * `L1_BLOK_BIT +: `L1_BLOK_BIT];
    end
endgenerate

// TODO: Veri Onbellegi Eklenince port bunlarin arbitrate edilmesi lazim
// L1BD < Veri Yolu Denetleyicisi
assign io_l1bd_vy_istek_hazir_w = io_vyd_l1_istek_hazir_w;
assign io_l1bd_vy_veri_w = io_vyd_l1_veri_w;
assign io_l1bd_vy_veri_gecerli_w = io_vyd_l1_veri_gecerli_w;

// Veri Yolu Denetleyicisi < L1BD
assign io_vyd_l1_istek_adres_w = io_l1bd_vy_istek_adres_w;
assign io_vyd_l1_istek_gecerli_w = io_l1bd_vy_istek_gecerli_w;
assign io_vyd_l1_istek_veri_w = io_l1bd_vy_istek_veri_w;
assign io_vyd_l1_istek_yaz_w = io_l1bd_vy_istek_yaz_w;
assign io_vyd_l1_veri_hazir_w = io_l1bd_vy_veri_hazir_w;

// Sistem Veri Yolu < Veri Yolu Denetleyicisi
assign iomem_wdata = io_vyd_mem_istek_veri_w;
assign iomem_valid = io_vyd_mem_istek_gecerli_w;
assign iomem_addr = io_vyd_mem_istek_adres_w;
generate
    for (i = 0; i < `VERI_BYTE; i = i + 1) begin
        assign iomem_wstrb[i] = io_vyd_mem_istek_yaz_w;
    end
endgenerate

// Veri Yolu Denetleyicisi < Sistem Veri Yolu Istek Hazir / Veri Gecerli
reg bellek_istek_bosta;
reg bellek_oku_istek;
reg bellek_veri_gecerli;

always @(posedge clk) begin
    if (!resetn) begin
        bellek_istek_bosta <= 1'b1;
        bellek_oku_istek <= 1'b0;
        bellek_veri_gecerli <= 1'b0;
    end
    else begin
        if (bellek_istek_bosta && io_vyd_mem_istek_gecerli_w) begin
            bellek_istek_bosta <= 1'b0;
            bellek_oku_istek <= !io_vyd_mem_istek_yaz_w;
        end
        if (iomem_ready) begin
            bellek_istek_bosta <= 1'b1;
        end
    end
end

always @* begin
    bellek_veri_gecerli = bellek_oku_istek && iomem_ready;
end

// Veri Yolu Denetleyicisi < Sistem Veri Yolu
assign io_vyd_mem_istek_hazir_w = iomem_ready;

assign io_vyd_mem_veri_w = iomem_rdata;
assign io_vyd_mem_veri_gecerli_w = bellek_veri_gecerli;

// ---- Cekirdek ----
assign spi_cs_o = 0;
assign spi_sck_o = 0;
assign spi_mosi_o = 0;
assign uart_tx_o = 0;
assign pwm0_o = 0;
assign pwm1_o = 0;

endmodule