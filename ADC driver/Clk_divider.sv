module Clk_divider(
	input clk_in,
	input [31:0] divisor,
	input switch,
	output reg clk_out);
	
	reg [31:0] counter = 0; 
	
	always_ff@(posedge clk_in)
	begin
		if(switch == 1'b1) begin
			counter <= counter + 1'b1;
			if(counter >= (divisor-1)) begin   //Resets when counters meets divisor 
				counter <= 32'd0;
			end
			clk_out <= ( (divisor/2) > counter) ? 1'b1 : 1'b0;   //Change polarity half way through one clk cycle
		end else begin								  //When switch is off, no posedge will be produced
			clk_out <= 1'b0;
			counter <= 32'd0;	
		end
	end
	
endmodule
