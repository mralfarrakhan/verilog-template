# Vivado non-project mode build script

set part_name "xc7a35tcpg236-1" ; # Change to your target part
set output_dir "./build"

file mkdir $output_dir

# Read sources
read_verilog [glob -nocomplain ./rtl/*.v]
read_verilog -sv [glob -nocomplain ./rtl/*.sv]

# Read constraints
read_xdc [glob -nocomplain ./xdc/*.xdc]

# Synthesize
synth_design -top top -part $part_name
write_checkpoint -force $output_dir/post_synth.dcp

# Place and Route
opt_design
place_design
route_design
write_checkpoint -force $output_dir/post_route.dcp

# Generate bitstream
write_bitstream -force $output_dir/top.bit

# Reports
report_timing_summary -file $output_dir/post_route_timing_summary.rpt
report_utilization -file $output_dir/post_route_util.rpt
report_power -file $output_dir/post_route_power.rpt

puts "Build completed successfully."
