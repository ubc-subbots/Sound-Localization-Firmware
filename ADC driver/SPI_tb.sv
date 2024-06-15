module SPI_tb();
	reg rst;
   reg sclk;
	reg Indata_valid; //pulse from top level module to indicate it can start process the data 
	
	reg [15:0] unprocessed_MISO; //the 2 byte to serialize before sending
	
	wire Outdata_valid; //pulse to rasberry pi indicating it should be ready to recieve data
	wire processed_MISO;
	wire ready_for_data;
	
	SPI_slave DUT(
	.rst(rst),
	.sclk(sclk),
	.Indata_valid(Indata_valid), 
	.unprocessed_MISO(unprocessed_MISO),
	.Outdata_valid(Outdata_valid), 
	.processed_MISO(processed_MISO),
	.ready_for_data(ready_for_data)
	);
	
	initial begin
		sclk = 1'b0; 
		
		forever begin 
			sclk = ~sclk; 
			#5;
		end
	end
	
	initial begin 
		rst = 1'b0;
		#10
		rst = 1'b1; 
		#10
		Indata_valid = 1'b1;
		unprocessed_MISO = 16'b1010101010101011;
		#25;
		Indata_valid = 1'b0;
		#180;
		Indata_valid = 1'b1;
		unprocessed_MISO = 16'b0101101010101110;
		#25;
		Indata_valid = 1'b0;
	end
	
	
	
endmodule 