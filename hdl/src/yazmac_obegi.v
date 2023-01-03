`timescale 1ns / 1ps

// !!!GECICI YAZMAC OBEGI MODULU!!!
module yazmac_obegi (
    input               clk_i,
    input               rst_i,

    input   [4:0]       oku_adres1_i,
    input   [4:0]       oku_adres2_i,

    output  [31:0]      oku_veri1_o,
    output              oku_veri1_gecerli_o,
    output  [31:0]      oku_veri2_o,
    output              oku_veri2_gecerli_o,

    input   [31:0]      yaz_veri_i,
    input   [4:0]       yaz_adres_i,
    input   [3:0]       yaz_etiket_i,
    input               yaz_gecerli_i,

    input   [3:0]       etiket_i,
    input   [4:0]       etiket_adres_i,
    input               etiket_gecerli_i
);

reg [31:0] yazmac_ns [0:31];
reg [31:0] yazmac_r [0:31];

reg [31:0] yazmac_gecerli_ns;
reg [31:0] yazmac_gecerli_r;

reg [3:0] yazmac_etiket_ns [0:31];
reg [3:0] yazmac_etiket_r [0:31];

integer i;
always @* begin
    for (i = 0; i < 32; i = i + 1) begin
        yazmac_ns[i] = yazmac_r[i];
        yazmac_etiket_ns[i] = yazmac_etiket_r[i];
        yazmac_gecerli_ns[i] = yazmac_gecerli_r[i];
    end

    if (etiket_gecerli_i) begin
        yazmac_etiket_ns[etiket_adres_i] = etiket_i;
        yazmac_gecerli_ns[etiket_adres_i] = 1'b0;
    end

    if (yaz_gecerli_i) begin
        yazmac_ns[yaz_adres_i] = yaz_veri_i;
        yazmac_gecerli_ns[yaz_adres_i] = yazmac_etiket_r[yaz_adres_i] == yaz_etiket_i;
    end
end

always @(posedge clk_i) begin
    if (rst_i) begin
        for (i = 0; i < 32; i = i + 1) begin
            yazmac_gecerli_r[i] <= 1;
            yazmac_etiket_r[i] <= 0;
            yazmac_r[i] <= 0;
        end
    end
    else begin
        yazmac_r[0] <= 0;
        yazmac_gecerli_r[0] <= 1;

        for (i = 1; i < 32; i = i + 1) begin
            yazmac_gecerli_r[i] <= yazmac_gecerli_ns[i];
            yazmac_etiket_r[i] <= yazmac_etiket_ns[i];
            yazmac_r[i] <= yazmac_ns[i];
        end 
    end
end

assign oku_veri1_o = yazmac_r[oku_adres1_i];
assign oku_veri1_gecerli_o = yazmac_gecerli_r[oku_adres1_i];
assign oku_veri2_o = yazmac_r[oku_adres2_i];
assign oku_veri2_gecerli_o = yazmac_gecerli_r[oku_adres2_i];

endmodule