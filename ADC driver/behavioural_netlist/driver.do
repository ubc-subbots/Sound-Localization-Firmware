onerror {resume}
radix define 
    -default default
 {
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
radix define  {
    -default default
}
quietly WaveActivateNextPane {} 0
add wave -noupdate /driver_tb/adc_inst/XCLK
add wave -noupdate /driver_tb/WR_N
add wave -noupdate /driver_tb/adc_inst/direction
add wave -noupdate /driver_tb/RD_N
add wave -noupdate -radix hexadecimal /driver_tb/DB
add wave -noupdate -radix hexadecimal /driver_tb/adc_inst/ADC_num
add wave -noupdate /driver_tb/CS_N
add wave -noupdate /driver_tb/CONVST_D
add wave -noupdate /driver_tb/CONVST_C
add wave -noupdate /driver_tb/CONVST_B
add wave -noupdate /driver_tb/CONVST_A
add wave -noupdate /driver_tb/BUSY
add wave -noupdate -expand -group {Channel Outputs} -radix hexadecimal /driver_tb/adc_inst/CH_D1
add wave -noupdate -expand -group {Channel Outputs} -radix hexadecimal /driver_tb/adc_inst/CH_D0
add wave -noupdate -expand -group {Channel Outputs} -radix hexadecimal /driver_tb/adc_inst/CH_C1
add wave -noupdate -expand -group {Channel Outputs} -radix hexadecimal /driver_tb/adc_inst/CH_C0
add wave -noupdate -expand -group {Channel Outputs} -radix hexadecimal /driver_tb/adc_inst/CH_B1
add wave -noupdate -expand -group {Channel Outputs} -radix hexadecimal /driver_tb/adc_inst/CH_B0
add wave -noupdate -expand -group {Channel Outputs} -radix hexadecimal /driver_tb/adc_inst/CH_A1
add wave -noupdate -expand -group {Channel Outputs} -radix hexadecimal /driver_tb/adc_inst/CH_A0
add wave -noupdate -radix hexadecimal /driver_tb/adc_inst/CONFIG_REG
add wave -noupdate -expand -group {Ana vals} /driver_tb/CH_ANA_D1
add wave -noupdate -expand -group {Ana vals} /driver_tb/CH_ANA_D0
add wave -noupdate -expand -group {Ana vals} /driver_tb/CH_ANA_C1
add wave -noupdate -expand -group {Ana vals} /driver_tb/CH_ANA_C0
add wave -noupdate -expand -group {Ana vals} /driver_tb/CH_ANA_B1
add wave -noupdate -expand -group {Ana vals} /driver_tb/CH_ANA_B0
add wave -noupdate -expand -group {Ana vals} /driver_tb/CH_ANA_A1
add wave -noupdate -expand -group {Ana vals} /driver_tb/CH_ANA_A0
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2166937 ps} 0}
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
WaveRestoreZoom {0 ps} {8305152 ps}
