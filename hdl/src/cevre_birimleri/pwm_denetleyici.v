`timescale 1ns/1ps

`include "sabitler.vh"

module pwm_denetleyici (
    input                       clk_i,
    input                       rstn_i,

    input   [`ADRES_BIT-1:0]    cek_adres_i,
    input   [`VERI_BIT-1:0]     cek_veri_i,
    input   [`TL_A_BITS-1:0]    cek_tilefields_i,

    input                       cek_gecerli_i,
    output                      cek_hazir_o,

    output  [`VERI_BIT-1:0]     pwm_veri_o,
    output                      pwm_gecerli_o,
    output  [`TL_D_BITS-1:0]    pwm_tilefields_o,
    input                       pwm_hazir_i,

    output                      o1,
    output                      o2
);

assign cek_hazir_o = `HIGH;
assign pwm_veri_o = pwm_veri_r;
assign pwm_gecerli_o = pwm_gecerli_r;
assign pwm_tilefields_o = pwm_tilefields_r;

reg [`VERI_BIT-1:0] pwm_veri_r;
reg [`VERI_BIT-1:0] pwm_veri_ns;
reg pwm_gecerli_r;
reg pwm_gecerli_ns;
reg [`TL_D_BITS-1:0] pwm_tilefields_r;
reg [`TL_D_BITS-1:0] pwm_tilefields_ns;

wire        cek_pwm_istek_w;
wire [7:0]  cek_pwm_addr_w;
wire        cek_pwm_yaz_w;
wire        cek_pwm_oku_w;

assign cek_pwm_istek_w = ((cek_adres_i & ~`PWM_MASK_ADDR) == `PWM_BASE_ADDR) && cek_gecerli_i;
assign cek_pwm_addr_w = cek_adres_i & `PWM_MASK_ADDR;
assign cek_pwm_yaz_w = cek_tilefields_i[`TL_A_OP] == `TL_OP_PUT_FULL || cek_tilefields_i[`TL_A_OP] == `TL_OP_PUT_PART;
assign cek_pwm_oku_w = cek_tilefields_i[`TL_A_OP] == `TL_OP_GET;

reg [1:0]  pwm_control_1_r,pwm_control_1_ns;
reg [1:0]  pwm_control_2_r,pwm_control_2_ns;
reg [`VERI_BIT-1:0] pwm_period_1_r,pwm_period_1_ns;
reg [`VERI_BIT-1:0] pwm_period_2_r,pwm_period_2_ns;
reg [`VERI_BIT-1:0] pwm_threshold_1_1_r,pwm_threshold_1_1_ns;
reg [`VERI_BIT-1:0] pwm_threshold_2_1_r,pwm_threshold_2_1_ns;
reg [`VERI_BIT-1:0] pwm_threshold_1_2_r,pwm_threshold_1_2_ns;
reg [`VERI_BIT-1:0] pwm_threshold_2_2_r,pwm_threshold_2_2_ns;
reg [`VERI_BIT-1:0] pwm_step_1_r,pwm_step_1_ns;
reg [`VERI_BIT-1:0] pwm_step_2_r,pwm_step_2_ns;
wire pwm_output_1_w;
wire pwm_output_2_w;

assign o1 = pwm_output_1_w;
assign o2 = pwm_output_2_w;

pwm p_w_m (
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .pwm_control_1(pwm_control_1_r),
    .pwm_control_2(pwm_control_2_r),
    .pwm_period_1(pwm_period_1_r),
    .pwm_period_2(pwm_period_2_r),
    .pwm_threshold_1_1(pwm_threshold_1_1_r),
    .pwm_threshold_2_1(pwm_threshold_2_1_r),
    .pwm_threshold_1_2(pwm_threshold_1_2_r),
    .pwm_threshold_2_2(pwm_threshold_2_2_r),
    .pwm_step_1(pwm_step_1_r),
    .pwm_step_2(pwm_step_2_r),
    .pwm_output_1(pwm_output_1_w),
    .pwm_output_2(pwm_output_2_w)
);

always @* begin
    pwm_control_1_ns = pwm_control_1_r;
    pwm_control_2_ns = pwm_control_2_r;
    pwm_period_1_ns = pwm_period_1_r;
    pwm_period_2_ns = pwm_period_2_r;
    pwm_threshold_1_1_ns = pwm_threshold_1_1_r;
    pwm_threshold_2_1_ns = pwm_threshold_2_1_r;
    pwm_threshold_1_2_ns = pwm_threshold_1_2_r;
    pwm_threshold_2_2_ns = pwm_threshold_2_2_r;
    pwm_step_1_ns = pwm_step_1_r;
    pwm_step_2_ns = pwm_step_2_r;

    pwm_veri_ns = pwm_veri_r;
    pwm_gecerli_ns = pwm_gecerli_r;
    pwm_tilefields_ns = pwm_tilefields_r;
    pwm_tilefields_ns[`TL_D_SIZE] = 5; 

    if ((pwm_gecerli_o && pwm_hazir_i) || pwm_tilefields_r[`TL_D_OP] == `TL_OP_ACK) begin
        pwm_gecerli_ns = `LOW;
    end

    if(cek_pwm_istek_w) begin
        case(cek_pwm_addr_w)
            `PWM_CTRL_1_REG: begin
                if(cek_pwm_yaz_w) begin
                    pwm_control_1_ns = cek_veri_i;
                    pwm_gecerli_ns = `HIGH;
                    pwm_tilefields_ns[`TL_D_OP] = `TL_OP_ACK;
                end
                else if (cek_pwm_oku_w) begin
                    pwm_veri_ns = pwm_control_1_r; 
                    pwm_gecerli_ns = `HIGH;
                    pwm_tilefields_ns[`TL_D_OP] = `TL_OP_ACK_DATA;
                end
            end
            `PWM_CTRL_2_REG: begin
                if(cek_pwm_yaz_w) begin
                    pwm_control_2_ns = cek_veri_i;
                    pwm_gecerli_ns = `HIGH;
                    pwm_tilefields_ns[`TL_D_OP] = `TL_OP_ACK;
                end
                else if (cek_pwm_oku_w) begin
                    pwm_veri_ns = pwm_control_2_r; 
                    pwm_gecerli_ns = `HIGH;
                    pwm_tilefields_ns[`TL_D_OP] = `TL_OP_ACK_DATA;
                end
            end
            `PWM_PERIOD_1_REG: begin
                if(cek_pwm_yaz_w) begin
                    pwm_period_1_ns = cek_veri_i;
                    pwm_gecerli_ns = `HIGH;
                    pwm_tilefields_ns[`TL_D_OP] = `TL_OP_ACK;
                end
                else if (cek_pwm_oku_w) begin
                    pwm_veri_ns = pwm_period_1_r; 
                    pwm_gecerli_ns = `HIGH;
                    pwm_tilefields_ns[`TL_D_OP] = `TL_OP_ACK_DATA;
                end
            end
            `PWM_PERIOD_2_REG: begin
                if(cek_pwm_yaz_w) begin
                    pwm_period_2_ns = cek_veri_i;
                    pwm_gecerli_ns = `HIGH;
                    pwm_tilefields_ns[`TL_D_OP] = `TL_OP_ACK;
                end     
                else if (cek_pwm_oku_w) begin
                    pwm_veri_ns = pwm_period_2_r; 
                    pwm_gecerli_ns = `HIGH;
                    pwm_tilefields_ns[`TL_D_OP] = `TL_OP_ACK_DATA;
                end 
            end
            `PWM_THRSLD_1_1_REG: begin
                if( cek_pwm_yaz_w) begin
                    pwm_threshold_1_1_ns = cek_veri_i;
                    pwm_gecerli_ns = `HIGH;
                    pwm_tilefields_ns[`TL_D_OP] = `TL_OP_ACK;
                end
                else if (cek_pwm_oku_w) begin
                    pwm_veri_ns = pwm_threshold_1_1_r; 
                    pwm_gecerli_ns = `HIGH;
                    pwm_tilefields_ns[`TL_D_OP] = `TL_OP_ACK_DATA;
                end 
            end
            `PWM_THRSLD_1_2_REG: begin
                if( cek_pwm_yaz_w) begin
                    pwm_threshold_1_2_ns = cek_veri_i;
                    pwm_gecerli_ns = `HIGH;
                    pwm_tilefields_ns[`TL_D_OP] = `TL_OP_ACK;
                end
                else if (cek_pwm_oku_w) begin
                    pwm_veri_ns = pwm_threshold_1_2_r; 
                    pwm_gecerli_ns = `HIGH;
                    pwm_tilefields_ns[`TL_D_OP] = `TL_OP_ACK_DATA;
                end 
            end
            `PWM_THRSLD_2_1_REG: begin
                if( cek_pwm_yaz_w) begin
                    pwm_threshold_2_1_ns = cek_veri_i;
                    pwm_gecerli_ns = `HIGH;
                    pwm_tilefields_ns[`TL_D_OP] = `TL_OP_ACK;
                end     
                else if (cek_pwm_oku_w) begin
                    pwm_veri_ns = pwm_threshold_2_1_r; 
                    pwm_gecerli_ns = `HIGH;
                    pwm_tilefields_ns[`TL_D_OP] = `TL_OP_ACK_DATA;
                end 
            end
            `PWM_THRSLD_2_2_REG: begin
                if(cek_pwm_yaz_w) begin
                    pwm_threshold_2_2_ns = cek_veri_i;
                    pwm_gecerli_ns = `HIGH;
                    pwm_tilefields_ns[`TL_D_OP] = `TL_OP_ACK;
                end
                else if (cek_pwm_oku_w) begin
                    pwm_veri_ns = pwm_threshold_2_2_r; 
                    pwm_gecerli_ns = `HIGH;
                    pwm_tilefields_ns[`TL_D_OP] = `TL_OP_ACK_DATA;
                end 
            end
            `PWM_STEP_1_REG: begin
                if(cek_pwm_yaz_w) begin
                    pwm_step_1_ns = cek_veri_i;
                    pwm_gecerli_ns = `HIGH;
                    pwm_tilefields_ns[`TL_D_OP] = `TL_OP_ACK;
                end
                else if (cek_pwm_oku_w) begin
                    pwm_veri_ns = pwm_step_1_r; 
                    pwm_gecerli_ns = `HIGH;
                    pwm_tilefields_ns[`TL_D_OP] = `TL_OP_ACK_DATA;
                end 
            end
            `PWM_STEP_2_REG: begin
                if( cek_pwm_yaz_w) begin
                    pwm_step_2_ns = cek_veri_i;
                    pwm_gecerli_ns = `HIGH;
                    pwm_tilefields_ns[`TL_D_OP] = `TL_OP_ACK;
                end
                else if (cek_pwm_oku_w) begin
                    pwm_veri_ns = pwm_step_2_r; 
                    pwm_gecerli_ns = `HIGH;
                    pwm_tilefields_ns[`TL_D_OP] = `TL_OP_ACK_DATA;
                end 
            end
            `PWM_WRT_1_REG: begin
                if(cek_pwm_oku_w) begin
                    pwm_veri_ns = pwm_output_1_w;
                    pwm_gecerli_ns = `HIGH;
                    pwm_tilefields_ns[`TL_D_OP] = `TL_OP_ACK_DATA;
                end
            end
            `PWM_WRT_2_REG: begin
                if(cek_pwm_oku_w) begin
                    pwm_veri_ns = pwm_output_2_w;
                    pwm_gecerli_ns = `HIGH;
                    pwm_tilefields_ns[`TL_D_OP] = `TL_OP_ACK_DATA;
                end
            end
        endcase
    end
end

always@( posedge clk_i) begin
    if(!rstn_i) begin
        pwm_control_1_r <= 0;
        pwm_control_2_r <= 0;
        pwm_period_1_r <= 0;
        pwm_period_2_r <= 0;
        pwm_threshold_1_1_r <= 0;
        pwm_threshold_2_1_r <= 0;
        pwm_threshold_1_2_r <= 0;
        pwm_threshold_2_2_r <= 0;
        pwm_step_1_r <= 0;
        pwm_step_2_r <= 0;
        pwm_veri_r <= 0;
        pwm_gecerli_r <= 0;
        pwm_tilefields_r <= 0;
    end else begin
        pwm_control_1_r <= pwm_control_1_ns;
        pwm_control_2_r <= pwm_control_2_ns;
        pwm_period_1_r <= pwm_period_1_ns;
        pwm_period_2_r <= pwm_period_2_ns;
        pwm_threshold_1_1_r <= pwm_threshold_1_1_ns;
        pwm_threshold_2_1_r <= pwm_threshold_2_1_ns;
        pwm_threshold_1_2_r <= pwm_threshold_1_2_ns;
        pwm_threshold_2_2_r <= pwm_threshold_2_2_ns;
        pwm_step_1_r <= pwm_step_1_ns;
        pwm_step_2_r <= pwm_step_2_ns;
        pwm_veri_r <= pwm_veri_ns;
        pwm_gecerli_r <= pwm_gecerli_ns;
        pwm_tilefields_r <= pwm_tilefields_ns;
    end
end

endmodule