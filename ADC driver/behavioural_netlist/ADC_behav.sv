// ADS8528 System Verilog Behavioural Model
// 
// This is a non-synthesizable model intended for simulation purposes only
// A testbench environment should be made with this behavioural model and 

// Main task that is used for getting channel data. Works with both internal conversion clock or external clock
`include "timing.sv"
`include "config.sv"

module ADC_behav(
    input logic             XCLK,     // external clock
    input logic             CS_N,     // chip select 
    input logic             WR_N,     // write data
    input logic             RD_N,     // read data 
    input logic             HW_N_SW,  // Pin 41 - hardware/software mode select 

    input logic             CONVST_A, // initialize conversion for channel
    input logic             CONVST_B, // initialize conversion for channel
    input logic             CONVST_C, // initialize conversion for channel
    input logic             CONVST_D, // initialize conversion for channel

    `ifdef SAR_ADC_CONV
    input  real             CH_ANA_A0,  // analog values to come from tb
    input  real             CH_ANA_B0,  
    input  real             CH_ANA_C0,      
    input  real             CH_ANA_D0,  
    input  real             CH_ANA_A1,  
    input  real             CH_ANA_B1,  
    input  real             CH_ANA_C1,      
    input  real             CH_ANA_D1,  
    `endif

    output logic            BUSY,      // indicates channgel conversion is ongoing
    inout  wire    [15:0]   DB         // databus 
);

    reg [15:0] DB_i,  DB_o;    // Buffer since inout port cannot be driven by an initial block
    reg [15:0] DB_tri;         // Parallel interface is disabled if CS_N is high
    reg [15:0] CH_A0, CH_A1;   // Channel A conversion output
    reg [15:0] CH_B0, CH_B1;   // Channel B conversion output
    reg [15:0] CH_C0, CH_C1;   // Channel C conversion output
    reg [15:0] CH_D0, CH_D1;   // Channel D conversion output

    reg [2:0] ADC_num;
    bit CONVST_A_ongoing;      // Internal flag used for checking conversion violations
    bit CONVST_B_ongoing; 
    bit CONVST_C_ongoing; 
    bit CONVST_D_ongoing; 

    // You cannot pass signals by reference to a task
    // Can work around this by providing a buffered version of the signal
    logic XCLK_buf;
    logic RD_N_buf;
    logic WR_N_buf;
    logic CS_N_buf;
    logic BUSY_buf;
    logic CONVST_A_buf;
    logic CONVST_B_buf;
    logic CONVST_C_buf;
    logic CONVST_D_buf;
    logic [15:0] DB_buf;

    assign XCLK_buf = XCLK;
    assign RD_N_buf = RD_N;
    assign WR_N_buf = WR_N;
    assign CS_N_buf = CS_N;
    assign BUSY_buf = BUSY;
    assign CONVST_A_buf = CONVST_A;
    assign CONVST_B_buf = CONVST_B;
    assign CONVST_C_buf = CONVST_C;
    assign CONVST_D_buf = CONVST_D;
    assign DB_buf = DB;

    // ========================================================
    // Module Instantiations
    // ======================================================== 
    SAR_ADC         SAR_ADC();   // Main conversion handling module
    self_checker    check  ();   // Read and write access properties
    cfg             cfg    ();   // Config params so less reliance on macros

    // ========================================================
    // Write Access and Configuration
    // ========================================================

    // This is to test functionality of the 2 bytes sent to configure registers are written correclty
    reg   [31:0] CONFIG_REG_TEMP, CONFIG_REG;
    int          REFDAC;
    int          write_count;

    // Setting Software vs Hardware mode
    assign SOFTWARE_MODE = (HW_N_SW) ? 1 : 0; // 1 = Software mode, 0 == Hardware mode

    // Setting internal flags based on the values of the configuration register 
    assign CLKSEL  = CONFIG_REG[29]; // 0 = Use internal conversion clock : 1 = use XCLK
    assign RANGE_A = CONFIG_REG[24]; 
    assign RANGE_B = CONFIG_REG[23]; 
    assign PD_B    = CONFIG_REG[22]; 
    assign RANGE_C = CONFIG_REG[21]; 
    assign PD_C    = CONFIG_REG[20]; 
    assign RANGE_D = CONFIG_REG[19]; 
    assign PD_D    = CONFIG_REG[18]; 
    assign REF_EN  = CONFIG_REG[15]; // 0 = Internal reference disabled : 1 = Internal reference soruce enabled
    assign VREF    = CONFIG_REG[13]; // 0 = 2.5V internal reference : 1 = 3.0V internal reference
    assign REFDAC  = CONFIG_REG[9:0];

    // I don't assign any logic for hardware mode since throw error if configured for hardware mode

    // Internal reference calculation
    real VRANGE; // 2.5V or 3V
    real Vref_out;
    real Vref_A;
    real Vref_B;
    real Vref_C;
    real Vref_D;

    // Write to the configuration registers when WR_N goes low
    initial begin
        write_count = 0;
        
        `ifdef SAR_ADC_CONV
            $display("[ADC BEHAV] Using SAR ADC model");
        `endif
        `ifdef USE_RANDOM_DATA
            $display("[ADC BEHAV] Using random data");
        `endif

        forever begin
            @ (negedge WR_N) write_count <= write_count + 1;

            // Ignoring for now that technically the config reg only updates after both write signals. Implement a buffer in the future
            if      (write_count == 0) CONFIG_REG_TEMP[31:16] = DB_i;
            else if (write_count == 1) CONFIG_REG_TEMP[15:0]  = DB_i;
            
            // Write the config reg and reset the counter
            if (write_count == 1) begin
                write_count = 0;
                CONFIG_REG = CONFIG_REG_TEMP;

                // Calculate internal reference the ADC will be using now that it's been set
                VRANGE   = CONFIG_REG[13] ? 3.0 : 2.5;
                Vref_out = VRANGE * (CONFIG_REG[9:0] + 1.0) / 1024.0;

                Vref_A = (CONFIG_REG[24] == 0) ? 4 * Vref_out : 2 * Vref_out;
                Vref_B = (CONFIG_REG[23] == 0) ? 4 * Vref_out : 2 * Vref_out;
                Vref_C = (CONFIG_REG[21] == 0) ? 4 * Vref_out : 2 * Vref_out;
                Vref_D = (CONFIG_REG[19] == 0) ? 4 * Vref_out : 2 * Vref_out;

                // Display Current Config Setting if the option is set
                check.Vref_out_valid(Vref_out);
                check.CONFIG_REG(CONFIG_REG, cfg.CONFIG_SHOW, cfg.DISPLAY_CONFIG_REF);
                check.voltage_ranges(Vref_out, CONFIG_REG);
            end
        end
    end

    // ========================================================
    // DB Port Driver     
    // ========================================================
    initial forever begin
        @ (negedge RD_N) begin 
            // output constraint on when DB will update after RD_N goes low
            // 3 state buffer with CS_N adds additional `tDTRI delay so it's subtracted here to achieve a `tPDDO delay
            # (`tPDDO-`tDTRI); 

            case (ADC_num)
                0 : DB_tri = CH_A0;
                1 : DB_tri = CH_A1;
                2 : DB_tri = CH_B0;
                3 : DB_tri = CH_B1;
                4 : DB_tri = CH_C0;
                5 : DB_tri = CH_C1;
                6 : DB_tri = CH_D0;
                7 : DB_tri = CH_D1;
                default : DB_tri = 'bx; // check what it should be between data values
            endcase

            ADC_num = ADC_num + 1;
        end
    end

    assign direction = WR_N;   
    assign #(`tDTRI) DB_o = (CS_N == 0) ? DB_tri : 'bz; // 3 state buffer with delay. RD_N to DB delay is still `tPDDO
    assign DB   =  direction ?  DB_o : 'bz; // inout port logic
    assign DB_i =  direction ?  'bz : DB;

    // ========================================================
    // Read Access
    // ========================================================

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
    // Randomize value for channel
    initial begin
        ADC_num = 0;
        CONVST_A_ongoing = 0;
        CONVST_B_ongoing = 0;
        CONVST_C_ongoing = 0;
        CONVST_D_ongoing = 0;

        forever begin
            fork
                // THREAD - Reset process. If CONVST_A goes high, all the conversions for channel A, B, C D should also be high
                @ (posedge CONVST_A_buf) ADC_num = 0;
    
                // THREAD - Channel conversions
                // On the positive edge of CONVST_x, conversion begins assuming that CONVST_A process was not asserted before
                // Each of these will launch a new thread which will set the CONVST_x_ongoing flag to true
                `ifdef USE_RANDOM_DATA
                SAR_ADC.start_channel_conversion(XCLK_buf, CLKSEL, CONVST_A_buf, CONVST_A_ongoing, CH_A0, CH_A1);
                SAR_ADC.start_channel_conversion(XCLK_buf, CLKSEL, CONVST_B_buf, CONVST_B_ongoing, CH_B0, CH_B1);
                SAR_ADC.start_channel_conversion(XCLK_buf, CLKSEL, CONVST_C_buf, CONVST_C_ongoing, CH_C0, CH_C1);
                SAR_ADC.start_channel_conversion(XCLK_buf, CLKSEL, CONVST_D_buf, CONVST_D_ongoing, CH_D0, CH_D1);
                `endif

                `ifdef SAR_ADC_CONV
                SAR_ADC.start_channel_conversion(XCLK_buf, CLKSEL, CONVST_A_buf, CONVST_A_ongoing, CH_ANA_A0, CH_ANA_A1, Vref_A, CH_A0, CH_A1);
                SAR_ADC.start_channel_conversion(XCLK_buf, CLKSEL, CONVST_B_buf, CONVST_B_ongoing, CH_ANA_B0, CH_ANA_B1, Vref_B, CH_B0, CH_B1);
                SAR_ADC.start_channel_conversion(XCLK_buf, CLKSEL, CONVST_C_buf, CONVST_C_ongoing, CH_ANA_C0, CH_ANA_C1, Vref_C, CH_C0, CH_C1);
                SAR_ADC.start_channel_conversion(XCLK_buf, CLKSEL, CONVST_D_buf, CONVST_D_ongoing, CH_ANA_D0, CH_ANA_D1, Vref_D, CH_D0, CH_D1);
                `endif
            join_any // Prevents hanging if a particular thread is stuck in a waiting state
        end
    end

    // ========================================================
    // Assert Model Properties  
    // ========================================================
    initial begin
        #0.1us;
        if (SOFTWARE_MODE == 0) begin
            $error("Configured for hardware mode! Change signal going to HW_N_SW to be 1");
            $stop;
        end
    end

    initial forever begin
        fork
            @ (negedge WR_N or negedge RD_N) begin
                assert (!(WR_N == 0 && RD_N == 0)); // Write and read signals should never both be 0 at the same time
            end
        join_none

        fork 
            check.write_access_properties (
                .CS_N                  (CS_N_buf),
                .WR_N                  (WR_N_buf),
                .DB                    (DB_buf)
            );
            
            check.read_access_properties (
                .ADC_num               (ADC_num),
                .RD_N                  (RD_N_buf),
                .CS_N                  (CS_N_buf),
                .BUSY                  (BUSY_buf),
                .CONVST_A_ongoing      (CONVST_A_ongoing),
                .CONVST_B_ongoing      (CONVST_B_ongoing),
                .CONVST_C_ongoing      (CONVST_C_ongoing),
                .CONVST_D_ongoing      (CONVST_D_ongoing),
                .CONVST_A              (CONVST_A_buf),
                .CONVST_B              (CONVST_B_buf),
                .CONVST_C              (CONVST_C_buf),
                .CONVST_D              (CONVST_D_buf)
            );
        join_any
    end

endmodule

// ========================================================
// Behavioural SAR ADC Channel conversion model
// ========================================================
module SAR_ADC();

    // N bit DAC that calculates Vcommon based on what's in the SAR REG 
    task automatic DAC (
        input reg   [15:0]  SAR_REG,
        input real          Vref,
        output real         VDAC
    );
        bit is_negative = SAR_REG[15]; // ADC is binary 2s complement
        VDAC = is_negative ? -Vref : 0;
        
        for (int j = 14; j >= 0; j--) begin
            VDAC = VDAC  + SAR_REG[j]  * Vref / 2**(15-j); // 2 is default for RANGE
        end
    endtask

    task automatic successive_approximation (
        input  real         Vin,
        input  real         Vref,
        output reg  [15:0]  adc_val // value after successive approximation
    );
    
        // SAR ADCs work via a binary search algorithm
        // 1st bit is 1/2 VREF, 2nd bit is 1/4VREF, 3rd is 1/8th vref ... 
        // LSB = 1/2^n VREF 
        
        real        VDAC;         // DAC is used to recreate the voltage given by the capacitors to feed the comparator
        reg [15:0]  SAR_REG = 0;      // Stores the result of sampling

        // Binary 2s complement
        // -4VREF = 16'b1000_0000_0000_0000
        //     -0 = 16'b1111_1111_1111_1111
        //     +0 = 16'b0000_0000_0000_0000
        //  4VREF = 16'b0111_1111_1111_1111

        // ------ Main SAR ADC task  ------ 
        bit is_negative = (Vin < 0) ? 1 : 0;
        // Throw warning if the voltage saturates the ADC. $abs() does not work with real numbers, only ints and regs
        if (is_negative & (Vin < -Vref)) cfg.log_warning($sformatf("Vin = %11.5f is outisde voltage range +/- %6.3f", Vin, Vref), cfg.VOLTAGE_WARNINGS);
        else if           (Vin >  Vref)  cfg.log_warning($sformatf("Vin = %11.5f is outisde voltage range +/- %6.3f", Vin, Vref), cfg.VOLTAGE_WARNINGS);

        SAR_REG[15] = is_negative; // Keep MSB 0 only if positive voltage

        // Binary search is ran on the lower 15 bits since 1st is reserved for sign
        for (int i = 14; i >= 0; i--) begin
            SAR_REG[i] = 1;
            
            // Calculate DAC output
            DAC(SAR_REG, Vref, VDAC);
            if (Vin > VDAC) SAR_REG[i] = 1; 
            else            SAR_REG[i] = 0; 

            cfg.log_info($sformatf("Vin = %10.5f, VDAC = %10.5f, %b", Vin, VDAC, SAR_REG), cfg.SAR_LOOP, cfg.DISPLAY_SAR_APPX);
        end
        adc_val = SAR_REG;
        
        // Logging
        cfg.log_info("", cfg.SAR_LOOP, cfg.DISPLAY_SAR_APPX);
        cfg.log_info($sformatf("Vin = %10.5f, VDAC = %10.5f, %b", Vin, VDAC, SAR_REG), cfg.SAR_FINAL, cfg.DISPLAY_SAR_APPX);
    endtask

    task automatic start_channel_conversion (
        ref     logic        XCLK,
        input   bit          CLKSEL,
        ref     logic        CONVST_x, 
        ref     bit          channel_conv_ongoing, 

        `ifdef SAR_ADC_CONV
        ref     real         CH_ANA0, // analog value of channel
        ref     real         CH_ANA1, // analog value of channel
        ref     real         Vref,  // reference voltage
        `endif

        ref     reg  [15:0]  CH0, 
        ref     reg  [15:0]  CH1
    );
        // Initiate channel conversion for this specific channel
        @ (posedge CONVST_x) begin
            channel_conv_ongoing = 1; 

            // Conversion time
            if      (CLKSEL == 0) # (`tCONV );  // using internal clock to fixed delay
            else if (CLKSEL == 1) repeat(`tCCLK) @ (posedge XCLK); // Repeat for tCCLK cycles of the external conversion clock
    
            `ifdef USE_RANDOM_DATA
                CH0 = $urandom_range(0, 65535); // TODO Make max 2**DATA_WIDTH-1 for general model
                CH1 = $urandom_range(0, 65535);
            `endif
            
            `ifdef SAR_ADC_CONV
                successive_approximation(CH_ANA0, Vref, CH0);
                successive_approximation(CH_ANA1, Vref, CH1);
            `endif
    
            channel_conv_ongoing = 0;
        end
    endtask
endmodule

module self_checker();

    task CONFIG_REG(reg [31:0] CONFIG_REG, int message_verbosity, int configured_verbosity);
                                     $display ("[CONFIG_REG] val = 0x%h_%h", CONFIG_REG[31:16], CONFIG_REG[15:0]);
                                     $display ("[CONFIG_REG] val = 32'b%b_%b", CONFIG_REG[31:16], CONFIG_REG[15:0]);
        if (message_verbosity == configured_verbosity) begin
            if (CONFIG_REG[29] == 0) $display ("[CONFIG_REG] BIT29 - Using internal conversion clock");
            else                     $display ("[CONFIG_REG] BIT29 - Using XCLK");

            // Voltage range configurations
            if (CONFIG_REG[24] == 0) $display ("[CONFIG_REG] BIT24 - CHA Voltage range is 4VREF");
            else                     $display ("[CONFIG_REG] BIT24 - CHA Voltage range is 2VRFEF");
            if (CONFIG_REG[23] == 0) $display ("[CONFIG_REG] BIT23 - CHB Voltage range is 4VREF");
            else                     $display ("[CONFIG_REG] BIT23 - CHB Voltage range is 2VRFEF");
            if (CONFIG_REG[21] == 0) $display ("[CONFIG_REG] BIT21 - CHC Voltage range is 4VREF");
            else                     $display ("[CONFIG_REG] BIT21 - CHC Voltage range is 2VRFEF");
            if (CONFIG_REG[19] == 0) $display ("[CONFIG_REG] BIT19 - CHD Voltage range is 4VREF");
            else                     $display ("[CONFIG_REG] BIT19 - CHD Voltage range is 2VRFEF");

            // Channel ON_OFF Configuration
            if (CONFIG_REG[22] == 0) $display ("[CONFIG_REG] BIT22 - Channel B ON");
            else                     $display ("[CONFIG_REG] BIT22 - Channel B OFF");
            if (CONFIG_REG[20] == 0) $display ("[CONFIG_REG] BIT20 - Channel C ON");
            else                     $display ("[CONFIG_REG] BIT20 - Channel C OFF");
            if (CONFIG_REG[18] == 0) $display ("[CONFIG_REG] BIT18 - Channel D ON");
            else                     $display ("[CONFIG_REG] BIT18 - Channel D OFF");

            // Vref Configuration
            if (CONFIG_REG[15] == 0) $display ("[CONFIG_REG] BIT15 - Internal reference source disabled");
            else                     $display ("[CONFIG_REG] BIT15 - Internal reference source enabled");
            if (CONFIG_REG[13] == 0) $display ("[CONFIG_REG] BIT13 - Reference source = 2.5V");
            else                     $display ("[CONFIG_REG] BIT13 - Reference source = 3.0V");
                                     $display ("[CONFIG_REG] DAC   - Code = %d", CONFIG_REG[9:0]);
                                     $display ("[CONFIG_REG] DAC   - Code = %bb", CONFIG_REG[9:0]);
        end
    endtask

    task automatic one_signal_constraint(
        ref signal, 
        input bit pos_edge_start,
        input real pulse_min, // timing constraint
        input string constraint_name
    );

        realtime start_time, end_time;
        real pulse_duration;

        // Process is blocking. Later calculation won't happen until this finishes
        if (pos_edge_start) begin
            @ (posedge signal) start_time = $time;
            @ (negedge signal) end_time   = $time;
        end  else begin
            @ (negedge signal) start_time = $time;
            @ (posedge signal) end_time   = $time;
        end

        pulse_duration = real'(end_time - start_time);
        assert (pulse_duration >= pulse_min) else cfg.timing_violation(constraint_name, pulse_duration, pulse_min, cfg.STOP_SIM);

    endtask

    task automatic two_signal_constraint(
        ref signal1,
        input bit s1_pos_triggered,
        ref signal2,
        input bit s2_pos_triggered,
        input real pulse_min,
        input string constraint_name
    );
        realtime start_time, end_time;
        real pulse_duration;

        // Process is blocking. Later calculation won't happen until this finishes
        if (s1_pos_triggered) begin
            @ (posedge signal1) start_time = $time;
        end  else begin
            @ (negedge signal1) start_time = $time;
        end

        if (s2_pos_triggered) begin
            @ (posedge signal2) end_time = $time;
        end  else begin
            @ (negedge signal1) end_time = $time;
        end

        pulse_duration = real'(end_time - start_time);
        assert (pulse_duration >= pulse_min) else cfg.timing_violation(constraint_name, pulse_duration, pulse_min, cfg.STOP_SIM);

    endtask

    task Vref_out_valid(real Vref_out);
        // DAC has poor performance if Vref out is programmed to be below 0.5V       
        if (Vref_out < 0.5)      $warning ("9.3.1.7 Reference - DAC programmed to use reference voltage below 0.5V");
    endtask

    task voltage_ranges(real Vref_out, reg [31:0] CONFIG_REG);
        $display();
        if (CONFIG_REG[24] == 0) $display ("[VOLTAGE] CHA Voltage range is +/- %6.3fV", 4*Vref_out); // 0 is default, 4Vref
        else                     $display ("[VOLTAGE] CHA Voltage range is +/- %6.3fV", 2*Vref_out);
        if (CONFIG_REG[23] == 0) $display ("[VOLTAGE] CHB Voltage range is +/- %6.3fV", 4*Vref_out);
        else                     $display ("[VOLTAGE] CHB Voltage range is +/- %6.3fV", 2*Vref_out);
        if (CONFIG_REG[21] == 0) $display ("[VOLTAGE] CHC Voltage range is +/- %6.3fV", 4*Vref_out);
        else                     $display ("[VOLTAGE] CHC Voltage range is +/- %6.3fV", 2*Vref_out);
        if (CONFIG_REG[19] == 0) $display ("[VOLTAGE] CHD Voltage range is +/- %6.3fV", 4*Vref_out);
        else                     $display ("[VOLTAGE] CHD Voltage range is +/- %6.3fV", 2*Vref_out);
        $display();
    endtask
 
    task automatic write_access_properties (
        ref CS_N,
        ref WR_N,
        ref [15:0] DB
    );
    
        reg [15:0] DB_val;
        real time_start = -1, time_end;
        real pulse_duration;
    
        @ (posedge WR_N) DB_val = DB;
        # (`tHDI) assert (DB == DB_val) else $error ("tHDI requirement violated");

        // Add a checker for setup time requirement. In a sense this requires looking into the future
        @ (negedge WR_N) 
        
        do begin
            // Snap show DB, if DB_val after a timestep == DB, start recording time
            DB_val = DB;
            # (cfg.CHECKER_TIMESTEP); // How precisely setup time requirement will be measured
    
            // If they are the same value, startup the timer
            if (DB_val == DB & time_start == -1) time_start = $time;
            else if (DB_val != DB) time_start = -1;
        end while (WR_N == 0);

        time_end = $time;
        pulse_duration = time_end - time_start;
        assert (pulse_duration >= `tSUDI) else $error ("tSUDI requirement violated -- %0.5f", pulse_duration);
    
        two_signal_constraint(CS_N, 0, WR_N, 0, `tCSWR, "tCSWR");
        two_signal_constraint(WR_N, 1, CS_N, 1, `tWRCS, "tWRCS");
        one_signal_constraint(WR_N, 0,          `tWRL,  "tWRL");
        one_signal_constraint(WR_N, 1,          `tWRH,  "tWRH");
    endtask
    
    task automatic read_access_properties (
        ref logic RD_N,
        ref logic CS_N,
        ref logic BUSY,
        ref logic CONVST_A, // if the posedge construct is to be used the signal needs to be passed by reference
        ref logic CONVST_B,
        ref logic CONVST_C,
        ref logic CONVST_D,
        input int ADC_num,
        input bit CONVST_A_ongoing,
        input bit CONVST_B_ongoing,
        input bit CONVST_C_ongoing,
        input bit CONVST_D_ongoing
    );
        fork
            // PROPERTY - If a conversion is ongoing, then an error will be raised if CONVST_x is positive edge triggered at any time 
            // These are status flags that will be set inside the model that will be 1 when a conversion for that channel is ongoing. 
            @(posedge CONVST_A) assert (CONVST_A_ongoing == 0) else $warning("CHA conversion initated while conversion still ongoing");
            @(posedge CONVST_B) assert (CONVST_B_ongoing == 0) else $warning("CHB conversion initated while conversion still ongoing"); 
            @(posedge CONVST_C) assert (CONVST_C_ongoing == 0) else $warning("CHC conversion initated while conversion still ongoing"); 
            @(posedge CONVST_D) assert (CONVST_D_ongoing == 0) else $warning("CHD conversion initated while conversion still ongoing"); 
        
            // PROPERTY - Should not try to read from a channel that is not connected to a mic
            @(posedge RD_N) assert (ADC_num <= cfg.NUM_MICS) else $warning("Reading from an invalid channel");
            
            two_signal_constraint(BUSY, 0, CONVST_A, 1, `tACQ,  "tACQ");
            two_signal_constraint(BUSY, 0, CS_N,     0, `tBUCS, "tBUCS");
            two_signal_constraint(CS_N, 0, RD_N,     0, `tCSRD, "tCSRD");
            two_signal_constraint(CS_N, 1, CONVST_A, 1, `tCSCV, "tCSCV");
    
            // PROPERTY - RDL and RDH min pulse durations are met
            one_signal_constraint(RD_N, 0, `tRDL, "tRDL");
            one_signal_constraint(RD_N, 1, `tRDH, "tRDH");
    
            // Output data hold time constraint
            one_signal_constraint(RD_N, 0, `tPDDO+`tHDO, "tHDO"); // data appears at tHDO and posedge should be tDHO after that time
        join_any
    endtask
endmodule
