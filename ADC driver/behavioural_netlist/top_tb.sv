module top_tb();
    // Declare signals to connect to top module
    wire [15:0] DB;
    logic CLOCK_25M;
    logic rst;
    logic KEY2;
    logic sclk;
    logic SPI_cs;
    logic transaction_done;
    
    logic convst_A;
    logic convst_B;
    logic convst_C;
    logic convst_D;
    logic RD_N; 
    logic ADC_CS_N;
    logic HW_N;
    logic PAR_N;
    logic ADCrst;
    logic STBY_N;
    logic WR_N;
    logic XCLK;
    
    logic processed_MISO;
    logic SPI_RDY;

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


    // Instantiate the top module
    top DUT (
        .DB(DB),
        .Busy(BUSY),
        .CLOCK_27M(CLOCK_25M),
        .rst(rst), 
        .KEY2(KEY2),
        
        .sclk(sclk),
        .SPI_cs(SPI_cs),
        .transaction_done(transaction_done),
        
        .convst_A(convst_A),
        .convst_B(convst_B),
        .convst_C(convst_C),
        .convst_D(convst_D),
        .RD_N(RD_N),
        .ADC_CS_N(ADC_CS_N),
        .HW_N(HW_N),
        .PAR_N(PAR_N),
        .ADCrst(ADCrst),
        .STBY_N(STBY_N),
        .WR_N(WR_N),
        .XCLK(XCLK),
        
        .processed_MISO(processed_MISO),
        .SPI_RDY(SPI_RDY)
    );

    initial begin
        rst = 1;  // Assuming active high reset
        KEY2 = 0;
        SPI_cs = 1;
        transaction_done = 0;
        # 500;
        rst = 0; #100;
        rst = 1;

        #120000;
        SPI_cs = 0;
        #15000;

        // // Debounce on reset
        // rst = 0; #800;
        // rst = 1; #950;
        // rst = 0; #500;
        // rst = 1; #550;
        // rst = 0; #300;
        // rst = 1; #550;
        // #15000;
        $stop;
    end


    // 25 MHz internal FPGA clock
    initial begin
         CLOCK_25M = 0;
        forever #40 CLOCK_25M = ~CLOCK_25M;  // 27 MHz clock period = 37.04 ns
    end

    // External SPI clock 
    initial begin
        sclk = 0;
        forever #60 sclk = ~sclk;  // 27 MHz clock period = 37.04 ns
    end

endmodule