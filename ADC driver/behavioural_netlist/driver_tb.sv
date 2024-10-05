`include "macro.f"
module driver_tb();
    reg           XCLK;
    reg           rst;
    reg           CS_N;
    reg           WR_N;
    reg           RD_N;

    reg          CONVST_A;
    reg          CONVST_B;
    reg          CONVST_C;
    reg          CONVST_D;

    wire          BUSY;
    wire [15:0]   DB;
    reg [15:0]    DB_i;

    // Instantiate driver + ADC model


    ADC_behav adc_inst (
        .XCLK (XCLK)  ,
        .CS_N (CS_N)  ,
        .WR_N (WR_N)  ,
        .RD_N (RD_N)  ,
        
        .CONVST_A(convst_A),
        .CONVST_B(convst_B),
        .CONVST_C(convst_C),
        .CONVST_D(convst_D),
        
        .BUSY(BUSY),    
        .DB(DB)       
    );

	driver driver_inst(
		.convst_A(convst_A),
		.convst_B(convst_B),
		.convst_C(convst_C),
		.convst_D(convst_D),
		.RD_N(RD_N),
		.CS_N(ADC_CS_N),
		.HW_N(HW_N),
		.PAR_N(PAR_N),
		.ADCrst(),
		.STBY_N(STBY_N),
		.WR_N(WR_N),
		.toMem(toMem),         // output to ADC mem
		.mem_ready(mem_ready), // output to state machine
		.DB(DB),               // inout - data bus
		.state_ff(),  

		.Busy(BUSY),            // input DC
		.rst(rst),              // input  
		.clk(XCLK)               // input  
	);

    initial begin
        rst = 1; #100;
        rst = 0; #100;
        rst = 1;

        repeat(10) @ (posedge convst_A);
        $stop;
    end


    initial begin
        XCLK = 0;
        forever begin
            XCLK = ~XCLK; #67;
        end
    end
endmodule