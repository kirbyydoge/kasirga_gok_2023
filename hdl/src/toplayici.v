`timescale 1ns/1ps

module toplayici (
    input   [31:0]  islec0_i,
    input   [31:0]  islec1_i,
    input           carry_i,
    output  [31:0]  toplam_o,
    output          carry_o
);

reg [31:0]  g_l0;
reg [15:0]  g_l1;
reg [7:0]   g_l2;
reg [3:0]   g_l3;
reg [1:0]   g_l4;
reg         g_l5;
reg         g_l6;
reg [2:0]   g_l7;
reg [6:0]   g_l8;

reg [31:0]  p_l0;
reg [15:0]  p_l1;
reg [7:0]   p_l2;
reg [3:0]   p_l3;
reg [1:0]   p_l4;

reg [31:0]  g_final;

reg         carry_cmb;
reg [31:0]  sum_cmb;

integer i;
always @* begin
    for (i = 1; i < 32; i = i + 1) begin
        p_l0[i] = islec0_i[i] | islec1_i[i];
        g_l0[i] = islec0_i[i] & islec1_i[i];
    end
    p_l0[0] = islec0_i[0] | islec1_i[0] | carry_i;
    g_l0[0] = (islec0_i[0] & islec1_i[0]) | (islec0_i[0] & carry_i) | (islec1_i[0] & carry_i);
    for (i = 0; i < 16; i = i + 1) begin
        p_l1[i] = p_l0[2*i + 1] & p_l0[2*i];
        g_l1[i] = g_l0[2*i + 1] | (g_l0[2*i] & p_l0[2*i + 1]);
    end
    for (i = 0; i < 8; i = i + 1) begin
        p_l2[i] = p_l1[2*i + 1] & p_l1[2*i];
        g_l2[i] = g_l1[2*i + 1] | (g_l1[2*i] & p_l1[2*i + 1]);
    end
    for (i = 0; i < 4; i = i + 1) begin
        p_l3[i] = p_l2[2*i + 1] & p_l2[2*i];
        g_l3[i] = g_l2[2*i + 1] | (g_l2[2*i] & p_l2[2*i + 1]);
    end
    for (i = 0; i < 2; i = i + 1) begin
        p_l4[i] = p_l3[2*i + 1] & p_l3[2*i];
        g_l4[i] = g_l3[2*i + 1] | (g_l3[2*i] & p_l3[2*i + 1]);
    end
    g_l5 = g_l4[1] | (g_l4[0] & p_l4[1]);
    g_l6 = g_l3[2] | (g_l4[0] & p_l3[2]);
    g_l7[0] = g_l2[2] | (g_l3[0] & p_l2[2]);
    g_l7[1] = g_l2[4] | (g_l4[0] & p_l2[4]);
    g_l7[2] = g_l2[6] | (g_l6 & p_l2[6]);
    g_l8[0] = g_l1[2] | (g_l2[0] & p_l1[2]);
    g_l8[1] = g_l1[4] | (g_l3[0] & p_l1[4]);
    g_l8[2] = g_l1[6] | (g_l7[0] & p_l1[6]);
    g_l8[3] = g_l1[8] | (g_l4[0] & p_l1[8]);
    g_l8[4] = g_l1[10] | (g_l7[1] & p_l1[10]);
    g_l8[5] = g_l1[12] | (g_l6 & p_l1[12]);
    g_l8[6] = g_l1[14] | (g_l7[2] & p_l1[14]);
    g_final[0] = g_l0[0];
    g_final[1] = g_l1[0];
    g_final[2] = g_l0[2] | (g_l1[0] & p_l0[2]);
    g_final[3] = g_l2[0];
    g_final[4] = g_l0[4] | (g_l2[0] & p_l0[4]);
    g_final[5] = g_l8[0];
    g_final[6] = g_l0[6] | (g_l8[0] & p_l0[6]);
    g_final[7] = g_l3[0];
    g_final[8] = g_l0[8] | (g_l3[0] & p_l0[8]);
    g_final[9] = g_l8[1];
    g_final[10] = g_l0[10] | (g_l8[1] & p_l0[10]);
    g_final[11] = g_l7[0];
    g_final[12] = g_l0[12] | (g_l7[0] & p_l0[12]);
    g_final[13] = g_l8[2];
    g_final[14] = g_l0[14] | (g_l8[2] & p_l0[14]);
    g_final[15] = g_l4[0];
    g_final[16] = g_l0[16] | (g_l4[0] & p_l0[16]);
    g_final[17] = g_l8[3];
    g_final[18] = g_l0[18] | (g_l8[3] & p_l0[18]);
    g_final[19] = g_l7[1];
    g_final[20] = g_l0[20] | (g_l7[1] & p_l0[20]);
    g_final[21] = g_l8[4];
    g_final[22] = g_l0[22] | (g_l8[4] & p_l0[22]);
    g_final[23] = g_l6;
    g_final[24] = g_l0[24] | (g_l6 & p_l0[24]);
    g_final[25] = g_l8[5];
    g_final[26] = g_l0[26] | (g_l8[5] & p_l0[26]);
    g_final[27] = g_l7[2];
    g_final[28] = g_l0[28] | (g_l7[2] & p_l0[28]);
    g_final[29] = g_l8[6];
    g_final[30] = g_l0[30] | (g_l8[6] & p_l0[30]);
    g_final[31] = g_l5;

    carry_cmb = g_final[31];
    sum_cmb[0] = islec0_i[0] ^ islec1_i[0] ^ carry_i;
    for (i = 1; i < 32; i = i + 1) begin
        sum_cmb[i] = (islec0_i[i] ^ islec1_i[i]) ^ g_final[i-1];
    end
end

assign toplam_o = sum_cmb;
assign carry_o = carry_cmb;

endmodule