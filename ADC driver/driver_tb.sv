module driver_tb();
	wire convst_A;
	wire convst_B;
	wire convst_C;
	wire convst_D;
	
	wire read;
	wire CS;
	wire HW;
	wire PAR;
	wire rst;
	wire STBY;
	wire write;
	wire [15:0] DB;
	wire [15:0] toMem;

	reg Busy;
	reg clk;
	reg [15:0] DBin;

	driver DUT(
	.convst_A(convst_A),
	.convst_B(convst_B),
	.convst_C(convst_C),
	.convst_D(convst_D),
	.read(read),
	.CS(CS),
	.HW(HW),
	.PAR(PAR),
	.rst(rst),
	.STBY(STBY),
	.write(write),
	.toMem(toMem),
	.Busy(Busy),
	.DB(DB),
	.clk(clk)
	);
	
	assign DB = (write) ? DBin : 16'bz;
	
	
	initial begin
		clk = 1'b0;
		Busy = 1'b0;
		forever begin 
			clk = ~clk;
			#5;
		end
	end
	
	initial begin 
		#70;
		Busy = 1'b1;
		#20;
		Busy = 1'b0;
		#20;
		DBin = 16'b1010101010101000; //Simulated A0
		#30;
		DBin = 16'b0;
		#20;
		DBin = 16'b1110001110001100; //Simulated A1
		#30;
		DBin = 16'b0;
		#20;
		DBin = 16'b1111111111111111; //Simulated B0
		#30;
		DBin = 16'b0;
		#20;
		DBin = 16'b1111111110001100; //Simulated B1
		#30;
		DBin = 16'b0;
		#20;
		DBin = 16'b1111111110000000; //Simulated C0
		
		
		#50;
		Busy = 1'b1; //Second read cycle
		#20;
		Busy = 1'b0;
		DBin = 16'b1111111111101000;
	
	end
	


endmodule