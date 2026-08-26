#!/usr/bin/env bash

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <project_name>"
    exit 1
fi

PROJECT_NAME=$1
PROJECT_DIR="projects/${PROJECT_NAME}"

if [ -d "${PROJECT_DIR}" ]; then
    echo "Error: Project '${PROJECT_NAME}' already exists."
    exit 1
fi

mkdir -p "${PROJECT_DIR}/rtl"
mkdir -p "${PROJECT_DIR}/tb"
mkdir -p "${PROJECT_DIR}/xdc"

# Optional: Add template files
cat << 'EOF' > "${PROJECT_DIR}/rtl/top.v"
`timescale 1ns / 1ps

module top (
    input clk,
    output reg out
);
    always @(posedge clk) begin
        out <= ~out;
    end
endmodule
EOF

cat << 'EOF' > "${PROJECT_DIR}/tb/top_tb.v"
`timescale 1ns / 1ps

module top_tb;
    reg clk;
    wire out;

    top uut (
        .clk(clk),
        .out(out)
    );

    initial begin
        $dumpfile("top_tb.fst");
        $dumpvars(0, top_tb);
        
        clk = 0;
        #100;
        $finish;
    end

    always #5 clk = ~clk;
endmodule
EOF

cat << 'EOF' > "${PROJECT_DIR}/xdc/top.xdc"
# Add Xilinx constraints here
EOF

echo "Created new project '${PROJECT_NAME}' at ${PROJECT_DIR}"
