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

reg [`UOP_BIT-1:0]              uop_r;
reg [`UOP_BIT-1:0]              uop_ns;

wire                            uop_gecerli_w;
wire [`UOP_PC_BIT-1:0]          uop_ps_w;
wire [`UOP_TAG_BIT-1:0]         uop_tag_w;
wire                            uop_taken_w;
wire [`UOP_AMB_OP1_BIT-1:0]     uop_amb_islec1_sec_w;
wire [`UOP_AMB_OP2_BIT-1:0]     uop_amb_islec2_sec_w;
wire [`UOP_RS2_BIT-1:0]         uop_rs1_w;
wire [`UOP_RS1_BIT-1:0]         uop_rs2_w;
wire [`UOP_IMM_BIT-1:0]         uop_imm_w;
wire [`UOP_CSR_BIT-1:0]         uop_csr_w;

wire [`UOP_DAL_BIT-1:0]         uop_dal_islem_sec_w;
wire [`UOP_AMB_BIT-1:0]         uop_amb_islem_sec_w;
wire [`UOP_CSR_OP_BIT-1:0]      uop_csr_islem_sec_w;
wire [`UOP_YAZ_BIT-1:0]         uop_yaz_sec_w;

wire [`VERI_BIT-1:0]            amb_islec1_w;
wire [`VERI_BIT-1:0]            amb_islec2_w;
wire                            amb_esittir_w;
wire                            amb_buyuktur_w;
wire [`VERI_BIT-1:0]            amb_sonuc_w;

reg                             duraklat_cmb;
reg                             bosalt_cmb;

reg  [`PS_BIT-1:0]              g1_ps_cmb;
reg                             g1_ps_gecerli_cmb;

reg  [`PS_BIT-1:0]              g2_ps_cmb;
reg                             g2_guncelle_cmb;
reg                             g2_atladi_cmb;
reg                             g2_hatali_tahmin_cmb;

function [`VERI_BIT-1:0] islec_sec (
    input [`UOP_AMB_OP_BIT-1:0] uop_secici,
    input [`VERI_BIT-1:0]       uop_rs1_w,
    input [`VERI_BIT-1:0]       uop_rs2_w,
    input [`VERI_BIT-1:0]       uop_imm_w
);
begin
    islec_sec = {`VERI_BIT{1'b0}};
    case(uop_secici)
    `UOP_AMB_OP_NOP: islec_sec = {`VERI_BIT{1'b0}};
    `UOP_AMB_OP_RS1: islec_sec = uop_rs1_w;
    `UOP_AMB_OP_RS2: islec_sec = uop_rs2_w;
    `UOP_AMB_OP_IMM: islec_sec = uop_imm_w;
    endcase
end
endfunction

// TODO: ANLIK DEGERLER GENISLETILECEKSE BUNUN MIKROISLEME EKLENMESI YA DA COZDE ARADAN HALLEDILMESI LAZIM
always @* begin
    uop_ns = yurut_uop_i;
    uop_ns[`UOP_VALID] = uop_gecerli_w; // simdilik her sey tek cevrim
    bosalt_cmb = `LOW;

    case(uop_yaz_sec_w)
    `UOP_YAZ_NOP: uop_ns[`UOP_RD] = {`VERI_BIT{1'b0}};
    `UOP_YAZ_AMB: uop_ns[`UOP_RD] = amb_sonuc_w;
    `UOP_YAZ_IS1: uop_ns[`UOP_RD] = amb_islec1_w;
    `UOP_YAZ_DAL: uop_ns[`UOP_RD] = uop_ps_w + 32'd4;   // dallanma biriminden gelmesi gerekiyor
    `UOP_YAZ_CSR: uop_ns[`UOP_RD] = uop_csr_w;
    endcase

    case(uop_csr_islem_sec_w)
    `UOP_CSR_NOP: uop_ns[`UOP_CSR] = {`VERI_BIT{1'b0}};
    `UOP_CSR_RW: uop_ns[`UOP_CSR] = uop_rs1_w;
    endcase

    case(uop_dal_islem_sec_w)
    `UOP_DAL_NOP: begin
        g1_ps_cmb = {`PS_BIT{1'b0}};
        g1_ps_gecerli_cmb = `LOW;
        g2_ps_cmb = {`PS_BIT{1'b0}};
        g2_guncelle_cmb = `LOW;
        g2_atladi_cmb = `LOW;
        g2_hatali_tahmin_cmb = `LOW;
    end
    `UOP_DAL_BNE: begin
        g2_ps_cmb = uop_ps_w;
        g2_guncelle_cmb = `HIGH;
        g2_atladi_cmb = !amb_esittir_w;
        g2_hatali_tahmin_cmb = !(amb_esittir_w ^ uop_taken_w);
        bosalt_cmb = !(amb_esittir_w ^ uop_taken_w);

        g1_ps_gecerli_cmb = g2_hatali_tahmin_cmb;
        if (g2_atladi_cmb) begin
            g1_ps_cmb = uop_ps_w + uop_imm_w;
        end
        else begin
            g1_ps_cmb = uop_ps_w + 32'd4;
        end
    end
    default: begin
        g1_ps_cmb = {`PS_BIT{1'b0}};
        g1_ps_gecerli_cmb = `LOW;
        g2_ps_cmb = {`PS_BIT{1'b0}};
        g2_guncelle_cmb = `LOW;
        g2_atladi_cmb = `LOW;
        g2_hatali_tahmin_cmb = `LOW;
    end
    endcase
    
    duraklat_cmb = `LOW; // asla duraklatma

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
    .clk_i             ( clk_i               ),
    .islem_kod_i       ( uop_amb_islem_sec_w ),
    .islem_islec1_i    ( amb_islec1_w        ),
    .islem_islec2_i    ( amb_islec2_w        ),
    .islem_esittir_o   ( amb_esittir_w       ),
    .islem_buyuktur_o  ( amb_buyuktur_w      ),
    .islem_sonuc_o     ( amb_sonuc_w         )
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

assign amb_islec1_w = islec_sec(uop_amb_islec1_sec_w, uop_rs1_w, uop_rs2_w, uop_imm_w);
assign amb_islec2_w = islec_sec(uop_amb_islec2_sec_w, uop_rs1_w, uop_rs2_w, uop_imm_w);

assign bosalt_o = bosalt_cmb && uop_gecerli_w;
assign duraklat_o = `LOW && uop_gecerli_w;

assign g1_ps_o = g1_ps_cmb;
assign g1_ps_gecerli_o = g1_ps_gecerli_cmb && uop_gecerli_w;
assign g2_ps_o = g2_ps_cmb;
assign g2_guncelle_o = g2_guncelle_cmb && uop_gecerli_w;
assign g2_atladi_o = g2_atladi_cmb;
assign g2_hatali_tahmin_o = g2_hatali_tahmin_cmb;

assign bellek_uop_o = uop_r;

endmodule