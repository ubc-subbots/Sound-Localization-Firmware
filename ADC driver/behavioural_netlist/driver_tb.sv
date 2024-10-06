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
    wire [15:0] data_out;

    real CH_ANA_A0;
    real CH_ANA_B0;
    real CH_ANA_C0;
    real CH_ANA_D0;
    real CH_ANA_A1;
    real CH_ANA_B1;
    real CH_ANA_C1;
    real CH_ANA_D1;
    
    // Instantiate driver + ADC model
    ADC_behav adc_inst (
        .XCLK (XCLK)  ,
        .CS_N (CS_N)  ,
        .WR_N (WR_N)  ,
        .RD_N (RD_N)  ,
        .HW_N_SW(software_mode),
        
        .CONVST_A(convst_A),
        .CONVST_B(convst_B),
        .CONVST_C(convst_C),
        .CONVST_D(convst_D),
        
        `ifdef SAR_ADC_CONV

        .CH_ANA_A0( CH_ANA_A0 ),
        .CH_ANA_B0( CH_ANA_B0 ),
        .CH_ANA_C0( CH_ANA_C0 ),    
        .CH_ANA_D0( CH_ANA_D0 ),
        .CH_ANA_A1( CH_ANA_A1 ),
        .CH_ANA_B1( CH_ANA_B1 ),
        .CH_ANA_C1( CH_ANA_C1 ),    
        .CH_ANA_D1( CH_ANA_D1 ),
        
        `endif

        .BUSY(BUSY),    
        .DB(DB)       
    );

	driver driver_inst(
        .clk              ( XCLK          ),
        .sresetn          ( rst           ),
        .busy             ( BUSY          ),
        .data_adc         ( DB            ),
        .read_n           ( RD_N          ),
        .write_n          ( WR_N          ),
        .chipselect_n     ( CS_N          ),
        .software_mode    ( software_mode ),
        .serial_mode      ( serial_mode   ),
        .standby_n        ( standby_n     ),
        .conv_start_a     ( convst_A      ),
        .conv_start_b     ( convst_B      ),
        .conv_start_c     ( convst_C      ),
        .conv_start_d     ( convst_D      ),
        .data_out         ( data_out      ),
        .data_valid       ( data_valid    )
	);

    initial begin
        rst = 1; #100;
        rst = 0; #100;
        rst = 1;

        repeat(36) @ (posedge convst_A);
        $stop;
    end


    initial begin
        XCLK = 0;

        forever begin
            XCLK = ~XCLK; #67;
        end
    end


    // Channel value generation
    initial begin
        CH_ANA_A0 = 0.52;
        CH_ANA_B0 = 0.76;
        CH_ANA_C0 = 0.24;
        CH_ANA_D0 = 10.3287;

        CH_ANA_A1 = -10.98;
        CH_ANA_B1 = 0.001;
        CH_ANA_C1 = -0.00027;
        CH_ANA_D1 = 0.657;

        forever begin
            CH_ANA_A0 = 2.5*$sin($time/5000.0); 
            CH_ANA_B0 = -2.5 * $sin($time / 5000.0 + 0.2); 
            CH_ANA_C0 = 2.5 * $sin($time / 5000.0 + 0.3); 
            CH_ANA_D0 = -2.5 * $sin($time / 5000.0 + 0.5); 
    
            CH_ANA_A1 = -7.5 * $sin($time / 5000.0 + 0.9); 
            CH_ANA_B1 = -2.5 * $sin($time / 5000.0 + 1.0); 
            CH_ANA_C1 = 18.5 * $sin($time / 5000.0 + 1.4); 
            CH_ANA_D1 = -2.5 * $sin($time / 5000.0 + 1.9); 

            #100ns;  // Change sin wave resolution here. Up to 250ns is decent
        end
    end
endmodule