onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /driver_tb/adc_inst/XCLK
add wave -noupdate /driver_tb/WR_N
add wave -noupdate /driver_tb/adc_inst/direction
add wave -noupdate /driver_tb/RD_N
add wave -noupdate -radix hexadecimal /driver_tb/DB
add wave -noupdate -radix hexadecimal /driver_tb/DB_i
add wave -noupdate -radix hexadecimal /driver_tb/adc_inst/ADC_num
add wave -noupdate /driver_tb/CS_N
add wave -noupdate /driver_tb/CONVST_D
add wave -noupdate /driver_tb/CONVST_C
add wave -noupdate /driver_tb/CONVST_B
add wave -noupdate /driver_tb/CONVST_A
add wave -noupdate /driver_tb/BUSY
add wave -noupdate -group {Channel Outputs} -radix hexadecimal /driver_tb/adc_inst/CH_D1
add wave -noupdate -group {Channel Outputs} -radix hexadecimal /driver_tb/adc_inst/CH_D0
add wave -noupdate -group {Channel Outputs} -radix hexadecimal /driver_tb/adc_inst/CH_C1
add wave -noupdate -group {Channel Outputs} -radix hexadecimal /driver_tb/adc_inst/CH_C0
add wave -noupdate -group {Channel Outputs} -radix hexadecimal /driver_tb/adc_inst/CH_B1
add wave -noupdate -group {Channel Outputs} -radix hexadecimal /driver_tb/adc_inst/CH_B0
add wave -noupdate -group {Channel Outputs} -radix hexadecimal /driver_tb/adc_inst/CH_A1
add wave -noupdate -group {Channel Outputs} -radix hexadecimal /driver_tb/adc_inst/CH_A0
add wave -noupdate -group {Channel Outputs} -radix hexadecimal /driver_tb/adc_inst/CH_D1
add wave -noupdate -group {Channel Outputs} -radix hexadecimal /driver_tb/adc_inst/CH_D0
add wave -noupdate -group {Channel Outputs} -radix hexadecimal /driver_tb/adc_inst/CH_C1
add wave -noupdate -group {Channel Outputs} -radix hexadecimal /driver_tb/adc_inst/CH_C0
add wave -noupdate -group {Channel Outputs} -radix hexadecimal /driver_tb/adc_inst/CH_B1
add wave -noupdate -group {Channel Outputs} -radix hexadecimal /driver_tb/adc_inst/CH_B0
add wave -noupdate -group {Channel Outputs} -radix hexadecimal /driver_tb/adc_inst/CH_A1
add wave -noupdate -group {Channel Outputs} -radix hexadecimal /driver_tb/adc_inst/CH_A0
add wave -noupdate -radix hexadecimal /driver_tb/adc_inst/CONFIG_REG
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1204 ps} 0}
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
WaveRestoreZoom {0 ps} {22720 ps}
