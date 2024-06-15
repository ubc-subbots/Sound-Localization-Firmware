/// # ADS8528 Memory Specification
///
/// ## Overview
///
/// This verilog code synethizes to 32 Kilo Bytes of RAM 
/// that stores the information collected by the
/// ADS8528 and sends it out in a FIFO style
///
/// ## IO Ports
/// clk: externally driven clk
/// rst: reset  
/// write: notifies the memory to prepare for write operation
/// read: notifies the memory to be read to output data
///
/// [DATA_WIDTH - 1:0] data_in : data input from the ADC
/// [DATA_WIDTH - 1:0] data_out: data output going towards the SPI for the raspberry PI
/// full: output to top level module to indicate the memory is full and cannot recieve anymore data
/// empty: output to top level module to indicate the memory is empty and cannot be read anymore
///
/// ## Parameters 
/// DEPTH: chosen to be 16384, as 16*16384 = 262144, i.e, just barely bigger then the memory needed
/// DATA_WIDTH: chosen to be 16, as ADC provides data in this format

  
module ADCmemory #(parameter DEPTH = 16384, DATA_WIDTH = 16) (
	input clk,
	input rst, 
	input write,
	input read, 
	
	input [DATA_WIDTH - 1:0] data_in,
	output logic [DATA_WIDTH - 1:0] data_out,
	output full,
	output empty
);
	
	logic [DATA_WIDTH-1:0] storage [DEPTH];
	logic [$clog2(DEPTH) - 1:0] write_ptr;
	logic  [$clog2(DEPTH) - 1:0] read_ptr;
	logic [$clog2(DEPTH) - 1:0] count;

	assign full = (count == DEPTH);
	assign empty = (count == 0);

	always_ff @(posedge clk) begin
		 if (!rst) begin
			  write_ptr <= 0;
			  read_ptr <= 0;
			  count <= 0;
		 end
		 else begin
			  if (write & !full) begin  
					storage[write_ptr] <= data_in;
					write_ptr <= write_ptr + 1;  //write_ptr over flows 
					count <= count + 1;
			  end
			  if (read & !empty) begin
					data_out <= storage[read_ptr];
					read_ptr <= read_ptr + 1;
					count <= count - 1;
			  end
		 end
	end
		

endmodule