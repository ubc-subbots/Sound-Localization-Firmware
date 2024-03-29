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
	output convst_A,
	output convst_B,
	output convst_C,
	output convst_D,
	
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
	reg finishwrite = 1'b0;
	
	reg [2:0] writecount = 3'b100;
	
	assign DB = (!write) ? DBout : 16'bz;
	assign write = internalwrite;
		
	always_ff@(posedge clk) begin //Initial write procedure to set the config regs, runs only once
		CS <= 1'b0;
		HW <= 1'b1;
		PAR <= 1'b0; 
		
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





endmodule 