`timescale 1ns/1ps

`include "sabitler.vh"

module spi_denetleyici (
    input                       clk_i,
    input                       rstn_i,

    input   [`ADRES_BIT-1:0]    cek_adres_i,
    input   [`VERI_BIT-1:0]     cek_veri_i,
    input                       cek_yaz_i,
    input                       cek_gecerli_i,
    output                      cek_hazir_o,

    output  [`VERI_BIT-1:0]     spi_veri_o,
    output                      spi_gecerli_o,
    input                       spi_hazir_i,

    input                       miso_i,
    output                      mosi_o,
    output                      csn_o,
    output                      sck_o
);

wire        cek_spi_istek_w;
wire [3:0]  cek_spi_addr_w;

assign cek_spi_istek_w = ((cek_adres_i & ~`SPI_MASK_ADDR) == `SPI_BASE_ADDR) && cek_gecerli_i;
assign cek_spi_addr_w = cek_adres_i & `SPI_MASK_ADDR;

reg [31:0]      fifo_miso_wr_data_cmb;
reg             fifo_miso_wr_en_cmb;
wire [31:0]     fifo_miso_rd_data_w;
reg             fifo_miso_rd_en_cmb;
wire            fifo_miso_full_w;
wire            fifo_miso_empty_w;

reg [31:0]      fifo_mosi_wr_data_cmb;
reg             fifo_mosi_wr_en_cmb;
wire [31:0]     fifo_mosi_rd_data_w;
reg             fifo_mosi_rd_en_cmb;
wire            fifo_mosi_full_w;
wire            fifo_mosi_empty_w;

reg [31:0]      fifo_cmd_wr_data_cmb;
reg             fifo_cmd_wr_en_cmb;
wire [31:0]     fifo_cmd_rd_data_w;
reg             fifo_cmd_rd_en_cmb;
wire            fifo_cmd_full_w;
wire            fifo_cmd_empty_w;

reg [`VERI_BIT-1:0] spi_veri_r;
reg [`VERI_BIT-1:0] spi_veri_ns;

reg [`VERI_BIT-1:0] fifo_buf_veri_r;
reg [`VERI_BIT-1:0] fifo_buf_veri_ns;

reg [`VERI_BIT-1:0] fifo_buf_miso_r;
reg [`VERI_BIT-1:0] fifo_buf_miso_ns;

reg         spi_gecerli_r;
reg         spi_gecerli_ns;

reg [31:0]  spi_ctrl_r;
reg [31:0]  spi_ctrl_ns;

wire        spi_ctrl_en_w;
wire        spi_ctrl_rst_w;
wire        spi_ctrl_cpha_w;
wire        spi_ctrl_cpol_w;
wire [15:0] spi_ctrl_sck_div_w;

wire [31:0] spi_status_w;

reg         cek_hazir_r;
reg         cek_hazir_ns;

localparam  DURUM_BOSTA = 'd0;
localparam  DURUM_VERI_BEKLE = 'd1;
localparam  DURUM_MOSI_YER_BEKLE = 'd2;
localparam  DURUM_CMD_YER_BEKLE = 'd3;

localparam  DURUM_EXE_BOSTA = 'd0;
localparam  DURUM_EXE_BASLAT = 'd1;
localparam  DURUM_EXE_OKU_BEKLE = 'd2;
localparam  DURUM_EXE_VERI_BEKLE = 'd3;
localparam  DURUM_EXE_YER_BEKLE = 'd4;

reg [1:0]   durum_r;
reg [1:0]   durum_ns;

reg [2:0]   durum_exe_r;
reg [2:0]   durum_exe_ns;

reg [1:0]   exe_cmd_yon_r;
reg [1:0]   exe_cmd_yon_ns;

reg         exe_cs_end_r;
reg         exe_cs_end_ns;

reg [9:0]   exe_kalan_r;
reg [9:0]   exe_kalan_ns;

reg                             sb_cmd_msb_first_cmb;
reg     [`SPI_TXN_SIZE-1:0]     sb_cmd_data_cmb;
reg                             sb_cmd_valid_cmb;
reg                             sb_cmd_cpha_cmb;
reg                             sb_cmd_cpol_cmb;
reg     [15:0]                  sb_cmd_sck_div_cmb;
reg                             sb_cmd_end_cs_cmb;
reg     [1:0]                   sb_cmd_dir_cmb;
wire                            sb_cmd_ready_w;
wire    [`SPI_TXN_SIZE-1:0]     sb_recv_data_w;
wire                            sb_recv_data_valid_w;

localparam  KOMUT_BOS = 2'b00;
localparam  KOMUT_OKU = 2'b01;
localparam  KOMUT_YAZ = 2'b10;

always @* begin
    spi_gecerli_ns = spi_gecerli_r;
    spi_veri_ns = spi_veri_r;
    durum_ns = durum_r;
    durum_exe_ns = durum_exe_r;
    exe_cmd_yon_ns = exe_cmd_yon_r;
    exe_cs_end_ns = exe_cs_end_r;
    exe_kalan_ns = exe_kalan_r;
    fifo_miso_wr_data_cmb = 0;
    fifo_mosi_wr_data_cmb = 0;
    fifo_cmd_wr_data_cmb = 0;
    fifo_miso_wr_en_cmb = `LOW;
    fifo_miso_rd_en_cmb = `LOW;
    fifo_mosi_wr_en_cmb = `LOW;
    fifo_mosi_rd_en_cmb = `LOW;
    fifo_cmd_wr_en_cmb = `LOW;
    fifo_cmd_rd_en_cmb = `LOW;

    if (spi_gecerli_o && spi_hazir_i) begin
        spi_gecerli_ns = `LOW;
    end

    case(durum_r)
    DURUM_BOSTA: begin
        if (cek_spi_istek_w) begin
            case(cek_spi_addr_w)
            `SPI_CTRL_REG: begin
                if (cek_yaz_i) begin
                    spi_ctrl_ns = cek_veri_i;
                end
            end
            `SPI_STATUS_REG: begin
                if (!cek_yaz_i) begin
                    spi_veri_ns = spi_status_w;
                    spi_gecerli_ns = `HIGH;
                end
            end
            `SPI_RDATA_REG: begin
                if (!cek_yaz_i) begin
                    if (fifo_miso_empty_w) begin
                        durum_ns = DURUM_VERI_BEKLE;
                    end
                    else begin
                        spi_veri_ns = fifo_miso_rd_data_w;
                        spi_gecerli_ns = `HIGH;
                    end
                end
            end
            `SPI_WDATA_REG: begin
                if (cek_yaz_i) begin
                    if (fifo_mosi_full_w) begin
                        fifo_buf_veri_ns = cek_veri_i;
                        durum_ns = DURUM_MOSI_YER_BEKLE;
                    end
                    else begin
                        fifo_mosi_wr_data_cmb = cek_veri_i;
                        fifo_mosi_wr_en_cmb = `HIGH;
                    end
                end
            end
            `SPI_CMD_REG: begin
                if (cek_yaz_i) begin
                    if (fifo_cmd_full_w) begin
                        fifo_buf_veri_ns = cek_veri_i;
                        durum_ns = DURUM_CMD_YER_BEKLE;
                    end
                    else begin
                        fifo_cmd_wr_data_cmb = cek_veri_i;
                        fifo_cmd_wr_en_cmb = `HIGH;
                    end
                end
            end
            endcase
        end
    end
    DURUM_VERI_BEKLE: begin
        if (!fifo_miso_empty_w) begin
            spi_veri_ns = fifo_miso_rd_data_w;
            spi_gecerli_ns = `HIGH;
            durum_ns = DURUM_BOSTA;
        end
    end
    DURUM_MOSI_YER_BEKLE: begin
        if (!fifo_mosi_full_w) begin
            fifo_mosi_wr_data_cmb = fifo_buf_veri_r;
            fifo_mosi_wr_en_cmb = `HIGH;
            durum_ns = DURUM_BOSTA;
        end
    end
    DURUM_CMD_YER_BEKLE: begin
        if (!fifo_cmd_full_w) begin
            fifo_cmd_wr_data_cmb = fifo_buf_veri_r;
            fifo_cmd_wr_en_cmb = `HIGH;
            durum_ns = DURUM_BOSTA;
        end
    end
    endcase

    sb_cmd_cpha_cmb = 0;
    sb_cmd_cpol_cmb = 0;
    sb_cmd_dir_cmb = 0;
    sb_cmd_data_cmb = 0;
    sb_cmd_end_cs_cmb = 0;
    sb_cmd_msb_first_cmb = 0;
    sb_cmd_sck_div_cmb = 0;
    sb_cmd_valid_cmb = 0;

    case(durum_exe_r)
    DURUM_EXE_BOSTA: begin
        if (!fifo_cmd_empty_w && spi_ctrl_en_w) begin
            exe_kalan_ns = fifo_cmd_rd_data_w[8:0] + 10'd1;
            exe_cs_end_ns = fifo_cmd_rd_data_w[9];
            exe_cmd_yon_ns = fifo_cmd_rd_data_w[13:12];
            fifo_cmd_rd_en_cmb = `HIGH;
            durum_exe_ns = DURUM_EXE_BASLAT;
        end
    end
    DURUM_EXE_BASLAT: begin
        if (exe_cmd_yon_r == KOMUT_YAZ && fifo_mosi_empty_w) begin
            durum_exe_ns = DURUM_EXE_VERI_BEKLE;
        end
        else if (exe_kalan_r == 0) begin
            durum_exe_ns = DURUM_EXE_BOSTA;
        end
        else if (sb_cmd_ready_w) begin
            sb_cmd_cpha_cmb = spi_ctrl_cpha_w;
            sb_cmd_cpol_cmb = spi_ctrl_cpol_w;
            sb_cmd_dir_cmb = exe_cmd_yon_r;
            sb_cmd_data_cmb = fifo_mosi_rd_data_w;
            fifo_mosi_rd_en_cmb = exe_cmd_yon_r == KOMUT_YAZ;
            sb_cmd_end_cs_cmb = exe_kalan_r == 1 ? exe_cs_end_r : `LOW;
            sb_cmd_msb_first_cmb = `HIGH;
            sb_cmd_sck_div_cmb = spi_ctrl_sck_div_w;
            sb_cmd_valid_cmb = `HIGH;
            exe_kalan_ns = exe_kalan_r - 1;
            durum_exe_ns = exe_cmd_yon_r == KOMUT_OKU ? DURUM_EXE_OKU_BEKLE : DURUM_EXE_BASLAT;
        end
    end
    DURUM_EXE_OKU_BEKLE: begin
        if (sb_recv_data_valid_w) begin
            if (fifo_miso_full_w) begin
                fifo_miso_wr_data_cmb = sb_recv_data_w;
                fifo_miso_wr_en_cmb = `HIGH;
                durum_exe_ns = DURUM_EXE_BASLAT;
            end
            else begin
                fifo_buf_miso_ns = sb_recv_data_w;
                durum_exe_ns = DURUM_EXE_YER_BEKLE;
            end 
        end
    end
    DURUM_EXE_YER_BEKLE: begin
        if (!fifo_miso_full_w) begin
            fifo_miso_wr_data_cmb = fifo_buf_miso_r;
            fifo_miso_wr_en_cmb = `HIGH;
            durum_exe_ns = DURUM_EXE_BASLAT;
        end
    end
    DURUM_EXE_VERI_BEKLE: begin
        if (!fifo_mosi_empty_w) begin
            durum_exe_ns = DURUM_EXE_BASLAT;
        end
    end
    endcase

    cek_hazir_ns = durum_ns == DURUM_BOSTA;
end

always @(posedge clk_i) begin
    if (!rstn_i) begin
        spi_veri_r <= 0;
        fifo_buf_veri_r <= 0;
        fifo_buf_miso_r <= 0;
        spi_gecerli_r <= 0;
        spi_ctrl_r <= 0;
        cek_hazir_r <= 0;
        durum_r <= 0;
        durum_exe_r <= 0;
        exe_cmd_yon_r <= 0;
        exe_cs_end_r <= 0;
        exe_kalan_r <= 0;
    end
    else begin
        spi_veri_r <= spi_veri_ns;
        fifo_buf_veri_r <= fifo_buf_veri_ns;
        fifo_buf_miso_r <= fifo_buf_miso_ns;
        spi_gecerli_r <= spi_gecerli_ns;
        spi_ctrl_r <= spi_ctrl_ns;
        cek_hazir_r <= cek_hazir_ns;
        durum_r <= durum_ns;
        durum_exe_r <= durum_exe_ns;
        exe_cmd_yon_r <= exe_cmd_yon_ns;
        exe_cs_end_r <= exe_cs_end_ns;
        exe_kalan_r <= exe_kalan_ns;
    end
end

spi_birimi spi (
    .clk_i               ( clk_i ),
    .rstn_i              ( rstn_i ),
    .cmd_msb_first_i     ( sb_cmd_msb_first_cmb ),
    .cmd_data_i          ( sb_cmd_data_cmb ),
    .cmd_valid_i         ( sb_cmd_valid_cmb ),
    .cmd_cpha_i          ( sb_cmd_cpha_cmb ),
    .cmd_cpol_i          ( sb_cmd_cpol_cmb ),
    .cmd_sck_div_i       ( sb_cmd_sck_div_cmb ),
    .cmd_end_cs_i        ( sb_cmd_end_cs_cmb ),
    .cmd_dir_i           ( sb_cmd_dir_cmb ),
    .cmd_ready_o         ( sb_cmd_ready_w ),
    .recv_data_o         ( sb_recv_data_w ),
    .recv_data_valid_o   ( sb_recv_data_valid_w ),
    .miso_i              ( miso_i ),
    .mosi_o              ( mosi_o ),
    .csn_o               ( csn_o ),
    .sck_o               ( sck_o )
); 

fifo #(
    .DATA_WIDTH(32),
    .DATA_DEPTH(8)
) fifo_miso (
    .clk_i      ( clk_i ),
    .rstn_i     ( rstn_i ),
    .data_i     ( fifo_miso_wr_data_cmb ),
    .wr_en_i    ( fifo_miso_wr_en_cmb ),
    .data_o     ( fifo_miso_rd_data_w ),
    .rd_en_i    ( fifo_miso_rd_en_cmb ),
    .full_o     ( fifo_miso_full_w ),
    .empty_o    ( fifo_miso_empty_w )
);

fifo #(
    .DATA_WIDTH(32),
    .DATA_DEPTH(8)
) fifo_mosi (
    .clk_i      ( clk_i ),
    .rstn_i     ( rstn_i ),
    .data_i     ( fifo_mosi_wr_data_cmb ),
    .wr_en_i    ( fifo_mosi_wr_en_cmb ),
    .data_o     ( fifo_mosi_rd_data_w ),
    .rd_en_i    ( fifo_mosi_rd_en_cmb ),
    .full_o     ( fifo_mosi_full_w ),
    .empty_o    ( fifo_mosi_empty_w )
);

fifo #(
    .DATA_WIDTH(32),
    .DATA_DEPTH(8)
) fifo_cmd (
    .clk_i      ( clk_i ),
    .rstn_i     ( rstn_i ),
    .data_i     ( fifo_cmd_wr_data_cmb ),
    .wr_en_i    ( fifo_cmd_wr_en_cmb ),
    .data_o     ( fifo_cmd_rd_data_w ),
    .rd_en_i    ( fifo_cmd_rd_en_cmb ),
    .full_o     ( fifo_cmd_full_w ),
    .empty_o    ( fifo_cmd_empty_w )
);

assign spi_ctrl_en_w = spi_ctrl_r[0];
assign spi_ctrl_rst_w = spi_ctrl_r[1];
assign spi_ctrl_cpha_w = spi_ctrl_r[2];
assign spi_ctrl_cpol_w = spi_ctrl_r[3];
assign spi_ctrl_sck_div_w = spi_ctrl_r[31:16];
assign spi_veri_o = spi_veri_r;
assign spi_gecerli_o = spi_gecerli_r;
assign cek_hazir_o = cek_hazir_r;

endmodule