//====================================
// ADC Params
//====================================
`define SAR_ADC_CONV  // Comment to switch between SAR ADC + Data values or randomized values

`ifndef SAR_ADC_CONV
    `define USE_RANDOM_DATA
`endif

module cfg();
    // Configurations go here
    real Vref = 2.5;
    int  DATA_WIDTH = 16; // 12, 14, 16 bit ADC
endmodule