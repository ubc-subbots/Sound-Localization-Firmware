onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/DUT/XCLK
add wave -noupdate /tb/WR_N
add wave -noupdate /tb/DUT/direction
add wave -noupdate /tb/RD_N
add wave -noupdate -radix hexadecimal /tb/DB
add wave -noupdate -radix hexadecimal /tb/DB_i
add wave -noupdate -radix hexadecimal /tb/DUT/ADC_num
add wave -noupdate /tb/CS_N
add wave -noupdate /tb/CONVST_D
add wave -noupdate /tb/CONVST_C
add wave -noupdate /tb/CONVST_B
add wave -noupdate /tb/CONVST_A
add wave -noupdate /tb/BUSY
add wave -noupdate -group {Channel Outputs} -radix hexadecimal /tb/DUT/CH_D1
add wave -noupdate -group {Channel Outputs} -radix hexadecimal /tb/DUT/CH_D0
add wave -noupdate -group {Channel Outputs} -radix hexadecimal /tb/DUT/CH_C1
add wave -noupdate -group {Channel Outputs} -radix hexadecimal /tb/DUT/CH_C0
add wave -noupdate -group {Channel Outputs} -radix hexadecimal /tb/DUT/CH_B1
add wave -noupdate -group {Channel Outputs} -radix hexadecimal /tb/DUT/CH_B0
add wave -noupdate -group {Channel Outputs} -radix hexadecimal /tb/DUT/CH_A1
add wave -noupdate -group {Channel Outputs} -radix hexadecimal /tb/DUT/CH_A0
add wave -noupdate -group {Channel Outputs} -radix hexadecimal /tb/DUT/CH_D1
add wave -noupdate -group {Channel Outputs} -radix hexadecimal /tb/DUT/CH_D0
add wave -noupdate -group {Channel Outputs} -radix hexadecimal /tb/DUT/CH_C1
add wave -noupdate -group {Channel Outputs} -radix hexadecimal /tb/DUT/CH_C0
add wave -noupdate -group {Channel Outputs} -radix hexadecimal /tb/DUT/CH_B1
add wave -noupdate -group {Channel Outputs} -radix hexadecimal /tb/DUT/CH_B0
add wave -noupdate -group {Channel Outputs} -radix hexadecimal /tb/DUT/CH_A1
add wave -noupdate -group {Channel Outputs} -radix hexadecimal /tb/DUT/CH_A0
add wave -noupdate -radix hexadecimal /tb/DUT/CONFIG_REG
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
