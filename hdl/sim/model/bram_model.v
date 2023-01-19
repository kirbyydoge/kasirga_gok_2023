`timescale 1ns/1ps

module bram_model #(
	parameter DATA_WIDTH = 32,
	parameter BRAM_DEPTH = 128,
	parameter HARDCORE_DEBUG = "FALSE",

	localparam ADDR_WIDTH = $clog2(BRAM_DEPTH)
)(
	input 						clk_i,
	
	input	[DATA_WIDTH-1:0]	data_i,
	input	[ADDR_WIDTH-1:0]	addr_i,
	input						wr_en_i,
	input						cmd_en_i,
	output	[DATA_WIDTH-1:0]	data_o
);

localparam UNDEFINED = HARDCORE_DEBUG == "TRUE" ? {DATA_WIDTH{1'bZ}} : {DATA_WIDTH{1'b0}};

reg [DATA_WIDTH-1:0] mem_r [0:BRAM_DEPTH-1];
reg [DATA_WIDTH-1:0] data_r;

integer i;
initial begin
	for (i = 0; i < BRAM_DEPTH; i = i + 1) begin
		mem_r[i] <= UNDEFINED;
	end
	data_r <= UNDEFINED;
end

always @(posedge clk_i) begin
	if (cmd_en_i) begin
		if (wr_en_i) begin
			mem_r[addr_i] <= data_i;
			if (HARDCORE_DEBUG == "TRUE") begin
				data_r <= UNDEFINED;
			end
		end
		else begin
			data_r <= mem_r[addr_i];
		end
	end
end

assign data_o = data_r;

endmodule
