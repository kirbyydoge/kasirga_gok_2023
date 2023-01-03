`timescale 1ns / 1ps

`include "sabitler.vh"
`include "mikroislem.vh"
`include "coz.vh"
`include "opcode.vh"

module coz(
    input                           clk_i,
    input                           rst_i,

    input                           bosalt_i,
    output                          duraklat_o,

    output                          gecersiz_buyruk_o,
    
    input   [`PS_BIT-1:0]           getir_buyruk_i,
    input   [`PS_BIT-1:0]           getir_ps_i,
    input                           getir_gecerli_i,

    input   [`VERI_BIT-1:0]         geriyaz_veri_i,
    input   [`YAZMAC_BIT-1:0]       geriyaz_adres_i,
    input   [`UOP_TAG_BIT-1:0]      geriyaz_etiket_i,
    input                           geriyaz_gecerli_i,

    output  [`UOP_BIT-1:0]          yurut_uop_o
);

wire [14:0] buyruk;

generate
    assign buyruk[`LUI]   = match(getir_buyruk_i, `MASK_LUI, `MATCH_LUI) && coz_aktif_w;
    assign buyruk[`AUIPC] = match(getir_buyruk_i, `MASK_AUIPC, `MATCH_AUIPC) && coz_aktif_w;
    assign buyruk[`JALR]  = match(getir_buyruk_i, `MASK_JALR, `MATCH_JALR) && coz_aktif_w;
    assign buyruk[`JAL]   = match(getir_buyruk_i, `MASK_JAL, `MATCH_JAL) && coz_aktif_w;
    assign buyruk[`BEQ]   = match(getir_buyruk_i, `MASK_BEQ, `MATCH_BEQ) && coz_aktif_w;
    assign buyruk[`BNE]   = match(getir_buyruk_i, `MASK_BNE, `MATCH_BNE) && coz_aktif_w;
    assign buyruk[`BLT]   = match(getir_buyruk_i, `MASK_BLT, `MATCH_BLT) && coz_aktif_w;
    assign buyruk[`LW]    = match(getir_buyruk_i, `MASK_LW, `MATCH_LW) && coz_aktif_w;
    assign buyruk[`SW]    = match(getir_buyruk_i, `MASK_SW, `MATCH_SW) && coz_aktif_w;
    assign buyruk[`ADDI]  = match(getir_buyruk_i, `MASK_ADDI, `MATCH_ADDI) && coz_aktif_w;
    assign buyruk[`ADD]   = match(getir_buyruk_i, `MASK_ADD, `MATCH_ADD) && coz_aktif_w;
    assign buyruk[`SUB]   = match(getir_buyruk_i, `MASK_SUB, `MATCH_SUB) && coz_aktif_w;
    assign buyruk[`OR]    = match(getir_buyruk_i, `MASK_OR, `MATCH_OR) && coz_aktif_w;
    assign buyruk[`AND]   = match(getir_buyruk_i, `MASK_AND, `MATCH_AND) && coz_aktif_w;
    assign buyruk[`XOR]   = match(getir_buyruk_i, `MASK_XOR, `MATCH_XOR) && coz_aktif_w;

    assign gecersiz_buyruk_o = !(|buyruk) && !coz_aktif_w;
endgenerate

localparam CASE_LUI     = 1 << `LUI;     
localparam CASE_AUIPC   = 1 << `AUIPC;         
localparam CASE_JALR    = 1 << `JALR;         
localparam CASE_JAL     = 1 << `JAL;     
localparam CASE_BEQ     = 1 << `BEQ;     
localparam CASE_BNE     = 1 << `BNE;     
localparam CASE_BLT     = 1 << `BLT;     
localparam CASE_LW      = 1 << `LW;     
localparam CASE_SW      = 1 << `SW;     
localparam CASE_ADDI    = 1 << `ADDI;         
localparam CASE_ADD     = 1 << `ADD;     
localparam CASE_SUB     = 1 << `SUB;     
localparam CASE_OR      = 1 << `OR;     
localparam CASE_AND     = 1 << `AND;     
localparam CASE_XOR     = 1 << `XOR;

wire coz_aktif_w;

reg [`VERI_BIT-1:0]     buyruk_imm_cmb;
reg [`VERI_BIT-1:0]     buyruk_rs1_cmb;
reg [`VERI_BIT-1:0]     buyruk_rs2_cmb;
reg [`VERI_BIT-1:0]     buyruk_rd_cmb;
reg [`UOP_TAG_BIT-1:0]  buyruk_etiket_gecerli_cmb;

reg [`UOP_TAG_BIT-1:0]  buyruk_etiket_r;
reg [`UOP_TAG_BIT-1:0]  buyruk_etiket_ns;

reg [`UOP_BIT-1:0]      uop_r;
reg [`UOP_BIT-1:0]      uop_ns;

task uop_genel();
begin
    uop_ns[`UOP_VALID] = coz_aktif_w;
    uop_ns[`UOP_PC] = getir_ps_i;
    uop_ns[`UOP_TAG] = buyruk_etiket_r;
end
endtask

task uop_rv32add();
begin
    buyruk_rs1_cmb = {{27{1'b0}}, getir_buyruk_i[`R_RS1]};
    buyruk_rs2_cmb = {{27{1'b0}}, getir_buyruk_i[`R_RS2]};
    buyruk_rd_cmb = {{27{1'b0}}, getir_buyruk_i[`R_RD]};

    buyruk_etiket_gecerli_cmb = 1'b1;

    uop_ns[`UOP_RS1] = buyruk_rs1_cmb;
    uop_ns[`UOP_RS2] = buyruk_rs2_cmb;
    uop_ns[`UOP_RD] = buyruk_rd_cmb;
    uop_ns[`UOP_AMB] = `UOP_AMB_ADD;
    uop_ns[`UOP_YAZ] = `UOP_YAZ_AMB;

    // Tum UOPlarin NOP'larini 0 belirlersek bu kisimlara gerek yok
    uop_ns[`UOP_DAL] = `UOP_DAL_NOP; 
    uop_ns[`UOP_BEL] = `UOP_BEL_NOP;
end
endtask

task uop_nop();
begin
    uop_ns[`UOP_VALID] = 1'b0;
    // Asagidaki gibi de yapabiliriz belki
    // uop_ns[`UOP_VALID] = 1'b1;
    // uop_ns[`UOP_AMB] = `UOP_AMB_NOP;
    // uop_ns[`UOP_YAZ] = `UOP_YAZ_NOP;
    // uop_ns[`UOP_DAL] = `UOP_DAL_NOP; 
    // uop_ns[`UOP_BEL] = `UOP_BEL_NOP;
end
endtask

task coz();
begin
    uop_genel();
    case (buyruk)
    CASE_LUI   : uop_nop();
    CASE_AUIPC : uop_nop();
    CASE_JALR  : uop_nop();
    CASE_JAL   : uop_nop();
    CASE_BEQ   : uop_nop();
    CASE_BNE   : uop_nop();
    CASE_BLT   : uop_nop();
    CASE_LW    : uop_nop();
    CASE_SW    : uop_nop();
    CASE_ADDI  : uop_nop();
    CASE_ADD   : uop_rv32add();
    CASE_SUB   : uop_nop();
    CASE_OR    : uop_nop();
    CASE_AND   : uop_nop();
    CASE_XOR   : uop_nop();
    endcase
end
endtask

always @* begin
    uop_ns = 0;
    buyruk_etiket_ns = buyruk_etiket_r;

    coz();
end

always @(posedge clk_i) begin
    if (!rst_i) begin
        uop_r <= 0;
        buyruk_etiket_r <= 0;
    end
    else begin
        uop_r <= uop_ns;
        buyruk_etiket_r <= buyruk_etiket_ns;
    end
end

assign yurut_uop_o = uop_r;
assign coz_aktif_w = getir_gecerli_i && !bosalt_i;

endmodule