`timescale 1ns/1ps

`include "sabitler.vh"
`include "mikroislem.vh"

module bellek_islem_birimi(
    input                        clk_i,
    input                        rstn_i,
    // Buyruk türüne göre maske oluşturur ve erişilecek adresi hesaplar
    input   [`UOP_BEL_BIT-1:0]   uop_buyruk_secim_i,
    input   [`UOP_RS1_BIT-1:0]   uop_rs1_i,
    input   [`UOP_RS2_BIT-1:0]   uop_rs2_i,
    input   [`UOP_IMM_BIT-1:0]   uop_imm_i,

    output  [`VERI_BIT-1:0]      maske_o,
    output  [`ADRES_BIT-1:0]     erisilecek_adres_o 

);

reg [`VERI_BIT-1:0] maske_cmb;
reg [`ADRES_BIT-1:0] erisilecek_adres_cmb;

always @* begin
    // 16 VE 8 BİT lOAD YAPARKEN REGISTERIN EN ANLAMLI BYTELARINA YAZILMIŞTIR, BELLEĞE STORE YAPARKEN VERİ ÖBEĞİNİN EN ANLAMLI BYTLEARINA YAZILDI 
    case(uop_buyruk_secim_i)
        `UOP_BEL_NOP: begin
            maske_cmb = `NOP_MASKE;
            erisilecek_adres_cmb = {`VERI_BIT{1'b0}};
        end
        // Load Buyrukları
        `UOP_BEL_LW: begin // 32 Bit Okur
            maske_cmb = `WORD_MASKE;
            erisilecek_adres_cmb = $signed(uop_imm_i) + uop_rs1_i;
        end
        `UOP_BEL_LH: begin // 16 Bit Okur, sign-extend edip rd'ye yazar
            maske_cmb = `EN_ANLAMLI_HALF_WORD_MASKE;
            erisilecek_adres_cmb = $signed(uop_imm_i) + uop_rs1_i;
        end
        `UOP_BEL_LHU: begin // 16 Bit Okur, zero-extend edip rd'ye yazar
            maske_cmb = `EN_ANLAMLI_HALF_WORD_MASKE;
            erisilecek_adres_cmb = $signed(uop_imm_i) + uop_rs1_i;
        end
        `UOP_BEL_LB: begin // 8 Bit Okur, sign-extend edip rd'ye yazar
            maske_cmb = `EN_ANLAMLI_BYTE_MASKE;
            erisilecek_adres_cmb = $signed(uop_imm_i) + uop_rs1_i;    
        end
        `UOP_BEL_LBU: begin // 16 Bit Okur, zero-extend edip rd'ye yazar
            maske_cmb = `EN_ANLAMLI_BYTE_MASKE;
            erisilecek_adres_cmb = $signed(uop_imm_i) + uop_rs1_i;
        end
        // Store Buyrukları
        `UOP_BEL_SW: begin // 32 Bit Store'lar
            maske_cmb = `WORD_MASKE;
            erisilecek_adres_cmb = $signed(uop_imm_i) + uop_rs1_i;
        end
        `UOP_BEL_SH: begin // 16 Bit Store'lar
            maske_cmb = `EN_ANLAMLI_HALF_WORD_MASKE;
            erisilecek_adres_cmb = $signed(uop_imm_i) + uop_rs1_i;
        end
        `UOP_BEL_SB: begin // 8 Bit Store'lar
            maske_cmb = `EN_ANLAMLI_BYTE_MASKE;
            erisilecek_adres_cmb = $signed(uop_imm_i) + uop_rs1_i;
        end
    endcase
end

assign maske_o = maske_cmb;
assign erisilecek_adres_o = erisilecek_adres_cmb;


endmodule