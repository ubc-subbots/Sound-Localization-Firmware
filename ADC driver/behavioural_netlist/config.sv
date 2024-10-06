//====================================
// ADC Behav Params
//====================================
`define SAR_ADC_CONV  // Comment to switch between SAR ADC + Data values or randomized values



`ifndef SAR_ADC_CONV  // Don't manually edit this
    `define USE_RANDOM_DATA
`endif


module cfg();
    // Configurations go here
    int  DATA_WIDTH = 16; // 12, 14, 16 bit ADC

    // ========================================
    // Display Control (edit these)
    // ========================================

    int DISPLAY_SAR_APPX     = 0; // See SAR options    --- Valid options {0, 1, 2}
    int DISPLAY_CONFIG_REF   = 1; // See config optiosn --- Valid options {0, 1}
    int DISPLAY_VOLTAGE_WARN = 1; // 0 = hide, 1 = show --- Valid options {0, 1}


    // ===========================================================================


    // =============================================
    // Display option explanations (don't touch)
    // =============================================

    // SAR options
    int SAR_DISABLE = 0;      // Don't show any info about SAR vals
    int SAR_FINAL   = 1;      // Print final value only
    int SAR_LOOP    = 2;      // 16 lines / val. 1 line for each bit during successive appx.

    // Configuration register options
    int CONFIG_HIDE = 0;
    int CONFIG_SHOW = 1;       // Print out the contents of the control register

    // Voltage warn options
    int VOLTAGE_WARN_HIDE = 0;
    int VOLTAGE_WARN_SHOW = 1; // Print out the contents of the control register

    // ========================================
    // Helper Taks (dont' touch)
    // ========================================

    // Call with $sformatf for message. Functions similarly to UVM_INFO but verbosity must match exactly
    task log_info(
        string message, 
        int message_verbosity,   // verbosity for which the message will be triggered
        int configured_verbosity // option set above in display control section
    );
        if (configured_verbosity == message_verbosity) $display(message);
    endtask

    task log_warning (
        string message, 
        int    show_warning
    );
        if (show_warning) $display($sformatf("[WARNING] @ %10.2fus --- %s", real'($time/100_000.0), message));
    endtask

endmodule