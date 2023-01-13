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

localparam CASE_LUI    = 1 << `LUI;
localparam CASE_AUIPC  = 1 << `AUIPC;
localparam CASE_JALR   = 1 << `JALR;
localparam CASE_JAL    = 1 << `JAL;
localparam CASE_BEQ    = 1 << `BEQ;
localparam CASE_BNE    = 1 << `BNE;
localparam CASE_BLT    = 1 << `BLT;
localparam CASE_LW     = 1 << `LW;
localparam CASE_SW     = 1 << `SW;
localparam CASE_ADDI   = 1 << `ADDI;
localparam CASE_ADD    = 1 << `ADD;
localparam CASE_SUB    = 1 << `SUB;
localparam CASE_OR     = 1 << `OR;
localparam CASE_AND    = 1 << `AND;
localparam CASE_XOR    = 1 << `XOR;
localparam CASE_CSRRW  = 1 << `CSRRW;
localparam CASE_CSRRS  = 1 << `CSRRS;
localparam CASE_CSRRWI = 1 << `CSRRWI;
localparam CASE_CSRRSI = 1 << `CSRRSI;
localparam CASE_FENCE  = 1 << `FENCE;
localparam CASE_ECALL  = 1 << `ECALL;
localparam CASE_MRET   = 1 << `MRET;
localparam CASE_SLLI   = 1 << `SLLI;
localparam CASE_ORI    = 1 << `ORI;
localparam CASE_BGE    = 1 << `BGE;

wire coz_aktif_w;

reg [`VERI_BIT-1:0]         buyruk_imm_cmb;
reg [`VERI_BIT-1:0]         buyruk_rs1_cmb;
reg [`VERI_BIT-1:0]         buyruk_rs2_cmb;
reg [`YAZMAC_BIT-1:0]       buyruk_rd_cmb;
reg [`CSR_ADRES_BIT-1:0]    buyruk_csr_cmb;
reg [`UOP_TAG_BIT-1:0]      buyruk_etiket_gecerli_cmb;

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

task uop_nop();
begin
    uop_ns = {`UOP_BIT{1'b0}};
    uop_ns[`UOP_VALID] = `HIGH;
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
    buyruk_etiket_gecerli_cmb = {`UOP_TAG_BIT{1'b0}};
    uop_ns = {`UOP_BIT{`LOW}};
    buyruk_etiket_ns = buyruk_etiket_r;

    uop_ns[`UOP_PC] = getir_ps_i;
    uop_ns[`UOP_TAG] = buyruk_etiket_r;
    uop_ns[`UOP_VALID] = coz_aktif_w;
    uop_ns[`UOP_TAKEN] = getir_atladi_i;

    case (buyruk)
    CASE_LUI   : uop_rv32lui();
    CASE_AUIPC : uop_rv32auipc();
    CASE_JALR  : uop_rv32jalr();
    CASE_JAL   : uop_rv32jal();
    CASE_BEQ   : uop_rv32beq();
    CASE_BNE   : uop_rv32bne();
    CASE_BGE   : uop_rv32bge();
    CASE_BLT   : uop_nop();
    CASE_LW    : uop_nop();
    CASE_SW    : uop_nop();
    CASE_ADD   : uop_rv32add();
    CASE_ADDI  : uop_rv32addi();
    CASE_SUB   : uop_nop();
    CASE_OR    : uop_rv32or();
    CASE_ORI   : uop_rv32ori();
    CASE_AND   : uop_nop();
    CASE_XOR   : uop_nop();
    CASE_SLLI  : uop_rv32slli();
    CASE_CSRRW : uop_rv32csrrw();
    CASE_CSRRWI: uop_rv32csrrwi();
    CASE_CSRRS : uop_rv32csrrs();
    CASE_CSRRSI: uop_rv32csrrsi();
    CASE_FENCE : uop_nop();
    CASE_ECALL : uop_nop();
    CASE_MRET  : uop_rv32mret();
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