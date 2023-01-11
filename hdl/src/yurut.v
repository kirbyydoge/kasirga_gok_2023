`timescale 1ns/1ps

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
wire [`UOP_AMB_BIT-1:0]         uop_amb_islem_sec_w;
wire [`UOP_AMB_OP1_BIT-1:0]     uop_amb_islec1_sec_w;
wire [`UOP_AMB_OP2_BIT-1:0]     uop_amb_islec2_sec_w;
wire [`UOP_YAZ_BIT-1:0]         uop_yaz_sec_w;
wire [`UOP_RS2_BIT-1:0]         uop_rs1_w;
wire [`UOP_RS1_BIT-1:0]         uop_rs2_w;
wire [`UOP_IMM_BIT-1:0]         uop_imm_w;

wire [`VERI_BIT-1:0]            amb_islec1_w;
wire [`VERI_BIT-1:0]            amb_islec2_w;
wire                            amb_esittir_w;
wire                            amb_buyuktur_w;
wire [`VERI_BIT-1:0]            amb_sonuc_w;

reg duraklat_cmb;

function [`VERI_BIT-1:0] islec_sec (
    input [`UOP_AMB_OP_BIT-1:0] uop_secici
);
begin
    case(uop_secici)
    `UOP_AMB_OP_NOP: islec_sec = {`VERI_BIT{1'b0}};
    `UOP_AMB_OP_RS1: islec_sec = uop_rs1_w;
    `UOP_AMB_OP_RS2: islec_sec = uop_rs2_w;
    `UOP_AMB_OP_IMM: islec_sec = uop_imm_w;
    endcase
end
endfunction

function [`VERI_BIT-1:0] kaynak_sec (
    input [`UOP_YAZ_BIT-1:0]    uop_secici
);
begin
    case(uop_secici)
    `UOP_YAZ_NOP: kaynak_sec = {`VERI_BIT{1'b0}};
    `UOP_YAZ_AMB: kaynak_sec = amb_sonuc_w;
    `UOP_YAZ_IS1: kaynak_sec = amb_islec1_w;
    `UOP_YAZ_DAL: kaynak_sec = uop_ps_w + 32'd4;   // dallanma biriminden gelmesi gerekiyor
    endcase
end
endfunction

// TODO: ANLIK DEGERLER GENISLETILECEKSE BUNUN MIKROISLEME EKLENMESI YA DA COZDE ARADAN HALLEDILMESI LAZIM
always @* begin
    uop_ns = yurut_uop_i;
    uop_ns[`UOP_VALID] = `HIGH; // simdilik her sey tek cevrim
    uop_ns[`UOP_RD] = kaynak_sec(uop_yaz_sec_w);
    duraklat_cmb = `LOW; // asla duraklatma
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
assign uop_amb_islem_sec_w = yurut_uop_i[`UOP_AMB];
assign uop_amb_islec1_sec_w = yurut_uop_i[`UOP_AMB_OP1];
assign uop_amb_islec2_sec_w = yurut_uop_i[`UOP_AMB_OP2];
assign uop_rs1_w = yurut_uop_i[`UOP_RS1];
assign uop_rs2_w = yurut_uop_i[`UOP_RS2];
assign uop_imm_w = yurut_uop_i[`UOP_IMM];
assign uop_yaz_sec_w = yurut_uop_i[`UOP_YAZ];

assign amb_islec1_w = islec_sec(uop_amb_islec1_sec_w);
assign amb_islec2_w = islec_sec(uop_amb_islec2_sec_w);

assign duraklat_o = `LOW;

assign g1_ps_o = uop_ps_w;
assign g1_ps_gecerli_o = `LOW;

assign g2_dal_ps_o = uop_ps_w;
assign g2_dal_guncelle_o = `LOW;
assign g2_dal_atladi_o = `LOW;
assign g2_dal_hatali_tahmin_o = `LOW;

endmodule