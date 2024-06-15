module SPI_slave 
	(
	input rst,
	input sclk,
	input Indata_valid, //pulse from top level module to indicate it can start process the data 
	
	input [15:0] unprocessed_MISO, //the 2 byte to serialize before sending
	
	output logic Outdata_valid, //pulse to rasberry pi indicating it should be ready to recieve data
	output logic processed_MISO,
	output logic ready_for_data
	);
	
	logic [3:0] MISO_counter; 
	logic begin_transfer;
	logic [15:0] temp_MISO;
	
	
	always_ff @(posedge sclk) begin 
		if(~rst) begin
			MISO_counter <= 4'b0;
			Outdata_valid <= 1'b0;
			begin_transfer <= 1'b0;
		end
		else begin
			if(Indata_valid) begin
				begin_transfer <= 1'b1;
				MISO_counter <= 4'b1111;
				temp_MISO <= unprocessed_MISO;
				Outdata_valid <= 1'b1; 
				processed_MISO <= 1'bz;
				ready_for_data <= 1'b0;
			end
			
			if(begin_transfer) begin
				processed_MISO <= temp_MISO[MISO_counter];
				MISO_counter <= MISO_counter - 1;
				Outdata_valid <= 1'b1; 
				ready_for_data <= 1'b0;
			end else begin
				Outdata_valid <= 1'b0;
				processed_MISO <= 1'bz;
				ready_for_data <= 1'b1;

			end
			
			if(MISO_counter == 4'b0 && begin_transfer == 1'b1) begin
				begin_transfer <= 1'b0;
			end
		
		
		end
		
	end
		
	
endmodule
