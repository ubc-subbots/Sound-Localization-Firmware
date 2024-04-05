module ADCmemory #(parameter DEPTH = 1048576, DATA_WIDTH = 16) (
	input clk,
	input rst, 
	input write,
	input read, 
	
	input [DATA_WIDTH - 1:0] data_in,
	output reg [DATA_WIDTH - 1:0] data_out,
	output full,
	output empty
);
	
	reg [DATA_WIDTH-1:0] storage [DEPTH];
	reg [$clog2(DEPTH) - 1:0] write_ptr;
	reg [$clog2(DEPTH) - 1:0] read_ptr;
	reg [$clog2(DEPTH) - 1:0] count;

	assign full = (count == DEPTH);
	assign empty = (count == 0);

	always_ff@(posedge clk)begin 
		if(!rst) begin
			write_ptr <= 0;
			read_ptr <= 0;
			data_out <= 0;
			count <= 0;
		end
	end

	
	always_ff@(posedge clk) begin
		if(write & !full) begin
			storage[write_ptr] <= data_in;
			write_ptr <= write_ptr + 1;
			count <= count + 1;
		end
	end
	
	always_ff@(posedge clk) begin
		if(read & !empty) begin
			data_out <= fifo[read_ptr];
			read_ptr <= read_ptr + 1;
			count <= count - 1;
		end
	
	
	end
	
	

endmodule