`timescale 1ns/1ps

module carpici_pipe3 (
    input           clk_i,
    input   [31:0]  islec0_i,
    input   [31:0]  islec1_i,
    input           islem_gecerli_i,
    output  [63:0]  carpim_o,
    output          carpim_gecerli_o
);

reg  [63:0] partial [0:31];
wire [63:0] s_l0 [0:9];
wire [63:0] c_l0 [0:9];
wire [63:0] s_l1 [0:6];
wire [63:0] c_l1 [0:6];
wire [63:0] s_l2 [0:4];
wire [63:0] c_l2 [0:4];
wire [63:0] s_l3 [0:2];
wire [63:0] c_l3 [0:2];
wire [63:0] s_l4 [0:1];
wire [63:0] c_l4 [0:1];
wire [63:0] s_l5;
wire [63:0] c_l5;
wire [63:0] s_l6;
wire [63:0] c_l6;
wire [63:0] s_l7;
wire [63:0] c_l7;

reg  [31:0] islec0_sign_corrected;
reg         islec0_is_negated;
reg  [31:0] islec1_sign_corrected;
reg         islec1_is_negated;

integer i;
always @* begin
    islec0_sign_corrected = islec0_i[31] ? (~islec0_i + 32'b1) : islec0_i;
    islec1_sign_corrected = islec1_i[31] ? (~islec1_i + 32'b1) : islec1_i;
    islec0_is_negated = islec0_i[31];
    islec1_is_negated = islec1_i[31];
    for (i = 0; i < 32; i = i + 1) begin
        if (islec1_sign_corrected[i]) begin
            partial[i] = {{32{islec0_sign_corrected[31]}}, islec0_sign_corrected} << i;
        end
        else begin
            partial[i] = 64'd0;
        end
    end
end

genvar j;
generate
    for (j = 0; j < 10; j = j + 1) begin : gen_partial
        csa64 csa_partial (partial[j * 3], partial[j * 3 + 1], partial[j * 3 + 2], s_l0[j], c_l0[j]);
    end
endgenerate

csa64 csa_l0_0 (s_l0[0], c_l0[0], s_l0[1], s_l1[0], c_l1[0]);
csa64 csa_l0_1 (c_l0[1], s_l0[2], c_l0[2], s_l1[1], c_l1[1]);
csa64 csa_l0_2 (s_l0[3], c_l0[3], s_l0[4], s_l1[2], c_l1[2]);
csa64 csa_l0_3 (c_l0[4], s_l0[5], c_l0[5], s_l1[3], c_l1[3]);
csa64 csa_l0_4 (s_l0[6], c_l0[6], s_l0[7], s_l1[4], c_l1[4]);
csa64 csa_l0_5 (c_l0[7], s_l0[8], c_l0[8], s_l1[5], c_l1[5]);
csa64 csa_l0_6 (s_l0[9], c_l0[9], partial[30], s_l1[6], c_l1[6]);

csa64 csa_l1_0 (s_l1[0], c_l1[0], s_l1[1], s_l2[0], c_l2[0]);
csa64 csa_l1_1 (c_l1[1], s_l1[2], c_l1[2], s_l2[1], c_l2[1]);
csa64 csa_l1_2 (s_l1[3], c_l1[3], s_l1[4], s_l2[2], c_l2[2]);
csa64 csa_l1_3 (c_l1[4], s_l1[5], c_l1[5], s_l2[3], c_l2[3]);
csa64 csa_l1_4 (s_l1[6], c_l1[6], partial[31], s_l2[4], c_l2[4]);

reg [63:0]  pipe_s0_sl2 [0:4];
reg [63:0]  pipe_s0_cl2 [0:4];
reg         pipe_s0_negate;
reg         pipe_s0_valid;

always @(posedge clk_i) begin
    pipe_s0_sl2[0] <= s_l2[0];
    pipe_s0_cl2[0] <= c_l2[0];
    pipe_s0_sl2[1] <= s_l2[1];
    pipe_s0_cl2[1] <= c_l2[1];
    pipe_s0_sl2[2] <= s_l2[2];
    pipe_s0_cl2[2] <= c_l2[2];
    pipe_s0_sl2[3] <= s_l2[3];
    pipe_s0_cl2[3] <= c_l2[3];
    pipe_s0_sl2[4] <= s_l2[4];
    pipe_s0_cl2[4] <= c_l2[4];
    pipe_s0_negate <= islec0_is_negated ^ islec1_is_negated;
    pipe_s0_valid <= islem_gecerli_i;
end

csa64 csa_l2_0 (pipe_s0_sl2[0], pipe_s0_cl2[0], pipe_s0_sl2[1], s_l3[0], c_l3[0]);
csa64 csa_l2_1 (pipe_s0_cl2[1], pipe_s0_sl2[2], pipe_s0_cl2[2], s_l3[1], c_l3[1]);
csa64 csa_l2_2 (pipe_s0_sl2[3], pipe_s0_cl2[3], pipe_s0_sl2[4], s_l3[2], c_l3[2]);

csa64 csa_l3_0 (s_l3[0], c_l3[0], s_l3[1], s_l4[0], c_l4[0]);
csa64 csa_l3_1 (c_l3[1], s_l3[2], c_l3[2], s_l4[1], c_l4[1]);

csa64 csa_l4_0 (s_l4[0], c_l4[0], s_l4[1], s_l5, c_l5);

csa64 csa_l5_0 (s_l5, c_l5, c_l4[1], s_l6, c_l6);

csa64 csa_l6_0 (s_l6, c_l6, c_l2[4], s_l7, c_l7);

reg [63:0]  pipe_s1_sl7;
reg [63:0]  pipe_s1_cl7;
reg         pipe_s1_negate; 
reg         pipe_s1_valid; 

always @(posedge clk_i) begin
    pipe_s1_sl7 <= s_l7;
    pipe_s1_cl7 <= c_l7;
    pipe_s1_negate <= pipe_s0_negate;
    pipe_s1_valid <= pipe_s0_valid;
end

wire [1:0] c_l8;
wire [63:0] res_l8;

toplayici bk_lsb (
    .islec0_i(pipe_s1_sl7[31:0]),
    .islec1_i(pipe_s1_cl7[31:0]),
    .carry_i(1'b0),
    .toplam_o(res_l8[31:0]),
    .carry_o(c_l8[0])
);

toplayici bk_msg (
    .islec0_i(pipe_s1_sl7[63:32]),
    .islec1_i(pipe_s1_cl7[63:32]),
    .carry_i(c_l8[0]),
    .toplam_o(res_l8[63:32]),
    .carry_o(c_l8[1])
); 

reg [63:0]  res_sign_corrected;
reg [63:0]  res_r;
reg         res_valid_r;

always @* begin
    res_sign_corrected = pipe_s1_negate ? (~res_l8 + 64'b1) : res_l8;
end

always @(posedge clk_i) begin
    res_r <= res_sign_corrected;
    res_valid_r <= pipe_s1_valid;
end

assign carpim_o = res_r;
assign carpim_gecerli_o = res_valid_r;

endmodule