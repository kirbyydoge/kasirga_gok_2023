`timescale 1ns/1ps

`include "sabitler.vh"
`include "mikroislem.vh"

module veri_yolu_birimi(
    input                                           clk_i,
    input                                           rstn_i,

    //l1 denetleyici ile iletişim 
    
    output  [`ADRES_BIT-1:0]                        port_istek_adres_o,
    output                                          port_istek_gecerli_o,
    output                                          port_istek_onbellekleme_o,

    // Yaz
    output                                          port_istek_yaz_o,
    output  [`VERI_BIT-1:0]                         port_istek_veri_o,
    output  [`VERI_BYTE-1:0]                        port_istek_maske_o,
    input                                           port_istek_hazir_i,

    // Oku
    input   [`VERI_BIT-1:0]                         port_veri_i,
    input                                           port_veri_gecerli_i,
    output                                          port_veri_hazir_o,

    // Gelen buyruğa göre Okuma-yazma yapar
    input                                           bib_istek_gecerli_i,
    input                                           bib_istek_yaz_i,
    input  [`VERI_BIT-1:0]                          bib_veri_i,  // yazılacak veri
    input                                           bib_istek_oku_i,
    input   [`VERI_BIT-1:0]                         bib_istek_adres_i,
    input   [`VERI_BYTE-1:0]                        bib_istek_maske_i,
    
    output                                          bellek_hazir_o,
    output  [`VERI_BIT-1:0]                         bellek_veri_o,
    output                                          bellek_gecerli_o // hazır sinyali
    
);

reg  [`ADRES_BIT-1:0]   port_istek_adres_r;
reg  [`ADRES_BIT-1:0]   port_istek_adres_ns;

reg                     port_istek_gecerli_r;
reg                     port_istek_gecerli_ns;

reg                     port_istek_onbellekleme_r;
reg                     port_istek_onbellekleme_ns;

// Okuma
reg                     port_veri_hazir_r;
reg                     port_veri_hazir_ns;
// Yazma
reg                     port_istek_yaz_r;
reg                     port_istek_yaz_ns;

reg [`VERI_BIT-1:0]     port_istek_veri_r,
reg [`VERI_BIT-1:0]     port_istek_veri_ns,

reg [`VERI_BYTE-1:0]    port_istek_maske_r;
reg [`VERI_BYTE-1:0]    port_istek_maske_ns;

reg                     bellek_gecerli_cmb;
reg [`VERI_BIT-1:0]     bellek_veri_cmb;

localparam              HAZIR = 'd0;
localparam              ISTEK = 'd1;
localparam              BEKLE = 'd2;

reg                     bib_oku_istek_r;
reg                     bib_oku_istek_ns;

reg [1:0]               vyb_durum_r;
reg [1:0]               vyb_durum_ns;


always @* begin
    vyb_durum_ns = vyb_durum_r;
    port_istek_adres_ns = port_istek_adres_r;
    port_istek_gecerli_ns = port_istek_gecerli_r;
    port_veri_hazir_ns = port_veri_hazir_r;
    port_istek_yaz_ns = port_istek_yaz_r;
    port_istek_veri_ns = port_istek_veri_r;
    bib_oku_istek_ns = bib_oku_istek_r;
    port_istek_maske_ns = port_istek_maske_r;
    port_istek_onbellekleme_ns = port_istek_onbellekleme_r;
    bellek_gecerli_cmb = `LOW;
    bellek_veri_cmb = {`VERI_BIT{1'b0}};

    case(vyb_durum_r)
    HAZIR: begin
        if (bib_istek_gecerli_i) begin
            port_istek_onbellekleme_ns = (bib_istek_adres_i & ~`RAM_MASK_ADDR) != `RAM_BASE_ADDR;
            if (bib_istek_yaz_i) begin
                port_istek_adres_ns = bib_istek_adres_i;
                port_istek_maske_ns = bib_istek_maske_i;
                port_istek_gecerli_ns = `HIGH;
                port_istek_yaz_ns = `HIGH;
                port_istek_veri_ns = bib_veri_i;
                bib_oku_istek_ns = `LOW;
            end
            if (bib_istek_oku_i) begin
                port_istek_adres_ns = bib_istek_adres_i; 
                port_istek_gecerli_ns = `HIGH;
                bib_oku_istek_ns = `HIGH;
                port_istek_yaz_ns = `LOW;
            end
            vyb_durum_ns = ISTEK;
        end
    end
    ISTEK: begin
        port_istek_gecerli_ns = `HIGH;
        if (port_istek_gecerli_o && port_istek_hazir_i) begin
            port_istek_onbellekleme_ns = `LOW;
            port_istek_gecerli_ns = `LOW;
            port_istek_yaz_ns = `LOW;
            vyb_durum_ns = bib_oku_istek_r ? BEKLE : HAZIR;
            bellek_gecerli_cmb = !bib_oku_istek_r;
            port_veri_hazir_ns = bib_oku_istek_r;
        end
    end
    BEKLE: begin
        port_veri_hazir_ns = `HIGH;
        if (port_veri_gecerli_i && port_veri_hazir_o) begin
            port_veri_hazir_ns = `LOW;
            bellek_veri_cmb = port_veri_i;
            bellek_gecerli_cmb = `HIGH;
            vyb_durum_ns = HAZIR;
        end
    end
    endcase
    
end

always @(posedge clk_i) begin
    if (!rstn_i) begin
        vyb_durum_r <= HAZIR;
        port_istek_adres_r <= {`ADRES_BIT{1'b0}};    
        port_istek_gecerli_r <= 1'b0;               
        port_istek_onbellekleme_r <= `LOW;
        port_veri_hazir_r <= 1'b0;                   
        port_istek_yaz_r <= 1'b0;                 
        port_istek_veri_r <= {`VERI_BIT{1'b0}};    
        bib_oku_istek_r <= `LOW;
        port_istek_maske_r <= {`VERI_BYTE{1'b0}};
    end
    else begin
        vyb_durum_r <= vyb_durum_ns;
        bib_oku_istek_r <= bib_oku_istek_ns;
        port_istek_adres_r <= port_istek_adres_ns;
        port_istek_gecerli_r <= port_istek_gecerli_ns;
        port_istek_onbellekleme_r <= port_istek_onbellekleme_ns;
        port_veri_hazir_r <= port_veri_hazir_ns;
        port_istek_yaz_r <= port_istek_yaz_ns;
        port_istek_veri_r <= port_istek_veri_ns;
        port_istek_maske_r <= port_istek_maske_ns;
    end
end

assign port_istek_adres_o = port_istek_adres_r & 32'hFFFF_FFFC;
assign port_istek_gecerli_o = port_istek_gecerli_r;
assign port_istek_onbellekleme_o = port_istek_onbellekleme_r;
assign port_istek_maske_o = port_istek_maske_r;
assign port_veri_hazir_o = port_veri_hazir_r;
assign bellek_gecerli_o = bellek_gecerli_cmb;
assign bellek_veri_o = bellek_veri_cmb;
assign port_istek_yaz_o = port_istek_yaz_r;
assign port_istek_veri_o = port_istek_veri_r;
assign bellek_hazir_o = vyb_durum_r == HAZIR;

endmodule