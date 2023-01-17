`timescale 1ns/1ps

`include "sabitler.vh"
`include "mikroislem.vh"

module bellek_islem_birimi(
    input                        clk_i,
    input                        rstn_i,
    // Buyruk türüne göre maske oluşturur, Okuma mı yazma mı yapılacağını söyler
    input   [`UOP_BEL_BIT-1:0]   uop_buyruk_secim_i,
    input   [`UOP_RD_BIT-1:0]    uop_rd_i, // adres burada gömülü geliyor

    output  [`VERI_BYTE-1:0]                maske_o,
    output                       oku_o,
    output                       yaz_o
);

reg [`VERI_BYTE-1:0] maske_cmb;
reg       oku_cmb;
reg       yaz_cmb;

localparam nop_islem    0;
localparam btye_islem   1;
localparam hw_islem     2;
localparam w_islem      3;

function [`VERI_BYTE-1:0] maske_sec (
    input [2:0]                 boyut_w,   // nop, byte, hw ya da w olabilir
    input [`UOP_RD_BIT-1:0]     uop_rd_w
);
begin
    maske_sec = {`VERI_BIT{1'b0}};
    case(boyut_w)
        nop_islem: maske_sec = 
        btye_islem: begin
            case(uop_rd_w[1:0])
                2'b00: maske_sec = BYTE_MAKSE_0;
                2'b01: maske_sec = BYTE_MAKSE_1;
                2'b10: maske_sec = BYTE_MAKSE_2;
                2'b11: maske_sec = BYTE_MAKSE_3;              
            endcase   
        end 
        hw_islem: begin
            case(uop_rd_w[1:0])
                2'b00: maske_sec = HALF_WORD_MASKE_0;
                2'b01: maske_sec = HALF_WORD_MASKE_1;
                2'b10: maske_sec = HALF_WORD_MASKE_2;
                // Diğer durumlar odd atar mı tartışılacak
            endcase    
        end
        w_islem: begin
            maske_sec = WORD_MASKE;
            // Byte seçimi 00 değilse odd atar mı tartışılacak
        end
    endcase
end
endfunction


always @* begin
    // 16 VE 8 BİT lOAD YAPARKEN REGISTERIN EN ANLAMLI BYTELARINA YAZILMIŞTIR, BELLEĞE STORE YAPARKEN VERİ ÖBEĞİNİN EN ANLAMLI BYTLEARINA YAZILDI 
    case(uop_buyruk_secim_i)
        `UOP_BEL_NOP: begin
            maske_cmb = maske_sec(nop_islem, uop_rd_i); 
            oku_cmb = 0;
            yaz_cmb = 0;  
        end
        // Load Buyrukları
        `UOP_BEL_LW: begin // 32 Bit Okur
            maske_cmb = maske_sec(w_islem, uop_rd_i); 
            oku_cmb = 1;
            yaz_cmb = 0;         
        end
        `UOP_BEL_LH: begin // 16 Bit Okur, sign-extend edip rd'ye yazar
            maske_cmb = maske_sec(hw_islem, uop_rd_i); 
            oku_cmb = 1;
            yaz_cmb = 0; 
        end
        `UOP_BEL_LHU: begin // 16 Bit Okur, zero-extend edip rd'ye yazar
            maske_cmb = maske_sec(hw_islem, uop_rd_i); 
            oku_cmb = 1;
            yaz_cmb = 0;          
        end
        `UOP_BEL_LB: begin // 8 Bit Okur, sign-extend edip rd'ye yazar
            maske_cmb = maske_sec(byte_islem, uop_rd_i); 
            oku_cmb = 1;
            yaz_cmb = 0;           
        end
        `UOP_BEL_LBU: begin // 8 Bit Okur, zero-extend edip rd'ye yazar
            maske_cmb = maske_sec(byte_islem, uop_rd_i); 
            oku_cmb = 1;
            yaz_cmb = 0;       
        end
        // Store Buyrukları
        `UOP_BEL_SW: begin // 32 Bit Store'lar
            maske_cmb = maske_sec(w_islem, uop_rd_i); 
            oku_cmb = 0;
            yaz_cmb = 1;     
        end
        `UOP_BEL_SH: begin // 16 Bit Store'lar
            maske_cmb = maske_sec(hw_islem, uop_rd_i);
            oku_cmb = 0;
            yaz_cmb = 1;          
        end
        `UOP_BEL_SB: begin // 8 Bit Store'lar
            maske_cmb = maske_sec(byte_islem, uop_rd_i);
            oku_cmb = 0;
            yaz_cmb = 1;          
        end
    endcase
end

assign maske_o = maske_cmb;
assign oku_o   = oku_cmb;
assign yaz_o   = yaz_cmb;



endmodule