project_name := "top"
rtl_dir := "rtl"
tb_dir := "tb"
sim_dir := "sim_build"
vivado_dir := "vivado"
build_dir := "build"

iverilog := "iverilog"
vvp := "vvp"
gtkwave := "gtkwave"

# Default target
default: sim

# Compile and run simulation
sim:
    mkdir -p {{sim_dir}}
    {{iverilog}} -o {{sim_dir}}/{{project_name}}_tb.vvp -I {{rtl_dir}} {{rtl_dir}}/*.v {{tb_dir}}/*.v
    cd {{sim_dir}} && {{vvp}} {{project_name}}_tb.vvp -fst

# Run simulation and open waveforms
wave: sim
    cd {{sim_dir}} && {{gtkwave}} {{project_name}}_tb.fst

# Generate logic schematic SVG
schematic:
    mkdir -p {{build_dir}}
    yosys -p "prep -top {{project_name}}; write_json {{build_dir}}/{{project_name}}.json" {{rtl_dir}}/*.v
    netlistsvg {{build_dir}}/{{project_name}}.json -o {{build_dir}}/{{project_name}}_schematic.svg
    @echo "Schematic generated at {{build_dir}}/{{project_name}}_schematic.svg"

# Generate Vivado project
project:
    vivado -mode batch -source scripts/create_project.tcl

# Build bitstream in Vivado non-project mode
bitstream:
    vivado -mode batch -source scripts/build.tcl

# Clean simulation files
clean: vivado-clean
    rm -rf {{sim_dir}}
    rm -f *.jou *.log

# Clean Vivado files
vivado-clean:
    rm -rf {{vivado_dir}} {{build_dir}}
    rm -rf .Xil
    rm -f *.jou *.log usage_statistics_webtalk.html usage_statistics_webtalk.xml


