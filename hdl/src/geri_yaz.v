`timescale 1ns/1ps

`include "sabitler.vh"
`include "mikroislem.vh"

module geri_yaz (
    input                           clk_i,
    input                           rstn_i,

    input   [`UOP_BIT-1:0]          gy_uop_i,

    output  [`VERI_BIT-1:0]         yo_veri_o,
    output  [`YAZMAC_BIT-1:0]       yo_adres_o,
    output  [`UOP_TAG_BIT-1:0]      yo_etiket_o,
    output                          yo_gecerli_o,

    output  [`VERI_BIT-1:0]         csr_veri_o,
    output  [`CSR_ADRES_BIT-1:0]    csr_adres_o,
    output  [`UOP_TAG_BIT-1:0]      csr_etiket_o,
    output                          csr_gecerli_o
);

// DEBUG
wire    [`PS_BIT-1:0]           uop_ps_w;
wire                            uop_gecerli_w;
// DEBUG

wire                            uop_gy_gecerli_w;
wire    [`VERI_BIT-1:0]         uop_gy_veri_w;
wire                            uop_gy_veri_gecerli_w;
wire    [`YAZMAC_BIT-1:0]       uop_gy_adres_w;
wire    [`UOP_TAG_BIT-1:0]      uop_gy_etiket_w;

wire    [`VERI_BIT-1:0]         uop_gy_csr_veri_w;
wire                            uop_gy_csr_veri_gecerli_w;
wire    [`CSR_ADRES_BIT-1:0]    uop_gy_csr_adres_w;

assign uop_gecerli_w = gy_uop_i[`UOP_VALID];
assign uop_ps_w = gy_uop_i[`UOP_PC];

assign uop_gy_gecerli_w = gy_uop_i[`UOP_VALID];
assign uop_gy_veri_w = gy_uop_i[`UOP_RD];
assign uop_gy_veri_gecerli_w = gy_uop_i[`UOP_RD_ALLOC];
assign uop_gy_adres_w = gy_uop_i[`UOP_RD_ADDR];
assign uop_gy_etiket_w = gy_uop_i[`UOP_TAG];

assign uop_gy_csr_veri_w = gy_uop_i[`UOP_CSR];
assign uop_gy_csr_veri_gecerli_w = gy_uop_i[`UOP_CSR_ALLOC];
assign uop_gy_csr_adres_w = gy_uop_i[`UOP_CSR_ADDR];

assign yo_gecerli_o = uop_gy_gecerli_w && uop_gy_veri_gecerli_w;
assign yo_veri_o = uop_gy_veri_w;
assign yo_adres_o = uop_gy_adres_w;
assign yo_etiket_o = uop_gy_etiket_w;

assign csr_gecerli_o = uop_gy_gecerli_w && uop_gy_csr_veri_gecerli_w;
assign csr_veri_o = uop_gy_csr_veri_w;
assign csr_adres_o = uop_gy_csr_adres_w;
assign csr_etiket_o = uop_gy_etiket_w;

reg [31:0] inst_ctr_r;
always @(posedge clk_i) begin
    if (uop_gy_gecerli_w) begin
        inst_ctr_r <= inst_ctr_r + 1;
    `ifdef LOG_COMMITS
        if (uop_gy_veri_gecerli_w) begin
            $display("core   0: 3 0x%08x (0x0000) x%2d 0x%08x", uop_ps_w, uop_gy_adres_w, uop_gy_veri_w);
        end
        else begin
            $display("core   0: 3 0x%08x (0x0000)", uop_ps_w);
        end
    `endif
    end

    if (!rstn_i) begin
        inst_ctr_r <= 0;
    end
end
// Simdilik 2 kere registerlamaya gerek yok. Direkt UOP yazmaclarindan combinational gitmeli.

// reg     [`VERI_BIT-1:0]         yo_veri_r;
// reg     [`VERI_BIT-1:0]         yo_veri_ns;

// reg     [`YAZMAC_BIT-1:0]       yo_adres_r;
// reg     [`YAZMAC_BIT-1:0]       yo_adres_ns;

// reg     [`UOP_TAG_BIT-1:0]      yo_etiket_r;
// reg     [`UOP_TAG_BIT-1:0]      yo_etiket_ns;

// reg                             yo_gecerli_r;
// reg                             yo_gecerli_ns;

// reg     [`VERI_BIT-1:0]         csr_veri_r;
// reg     [`VERI_BIT-1:0]         csr_veri_ns;

// reg     [`CSR_ADRES_BIT-1:0]    csr_adres_r;
// reg     [`CSR_ADRES_BIT-1:0]    csr_adres_ns;

// reg     [`UOP_TAG_BIT-1:0]      csr_etiket_r;
// reg     [`UOP_TAG_BIT-1:0]      csr_etiket_ns;

// reg                             csr_gecerli_r;
// reg                             csr_gecerli_ns;

// always @* begin
//     yo_gecerli_ns = uop_gy_gecerli_w && uop_gy_veri_gecerli_w;
//     yo_veri_ns = uop_gy_veri_w;
//     yo_adres_ns = uop_gy_adres_w;
//     yo_etiket_ns = uop_gy_etiket_w;

//     csr_gecerli_ns = uop_gy_gecerli_w && uop_gy_csr_veri_gecerli_w;
//     csr_veri_ns = uop_gy_csr_veri_w;
//     csr_adres_ns = uop_gy_csr_adres_w;
//     csr_etiket_ns = uop_gy_etiket_w;
// end

// always @(posedge clk_i) begin
//     if (!rstn_i) begin
//         yo_gecerli_r <= `LOW;
//         yo_veri_r <= {`VERI_BIT{1'b0}};
//         yo_adres_r <= {`YAZMAC_BIT{1'b0}};
//         yo_etiket_r <= {`UOP_TAG_BIT{1'b0}};
//         csr_gecerli_r <= `LOW;
//         csr_veri_r <= {`VERI_BIT{1'b0}};
//         csr_adres_r <= {`YAZMAC_BIT{1'b0}};
//         csr_etiket_r <= {`UOP_TAG_BIT{1'b0}};
//     end
//     else begin
//         yo_gecerli_r <= yo_gecerli_ns;
//         yo_veri_r <= yo_veri_ns;
//         yo_adres_r <= yo_adres_ns;
//         yo_etiket_r <= yo_etiket_ns;
//         csr_gecerli_r <= csr_gecerli_ns;
//         csr_veri_r <= csr_veri_ns;
//         csr_adres_r <= csr_adres_ns;
//         csr_etiket_r <= csr_etiket_ns;
//     end
// end

endmodule