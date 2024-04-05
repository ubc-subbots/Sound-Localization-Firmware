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
	reg DBin;

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
		forever begin 
			clk = ~clk;
			#5;
		end
	end
	


endmodule