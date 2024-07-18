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
/// toMem[15:0] : the data to be sent to FPGA's memory for processing later
/// 
/// Busy: default low, high when conversion is taking place, low again when conversion is finished
/// clk: externally driven clk
///
/// DB[15:0] : the input/output of the driver for data


module driver(
	output logic convst_A,
	output logic convst_B,
	output logic convst_C,
	output logic convst_D,
	
	output logic read, 
	output logic CS,
	output logic HW,
	output logic PAR,
	output logic ADCrst,
	output logic STBY,
	output logic write,
	
	output logic [15:0] toMem,
	output logic mem_ready,
	
	input rst,
	input Busy,
	inout [15:0] DB,
	input clk
);

	typedef enum {
		HOLD,
		INIT,
		BUSY,
		RDWAIT,
		READDB,
		SAFE,
		CAPTURE,
		MEM
	} state_t;

		
	logic [15:0] DBout;
	logic finishwrite;
	
	logic convstsent;
	logic isReading;
	
	logic [15:0] memreg;
	
	logic [6:0] writecount;
	
	logic [3:0] ADCread; //counter of which ADC we are on, should reset to 0 after we hit 5
		
	state_t state_ff;
	
	assign DB = (!write) ? DBout : 16'bz;
	
	//assign CS = 1'b0;
	assign HW = 1'b1;
	assign PAR = 1'b0;
	assign STBY = 1'b1;
	
	
	
	
	always_ff@(posedge clk) begin
		if(!rst) begin
			CS                  <= 1'b1;
		end else begin
			if(finishwrite == 1'b0) begin
				if(writecount > 6'd28) begin
					CS            <= 1'b0;
				end else begin
					CS            <= 1'b1;
				end				
			end else begin
				if(convstsent || (state_ff == BUSY || state_ff == MEM))
					CS            <= 1'b1;
				else 
					CS            <= 1'b1;
			end
		
		end
	
	end
	
	
	always_ff@(posedge clk)begin 
		if(!rst) begin
			write               <= 1'b1;
			finishwrite         <= 1'b0;
			isReading           <= 1'b0;
			writecount          <= 6'd32;
		end else begin 
			if(finishwrite == 1'b0) begin
				if(writecount > 6'd0) begin
					writecount    <= writecount - 1;
				end else begin
					finishwrite   <= 1'b1;
				end
				
				if(writecount > 6'd28) begin
					write 		  <= ~write;
					//CS            <= 1'b0;
				end else begin
					write 		  <= 1'b1;
					//CS            <= 1'b1;
				end
				
				if(writecount > 6'd30)begin
					DBout         <= 16'b0000_0000_0000_0000;  //First sets of config  intended config:  default 16'd0
				end
				else begin 
					DBout         <= 16'b0000_0011_1111_1111;   //Second set of config 
				end
				
				if(writecount == 6'd26 || writecount == 6'd6) begin
					convst_D      <= 1'b1;
				end else begin
					convst_D      <= 1'b0;
				end

			end
			
		end
	end
		


	
	always_ff@(posedge clk) begin
		if(!rst) begin
				state_ff         <= HOLD; 
				ADCread          <= 3'b000;
			   convstsent       <= 1'b0;
				read             <= 1'b1;
				mem_ready        <= 1'b0;
				
		end else begin
			case(state_ff) 
				//HOLD: The state before the driver finish writing 
				HOLD: 
					if(finishwrite)
						state_ff   <= INIT;
					else
						state_ff   <= HOLD;
				//INIT: The conversion signal is sent in this state
				INIT: 
					if(convstsent)  
						state_ff   <= BUSY;
					else
						state_ff   <= INIT;
				//BUSY: The state that waits for busy to go low and then sets read low
				BUSY: 
					if(Busy == 1'b0 && ADCread != 3'b101) 
						state_ff   <= MEM;
					else if(ADCread == 3'b101)
						state_ff   <= INIT;
					else 
						state_ff   <= BUSY; 
				//MEM: The state where the ADC reading is sent to memory
				MEM:
					state_ff      <= BUSY;
			endcase
			
			case(state_ff) 
				HOLD:
					begin
						read       <= 1'b0;  //should be 1
						convst_A   <= 1'b0;
						convst_B   <= 1'b0;
						convst_C   <= 1'b0;
						//convst_D   <= 1'b0; 
						convstsent <= 1'b0; 
						mem_ready  <= 1'b0;
					end
				INIT:
					begin 
						convst_A   <= 1'b0; //should be 1
						convst_B   <= 1'b1;
						convst_C   <= 1'b1;
						//convst_D   <= 1'b1; 
						convstsent <= 1'b1; 
						ADCread    <= 3'b000;
						read       <= 1'b1;
					end
				BUSY:
					begin
						if(Busy == 1'b0 && ADCread != 3'b101) begin
							read    <= 0;
							memreg  <= DB;
						end else begin
							read    <= 1'b0;   //should be 1;
							memreg  <= DB;
						end
						convstsent <= 1'b0; 
						convst_A   <= 1'b0; 
						convst_B   <= 1'b0; 
						convst_C   <= 1'b0;
						//convst_D   <= 1'b0;  
					end	
				MEM:
					begin
						toMem      <= memreg;
						mem_ready  <= 1'b1; 
						read       <= 1'b0;  //should be 1
						ADCread    <= ADCread + 1'b1;
					end
			endcase
		
		
		end
	end



endmodule 