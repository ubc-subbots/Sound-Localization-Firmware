onerror {resume}
radix define  {
    -default default
}
radix define state {
    "6'b000000" "DEFAULT_WAIT",
    "6'b000011" "JUNK",
    "6'b000001" "FILL_BUFFER",
    "6'b001010" "DUMP_EXCESS",
    "6'b001001" "COLLECT_UNTIL_FULL",
    "6'b001000" "WAIT_FOR_FILL",
    "6'b000010" "PASSING_DATA_TO_SPI",
    "6'b000100" "SPI",
    "6'b010000" "WAIT_FOR_SPI",
    -default binary
}
radix define driver_states {
    "5'b00000" "HOLD",
    "5'b00010" "INIT",
    "5'b00100" "BUSY",
    "5'b01000" "MEM",
    -default binary
}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {ADC Inst} -radix hexadecimal /top_tb/adc_inst/CH_D1
add wave -noupdate -expand -group {ADC Inst} -radix hexadecimal /top_tb/adc_inst/CH_D0
add wave -noupdate -expand -group {ADC Inst} -radix hexadecimal /top_tb/adc_inst/CH_C1
add wave -noupdate -expand -group {ADC Inst} -divider {Valid ADC Channel}
add wave -noupdate -expand -group {ADC Inst} -radix hexadecimal /top_tb/adc_inst/CH_C0
add wave -noupdate -expand -group {ADC Inst} -radix hexadecimal /top_tb/adc_inst/CH_B1
add wave -noupdate -expand -group {ADC Inst} -radix hexadecimal /top_tb/adc_inst/CH_B0
add wave -noupdate -expand -group {ADC Inst} -radix hexadecimal /top_tb/adc_inst/CH_A1
add wave -noupdate -expand -group {ADC Inst} -radix hexadecimal /top_tb/adc_inst/CH_A0
add wave -noupdate -expand -group {ADC Inst} -radix hexadecimal /top_tb/adc_inst/CONFIG_REG
add wave -noupdate -expand -group {ADC Inst} -radix hexadecimal /top_tb/adc_inst/ADC_num
add wave -noupdate /top_tb/DUT/driver_inst/WR_N
add wave -noupdate /top_tb/RD_N
add wave -noupdate /top_tb/adc_inst/BUSY
add wave -noupdate -expand -group {DUT counters} -radix unsigned /top_tb/DUT/valid_count
add wave -noupdate -expand -group {DUT counters} -radix unsigned /top_tb/DUT/mem_count
add wave -noupdate -expand -group {DUT counters} -radix unsigned /top_tb/DUT/count
add wave -noupdate -expand -group DUT -radix hexadecimal /top_tb/DB
add wave -noupdate -expand -group DUT /top_tb/XCLK
add wave -noupdate -expand -group DUT /top_tb/sclk
add wave -noupdate -expand -group DUT /top_tb/rst
add wave -noupdate -expand -group DUT /top_tb/DUT/mem_ready
add wave -noupdate -expand -group DUT /top_tb/convst_D
add wave -noupdate -expand -group DUT /top_tb/convst_C
add wave -noupdate -expand -group DUT /top_tb/convst_B
add wave -noupdate -expand -group DUT /top_tb/convst_A
add wave -noupdate -radix state -childformat {{{/top_tb/DUT/state[5]} -radix state} {{/top_tb/DUT/state[4]} -radix state} {{/top_tb/DUT/state[3]} -radix state} {{/top_tb/DUT/state[2]} -radix state} {{/top_tb/DUT/state[1]} -radix state} {{/top_tb/DUT/state[0]} -radix state}} -subitemconfig {{/top_tb/DUT/state[5]} {-height 15 -radix state} {/top_tb/DUT/state[4]} {-height 15 -radix state} {/top_tb/DUT/state[3]} {-height 15 -radix state} {/top_tb/DUT/state[2]} {-height 15 -radix state} {/top_tb/DUT/state[1]} {-height 15 -radix state} {/top_tb/DUT/state[0]} {-height 15 -radix state}} /top_tb/DUT/state
add wave -noupdate -radix driver_states /top_tb/DUT/driver_inst/state_ff
add wave -noupdate -group Driver /top_tb/DUT/driver_inst/clk
add wave -noupdate -group Driver /top_tb/DUT/driver_inst/rst
add wave -noupdate -group Driver -radix driver_states /top_tb/DUT/driver_inst/state_ff
add wave -noupdate -expand -group {ADC mem} /top_tb/DUT/mem_read
add wave -noupdate -expand -group {ADC mem} -childformat {{{/top_tb/DUT/ADCmemory_inst/storage[0]} -radix hexadecimal} {{/top_tb/DUT/ADCmemory_inst/storage[1]} -radix hexadecimal} {{/top_tb/DUT/ADCmemory_inst/storage[2]} -radix hexadecimal} {{/top_tb/DUT/ADCmemory_inst/storage[3]} -radix hexadecimal} {{/top_tb/DUT/ADCmemory_inst/storage[4]} -radix hexadecimal} {{/top_tb/DUT/ADCmemory_inst/storage[5]} -radix hexadecimal} {{/top_tb/DUT/ADCmemory_inst/storage[6]} -radix hexadecimal} {{/top_tb/DUT/ADCmemory_inst/storage[7]} -radix hexadecimal} {{/top_tb/DUT/ADCmemory_inst/storage[8]} -radix hexadecimal} {{/top_tb/DUT/ADCmemory_inst/storage[9]} -radix hexadecimal} {{/top_tb/DUT/ADCmemory_inst/storage[10]} -radix hexadecimal} {{/top_tb/DUT/ADCmemory_inst/storage[11]} -radix hexadecimal} {{/top_tb/DUT/ADCmemory_inst/storage[12]} -radix hexadecimal} {{/top_tb/DUT/ADCmemory_inst/storage[13]} -radix hexadecimal} {{/top_tb/DUT/ADCmemory_inst/storage[14]} -radix hexadecimal} {{/top_tb/DUT/ADCmemory_inst/storage[15]} -radix hexadecimal} {{/top_tb/DUT/ADCmemory_inst/storage[16]} -radix hexadecimal} {{/top_tb/DUT/ADCmemory_inst/storage[17]} -radix hexadecimal} {{/top_tb/DUT/ADCmemory_inst/storage[18]} -radix hexadecimal} {{/top_tb/DUT/ADCmemory_inst/storage[19]} -radix hexadecimal} {{/top_tb/DUT/ADCmemory_inst/storage[20]} -radix hexadecimal} {{/top_tb/DUT/ADCmemory_inst/storage[21]} -radix hexadecimal}} -subitemconfig {{/top_tb/DUT/ADCmemory_inst/storage[0]} {-height 15 -radix hexadecimal} {/top_tb/DUT/ADCmemory_inst/storage[1]} {-height 15 -radix hexadecimal} {/top_tb/DUT/ADCmemory_inst/storage[2]} {-height 15 -radix hexadecimal} {/top_tb/DUT/ADCmemory_inst/storage[3]} {-height 15 -radix hexadecimal} {/top_tb/DUT/ADCmemory_inst/storage[4]} {-height 15 -radix hexadecimal} {/top_tb/DUT/ADCmemory_inst/storage[5]} {-height 15 -radix hexadecimal} {/top_tb/DUT/ADCmemory_inst/storage[6]} {-color Cyan -height 15 -radix hexadecimal} {/top_tb/DUT/ADCmemory_inst/storage[7]} {-height 15 -radix hexadecimal} {/top_tb/DUT/ADCmemory_inst/storage[8]} {-height 15 -radix hexadecimal} {/top_tb/DUT/ADCmemory_inst/storage[9]} {-height 15 -radix hexadecimal} {/top_tb/DUT/ADCmemory_inst/storage[10]} {-height 15 -radix hexadecimal} {/top_tb/DUT/ADCmemory_inst/storage[11]} {-height 15 -radix hexadecimal} {/top_tb/DUT/ADCmemory_inst/storage[12]} {-color Cyan -height 15 -radix hexadecimal} {/top_tb/DUT/ADCmemory_inst/storage[13]} {-height 15 -radix hexadecimal} {/top_tb/DUT/ADCmemory_inst/storage[14]} {-height 15 -radix hexadecimal} {/top_tb/DUT/ADCmemory_inst/storage[15]} {-height 15 -radix hexadecimal} {/top_tb/DUT/ADCmemory_inst/storage[16]} {-height 15 -radix hexadecimal} {/top_tb/DUT/ADCmemory_inst/storage[17]} {-height 15 -radix hexadecimal} {/top_tb/DUT/ADCmemory_inst/storage[18]} {-height 15 -radix hexadecimal} {/top_tb/DUT/ADCmemory_inst/storage[19]} {-height 15 -radix hexadecimal} {/top_tb/DUT/ADCmemory_inst/storage[20]} {-height 15 -radix hexadecimal} {/top_tb/DUT/ADCmemory_inst/storage[21]} {-height 15 -radix hexadecimal}} /top_tb/DUT/ADCmemory_inst/storage
add wave -noupdate -expand -group {SPI Inst} /top_tb/DUT/spi_inst/rst
add wave -noupdate -expand -group {SPI Inst} /top_tb/DUT/spi_inst/sclk
add wave -noupdate -expand -group {SPI Inst} /top_tb/DUT/spi_inst/cs
add wave -noupdate -expand -group {SPI Inst} -radix hexadecimal /top_tb/DUT/spi_inst/unprocessed_MISO
add wave -noupdate -expand -group {SPI Inst} /top_tb/DUT/spi_inst/processed_MISO
add wave -noupdate -expand -group {SPI Inst} /top_tb/DUT/spi_inst/ready_for_data
add wave -noupdate -expand -group {SPI Inst} -radix unsigned /top_tb/DUT/spi_inst/MISO_counter
add wave -noupdate -expand -group {SPI Inst} /top_tb/DUT/spi_inst/notfinished
add wave -noupdate -expand -group {SPI Inst} /top_tb/DUT/spi_inst/state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {75780 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 10
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {0 ps} {201536 ps}
