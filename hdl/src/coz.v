`timescale 1ns / 1ps

`include "sabitler.vh"
`include "mikroislem.vh"
`include "coz.vh"
`include "opcode.vh"

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

wire coz_aktif_w;

reg [`VERI_BIT-1:0]         buyruk_imm_cmb;
reg [`VERI_BIT-1:0]         buyruk_rs1_cmb;
reg [`VERI_BIT-1:0]         buyruk_rs2_cmb;
reg [`YAZMAC_BIT-1:0]       buyruk_rd_cmb;
reg [`CSR_ADRES_BIT-1:0]    buyruk_csr_cmb;
reg                         buyruk_etiket_gecerli_cmb;

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
    assign buyruk[`LUI]     = match(getir_buyruk_i, `MASK_LUI, `MATCH_LUI) && coz_aktif_w;
    assign buyruk[`AUIPC]   = match(getir_buyruk_i, `MASK_AUIPC, `MATCH_AUIPC) && coz_aktif_w;
    assign buyruk[`JALR]    = match(getir_buyruk_i, `MASK_JALR, `MATCH_JALR) && coz_aktif_w;
    assign buyruk[`JAL]     = match(getir_buyruk_i, `MASK_JAL, `MATCH_JAL) && coz_aktif_w;
    assign buyruk[`BEQ]     = match(getir_buyruk_i, `MASK_BEQ, `MATCH_BEQ) && coz_aktif_w;
    assign buyruk[`BNE]     = match(getir_buyruk_i, `MASK_BNE, `MATCH_BNE) && coz_aktif_w;
    assign buyruk[`BLT]     = match(getir_buyruk_i, `MASK_BLT, `MATCH_BLT) && coz_aktif_w;
    assign buyruk[`LW]      = match(getir_buyruk_i, `MASK_LW, `MATCH_LW) && coz_aktif_w;
    assign buyruk[`SW]      = match(getir_buyruk_i, `MASK_SW, `MATCH_SW) && coz_aktif_w;
    assign buyruk[`ADDI]    = match(getir_buyruk_i, `MASK_ADDI, `MATCH_ADDI) && coz_aktif_w;
    assign buyruk[`ADD]     = match(getir_buyruk_i, `MASK_ADD, `MATCH_ADD) && coz_aktif_w;
    assign buyruk[`SUB]     = match(getir_buyruk_i, `MASK_SUB, `MATCH_SUB) && coz_aktif_w;
    assign buyruk[`OR]      = match(getir_buyruk_i, `MASK_OR, `MATCH_OR) && coz_aktif_w;
    assign buyruk[`AND]     = match(getir_buyruk_i, `MASK_AND, `MATCH_AND) && coz_aktif_w;
    assign buyruk[`XOR]     = match(getir_buyruk_i, `MASK_XOR, `MATCH_XOR) && coz_aktif_w;
    assign buyruk[`CSRRW]   = match(getir_buyruk_i, `MASK_CSRRW, `MATCH_CSRRW) && coz_aktif_w;
    assign buyruk[`CSRRS]   = match(getir_buyruk_i, `MASK_CSRRS, `MATCH_CSRRS) && coz_aktif_w;
    assign buyruk[`CSRRWI]  = match(getir_buyruk_i, `MASK_CSRRWI, `MATCH_CSRRWI) && coz_aktif_w;
    assign buyruk[`CSRRSI]  = match(getir_buyruk_i, `MASK_CSRRSI, `MATCH_CSRRSI) && coz_aktif_w;
    assign buyruk[`FENCE]   = match(getir_buyruk_i, `MASK_FENCE, `MATCH_FENCE) && coz_aktif_w;
    assign buyruk[`ECALL]   = match(getir_buyruk_i, `MASK_ECALL, `MATCH_ECALL) && coz_aktif_w;
    assign buyruk[`MRET]    = match(getir_buyruk_i, `MASK_MRET, `MATCH_MRET) && coz_aktif_w;
    assign buyruk[`SLLI]    = match(getir_buyruk_i, `MASK_SLLI, `MATCH_SLLI) && coz_aktif_w;
    assign buyruk[`ORI]     = match(getir_buyruk_i, `MASK_ORI, `MATCH_ORI) && coz_aktif_w;
    assign buyruk[`BGE]     = match(getir_buyruk_i, `MASK_BGE, `MATCH_BGE) && coz_aktif_w;
    assign buyruk[`SLTI]    = match(getir_buyruk_i, `MASK_SLTI, `MATCH_SLTI) && coz_aktif_w;
    assign buyruk[`SLTU]    = match(getir_buyruk_i, `MASK_SLTU, `MATCH_SLTU) && coz_aktif_w;
    assign buyruk[`XORI]    = match(getir_buyruk_i, `MASK_XORI, `MATCH_XORI) && coz_aktif_w;
    assign buyruk[`ANDI]    = match(getir_buyruk_i, `MASK_ANDI, `MATCH_ANDI) && coz_aktif_w;
    assign buyruk[`SRLI]    = match(getir_buyruk_i, `MASK_SRLI, `MATCH_SRLI) && coz_aktif_w;
    assign buyruk[`SRAI]    = match(getir_buyruk_i, `MASK_SRAI, `MATCH_SRAI) && coz_aktif_w;
    assign buyruk[`FENCE_I] = match(getir_buyruk_i, `MASK_FENCE_I, `MATCH_FENCE_I) && coz_aktif_w;
    assign buyruk[`CSRRC]   = match(getir_buyruk_i, `MASK_CSRRC, `MATCH_CSRRC) && coz_aktif_w;
    assign buyruk[`CSRRCI]  = match(getir_buyruk_i, `MASK_CSRRCI, `MATCH_CSRRCI) && coz_aktif_w;
    assign buyruk[`EBREAK]  = match(getir_buyruk_i, `MASK_EBREAK, `MATCH_EBREAK) && coz_aktif_w;
    assign buyruk[`LB]      = match(getir_buyruk_i, `MASK_LB, `MATCH_LB) && coz_aktif_w;
    assign buyruk[`LH]      = match(getir_buyruk_i, `MASK_LH, `MATCH_LH) && coz_aktif_w;
    assign buyruk[`LBU]     = match(getir_buyruk_i, `MASK_LBU, `MATCH_LBU) && coz_aktif_w;
    assign buyruk[`LHU]     = match(getir_buyruk_i, `MASK_LHU, `MATCH_LHU) && coz_aktif_w;
    assign buyruk[`SB]      = match(getir_buyruk_i, `MASK_SB, `MATCH_SB) && coz_aktif_w;
    assign buyruk[`SH]      = match(getir_buyruk_i, `MASK_SH, `MATCH_SH) && coz_aktif_w;
    assign buyruk[`BLTU]    = match(getir_buyruk_i, `MASK_BLTU, `MATCH_BLTU) && coz_aktif_w;
    assign buyruk[`BGEU]    = match(getir_buyruk_i, `MASK_BGEU, `MATCH_BGEU) && coz_aktif_w;
    assign buyruk[`SLT]     = match(getir_buyruk_i, `MASK_SLT, `MATCH_SLT) && coz_aktif_w;

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
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`S_RS1]};
    buyruk_rs2_cmb = {{27{`LOW}}, getir_buyruk_i[`S_RS2]};
    buyruk_imm_cmb = {{21{getir_buyruk_i[`S_SIGN]}}, getir_buyruk_i[7], getir_buyruk_i[30:25], getir_buyruk_i[11:8], 1'b0};

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
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`S_RS1]};
    buyruk_rs2_cmb = {{27{`LOW}}, getir_buyruk_i[`S_RS2]};
    buyruk_imm_cmb = {{21{getir_buyruk_i[`S_SIGN]}}, getir_buyruk_i[7], getir_buyruk_i[30:25], getir_buyruk_i[11:8], 1'b0};

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
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`S_RS1]};
    buyruk_rs2_cmb = {{27{`LOW}}, getir_buyruk_i[`S_RS2]};
    buyruk_imm_cmb = {{21{getir_buyruk_i[`S_SIGN]}}, getir_buyruk_i[7], getir_buyruk_i[30:25], getir_buyruk_i[11:8], 1'b0};

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
    buyruk_rd_cmb = {{27{`LOW}}, getir_buyruk_i[`I_RD]};
    buyruk_imm_cmb = {{20{getir_buyruk_i[`I_SIGN]}}, getir_buyruk_i[`I_IMM]};

    buyruk_etiket_gecerli_cmb = `HIGH;

    uop_ns[`UOP_RD_ADDR] = buyruk_rd_cmb;
    uop_ns[`UOP_RD_ALLOC] = `HIGH;
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
    buyruk_imm_cmb = {{20{getir_buyruk_i[`LOW]}}, getir_buyruk_i[`I_IMM]};

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
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`S_RS1]};
    buyruk_rs2_cmb = {{27{`LOW}}, getir_buyruk_i[`S_RS2]};
    buyruk_imm_cmb = {{21{getir_buyruk_i[`S_SIGN]}}, getir_buyruk_i[7], getir_buyruk_i[30:25], getir_buyruk_i[11:8], 1'b0};

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
    buyruk_rs1_cmb = {{27{`LOW}}, getir_buyruk_i[`S_RS1]};
    buyruk_rs2_cmb = {{27{`LOW}}, getir_buyruk_i[`S_RS2]};
    buyruk_imm_cmb = {{21{getir_buyruk_i[`S_SIGN]}}, getir_buyruk_i[7], getir_buyruk_i[30:25], getir_buyruk_i[11:8], 1'b0};

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

task uop_nop();
begin
    uop_ns = {`UOP_BIT{1'b0}};
    // Asagidaki gibi de yapabiliriz belki
    // uop_ns[`UOP_VALID] = `HIGH;
    // uop_ns[`UOP_AMB] = `UOP_AMB_NOP;
    // uop_ns[`UOP_YAZ] = `UOP_YAZ_NOP;
    // uop_ns[`UOP_DAL] = `UOP_DAL_NOP; 
    // uop_ns[`UOP_BEL] = `UOP_BEL_NOP;
end
endtask

always @* begin
    buyruk_imm_cmb = {`VERI_BIT{1'b0}};
    buyruk_rs1_cmb = {`VERI_BIT{1'b0}};
    buyruk_rs2_cmb = {`VERI_BIT{1'b0}};
    buyruk_rd_cmb = {`YAZMAC_BIT{1'b0}};
    buyruk_csr_cmb = {`CSR_ADRES_BIT{1'b0}};
    buyruk_etiket_gecerli_cmb = `LOW;
    uop_ns = {`UOP_BIT{`LOW}};
    buyruk_etiket_ns = buyruk_etiket_r;

    uop_ns[`UOP_PC] = getir_ps_i;
    uop_ns[`UOP_TAG] = buyruk_etiket_r;
    uop_ns[`UOP_VALID] = coz_aktif_w;
    uop_ns[`UOP_TAKEN] = getir_atladi_i;

    case (buyruk)
    CASE_LUI     : uop_rv32lui();
    CASE_AUIPC   : uop_rv32auipc();
    CASE_JALR    : uop_rv32jalr();
    CASE_JAL     : uop_rv32jal();
    CASE_BEQ     : uop_rv32beq();
    CASE_BNE     : uop_rv32bne();
    CASE_BGE     : uop_rv32bge();
    CASE_BLT     : uop_rv32blt();
    CASE_LW      : uop_rv32lw();
    CASE_SW      : uop_rv32sw();
    CASE_ADD     : uop_rv32add();
    CASE_ADDI    : uop_rv32addi();
    CASE_SUB     : uop_rv32sub();
    CASE_OR      : uop_rv32or();
    CASE_ORI     : uop_rv32ori();
    CASE_AND     : uop_rv32and();
    CASE_XOR     : uop_rv32xor();
    CASE_SLLI    : uop_rv32slli();
    CASE_CSRRW   : uop_rv32csrrw();
    CASE_CSRRWI  : uop_rv32csrrwi();
    CASE_CSRRS   : uop_rv32csrrs();
    CASE_CSRRSI  : uop_rv32csrrsi();
    CASE_FENCE   : uop_nop();
    CASE_ECALL   : uop_nop();
    CASE_MRET    : uop_rv32mret();
    CASE_SLT     : uop_rv32slt();
    CASE_SLTI    : uop_rv32slti();
    CASE_SLTU    : uop_rv32sltu();
    CASE_XORI    : uop_rv32xori();
    CASE_ANDI    : uop_rv32andi();
    CASE_SRLI    : uop_rv32srli();
    CASE_SRAI    : uop_rv32srai();
    CASE_FENCE_I : uop_nop();
    CASE_CSRRC   : uop_rv32csrrc();
    CASE_CSRRCI  : uop_rv32csrrci();
    CASE_EBREAK  : uop_nop();
    CASE_LB      : uop_rv32lb();
    CASE_LH      : uop_rv32lh();
    CASE_LBU     : uop_rv32lbu();
    CASE_LHU     : uop_rv32lhu();
    CASE_SB      : uop_rv32sb();
    CASE_SH      : uop_rv32sh();   
    default      : uop_nop();
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