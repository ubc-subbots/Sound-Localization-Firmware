// ADS8528 System Verilog Behavioural Model
// 
// This is a non-synthesizable model intended for simulation purposes only
// A testbench environment should be made with this behavioural model and 

`include "timing.sv"

module ADC_behav(
    input logic             XCLK,       // external clock
    input logic             CS_N,     // chip select 
    input logic             RD_N,     // read data 

    input logic             CONVST_A, // initialize conversion for channel
    input logic             CONVST_B, // initialize conversion for channel
    input logic             CONVST_C, // initialize conversion for channel
    input logic             CONVST_D, // initialize conversion for channel

    output logic            BUSY,
    inout  logic    [15:0]  DB          // databus - I want to test some simulations just to see how this is meant to behave
);

[15:0] reg CH_A0, CH_A1;
[15:0] reg CH_B0, CH_B1;
[15:0] reg CH_C0, CH_C1;
[15:0] reg CH_D0, CH_D1;

//-------------------------//
//       Write Access      //
//-------------------------//

// Timing
// tCSWR
// tWRL
// tWRH
// tWRCS
// tSUDI
// tHDI

// This is to test functionality of the 2 bytes sent to configure registers are written correclty
reg [31:0] CONFIG_REG;
reg [31:0] write_count; // set to reasonably large number with no upper bound 
initial begin
    write_count = 0;
end

always_ff @ (negedge WR_N) begin
    write_count <= write_count + 1;
end

// Set the bits of the configuration register based on the write count

//--------------------------//
//        Read Access       // 
//--------------------------//

// Timing
// tSCVX - input constraint = setup time from CONVST_x high to posedge XCLK
// tCONV - conversion time  = 1.33us / 19 clock cycles
// tCVL  - input constraint: min amount of time that busy needs to remain low before before posedge CONVST_x
// tRDL  - input constraint: min RD pulse duration = 20ns
// tDCVB - output constraint: CONVST_x posedge to BUSY posedge delay = 25ns
// tPDDO - output constraint: RD negedge propagation delay before valid data = 15ns 


// Randomize value for channel. Seed with a value so that this random sequence can be reasserted. 
// Use $urandom_range instead of random for generation random sequences since $random isn't thread safe so hard to reproduce random sequences when multiple initial blocks are used
reg [2:0] ADC_num;
reg [4:0] A_CLK_COUNT, B_CLK_COUNT, C_CLK_COUNT, D_CLK_COUNT; // number of clock cyccles once a conversion begins
bit CONVST_A_started;
bit CONVST_B_started;
bit CONVST_C_started;
bit CONVST_D_started;
int XCLK_setup = 0;

initial begin
    ADC_num = 0;
    CONVST_A_started = 0;
    CONVST_B_started = 0;
    CONVST_C_started = 0;
    CONVST_D_started = 0;
    A_CLK_COUNT = 0;
    B_CLK_COUNT = 0;
    C_CLK_COUNT = 0;
    D_CLK_COUNT = 0;
end

// Reset
always @ posedge (CS_N) begin
    ADC_num = 0;
    CONVST_A_started = 0;
    CONVST_B_started = 0;
    CONVST_C_started = 0;
    CONVST_D_started = 0;
    A_CLK_COUNT = 0;
    B_CLK_COUNT = 0;
    C_CLK_COUNT = 0;
    D_CLK_COUNT = 0;
end

// On the positive edge of CONVST_x, conversion begins. It will finish in 19 clock cycles of XCLK if the timing requirement for tSCVX is met
// If CONVST_A positive edge is detected reset internal state machine
// TODO: Implement conversion timing model
always @ (posedge CONVST_A) begin
    ADC_num = 0;
    CONVST_A_started = 1
    XCLK_setup = $time;
    CH_A0 = $urandom_range(0, 65535);
    CH_A1 = $urandom_range(0, 65535);
end

always @ (posedge CONVST_B) begin
    CONVST_B_started = 1
    CH_B0 = $urandom_range(0, 65535);
    CH_B1 = $urandom_range(0, 65535);
end

always @ (posedge CONVST_C) begin
    CONVST_C_started = 1
    CH_C0 = $urandom_range(0, 65535);
    CH_C1 = $urandom_range(0, 65535);
end

always @ (posedge CONVST_D) begin
    CONVST_D_started = 1
    CH_D0 = $urandom_range(0, 65535);
    CH_D1 = $urandom_range(0, 65535);
end

always @ (posedge XCLK) begin
    if ($time - XCLK_setup > `tSCVX) begin // setup time constraint
        A_CLK_COUNT = A_CLK_COUNT + 1;       
        B_CLK_COUNT = B_CLK_COUNT + 1;       
        C_CLK_COUNT = C_CLK_COUNT + 1;       
        D_CLK_COUNT = D_CLK_COUNT + 1;       
    end
end

always @ (negedge RD_N) begin : channel_data_gen
    # (`tPDDO); // output constraint on when DB will update after RD_N goes low

    ADC_num <= ADC_num + 1;
end

always_comb begin : channel_selection
    case (ADC_num)
        0 : DB = CH_A0;
        1 : DB = CH_A1;
        2 : DB = CH_B0;
        3 : DB = CH_B1;
        4 : DB = CH_C0;
        5 : DB = CH_C1;
        6 : DB = CH_D0;
        7 : DB = CH_D1;
        default: DB = 'bz; // check what it should be between data values
    endcase
end

// BUSY signal output constraint



// ---------------------- //
//    Model Properties    //
// ---------------------- //

assert property (!(WR_N == 0 && RD_N == 0)); // Write and read signals should never both be 0 at the same time

// --------- WRITE ACCESS CHECKS ------ //
// Here checking that the timing requirements and read access behaviours for the model are not violated

// PROPERTY - During parallel write access CS should be low with all the timing met 


// PROPERTY - We should never write to the configuration register more than two times
assert property (!(write_count > 2));


// --------- READ ACCESS CHECKS ------ //

// DATA validity - Check that based on ADC number, that on the positive edge of RD_N that the correct channel is outputed
// Placed here to act as an automatic checker to emulate what the driver module should be getting
always_ff @ (posedge RD_N) begin
    case (ADC_num)
        0 : assert(DB = CH_A0) 
        1 : assert(DB = CH_A1) 
        2 : assert(DB = CH_B0) 
        3 : assert(DB = CH_B1) 
        4 : assert(DB = CH_C0) 
        5 : assert(DB = CH_C1) 
        6 : assert(DB = CH_D0) 
        7 : assert(DB = CH_D1) 
        default: assert(DB = 'bz); // check what it should be between data values
    endcase
end

// PROPERTY - If a conversion has started, then an error will be raised if CONVST_x is positive edge triggered at any time 
// These are status flags that will be set inside the model that will be 1 when a conversion for that channel is ongoing. 
bit CHA_conversion;
bit CHB_conversion;
bit CHC_conversion;
bit CHD_conversion;

assert property (@(posedge CONVST_A) CHA_conversion == 0); 
assert property (@(posedge CONVST_B) CHB_conversion == 0); 
assert property (@(posedge CONVST_C) CHC_conversion == 0); 
assert property (@(posedge CONVST_D) CHD_conversion == 0); 


// PROPERTY - DB should never have the take on the values of C1, D0, or D1 since the driver should reset the ADC counter
assert property (@(posedge RD_N) DB != CH_C1)
assert property (@(posedge RD_N) DB != CH_D0)
assert property (@(posedge RD_N) DB != CH_D1)


// PROPERTY - RDL min pulse duration is met
int negedge_RD;
int posedge_RD;
int RD_pulse_duration;
initial forever begin
    @ (negedge RD_N) negedge_RD = $time;
    @ (posedge RD_N) begin 
        posedge_RD = $time;

        RD_pulse_duration = posedge_RD - negedge_RD;
        assert RD_pulse_duration > `tRDL;
    end
end

// PROPERTY - RDH read access restriction is met



// PROPERTY - Once the bits have been written into the registers check their values




endmodule

