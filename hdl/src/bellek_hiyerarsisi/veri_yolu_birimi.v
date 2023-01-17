`timescale 1ns/1ps

`include "sabitler.vh"
`include "mikroislem.vh"

module veri_yolu_birimi(
    input                                           clk_i,
    input                                           rstn_i,

    //l1 denetleyici ile iletişim 
    
    output  [`ADRES_BIT-1:0]                        port_istek_adres_o,
    output                                          port_istek_gecerli_o,
    // Yaz
    output                                          port_istek_yaz_o,
    output  [`VERI_BIT-1:0]                         port_istek_veri_o,
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
            
    output  [`VERI_BIT-1:0]                         bellek_veri_o,
    output                                          bellek_gecerli_o // hazır sinyali
    
);

reg  [`ADRES_BIT-1:0]   port_istek_adres_r;
reg  [`ADRES_BIT-1:0]   port_istek_adres_ns;

reg                     port_istek_gecerli_r;
reg                     port_istek_gecerli_ns;

// Okuma
reg                     port_veri_hazir_r;
reg                     port_veri_hazir_ns;
// Yazma
reg                     port_istek_yaz_r;
reg                     port_istek_yaz_ns;

reg [`VERI_BIT-1:0]     port_istek_veri_r,
reg [`VERI_BIT-1:0]     port_istek_veri_ns,

//
reg                     bellek_gecerli_r;
reg                     bellek_gecerli_ns;
reg [`VERI_BIT-1:0]     bellek_veri_r,
reg [`VERI_BIT-1:0]     bellek_veri_ns,


always @* begin
    port_istek_adres_ns = port_istek_adres_r;
    port_istek_gecerli_ns = port_istek_gecerli_r;
    port_veri_hazir_ns = port_veri_hazir_r;
    bellek_gecerli_ns = bellek_gecerli_r;
    bellek_veri_ns = bellek_veri_r;
    port_istek_yaz_ns = port_istek_yaz_r;
    port_istek_veri_ns = port_istek_veri_r;

        if (bib_istek_gecerli_i) begin

            if (!bib_istek_yaz_i & !bib_istek_oku_i )

            if (bib_istek_yaz_i) begin
                port_istek_adres_ns = bib_istek_adres_i;  
                port_istek_gecerli_ns = `HIGH;
                if (port_istek_hazir_i) begin  // biz hazırız l1v de hazırsa başla
                    port_istek_yaz_ns = `HIGH;
                    port_istek_veri_ns = bib_veri_i;  // YAZMAK İÇİN GÖNDERDİM BİTTİĞİNİ NASIL ANLICAM ??? GEREK VAR MI ANLAMAMA
                    bellek_gecerli_ns = `HIGH; // Bitti 
                end
            end

            if (bib_istek_oku_i) begin
                port_istek_adres_ns = bib_istek_adres_i; 
                port_istek_gecerli_ns = `HIGH;
                if (port_veri_gecerli_i) begin // gelen veri geçerliyse
                    bellek_veri_ns = port_veri_i;
                    bellek_gecerli_ns = `HIGH; // Bitti   
                end  
            end  
        end
end

always @(posedge clk_i) begin
    if (!rstn_i) begin
        //reset
    end
    else begin
        port_istek_adres_r <= port_istek_adres_ns;
        port_istek_gecerli_r <= port_istek_gecerli_ns;
        port_veri_hazir_r <= port_veri_hazir_ns;
        bellek_gecerli_r <= bellek_gecerli_ns;
        bellek_veri_r <= bellek_veri_ns;
        port_istek_yaz_r <= port_istek_yaz_ns;
        port_istek_veri_r <= port_istek_veri_ns;
    end
end

assign port_istek_adres_o = port_istek_adres_r;
assign port_istek_gecerli_o = port_istek_gecerli_r;
assign port_veri_hazir_o = port_veri_hazir_r;
assign bellek_gecerli_o = bellek_gecerli_r;
assign bellek_veri_o = bellek_veri_r;
assign port_istek_yaz_o = port_istek_yaz_r;
assign port_istek_veri_o = port_istek_veri_r;


endmodule