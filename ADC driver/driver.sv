/// # ADS8528 Driver Specification
///
/// ## Overview
///
/// This verilog code is suppose to config the ADC to run
/// in the PAR_Naelle setting with an external clk then collect data
/// on a frequent basis 
///
/// ## IO Ports
/// convst_X: notifies the adc X0 and X1 to start converting from analogue to digital
/// RD_N: notifies the ADC the driver is ready to recieve data
/// CS_N: chip select, default high and should be switched low for any operation
/// HW_N: hardware/software select, this driver opts for the software option
/// PAR_N: paralle/serial select, this driver opts for paraalle
/// rst: reset
/// STBY_N: not relevant for this implementation
/// WR_N: notifies the ADC to prepare for write operation
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
	
	output logic RD_N, 
	output logic CS_N,
	output logic HW_N,
	output logic PAR_N,
	output logic ADCrst,
	output logic STBY_N,
	output logic WR_N,
	
	output logic [15:0] toMem,
	output logic mem_ready,
	output logic [4:0] state_ff,
	
	input rst,
	input Busy, // George: is this the busy signal that is coming from the ADC? 
	inout [15:0] DB,
	input clk
);

	/*typedef enum {
		HOLD,
		INIT,
		BUSY,
		MEM
	} state_t;*/
	
	parameter [4:0] HOLD = 5'b00000,
						 INIT = 5'b00010,
						 BUSY = 5'b00100,
						 MEM = 5'b01000;
			
	
		
	logic [15:0] DBout;
	logic finishwrite;
	
	logic convstsent; // Georgee: flag that tells the FSM that the CONVST signal has been triggered
	logic isReading;
	
	logic [15:0] memreg;
	
	logic [6:0] writecount;
	
	logic [3:0] ADCread; //counter of which ADC we are on, should reset to 0 after we hit 5
		
	//reg [4:0] state_ff;
	
	assign DB = (!WR_N) ? DBout : 16'bz;
	
	//assign CS_N = 1'b0;
	assign HW_N = 1'b1;
	assign PAR_N = 1'b0;
	assign STBY_N = 1'b1;
	
	logic [31:0] waitcounter;
	
	
	/*always_ff@(posedge clk) begin
		if(!rst) begin
			waitcounter <= 32'd0;
		end else begin
			if(finishwrite) begin
				if(waitcounter < 32'd1500) begin
					waitcounter <= waitcounter + 1'b1;
				end
			end
		end
	end*/
	
	
	// Chip select control logic
	always_ff@(posedge clk) begin
		if(!rst) begin
			CS_N                <= 1'b1;
		end else begin
			if(finishwrite == 1'b0) begin				
				if(writecount > 7'd0) begin
				 CS_N            <= 1'b0;
				end else begin
				 CS_N            <= 1'b1;
				end		
			end else begin
				if(convstsent || (state_ff == BUSY || state_ff == MEM))
				 CS_N            <= 1'b0;
				else 
				 CS_N            <= 1'b1;
			end
		
		end
	
	end
	
	
	/*
	always_ff@(posedge clk)begin 
		if(!rst) begin
			WR_N               <= 1'b1;
			finishwrite         <= 1'b0;
			isReading           <= 1'b0;
			writecount          <= 7'd40;
		end else begin 
			if(finishwrite == 1'b0) begin
				if((writecount == 7'd40) || (writecount == 7'd30) || (writecount == 7'd20) || (writecount == 7'd10)) begin
					WR_N         <= ~WR_N;
				end else if(writecount > 7'd0) begin
					WR_N         <= WR_N;
				end else begin
					WR_N         <= 1'b1;
				end
				
				if(writecount > 7'd0) begin
					writecount    <= writecount - 1'b1;
					finishwrite   <= 1'b0;
				end else begin
					finishwrite   <= 1'b1;
				end
				
				if(writecount > 7'd20)begin
					DBout         <= 16'b1000_0000_0000_0000;  //First sets of config
				end
				else begin 
					DBout         <= 16'h03ff;   //Second set of config 
				end

			end
			
		end
	
	
	
	end
	*/
		

	// Data control block
	// Controls when the FSM will transition from HOLD -> INIT
	// Makes sure that the registers get configured first
	always_ff@(posedge clk)begin 
		if(!rst) begin
			WR_N                <= 1'b1;
			finishwrite         <= 1'b0;
			isReading           <= 1'b0;
			writecount          <= 3'b100;
		end else begin 
			if(finishwrite == 1'b0) begin
				if(writecount > 3'b0) begin
					writecount    <= writecount - 1;
					WR_N         <= ~WR_N;
				end else begin
					finishwrite   <= 1'b1;
				end
					
				// George: Se 9.5.1.1, pg. 39 for CONFIG registers
				// Changed from default
				// I'd recommend a style change where you explicitely say which bits are changed so no one needs to go hunting for it
				// config_val = `DEFAULT_VAL // 
				// config_val[31] = 1
				// config_val[22] = 1
				// config_val[20] = 1
				// config_val[18] = 1
				// DBout <= config_val;
				// BIT 31 - Register content update enabled
				// BIT 22 - Channel pair B is powered down : George:Why are thes 3 channels powered down? 
				// BIT 20 - Channel pair C is powered down : 
				// BIT 18 - Channel pair D is powered down : 
				if(writecount > 3'b010)begin
					DBout         <= 16'b1000_0000_0101_0100;  //First sets of config // George: magic number >:(	
				end
				else begin 
					DBout         <= 16'h03FF;   //Second set of config (default)
				end

			end
			
		end
	end
	
	// FSM
	always_ff@(posedge clk) begin
		if(!rst) begin
				state_ff         <= HOLD; 
				ADCread          <= 3'b000;
			    convstsent       <= 1'b0;
				RD_N             <= 1'b1;
				mem_ready        <= 1'b0;
				
		end else begin
			case(state_ff) 
				//HOLD: The state before the driver finish writing 
				HOLD: begin
					if(finishwrite) state_ff   <= INIT;
					else            state_ff   <= HOLD;
					end

				//INIT: The conversion signal is sent in this state
				INIT: begin
				//We choose to transition when busy goes high to make sure that the conversion process has actually begun
				//before we go to our busy state and begin waiting for busy to go low
				// George: the busy signal should be brought into the if statement then lol
					if(convstsent)  state_ff   <= BUSY;
					else            state_ff   <= INIT;
					end
				//BUSY: The state that waits for busy to go low and then sets RD_N low
				BUSY: begin
					if(Busy == 1'b0 && ADCread != 3'b110)  state_ff   <= MEM;
					else if            (ADCread == 3'b110) state_ff   <= INIT; // George: I assume reset after 5 because there's 5 microphones
					else          						   state_ff   <= BUSY; 
					end
				//MEM: The state where the ADC RD_Ning is sent to memory
				MEM:     state_ff      <= BUSY;
				default: state_ff <= INIT;
			endcase
			
			case(state_ff) 
				HOLD:
					begin
						RD_N       <= 1'b1;  
						convst_A   <= 1'b0;
						convst_B   <= 1'b0;
						convst_C   <= 1'b0;
						convst_D   <= 1'b0; 
						convstsent <= 1'b0; 
						mem_ready  <= 1'b0;
					end
				INIT:
					begin 
						convst_A   <= 1'b1; 
						convst_B   <= 1'b1;
						convst_C   <= 1'b1;
						convst_D   <= 1'b1; 
						convstsent <= 1'b1; 
						ADCread    <= 3'b000;
						RD_N       <= 1'b1;
						mem_ready  <= 1'b0;
					end
				BUSY:
					begin
						if(Busy == 1'b0 && ADCread != 3'b110) begin
							RD_N    <= 1'b0;
							memreg  <= DB;
						end else begin
							RD_N    <= 1'b1;   
							memreg  <= DB;
						end
						convstsent <= 1'b0; 
						convst_A   <= 1'b0; 
						convst_B   <= 1'b0; 
						convst_C   <= 1'b0;
						convst_D   <= 1'b0; 
						mem_ready  <= 1'b0;
					end	
				MEM:
					begin
						toMem      <= memreg;
						mem_ready  <= 1'b1; 
						RD_N       <= 1'b1;  
						ADCread    <= ADCread + 1'b1;
					end
				
			endcase
		
		
		end
	end



endmodule 