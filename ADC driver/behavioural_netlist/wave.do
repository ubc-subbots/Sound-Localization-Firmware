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
add wave -noupdate /driver_tb/BUSY
add wave -noupdate /driver_tb/convst_D
add wave -noupdate /driver_tb/convst_C
add wave -noupdate /driver_tb/convst_B
add wave -noupdate /driver_tb/convst_A
add wave -noupdate -group {Channel Outputs} -radix hexadecimal /driver_tb/adc_inst/CH_D1
add wave -noupdate -group {Channel Outputs} -radix hexadecimal /driver_tb/adc_inst/CH_D0
add wave -noupdate -group {Channel Outputs} -radix hexadecimal /driver_tb/adc_inst/CH_C1
add wave -noupdate -group {Channel Outputs} -radix hexadecimal /driver_tb/adc_inst/CH_C0
add wave -noupdate -group {Channel Outputs} -radix hexadecimal /driver_tb/adc_inst/CH_B1
add wave -noupdate -group {Channel Outputs} -radix symbolic /driver_tb/adc_inst/CH_B0
add wave -noupdate -group {Channel Outputs} -format Analog-Step -height 74 -max 20478.0 -min -20471.0 -radix symbolic /driver_tb/adc_inst/CH_A1
add wave -noupdate -group {Channel Outputs} -format Analog-Step -height 74 -max 6823.0 -min -6827.0 -radix symbolic /driver_tb/adc_inst/CH_A0
add wave -noupdate -group ANA -radix symbolic /driver_tb/CH_ANA_D1
add wave -noupdate -group ANA -radix symbolic /driver_tb/CH_ANA_D0
add wave -noupdate -group ANA -radix symbolic /driver_tb/CH_ANA_C1
add wave -noupdate -group ANA -radix symbolic /driver_tb/CH_ANA_C0
add wave -noupdate -group ANA -radix symbolic /driver_tb/CH_ANA_B1
add wave -noupdate -group ANA -radix symbolic /driver_tb/CH_ANA_B0
add wave -noupdate -group ANA -format Analog-Step -height 74 -max 7.4999265491302749 -min -7.4999641140276001 -radix symbolic /driver_tb/CH_ANA_A1
add wave -noupdate -group ANA -format Analog-Step -height 74 -max 2.5 -min -2.5 -radix symbolic /driver_tb/CH_ANA_A0
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {67124000 ps} 0}
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
WaveRestoreZoom {0 ps} {314500300 ps}
