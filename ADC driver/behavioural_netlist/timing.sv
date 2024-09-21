//========================
//  ADS8528 Timing Sepcs
//========================

// Write Access Timing
`define tCSWR 0    // input constraint - CS  low to WR low time
`define tWRL  15   // input constraint - WR low pulse duration
`define tWRH  10   // input constraint - Minimum time between two write accesses
`define tWRCS 0    // input constraint - WR high to CS high time
`define tSUDI 5    // input constraint - Output data to WR rising edge setup time
`define tHDI  5    // input constraint - Data output to WR rising edge hold time


// Read Access Timing
`define tCVL  20   // input constraint  - CONVST_x low time
`define tACQ  280  // input constraint  - Acquisition time
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