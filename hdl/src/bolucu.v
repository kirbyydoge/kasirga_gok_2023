`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/09/2023 08:30:52 PM
// Design Name: 
// Module Name: bolucu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bolucu(
    input                 clk_i                                                         ,
    input                 rst_i                                                         ,
    input        [3:0]    islev_kodu_i                                                  ,
    input        [31:0]   islec0_i                                                      ,
    input        [31:0]   islec1_i                                                      ,
    input                 islem_gecerli_i                                               ,
    output       [31:0]   bolum_o                                                       ,
    output                bolum_gecerli_o
);

reg[31:0] bolum_o_r=0;
reg[31:0] bolum_o_r_ns=0;
reg[31:0] k;
assign bolum_o=k;

reg bolum_gecerli_r_o;
assign bolum_gecerli_o=bolum_gecerli_r_o;

localparam DIV  = 4'h1; 
localparam DIVU = 4'h2; 
localparam REM  = 4'h4; 
localparam REMU = 4'h8;

localparam BEKLE    = 2'd0;
localparam HAZIRLAN = 2'd1;
localparam BOL      = 2'd2;

reg [9:0] sayac=9'd1;
reg [9:0] sayac_ns=9'd1;

reg           [3:0] islev_kodu_r=0;
reg           [3:0] islev_kodu_r_ns=0;

reg          [31:0] islec0_r=0;
reg          [31:0] islec0_r_ns=0;

reg          [63:0] islec1_r=0;
reg          [63:0] islec1_r_ns=0;

reg[31:0]   SS1=0,SS1_ns=0,SS2=0,SS2_ns=0;

reg[1:0] durum=0;
reg[1:0] durum_ns=0;

reg sign=0;
reg sign_ns=0;
reg rem_sign=0;
reg rem_sign_ns=0;

wire bitwise;  
assign bitwise = |islec1_r[63:36];

wire A,B,C,D;
assign A=islec1_r[35];
assign B=islec1_r[34];
assign C=islec1_r[33];
assign D=islec1_r[32];

wire[2:0] shift_amount;
assign shift_amount[2] = A;
assign shift_amount[1] = ((~A)&&C)||((~A)&&B);
assign shift_amount[0] = ((~A)&&B)||((~A)&&(~C)&&D);

reg[32:0] S1 [3:0];
reg[32:0] S2 [3:0];

wire[32:0] cikarma_s [3:0];


toplayici_33 a1(.islec0_i(S1[0]),.islec1_i(-S2[0]),.toplam_o(cikarma_s[0]));
toplayici_33 a2(.islec0_i(S1[1]),.islec1_i(-S2[1]),.toplam_o(cikarma_s[1]));
toplayici_33 a3(.islec0_i(S1[2]),.islec1_i(-S2[2]),.toplam_o(cikarma_s[2]));
toplayici_33 a4(.islec0_i(S1[3]),.islec1_i(-S2[3]),.toplam_o(cikarma_s[3]));

reg[2:0] ss=0,ss_ns=0;
reg[31:0] kalan=0,kalan_ns=0;

always @* begin
    bolum_o_r_ns = bolum_o_r;
    sayac_ns = sayac;
    islev_kodu_r_ns = islev_kodu_r;
    islec0_r_ns = islec0_r;
    islec1_r_ns = islec1_r;
    sign_ns = sign;
    durum_ns = durum;
    ss_ns=ss;
    rem_sign_ns=rem_sign;
    SS1_ns=SS1;
    SS2_ns=SS2;

    case(durum)
        BEKLE: begin
            
            bolum_gecerli_r_o=1'b0;
            if(islem_gecerli_i && sayac[0]) begin
                SS1_ns=islec0_i;
                SS2_ns=islec1_i;
                case(islev_kodu_i)
                    DIV: begin
                        islec0_r_ns= islec0_i[31] ? -islec0_i : islec0_i;
                        islec1_r_ns[63:32]= islec1_i[31] ? -islec1_i : islec1_i;
                        islec1_r_ns[31:0]=32'd0;
                    end
                    DIVU: begin
                        islec0_r_ns= islec0_i;
                        islec1_r_ns[63:32]= islec1_i;
                        islec1_r_ns[31:0]=32'd0;    
                    end
                    REM:begin
                        islec0_r_ns= islec0_i[31] ? -islec0_i : islec0_i;
                        islec1_r_ns[63:32]= islec1_i[31] ? -islec1_i : islec1_i;
                        islec1_r_ns[31:0]=32'd0;
                        rem_sign_ns=islec0_i[31];
                    end
                    REMU:begin
                        islec0_r_ns= islec0_i;
                        islec1_r_ns[63:32]= islec1_i;
                        islec1_r_ns[31:0]=32'd0;
                    end
                endcase
                sign_ns= islec0_i[31] ^ islec1_i[31];
                islev_kodu_r_ns=islev_kodu_i;    
                sayac_ns=sayac<<1;
                bolum_o_r_ns=0;
                durum_ns=HAZIRLAN;
            end
        end
        
        HAZIRLAN: begin
            
            islec1_r_ns = bitwise ? islec1_r>>4 : islec1_r>>(shift_amount);
            
            durum_ns = bitwise ? HAZIRLAN : BOL;
            
            ss_ns=shift_amount;
            
            sayac_ns=sayac<<1;
        end
        
        BOL: begin
            
            S1[0]=islec0_r;
            S2[0]=islec1_r[31:0];

            if(cikarma_s[0][32]) begin
                S1[1]=islec0_r;
                S2[1]=islec1_r[31:0] >>1;
                bolum_o_r_ns[3]=1'b0;
            end else begin
                S1[1]=cikarma_s[0];
                S2[1]=islec1_r[31:0] >>1;
                bolum_o_r_ns[3]=1'b1;    
            end

            if(cikarma_s[1][32]) begin
                S1[2]= S1[1];
                S2[2]=islec1_r[31:0] >>2;
                bolum_o_r_ns[2]=1'b0;
            end else begin
                S1[2]=cikarma_s[1];
                S2[2]=islec1_r[31:0] >>2; 
                bolum_o_r_ns[2]=1'b1;   
            end

            if(cikarma_s[2][32]) begin
                S1[3]= S1[2];
                S2[3]=islec1_r[31:0] >>3;
                bolum_o_r_ns[1]=1'b0;
            end else begin
                S1[3]=cikarma_s[2];
                S2[3]=islec1_r[31:0] >>3;
                bolum_o_r_ns[1]=1'b1;    
            end

            if(cikarma_s[3][31]) begin
                islec0_r_ns= S1[3];
                islec1_r_ns=islec1_r[31:0] >>4;
                bolum_o_r_ns[0]=1'b0;
            end else begin
                islec0_r_ns=cikarma_s[3];
                islec1_r_ns=islec1_r[31:0] >>4;
                bolum_o_r_ns[0]=1'b1;    
            end
            bolum_o_r_ns[31:4]=bolum_o_r[27:0];
            sayac_ns=sayac<<1;
            if(sayac[9]) begin
                bolum_gecerli_r_o=1'b1;
                durum_ns=BEKLE;
                sayac_ns=10'd1;
                case(islev_kodu_r)
                    DIV: begin
                        if(SS2==32'd0) begin
                            k=32'b11111111111111111111111111111111;
                        end else if(SS1==32'b10000000000000000000000000000000 && SS2==32'b11111111111111111111111111111111) begin
                            k=32'b10000000000000000000000000000000;
                        end else begin
                            k = sign ? -(bolum_o_r_ns[31:0] >> (ss-1)) : (bolum_o_r_ns[31:0] >> (ss-1));
                        end
                    end
                    DIVU: begin
                        if(SS2==32'd0) begin
                            k=32'b11111111111111111111111111111111;
                        end else begin
                            k = bolum_o_r_ns[31:0] >> (ss-1);    
                        end
                    end
                    REM:begin
                        if(SS2==32'd0) begin
                            k=SS1;
                        end else if(SS1==32'b10000000000000000000000000000000 && SS2==32'b11111111111111111111111111111111) begin
                            k=32'd0;
                        end else begin
                            k= rem_sign ? -(cikarma_s[4-ss][32] ? S1[4-ss] : cikarma_s[4-ss]) : (cikarma_s[4-ss][32] ? S1[4-ss] : cikarma_s[4-ss])  ;
                        end
                    end
                    REMU:begin
                        if(SS2==32'd0) begin
                            k=SS1;
                        end else begin
                            k= cikarma_s[4-ss][32] ? S1[4-ss] : cikarma_s[4-ss];
                        end
                    end
                endcase
            end
        end
    endcase
end

always @(posedge clk_i) begin
    if (rst_i) begin
        bolum_o_r<=0;
        sayac<=1;
        islev_kodu_r<=0;
        islec0_r<=0;
        islec1_r<=0;
        sign<=0;
        ss<=0;
        durum<=BEKLE;
        rem_sign<=0;
        SS2<=0;
        SS2<=0;
    end
    else begin
        bolum_o_r<=bolum_o_r_ns;
        sayac<=sayac_ns;
        islev_kodu_r<=islev_kodu_r_ns;
        islec0_r<=islec0_r_ns;
        islec1_r<=islec1_r_ns;
        sign<=sign_ns;
        durum<=durum_ns;
        ss<=ss_ns;
        rem_sign<=rem_sign_ns;
        SS1<=SS1_ns;
        SS2<=SS2_ns;
    end
end

    
endmodule