`timescale 1ns/1ps

`include "sabitler.vh"
`include "mikroislem.vh"

module veri_yolu_birimi(
    input                                            clk_i,
    input                                            rstn_i,

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
    input   [`VERI_BIT-1:0]                         bib_istek_adres_i,
    input   [`VERI_BYTE-1:0]                        bib_istek_maske_i,
            
    output  [`VERI_BIT-1:0]                         bellek_veri_o,
    output                                          bellek_gecerli_o
    
);

reg [`VERI_BIT-1:0]     okunan_veri_r;
reg [`VERI_BIT-1:0]     okunan_veri_ns;

reg                     hazir_r;
reg                     hazir_ns;

// l1 için adres
reg [`ADRES_BIT-1:0]    port_istek_adres_r;
reg [`ADRES_BIT-1:0]    port_istek_adres_ns;

reg                     port_istek_gecerli_r;
reg                     port_istek_gecerli_ns;

// Yazma
reg                     port_istek_yaz_r;
reg                     port_istek_yaz_ns;

reg [`VERI_BIT-1:0]     port_istek_veri_r;
reg [`VERI_BIT-1:0]     port_istek_veri_ns;

// Okuma
reg                     port_veri_hazir_r;
reg                     port_veri_hazir_ns;


always @* begin
    okunan_veri_ns = okunan_veri_r;
    hazir_ns = hazir_r;
    port_istek_adres_ns = port_istek_adres_r;
    port_istek_gecerli_ns = port_istek_gecerli_r;
    port_istek_yaz_ns = port_istek_yaz_r;
    port_istek_veri_ns = port_istek_veri_r;
    port_veri_hazir_ns = port_veri_hazir_r;

    case(uop_buyruk_secim_i)
        `UOP_BEL_NOP: begin
            okunan_veri_ns = {`VERI_BIT{1'b0}};
            hazir_ns = `HIGH;   
        end
        // Load Buyrukları
        `UOP_BEL_LW: begin // 32 Bit Okur
            port_istek_adres_ns = erisilecek_adres_i; 
            port_istek_gecerli_ns = `HIGH;   
            if (port_veri_gecerli_i) begin
                okunan_veri_ns = port_veri_i & maske_i; 
                hazir_ns = `HIGH;   
            end 
        end
        `UOP_BEL_LH: begin // 16 Bit Okur, sign-extend edip rd'ye yazar
            
        end
        `UOP_BEL_LHU: begin // 16 Bit Okur, zero-extend edip rd'ye yazar
            
        end
        `UOP_BEL_LB: begin // 8 Bit Okur, sign-extend edip rd'ye yazar
                
        end
        `UOP_BEL_LBU: begin // 16 Bit Okur, zero-extend edip rd'ye yazar
            
        end
        // Store Buyrukları
        `UOP_BEL_SW: begin // 32 Bit Store'lar
           
        end
        `UOP_BEL_SH: begin // 16 Bit Store'lar
            
        end
        `UOP_BEL_SB: begin // 8 Bit Store'lar
            
        end

    endcase
end

always @ (posedge clk_i) begin

end


assign okunan_veri_o = okunan_veri_r;
assign hazir_o = hazir_r;
assign port_istek_adres_o = port_istek_adres_r;
assign port_istek_gecerli_o = port_istek_gecerli_r;
assign port_istek_yaz_o = port_istek_yaz_r;
assign port_istek_veri_o = port_istek_veri_r;
assign port_veri_hazir_o = port_veri_hazir_r;


endmodule