/*`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/08/2023 12:35:33 PM
// Design Name: 
// Module Name: pwm
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


module pwm(
    input         clk_i,
    input         rstn_i,
    input  [1:0]  pwm_control_1,
    input  [1:0]  pwm_control_2,
    input [31:0]  pwm_period_1,
    input [31:0]  pwm_period_2,
    input [31:0]  pwm_threshold_1_1,
    input [31:0]  pwm_threshold_2_1,
    input [31:0]  pwm_threshold_1_2,
    input [31:0]  pwm_threshold_2_2,
    input [11:0]  pwm_step_1,
    input [11:0]  pwm_step_2,
    output  reg   pwm_output_1,
    output  reg   pwm_output_2
    );
    
    localparam bekle=0;
    localparam standart=1;
    localparam kalp=2;
    
    reg[31:0] psayac=0,psayac_ns=0,tsayac=0,tsayac_ns=0;
    reg[31:0] psayac2=0,psayac2_ns=0,tsayac2=0,tsayac2_ns=0;
    
    reg[31:0] kalp_sayma=0,kalp_sayma_ns=0;
    reg[31:0] kalp_sayma2=0,kalp_sayma2_ns=0;  
    reg[1:0] mod=0,mod_ns=0;
    reg[1:0] mod2=0,mod2_ns=0;
    reg art_azal=0,art_azal_ns=0;
    reg art_azal2=0,art_azal2_ns=0;
    
    always@* begin
    
        tsayac_ns=tsayac;
        psayac_ns=psayac;
        art_azal_ns=art_azal;
        mod_ns=mod;
        kalp_sayma_ns=kalp_sayma;
        tsayac2_ns=tsayac2;
        psayac2_ns=psayac2;
        art_azal2_ns=art_azal2;
        mod2_ns=mod2;
        kalp_sayma2_ns=kalp_sayma2;
    
        case(pwm_control_1)
            bekle: begin
                pwm_output_1=0;
                psayac_ns=0;
                tsayac_ns=0;
                mod_ns=2'b00;
            end
            standart: begin
                if(mod[0]==0) begin
                    pwm_output_1=1;
                    tsayac_ns=1;
                    psayac_ns=1;
                    mod_ns=2'b01;
                end else if(tsayac<pwm_threshold_1_1 && psayac<pwm_period_1 && mod[0]) begin
                    pwm_output_1=1;
                    tsayac_ns=tsayac+1;
                    psayac_ns=psayac+1;
                    mod_ns=2'b01;
                end else if(tsayac>=pwm_threshold_1_1 && psayac<pwm_period_1 && mod[0] ) begin
                    pwm_output_1=0;
                    tsayac_ns=tsayac+1;
                    psayac_ns=psayac+1;
                    mod_ns=2'b01;
                end else if(psayac==pwm_period_1 && mod[0]) begin
                    pwm_output_1=1;
                    tsayac_ns=1;
                    psayac_ns=1;
                    mod_ns=2'b01;
                end
            end 
            kalp: begin
                if(mod[1]==0) begin
                    pwm_output_1=1;
                    tsayac_ns=1;
                    psayac_ns=1;
                    mod_ns=2'b10;
                    kalp_sayma_ns= pwm_threshold_1_1;
                    art_azal_ns=0;
                end else if(tsayac<kalp_sayma && psayac<pwm_period_1 && mod[1]) begin
                    pwm_output_1=1;
                    tsayac_ns=tsayac+1;
                    psayac_ns=psayac+1;
                    mod_ns=2'b10;
                end else if(tsayac>=kalp_sayma && psayac<pwm_period_1 && mod[1] ) begin
                    pwm_output_1=0;
                    tsayac_ns=tsayac+1;
                    psayac_ns=psayac+1;
                    mod_ns=2'b10;
                end else if(psayac==pwm_period_1 && mod[1]) begin
                    pwm_output_1=1;
                    tsayac_ns=1;
                    psayac_ns=1;
                    mod_ns=2'b10;
                    if(art_azal==0) begin
                        kalp_sayma_ns=kalp_sayma+pwm_step_1;
                        if(kalp_sayma+pwm_step_1 == pwm_threshold_1_2) begin
                            art_azal_ns=1;
                        end
                    end else if(art_azal==1) begin
                        kalp_sayma_ns=kalp_sayma-pwm_step_1;
                        if(kalp_sayma+pwm_step_1 == pwm_threshold_1_1) begin
                            art_azal_ns=0;
                        end
                    end
                end
            end
        endcase
        
        case(pwm_control_2)
            bekle: begin
                pwm_output_2=0;
                psayac2_ns=0;
                tsayac2_ns=0;
                mod2_ns=2'b00;
            end
            standart: begin
                if(mod2[0]==0) begin
                    pwm_output_2=1;
                    tsayac2_ns=1;
                    psayac2_ns=1;
                    mod2_ns=2'b01;
                end else if(tsayac2<pwm_threshold_2_1 && psayac2<pwm_period_2 && mod2[0]) begin
                    pwm_output_2=1;
                    tsayac2_ns=tsayac2+1;
                    psayac2_ns=psayac2+1;
                    mod2_ns=2'b01;
                end else if(tsayac2>=pwm_threshold_2_1 && psayac2<pwm_period_2 && mod2[0] ) begin
                    pwm_output_2=0;
                    tsayac2_ns=tsayac2+1;
                    psayac2_ns=psayac2+1;
                    mod2_ns=2'b01;
                end else if(psayac2==pwm_period_2 && mod2[0]) begin
                    pwm_output_2=1;
                    tsayac2_ns=1;
                    psayac2_ns=1;
                    mod2_ns=2'b01;
                end
            end 
            kalp: begin
                if(mod2[1]==0) begin
                    pwm_output_2=1;
                    tsayac2_ns=1;
                    psayac2_ns=1;
                    mod2_ns=2'b10;
                    kalp_sayma2_ns= pwm_threshold_2_1;
                    art_azal_ns=0;
                end else if(tsayac2<kalp_sayma2 && psayac2<pwm_period_2 && mod2[1]) begin
                    pwm_output_2=1;
                    tsayac2_ns=tsayac2+1;
                    psayac2_ns=psayac2+1;
                    mod2_ns=2'b10;
                end else if(tsayac2>=kalp_sayma2 && psayac2<pwm_period_2 && mod2[1] ) begin
                    pwm_output_2=0;
                    tsayac2_ns=tsayac2+1;
                    psayac2_ns=psayac2+1;
                    mod2_ns=2'b10;
                end else if(psayac2==pwm_period_2 && mod2[1]) begin
                    pwm_output_2=1;
                    tsayac2_ns=1;
                    psayac2_ns=1;
                    mod2_ns=2'b10;
                    if(art_azal2==0) begin
                        kalp_sayma2_ns=kalp_sayma2+pwm_step_2;
                        if(kalp_sayma2+pwm_step_2 == pwm_threshold_2_2) begin
                            art_azal2_ns=1;
                        end
                    end else if(art_azal2==1) begin
                        kalp_sayma2_ns=kalp_sayma2-pwm_step_2;
                        if(kalp_sayma2+pwm_step_2 == pwm_threshold_2_1) begin
                            art_azal2_ns=0;
                        end
                    end
                end
            end
        endcase    
    end
    
    always@(posedge clk_i) begin
        if(!rstn_i) begin
            tsayac<=0;
            psayac<=0;
            art_azal<=0;
            mod<=0;
            kalp_sayma<=0;
            tsayac2<=0;
            psayac2<=0;
            art_azal2<=0;
            mod2<=0;
            kalp_sayma2<=kalp_sayma2_ns;
        end else begin
            tsayac<=tsayac_ns;
            psayac<=psayac_ns;
            art_azal<=art_azal_ns;
            mod<=mod_ns;
            kalp_sayma<=kalp_sayma_ns;
            tsayac2<=tsayac2_ns;
            psayac2<=psayac2_ns;
            art_azal2<=art_azal2_ns;
            mod2<=mod2_ns;
            kalp_sayma2<=kalp_sayma2_ns;
        end
        
    end
endmodule*/
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/08/2023 12:35:33 PM
// Design Name: 
// Module Name: pwm
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


module pwm(
    input         clk_i,
    input         rstn_i,
    input  [1:0]  pwm_control_1,
    input  [1:0]  pwm_control_2,
    input [31:0]  pwm_period_1,
    input [31:0]  pwm_period_2,
    input [31:0]  pwm_threshold_1_1,
    input [31:0]  pwm_threshold_2_1,
    input [31:0]  pwm_threshold_1_2,
    input [31:0]  pwm_threshold_2_2,
    input [11:0]  pwm_step_1,
    input [11:0]  pwm_step_2,
    output  reg   pwm_output_1,
    output  reg   pwm_output_2
    );
    
    localparam bekle=0;
    localparam standart=1;
    localparam kalp=2;
    
    reg[31:0] psayac=0,psayac_ns=0,tsayac=0,tsayac_ns=0;
    reg[31:0] psayac2=0,psayac2_ns=0,tsayac2=0,tsayac2_ns=0;
    
    reg[31:0] kalp_sayma=0,kalp_sayma_ns=0;
    reg[31:0] kalp_sayma2=0,kalp_sayma2_ns=0;  
    reg[1:0] mod=0,mod_ns=0;
    reg[1:0] mod2=0,mod2_ns=0;
    reg art_azal=0,art_azal_ns=0;
    reg art_azal2=0,art_azal2_ns=0;
    
    wire art_azalt_w;
    wire art_azalt2_w;
    wire[31:0] kucuk_threshold;
    wire[31:0] kucuk_threshold2;
    wire[31:0] buyuk_threshold;
    wire[31:0] buyuk_threshold2;
    
    assign kucuk_threshold = pwm_threshold_1_1 < pwm_threshold_1_2 ? pwm_threshold_1_1 : pwm_threshold_1_2;
    assign kucuk_threshold2 = pwm_threshold_2_1 < pwm_threshold_2_2 ? pwm_threshold_2_1 : pwm_threshold_2_2;  
    
    assign buyuk_threshold = pwm_threshold_1_1 < pwm_threshold_1_2 ? pwm_threshold_1_2 : pwm_threshold_1_1;
    assign buyuk_threshold2 = pwm_threshold_2_1 < pwm_threshold_2_2 ? pwm_threshold_2_2 : pwm_threshold_2_1; 
    
    assign art_azalt_w = pwm_threshold_1_1 < pwm_threshold_1_2 ? 0 : 1;
    assign art_azalt2_w = pwm_threshold_2_1 < pwm_threshold_2_2 ? 0 : 1;
    
    always@* begin
    
        tsayac_ns=tsayac;
        psayac_ns=psayac;
        art_azal_ns=art_azal;
        mod_ns=mod;
        kalp_sayma_ns=kalp_sayma;
        
        tsayac2_ns=tsayac2;
        psayac2_ns=psayac2;
        art_azal2_ns=art_azal2;
        mod2_ns=mod2;
        kalp_sayma2_ns=kalp_sayma2;
    
            
        case(pwm_control_1)
            bekle: begin
                pwm_output_1=0;
                psayac_ns=0;
                tsayac_ns=0;
                mod_ns=2'b00;
            end
            standart: begin
                if(mod[0]==0) begin
                    pwm_output_1=1;
                    tsayac_ns=1;
                    psayac_ns=1;
                    mod_ns=2'b01;
                end else if(tsayac<pwm_threshold_1_1 && psayac<pwm_period_1 && mod[0]) begin
                    pwm_output_1=1;
                    tsayac_ns=tsayac+1;
                    psayac_ns=psayac+1;
                    mod_ns=2'b01;
                end else if(tsayac>=pwm_threshold_1_1 && psayac<pwm_period_1 && mod[0] ) begin
                    pwm_output_1=0;
                    tsayac_ns=tsayac+1;
                    psayac_ns=psayac+1;
                    mod_ns=2'b01;
                end else if(psayac==pwm_period_1 && mod[0]) begin
                    pwm_output_1=1;
                    tsayac_ns=1;
                    psayac_ns=1;
                    mod_ns=2'b01;
                end
            end 
            kalp: begin
                if(mod[1]==0) begin
                    pwm_output_1=1;
                    tsayac_ns=1;
                    psayac_ns=1;
                    mod_ns=2'b10;
                    kalp_sayma_ns= pwm_threshold_1_1;
                    art_azal_ns= art_azalt_w;
                end else if(tsayac<kalp_sayma && psayac<pwm_period_1 && mod[1]) begin
                    pwm_output_1=1;
                    tsayac_ns=tsayac+1;
                    psayac_ns=psayac+1;
                    mod_ns=2'b10;
                end else if(tsayac>=kalp_sayma && psayac<pwm_period_1 && mod[1] ) begin
                    pwm_output_1=0;
                    tsayac_ns=tsayac+1;
                    psayac_ns=psayac+1;
                    mod_ns=2'b10;
                end else if(psayac==pwm_period_1 && mod[1]) begin
                    pwm_output_1=1;
                    tsayac_ns=1;
                    psayac_ns=1;
                    mod_ns=2'b10;
                    if(art_azal==0) begin
                        kalp_sayma_ns=kalp_sayma+pwm_step_1;
                        if(kalp_sayma+pwm_step_1 >= buyuk_threshold) begin
                        //if(kalp_sayma >= pwm_threshold_1_2) begin
                            art_azal_ns=1;
                            kalp_sayma_ns = buyuk_threshold;
                        end
                    end else if(art_azal==1) begin
                        kalp_sayma_ns=kalp_sayma-pwm_step_1;
                        if(kalp_sayma-pwm_step_1 <= kucuk_threshold) begin
                        //if(kalp_sayma <= pwm_threshold_1_1) begin
                            art_azal_ns=0;
                            kalp_sayma_ns = kucuk_threshold;
                        end
                    end
                end
            end
        endcase
             
        
        case(pwm_control_2)
            bekle: begin
                pwm_output_2=0;
                psayac2_ns=0;
                tsayac2_ns=0;
                mod2_ns=2'b00;
            end
            standart: begin
                if(mod2[0]==0) begin
                    pwm_output_2=1;
                    tsayac2_ns=1;
                    psayac2_ns=1;
                    mod2_ns=2'b01;
                end else if(tsayac2<pwm_threshold_2_1 && psayac2<pwm_period_2 && mod2[0]) begin
                    pwm_output_2=1;
                    tsayac2_ns=tsayac2+1;
                    psayac2_ns=psayac2+1;
                    mod2_ns=2'b01;
                end else if(tsayac2>=pwm_threshold_2_1 && psayac2<pwm_period_2 && mod2[0] ) begin
                    pwm_output_2=0;
                    tsayac2_ns=tsayac2+1;
                    psayac2_ns=psayac2+1;
                    mod2_ns=2'b01;
                end else if(psayac2==pwm_period_2 && mod2[0]) begin
                    pwm_output_2=1;
                    tsayac2_ns=1;
                    psayac2_ns=1;
                    mod2_ns=2'b01;
                end
            end 
            kalp: begin
                if(mod2[1]==0) begin
                    pwm_output_2=1;
                    tsayac2_ns=1;
                    psayac2_ns=1;
                    mod2_ns=2'b10;
                    kalp_sayma2_ns= pwm_threshold_2_1;
                    art_azal2_ns= art_azalt2_w;
                end else if(tsayac2<kalp_sayma2 && psayac2<pwm_period_2 && mod2[1]) begin
                    pwm_output_2=1;
                    tsayac2_ns=tsayac2+1;
                    psayac2_ns=psayac2+1;
                    mod2_ns=2'b10;
                end else if(tsayac2>=kalp_sayma2 && psayac2<pwm_period_2 && mod2[1] ) begin
                    pwm_output_2=0;
                    tsayac2_ns=tsayac2+1;
                    psayac2_ns=psayac2+1;
                    mod2_ns=2'b10;
                end else if(psayac2==pwm_period_2 && mod2[1]) begin
                    pwm_output_2=1;
                    tsayac2_ns=1;
                    psayac2_ns=1;
                    mod2_ns=2'b10;
                    if(art_azal2==0) begin
                        kalp_sayma2_ns=kalp_sayma2+pwm_step_2;
                        if(kalp_sayma2+pwm_step_2 >= buyuk_threshold2) begin
                        //if(kalp_sayma2 >= pwm_threshold_2_2) begin
                            art_azal2_ns=1;
                            kalp_sayma2_ns = buyuk_threshold2;
                        end
                    end else if(art_azal2==1) begin
                        kalp_sayma2_ns=kalp_sayma2-pwm_step_2;
                        if(kalp_sayma2-pwm_step_2 <= kucuk_threshold2) begin
                        //if(kalp_sayma2 <= pwm_threshold_2_1) begin
                            art_azal2_ns=0;
                            kalp_sayma2_ns = kucuk_threshold2;
                        end
                    end
                end
            end
        endcase    
    end
    
    always@(posedge clk_i) begin
        if(!rstn_i) begin
            tsayac<=0;
            psayac<=0;
            art_azal<=0;
            mod<=0;
            kalp_sayma<=0;
            tsayac2<=0;
            psayac2<=0;
            art_azal2<=0;
            mod2<=0;
            kalp_sayma2<=kalp_sayma2_ns;
        end else begin
            tsayac<=tsayac_ns;
            psayac<=psayac_ns;
            art_azal<=art_azal_ns;
            mod<=mod_ns;
            kalp_sayma<=kalp_sayma_ns;
            tsayac2<=tsayac2_ns;
            psayac2<=psayac2_ns;
            art_azal2<=art_azal2_ns;
            mod2<=mod2_ns;
            kalp_sayma2<=kalp_sayma2_ns;
        end
        
    end
endmodule