`timescale 1ns / 1ps

module bolucu(
    input                 clk_i                                                         ,
    input                 rst_i                                                         ,
    input        [3:0]    islev_kodu_i                                                  ,
    input        [31:0]   islec0_i                                                      ,
    input        [31:0]   islec1_i                                                      ,
    input                 islem_gecerli_i                                                       ,
    output     reg        bolum_gecerli_o=0                                                     ,
    output     reg[31:0]  bolum_o
    );
    
    localparam DIV  = 4'h1; 
    localparam DIVU = 4'h2; 
    localparam REM  = 4'h4; 
    localparam REMU = 4'h8;
    localparam EVET= 1'b1;
    reg[1:0] durum=2'b00,durum_next=2'b00;
    reg[3:0] islev_kodu_r=0,islev_kodu_r_next=0;
    reg[62:0] s2=0,s2_next=0;
    reg[62:0] s1=0,s1_next=0;
    reg[16:0]  cevrim=17'd1,cevrim_next=17'd1;
    reg       bolum_gecerli_o_next=0;
    reg       sign_bolum=0,sign_bolum_next=0;
    reg       sign_kalan=0,sign_kalan_next=0;
    reg[31:0] bolum_o_next=0;
    reg[31:0] tt        =  32'b10_00000_00000_00000_00000_00000_00000;
    reg[31:0] tt_next   =  32'b10000000000000000000000000000000;
    always@* begin
        bolum_gecerli_o_next=bolum_gecerli_o;
        islev_kodu_r_next=islev_kodu_r;
        s2_next=s2;
        s1_next=s1;
        cevrim_next=cevrim;
        sign_bolum_next=sign_bolum;
        bolum_o_next=bolum_o;
        sign_kalan_next=sign_kalan;
        tt_next=tt;
        durum_next=durum;
        
        case(islem_gecerli_i&cevrim[0])
            1'b1: begin
                case( {islec0_i[31],(islev_kodu_i[1]|islev_kodu_i[3])})
                    2'b10: s1_next={31'd0,{~islec0_i+1}};
                    2'b00: s1_next={31'd0,islec0_i};
                    2'b11: s1_next={31'd0,islec0_i};
                    2'b01: s1_next={31'd0,islec0_i};
                endcase
                case({islec1_i[31],(islev_kodu_i[1]|islev_kodu_i[3])})
                    2'b10:s2_next={{~islec1_i+1},31'd0};
                    2'b00:s2_next={islec1_i,31'd0};
                    2'b11:s2_next={islec1_i,31'd0};
                    2'b01:s2_next={islec1_i,31'd0};
                endcase
                sign_bolum_next=islec0_i[31]^islec1_i[31];
                sign_kalan_next=islec0_i[31];
                bolum_gecerli_o_next=1'b0;
                bolum_o_next=32'd0;
                islev_kodu_r_next=islev_kodu_i;
                durum_next=durum+1;
                cevrim_next=cevrim<<1;
            end
        endcase
        
        case(durum)
            2'b01: begin
                case(s1>=s2)
                    1'b1: begin
                        case(s1>=(s2+(s2>>1)))
                            1'b1: begin
                                s1_next=s1-s2-(s2>>1);
                                bolum_o_next=bolum_o+tt+(tt>>1);
                            end
                            1'b0: begin
                                s1_next=s1-s2;
                                bolum_o_next=bolum_o+tt;
                            end
                        endcase
                    end
                    1'b0: begin
                        case(s1>=(s2>>1))
                            1'b1: begin
                                s1_next=s1-(s2>>1);
                                bolum_o_next=bolum_o+(tt>>1);
                            end
                        endcase
                    end
                endcase
                s2_next=s2>>2;
                tt_next=tt>>2;
                cevrim_next=cevrim<<1;
                durum_next[0]=durum[0]^cevrim[16];
                durum_next[1]=durum[1]^cevrim[16];
            end
            2'b10: begin
                case(islev_kodu_r)
                    DIV & {sign_bolum,sign_bolum,sign_bolum,sign_bolum}: begin
                        bolum_o_next=(~bolum_o)+32'd1;
                    end
                    REM & {sign_kalan,sign_kalan,sign_kalan,sign_kalan}: begin
                        bolum_o_next=(~s1[31:0])+32'd1;    
                    end
                    REM | {sign_kalan,sign_kalan,sign_kalan,sign_kalan}: begin
                        bolum_o_next=s1[31:0];   
                    end
                    REMU: begin
                        bolum_o_next=s1[31:0];   
                    end
                endcase
                tt_next=32'b10000000000000000000000000000000;
                bolum_gecerli_o_next=1'b1;
                cevrim_next=17'd1;
                durum_next=durum+1;
            end
            2'b11: begin
                case(islem_gecerli_i&cevrim[0])
                    1'b1: durum_next=2'b01;
                    1'b0: durum_next=2'b00;
                endcase
                bolum_gecerli_o_next=1'b0;
                cevrim_next=17'd1;
            end
         
        endcase
        
    end
    
    always@(posedge clk_i) begin
        case(rst_i)
        1'b1: begin
            bolum_gecerli_o<=1'b0;
            s2<=63'd0;
            s1<=63'd0;
            cevrim<=17'd1;
            sign_bolum<=1'd0;
            tt<=32'b10000000000000000000000000000000;
            islev_kodu_r<=4'b0001;
            bolum_o<=32'd0;
            sign_kalan<=1'b0;    
            durum<=2'b00;
        end 
        1'b0: begin
            bolum_gecerli_o<=bolum_gecerli_o_next;
            s2<=s2_next;
            s1<=s1_next;
            cevrim<=cevrim_next;
            sign_bolum<=sign_bolum_next;
            tt<=tt_next;
            islev_kodu_r<=islev_kodu_r_next;
            bolum_o<=bolum_o_next;
            sign_kalan<=sign_kalan_next;
            durum<=durum_next;
        end
        endcase
    end
endmodule