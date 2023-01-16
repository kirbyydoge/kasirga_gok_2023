`timescale 1ns/1ps

`include "sabitler.vh"
`include "mikroislem.vh"

module veri_yolu_birimi(
    input                      clk_i,
    input                      rstn_i,

    //veri yolu birimi + l1 denetleyici 
    //Okuma girdileri
    input   [`VERI_BIT-1:0]     l1v_veri_i,
    input                       l1v_veri_gecerli_i,
    output                      l1v_veri_hazir_o,
    //Yazma
    input                       l1v_istek_hazir_i,
    output  [`PS_BIT-1:0]       l1v_istek_adres_o,
    output                      l1v_istek_gecerli_o,

    // Gelen buyruğa göre Okuma-yazma yapar
    input   [`UOP_BEL_BIT-1:0]  uop_buyruk_secim_i,
    input   [`UOP_RS2_BIT-1:0]  uop_rs2_i,
    input   [`VERI_BIT-1:0]     maske_o,
    input   [`ADRES_BIT-1:0]    erisilecek_adres_o,

    output  [`VERI_BIT-1:0]     okunan_veri_o
    
);

always @* begin
    case(uop_buyruk_secim_i)
        `UOP_BEL_NOP: begin
            
        end
        // Load Buyrukları
        `UOP_BEL_LW: begin // 32 Bit Okur
           
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





endmodule