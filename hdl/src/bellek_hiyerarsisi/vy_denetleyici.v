`timescale 1ns / 1ps

`include "sabitler.vh"

module vy_denetleyici (
    input                           clk_i,
    input                           rstn_i,

    // ab denetleyici istek <-> bellek
    output  [`ADRES_BIT-1:0]        mem_istek_adres_o,
    output  [`VERI_BIT-1:0]         mem_istek_veri_o,
    output                          mem_istek_yaz_o,
    output                          mem_istek_gecerli_o,
    input                           mem_istek_hazir_i,

    // bellek yanit <-> ab denetleyici
    input   [`VERI_BIT-1:0]         mem_veri_i,
    input                           mem_veri_gecerli_i,
    output                          mem_veri_hazir_o,

    // l1 denetleyici istek <-> ab denetleyici 
    input   [`ADRES_BIT-1:0]        l1_istek_adres_i,
    input                           l1_istek_gecerli_i,
    input   [`L1_BLOK_BIT-1:0]      l1_istek_veri_i,
    input                           l1_istek_yaz_i,
    output                          l1_istek_hazir_o,

    // ab denetleyici yanit <-> l1 denetleyici
    output  [`L1_BLOK_BIT-1:0]      l1_veri_o,
    output                          l1_veri_gecerli_o,
    input                           l1_veri_hazir_i
);

localparam vy_DURUM_BIT = 3;

localparam vy_BOSTA             = 'd0;
localparam vy_BLOK_OKU_ISTEK    = 'd1;
localparam vy_BLOK_OKU_BEKLE    = 'd2;
localparam vy_BLOK_OKU_YANIT    = 'd3;
localparam vy_BLOK_YAZ          = 'd4;

reg  [`ADRES_BIT-1:0]   mem_istek_adres_r;
reg  [`ADRES_BIT-1:0]   mem_istek_adres_ns;
assign mem_istek_adres_o = mem_istek_adres_r;

reg  [`VERI_BIT-1:0]    mem_istek_veri_r;
reg  [`VERI_BIT-1:0]    mem_istek_veri_ns;
assign mem_istek_veri_o = mem_istek_veri_r;

reg                     mem_istek_yaz_r;
reg                     mem_istek_yaz_ns;
assign mem_istek_yaz_o = mem_istek_yaz_r;

reg                     mem_istek_gecerli_r;
reg                     mem_istek_gecerli_ns;
assign mem_istek_gecerli_o = mem_istek_gecerli_r;

reg                     mem_veri_hazir_r;
reg                     mem_veri_hazir_ns;
assign mem_veri_hazir_o = mem_veri_hazir_r;

reg [vy_DURUM_BIT-1:0]  vy_durum_r;
reg [vy_DURUM_BIT-1:0]  vy_durum_ns;

reg                     l1_istek_hazir_r;
reg                     l1_istek_hazir_ns;
assign l1_istek_hazir_o = l1_istek_hazir_r;

reg [`L1_BLOK_BIT-1:0]  l1_veri_r;
reg [`L1_BLOK_BIT-1:0]  l1_veri_ns;
assign l1_veri_o = l1_veri_r;

reg                     l1_veri_gecerli_r;
reg                     l1_veri_gecerli_ns;
assign l1_veri_gecerli_o = l1_veri_gecerli_r;

localparam BLOK_VERI_SAYISI = `L1_BLOK_BIT / `VERI_BIT;

reg [`L1_BLOK_BIT-1:0]  vy_buffer_blok_r;
reg [`L1_BLOK_BIT-1:0]  vy_buffer_blok_ns;

reg [$clog2(BLOK_VERI_SAYISI)-1:0] vy_buffer_indis_r;
reg [$clog2(BLOK_VERI_SAYISI)-1:0] vy_buffer_indis_ns;

reg [$clog2(BLOK_VERI_SAYISI)-1:0] vy_istek_indis_r;
reg [$clog2(BLOK_VERI_SAYISI)-1:0] vy_istek_indis_ns;

always @* begin
    vy_durum_ns = vy_durum_r;
    l1_istek_hazir_ns = vy_durum_ns == vy_BOSTA;
    l1_veri_ns = l1_veri_r;
    l1_veri_gecerli_ns = l1_veri_gecerli_r;
    vy_buffer_blok_ns = vy_buffer_blok_r;
    vy_buffer_indis_ns = vy_buffer_indis_r; 
    vy_istek_indis_ns = vy_istek_indis_r; 
    mem_istek_adres_ns = mem_istek_adres_r;
    mem_istek_veri_ns = mem_istek_veri_r;
    mem_istek_yaz_ns = mem_istek_yaz_r;
    mem_istek_gecerli_ns = mem_istek_gecerli_r;
    mem_veri_hazir_ns = mem_veri_hazir_r;
 
    case (vy_durum_r)
    vy_BOSTA: begin
        l1_istek_hazir_ns = `HIGH;
        vy_buffer_indis_ns = 0;
        vy_istek_indis_ns = 0;
        if (l1_istek_hazir_o && l1_istek_gecerli_i) begin
            l1_istek_hazir_ns = `LOW;
            mem_istek_adres_ns = l1_istek_adres_i;
            if (l1_istek_yaz_i) begin
                vy_buffer_blok_ns = l1_istek_veri_i;
                vy_durum_ns = vy_BLOK_YAZ;
            end
            else begin
                vy_durum_ns = vy_BLOK_OKU_ISTEK;
            end
        end
    end
    vy_BLOK_OKU_ISTEK: begin
    // Bu durum icerisinde istek yapma ve veri kabul etme asenkron calisiyor.
    // O nedenle tum isteklerimizi bitirdigimizde vy_BLOK_BEKLE durumuna gidilmeli.
        mem_istek_adres_ns = mem_istek_adres_r;
        mem_istek_veri_ns = vy_buffer_blok_r[vy_istek_indis_r];
        mem_istek_gecerli_ns = `HIGH;
        mem_istek_yaz_ns = `LOW;
        if (mem_istek_hazir_i && mem_istek_gecerli_o) begin
            mem_istek_adres_ns = mem_istek_adres_r + `VERI_BYTE;
            vy_istek_indis_ns = vy_istek_indis_r + 1;
            if (vy_istek_indis_r == BLOK_VERI_SAYISI - 1) begin
                mem_istek_gecerli_ns = `LOW;
                vy_durum_ns = vy_BLOK_OKU_BEKLE;
            end
        end

        mem_veri_hazir_ns = `HIGH;
        if (mem_veri_hazir_o && mem_veri_gecerli_i) begin
            vy_buffer_blok_ns[vy_buffer_indis_r * `VERI_BIT +: `VERI_BIT] = mem_veri_i;
            vy_buffer_indis_ns = vy_buffer_indis_r  + 1;
            // vy_buffer_indis_r == BLOK_VERI_SAYISI - 1 kontrolune gerek 
            // yok bu istegi en hizli durumda bu cevrim yapabiliriz
        end
    end
    vy_BLOK_OKU_BEKLE: begin
        // Istek yaptigimiz veriye karsi hazir olmamak gibi bir luksumuz yok.
        // Gelecekte farkli bellek tipleriyle uyumlu olmasi icin bu sinyallerle yazdim.
        mem_veri_hazir_ns = `HIGH;
        if (mem_veri_hazir_o && mem_veri_gecerli_i) begin
            vy_buffer_blok_ns[vy_buffer_indis_r * `VERI_BIT +: `VERI_BIT] = mem_veri_i;
            vy_buffer_indis_ns = vy_buffer_indis_r  + 1;
            if (vy_buffer_indis_r == BLOK_VERI_SAYISI - 1) begin
                mem_veri_hazir_ns = `LOW;
                l1_veri_ns = vy_buffer_blok_ns;
                l1_veri_gecerli_ns = `HIGH;
                vy_durum_ns = vy_BLOK_OKU_YANIT;
            end
        end
    end
    vy_BLOK_OKU_YANIT: begin
        l1_veri_ns = vy_buffer_blok_r;
        l1_veri_gecerli_ns = `HIGH;
        if (l1_veri_hazir_i && l1_veri_gecerli_o) begin
            l1_veri_gecerli_ns = `LOW;
            vy_durum_ns = vy_BOSTA;
        end
    end
    vy_BLOK_YAZ: begin
        mem_istek_adres_ns = mem_istek_adres_r;
        mem_istek_veri_ns = vy_buffer_blok_r[vy_istek_indis_r * `VERI_BIT +: `VERI_BIT];
        mem_istek_gecerli_ns = `HIGH;
        mem_istek_yaz_ns = `HIGH;
        if (mem_istek_hazir_i && mem_istek_gecerli_o) begin
            mem_istek_adres_ns = mem_istek_adres_r + `VERI_BYTE;
            mem_istek_veri_ns = vy_buffer_blok_r[(vy_istek_indis_r + 1) * `VERI_BIT +: `VERI_BIT];
            vy_istek_indis_ns = vy_istek_indis_r + 1;
            if (vy_istek_indis_r == BLOK_VERI_SAYISI - 1) begin
                mem_istek_gecerli_ns = `LOW;
                mem_istek_yaz_ns = `LOW;
                vy_durum_ns = vy_BOSTA;
            end
        end
    end
    endcase
end

always @(posedge clk_i) begin
    if (!rstn_i) begin
        vy_durum_r <= vy_BOSTA;
        l1_istek_hazir_r <= 0;
        l1_veri_r <= 0;
        l1_veri_gecerli_r <= 0;
        vy_buffer_blok_r <= 0;
        vy_buffer_indis_r <= 0;
        vy_istek_indis_r <= 0;
        mem_istek_adres_r <= 0;
        mem_istek_veri_r <= 0;
        mem_istek_yaz_r <= 0;
        mem_istek_gecerli_r <= 0;
        mem_veri_hazir_r <= 0;
    end
    else begin
        vy_durum_r <= vy_durum_ns;
        l1_istek_hazir_r <= l1_istek_hazir_ns;
        l1_veri_r <= l1_veri_ns;
        l1_veri_gecerli_r <= l1_veri_gecerli_ns;
        vy_buffer_blok_r <= vy_buffer_blok_ns;
        vy_buffer_indis_r <= vy_buffer_indis_ns;
        vy_istek_indis_r <= vy_istek_indis_ns;
        mem_istek_adres_r <= mem_istek_adres_ns;
        mem_istek_veri_r <= mem_istek_veri_ns;
        mem_istek_yaz_r <= mem_istek_yaz_ns;
        mem_istek_gecerli_r <= mem_istek_gecerli_ns;
        mem_veri_hazir_r <= mem_veri_hazir_ns;
    end
end

endmodule