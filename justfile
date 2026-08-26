# justfile for Verilog Simulation and F4PGA Build

set shell := ["bash", "-c"]

iverilog := "iverilog"
vvp := "vvp"
gtkwave := "gtkwave"
yosys := "yosys"
netlistsvg := "netlistsvg"
f4pga_image := "ghcr.io/hdl/conda/f4pga/xc7/z010:latest"
project_name := "top"

# Default target: list all available recipes
default:
    @just --list

# Scaffold a new project structure
new name:
    ./scripts/create_project.sh {{name}}

# Run simulation
sim project="default":
    #!/usr/bin/env bash
    PROJ_DIR="projects/{{project}}"
    SIM_DIR="${PROJ_DIR}/build/sim"
    RTL_DIR="${PROJ_DIR}/rtl"
    TB_DIR="${PROJ_DIR}/tb"
    RTL_SRCS=$(find ${RTL_DIR} -name "*.v" -o -name "*.sv" 2>/dev/null | tr '\n' ' ')
    TB_SRCS=$(find ${TB_DIR} -name "*.v" -o -name "*.sv" 2>/dev/null | tr '\n' ' ')
    
    mkdir -p ${SIM_DIR}
    {{iverilog}} -o ${SIM_DIR}/{{project_name}}_tb.vvp -I ${RTL_DIR} ${RTL_SRCS} ${TB_SRCS}
    cd ${SIM_DIR} && {{vvp}} {{project_name}}_tb.vvp -fst

# Run simulation and open waveform in GTKWave
wave project="default":
    #!/usr/bin/env bash
    PROJ_DIR="projects/{{project}}"
    SIM_DIR="${PROJ_DIR}/build/sim"
    just sim {{project}}
    cd ${SIM_DIR} && {{gtkwave}} {{project_name}}_tb.fst

# Generate elaborated schematic
schematic project="default":
    #!/usr/bin/env bash
    PROJ_DIR="projects/{{project}}"
    BUILD_DIR="${PROJ_DIR}/build"
    RTL_DIR="${PROJ_DIR}/rtl"
    RTL_SRCS=$(find ${RTL_DIR} -name "*.v" -o -name "*.sv" 2>/dev/null | tr '\n' ' ')
    
    mkdir -p ${BUILD_DIR}
    {{yosys}} -p "prep -top {{project_name}}; write_json ${BUILD_DIR}/{{project_name}}.json" ${RTL_SRCS}
    {{netlistsvg}} ${BUILD_DIR}/{{project_name}}.json -o ${BUILD_DIR}/{{project_name}}_schematic.svg
    echo "Elaborated schematic generated at ${BUILD_DIR}/{{project_name}}_schematic.svg"

# Generate synthesized schematic
schematic-synth project="default":
    #!/usr/bin/env bash
    PROJ_DIR="projects/{{project}}"
    BUILD_DIR="${PROJ_DIR}/build"
    RTL_DIR="${PROJ_DIR}/rtl"
    RTL_SRCS=$(find ${RTL_DIR} -name "*.v" -o -name "*.sv" 2>/dev/null | tr '\n' ' ')
    
    mkdir -p ${BUILD_DIR}
    {{yosys}} -p "synth_xilinx -top {{project_name}}; write_json ${BUILD_DIR}/{{project_name}}_synth.json" ${RTL_SRCS}
    sed -i.bak 's/"inout"/"input"/g' ${BUILD_DIR}/{{project_name}}_synth.json
    {{netlistsvg}} ${BUILD_DIR}/{{project_name}}_synth.json -o ${BUILD_DIR}/{{project_name}}_synth_schematic.svg
    echo "Synthesized schematic generated at ${BUILD_DIR}/{{project_name}}_synth_schematic.svg"

# Generate bitstream using F4PGA
bitstream project="default":
    #!/usr/bin/env bash
    PROJ_DIR="projects/{{project}}"
    F4PGA_DIR="${PROJ_DIR}/build/f4pga"
    
    mkdir -p ${F4PGA_DIR}
    docker run --rm -v "$PWD":/wrk -w /wrk/${F4PGA_DIR} {{f4pga_image}} \
        bash -c "source /usr/local/conda/etc/profile.d/conda.sh || true && \
        f4pga -m xc7 -c xc7z010-clg400-1 -t {{project_name}} -p ../../xdc/top.xdc ../../rtl/top.v"
    echo "Bitstream generated in ${F4PGA_DIR}/build/{{project_name}}.bit"

# Clean all build artifacts
clean project="default":
    #!/usr/bin/env bash
    PROJ_DIR="projects/{{project}}"
    SIM_DIR="${PROJ_DIR}/build/sim"
    F4PGA_DIR="${PROJ_DIR}/build/f4pga"
    
    rm -rf ${SIM_DIR}
    rm -rf ${F4PGA_DIR}
    rm -rf ${PROJ_DIR}/build/.Xil
    rm -f ${PROJ_DIR}/build/*.jou ${PROJ_DIR}/build/*.log ${PROJ_DIR}/build/usage_statistics_webtalk.*
