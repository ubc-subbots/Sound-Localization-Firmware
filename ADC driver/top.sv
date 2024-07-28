module top(
	inout [15:0] DB,  //driver inputs
	input Busy,
	input CLOCK_27M,
	input rst,
	input KEY2,
	
	input sclk, //SPI inputs
	input SPI_cs,
	input transaction_done,
	
	output logic convst_A, //Driver outputs to ADC
	output logic convst_B,
	output logic convst_C,
	output logic convst_D,
	output logic RD_N, 
	output logic ADC_CS_N,
	output logic HW_N,
	output logic PAR_N,
	output logic ADCrst,
	output logic STBY_N,
	output logic WR_N,
	output logic XCLK,

	
	output logic processed_MISO //SPI outputs to Rasberry pi
);
	
	parameter [31:0] BUFFER_SAMPLE = 32'd10;
	parameter [15:0] VALID_VOLTAGE = 16'd32; 
	parameter [31:0] VALID_COUNT_NEEDED = 32'd4;
	parameter [31:0] REQUIRED_VOLTAGE = 32'd20;
	
	logic [15:0] toMem;
	logic mem_ready;
	
	logic mem_write;
	logic mem_read;
	logic [13:0] mem_count;
	logic [15:0] toSPI;
	logic full;
	logic empty;
	
	logic ready_for_data;
	
	
	logic [31:0] valid_count; 
	
	logic [31:0] count;

	logic clk; 
	
	assign ADCrst = ~KEY2;
	
	typedef enum {
		DEFAULT_WAIT, 
		JUNK,
		FILL_BUFFER,
		COLLECT_UNTIL_FULL,
		WAIT_FOR_FILL,
		SPI,
		WAIT_FOR_SPI 
	} state_t;
	
	state_t state; 
	
	Clk_divider Clk_divider_inst(
		.clk_in(CLOCK_27M),
		.divisor(32'd4),
		.switch(1'd1),
		.clk_out(clk)
	);
	
	assign XCLK = 1'b1; //should be clk
	
	driver driver_inst(
		.convst_A(convst_A),
		.convst_B(convst_B),
		.convst_C(convst_C),
		.convst_D(convst_D),
		.RD_N(RD_N),
		.CS_N(ADC_CS_N),
		.HW_N(HW_N),
		.PAR_N(PAR_N),
		.ADCrst(),
		.STBY_N(STBY_N),
		.WR_N(WR_N),
		.toMem(toMem),
		.mem_ready(mem_ready),
		.state_ff(),
		.DB(DB),
		.Busy(Busy),
		.rst(rst),
		.clk(clk)
	);
	
	ADCmemory ADCmemory_inst(
		.clk(clk),
		.rst(rst),
		.write(mem_write),
		.read(mem_read),
		.data_in(toMem),
		.count(mem_count),
		.data_out(toSPI),
		.full(full),
		.empty(empty)
	); 
	
	spi spi_inst(
		.rst(rst),
		.sclk(sclk),
		.cs(SPI_cs),
		.unprocessed_MISO(toSPI),
		.processed_MISO(processed_MISO),
		.ready_for_data(ready_for_data)
	);
		
	always_ff@(posedge clk or negedge rst) begin 
		if(~rst) begin
			state <= DEFAULT_WAIT;
		end else begin
			case(state) 
				DEFAULT_WAIT: begin
										if(mem_ready && (valid_count == VALID_COUNT_NEEDED))
											state <= COLLECT_UNTIL_FULL;
										else if(mem_ready && (mem_count < BUFFER_SAMPLE))
											state <= FILL_BUFFER;
										else if(mem_ready && (mem_count == BUFFER_SAMPLE))
											state <= JUNK;
										else 
											state <= DEFAULT_WAIT; 
								  end
				JUNK: state <= DEFAULT_WAIT; 
				FILL_BUFFER: state <= DEFAULT_WAIT; 
				COLLECT_UNTIL_FULL: begin
											if(count == REQUIRED_VOLTAGE) 
												state <= SPI;
											else 
												state <= WAIT_FOR_FILL;
										  end 
				WAIT_FOR_FILL: begin
											if(mem_ready)
												state <= COLLECT_UNTIL_FULL;
											else 
												state <= WAIT_FOR_FILL;
									end 
				SPI: begin
							if(empty) 
								state <= DEFAULT_WAIT;
							else 
								state <= WAIT_FOR_SPI;
					  end
				WAIT_FOR_SPI: begin	
										if(transaction_done)
											state <= SPI;
										else 
											state <= WAIT_FOR_SPI;
								  end 
				endcase 
		
		end
	end
	
	/*always_ff @(posedge clk or negedge rst) begin 
		if(~rst) begin
			valid_count <= 32'd0;
		end else begin
			case(state) 
				DEFAULT_WAIT: begin 
										mem_write <= 1'd0;
										mem_read <= 1'd0;
								  end 
				JUNK: begin
							mem_write <= 1'd1;
							mem_read <= 1'd1;
						end
				FILL_BUFFER: begin
									mem_read <= 1'd0;
								 end
				
				
		
		end
	
	
	end*/
	

		
	
endmodule
	
	
	
	
	
	