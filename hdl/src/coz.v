`timescale 1ns / 1ps

`include "sabitler.vh"
`include "mikroislem.vh"
`include "coz.vh"
`include "opcode.vh"
`include "opcode_x.vh"
`include "opcode_cnn.vh"

module coz(
    input                           clk_i,
    input                           rstn_i,

    input                           cek_bosalt_i,
    input                           cek_duraklat_i,
    output                          duraklat_o,

    output                          gecersiz_buyruk_o,
    
    input   [`PS_BIT-1:0]           getir_buyruk_i,
    input   [`PS_BIT-1:0]           getir_ps_i,
    input                           getir_gecerli_i,
    input                           getir_atladi_i,
    input                           getir_rvc_i,

    output  [`UOP_BIT-1:0]          yo_uop_o
);

wire [`N_BUYRUK-1:0] buyruk;

localparam CASE_LUI        = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `LUI;
localparam CASE_AUIPC      = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `AUIPC;
localparam CASE_JALR       = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `JALR;
localparam CASE_JAL        = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `JAL;
localparam CASE_BEQ        = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `BEQ;
localparam CASE_BNE        = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `BNE;
localparam CASE_BLT        = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `BLT;
localparam CASE_LW         = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `LW;
localparam CASE_SW         = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `SW;
localparam CASE_ADDI       = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `ADDI;
localparam CASE_ADD        = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `ADD;
localparam CASE_SUB        = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `SUB;
localparam CASE_OR         = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `OR;
localparam CASE_AND        = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `AND;
localparam CASE_XOR        = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `XOR;
localparam CASE_CSRRW      = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `CSRRW;
localparam CASE_CSRRS      = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `CSRRS;
localparam CASE_CSRRWI     = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `CSRRWI;
localparam CASE_CSRRSI     = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `CSRRSI;
localparam CASE_FENCE      = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `FENCE;
localparam CASE_ECALL      = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `ECALL;
localparam CASE_MRET       = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `MRET;
localparam CASE_SLLI       = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `SLLI;
localparam CASE_ORI        = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `ORI;
localparam CASE_BGE        = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `BGE;
localparam CASE_SLTI       = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `SLTI;
localparam CASE_SLTU       = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `SLTU;
localparam CASE_XORI       = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `XORI;
localparam CASE_ANDI       = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `ANDI;
localparam CASE_SRLI       = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `SRLI;
localparam CASE_SRAI       = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `SRAI;
localparam CASE_FENCE_I    = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `FENCE_I;
localparam CASE_CSRRC      = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `CSRRC;
localparam CASE_CSRRCI     = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `CSRRCI;
localparam CASE_EBREAK     = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `EBREAK;
localparam CASE_LB         = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `LB;
localparam CASE_LH         = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `LH;
localparam CASE_LBU        = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `LBU;
localparam CASE_LHU        = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `LHU;
localparam CASE_SB         = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `SB;
localparam CASE_SH         = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `SH;
localparam CASE_BLTU       = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `BLTU;
localparam CASE_BGEU       = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `BGEU;
localparam CASE_SLT        = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `SLT;
localparam CASE_HMDST      = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `HMDST;     
localparam CASE_PKG        = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `PKG; 
localparam CASE_RVRS       = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `RVRS;     
localparam CASE_SLADD      = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `SLADD;     
localparam CASE_CNTZ       = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `CNTZ;     
localparam CASE_CNTP       = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `CNTP;     
localparam CASE_SLTIU      = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `SLTIU;
localparam CASE_SLL        = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `SLL;
localparam CASE_SRL        = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `SRL;
localparam CASE_SRA        = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `SRA;
localparam CASE_WFI        = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `WFI;
localparam CASE_MUL        = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `MUL;
localparam CASE_MULHU      = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `MULHU;
localparam CASE_MULHSU     = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `MULHSU;
localparam CASE_MULH       = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `MULH;
localparam CASE_DIV        = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `DIV;
localparam CASE_DIVU       = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `DIVU;
localparam CASE_REM        = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `REM;
localparam CASE_REMU       = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `REMU;
localparam CASE_SFENCE_VMA = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `SFENCE_VMA;
localparam CASE_CNN_LDX    = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `CNN_LDX; 
localparam CASE_CNN_CLRX   = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `CNN_CLRX;     
localparam CASE_CNN_LDW    = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `CNN_LDW; 
localparam CASE_CNN_CLRW   = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `CNN_CLRW;     
localparam CASE_CNN_RUN    = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `CNN_RUN; 
localparam CASE_C_ADDI4SPN = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_ADDI4SPN;
localparam CASE_C_FLD      = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_FLD;     
localparam CASE_C_LW       = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_LW;      
localparam CASE_C_FLW      = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_FLW;     
localparam CASE_C_FSD      = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_FSD;     
localparam CASE_C_SW       = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_SW;      
localparam CASE_C_FSW      = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_FSW;     
localparam CASE_C_ADDI     = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_ADDI;   
localparam CASE_C_JAL      = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_JAL;     
localparam CASE_C_LI       = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_LI;      
localparam CASE_C_LUI      = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_LUI;     
localparam CASE_C_SRLI     = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_SRLI;    
localparam CASE_C_SRLI64   = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_SRLI64;  
localparam CASE_C_SRAI     = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_SRAI;    
localparam CASE_C_SRAI64   = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_SRAI64;  
localparam CASE_C_ANDI     = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_ANDI;    
localparam CASE_C_SUB      = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_SUB;     
localparam CASE_C_XOR      = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_XOR;     
localparam CASE_C_OR       = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_OR;      
localparam CASE_C_AND      = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_AND;     
localparam CASE_C_SUBW     = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_SUBW;    
localparam CASE_C_ADDW     = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_ADDW;    
localparam CASE_C_J        = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_J;       
localparam CASE_C_BEQZ     = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_BEQZ;    
localparam CASE_C_BNEZ     = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_BNEZ;    
localparam CASE_C_SLLI     = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_SLLI;    
localparam CASE_C_SLLI64   = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_SLLI64;  
localparam CASE_C_FLDSP    = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_FLDSP;   
localparam CASE_C_LWSP     = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_LWSP;    
localparam CASE_C_FLWSP    = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_FLWSP;   
localparam CASE_C_MV       = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_MV;      
localparam CASE_C_ADD      = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_ADD;     
localparam CASE_C_FSDSP    = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_FSDSP;   
localparam CASE_C_SWSP     = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_SWSP;    
localparam CASE_C_FSWSP    = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_FSWSP;   
localparam CASE_C_NOP      = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_NOP;     
localparam CASE_C_ADDI16SP = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_ADDI16SP;
localparam CASE_C_JR       = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_JR;      
localparam CASE_C_JALR     = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_JALR;    
localparam CASE_C_EBREAK   = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_EBREAK;  
localparam CASE_C_LD       = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_LD;         
localparam CASE_C_SD       = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_SD;          
localparam CASE_C_LDSP     = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_LDSP;    
localparam CASE_C_SDSP     = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_SDSP;
//localparam CASE_C_ADDIW    = {{`N_BUYRUK-1{1'b0}}, 1'b1} << `C_ADDIW;       

wire coz_aktif_w;
wire [4:0] buyruk_c_lui_rd;
wire [4:0] buyruk_c_add_rs2;
wire [4:0] buyruk_c_addi_rd;
wire [4:0] buyruk_c_mv_rs2;
wire [4:0] buyruk_c_jalr_rs1;
//wire [4:0] buyruk_c_addiw_imm;

reg [`VERI_BIT-1:0]         buyruk_imm_cmb;
reg [`VERI_BIT-1:0]         buyruk_rs1_cmb;
reg [`VERI_BIT-1:0]         buyruk_rs2_cmb;
reg [`YAZMAC_BIT-1:0]       buyruk_rd_cmb;
reg [`CSR_ADRES_BIT-1:0]    buyruk_csr_cmb;
reg                         buyruk_etiket_gecerli_cmb;
reg                         buyruk_cnn_rs1_en_cmb;
reg                         buyruk_cnn_rs2_en_cmb;

reg [`UOP_TAG_BIT-1:0]  buyruk_etiket_r;
reg [`UOP_TAG_BIT-1:0]  buyruk_etiket_ns;

reg [`UOP_BIT-1:0]      uop_r;
reg [`UOP_BIT-1:0]      uop_ns;

function match(
    input [31:0] buyruk,
    input [31:0] maske,
    input [31:0] eslik
);
begin
    match = &(~((buyruk & maske) ^ eslik));
end
endfunction
   
generate
    assign buyruk_c_lui_rd    = getir_buyruk_i[11:7];
    assign buyruk_c_add_rs2   = getir_buyruk_i[6:2];
    assign buyruk_c_addi_rd   = getir_buyruk_i[11:7];
    assign buyruk_c_mv_rs2    = getir_buyruk_i[6:2];
    assign buyruk_c_jalr_rs1  = getir_buyruk_i[11:7]; 
    //assign buyruk_c_addiw_imm = {getir_buyruk_i[12],getir_buyruk_i[6:2]};

    assign buyruk[`LUI]        = match(getir_buyruk_i, `MASK_LUI, `MATCH_LUI) && coz_aktif_w;
    assign buyruk[`AUIPC]      = match(getir_buyruk_i, `MASK_AUIPC, `MATCH_AUIPC) && coz_aktif_w;
    assign buyruk[`JALR]       = match(getir_buyruk_i, `MASK_JALR, `MATCH_JALR) && coz_aktif_w;
    assign buyruk[`JAL]        = match(getir_buyruk_i, `MASK_JAL, `MATCH_JAL) && coz_aktif_w;
    assign buyruk[`BEQ]        = match(getir_buyruk_i, `MASK_BEQ, `MATCH_BEQ) && coz_aktif_w;
    assign buyruk[`BNE]        = match(getir_buyruk_i, `MASK_BNE, `MATCH_BNE) && coz_aktif_w;
    assign buyruk[`BLT]        = match(getir_buyruk_i, `MASK_BLT, `MATCH_BLT) && coz_aktif_w;
    assign buyruk[`LW]         = match(getir_buyruk_i, `MASK_LW, `MATCH_LW) && coz_aktif_w;
    assign buyruk[`SW]         = match(getir_buyruk_i, `MASK_SW, `MATCH_SW) && coz_aktif_w;
    assign buyruk[`ADDI]       = match(getir_buyruk_i, `MASK_ADDI, `MATCH_ADDI) && coz_aktif_w;
    assign buyruk[`ADD]        = match(getir_buyruk_i, `MASK_ADD, `MATCH_ADD) && coz_aktif_w;
    assign buyruk[`SUB]        = match(getir_buyruk_i, `MASK_SUB, `MATCH_SUB) && coz_aktif_w;
    assign buyruk[`OR]         = match(getir_buyruk_i, `MASK_OR, `MATCH_OR) && coz_aktif_w;
    assign buyruk[`AND]        = match(getir_buyruk_i, `MASK_AND, `MATCH_AND) && coz_aktif_w;
    assign buyruk[`XOR]        = match(getir_buyruk_i, `MASK_XOR, `MATCH_XOR) && coz_aktif_w;
    assign buyruk[`CSRRW]      = match(getir_buyruk_i, `MASK_CSRRW, `MATCH_CSRRW) && coz_aktif_w;
    assign buyruk[`CSRRS]      = match(getir_buyruk_i, `MASK_CSRRS, `MATCH_CSRRS) && coz_aktif_w;
    assign buyruk[`CSRRWI]     = match(getir_buyruk_i, `MASK_CSRRWI, `MATCH_CSRRWI) && coz_aktif_w;
    assign buyruk[`CSRRSI]     = match(getir_buyruk_i, `MASK_CSRRSI, `MATCH_CSRRSI) && coz_aktif_w;
    assign buyruk[`FENCE]      = match(getir_buyruk_i, `MASK_FENCE, `MATCH_FENCE) && coz_aktif_w;
    assign buyruk[`ECALL]      = match(getir_buyruk_i, `MASK_ECALL, `MATCH_ECALL) && coz_aktif_w;
    assign buyruk[`MRET]       = match(getir_buyruk_i, `MASK_MRET, `MATCH_MRET) && coz_aktif_w;
    assign buyruk[`SLLI]       = match(getir_buyruk_i, `MASK_SLLI, `MATCH_SLLI) && coz_aktif_w;
    assign buyruk[`ORI]        = match(getir_buyruk_i, `MASK_ORI, `MATCH_ORI) && coz_aktif_w;
    assign buyruk[`BGE]        = match(getir_buyruk_i, `MASK_BGE, `MATCH_BGE) && coz_aktif_w;
    assign buyruk[`SLTI]       = match(getir_buyruk_i, `MASK_SLTI, `MATCH_SLTI) && coz_aktif_w;
    assign buyruk[`SLTU]       = match(getir_buyruk_i, `MASK_SLTU, `MATCH_SLTU) && coz_aktif_w;
    assign buyruk[`XORI]       = match(getir_buyruk_i, `MASK_XORI, `MATCH_XORI) && coz_aktif_w;
    assign buyruk[`ANDI]       = match(getir_buyruk_i, `MASK_ANDI, `MATCH_ANDI) && coz_aktif_w;
    assign buyruk[`SRLI]       = match(getir_buyruk_i, `MASK_SRLI, `MATCH_SRLI) && coz_aktif_w;
    assign buyruk[`SRAI]       = match(getir_buyruk_i, `MASK_SRAI, `MATCH_SRAI) && coz_aktif_w;
    assign buyruk[`FENCE_I]    = match(getir_buyruk_i, `MASK_FENCE_I, `MATCH_FENCE_I) && coz_aktif_w;
    assign buyruk[`CSRRC]      = match(getir_buyruk_i, `MASK_CSRRC, `MATCH_CSRRC) && coz_aktif_w;
    assign buyruk[`CSRRCI]     = match(getir_buyruk_i, `MASK_CSRRCI, `MATCH_CSRRCI) && coz_aktif_w;
    assign buyruk[`EBREAK]     = match(getir_buyruk_i, `MASK_EBREAK, `MATCH_EBREAK) && coz_aktif_w;
    assign buyruk[`LB]         = match(getir_buyruk_i, `MASK_LB, `MATCH_LB) && coz_aktif_w;
    assign buyruk[`LH]         = match(getir_buyruk_i, `MASK_LH, `MATCH_LH) && coz_aktif_w;
    assign buyruk[`LBU]        = match(getir_buyruk_i, `MASK_LBU, `MATCH_LBU) && coz_aktif_w;
    assign buyruk[`LHU]        = match(getir_buyruk_i, `MASK_LHU, `MATCH_LHU) && coz_aktif_w;
    assign buyruk[`SB]         = match(getir_buyruk_i, `MASK_SB, `MATCH_SB) && coz_aktif_w;
    assign buyruk[`SH]         = match(getir_buyruk_i, `MASK_SH, `MATCH_SH) && coz_aktif_w;
    assign buyruk[`BLTU]       = match(getir_buyruk_i, `MASK_BLTU, `MATCH_BLTU) && coz_aktif_w;
    assign buyruk[`BGEU]       = match(getir_buyruk_i, `MASK_BGEU, `MATCH_BGEU) && coz_aktif_w;
    assign buyruk[`SLT]        = match(getir_buyruk_i, `MASK_SLT, `MATCH_SLT) && coz_aktif_w;
    assign buyruk[`HMDST]      = match(getir_buyruk_i, `MASK_HMDST, `MATCH_HMDST) && coz_aktif_w;
    assign buyruk[`PKG]        = match(getir_buyruk_i, `MASK_PKG, `MATCH_PKG) && coz_aktif_w;
    assign buyruk[`RVRS]       = match(getir_buyruk_i, `MASK_RVRS, `MATCH_RVRS) && coz_aktif_w;
    assign buyruk[`SLADD]      = match(getir_buyruk_i, `MASK_SLADD, `MATCH_SLADD) && coz_aktif_w;
    assign buyruk[`CNTZ]       = match(getir_buyruk_i, `MASK_CNTZ, `MATCH_CNTZ) && coz_aktif_w;
    assign buyruk[`CNTP]       = match(getir_buyruk_i, `MASK_CNTP, `MATCH_CNTP) && coz_aktif_w;
    assign buyruk[`SLTIU]      = match(getir_buyruk_i, `MASK_SLTIU, `MATCH_SLTIU) && coz_aktif_w;
    assign buyruk[`SLL]        = match(getir_buyruk_i, `MASK_SLL, `MATCH_SLL) && coz_aktif_w;
    assign buyruk[`SRL]        = match(getir_buyruk_i, `MASK_SRL, `MATCH_SRL) && coz_aktif_w;
    assign buyruk[`SRA]        = match(getir_buyruk_i, `MASK_SRA, `MATCH_SRA) && coz_aktif_w;
    assign buyruk[`WFI]        = match(getir_buyruk_i, `MASK_WFI, `MATCH_WFI) && coz_aktif_w;
    assign buyruk[`MUL]        = match(getir_buyruk_i, `MASK_MUL, `MATCH_MUL) && coz_aktif_w;
    assign buyruk[`MULH]       = match(getir_buyruk_i, `MASK_MULH, `MATCH_MULH) && coz_aktif_w;
    assign buyruk[`MULHSU]     = match(getir_buyruk_i, `MASK_MULHSU, `MATCH_MULHSU) && coz_aktif_w;
    assign buyruk[`MULHU]      = match(getir_buyruk_i, `MASK_MULHU, `MATCH_MULHU) && coz_aktif_w;
    assign buyruk[`DIV]        = match(getir_buyruk_i, `MASK_DIV, `MATCH_DIV) && coz_aktif_w;
    assign buyruk[`DIVU]       = match(getir_buyruk_i, `MASK_DIVU, `MATCH_DIVU) && coz_aktif_w;
    assign buyruk[`REM]        = match(getir_buyruk_i, `MASK_REM, `MATCH_REM) && coz_aktif_w;
    assign buyruk[`REMU]       = match(getir_buyruk_i, `MASK_REMU, `MATCH_REMU) && coz_aktif_w;
    assign buyruk[`SFENCE_VMA] = match(getir_buyruk_i, `MASK_SFENCE_VMA, `MATCH_SFENCE_VMA) && coz_aktif_w;
    assign buyruk[`CNN_LDX]    = match(getir_buyruk_i, `MASK_CNN_LDX, `MATCH_CNN_LDX) && coz_aktif_w;
    assign buyruk[`CNN_CLRX]   = match(getir_buyruk_i, `MASK_CNN_CLRX, `MATCH_CNN_CLRX) && coz_aktif_w;
    assign buyruk[`CNN_LDW]    = match(getir_buyruk_i, `MASK_CNN_LDW, `MATCH_CNN_LDW) && coz_aktif_w;
    assign buyruk[`CNN_CLRW]   = match(getir_buyruk_i, `MASK_CNN_CLRW, `MATCH_CNN_CLRW) && coz_aktif_w;
    assign buyruk[`CNN_RUN]    = match(getir_buyruk_i, `MASK_CNN_RUN, `MATCH_CNN_RUN) && coz_aktif_w;
    assign buyruk[`C_ADDI4SPN] = match(getir_buyruk_i, `MASK_C_ADDI4SPN, `MATCH_C_ADDI4SPN) && coz_aktif_w;
    assign buyruk[`C_FLD]      = match(getir_buyruk_i, `MASK_C_FLD, `MATCH_C_FLD) && coz_aktif_w;
    assign buyruk[`C_LW]       = match(getir_buyruk_i, `MASK_C_LW, `MATCH_C_LW) && coz_aktif_w;
    assign buyruk[`C_FLW]      = match(getir_buyruk_i, `MASK_C_FLW, `MATCH_C_FLW) && coz_aktif_w;
    assign buyruk[`C_FSD]      = match(getir_buyruk_i, `MASK_C_FSD, `MATCH_C_FSD) && coz_aktif_w;
    assign buyruk[`C_SW]       = match(getir_buyruk_i, `MASK_C_SW, `MATCH_C_SW) && coz_aktif_w;
    assign buyruk[`C_FSW]      = match(getir_buyruk_i, `MASK_C_FSW, `MATCH_C_FSW) && coz_aktif_w;
    assign buyruk[`C_ADDI]     = match(getir_buyruk_i, `MASK_C_ADDI, `MATCH_C_ADDI) && coz_aktif_w && buyruk_c_addi_rd !=0;
    assign buyruk[`C_JAL]      = match(getir_buyruk_i, `MASK_C_JAL, `MATCH_C_JAL) && coz_aktif_w;
    assign buyruk[`C_LI]       = match(getir_buyruk_i, `MASK_C_LI, `MATCH_C_LI) && coz_aktif_w;
    assign buyruk[`C_LUI]      = match(getir_buyruk_i, `MASK_C_LUI, `MATCH_C_LUI) && buyruk_c_lui_rd != 5'b00010 && coz_aktif_w;
    assign buyruk[`C_SRLI]     = match(getir_buyruk_i, `MASK_C_SRLI, `MATCH_C_SRLI) && coz_aktif_w;
    assign buyruk[`C_SRLI64]   = match(getir_buyruk_i, `MASK_C_SRLI64, `MATCH_C_SRLI64) && coz_aktif_w;
    assign buyruk[`C_SRAI]     = match(getir_buyruk_i, `MASK_C_SRAI, `MATCH_C_SRAI) && coz_aktif_w;
    assign buyruk[`C_SRAI64]   = match(getir_buyruk_i, `MASK_C_SRAI64, `MATCH_C_SRAI64) && coz_aktif_w;
    assign buyruk[`C_ANDI]     = match(getir_buyruk_i, `MASK_C_ANDI, `MATCH_C_ANDI) && coz_aktif_w;
    assign buyruk[`C_SUB]      = match(getir_buyruk_i, `MASK_C_SUB, `MATCH_C_SUB) && coz_aktif_w;
    assign buyruk[`C_XOR]      = match(getir_buyruk_i, `MASK_C_XOR, `MATCH_C_XOR) && coz_aktif_w;
    assign buyruk[`C_OR]       = match(getir_buyruk_i, `MASK_C_OR, `MATCH_C_OR) && coz_aktif_w;
    assign buyruk[`C_AND]      = match(getir_buyruk_i, `MASK_C_AND, `MATCH_C_AND) && coz_aktif_w;
    assign buyruk[`C_SUBW]     = match(getir_buyruk_i, `MASK_C_SUBW, `MATCH_C_SUBW) && coz_aktif_w;
    assign buyruk[`C_ADDW]     = match(getir_buyruk_i, `MASK_C_ADDW, `MATCH_C_ADDW) && coz_aktif_w;
    assign buyruk[`C_J]        = match(getir_buyruk_i, `MASK_C_J, `MATCH_C_J) && coz_aktif_w;
    assign buyruk[`C_BEQZ]     = match(getir_buyruk_i, `MASK_C_BEQZ, `MATCH_C_BEQZ) && coz_aktif_w;
    assign buyruk[`C_BNEZ]     = match(getir_buyruk_i, `MASK_C_BNEZ, `MATCH_C_BNEZ) && coz_aktif_w;
    assign buyruk[`C_SLLI]     = match(getir_buyruk_i, `MASK_C_SLLI, `MATCH_C_SLLI) && coz_aktif_w;
    assign buyruk[`C_SLLI64]   = match(getir_buyruk_i, `MASK_C_SLLI64, `MATCH_C_SLLI64) && coz_aktif_w;
    assign buyruk[`C_FLDSP]    = match(getir_buyruk_i, `MASK_C_FLDSP, `MATCH_C_FLDSP) && coz_aktif_w;
    assign buyruk[`C_LWSP]     = match(getir_buyruk_i, `MASK_C_LWSP, `MATCH_C_LWSP) && coz_aktif_w;
    assign buyruk[`C_FLWSP]    = match(getir_buyruk_i, `MASK_C_FLWSP, `MATCH_C_FLWSP) && coz_aktif_w;
    assign buyruk[`C_MV]       = match(getir_buyruk_i, `MASK_C_MV, `MATCH_C_MV) && coz_aktif_w && buyruk_c_mv_rs2!=0;
    assign buyruk[`C_ADD]      = match(getir_buyruk_i, `MASK_C_ADD, `MATCH_C_ADD) && coz_aktif_w && buyruk_c_add_rs2 != 0;
    assign buyruk[`C_FSDSP]    = match(getir_buyruk_i, `MASK_C_FSDSP, `MATCH_C_FSDSP) && coz_aktif_w;
    assign buyruk[`C_SWSP]     = match(getir_buyruk_i, `MASK_C_SWSP, `MATCH_C_SWSP) && coz_aktif_w;
    assign buyruk[`C_FSWSP]    = match(getir_buyruk_i, `MASK_C_FSWSP, `MATCH_C_FSWSP) && coz_aktif_w;
    assign buyruk[`C_NOP]      = match(getir_buyruk_i, `MASK_C_NOP, `MATCH_C_NOP) && coz_aktif_w;
    assign buyruk[`C_ADDI16SP] = match(getir_buyruk_i, `MASK_C_ADDI16SP, `MATCH_C_ADDI16SP) && coz_aktif_w;
    assign buyruk[`C_JR]       = match(getir_buyruk_i, `MASK_C_JR, `MATCH_C_JR) && coz_aktif_w && buyruk_c_jalr_rs1 != 0;
    assign buyruk[`C_JALR]     = match(getir_buyruk_i, `MASK_C_JALR, `MATCH_C_JALR) && coz_aktif_w && buyruk_c_jalr_rs1 != 0;
    assign buyruk[`C_EBREAK]   = match(getir_buyruk_i, `MASK_C_EBREAK, `MATCH_C_EBREAK) && coz_aktif_w;
    assign buyruk[`C_LD]       = match(getir_buyruk_i, `MASK_C_LD, `MATCH_C_LD) && coz_aktif_w;
    assign buyruk[`C_SD]       = match(getir_buyruk_i, `MASK_C_SD, `MATCH_C_SD) && coz_aktif_w;
    //assign buyruk[`C_ADDIW]    = match(getir_buyruk_i, `MASK_C_ADDIW, `MATCH_C_ADDIW) && coz_aktif_w && buyruk_c_addiw_imm != 0;
    assign buyruk[`C_LDSP]     = match(getir_buyruk_i, `MASK_C_LDSP, `MATCH_C_LDSP) && coz_aktif_w;
    assign buyruk[`C_SDSP]     = match(getir_buyruk_i, `MASK_C_SDSP, `MATCH_C_SDSP) && coz_aktif_w;

    assign gecersiz_buyruk_o = !(|buyruk) && coz_aktif_w;
endgenerate

task uop_rv32auipc();
begin
    buyruk_rd_cmb = {{27{`LOW}}, getir_buyruk_i[`U_RD]};
    buyruk_imm_cmb = getir_buyruk_i[`U_IMM] << 12;

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_PC;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_AMB] = `UOP_AMB_ADD;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_rv32lui();
begin
    buyruk_rd_cmb = {{27{`LOW}}, getir_buyruk_i[`U_RD]};
    buyruk_imm_cmb = getir_buyruk_i[`U_IMM] << 12;

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_IS1;
end
endtask

task uop_rv32csrrw();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`CSR_RS1]};
    buyruk_rd_cmb = {{27{`LOW}}, getir_buyruk_i[`CSR_RD]};
    buyruk_csr_cmb = getir_buyruk_i[`CSR_ADDR];

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_CSR_ADDR] = buyruk_csr_cmb;
    uop_ns[`UOP_CSR_EN] = `HIGH;
    uop_ns[`UOP_CSR_ALLOC] = `HIGH;
    uop_ns[`UOP_CSR_OP] = `UOP_CSR_RW;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_CSR;
end
endtask

task uop_rv32csrrwi();
begin
    buyruk_rd_cmb = {{27{`LOW}}, getir_buyruk_i[`CSR_RD]};
    buyruk_csr_cmb = getir_buyruk_i[`CSR_ADDR];
    buyruk_imm_cmb = {{27{`LOW}}, getir_buyruk_i[19:15]};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_imm_cmb;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_CSR_ADDR] = buyruk_csr_cmb;
    uop_ns[`UOP_CSR_EN] = `HIGH;
    uop_ns[`UOP_CSR_ALLOC] = `HIGH;
    uop_ns[`UOP_CSR_OP] = `UOP_CSR_RW;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_CSR;
end
endtask

task uop_rv32csrrs();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`CSR_RS1]};
    buyruk_rd_cmb = {{27{`LOW}}, getir_buyruk_i[`CSR_RD]};
    buyruk_csr_cmb = getir_buyruk_i[`CSR_ADDR];

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_CSR_ADDR] = buyruk_csr_cmb;
    uop_ns[`UOP_CSR_EN] = `HIGH;
    uop_ns[`UOP_CSR_ALLOC] = `HIGH;
    uop_ns[`UOP_CSR_OP] = `UOP_CSR_RS;
    uop_ns[`UOP_AMB] = `UOP_AMB_OR;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_CSR;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_CSR;
end
endtask

task uop_rv32csrrsi();
begin
    buyruk_rd_cmb = {{27{`LOW}}, getir_buyruk_i[`CSR_RD]};
    buyruk_csr_cmb = getir_buyruk_i[`CSR_ADDR];
    buyruk_imm_cmb = {{27{`LOW}}, getir_buyruk_i[19:15]};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_imm_cmb;
    uop_ns[`UOP_CSR_ADDR] = buyruk_csr_cmb;
    uop_ns[`UOP_CSR_EN] = `HIGH;
    uop_ns[`UOP_CSR_ALLOC] = `HIGH;
    uop_ns[`UOP_CSR_OP] = `UOP_CSR_RS;
    uop_ns[`UOP_AMB] = `UOP_AMB_OR;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_CSR;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_CSR;
end
endtask

task uop_rv32bne();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`B_RS1]};
    buyruk_rs2_cmb = {{27{`LOW}}, getir_buyruk_i[`B_RS2]};
    buyruk_imm_cmb = {{21{getir_buyruk_i[`B_SIGN]}}, getir_buyruk_i[7], getir_buyruk_i[30:25], getir_buyruk_i[11:8], 1'b0};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_RS2;
    uop_ns[`UOP_AMB] = `UOP_AMB_NOP;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_NOP;
    uop_ns[`UOP_DAL] = `UOP_DAL_BNE;
end
endtask

task uop_rv32beq();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`B_RS1]};
    buyruk_rs2_cmb = {{27{`LOW}}, getir_buyruk_i[`B_RS2]};
    buyruk_imm_cmb = {{21{getir_buyruk_i[`B_SIGN]}}, getir_buyruk_i[7], getir_buyruk_i[30:25], getir_buyruk_i[11:8], 1'b0};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_RS2;
    uop_ns[`UOP_AMB] = `UOP_AMB_NOP;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_NOP;
    uop_ns[`UOP_DAL] = `UOP_DAL_BEQ;
end
endtask

task uop_rv32bge();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`B_RS1]};
    buyruk_rs2_cmb = {{27{`LOW}}, getir_buyruk_i[`B_RS2]};
    buyruk_imm_cmb = {{21{getir_buyruk_i[`B_SIGN]}}, getir_buyruk_i[7], getir_buyruk_i[30:25], getir_buyruk_i[11:8], 1'b0};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_RS2;
    uop_ns[`UOP_AMB] = `UOP_AMB_NOP;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_NOP;
    uop_ns[`UOP_DAL] = `UOP_DAL_BGE;
end
endtask

task uop_rv32addi();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`I_RS1]};
    buyruk_rd_cmb = getir_buyruk_i[`I_RD];
    buyruk_imm_cmb = {{20{getir_buyruk_i[`I_SIGN]}}, getir_buyruk_i[`I_IMM]};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_AMB] = `UOP_AMB_ADD;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_rv32add();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS1]};
    buyruk_rs2_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS2]};
    buyruk_rd_cmb = getir_buyruk_i[`R_RD];

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_RS2;
    uop_ns[`UOP_AMB] = `UOP_AMB_ADD;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_rv32or();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS1]};
    buyruk_rs2_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS2]};
    buyruk_rd_cmb = getir_buyruk_i[`R_RD];

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_RS2;
    uop_ns[`UOP_AMB] = `UOP_AMB_OR;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_rv32ori();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`I_RS1]};
    buyruk_rd_cmb = getir_buyruk_i[`I_RD];
    buyruk_imm_cmb = {{20{getir_buyruk_i[`I_SIGN]}}, getir_buyruk_i[`I_IMM]};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_AMB] = `UOP_AMB_OR;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_rv32slli();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`I_RS1]};
    buyruk_rd_cmb = getir_buyruk_i[`I_RD];
    buyruk_imm_cmb = {{27{1'b0}}, getir_buyruk_i[24:20]};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_AMB] = `UOP_AMB_SLL;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_rv32sll();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS1]};
    buyruk_rs2_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS2]};
    buyruk_rd_cmb = getir_buyruk_i[`R_RD];
    

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_RS2;
    uop_ns[`UOP_AMB] = `UOP_AMB_SLL;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_rv32jal();
begin
    buyruk_rd_cmb = {{27{`LOW}}, getir_buyruk_i[`J_RD]};
    buyruk_imm_cmb = {{20{getir_buyruk_i[`J_SIGN]}}, getir_buyruk_i[31], getir_buyruk_i[19:12], getir_buyruk_i[20], getir_buyruk_i[30:21], 1'b0};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_DAL] = `UOP_DAL_JAL;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_DAL;
end
endtask

task uop_rv32jalr();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS1]};
    buyruk_rd_cmb = {{27{`LOW}}, getir_buyruk_i[`I_RD]};
    buyruk_imm_cmb = {{20{getir_buyruk_i[`I_SIGN]}}, getir_buyruk_i[`I_IMM]};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_DAL] = `UOP_DAL_JALR;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_DAL;
end
endtask

task uop_rv32mret();
begin
    uop_ns[`UOP_CSR_OP] = `UOP_CSR_MRET;
end
endtask

task uop_rv32slt();  
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS1]};
    buyruk_rs2_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS2]};
    buyruk_rd_cmb = getir_buyruk_i[`R_RD];

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_RS2;
    uop_ns[`UOP_AMB] = `UOP_AMB_SLT;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_rv32sltu();  
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS1]};
    buyruk_rs2_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS2]};
    buyruk_rd_cmb = getir_buyruk_i[`R_RD];

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_RS2;
    uop_ns[`UOP_AMB] = `UOP_AMB_SLTU;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_rv32slti();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`I_RS1]};
    buyruk_rd_cmb = getir_buyruk_i[`I_RD];
    buyruk_imm_cmb = {{20{getir_buyruk_i[`I_SIGN]}}, getir_buyruk_i[`I_IMM]};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_AMB] = `UOP_AMB_SLT;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_rv32sltiu();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`I_RS1]};
    buyruk_rd_cmb = getir_buyruk_i[`I_RD];
    buyruk_imm_cmb = {{20{getir_buyruk_i[`I_SIGN]}}, getir_buyruk_i[`I_IMM]};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_AMB] = `UOP_AMB_SLTU;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_rv32xori();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`I_RS1]};
    buyruk_rd_cmb = getir_buyruk_i[`I_RD];
    buyruk_imm_cmb = {{20{getir_buyruk_i[`I_SIGN]}}, getir_buyruk_i[`I_IMM]};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_AMB] = `UOP_AMB_XOR;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_rv32andi();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`I_RS1]};
    buyruk_rd_cmb = getir_buyruk_i[`I_RD];
    buyruk_imm_cmb = {{20{getir_buyruk_i[`I_SIGN]}}, getir_buyruk_i[`I_IMM]};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_AMB] = `UOP_AMB_AND;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_rv32srli();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`I_RS1]};
    buyruk_rd_cmb = getir_buyruk_i[`I_RD];
    buyruk_imm_cmb = {{27{1'b0}}, getir_buyruk_i[24:20]};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_AMB] = `UOP_AMB_SRL;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_rv32srl();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS1]};
    buyruk_rs2_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS2]};
    buyruk_rd_cmb = getir_buyruk_i[`R_RD];
    

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_RS2;
    uop_ns[`UOP_AMB] = `UOP_AMB_SRL;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_rv32srai();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`I_RS1]};
    buyruk_rd_cmb = getir_buyruk_i[`I_RD];
    buyruk_imm_cmb = {{27{1'b0}}, getir_buyruk_i[24:20]};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_AMB] = `UOP_AMB_SRA;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_rv32sra();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS1]};
    buyruk_rs2_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS2]};
    buyruk_rd_cmb = getir_buyruk_i[`R_RD];

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_RS2;
    uop_ns[`UOP_AMB] = `UOP_AMB_SRA;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_rv32sub();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS1]};
    buyruk_rs2_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS2]};
    buyruk_rd_cmb = getir_buyruk_i[`R_RD];

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_RS2;
    uop_ns[`UOP_AMB] = `UOP_AMB_SUB;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_rv32and();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS1]};
    buyruk_rs2_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS2]};
    buyruk_rd_cmb = getir_buyruk_i[`R_RD];

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_RS2;
    uop_ns[`UOP_AMB] = `UOP_AMB_AND;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_rv32xor();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS1]};
    buyruk_rs2_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS2]};
    buyruk_rd_cmb = getir_buyruk_i[`R_RD];

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_RS2;
    uop_ns[`UOP_AMB] = `UOP_AMB_XOR;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_rv32csrrc();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`CSR_RS1]};
    buyruk_rd_cmb = {{27{`LOW}}, getir_buyruk_i[`CSR_RD]};
    buyruk_csr_cmb = getir_buyruk_i[`CSR_ADDR];

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_CSR_ADDR] = buyruk_csr_cmb;
    uop_ns[`UOP_CSR_EN] = `HIGH;
    uop_ns[`UOP_CSR_ALLOC] = `HIGH;
    uop_ns[`UOP_CSR_OP] = `UOP_CSR_RC;
    uop_ns[`UOP_AMB] = `UOP_AMB_OR;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_CSR;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_CSR;
end
endtask

task uop_rv32csrrci();
begin
    buyruk_rd_cmb = {{27{`LOW}}, getir_buyruk_i[`CSR_RD]};
    buyruk_csr_cmb = getir_buyruk_i[`CSR_ADDR];
    buyruk_imm_cmb = {{27{`LOW}}, getir_buyruk_i[19:15]};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_imm_cmb;
    uop_ns[`UOP_CSR_ADDR] = buyruk_csr_cmb;
    uop_ns[`UOP_CSR_EN] = `HIGH;
    uop_ns[`UOP_CSR_ALLOC] = `HIGH;
    uop_ns[`UOP_CSR_OP] = `UOP_CSR_RC;
    uop_ns[`UOP_AMB] = `UOP_AMB_OR;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_CSR;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_CSR;
end
endtask

task uop_rv32lb();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`I_RS1]};
    buyruk_rd_cmb = getir_buyruk_i[`I_RD];
    buyruk_imm_cmb = {{20{getir_buyruk_i[`I_SIGN]}}, getir_buyruk_i[`I_IMM]};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_AMB] = `UOP_AMB_ADD;
    uop_ns[`UOP_BEL] = `UOP_BEL_LB;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_BEL;
end
endtask

task uop_rv32lh();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`I_RS1]};
    buyruk_rd_cmb = getir_buyruk_i[`I_RD];
    buyruk_imm_cmb = {{20{getir_buyruk_i[`I_SIGN]}}, getir_buyruk_i[`I_IMM]};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_AMB] = `UOP_AMB_ADD;
    uop_ns[`UOP_BEL] = `UOP_BEL_LH; 
    uop_ns[`UOP_YAZ] = `UOP_YAZ_BEL;
end
endtask

task uop_rv32lw();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`I_RS1]};
    buyruk_rd_cmb = getir_buyruk_i[`I_RD];
    buyruk_imm_cmb = {{20{getir_buyruk_i[`I_SIGN]}}, getir_buyruk_i[`I_IMM]};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_AMB] = `UOP_AMB_ADD;    
    uop_ns[`UOP_BEL] = `UOP_BEL_LW; 
    uop_ns[`UOP_YAZ] = `UOP_YAZ_BEL;
end
endtask

task uop_rv32lbu();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`I_RS1]};
    buyruk_rd_cmb = getir_buyruk_i[`I_RD];
    buyruk_imm_cmb = {{20{getir_buyruk_i[`I_SIGN]}}, getir_buyruk_i[`I_IMM]};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_AMB] = `UOP_AMB_ADD;
    uop_ns[`UOP_BEL] = `UOP_BEL_LBU; 
    uop_ns[`UOP_YAZ] = `UOP_YAZ_BEL;
end
endtask

task uop_rv32lhu();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`I_RS1]};
    buyruk_rd_cmb = getir_buyruk_i[`I_RD];
    buyruk_imm_cmb = {{20{getir_buyruk_i[`I_SIGN]}}, getir_buyruk_i[`I_IMM]};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_AMB] = `UOP_AMB_ADD;
    uop_ns[`UOP_BEL] = `UOP_BEL_LHU; 
    uop_ns[`UOP_YAZ] = `UOP_YAZ_BEL;
end
endtask

task uop_rv32sb();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`S_RS1]};
    buyruk_rs2_cmb = {{27{`LOW}}, getir_buyruk_i[`S_RS2]};
    buyruk_imm_cmb = {{20{getir_buyruk_i[`S_SIGN]}}, getir_buyruk_i[`S_IMM_HI], getir_buyruk_i[`S_IMM_LO]};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_AMB] = `UOP_AMB_ADD;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_NOP;
    uop_ns[`UOP_BEL] = `UOP_BEL_SB; 
end
endtask

task uop_rv32sw();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`S_RS1]};
    buyruk_rs2_cmb = {{27{`LOW}}, getir_buyruk_i[`S_RS2]};
    buyruk_imm_cmb = {{20{getir_buyruk_i[`S_SIGN]}}, getir_buyruk_i[`S_IMM_HI], getir_buyruk_i[`S_IMM_LO]};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_AMB] = `UOP_AMB_ADD;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_NOP;
    uop_ns[`UOP_BEL] = `UOP_BEL_SW;
end
endtask

task uop_rv32sh();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`S_RS1]};
    buyruk_rs2_cmb = {{27{`LOW}}, getir_buyruk_i[`S_RS2]};
    buyruk_imm_cmb = {{20{getir_buyruk_i[`S_SIGN]}}, getir_buyruk_i[`S_IMM_HI], getir_buyruk_i[`S_IMM_LO]};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_AMB] = `UOP_AMB_ADD;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_NOP;
    uop_ns[`UOP_BEL] = `UOP_BEL_SH; 
end
endtask

task uop_rv32blt();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`B_RS1]};
    buyruk_rs2_cmb = {{27{`LOW}}, getir_buyruk_i[`B_RS2]};
    buyruk_imm_cmb = {{21{getir_buyruk_i[`B_SIGN]}}, getir_buyruk_i[7], getir_buyruk_i[30:25], getir_buyruk_i[11:8], 1'b0};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_RS2;
    uop_ns[`UOP_AMB] = `UOP_AMB_NOP;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_NOP;
    uop_ns[`UOP_DAL] = `UOP_DAL_BLT;
end
endtask

task uop_rv32bltu();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`B_RS1]};
    buyruk_rs2_cmb = {{27{`LOW}}, getir_buyruk_i[`B_RS2]};
    buyruk_imm_cmb = {{21{getir_buyruk_i[`B_SIGN]}}, getir_buyruk_i[7], getir_buyruk_i[30:25], getir_buyruk_i[11:8], 1'b0};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_RS2;
    uop_ns[`UOP_AMB] = `UOP_AMB_NOP;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_NOP;
    uop_ns[`UOP_DAL] = `UOP_DAL_BLTU;
end
endtask

task uop_rv32bgeu();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`B_RS1]};
    buyruk_rs2_cmb = {{27{`LOW}}, getir_buyruk_i[`B_RS2]};
    buyruk_imm_cmb = {{21{getir_buyruk_i[`B_SIGN]}}, getir_buyruk_i[7], getir_buyruk_i[30:25], getir_buyruk_i[11:8], 1'b0};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_RS2;
    uop_ns[`UOP_AMB] = `UOP_AMB_NOP;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_NOP;
    uop_ns[`UOP_DAL] = `UOP_DAL_BGEU;
end
endtask

task uop_rv32mul();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS1]};
    buyruk_rs2_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS2]};
    buyruk_rd_cmb = getir_buyruk_i[`R_RD];

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_RS2;
    uop_ns[`UOP_AMB] = `UOP_AMB_MUL;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_rv32mulh();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS1]};
    buyruk_rs2_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS2]};
    buyruk_rd_cmb = getir_buyruk_i[`R_RD];

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_RS2;
    uop_ns[`UOP_AMB] = `UOP_AMB_MULH;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_rv32mulhu();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS1]};
    buyruk_rs2_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS2]};
    buyruk_rd_cmb = getir_buyruk_i[`R_RD];

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_RS2;
    uop_ns[`UOP_AMB] = `UOP_AMB_MULHU;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_rv32mulhsu();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS1]};
    buyruk_rs2_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS2]};
    buyruk_rd_cmb = getir_buyruk_i[`R_RD];

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_RS2;
    uop_ns[`UOP_AMB] = `UOP_AMB_MULHSU;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_rv32div();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS1]};
    buyruk_rs2_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS2]};
    buyruk_rd_cmb = getir_buyruk_i[`R_RD];

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_RS2;
    uop_ns[`UOP_AMB] = `UOP_AMB_DIV;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask
task uop_rv32divu();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS1]};
    buyruk_rs2_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS2]};
    buyruk_rd_cmb = getir_buyruk_i[`R_RD];

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_RS2;
    uop_ns[`UOP_AMB] = `UOP_AMB_DIVU;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_rv32rem();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS1]};
    buyruk_rs2_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS2]};
    buyruk_rd_cmb = getir_buyruk_i[`R_RD];

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_RS2;
    uop_ns[`UOP_AMB] = `UOP_AMB_REM;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_rv32remu();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS1]};
    buyruk_rs2_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS2]};
    buyruk_rd_cmb = getir_buyruk_i[`R_RD];

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_RS2;
    uop_ns[`UOP_AMB] = `UOP_AMB_REMU;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_xhmdst();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS1]};
    buyruk_rs2_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS2]};
    buyruk_rd_cmb = getir_buyruk_i[`R_RD];

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_RS2;
    uop_ns[`UOP_AMB] = `UOP_AMB_HMDST;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_xpkg();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS1]};
    buyruk_rs2_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS2]};
    buyruk_rd_cmb = getir_buyruk_i[`R_RD];

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_RS2;
    uop_ns[`UOP_AMB] = `UOP_AMB_PKG;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_xrvrs();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS1]};
    buyruk_rd_cmb = getir_buyruk_i[`R_RD];

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB] = `UOP_AMB_RVRS;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_xsladd();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS1]};
    buyruk_rs2_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS2]};
    buyruk_rd_cmb = getir_buyruk_i[`R_RD];

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_RS2;
    uop_ns[`UOP_AMB] = `UOP_AMB_SLADD;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_xcntz();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS1]};
    buyruk_rd_cmb = getir_buyruk_i[`R_RD];

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB] = `UOP_AMB_CNTZ;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_xcntp();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`R_RS1]};
    buyruk_rd_cmb = getir_buyruk_i[`R_RD];

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB] = `UOP_AMB_CNTP;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_cnnldx();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`CNN_RS1]};
    buyruk_rs2_cmb = {{27{`LOW}}, getir_buyruk_i[`CNN_RS2]};
    buyruk_cnn_rs2_en_cmb = getir_buyruk_i[`CNN_RS2_EN];

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = buyruk_cnn_rs2_en_cmb;
    uop_ns[`UOP_YZB] =  buyruk_cnn_rs2_en_cmb  ? `UOP_YZB_LDX_ALL : `UOP_YZB_LDX_OP1;
end
endtask

task uop_cnnclrx();
begin
    uop_ns[`UOP_YZB] =  `UOP_YZB_CLRX;
end
endtask

task uop_cnnldw();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`CNN_RS1]};
    buyruk_rs2_cmb = {{27{`LOW}}, getir_buyruk_i[`CNN_RS2]};
    buyruk_cnn_rs2_en_cmb = getir_buyruk_i[`CNN_RS2_EN];

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = buyruk_cnn_rs2_en_cmb;
    uop_ns[`UOP_YZB] =  buyruk_cnn_rs2_en_cmb  ? `UOP_YZB_LDW_ALL : `UOP_YZB_LDW_OP1;
end
endtask

task uop_cnnclrw();
begin
    uop_ns[`UOP_YZB] =  `UOP_YZB_CLRW;
end
endtask

task uop_cnnrun();
begin
    buyruk_rd_cmb = getir_buyruk_i[`CNN_RD];

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_YZB] = `UOP_YZB_RUN;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_YZB;
end
endtask

task uop_rv32caddi4spn();
begin
    buyruk_rs1_cmb = 32'd2;
    buyruk_rd_cmb = {2'd0,getir_buyruk_i[4:2]}+5'd8;
    buyruk_imm_cmb = { {22{`LOW}} , getir_buyruk_i[10:7], getir_buyruk_i[12:11], getir_buyruk_i[5], getir_buyruk_i[6], 2'd0};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_AMB] = `UOP_AMB_ADD;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB; 
end
endtask

task uop_rv32cfld();
begin
    buyruk_rs1_cmb = {29'd0,getir_buyruk_i[9:7]}+5'd8;
    buyruk_rd_cmb = {2'd0,getir_buyruk_i[4:2]}+5'd8;
    buyruk_imm_cmb = {24'd0,getir_buyruk_i[6:5],getir_buyruk_i[12:10],3'd0};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_AMB] = `UOP_AMB_ADD;    
    uop_ns[`UOP_BEL] = `UOP_BEL_LW; 
    uop_ns[`UOP_YAZ] = `UOP_YAZ_BEL;
end
endtask

task uop_rv32clw();
begin
    buyruk_rs1_cmb = {29'd0,getir_buyruk_i[9:7]}+5'd8;
    buyruk_rd_cmb = {2'd0,getir_buyruk_i[4:2]}+5'd8;
    buyruk_imm_cmb = {25'd0,getir_buyruk_i[5],getir_buyruk_i[12:10],getir_buyruk_i[6],2'd0};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_AMB] = `UOP_AMB_ADD;    
    uop_ns[`UOP_BEL] = `UOP_BEL_LW; 
    uop_ns[`UOP_YAZ] = `UOP_YAZ_BEL;
end
endtask

task uop_rv32cflw();
begin
    buyruk_rs1_cmb = {29'd0,getir_buyruk_i[9:7]}+5'd8;
    buyruk_rd_cmb = {2'd0,getir_buyruk_i[4:2]}+5'd8;
    buyruk_imm_cmb = {25'd0,getir_buyruk_i[5],getir_buyruk_i[12:10],getir_buyruk_i[6],2'd0};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_AMB] = `UOP_AMB_ADD;    
    uop_ns[`UOP_BEL] = `UOP_BEL_LW; 
    uop_ns[`UOP_YAZ] = `UOP_YAZ_BEL;
end
endtask

task uop_rv32cld();
begin
    buyruk_rs1_cmb = {29'd0,getir_buyruk_i[9:7]}+5'd8;
    buyruk_rd_cmb = {2'd0,getir_buyruk_i[4:2]}+5'd8;
    buyruk_imm_cmb = {24'd0,getir_buyruk_i[6:5],getir_buyruk_i[12:10],3'd0};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_AMB] = `UOP_AMB_ADD;    
    uop_ns[`UOP_BEL] = `UOP_BEL_LW; 
    uop_ns[`UOP_YAZ] = `UOP_YAZ_BEL;
end
endtask

task uop_rv32cfsd();
begin
    buyruk_rs1_cmb = {29'd0,getir_buyruk_i[9:7]}+5'd8;
    buyruk_rs2_cmb  = {2'd0,getir_buyruk_i[4:2]}+5'd8;
    buyruk_imm_cmb = {24'd0,getir_buyruk_i[6:5],getir_buyruk_i[12:10],3'd0};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_AMB] = `UOP_AMB_ADD;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_NOP;
    uop_ns[`UOP_BEL] = `UOP_BEL_SW;
end
endtask

task uop_rv32csw();
begin
    buyruk_rs1_cmb = {29'd0,getir_buyruk_i[9:7]}+5'd8;
    buyruk_rs2_cmb = {2'd0,getir_buyruk_i[4:2]}+5'd8;
    buyruk_imm_cmb = {25'd0,getir_buyruk_i[5],getir_buyruk_i[12:10],getir_buyruk_i[6],2'd0};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_AMB] = `UOP_AMB_ADD;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_NOP;
    uop_ns[`UOP_BEL] = `UOP_BEL_SW;
end
endtask

task uop_rv32cfsw();
begin
    buyruk_rs1_cmb = {29'd0,getir_buyruk_i[9:7]}+5'd8;
    buyruk_rs2_cmb = {2'd0,getir_buyruk_i[4:2]}+5'd8;
    buyruk_imm_cmb = {25'd0,getir_buyruk_i[5],getir_buyruk_i[12:10],getir_buyruk_i[6],2'd0};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_AMB] = `UOP_AMB_ADD;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_NOP;
    uop_ns[`UOP_BEL] = `UOP_BEL_SW;
end
endtask

task uop_rv32csd();
begin
    buyruk_rs1_cmb = {29'd0,getir_buyruk_i[9:7]}+5'd8;
    buyruk_rs2_cmb  = {2'd0,getir_buyruk_i[4:2]}+5'd8;
    buyruk_imm_cmb = {24'd0,getir_buyruk_i[6:5],getir_buyruk_i[12:10],3'd0};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_AMB] = `UOP_AMB_ADD;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_NOP;
    uop_ns[`UOP_BEL] = `UOP_BEL_SW;
end
endtask

task uop_rv32cnop();
begin
    uop_ns = {`UOP_BIT{1'b0}};
end
endtask

task uop_rv32caddi();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[11:7]};
    buyruk_rd_cmb = getir_buyruk_i[11:7];
    buyruk_imm_cmb = {{26{getir_buyruk_i[12]}}, getir_buyruk_i[12], getir_buyruk_i[6:2]};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_AMB] = `UOP_AMB_ADD;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_rv32cjal(); //TO DO
begin
    buyruk_rd_cmb = {{31{`LOW}}, 1'd1};
    buyruk_imm_cmb = {{20{getir_buyruk_i[12]}},getir_buyruk_i[12],getir_buyruk_i[8],getir_buyruk_i[10:9],getir_buyruk_i[6],getir_buyruk_i[7],getir_buyruk_i[2],getir_buyruk_i[11],getir_buyruk_i[5:3],1'd0};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_DAL] = `UOP_DAL_CJAL;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_DAL;
end
endtask

task uop_rv32caddiw();
begin
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[11:7]};
    buyruk_rd_cmb = getir_buyruk_i[11:7];
    buyruk_imm_cmb = {{26{getir_buyruk_i[12]}}, getir_buyruk_i[12], getir_buyruk_i[6:2]};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_AMB] = `UOP_AMB_ADD;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_rv32cli();
begin
    buyruk_rd_cmb = {{27{`LOW}}, getir_buyruk_i[11:7]};
    buyruk_imm_cmb = {{26{getir_buyruk_i[12]}}, getir_buyruk_i[12], getir_buyruk_i[6:2]};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_IS1;
end
endtask

task uop_rv32caddi16sp();
begin
    buyruk_rs1_cmb = 32'd2;
    buyruk_rd_cmb = 5'd2;
    buyruk_imm_cmb = {{22{getir_buyruk_i[12]}}, getir_buyruk_i[12], getir_buyruk_i[4:3], getir_buyruk_i[5], getir_buyruk_i[2], getir_buyruk_i[6], 4'd0};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_AMB] = `UOP_AMB_ADD;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_rv32clui();
begin
    buyruk_rd_cmb = {{27{`LOW}}, getir_buyruk_i[11:7]};
    buyruk_imm_cmb = {{14{getir_buyruk_i[12]}},getir_buyruk_i[12],getir_buyruk_i[6:2],12'd0};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_IS1;
end
endtask

task uop_rv32csrli();
begin
    buyruk_rs1_cmb = {29'd0, getir_buyruk_i[9:7]} + 32'd8;
    buyruk_rd_cmb = {2'd0, getir_buyruk_i[9:7]} + 5'd8;
    buyruk_imm_cmb = {{27{1'b0}}, getir_buyruk_i[12], getir_buyruk_i[6:2]};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_AMB] = `UOP_AMB_SRL;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_rv32csrai();
begin
    buyruk_rs1_cmb = {29'd0, getir_buyruk_i[9:7]} + 32'd8;
    buyruk_rd_cmb = {2'd0, getir_buyruk_i[9:7]} + 5'd8;
    buyruk_imm_cmb = {{27{1'b0}}, getir_buyruk_i[12], getir_buyruk_i[6:2]};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_AMB] = `UOP_AMB_SRA;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_rv32candi();
begin
    buyruk_rs1_cmb = {29'd0, getir_buyruk_i[9:7]} + 32'd8;
    buyruk_rd_cmb = {2'd0, getir_buyruk_i[9:7]} + 5'd8;
    buyruk_imm_cmb = {{26{getir_buyruk_i[12]}}, getir_buyruk_i[12], getir_buyruk_i[6:2]};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_AMB] = `UOP_AMB_AND;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_rv32csub();
begin
    buyruk_rs1_cmb = {29'd0, getir_buyruk_i[9:7]} + 32'd8;
    buyruk_rs2_cmb = {29'd0, getir_buyruk_i[4:2]} + 32'd8;
    buyruk_rd_cmb = {2'd0, getir_buyruk_i[9:7]} + 5'd8;

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_RS2;
    uop_ns[`UOP_AMB] = `UOP_AMB_SUB;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_rv32cxor();
begin
    buyruk_rs1_cmb = {29'd0, getir_buyruk_i[9:7]} + 32'd8;
    buyruk_rs2_cmb = {29'd0, getir_buyruk_i[4:2]} + 32'd8;
    buyruk_rd_cmb = {2'd0, getir_buyruk_i[9:7]} + 5'd8;

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_RS2;
    uop_ns[`UOP_AMB] = `UOP_AMB_XOR;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_rv32cor();
begin
    buyruk_rs1_cmb = {29'd0, getir_buyruk_i[9:7]} + 32'd8;
    buyruk_rs2_cmb = {29'd0, getir_buyruk_i[4:2]} + 32'd8;
    buyruk_rd_cmb = {2'd0, getir_buyruk_i[9:7]} + 5'd8;

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_RS2;
    uop_ns[`UOP_AMB] = `UOP_AMB_OR;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_rv32cand();
begin
    buyruk_rs1_cmb = {29'd0, getir_buyruk_i[9:7]} + 32'd8;
    buyruk_rs2_cmb = {29'd0, getir_buyruk_i[4:2]} + 32'd8;
    buyruk_rd_cmb = {2'd0, getir_buyruk_i[9:7]} + 5'd8;

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_RS2;
    uop_ns[`UOP_AMB] = `UOP_AMB_AND;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_rv32csubw();
begin
    buyruk_rs1_cmb = {29'd0, getir_buyruk_i[9:7]} + 32'd8;
    buyruk_rs2_cmb = {29'd0, getir_buyruk_i[4:2]} + 32'd8;
    buyruk_rd_cmb = {2'd0, getir_buyruk_i[9:7]} + 5'd8;

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_RS2;
    uop_ns[`UOP_AMB] = `UOP_AMB_SUB;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_rv32caddw();
begin
    buyruk_rs1_cmb = {29'd0, getir_buyruk_i[9:7]} + 32'd8;
    buyruk_rs2_cmb = {29'd0, getir_buyruk_i[4:2]} + 32'd8;
    buyruk_rd_cmb = {2'd0, getir_buyruk_i[9:7]} + 5'd8;

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_RS2;
    uop_ns[`UOP_AMB] = `UOP_AMB_ADD;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_rv32cj(); //TO DO
begin
    buyruk_rd_cmb = 32'd0;
    buyruk_imm_cmb = {{20{getir_buyruk_i[12]}},getir_buyruk_i[12],getir_buyruk_i[8],getir_buyruk_i[10:9],getir_buyruk_i[6],getir_buyruk_i[7],getir_buyruk_i[2],getir_buyruk_i[11],getir_buyruk_i[5:3],1'd0};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `LOW;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_DAL] = `UOP_DAL_CJAL;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_DAL;
end
endtask

task uop_rv32cbeqz();
begin
    buyruk_rs1_cmb = {29'd0, getir_buyruk_i[9:7]} + 32'd8;
    buyruk_rs2_cmb = 32'd0;
    buyruk_imm_cmb = {{23{getir_buyruk_i[12]}}, getir_buyruk_i[12], getir_buyruk_i[6:5], getir_buyruk_i[2], getir_buyruk_i[11:10], getir_buyruk_i[4:3],1'd0};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_RS2;
    uop_ns[`UOP_AMB] = `UOP_AMB_NOP;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_NOP;
    uop_ns[`UOP_DAL] = `UOP_DAL_BEQ;
end
endtask

task uop_rv32cbnez();
begin
    buyruk_rs1_cmb = {29'd0, getir_buyruk_i[9:7]} + 32'd8;
    buyruk_rs2_cmb = 32'd0;
    buyruk_imm_cmb = {{23{getir_buyruk_i[12]}}, getir_buyruk_i[12], getir_buyruk_i[6:5], getir_buyruk_i[2], getir_buyruk_i[11:10], getir_buyruk_i[4:3],1'd0};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_RS2;
    uop_ns[`UOP_AMB] = `UOP_AMB_NOP;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_NOP;
    uop_ns[`UOP_DAL] = `UOP_DAL_BNE;
end
endtask

task uop_rv32cslli();
begin
    buyruk_rs1_cmb = {{27{`LOW}},getir_buyruk_i[11:7]};
    buyruk_rd_cmb = getir_buyruk_i[11:7];
    buyruk_imm_cmb = {26'd0, getir_buyruk_i[12], getir_buyruk_i[6:2]};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_AMB] = `UOP_AMB_SLL;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_rv32clwsp(); //
begin
    buyruk_rs1_cmb = 32'd2;
    buyruk_rd_cmb = getir_buyruk_i[11:7];
    buyruk_imm_cmb = {24'd0,getir_buyruk_i[3:2],getir_buyruk_i[12],getir_buyruk_i[6:4],2'd0};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_AMB] = `UOP_AMB_ADD;    
    uop_ns[`UOP_BEL] = `UOP_BEL_LW; 
    uop_ns[`UOP_YAZ] = `UOP_YAZ_BEL;
end
endtask

task uop_rv32cldsp();
begin
    buyruk_rs1_cmb = 32'd2;
    buyruk_rd_cmb = getir_buyruk_i[11:7];
    buyruk_imm_cmb = {23'd0,getir_buyruk_i[4:2],getir_buyruk_i[12],getir_buyruk_i[6:5],3'd0};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_AMB] = `UOP_AMB_ADD;    
    uop_ns[`UOP_BEL] = `UOP_BEL_LW; 
    uop_ns[`UOP_YAZ] = `UOP_YAZ_BEL;
end
endtask

task uop_rv32cjr(); //TO DO
begin
    buyruk_rd_cmb = {{27{`LOW}}, getir_buyruk_i[`I_RD]};
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[11:7]};
    buyruk_imm_cmb = 32'd0;

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `LOW;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_DAL] = `UOP_DAL_CJALR;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_NOP;
end
endtask

task uop_rv32cmv();
begin
    buyruk_rs1_cmb = 32'd0;
    buyruk_rs2_cmb = {27'd0, getir_buyruk_i[6:2]};
    buyruk_rd_cmb =  getir_buyruk_i[11:7];

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS2;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_IS1;
end
endtask

task uop_rv32cadd();
begin
    buyruk_rs1_cmb = {27'd0, getir_buyruk_i[11:7]};
    buyruk_rs2_cmb = {27'd0, getir_buyruk_i[6:2]};
    buyruk_rd_cmb =  getir_buyruk_i[11:7];

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_RS2;
    uop_ns[`UOP_AMB] = `UOP_AMB_ADD;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;
end
endtask

task uop_rv32cswsp();
begin
    buyruk_rs1_cmb = 32'd2;
    buyruk_rs2_cmb = getir_buyruk_i[6:2];
    buyruk_imm_cmb = {24'd0, getir_buyruk_i[8:7], getir_buyruk_i[12:9], 2'd0};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_AMB] = `UOP_AMB_ADD;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_NOP;
    uop_ns[`UOP_BEL] = `UOP_BEL_SW;
end
endtask

task uop_rv32csdsp();
begin
    buyruk_rs1_cmb = 32'd2;
    buyruk_rs2_cmb  = {2'd0,getir_buyruk_i[4:2]};
    buyruk_imm_cmb = {23'd0,getir_buyruk_i[9:7],getir_buyruk_i[12:10],3'd0};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RS2_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_AMB_OP1] = `UOP_AMB_OP_RS1;
    uop_ns[`UOP_AMB_OP2] = `UOP_AMB_OP_IMM;
    uop_ns[`UOP_AMB] = `UOP_AMB_ADD;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_NOP;
    uop_ns[`UOP_BEL] = `UOP_BEL_SW;
end
endtask

task uop_rv32cjalr();
begin
    buyruk_rd_cmb = 32'd1;
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[11:7]};
    buyruk_imm_cmb = 32'd0;

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS1_EN] = `HIGH;
    uop_ns[`UOP_IMM] = buyruk_imm_cmb;
    uop_ns[`UOP_DAL] = `UOP_DAL_CJALR;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_DAL;
end
endtask

task uop_nop();
begin
    uop_ns = {`UOP_BIT{1'b0}};
end
endtask

always @* begin
    buyruk_imm_cmb = {`VERI_BIT{1'b0}};
    buyruk_rs1_cmb = {`VERI_BIT{1'b0}};
    buyruk_rs2_cmb = {`VERI_BIT{1'b0}};
    buyruk_rd_cmb = {`YAZMAC_BIT{1'b0}};
    buyruk_csr_cmb = {`CSR_ADRES_BIT{1'b0}};
    buyruk_cnn_rs1_en_cmb = `LOW;
    buyruk_cnn_rs2_en_cmb = `LOW;
    buyruk_etiket_gecerli_cmb = `LOW;
    uop_ns = {`UOP_BIT{`LOW}};
    buyruk_etiket_ns = buyruk_etiket_r;

    uop_ns[`UOP_PC] = getir_ps_i;
    uop_ns[`UOP_TAG] = buyruk_etiket_r;
    uop_ns[`UOP_VALID] = coz_aktif_w;
    uop_ns[`UOP_TAKEN] = getir_atladi_i;
    uop_ns[`UOP_RVC] = getir_rvc_i;
    
    case (buyruk)    
    CASE_LUI         : uop_rv32lui();
    CASE_AUIPC       : uop_rv32auipc();
    CASE_JALR        : uop_rv32jalr();
    CASE_JAL         : uop_rv32jal();
    CASE_BEQ         : uop_rv32beq();
    CASE_BNE         : uop_rv32bne();
    CASE_BGE         : uop_rv32bge();
    CASE_BLT         : uop_rv32blt();
    CASE_LW          : uop_rv32lw();
    CASE_SW          : uop_rv32sw();
    CASE_ADD         : uop_rv32add();
    CASE_ADDI        : uop_rv32addi();
    CASE_SUB         : uop_rv32sub();
    CASE_OR          : uop_rv32or();
    CASE_ORI         : uop_rv32ori();
    CASE_AND         : uop_rv32and();
    CASE_XOR         : uop_rv32xor();
    CASE_SLLI        : uop_rv32slli();
    CASE_SLL         : uop_rv32sll();
    CASE_CSRRW       : uop_rv32csrrw();
    CASE_CSRRWI      : uop_rv32csrrwi();
    CASE_CSRRS       : uop_rv32csrrs();
    CASE_CSRRSI      : uop_rv32csrrsi();
    CASE_FENCE       : uop_nop();
    CASE_ECALL       : uop_nop();
    CASE_MRET        : uop_rv32mret();
    CASE_SLT         : uop_rv32slt();
    CASE_SLTI        : uop_rv32slti();
    CASE_SLTU        : uop_rv32sltu();
    CASE_SLTIU       : uop_rv32sltiu();
    CASE_XORI        : uop_rv32xori();
    CASE_ANDI        : uop_rv32andi();
    CASE_SRLI        : uop_rv32srli();
    CASE_SRL         : uop_rv32srl();
    CASE_SRAI        : uop_rv32srai();
    CASE_SRA         : uop_rv32sra();
    CASE_FENCE_I     : uop_nop();
    CASE_CSRRC       : uop_rv32csrrc();
    CASE_CSRRCI      : uop_rv32csrrci();
    CASE_EBREAK      : uop_nop();
    CASE_LB          : uop_rv32lb();
    CASE_LH          : uop_rv32lh();
    CASE_LBU         : uop_rv32lbu();
    CASE_LHU         : uop_rv32lhu();
    CASE_SB          : uop_rv32sb();
    CASE_SH          : uop_rv32sh();
    CASE_BLTU        : uop_rv32bltu();
    CASE_BGEU        : uop_rv32bgeu();
    CASE_MUL         : uop_rv32mul();
    CASE_MULH        : uop_rv32mulh();
    CASE_MULHU       : uop_rv32mulhu();
    CASE_MULHSU      : uop_rv32mulhsu();
    CASE_DIV         : uop_rv32div();
    CASE_DIVU        : uop_rv32divu();
    CASE_REM         : uop_rv32rem();
    CASE_REMU        : uop_rv32remu(); 
    CASE_SFENCE_VMA  : uop_nop();
    CASE_WFI         : uop_nop();   
    CASE_HMDST       : uop_xhmdst();   
    CASE_PKG         : uop_xpkg();   
    CASE_RVRS        : uop_xrvrs();   
    CASE_SLADD       : uop_xsladd();   
    CASE_CNTZ        : uop_xcntz();   
    CASE_CNTP        : uop_xcntp();
    CASE_CNN_LDX     : uop_cnnldx();   
    CASE_CNN_CLRX    : uop_cnnclrx();   
    CASE_CNN_LDW     : uop_cnnldw();   
    CASE_CNN_CLRW    : uop_cnnclrw();   
    CASE_CNN_RUN     : uop_cnnrun();
    CASE_C_ADDI4SPN  : uop_rv32caddi4spn();
    CASE_C_FLD       : uop_rv32cfld();  
    CASE_C_LW        : uop_rv32clw();
    CASE_C_FLW       : uop_rv32cflw();
    CASE_C_FSD       : uop_rv32cfsd();
    CASE_C_SW        : uop_rv32csw();
    CASE_C_FSW       : uop_rv32cfsw();
    CASE_C_ADDI      : uop_rv32caddi();
    CASE_C_JAL       : uop_rv32cjal();
    CASE_C_LI        : uop_rv32cli();
    CASE_C_LUI       : uop_rv32clui();
    CASE_C_SRLI      : uop_rv32csrli();
    CASE_C_SRLI64    : uop_nop();
    CASE_C_SRAI      : uop_rv32csrai();
    CASE_C_SRAI64    : uop_nop();
    CASE_C_ANDI      : uop_rv32candi();
    CASE_C_SUB       : uop_rv32csub();
    CASE_C_XOR       : uop_rv32cxor();
    CASE_C_OR        : uop_rv32cor();
    CASE_C_AND       : uop_rv32cand();
    CASE_C_SUBW      : uop_rv32csubw();
    CASE_C_ADDW      : uop_rv32caddw();
    CASE_C_J         : uop_rv32cj();
    CASE_C_BEQZ      : uop_rv32cbeqz();
    CASE_C_BNEZ      : uop_rv32cbnez();
    CASE_C_SLLI      : uop_rv32cslli();
    CASE_C_SLLI64    : uop_nop();
    CASE_C_FLDSP     : uop_nop();
    CASE_C_LWSP      : uop_rv32clwsp();
    CASE_C_FLWSP     : uop_nop();
    CASE_C_MV        : uop_rv32cmv();    
    CASE_C_ADD       : uop_rv32cadd();
    CASE_C_FSDSP     : uop_nop();
    CASE_C_SWSP      : uop_rv32cswsp();
    CASE_C_FSWSP     : uop_nop();
    CASE_C_NOP       : uop_nop();
    CASE_C_ADDI16SP  : uop_rv32caddi16sp();
    CASE_C_JR        : uop_rv32cjr();
    CASE_C_JALR      : uop_rv32cjalr();
    CASE_C_EBREAK    : uop_nop();
    CASE_C_LD        : uop_rv32cld();
    CASE_C_SD        : uop_rv32csd();
    //CASE_C_ADDIW     : uop_rv32caddiw();
    CASE_C_LDSP      : uop_rv32cldsp();
    CASE_C_SDSP      : uop_rv32csdsp();       
    default          : uop_nop();
    endcase

    if (buyruk_etiket_gecerli_cmb && !cek_duraklat_i) begin
        buyruk_etiket_ns = buyruk_etiket_r + 4'd1; // UOP_TAG_BIT
    end

    if (cek_duraklat_i) begin
        uop_ns = uop_r;
    end
end

always @(posedge clk_i) begin
    if (!rstn_i) begin
        uop_r <= {`UOP_BIT{`LOW}};
        buyruk_etiket_r <= {`UOP_TAG_BIT{1'b0}};
    end
    else begin
        uop_r <= uop_ns;
        buyruk_etiket_r <= buyruk_etiket_ns;
    end
end

assign yo_uop_o = uop_r;
assign coz_aktif_w = getir_gecerli_i && !cek_bosalt_i;
assign duraklat_o = `LOW;

endmodule