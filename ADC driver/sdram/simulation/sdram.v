// sdram.v

// Generated using ACDS version 18.1 625

`timescale 1 ps / 1 ps
module sdram (
		output wire [13:0] sdram_wire_addr,  // sdram_wire.addr
		output wire        sdram_wire_ba,    //           .ba
		output wire        sdram_wire_cas_n, //           .cas_n
		output wire        sdram_wire_cke,   //           .cke
		output wire        sdram_wire_cs_n,  //           .cs_n
		inout  wire [15:0] sdram_wire_dq,    //           .dq
		output wire [1:0]  sdram_wire_dqm,   //           .dqm
		output wire        sdram_wire_ras_n, //           .ras_n
		output wire        sdram_wire_we_n   //           .we_n
	);

	wire    clock_0_sdram_clk_clk;          // clock_0:sdram_clk_clk -> [SDRAM:clk, rst_controller:clk]
	wire    clock_0_sys_clk_clk;            // clock_0:sys_clk_clk -> clock_0:ref_clk_clk
	wire    clock_0_reset_source_reset;     // clock_0:reset_source_reset -> [clock_0:ref_reset_reset, rst_controller:reset_in0]
	wire    rst_controller_reset_out_reset; // rst_controller:reset_out -> SDRAM:reset_n

	sdram_SDRAM sdram (
		.clk            (clock_0_sdram_clk_clk),           //   clk.clk
		.reset_n        (~rst_controller_reset_out_reset), // reset.reset_n
		.az_addr        (),                                //    s1.address
		.az_be_n        (),                                //      .byteenable_n
		.az_cs          (),                                //      .chipselect
		.az_data        (),                                //      .writedata
		.az_rd_n        (),                                //      .read_n
		.az_wr_n        (),                                //      .write_n
		.za_data        (),                                //      .readdata
		.za_valid       (),                                //      .readdatavalid
		.za_waitrequest (),                                //      .waitrequest
		.zs_addr        (sdram_wire_addr),                 //  wire.export
		.zs_ba          (sdram_wire_ba),                   //      .export
		.zs_cas_n       (sdram_wire_cas_n),                //      .export
		.zs_cke         (sdram_wire_cke),                  //      .export
		.zs_cs_n        (sdram_wire_cs_n),                 //      .export
		.zs_dq          (sdram_wire_dq),                   //      .export
		.zs_dqm         (sdram_wire_dqm),                  //      .export
		.zs_ras_n       (sdram_wire_ras_n),                //      .export
		.zs_we_n        (sdram_wire_we_n)                  //      .export
	);

	sdram_clock_0 clock_0 (
		.ref_clk_clk        (clock_0_sys_clk_clk),        //      ref_clk.clk
		.ref_reset_reset    (clock_0_reset_source_reset), //    ref_reset.reset
		.sys_clk_clk        (clock_0_sys_clk_clk),        //      sys_clk.clk
		.sdram_clk_clk      (clock_0_sdram_clk_clk),      //    sdram_clk.clk
		.reset_source_reset (clock_0_reset_source_reset)  // reset_source.reset
	);

	altera_reset_controller #(
		.NUM_RESET_INPUTS          (1),
		.OUTPUT_RESET_SYNC_EDGES   ("deassert"),
		.SYNC_DEPTH                (2),
		.RESET_REQUEST_PRESENT     (0),
		.RESET_REQ_WAIT_TIME       (1),
		.MIN_RST_ASSERTION_TIME    (3),
		.RESET_REQ_EARLY_DSRT_TIME (1),
		.USE_RESET_REQUEST_IN0     (0),
		.USE_RESET_REQUEST_IN1     (0),
		.USE_RESET_REQUEST_IN2     (0),
		.USE_RESET_REQUEST_IN3     (0),
		.USE_RESET_REQUEST_IN4     (0),
		.USE_RESET_REQUEST_IN5     (0),
		.USE_RESET_REQUEST_IN6     (0),
		.USE_RESET_REQUEST_IN7     (0),
		.USE_RESET_REQUEST_IN8     (0),
		.USE_RESET_REQUEST_IN9     (0),
		.USE_RESET_REQUEST_IN10    (0),
		.USE_RESET_REQUEST_IN11    (0),
		.USE_RESET_REQUEST_IN12    (0),
		.USE_RESET_REQUEST_IN13    (0),
		.USE_RESET_REQUEST_IN14    (0),
		.USE_RESET_REQUEST_IN15    (0),
		.ADAPT_RESET_REQUEST       (0)
	) rst_controller (
		.reset_in0      (clock_0_reset_source_reset),     // reset_in0.reset
		.clk            (clock_0_sdram_clk_clk),          //       clk.clk
		.reset_out      (rst_controller_reset_out_reset), // reset_out.reset
		.reset_req      (),                               // (terminated)
		.reset_req_in0  (1'b0),                           // (terminated)
		.reset_in1      (1'b0),                           // (terminated)
		.reset_req_in1  (1'b0),                           // (terminated)
		.reset_in2      (1'b0),                           // (terminated)
		.reset_req_in2  (1'b0),                           // (terminated)
		.reset_in3      (1'b0),                           // (terminated)
		.reset_req_in3  (1'b0),                           // (terminated)
		.reset_in4      (1'b0),                           // (terminated)
		.reset_req_in4  (1'b0),                           // (terminated)
		.reset_in5      (1'b0),                           // (terminated)
		.reset_req_in5  (1'b0),                           // (terminated)
		.reset_in6      (1'b0),                           // (terminated)
		.reset_req_in6  (1'b0),                           // (terminated)
		.reset_in7      (1'b0),                           // (terminated)
		.reset_req_in7  (1'b0),                           // (terminated)
		.reset_in8      (1'b0),                           // (terminated)
		.reset_req_in8  (1'b0),                           // (terminated)
		.reset_in9      (1'b0),                           // (terminated)
		.reset_req_in9  (1'b0),                           // (terminated)
		.reset_in10     (1'b0),                           // (terminated)
		.reset_req_in10 (1'b0),                           // (terminated)
		.reset_in11     (1'b0),                           // (terminated)
		.reset_req_in11 (1'b0),                           // (terminated)
		.reset_in12     (1'b0),                           // (terminated)
		.reset_req_in12 (1'b0),                           // (terminated)
		.reset_in13     (1'b0),                           // (terminated)
		.reset_req_in13 (1'b0),                           // (terminated)
		.reset_in14     (1'b0),                           // (terminated)
		.reset_req_in14 (1'b0),                           // (terminated)
		.reset_in15     (1'b0),                           // (terminated)
		.reset_req_in15 (1'b0)                            // (terminated)
	);

endmodule
