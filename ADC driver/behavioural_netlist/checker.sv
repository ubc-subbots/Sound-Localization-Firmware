module self_checker();

    /////////////////////////////////////////////////////////////////////////////////////////////

    // ========================================================
    // Configuration register checking
    // ========================================================

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


    /////////////////////////////////////////////////////////////////////////////////////////////

    // ========================================================
    // Main Write and Read Access Loops
    // ========================================================
 
    task automatic write_access_properties (
        ref CS_N,
        ref WR_N,
        ref [15:0] DB
    );
        fork
            two_signal_constraint(CS_N, 0, WR_N, 0, `tCSWR, "tCSWR");
            two_signal_constraint(WR_N, 1, CS_N, 1, `tWRCS, "tWRCS");
            one_signal_constraint(WR_N, 0,          `tWRL,  "tWRL");
            one_signal_constraint(WR_N, 1,          `tWRH,  "tWRH");
        join_any       

        // Only check if the interface has been enabled
        if (CS_N == 0) begin
            fork 
                hold_constraint (WR_N, DB, `tHDI, "tHDI");
                setup_constraint(WR_N, DB, `tSUDI, "tSUDI");
            join_any
        end

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


    /////////////////////////////////////////////////////////////////////////////////////////////

    // ========================================================
    // Pulse width constraint checks
    // ========================================================

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
        if (s1_pos_triggered) @ (posedge signal1) start_time = $time;
                              @ (negedge signal1) start_time = $time;

        if (s2_pos_triggered) @ (posedge signal2) end_time = $time;
                              @ (negedge signal1) end_time = $time;

        pulse_duration = real'(end_time - start_time);
        assert (pulse_duration >= pulse_min) else cfg.timing_violation(constraint_name, pulse_duration, pulse_min, cfg.STOP_SIM);
    endtask


    /////////////////////////////////////////////////////////////////////////////////////////////

    // Setup and hold time checks        

    task automatic hold_constraint(
        ref          signal,
        ref [15:0]   DB,
        input real   hold_time,
        input string constraint_name
    );
        reg [15:0] DB_val;

        @ (posedge signal) DB_val = DB;
        # (hold_time) assert (DB == DB_val) else $error ($sformatf("%s hold time violated", constraint_name ));
    endtask


    task automatic setup_constraint(
        ref          signal,
        ref [15:0]   DB,
        input real   hold_time,
        input string constraint_name
    );
        real time_start = -1, time_end;
        real pulse_duration;
        reg [15:0] DB_val;

        @ (negedge signal);
        do begin
            // Snap show DB, if DB_val after a timestep == DB, start recording time
            DB_val = DB;
            # (cfg.CHECKER_TIMESTEP); // How precisely setup time requirement will be measured
    
            // If they are the same value, startup the timer
            if (DB_val == DB & time_start == -1) time_start = $time;
            else if (DB_val != DB) time_start = -1;
        end while (signal == 0);

        time_end = $time;
        pulse_duration = time_end - time_start;
        assert (pulse_duration >= hold_time) else begin
            $error ($sformatf("%s setup time violated -- pulse duration was %0.5f.", constraint_name, pulse_duration));
        end

    endtask

endmodule
