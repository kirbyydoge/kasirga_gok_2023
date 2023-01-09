`timescale 1ns/1ps

`include "csr.vh"

module denetim_durum_birimi(
    input                           clk_i,
    input                           rstn_i,

    input   [`PS_BIT-1:0]           coz_odd_ps_i,
    input   [`EXC_CODE_BIT-1:0]     coz_odd_kod_i,
    input                           coz_odd_gecerli_i,

    input   [`PS_BIT-1:0]           yurut_odd_ps_i,
    input   [`EXC_CODE_BIT-1:0]     yurut_odd_kod_i,
    input   [`MXLEN-1:0]            yurut_odd_bilgi_i,
    input                           yurut_odd_gecerli_i,

    input   [`PS_BIT-1:0]           bellek_odd_ps_i,
    input   [`EXC_CODE_BIT-1:0]     bellek_odd_kod_i,
    input                           bellek_odd_gecerli_i,

    input   [`CSR_ADRES_BIT-1:0]    oku_istek_adres_i,
    input                           oku_istek_gecerli_i,

    input   [`MXLEN-1:0]            yaz_istek_veri_i,
    input   [`CSR_ADRES_BIT-1:0]    yaz_istek_adres_i,
    input                           yaz_istek_gecerli_i,

    output  [`MXLEN-1:0]            csr_veri_o,
    output                          csr_gecerli_o,

    output  [`PS_BIT-1:0]           getir_ps_o,
    output                          getir_ps_gecerli_o
);

reg     [`MXLEN-1:0]            csr_r [0:`CSR_ARCH_N_REGS-1];
reg     [`MXLEN-1:0]            csr_ns [0:`CSR_ARCH_N_REGS-1];

reg     [`MXLEN-1:0]            csr_veri_cmb;

reg                             csr_gecerli_cmb;

wire    [`CSR_ARCH_BIT-1:0]     yaz_mimari_adres_w;
wire    [`CSR_ARCH_BIT-1:0]     oku_mimari_adres_w;

reg     [`PS_BIT-1:0]           odd_ps_cmb;
reg                             odd_gecerli_cmb; 
reg     [`EXC_CODE_BIT-1:0]     odd_kod_cmb; 
reg     [`MXLEN-1:0]            odd_bilgi_cmb; 

reg     [`PS_BIT-1:0]           getir_ps_cmb;
reg     [`PS_BIT-1:0]           getir_ps_gecerli_cmb;

integer i;
task csr_init();
begin
    for (i = 0; i < `CSR_ARCH_N_REGS; i = i + 1) begin
        csr_r[i] = {`MXLEN{1'b0}};
    end

    csr_r[`CSR_MISA][`MISA_A] = `LOW;
    csr_r[`CSR_MISA][`MISA_B] = `LOW;
    csr_r[`CSR_MISA][`MISA_C] = `HIGH;
    csr_r[`CSR_MISA][`MISA_D] = `LOW;
    csr_r[`CSR_MISA][`MISA_E] = `LOW;
    csr_r[`CSR_MISA][`MISA_F] = `LOW;
    csr_r[`CSR_MISA][`MISA_G] = `LOW;
    csr_r[`CSR_MISA][`MISA_H] = `LOW;
    csr_r[`CSR_MISA][`MISA_I] = `HIGH;
    csr_r[`CSR_MISA][`MISA_J] = `LOW;
    csr_r[`CSR_MISA][`MISA_K] = `LOW;
    csr_r[`CSR_MISA][`MISA_L] = `LOW;
    csr_r[`CSR_MISA][`MISA_M] = `HIGH;
    csr_r[`CSR_MISA][`MISA_N] = `LOW;
    csr_r[`CSR_MISA][`MISA_O] = `LOW;
    csr_r[`CSR_MISA][`MISA_P] = `LOW;
    csr_r[`CSR_MISA][`MISA_Q] = `LOW;
    csr_r[`CSR_MISA][`MISA_R] = `LOW;
    csr_r[`CSR_MISA][`MISA_S] = `LOW;
    csr_r[`CSR_MISA][`MISA_T] = `LOW;
    csr_r[`CSR_MISA][`MISA_U] = `LOW;
    csr_r[`CSR_MISA][`MISA_V] = `LOW;
    csr_r[`CSR_MISA][`MISA_W] = `LOW;
    csr_r[`CSR_MISA][`MISA_X] = `HIGH;
    csr_r[`CSR_MISA][`MISA_Y] = `LOW;
    csr_r[`CSR_MISA][`MISA_Z] = `LOW;
    csr_r[`CSR_MISA][`MISA_MXL] = `MXL_32;

    csr_r[`CSR_MVENDORID] = {`MXLEN{1'b0}};
    csr_r[`CSR_MARCHID] = {`MXLEN{1'b0}};
    csr_r[`CSR_MIMPID] = {`MXLEN{1'b0}};
    csr_r[`CSR_MHARTID] = {`MXLEN{1'b0}};
end
endtask;

task odd_sec();
begin
    odd_gecerli_cmb = bellek_odd_gecerli_i || yurut_odd_gecerli_i || coz_odd_gecerli_i;
    odd_kod_cmb = {`EXC_CODE_BIT{1'b0}};
    odd_ps_cmb = {`PS_BIT{1'b0}};
    odd_bilgi_cmb = {`MXLEN{1'b0}};

    if (bellek_odd_gecerli_i) begin
        odd_ps_cmb = bellek_odd_ps_i;
        odd_kod_cmb = bellek_odd_kod_i;
    end
    else if (yurut_odd_gecerli_i) begin
        odd_ps_cmb = yurut_odd_ps_i;
        odd_kod_cmb = yurut_odd_kod_i;
        odd_bilgi_cmb = yurut_odd_bilgi_i;
    end
    else if (coz_odd_gecerli_i) begin
        odd_ps_cmb = coz_odd_ps_i;
        odd_kod_cmb = coz_odd_kod_i;
    end
end
endtask

initial begin
    csr_init();
end

always @* begin
    for (i = 0; i < `CSR_ARCH_N_REGS; i = i + 1) begin
        csr_ns[i] = csr_r[i];
    end
    csr_gecerli_cmb = `LOW;
    getir_ps_cmb = {`PS_BIT{1'b0}};
    getir_ps_gecerli_cmb = `LOW;

    odd_sec();
    
    if (odd_gecerli_cmb) begin
        csr_ns[`CSR_MEPC] = odd_ps_cmb;
        csr_ns[`CSR_MSTATUS][`MSTATUS_MIE] = csr_r[`CSR_MSTATUS][`MSTATUS_MPIE];
        csr_ns[`CSR_MSTATUS][`MSTATUS_MPIE] = `HIGH;
        csr_ns[`CSR_MSTATUS][`MSTATUS_MPP] = `PRIV_MACHINE;
        csr_ns[`CSR_MCAUSE] = odd_kod_cmb;
        csr_ns[`CSR_MTVAL] = odd_bilgi_cmb;

        getir_ps_cmb = csr_r[`CSR_MTVEC];
        getir_ps_gecerli_cmb = `HIGH;

        case(odd_kod_cmb)
        `EXC_CODE_MRET: begin
            getir_ps_cmb = csr_r[`CSR_MEPC];
        end
        endcase
    end

    // TODO: Yetki kontrolleri
    if (oku_istek_gecerli_i) begin
        csr_gecerli_cmb = `HIGH;
        csr_veri_cmb = csr_r[oku_mimari_adres_w];
    end

    // TODO: Yetki ve alan izin kontrolleri
    if (yaz_istek_gecerli_i) begin
        csr_ns[yaz_mimari_adres_w] = yaz_istek_veri_i;
    end
end

always @(posedge clk_i) begin
    if (!rstn_i) begin
        csr_init();
    end
    else begin
        for (i = 0; i < `CSR_N_REGS; i = i + 1) begin
            csr_r[i] <= csr_ns[i];
        end
    end
end

assign oku_mimari_adres_w = csr_adres_donustur(oku_istek_adres_i);
assign yaz_mimari_adres_w = csr_adres_donustur(yaz_istek_adres_i);

assign getir_ps_o = getir_ps_cmb;
assign getir_ps_gecerli_o = getir_ps_gecerli_cmb;

endmodule