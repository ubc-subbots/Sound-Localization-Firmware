`include "macro.f"
module tb();
    reg           XCLK;
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

    // Example of how you would instantiate the behavioural model
    ADC_behav DUT (
        XCLK,
        CS_N,
        WR_N,
        RD_N,

        CONVST_A,
        CONVST_B,
        CONVST_C,
        CONVST_D,

        BUSY,
        DB
    );

    initial begin
        XCLK = 0;
        // force DUT.CLKSEL = 0;
        forever begin
            XCLK = ~XCLK; # 67;
        end
    end

    // DB port driver
    assign direction = WR_N;   
    // assign DB   =  direction ?  DB_o : 'bz;
    assign DB =  direction ?  'bz : DB_i;

    initial begin
        WR_N = 1;
        RD_N = 1;

        // Write Access test
        DB_i = 'b1000_0000_0101_0100;
        # 10;
        WR_N = 0; #67;
        WR_N = 1; #67;
        DB_i = 'h03FF;
        WR_N = 0; #67;
        WR_N = 1; #67;

        // Read Access Test
        repeat (10) begin
            # 10;
            CONVST_A = 1;
            CONVST_B = 1;
            CONVST_C = 1;
            CONVST_D = 1;

            # 100;
            CONVST_A = 0;
            CONVST_B = 0;
            CONVST_C = 0;
            CONVST_D = 0;

            #(`tCONV);
            CS_N = 0;
            repeat(5) begin
                RD_N = 0; # 67;
                RD_N = 1; # 67;
            end
            CS_N = 1;

            #`tCSCV;
        end
        #10;

        $stop;
    end

endmodule