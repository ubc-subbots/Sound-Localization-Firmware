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

	
	output logic processed_MISO, //SPI outputs to Rasberry pi
	output logic SPI_RDY
);
	
	parameter [31:0] BUFFER_SAMPLE = 32'd50;
	parameter [15:0] VALID_VOLTAGE = 16'd32; 
	parameter [31:0] VALID_COUNT_NEEDED = 32'd20;
	parameter [31:0] REQUIRED_VOLTAGE = 32'd100;
	
	logic [15:0] toMem;
	logic mem_ready;
	
	logic mem_write;
	logic mem_read;
	logic [13:0] mem_count;
	logic [15:0] toSPI;
	logic full;
	logic empty;
	
	logic ready_for_data;
	
	
	logic [31:0] valid_count; //counter to indicate how many valid voltage we have gotten in a row, indicating if what we are detecting is a real pulse
	
	logic [31:0] count; //counter to indicate how many voltage we are storing in storage, and if this hits REQUIRED_VOLTAGE, we begin empting everything to SPI 

	logic clk; 
	
	assign ADCrst = ~KEY2;
	

	
	parameter [5:0] DEFAULT_WAIT = 6'd0,
						 JUNK = 6'b000011,
						 FILL_BUFFER = 6'b000001,
						 DUMP_EXCESS = 6'b001010,
						 COLLECT_UNTIL_FULL = 6'b001001,
						 WAIT_FOR_FILL = 6'b001000,
						 PASSING_DATA_TO_SPI = 6'b000010,
						 SPI = 6'b000100,   //6
						 WAIT_FOR_SPI = 6'b010000; //16
						 
   logic [5:0] state = DEFAULT_WAIT; 
	
	assign mem_write = state[0];
	assign mem_read = state[1];
	assign SPI_RDY = state[2];
	
	
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
										else if(mem_ready && (mem_count > BUFFER_SAMPLE))
											state <= DUMP_EXCESS;
										else 
											state <= DEFAULT_WAIT; 
								  end
				JUNK: state <= DEFAULT_WAIT; 
				FILL_BUFFER: state <= DEFAULT_WAIT; 
				COLLECT_UNTIL_FULL: begin
											if(count == REQUIRED_VOLTAGE) 
												state <= PASSING_DATA_TO_SPI;
											else 
												state <= WAIT_FOR_FILL;
										  end 
				WAIT_FOR_FILL: begin
											if(mem_ready)
												state <= COLLECT_UNTIL_FULL;
											else 
												state <= WAIT_FOR_FILL;
									end 
				PASSING_DATA_TO_SPI: begin
												state <= SPI;
											end
				SPI: begin
							if(empty) 
								state <= DEFAULT_WAIT;
							else if(~SPI_cs)
								state <= WAIT_FOR_SPI;
							else 
								state <= SPI;
					  end
				WAIT_FOR_SPI: begin	
										if(transaction_done)
											state <= PASSING_DATA_TO_SPI;
										else 
											state <= WAIT_FOR_SPI;
								  end 
				default: state <= DEFAULT_WAIT;
				endcase 
		
		end
	end
	
	always_ff@(posedge clk or negedge rst) begin
		if(~rst) begin
			valid_count <= 32'd0;
		end else begin
			if((((state == JUNK) || (state == FILL_BUFFER))) && ((toMem >= VALID_VOLTAGE) && (toMem < 16'b1111_1000_0000_0000))) 
				valid_count <= valid_count + 1'd1; 
			else if(state == COLLECT_UNTIL_FULL) 
				valid_count <= 32'd0; 
		end
	end
	
	always_ff@(posedge clk or negedge rst) begin
		if(~rst) begin
			count <= 32'd0;
		end else begin
			if(state == COLLECT_UNTIL_FULL)
				count <= count + 1'd1;
			else if(state == SPI) 
				count <= 32'd0;
		end
	end
		
	
endmodule
	
	
	
	
	
	