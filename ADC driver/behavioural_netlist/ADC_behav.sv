// ADS8528 System Verilog Behavioural Model
// 
// This is a non-synthesizable model intended for simulation purposes only
// A testbench environment should be made with this behavioural model and 

`include "macro.f"

task automatic start_channel_conversion (
    ref         logic        XCLK,
    input       bit          CLKSEL,
    ref         logic        CONVST_x, 
    ref         bit          channel_conv_ongoing, 
    output      reg  [15:0]  CH0, 
    output      reg  [15:0]  CH1
);
    // Initiate channel conversion for this specific channel
    // $display ("[%t] CONVS_x called", $time);
    channel_conv_ongoing = 1; 
    CH0 = 'bx;
    CH1 = 'bx;

    if      (CLKSEL == 0) # (`tCONV );  // Conversion time for internal clock
    else if (CLKSEL == 1) repeat(`tCCLK) @ (posedge XCLK); // Repeat for tCCLK cycles of the external conversion clock

    $display ("[%t] Channel set at", $time);
    CH0 = $urandom_range(0, 65535);
    CH1 = $urandom_range(0, 65535);

    channel_conv_ongoing = 0;
  
endtask



module ADC_behav(
    input logic             XCLK,     // external clock
    input logic             CS_N,     // chip select 
    input logic             WR_N,     // write data
    input logic             RD_N,     // read data 

    input logic             CONVST_A, // initialize conversion for channel
    input logic             CONVST_B, // initialize conversion for channel
    input logic             CONVST_C, // initialize conversion for channel
    input logic             CONVST_D, // initialize conversion for channel

    output logic            BUSY,
    inout  wire    [15:0]   DB         // databus 
);

reg [15:0] DB_i,  DB_o;    // buffer since inout port cannot be driven by an initial block
reg [15:0] CH_A0, CH_A1;   // Channel A conversion output
reg [15:0] CH_B0, CH_B1;   // Channel B conversion output
reg [15:0] CH_C0, CH_C1;   // Channel C conversion output
reg [15:0] CH_D0, CH_D1;   // Channel D conversion output

reg [2:0] ADC_num;
bit CONVST_A_ongoing;
bit CONVST_B_ongoing;
bit CONVST_C_ongoing;
bit CONVST_D_ongoing;

// You cannot pass input signals by reference to a task
// Therefore buffer it and pass the buffered signal to the task
logic XCLK_buf;
logic CONVST_A_buf;
logic CONVST_B_buf;
logic CONVST_C_buf;
logic CONVST_D_buf;

assign XCLK_buf = XCLK;
assign CONVST_A_buf = CONVST_A;
assign CONVST_B_buf = CONVST_B;
assign CONVST_C_buf = CONVST_C;
assign CONVST_D_buf = CONVST_D;

//-------------------------//
//       Write Access      //
//-------------------------//

// This is to test functionality of the 2 bytes sent to configure registers are written correclty
reg [31:0] CONFIG_REG;
int write_count;
assign CLKSEL = CONFIG_REG[29]; // 0 = Use internal conversion clock : 1 = use XCLK

// Write to the configuration registers when WR_N goes low
initial begin
    write_count = 0;
    forever begin
        @ (negedge WR_N) write_count <= write_count + 1;

        // Ignoring for now that technically the config reg only updates after both write signals. Implement a buffer in the future
        if      (write_count == 1) CONFIG_REG[31:16] = DB_i;
        else if (write_count == 2) CONFIG_REG[15:0]  = DB_i;
    end
end

//--------------------------//
//      DB Port Driver      //
//--------------------------//
initial forever begin
    @ (negedge RD_N) begin 
        # (`tPDDO); // output constraint on when DB will update after RD_N goes low

        case (ADC_num)
            0 : DB_o = CH_A0;
            1 : DB_o = CH_A1;
            2 : DB_o = CH_B0;
            3 : DB_o = CH_B1;
            4 : DB_o = CH_C0;
            5 : DB_o = CH_C1;
            6 : DB_o = CH_D0;
            7 : DB_o = CH_D1;
            default: DB_o = 'bz; // check what it should be between data values
        endcase

        ADC_num = ADC_num + 1;
    end
end

// Assume: Configure DB as an output port as the default
assign direction = WR_N;   
assign DB   =  direction ?  DB_o : 'bz;
assign DB_i =  direction ?  'bz : DB;

//--------------------------//
//        Read Access       // 
//--------------------------//

// ------- BUSY SIGNAL MODEL ------ //
initial forever begin
    // BUSY assertion logic
    @ (posedge CONVST_A or posedge CONVST_B or posedge CONVST_C or posedge CONVST_D) begin
        # (`tDCVB) BUSY <= 1'b1; // CONVST_x high to BUSY high delay
    end

    // BUSY deassertion logic
    // TODO: If we're operating each chanel independently, then BUSY should be 0 for 67ns then back to high if any channel conversion is still ongoing
    @ (negedge CONVST_A_ongoing) BUSY <= 1'b0;
end

// ------- CHANNEL CONVERSION MODEL ------ //

// Set channel output model params
initial begin
    ADC_num = 0;
    CONVST_A_ongoing = 0;
    CONVST_B_ongoing = 0;
    CONVST_C_ongoing = 0;
    CONVST_D_ongoing = 0;
end

// Randomize value for channel. Seed with a value so that this random sequence can be reasserted. 
// Use $urandom_range instead of random for generation random sequences since $random isn't thread safe so hard to reproduce random sequences when multiple initial blocks are used
initial forever begin
    fork
        // THREAD - Reset process. If CONVST_A goes high, all the conversions for channel A, B, C D should also be high
        @ (posedge CONVST_A_buf) ADC_num = 0;

        // THREAD - Channel conversions
        // On the positive edge of CONVST_x, conversion begins assuming that CONVST_A process was not asserted before
        // Each of these will launch a new thread which will set the CONVST_x_ongoing flag to true
        start_channel_conversion(XCLK_buf, CLKSEL, CONVST_A_buf, CONVST_A_ongoing, CH_A0, CH_A1);
        start_channel_conversion(XCLK_buf, CLKSEL, CONVST_B_buf, CONVST_B_ongoing, CH_B0, CH_B1);
        start_channel_conversion(XCLK_buf, CLKSEL, CONVST_C_buf, CONVST_C_ongoing, CH_C0, CH_C1);
        start_channel_conversion(XCLK_buf, CLKSEL, CONVST_D_buf, CONVST_D_ongoing, CH_D0, CH_D1);

    join_any // Prevents hanging if a particular thread is stuck in a waiting state
end

// ============================
// Assert Model Properties  
// ============================
initial forever begin

    // Need to add delay statements to this loop otherwise the simulation will hang
    if (WR_N == 0 | RD_N == 0) begin
        assert (!(WR_N == 0 && RD_N == 0)); // Write and read signals should never both be 0 at the same time
    end
    #1;

    // write_access_properties ();

    // read_access_properties (
    //       .ADC_num               (ADC_num),
    //       .RD_N                  (RD_N),
    //       .CONVST_A_ongoing      (CONVST_A_ongoing),
    //       .CONVST_B_ongoing      (CONVST_B_ongoing),
    //       .CONVST_C_ongoing      (CONVST_C_ongoing),
    //       .CONVST_D_ongoing      (CONVST_D_ongoing),
    //       .CONVST_A              (CONVST_A),
    //       .CONVST_B              (CONVST_B),
    //       .CONVST_C              (CONVST_C),
    //       .CONVST_D              (CONVST_D)
    // );

end

endmodule


task automatic write_access_properties (
    input int write_count,
    ref CS_N,
    ref WR_N,
    ref [15:0] DB
);

    // --------- WRITE ACCESS CHECKS ------ //
    // Here checking that the timing requirements and read access behaviours for the model are not violated

    // PROPERTY - CS  low to WR low time


    // PROPERTY - We should never write to the configuration register more than two times
    // assert property (!(write_count > 2));

    // Configuraition check

    // Timing Constraints check


endtask

task automatic read_access_properties (
    input int ADC_num,
    ref RD_N,
    input bit CHA_conversion,
    input bit CHB_conversion,
    input bit CHC_conversion,
    input bit CHD_conversion,
    ref CONVST_A, // if the posedge construct is to be used the signal needs to be passed by reference
    ref CONVST_B,
    ref CONVST_C,
    ref CONVST_D
);
    // --------- READ ACCESS CHECKS ------ //

    // PROPERTY - RDL min pulse duration is met
    int negedge_RD;
    int posedge_RD;
    int RD_pulse_duration;

    // George: Commented out for now due to modelsim compilation errors
    // DATA validity - Check that based on ADC number, that on the positive edge of RD_N that the correct channel is outputed
    // Placed here to act as an automatic checker to emulate what the driver module should be getting
    // @ (posedge RD_N) begin
    //     case (ADC_num)
    //         0 : assert(DB == CH_A0) 
    //         1 : assert(DB == CH_A1) 
    //         2 : assert(DB == CH_B0) 
    //         3 : assert(DB == CH_B1) 
    //         4 : assert(DB == CH_C0) 
    //         5 : assert(DB == CH_C1) 
    //         6 : assert(DB == CH_D0) 
    //         7 : assert(DB == CH_D1) 
    //         default: assert(DB == 'bz); // check what it should be between data values
    //     endcase
    // end

    // PROPERTY - If a conversion is ongoing, then an error will be raised if CONVST_x is positive edge triggered at any time 
    // These are status flags that will be set inside the model that will be 1 when a conversion for that channel is ongoing. 
    @(posedge CONVST_A) assert (CHA_conversion == 0); 
    @(posedge CONVST_B) assert (CHB_conversion == 0); 
    @(posedge CONVST_C) assert (CHC_conversion == 0); 
    @(posedge CONVST_D) assert (CHD_conversion == 0); 

    // // PROPERTY - This counter should never go above 5
    @(posedge RD_N) assert (ADC_num <= 5);

    // PROPERTY - RDL min pulse duration is met
    @ (negedge RD_N) negedge_RD = $time;
    @ (posedge RD_N) begin 
        posedge_RD = $time;

        RD_pulse_duration = posedge_RD - negedge_RD;
        assert (RD_pulse_duration > `tRDL);
    end

    // PROPERTY - RDH read access restriction is met


    // PROPERTY - Once the bits have been written into the registers check their values

endtask