`timescale 1ns/1ps

`include "sabitler.vh"
`include "mikroislem.vh"

module yurut (
    input                           clk_i,
    input                           rstn_i,

    input                           cek_bosalt_i,
    input                           cek_duraklat_i,
    output                          duraklat_o,
    output                          bosalt_o,

    output  [`PS_BIT-1:0]           ddb_odd_ps_o,
    output  [`EXC_CODE_BIT-1:0]     ddb_odd_kod_o,
    output  [`MXLEN-1:0]            ddb_odd_bilgi_o,
    output                          ddb_odd_gecerli_o,
    
    // Hatali dallanma
    output  [`PS_BIT-1:0]           g1_ps_o,
    output                          g1_ps_gecerli_o,

    // Dallanma geri bildirimi
    output  [`PS_BIT-1:0]           g2_ps_o,
    output                          g2_guncelle_o,
    output                          g2_atladi_o,
    output                          g2_hatali_tahmin_o,

    input   [`UOP_BIT-1:0]          yurut_uop_i,
    output  [`UOP_BIT-1:0]          bellek_uop_o
);

reg  [`UOP_BIT-1:0]             uop_r;
reg  [`UOP_BIT-1:0]             uop_ns;

wire                            uop_gecerli_w;
wire [`UOP_PC_BIT-1:0]          uop_ps_w;
wire [`UOP_TAG_BIT-1:0]         uop_tag_w;
wire                            uop_taken_w;
wire [`UOP_AMB_OP1_BIT-1:0]     uop_amb_islec1_sec_w;
wire [`UOP_AMB_OP2_BIT-1:0]     uop_amb_islec2_sec_w;
wire [`UOP_RS1_BIT-1:0]         uop_rs1_w;
wire [`UOP_RS2_BIT-1:0]         uop_rs2_w;
wire [`UOP_IMM_BIT-1:0]         uop_imm_w;
wire [`UOP_CSR_BIT-1:0]         uop_csr_w;

wire [`UOP_DAL_BIT-1:0]         uop_dal_islem_sec_w;
wire [`UOP_AMB_BIT-1:0]         uop_amb_islem_sec_w;
wire [`UOP_CSR_OP_BIT-1:0]      uop_csr_islem_sec_w;
wire [`UOP_YAZ_BIT-1:0]         uop_yaz_sec_w;

wire [`VERI_BIT-1:0]            amb_islec1_w;
wire [`VERI_BIT-1:0]            amb_islec2_w;
wire                            amb_esittir_w;
wire                            amb_kucuktur_w;
wire                            amb_kucuktur_isaretsiz_w;
wire [`VERI_BIT-1:0]            amb_sonuc_w;
wire                            amb_gecerli_w;

wire [`UOP_YZB_BIT-1:0]         uop_yzb_islem_sec_w;
wire [`VERI_BIT-1:0]            yzb_islec1_w;
wire [`VERI_BIT-1:0]            yzb_islec2_w;
wire [`VERI_BIT-1:0]            yzb_sonuc_w;
wire                            yzb_gecerli_w;

wire [`PS_BIT-1:0]              db_g1_ps_w;
wire                            db_g1_ps_gecerli_w;
wire [`PS_BIT-1:0]              db_g2_ps_w;
wire                            db_g2_guncelle_w;
wire                            db_g2_atladi_w;
wire                            db_g2_hatali_tahmin_w;
wire [`PS_BIT-1:0]              db_ps_atlamadi_w;

reg                             duraklat_cmb;
reg                             bosalt_cmb;

reg  [`PS_BIT-1:0]              ddb_odd_ps_cmb;
reg  [`EXC_CODE_BIT-1:0]        ddb_odd_kod_cmb;
reg  [`MXLEN-1:0]               ddb_odd_bilgi_cmb;
reg                             ddb_odd_gecerli_cmb;

function [`VERI_BIT-1:0] islec_sec (
    input [`UOP_AMB_OP_BIT-1:0] uop_secici,
    input [`VERI_BIT-1:0]       uop_rs1_w,
    input [`VERI_BIT-1:0]       uop_rs2_w,
    input [`VERI_BIT-1:0]       uop_imm_w,
    input [`VERI_BIT-1:0]       uop_csr_w,
    input [`PS_BIT-1:0]         uop_ps_w
);
begin
    islec_sec = {`VERI_BIT{1'b0}};
    case(uop_secici)
    `UOP_AMB_OP_NOP: islec_sec = {`VERI_BIT{1'b0}};
    `UOP_AMB_OP_RS1: islec_sec = uop_rs1_w;
    `UOP_AMB_OP_RS2: islec_sec = uop_rs2_w;
    `UOP_AMB_OP_IMM: islec_sec = uop_imm_w;
    `UOP_AMB_OP_CSR: islec_sec = uop_csr_w;
    `UOP_AMB_OP_PC : islec_sec = uop_ps_w;
    endcase
end
endfunction

always @* begin
    uop_ns = yurut_uop_i;
    bosalt_cmb = `LOW;
    duraklat_cmb = `LOW; 
    ddb_odd_ps_cmb = uop_ps_w;
    ddb_odd_kod_cmb = yurut_uop_i[`UOP_CSR_OP];
    ddb_odd_bilgi_cmb = {`MXLEN{1'b0}}; // mcause
    ddb_odd_gecerli_cmb = `LOW;
    uop_ns[`UOP_RD] = amb_sonuc_w;

    case(uop_yaz_sec_w) 
    `UOP_YAZ_AMB: uop_ns[`UOP_RD] = amb_sonuc_w;
    `UOP_YAZ_IS1: uop_ns[`UOP_RD] = amb_islec1_w;
    `UOP_YAZ_DAL: uop_ns[`UOP_RD] = db_ps_atlamadi_w;
    `UOP_YAZ_CSR: uop_ns[`UOP_RD] = uop_csr_w;
    `UOP_YAZ_BEL: uop_ns[`UOP_RD] = amb_sonuc_w;
    `UOP_YAZ_YZB: uop_ns[`UOP_RD] = yzb_sonuc_w;
    default     : uop_ns[`UOP_RD] = amb_sonuc_w;
    endcase

    case(uop_csr_islem_sec_w)
    `UOP_CSR_NOP: uop_ns[`UOP_CSR] = {`VERI_BIT{1'b0}};
    `UOP_CSR_RW: uop_ns[`UOP_CSR] = uop_rs1_w;
    `UOP_CSR_RS: uop_ns[`UOP_CSR] = amb_sonuc_w;
    `UOP_CSR_MRET: begin
        ddb_odd_gecerli_cmb = `HIGH; 
        ddb_odd_kod_cmb = `EXC_CODE_MRET;
    end
    endcase

    duraklat_cmb = !amb_gecerli_w || !yzb_gecerli_w;
    bosalt_cmb = db_g2_hatali_tahmin_w;

    uop_ns[`UOP_VALID] = uop_gecerli_w && !duraklat_cmb;
    if (cek_duraklat_i) begin
        uop_ns = uop_r;
    end
end

always @(posedge clk_i) begin
    if (!rstn_i) begin
        uop_r <= {`UOP_BIT{`LOW}};
    end
    else begin
        uop_r <= uop_ns;
    end
end

amb amb (
    .clk_i                          ( clk_i ),
    .rstn_i                         ( rstn_i ),
    .islem_kod_i                    ( uop_amb_islem_sec_w ),
    .islem_islec1_i                 ( amb_islec1_w ),
    .islem_islec2_i                 ( amb_islec2_w ),
    .islem_esittir_o                ( amb_esittir_w ),
    .islem_kucuktur_o               ( amb_kucuktur_w ),
    .islem_kucuktur_isaretsiz_o     ( amb_kucuktur_isaretsiz_w ),
    .islem_sonuc_o                  ( amb_sonuc_w ),
    .islem_gecerli_o                ( amb_gecerli_w )
);

dallanma_birimi db (
    .islem_kod_i                    ( uop_dal_islem_sec_w ),
    .islem_ps_i                     ( uop_ps_w ),
    .islem_atladi_i                 ( uop_taken_w ),
    .islem_anlik_i                  ( uop_imm_w ),
    .amb_esittir_i                  ( amb_esittir_w ),
    .amb_kucuktur_i                 ( amb_kucuktur_w ),
    .amb_kucuktur_isaretsiz_i       ( amb_kucuktur_isaretsiz_w ),
    .g1_ps_o                        ( db_g1_ps_w ),
    .g1_ps_gecerli_o                ( db_g1_ps_gecerli_w ),
    .g2_ps_o                        ( db_g2_ps_w ),
    .g2_guncelle_o                  ( db_g2_guncelle_w ),
    .g2_atladi_o                    ( db_g2_atladi_w ),
    .g2_hatali_tahmin_o             ( db_g2_hatali_tahmin_w ),
    .ps_atlamadi_o                  ( db_ps_atlamadi_w )
);

yapay_zeka_birimi yzb (
    .clk_i                          ( clk_i ),
    .rstn_i                         ( rstn_i ),
    .islem_kod_i                    ( uop_yzb_islem_sec_w ),
    .islem_islec1_i                 ( yzb_islec1_w ),
    .islem_islec2_i                 ( yzb_islec2_w ),
    .islem_sonuc_o                  ( yzb_sonuc_w ),
    .islem_gecerli_o                ( yzb_gecerli_w )
);

assign uop_gecerli_w = yurut_uop_i[`UOP_VALID];
assign uop_ps_w = yurut_uop_i[`UOP_PC];
assign uop_tag_w = yurut_uop_i[`UOP_TAG];
assign uop_taken_w = yurut_uop_i[`UOP_TAKEN];
assign uop_amb_islec1_sec_w = yurut_uop_i[`UOP_AMB_OP1];
assign uop_amb_islec2_sec_w = yurut_uop_i[`UOP_AMB_OP2];
assign uop_rs1_w = yurut_uop_i[`UOP_RS1];
assign uop_rs2_w = yurut_uop_i[`UOP_RS2];
assign uop_imm_w = yurut_uop_i[`UOP_IMM];
assign uop_csr_w = yurut_uop_i[`UOP_CSR];

assign uop_amb_islem_sec_w = yurut_uop_i[`UOP_AMB];
assign uop_dal_islem_sec_w = yurut_uop_i[`UOP_DAL];
assign uop_csr_islem_sec_w = yurut_uop_i[`UOP_CSR_OP];
assign uop_yaz_sec_w = yurut_uop_i[`UOP_YAZ];
assign uop_yzb_islem_sec_w = yurut_uop_i[`UOP_YZB];

assign amb_islec1_w = islec_sec(uop_amb_islec1_sec_w, uop_rs1_w, uop_rs2_w, uop_imm_w, uop_csr_w, uop_ps_w);
assign amb_islec2_w = islec_sec(uop_amb_islec2_sec_w, uop_rs1_w, uop_rs2_w, uop_imm_w, uop_csr_w, uop_ps_w);

assign yzb_islec1_w = uop_rs1_w;
assign yzb_islec2_w = uop_rs2_w;

assign bosalt_o = bosalt_cmb && uop_gecerli_w;
assign duraklat_o = duraklat_cmb && uop_gecerli_w;

assign g1_ps_o = db_g1_ps_w;
assign g1_ps_gecerli_o = db_g1_ps_gecerli_w && uop_gecerli_w;
assign g2_ps_o = db_g2_ps_w;
assign g2_guncelle_o = db_g2_guncelle_w && uop_gecerli_w;
assign g2_atladi_o = db_g2_atladi_w;
assign g2_hatali_tahmin_o = db_g2_hatali_tahmin_w;

assign ddb_odd_ps_o = ddb_odd_ps_cmb;
assign ddb_odd_kod_o = ddb_odd_kod_cmb;
assign ddb_odd_bilgi_o = ddb_odd_bilgi_cmb;
assign ddb_odd_gecerli_o = ddb_odd_gecerli_cmb;

assign bellek_uop_o = uop_r;

endmodule