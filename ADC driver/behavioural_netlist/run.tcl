# Set the log file path
set log_file "run.log"
set stdoutput [open $log_file w]
set stdout $stdoutput

# Run simulation
vsim tb
do wave.do
run -all

