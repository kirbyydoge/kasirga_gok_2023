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
    output                          yo_gecerli_o
);

reg     [`VERI_BIT-1:0]         yo_veri_r;
reg     [`VERI_BIT-1:0]         yo_veri_ns;

reg     [`YAZMAC_BIT-1:0]       yo_adres_r;
reg     [`YAZMAC_BIT-1:0]       yo_adres_ns;

reg     [`UOP_TAG_BIT-1:0]      yo_etiket_r;
reg     [`UOP_TAG_BIT-1:0]      yo_etiket_ns;

reg                             yo_gecerli_r;
reg                             yo_gecerli_ns;

wire                            uop_bellek_gecerli_w;
wire    [`VERI_BIT-1:0]         uop_bellek_veri_w;
wire                            uop_bellek_veri_gecerli_w;
wire    [`YAZMAC_BIT-1:0]       uop_bellek_adres_w;
wire    [`UOP_TAG_BIT-1:0]      uop_bellek_etiket_w;

always @* begin
    yo_gecerli_ns = uop_bellek_gecerli_w && uop_bellek_veri_gecerli_w;
    yo_veri_ns = uop_bellek_veri_w;
    yo_adres_ns = uop_bellek_adres_w;
    yo_etiket_ns = uop_bellek_etiket_w;
end

always @(posedge clk_i) begin
    if (!rstn_i) begin
        yo_gecerli_r <= `LOW;
        yo_veri_r <= {`VERI_BIT{1'b0}};
        yo_adres_r <= {`YAZMAC_BIT{1'b0}};
        yo_etiket_r <= {`UOP_TAG_BIT{1'b0}};
    end
    else begin
        yo_gecerli_r <= yo_gecerli_ns;
        yo_veri_r <= yo_veri_ns;
        yo_adres_r <= yo_adres_ns;
        yo_etiket_r <= yo_etiket_ns;
    end
end

assign uop_bellek_gecerli_w = bellek_uop_i[`UOP_VALID];
assign uop_bellek_veri_w = bellek_uop_i[`UOP_RD];
assign uop_bellek_veri_gecerli_w = bellek_uop_i[`UOP_RD_ALLOC];
assign uop_bellek_adres_w = bellek_uop_i[`UOP_RD_ADDR];
assign uop_bellek_etiket_w = bellek_uop_i[`UOP_TAG];

endmodule