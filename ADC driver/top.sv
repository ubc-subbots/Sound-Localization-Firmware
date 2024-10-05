`timescale 1ns/1ps
`default_nettype none

/**
 * ADS8528 Sampler Top-level module
 *
 * This module connects the ADC ADS8528 Controller module to the sample buffer, which is connected
 * to the SPI slave that interacts with the RaspberryPi.
 *
 * TODO:
 *      - rename module to adc_ads8528_sampler_top without breaking Quartus project
 */
module top #(
	parameter int 		 BUFFER_DEPTH       = 500,
	parameter int 		 NUM_OUTPUT_SAMPLES = 500,    // Number of ADC samples sent to raspberry pi
	parameter bit [15:0] VALID_VOLTAGE      = 16'd32, // Any voltage above this threshold will be considered valid
	parameter int 		 threshold_count_NEEDED = 20      // Number of valid voltages to be considered valid pulse
) (
    inout logic [15:0] DB,  //driver inputs
    input logic Busy,
    input logic CLOCK_27M,
    input logic rst,
    input logic KEY2,

    input logic sclk, //SPI inputs
    input logic SPI_cs,
    input logic transaction_done,

    output logic convst_A, //Driver outputs to ADC
    output logic convst_B,
    output logic convst_C,
    output logic convst_D,
    output logic RD_N,
    output logic ADC_CS_N,
    output logic HW_N,
    output logic PAR_N,
    output logic ADCrst,
    output logic STBY_N,
    output logic WR_N,
    output logic XCLK,

    output logic processed_MISO, //SPI outputs to Rasberry pi
    output logic SPI_RDY
);


    ////////////////////////////////////////////////////////////////////////////////////////////////
    // SECTION: Types and Constants Declarations


    typedef enum {
        DEFAULT_WAIT        = 'b0,
        JUNK                = 'b11,
        FILL_BUFFER         = 'b1,
        DUMP_EXCESS         = 'b1010,
        COLLECT_UNTIL_FULL  = 'b1001,
        WAIT_FOR_FILL       = 'b1000,
        PASSING_DATA_TO_SPI = 'b10,
        SPI                 = 'b100,
        WAIT_FOR_SPI        = 'b10000
    } state_t;


    ////////////////////////////////////////////////////////////////////////////////////////////////
    // SECTION: Signal Declarations


    state_t state;
    logic clk; 

    // Outputs of ADC ADS8528 Controller
    logic [15:0] adc_data_out;
    logic        adc_data_out_valid;

    // FIFO Buffer Signals
    logic                            write_to_buffer;  // Assert to write a value to the input of the buffer
    logic                            read_from_buffer; // Assert to read the value at the output of the buffer
    logic [$clog2(BUFFER_DEPTH)-1:0] buffer_count;     // Indicates the number of values stored in the buffer
    logic                            full, empty;      // Indicates if the buffer is full or empty
    logic [15:0]                     buffer_data_out;  // Output of the buffer

    // SPI Slave signals
    logic ready_for_data;

    logic [31:0] threshold_count; // Counter of consecutive valid voltages for threshold detection
    logic [31:0] count;           // Counter to indicate how many valid samples we are storing in storage, 
                                  // and if this hits NUM_OUTPUT_SAMPLES, empty everything to SPI 


    ////////////////////////////////////////////////////////////////////////////////////////////////
    // SECTION: Output Assignments


    assign ADCrst  = ~KEY2;
    assign XCLK    = 1'b1; //should be clk
    assign SPI_RDY = state[2];


    ////////////////////////////////////////////////////////////////////////////////////////////////
    // SECTION: Logic Implementation


    assign write_to_buffer  = state[0];
    assign read_from_buffer = state[1];

    // Clock Divider
    Clk_divider clk_divider_inst (
        .clk_in  ( CLOCK_27M ),
        .divisor ( 32'd4     ),
        .switch  ( 1'd1      ),
        .clk_out ( clk       )
    );

    // ADS8528 ADC Controller
    driver adc_ads8528_ctrl_inst (
        .clk           ( clk      ),
        .sresetn       ( rst      ),
        .busy          ( Busy     ),

        .data_adc      ( DB       ),

        // ADS8528 Control Signals
        .read_n        ( RD_N     ),
        .write_n       ( WR_N     ),
        .chipselect_n  ( ADC_CS_N ),
        .software_mode ( HW_N     ),
        .serial_mode   ( PAR_N    ),
        .standby_n     ( STBY_N   ),

        // ADS8528 starts conversion of channel 'x' on rising-edge of conv_start_x
        .conv_start_a  ( convst_A ),
        .conv_start_b  ( convst_B ),
        .conv_start_c  ( convst_C ),
        .conv_start_d  ( convst_D ),

        // Driver handshake
        .data_out      ( adc_data_out       ),
        .data_valid    ( adc_data_out_valid )
    );

    // FIFO Buffer for ADC Data
    ADCmemory fifo_buffer_inst  (
        .clk      ( clk              ),
        .rst      ( rst              ),
        .write    ( write_to_buffer  ),
        .read     ( read_from_buffer ),
        .data_in  ( adc_data_out     ),
        .count    ( buffer_count     ),
        .data_out ( buffer_data_out  ),
        .full     ( full             ),
        .empty    ( empty            )
    );

    // SPI Slave connected to RaspberryPi
    spi spi_slave_inst(
        .rst              ( rst             ),
        .sclk             ( sclk            ),
        .cs               ( SPI_cs          ),
        .unprocessed_MISO ( buffer_data_out ),
        .processed_MISO   ( processed_MISO  ),
        .ready_for_data   ( ready_for_data  )
    );

    // Top-Level State Machine Controller
    always_ff@(posedge clk or negedge rst) begin
        if (!rst) begin
            state <= DEFAULT_WAIT;

        end else begin
            case(state)
                DEFAULT_WAIT: begin
                    if (adc_data_out_valid) begin
                        if (threshold_count == threshold_count_NEEDED) begin
                            state <= COLLECT_UNTIL_FULL;
                        end else if (buffer_count < BUFFER_DEPTH) begin
                            state <= FILL_BUFFER;
                        end else if (buffer_count == BUFFER_DEPTH) begin
                            state <= JUNK;
                        end else if (buffer_count > BUFFER_DEPTH) begin
                            state <= DUMP_EXCESS;
                        end else begin
                            state <= DEFAULT_WAIT;
                        end
                    end
                end

                JUNK: begin
                    state <= DEFAULT_WAIT;
                end

                FILL_BUFFER: begin
                    state <= DEFAULT_WAIT;
                end

                COLLECT_UNTIL_FULL: begin
                    if (count == NUM_OUTPUT_SAMPLES) begin
                        state <= PASSING_DATA_TO_SPI;
                    end else begin
                        state <= WAIT_FOR_FILL;
                    end
                end

                WAIT_FOR_FILL: begin
                    if (adc_data_out_valid) begin
                        state <= COLLECT_UNTIL_FULL;
                    end else begin 
                        state <= WAIT_FOR_FILL;
                    end
                end

                PASSING_DATA_TO_SPI: begin
                    state <= SPI;
                end

                SPI: begin
                    if (empty) begin
                        state <= DEFAULT_WAIT;
                    end else if (~SPI_cs) begin
                        state <= WAIT_FOR_SPI;
                    end else begin
                        state <= SPI;
                    end
                end

                WAIT_FOR_SPI: begin
                    if (transaction_done) begin
                        state <= PASSING_DATA_TO_SPI;
                    end else begin
                        state <= WAIT_FOR_SPI;
                    end
                end

                default: state <= DEFAULT_WAIT;
            endcase 
        end
    end

    // Threshold Detection Counter Register
    always_ff @(posedge clk or negedge rst) begin
        if(!rst) begin
            threshold_count <= 32'd0;

        end else begin
            if ((((state == JUNK) || (state == FILL_BUFFER))) && ((adc_data_out >= VALID_VOLTAGE) && (adc_data_out < 16'b1111_1000_0000_0000))) begin
                threshold_count <= threshold_count + 1'd1;

            end else if (state == COLLECT_UNTIL_FULL) begin
                threshold_count <= 32'd0;
            end
        end
    end

    always_ff@(posedge clk or negedge rst) begin
        if(!rst) begin
            count <= 32'd0;

        end else begin
            if (state == COLLECT_UNTIL_FULL) begin
                count <= count + 1'd1;

            end else if (state == SPI) begin
                count <= 32'd0;
            end
        end
    end
endmodule

`default_nettype wire

/// # ADS8528 Driver Specification
///
/// ## Overview
///
/// Top level module responsible with the driver, memory
/// as well as the SPI module to raspberry-pi
///
/// ## IO Ports
/// refer to individual modules for port descrption
///
/// ## parameter 
///
/// BUFFER_SAMPLE : The maximum amount of sample stored in the FIFO while junk data is being read, writing to the FIFO while at this limit results in trashing whatever is at the start of the queue
/// VALID_VOLTAGE : Any voltage above this threshold will be considered valid
/// VALID_COUNT_NEEDED : The valid voltage the FPGA needs to recieve in a row for the system to consider it a valid pulse and transmit it to the raspberry pi 
/// NUM_SAMPLES_TO_COLLECT : Amount of sample to be collected and sent to the raspberry pi


// module top(
// 	inout [15:0] DB,  // data bus line
// 	input Busy,       // George: What is this signal? It controls the ADC driver logic
// 	input CLOCK_27M,
// 	input rst,        // George: is this active low? Should be named rst_n if so 
// 	input KEY2,
	
// 	input sclk, //SPI inputs
// 	input SPI_cs,
// 	input transaction_done, // George: What is this signal? Does it come from the ras pi? 
	
// 	output logic convst_A, //Driver outputs to ADC
// 	output logic convst_B,
// 	output logic convst_C,
// 	output logic convst_D,
// 	output logic RD_N, 
// 	output logic ADC_CS_N,
// 	output logic HW_N,
// 	output logic PAR_N,
// 	output logic ADCrst,
// 	output logic STBY_N,
// 	output logic WR_N,
// 	output logic XCLK,

	
// 	output logic processed_MISO, //SPI outputs to Rasberry pi
// 	output logic SPI_RDY
// );
// 	// Should paramaterize a value called `ADC_W or something to indicate the word length

// 	parameter [31:0] BUFFER_SAMPLE = 32'd100; // George: 32 bits aren't needed to store this value. Can just use the d'500 syntax and verilog will automatically get the vector length
// 	parameter [15:0] VALID_VOLTAGE = 16'd32; // George: I assume this is to set up something like a noise floor?
// 	parameter [31:0] VALID_COUNT_NEEDED = 32'd20;
// 	parameter [31:0] NUM_READINGS = 32'd100; // George: Renamed from REQUIRED_VOLTAGE since it's confusing with VALID_VOLTAGE
	
// 	logic [15:0] toMem;
// 	logic mem_ready;
	
// 	logic mem_write;
// 	logic mem_read;
// 	logic [13:0] mem_count;
// 	logic [15:0] toSPI;
// 	logic full;
// 	logic empty;
	
// 	logic ready_for_data;
	
	
// 	logic [31:0] valid_count; //counter to indicate how many valid voltage we have gotten in a row, indicating if what we are detecting is a real pulse
// 	logic [31:0] count; //counter to indicate how many voltage we are storing in storage, and if this hits NUM_READINGS, we begin empting everything to SPI 

// 	logic clk; 
		
// 	assign ADCrst = ~KEY2;
	
// 	parameter [5:0] 	 DEFAULT_WAIT        = 6'd000000,
// 						 JUNK                = 6'b000011, // write, read
// 						 FILL_BUFFER         = 6'b000001, // write, 
// 						 DUMP_EXCESS         = 6'b001010, //        read
// 						 COLLECT_UNTIL_FULL  = 6'b001001, // write
// 						 WAIT_FOR_FILL       = 6'b001000,
// 						 PASSING_DATA_TO_SPI = 6'b000010, //        read
// 						 SPI                 = 6'b000110, // George: in your SPI state you're not reading from adc mem
// 						 WAIT_FOR_SPI        = 6'b010000; 
						 
//    logic [5:0] state = DEFAULT_WAIT; 
	
// 	// George: Seems like bad practice to have it here. Should be in a combinational block
// 	// This will also force the synthesizer to use less efficient state encoding which could impact timing closure
// 	assign mem_write = state[0]; // FILL, COLLECT 
// 	assign mem_read  = state[1]; //  
// 	assign SPI_RDY   = state[2];
	
// 	// 50 / 4 -> 12.5MHz 
// 	Clk_divider Clk_divider_inst(
// 		.clk_in(CLOCK_27M),
// 		.divisor(32'd2),
// 		.switch(1'd1),
// 		.clk_out(clk) 
// 	);
	
// 	assign XCLK = 1'b1; //should be cll --> XCLK is the external clock that drives the ADC. 
	
// 	driver driver_inst(
// 		.convst_A(convst_A),
// 		.convst_B(convst_B),
// 		.convst_C(convst_C),
// 		.convst_D(convst_D),
// 		.RD_N(RD_N),
// 		.CS_N(ADC_CS_N),
// 		.HW_N(HW_N),
// 		.PAR_N(PAR_N),
// 		.ADCrst(),
// 		.STBY_N(STBY_N),
// 		.WR_N(WR_N),
// 		.toMem(toMem),         // output to ADC mem
// 		.mem_ready(mem_ready), // output to state machine
// 		.DB(DB),               // inout - data bus
// 		.state_ff(),  

// 		.Busy(Busy),            // input DC
// 		.rst(rst),              // input  
// 		.clk(clk)               // input  
// 	);
	
// 	// George: You guys will be potentially running into CDC issues here with transferring between the clk <--> sclk domains
// 	// George: Style recommendation: having _o or _i directly on the signal name so that you don't need to dig to find it

// 	ADCmemory ADCmemory_inst(
// 		.clk(clk),
// 		.rst(rst),
// 		.write(mem_write), // input port 
// 		.read(mem_read),   // input port 
// 		.data_in(toMem),
// 		.count(mem_count),
// 		.data_out(toSPI),
// 		.full(full),
// 		.empty(empty)
// 	); 
	
// 	spi spi_inst(
// 		.rst(rst),
// 		.sclk(sclk),
// 		.cs(SPI_cs),              // input
// 		.unprocessed_MISO(toSPI), //should be toSPI
// 		.processed_MISO(processed_MISO),
// 		.ready_for_data(ready_for_data) // output but not used
// 	);

// 	//-------------------------//
// 	//           FSM           //
// 	//-------------------------//

// 	// State transition always block
// 	always_ff@(posedge clk or negedge rst) begin 
// 		if(~rst) begin
// 			state <= DEFAULT_WAIT;
// 		end else begin
// 			case(state) 
// 				DEFAULT_WAIT: begin
// 								if     (mem_ready && (valid_count == VALID_COUNT_NEEDED)) state <= COLLECT_UNTIL_FULL;
// 								else if(mem_ready && (mem_count <  BUFFER_SAMPLE))        state <= FILL_BUFFER;
// 								else if(mem_ready && (mem_count == BUFFER_SAMPLE))        state <= JUNK;
// 								else if(mem_ready && (mem_count >  BUFFER_SAMPLE))        state <= DUMP_EXCESS;
// 								else                                                      state <= DEFAULT_WAIT; 
// 								end
// 				JUNK:        state <= DEFAULT_WAIT; 
// 				FILL_BUFFER: state <= DEFAULT_WAIT; 
// 				COLLECT_UNTIL_FULL: begin
// 	 								if(count == NUM_READINGS)  state <= PASSING_DATA_TO_SPI;
// 									else                       state <= WAIT_FOR_FILL;
// 							    end 
// 				WAIT_FOR_FILL:  begin
// 									if(mem_ready)				state <= COLLECT_UNTIL_FULL;
// 									else                   	 	state <= WAIT_FOR_FILL;
// 								end 
// 				PASSING_DATA_TO_SPI: state <= SPI;
// 				SPI: 			begin
// 									if(empty) 					state <= DEFAULT_WAIT;
// 									else if(~SPI_cs) 			state <= WAIT_FOR_SPI;
// 									else  state <= SPI;
// 					  			end
// 				WAIT_FOR_SPI:   begin	
// 									if(transaction_done)		state <= PASSING_DATA_TO_SPI;
// 									else  						state <= WAIT_FOR_SPI;
// 								end 
// 				default: state <= DEFAULT_WAIT;
// 				endcase 
		
// 		end
// 	end
	
// 	// This block needs to be changed to be a case statement 
// 	// Why is the output logic combinational???
// 	always_ff@(posedge clk or negedge rst) begin
// 		if(~rst) begin
// 			valid_count <= 32'd0;
// 		end else begin
// 			if((((state == JUNK) || (state == FILL_BUFFER))) && ((toMem >= VALID_VOLTAGE) && (toMem < 16'b1111_1000_0000_0000)))  // George: timing. Also needs a comment explaning the upper value limit. It's -2048 in 2s complement so that can be stored in 12 bits?
// 				valid_count <= valid_count + 1'd1; 
// 			else if(state == COLLECT_UNTIL_FULL) 
// 				valid_count <= 32'd0; 
// 			// valid_count otherwise?
// 		end
// 	end


// 	always_ff@(posedge clk or negedge rst) begin
// 		if(~rst) begin count <= 32'd0; end 
// 		else begin
// 			if(state == COLLECT_UNTIL_FULL)
// 				count <= count + 1'd1;
// 			else if(state == SPI) 
// 				count <= 32'd0;

// 			// should count be kept the same otherwise?
// 		end
// 	end
// endmodule