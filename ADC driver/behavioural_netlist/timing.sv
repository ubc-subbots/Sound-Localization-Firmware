//========================
//  ADS8528 Timing Sepcs
//========================

`include "config.sv"

// Conversion Clocking
`define tCONV 1330 // conversion logic  - Conversion time
`define tCCLK 20   // conversion logic  - Number of complete conversion clocks

`ifndef NO_TIMING
// Write Access Timing
`define tCSWR 0    // input constraint - CS  low to WR low time
`define tWRL  15   // input constraint - WR low pulse duration
`define tWRH  10   // input constraint - Minimum time between two write accesses
`define tWRCS 0    // input constraint - WR high to CS high time
`define tSUDI 5    // input constraint - Output data to WR rising edge setup time
`define tHDI  5    // input constraint - Data output to WR rising edge hold time


// Read Access Timing
`define tCVL  20   // input constraint  - CONVST_x low time
`define tDCVB 25   // output constraint - CONVST_x high to BUSY high delay
`define tBUCS 0    // input constraint  - BUSY low to CS low time ADS85x8, CLKSEL = 1
`define tCSCV 0    // input constraint  - Bus access finished to next conversion start time ADS8528
`define tCSRD 0    // input constraint  - CS low to RD low time
`define tRDCS 0    // input constraint  - RD high to CS high time
`define tRDL  20   // input consatrint  - RD pulse duration
`define tRDH  2    // input consatrint  - Minimum time between two read accesses
`define tPDDO 15   // output consatrint - RD or CS falling edge to data valid propagation delay
`define tHDO  15   // input constraint  - Output data to RD or CS rising edge hold time
`define tDTRI 10   // input constraint  - CS high to DB[15:0] three-state delay
`endif 
`ifdef NO_TIMING 
    `define tCSWR 0    
    `define tWRL  0   
    `define tWRH  0   
    `define tWRCS 0    
    `define tSUDI 0    
    `define tHDI  0    
    `define tCVL  0   
    `define tDCVB 0   
    `define tBUCS 0    
    `define tCSCV 0    
    `define tCSRD 0    
    `define tRDCS 0    
    `define tRDL  0   
    `define tRDH  0    
    `define tPDDO 0   
    `define tHDO  0   
    `define tDTRI 0   
`endif