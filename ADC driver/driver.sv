/// # ADS8528 Driver Specification
///
/// ## Overview
///
/// This verilog code is suppose to config the ADC to run
/// in the paraelle setting with an external clk then collect data
/// on a frequent basis 
///
/// ## IO Ports
/// convst_X: notifies the adc X0 and X1 to start converting from analogue to digital
/// read: notifies the ADC the driver is ready to recieve data
/// CS: chip select, default high and should be switched low for any operation
/// HW: hardware/software select, this driver opts for the software option
/// PAR: paralle/serial select, this driver opts for paralle
/// rst: reset
/// STBY: not relevant for this implementation
/// write: notifies the ADC to prepare for write operation
/// 
/// Busy: default low, high when conversion is taking place, low again when conversion is finished
/// clk: externally driven clk
///
/// DB[15:0] : the input/output of the driver for data



module driver(
	output reg convst_A,
	output reg convst_B,
	output reg convst_C,
	output reg convst_D,
	
	output reg read, 
	output reg CS,
	output reg HW,
	output reg PAR,
	output rst,
	output STBY,
	output reg write,
	
	input Busy,
	inout [15:0] DB,
	input clk
);

	reg internalwrite = 1'b1; 
	reg [15:0] DBout;
	reg [15:0] toMemory;
	reg finishwrite = 1'b0;
	
	reg convstsent = 1'b0;
	reg isReading = 1'b0;
	reg readcycle = 3'b111;
	
	reg [2:0] writecount = 3'b100;
	
	reg [3:0] ADCread = 3'b101;
	
	assign DB = (!write) ? DBout : 16'bz;
	assign write = internalwrite;
	
	assign CS = 1'b0;
	assign HW = 1'b1;
	assign PAR = 1'b0;
		
	always_ff@(posedge clk) begin //Initial write procedure to set the config regs, runs only once
		
		if(finishwrite == 1'b0) begin
			if(writecount > 3'b0) begin
				writecount <= writecount - 1;
				internalwrite <= ~internalwrite;
			end
			
			if(writecount > 3'b010)begin
				DBout <= 16'b1010100000000;  //First sets of config
			end
			else begin 
				DBout <= 16'b0;   //Second set of config 
			end
			
			if(writecount == 3'b0) begin
				finishwrite <= 1'b1;
			end
		end
		
	end

	
	
	
	always_ff@(posedge clk) begin
		read <= 1'b1;
	
		if(convstsent == 1'b1 && Busy == 1'b0) begin
			isReading = 1'b1;
			if(readcycle == 3'b111) begin 
				read <= 1'b0;
				readcycle <= readcycle - 1'b1; 
			end else if (readcycle > 3'b000) begin
				toMemory <= DB; 
				readcycle <= readcycle - 1'b1; 
			end else begin
				readcycle <= 3'b111;
				ADCread <= ADCread - 1'b1;
			end
		end
		
		if(ADCread == 3'b000) begin
			isReading = 1'b0;
			convstsent = 1'b0;
			ADCread <= 3'b101;
		end
	
		
		if(convstsent == 1'b0 && isReading == 1'b0) begin //Not reading and have 
			convst_A = 1'b1;
			convst_B = 1'b1;
			convst_C = 1'b1;
			convst_D = 1'b1; 
			convstsent = 1'b1; 
		end else begin
			convst_A = 1'b0;
			convst_B = 1'b0;
			convst_C = 1'b0;
			convst_D = 1'b0;
		end
	

	

	
	end
	




endmodule 