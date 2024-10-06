//====================================
// ADC Behav Params
//====================================
`define SAR_ADC_CONV  // Comment to switch between SAR ADC + Data values or randomized values

`ifndef SAR_ADC_CONV
    `define USE_RANDOM_DATA
`endif

module cfg();
    // Configurations go here
    int  DATA_WIDTH = 16; // 12, 14, 16 bit ADC

    // ========================================
    // Display Control
    // ========================================
    int DISPLAY_SAR_APPX     = 1; // {0, 1, 2}
    int DISPLAY_CONFIG_REF   = 0; // {0, 1}

    // ========================================
    // Display option explanations
    // ========================================

    // SAR options
    int SAR_DISABLE = 0; // Don't show any info about SAR vals
    int SAR_FINAL   = 1; // Print final value only
    int SAR_LOOP    = 2; // 16 lines / val. 1 line for each bit during successive appx.

    // Configuration register options
    int CONFIG_HIDE = 0; // Don't print on contents of configuration register
    int CONFIG_SHOW = 1;

    // ========================================
    // Helper Takss
    // ========================================

    // Call with $sformatf for message. Functions similarly to UVM_INFO but verbosity must match exactly
    task log_info(
        string message, 
        int message_verbosity,   // verbosity for which the message will be triggered
        int configured_verbosity // option set above in display control section
    );
        if (configured_verbosity == message_verbosity) $display(message);
    endtask

endmodule