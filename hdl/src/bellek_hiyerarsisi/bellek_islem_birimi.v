`timescale 1ns/1ps

`include "sabitler.vh"
`include "mikroislem.vh"

module bellek_islem_birimi(
    input                        clk_i,
    input                        rstn_i,
    // Buyruk türüne göre maske oluşturur, Okuma mı yazma mı yapılacağını söyler
    input   [`UOP_BEL_BIT-1:0]   uop_buyruk_secim_i,
    input   [`UOP_RD_BIT-1:0]    uop_rd_i,
    input   [`VERI_BIT-1:0]      uop_rs2_i,

    output  [`VERI_BIT-1:0]      veri_o,
    output  [`VERI_BYTE-1:0]     maske_o,
    output                       oku_o,
    output                       yaz_o
);

reg [`VERI_BIT-1:0]  veri_cmb;
reg [`VERI_BYTE-1:0] maske_cmb;
reg       oku_cmb;
reg       yaz_cmb;

localparam OP_NOP  = 0;
localparam OP_BYTE = 1;
localparam OP_HALF = 2;
localparam OP_WORD = 3;

function [`VERI_BYTE-1:0] maske_sec (
    input [2:0]                 boyut_w,   
    input [`UOP_RD_BIT-1:0]     uop_rd_w
);
begin
    maske_sec = {`VERI_BYTE{1'b0}};
    case(boyut_w)
        OP_NOP   : maske_sec = 0;
        OP_BYTE  : maske_sec = 8'b0001 << uop_rd_w[1:0];
        OP_HALF  : maske_sec = 8'b0011 << uop_rd_w[1:0];
        OP_WORD  : maske_sec = 8'b1111;
    endcase
end
endfunction

function [`VERI_BIT-1:0] veri_kaydir (
    input [`UOP_RD_BIT-1:0]     uop_rd_w,
    input [`VERI_BIT-1:0]       uop_rs2_w
);
begin
    veri_kaydir = uop_rs2_w << (uop_rd_w[1:0] * 8);
end
endfunction

always @* begin
    // 16 VE 8 BİT lOAD YAPARKEN REGISTERIN EN ANLAMLI BYTELARINA YAZILMIŞTIR, BELLEĞE STORE YAPARKEN VERİ ÖBEĞİNİN EN ANLAMLI BYTLEARINA YAZILDI 
    case(uop_buyruk_secim_i)
        // Load Buyrukları
        `UOP_BEL_LW: begin // 32 Bit Okur
            maske_cmb = maske_sec(OP_WORD, uop_rd_i); 
            oku_cmb = 1;
            yaz_cmb = 0;         
        end
        `UOP_BEL_LH: begin // 16 Bit Okur, sign-extend edip rd'ye yazar
            maske_cmb = maske_sec(OP_HALF, uop_rd_i); 
            oku_cmb = 1;
            yaz_cmb = 0; 
        end
        `UOP_BEL_LHU: begin // 16 Bit Okur, zero-extend edip rd'ye yazar
            maske_cmb = maske_sec(OP_HALF, uop_rd_i); 
            oku_cmb = 1;
            yaz_cmb = 0;          
        end
        `UOP_BEL_LB: begin // 8 Bit Okur, sign-extend edip rd'ye yazar
            maske_cmb = maske_sec(OP_BYTE, uop_rd_i); 
            oku_cmb = 1;
            yaz_cmb = 0;           
        end
        `UOP_BEL_LBU: begin // 8 Bit Okur, zero-extend edip rd'ye yazar
            maske_cmb = maske_sec(OP_BYTE, uop_rd_i); 
            oku_cmb = 1;
            yaz_cmb = 0;       
        end
        // Store Buyrukları
        `UOP_BEL_SW: begin // 32 Bit Store'lar
            maske_cmb = maske_sec(OP_WORD, uop_rd_i); 
            veri_cmb = uop_rs2_i; // 
            oku_cmb = 0;
            yaz_cmb = 1;     
        end
        `UOP_BEL_SH: begin // 16 Bit Store'lar
            maske_cmb = maske_sec(OP_HALF, uop_rd_i);
            veri_cmb = veri_kaydir(uop_rd_i, uop_rs2_i); 
            oku_cmb = 0;
            yaz_cmb = 1;          
        end
        `UOP_BEL_SB: begin // 8 Bit Store'lar
            maske_cmb = maske_sec(OP_BYTE, uop_rd_i);
            veri_cmb = veri_kaydir(uop_rd_i, uop_rs2_i); 
            oku_cmb = 0;
            yaz_cmb = 1;          
        end
        default: begin
            maske_cmb = maske_sec(OP_NOP, uop_rd_i);
            veri_cmb = 0;
            oku_cmb = 0;
            yaz_cmb = 0;  
        end
    endcase
end

assign veri_o = veri_cmb;
assign maske_o = maske_cmb;
assign oku_o   = oku_cmb;
assign yaz_o   = yaz_cmb;



endmodule