`timescale 1ns / 1ps

module memory_model #(
    parameter BASE_ADDR     = 'h4000_0000,
    parameter MEM_DEPTH     = 'h0000_1000,
    parameter DATA_WIDTH    = 32, // MUST BE A POWER OF 2
    parameter ADDR_WIDTH    = 32,

    localparam DATA_BYTES   = DATA_WIDTH / 8,
    localparam BYTE_BITS   = $clog2(DATA_BYTES)
)(
    input                           clk_i,

    input       [ADDR_WIDTH-1:0]    cmd_addr,

    output reg  [DATA_WIDTH-1:0]    rd_data,
    input       [DATA_WIDTH-1:0]    wr_data,
    
    input                           wr_enable,
    input                           cmd_valid
);

reg [7:0] mem [0:MEM_DEPTH-1][0:DATA_BYTES-1];

wire valid_addr;
assign valid_addr = (cmd_addr & BASE_ADDR) == BASE_ADDR;

wire [ADDR_WIDTH-1:0] data_offset;
assign data_offset = (cmd_addr & ~BASE_ADDR);

wire [ADDR_WIDTH-1:0] addr_row;
assign addr_row = data_offset >> BYTE_BITS;

integer i;
integer j;
initial begin
    for (i = 0; i < MEM_DEPTH; i = i + 1) begin
        for (j = 0; j < DATA_BYTES; j = j + 1) begin
            mem[i][j] = i[7:0] * 4 + j;
        end
    end    
end

always @(posedge clk_i) begin
    if (cmd_valid && valid_addr) begin
        if (wr_enable) begin
            for (i = 0; i < DATA_BYTES; i = i + 1) begin
                mem[addr_row][i] = wr_data[i*8 +: 8];
            end
        end
        else begin
            for (i = 0; i < DATA_BYTES; i = i + 1) begin
                rd_data[i*8 +: 8] = mem[addr_row][i];
            end
        end
    end
    else begin
        for (i = 0; i < DATA_WIDTH; i = i + 1) begin
            rd_data[i] <= 'bX;
        end
    end
end

endmodule