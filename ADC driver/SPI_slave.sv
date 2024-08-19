/// # SPI specification
///
/// ## Overview
///
/// This synthizes into a SPI modules capable of 
/// sending 16 bits of data to an external module (raspberry pi)
/// upon the lower of chip select by the master (raspberry pi) 
///
/// ## IO Ports
/// rst: reset
/// sclk: serial clk provided by raspberry pi
/// cs: chip select, default high and should be switched low for any operation
/// 
/// unprocessed_MISO: FPGA-facing 16 bits of data to be sent
/// 
/// processed_MISO: raspberry-pi facing, serialized data that are sent 
/// ready_for_data: FPGA-facing, flag that indicates its ready for another operation 




module spi 
	(
	input logic rst,
	input logic sclk,
	input logic cs,
	
	input logic [15:0] unprocessed_MISO, //the 2 byte to serialize before sending
	
	output logic processed_MISO,
	output logic ready_for_data
	);
	
	logic [3:0] MISO_counter; 
	logic notfinished;
	
	typedef enum {
		INIT, 
		SPI 
	} state_t;

	state_t state = INIT;
	
	always_ff@(posedge sclk or posedge cs) begin 
		 
		if(cs) begin 
			MISO_counter <= 4'b1110;
			processed_MISO <= unprocessed_MISO[4'b1111];
			ready_for_data <= 1'b1;
			state <= INIT;
		end
		
		else begin
			if(~rst) begin
				state <= INIT; 		
			end else begin
				case(state)
					INIT: begin
						MISO_counter <= 4'b1110;
						processed_MISO <= unprocessed_MISO[4'b1111];
						ready_for_data <= 1'b0;
						state <= SPI; 
					end
					SPI: begin
						if(MISO_counter != 4'b0000) begin
							processed_MISO <= unprocessed_MISO[MISO_counter];
							MISO_counter <= MISO_counter - 1;
							ready_for_data <= 1'b0;
							notfinished <= 1'b1;
						end else if(notfinished) begin
							processed_MISO <= unprocessed_MISO[0];
							notfinished <= 1'b0;
						end else begin
							processed_MISO <= 1'bz;
						end
					end
				endcase
					
			end
		
		end
		
	end
		
	
endmodule

