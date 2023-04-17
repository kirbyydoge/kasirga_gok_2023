`timescale 1ns/1ps

`include "sabitler.vh"

module spi_birimi (
    input                           clk_i,
    input                           rstn_i,

    input                           cmd_msb_first_i,
    input  [`SPI_TXN_SIZE-1:0]      cmd_data_i,
    input                           cmd_valid_i,
    input                           cmd_cpha_i,
    input                           cmd_cpol_i,
    input  [15:0]                   cmd_sck_div_i,
    input                           cmd_end_cs_i,
    input  [1:0]                    cmd_dir_i,
    input                           cmd_hint_i,
    output                          cmd_ready_o,

    output [`SPI_TXN_SIZE-1:0]      recv_data_o,
    output                          recv_data_valid_o,

    input                           miso_i,
    output                          mosi_o,
    output                          csn_o,
    output                          sck_o
); 

ila_spi debug_spi (
    .clk        (clk_i),
    .probe0     (csn_o),
    .probe1     (sck_o),
    .probe2     (mosi_o),
    .probe3     (miso_i)
);

reg           cmd_hint_r;
reg           cmd_hint_ns;

reg  [15:0]   cmd_sck_div_r;
reg  [15:0]   cmd_sck_div_ns;

reg           cmd_end_cs_r;
reg           cmd_end_cs_ns;

reg  [1:0]    cmd_dir_r;
reg  [1:0]    cmd_dir_ns;

reg  [15:0]   sck_sayac_r;
reg  [15:0]   sck_sayac_ns;

reg           sck_clk_r;
reg           sck_clk_ns;

reg           sck_posedge_r;
reg           sck_posedge_ns;

reg           sck_negedge_r;
reg           sck_negedge_ns;

reg           sck_enable_r;
reg           sck_enable_ns;

reg           sck_sample_cmb;
reg           sck_flip_cmb;

reg           cmd_ready_cmb;

reg  [5:0]    transfer_sayac_r;
reg  [5:0]    transfer_sayac_ns;

reg           recv_valid_r;
reg           recv_valid_ns;

reg  [`SPI_TXN_SIZE-1:0] buf_mosi_r;
reg  [`SPI_TXN_SIZE-1:0] buf_mosi_ns;

reg  [`SPI_TXN_SIZE-1:0] buf_miso_r;
reg  [`SPI_TXN_SIZE-1:0] buf_miso_ns;

reg           mosi_r;
reg           mosi_ns;

reg           csn_r;
reg           csn_ns;

wire [`SPI_TXN_SIZE-1:0] cmd_data_reversed_w;
wire [`SPI_TXN_SIZE-1:0] miso_data_reversed_w;

reg                      recv_data_valid_cmb;

genvar gen_i;
generate
    for (gen_i = 0; gen_i < `SPI_TXN_SIZE; gen_i = gen_i + 1) begin
        assign cmd_data_reversed_w[gen_i] = cmd_data_i[`SPI_TXN_SIZE - gen_i - 1];
        assign miso_data_reversed_w[gen_i] = buf_miso_r[`SPI_TXN_SIZE - gen_i - 1];
    end
endgenerate

localparam    DURUM_BOSTA = 'd0;
localparam    DURUM_BASLA = 'd1;
localparam    DURUM_GONDER = 'd2;
localparam    DURUM_GETIR = 'd3;

reg [1:0] durum_r;
reg [1:0] durum_ns;

reg [4:0] clock_edge_ctr_r;
reg [4:0] clock_edge_ctr_ns;

reg ancestor_valid_r;
reg ancestor_valid_ns;

always @* begin
    ancestor_valid_ns = ancestor_valid_r;
    cmd_hint_ns = cmd_hint_r;
    clock_edge_ctr_ns = clock_edge_ctr_r;
    durum_ns = durum_r;
    cmd_sck_div_ns = cmd_sck_div_r;
    cmd_end_cs_ns = cmd_end_cs_r;
    cmd_dir_ns = cmd_dir_r;
    sck_sayac_ns = sck_sayac_r;
    sck_clk_ns = sck_clk_r;
    sck_posedge_ns = sck_posedge_r;
    sck_negedge_ns = sck_negedge_r;
    sck_enable_ns = sck_enable_r;
    transfer_sayac_ns = transfer_sayac_r;
    buf_mosi_ns = buf_mosi_r;
    buf_miso_ns = buf_miso_r;
    mosi_ns = mosi_r;
    csn_ns = csn_r;
    recv_valid_ns = recv_valid_r;
    recv_data_valid_cmb = `LOW;

    cmd_ready_cmb = `LOW;
    sck_sample_cmb = cmd_cpol_i ^ cmd_cpha_i ? sck_negedge_r : sck_posedge_r;
    sck_flip_cmb = cmd_cpol_i ^ cmd_cpha_i ? sck_posedge_r : sck_negedge_r;

    sck_clk_ns = sck_sayac_r == cmd_sck_div_i ? !sck_clk_r : sck_clk_r;

    sck_posedge_ns = (sck_clk_ns ^ sck_clk_r) && !sck_clk_r;
    sck_negedge_ns = (sck_clk_ns ^ sck_clk_r) && sck_clk_r;

    sck_sayac_ns = sck_enable_r ? sck_sayac_r + 16'b1 : 16'b0;

    if (sck_posedge_ns || sck_negedge_ns) begin
        clock_edge_ctr_ns = clock_edge_ctr_r + 1;
    end

    if (sck_clk_ns ^ sck_clk_r) begin
        sck_sayac_ns = 0;
    end

    case(durum_r)
    DURUM_BOSTA: begin
        cmd_ready_cmb = `HIGH;
        sck_clk_ns = cmd_cpol_i;
        if (cmd_ready_o && cmd_valid_i) begin
            cmd_hint_ns = cmd_hint_i;
            cmd_end_cs_ns = cmd_end_cs_i;
            cmd_dir_ns = cmd_dir_i;
            buf_mosi_ns = cmd_msb_first_i ? cmd_data_reversed_w : cmd_data_i;
            transfer_sayac_ns = 5'b0;

            durum_ns = DURUM_BASLA;
        end
    end
    DURUM_BASLA: begin
        sck_sayac_ns = 15'd0;
        mosi_ns = cmd_cpha_i ? mosi_r : buf_mosi_r[transfer_sayac_r];
        csn_ns = cmd_dir_r[1] || cmd_dir_r[0] ? `LOW : csn_r;
        sck_enable_ns = cmd_dir_r[1] || cmd_dir_r[0];
        recv_valid_ns = ancestor_valid_r || !cmd_cpha_i;
        clock_edge_ctr_ns = 0;
        transfer_sayac_ns = cmd_dir_r[1] ? !cmd_cpha_i : 1'b0;
        ancestor_valid_ns = !cmd_hint_r;

        durum_ns =  cmd_dir_r[1] ? DURUM_GONDER :
                    cmd_dir_r[0] ? DURUM_GETIR  : DURUM_BOSTA;
    end
    DURUM_GONDER: begin
        if (sck_flip_cmb && transfer_sayac_r < `SPI_TXN_SIZE) begin
            transfer_sayac_ns = transfer_sayac_r + 5'b1;
            mosi_ns = buf_mosi_r[transfer_sayac_r];
        end
        if (clock_edge_ctr_ns == 2 * `SPI_TXN_SIZE + cmd_hint_r) begin
            csn_ns = cmd_end_cs_r;
            durum_ns = DURUM_BOSTA;
            sck_enable_ns = `LOW;
            sck_clk_ns = sck_clk_r;
        end
    end
    DURUM_GETIR: begin
        if (sck_flip_cmb) begin
            recv_valid_ns = `HIGH;
        end
        if (sck_sample_cmb && recv_valid_r && transfer_sayac_r < `SPI_TXN_SIZE) begin
            buf_miso_ns[transfer_sayac_r] = miso_i;
            transfer_sayac_ns = transfer_sayac_r + 5'b1;
        end
        if (clock_edge_ctr_ns == 2 * `SPI_TXN_SIZE + cmd_hint_r) begin
            csn_ns = cmd_end_cs_r;
            durum_ns = DURUM_BOSTA;
            recv_data_valid_cmb = `HIGH;
            sck_enable_ns = `LOW;
            sck_clk_ns = sck_clk_r;
        end
    end
    endcase
end


always @(posedge clk_i) begin
    if (!rstn_i) begin
        durum_r <= DURUM_BOSTA;
        cmd_end_cs_r <= 0;
        cmd_dir_r <= 0;
        sck_sayac_r <= 0;
        sck_clk_r <= 0;
        sck_posedge_r <= 0;
        sck_negedge_r <= 0;
        sck_enable_r <= 0;
        transfer_sayac_r <= 0;
        buf_mosi_r <= 0;
        buf_miso_r <= 0;
        mosi_r <= 0;
        csn_r <= `HIGH;
        recv_valid_r <= 0;
        clock_edge_ctr_r <= 0;
        cmd_hint_r <= 0;
        ancestor_valid_r <= 0;
    end
    else begin
        durum_r <= durum_ns;
        cmd_end_cs_r <= cmd_end_cs_ns;
        cmd_dir_r = cmd_dir_ns;
        sck_sayac_r <= sck_sayac_ns;
        sck_clk_r <= sck_clk_ns;
        sck_posedge_r <= sck_posedge_ns;
        sck_negedge_r <= sck_negedge_ns;
        sck_enable_r <= sck_enable_ns;
        transfer_sayac_r <= transfer_sayac_ns;
        buf_mosi_r <= buf_mosi_ns;
        buf_miso_r <= buf_miso_ns;
        mosi_r <= mosi_ns;
        csn_r <= csn_ns;
        recv_valid_r <= recv_valid_ns;
        clock_edge_ctr_r <= clock_edge_ctr_ns;
        cmd_hint_r <= cmd_hint_ns;
        ancestor_valid_r <= ancestor_valid_ns;
    end
end

assign cmd_ready_o = cmd_ready_cmb;
assign mosi_o = mosi_r;
assign csn_o = csn_r;
assign sck_o = sck_clk_r;
assign recv_data_o = cmd_msb_first_i ? miso_data_reversed_w : buf_miso_r;
assign recv_data_valid_o = recv_data_valid_cmb;

endmodule