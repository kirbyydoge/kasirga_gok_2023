`timescale 1ns/1ps

module tb_islemci();

reg                 clk;
reg                 resetn;
wire                iomem_valid;
reg                 iomem_ready;
wire    [3:0]       iomem_wstrb;
wire    [31:0]      iomem_addr;
wire    [31:0]      iomem_wdata;
wire    [31:0]      iomem_rdata;
wire                spi_cs_o;
wire                spi_sck_o;
wire                spi_mosi_o;
reg                 spi_miso_i;
wire                uart_tx_o;
reg                 uart_rx_i;
wire                pwm0_o;
wire                pwm1_o;

islemci islemci (
  .clk              ( clk ),
  .resetn           ( resetn ),
  .iomem_valid      ( iomem_valid ),
  .iomem_ready      ( iomem_ready ),
  .iomem_wstrb      ( iomem_wstrb ),
  .iomem_addr       ( iomem_addr ),
  .iomem_wdata      ( iomem_wdata ),
  .iomem_rdata      ( iomem_rdata ),
  .spi_cs_o         ( spi_cs_o ),
  .spi_sck_o        ( spi_sck_o ),
  .spi_mosi_o       ( spi_mosi_o ),
  .spi_miso_i       ( spi_miso_i ),
  .uart_tx_o        ( uart_tx_o ),
  .uart_rx_i        ( uart_rx_i ),
  .pwm0_o           ( pwm0_o ),
  .pwm1_o           ( pwm1_o )
);

wire    [31:0]    cmd_addr_w;
wire    [31:0]    rd_data_w;
wire    [31:0]    wr_data_w;
wire              wr_enable_w;
wire              cmd_valid_w;

memory_model #(
    .BASE_ADDR   ('h4000_0000), 
    .MEM_DEPTH   ('h0000_1000),
    .DATA_WIDTH  ('d32),
    .ADDR_WIDTH  ('d32)
)
mem (
    .clk_i          ( clk ),
    .cmd_addr_i     ( cmd_addr_w ),
    .rd_data_o      ( rd_data_w ),
    .wr_data_i      ( wr_data_w ),
    .wr_enable_i    ( wr_enable_w ),
    .cmd_valid_i    ( cmd_valid_w )
);

assign cmd_valid_w = iomem_valid;
assign wr_enable_w = |iomem_wstrb;
assign wr_data_w = iomem_wdata;
assign iomem_rdata = rd_data_w;
assign cmd_addr_w = iomem_addr;

always begin
    clk = 1'b0;
    #5;
    clk = 1'b1;
    #5;
end

localparam PATH_TO_TEST = "/home/kirbyydoge/teknofest_2023_test/rv32test/rv32imc-hex/rv32um-p-mul.hex"; 
localparam RAM_DELAY = 1;
reg [RAM_DELAY-1:0] delay_q;

always @(posedge clk) begin
    if (!resetn) begin
        delay_q <= 1'b0;
    end
    else begin
        if (!(|delay_q)) begin
            if (RAM_DELAY > 1) begin
                delay_q <= {delay_q[RAM_DELAY-2:0], iomem_valid};
            end
            else begin
                delay_q <= iomem_valid;
            end
        end
        else begin
            delay_q <= delay_q << 1;
        end
    end
end

always @* begin
    iomem_ready = delay_q[RAM_DELAY-1];
end

initial begin
    resetn = 1'b0;
    spi_miso_i = 1'b0;
    uart_rx_i = 1'b0;
    $readmemh(PATH_TO_TEST, mem.mem_r);
    repeat(20) @(posedge clk);
    resetn = 1'b1;
end

endmodule