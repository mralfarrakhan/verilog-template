#!/usr/bin/env -S uv run python

import argparse
import shutil
import subprocess
import sys
from pathlib import Path
import os

# Tool variables
IVERILOG = "iverilog"
VVP = "vvp"
GTKWAVE = "gtkwave"
YOSYS = "yosys"
NETLISTSVG = "netlistsvg"
F4PGA_IMAGE = "ghcr.io/hdl/conda/f4pga/xc7/z010:latest"

def load_env():
    """Simple parser for .env file to avoid third-party dependencies."""
    env = {}
    env_path = Path(".env")
    if env_path.exists():
        with open(env_path, "r") as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#") and "=" in line:
                    key, val = line.split("=", 1)
                    env[key.strip()] = val.strip()
    return env

def run_cmd(cmd, cwd=None):
    """Run a shell command, streaming output."""
    print(f"Running: {' '.join(cmd)}")
    result = subprocess.run(cmd, cwd=cwd)
    if result.returncode != 0:
        print(f"Error: Command failed with return code {result.returncode}")
        sys.exit(result.returncode)

def get_sources(rtl_dir: Path, tb_dir: Path = None):
    """Find all .v and .sv files."""
    rtl_srcs = list(rtl_dir.rglob("*.v")) + list(rtl_dir.rglob("*.sv"))
    tb_srcs = []
    if tb_dir:
        tb_srcs = list(tb_dir.rglob("*.v")) + list(tb_dir.rglob("*.sv"))
    return [str(p) for p in rtl_srcs], [str(p) for p in tb_srcs]

def cmd_new(args):
    name = args.name
    proj_dir = Path("projects") / name
    if proj_dir.exists():
        print(f"Error: Project '{name}' already exists.")
        sys.exit(1)

    # Create directories
    (proj_dir / "rtl").mkdir(parents=True)
    (proj_dir / "tb").mkdir(parents=True)
    (proj_dir / "xdc").mkdir(parents=True)

    # Write top.v
    with open(proj_dir / "rtl" / "top.v", "w") as f:
        f.write("`timescale 1ns / 1ps\n\nmodule top (\n    input clk,\n    output reg out\n);\n    always @(posedge clk) begin\n        out <= ~out;\n    end\nendmodule\n")

    # Write top_tb.v
    with open(proj_dir / "tb" / "top_tb.v", "w") as f:
        f.write("`timescale 1ns / 1ps\n\nmodule top_tb;\n    reg clk;\n    wire out;\n\n    top uut (\n        .clk(clk),\n        .out(out)\n    );\n\n    initial begin\n        $dumpfile(\"top_tb.fst\");\n        $dumpvars(0, top_tb);\n        \n        clk = 0;\n        #100;\n        $finish;\n    end\n\n    always #5 clk = ~clk;\nendmodule\n")

    # Write top.xdc
    with open(proj_dir / "xdc" / "top.xdc", "w") as f:
        f.write("# Add Xilinx constraints here\n")

    print(f"Created new project '{name}' at {proj_dir}")

def cmd_sim(args):
    proj_dir = Path("projects") / args.project
    sim_dir = proj_dir / "build" / "sim"
    rtl_dir = proj_dir / "rtl"
    tb_dir = proj_dir / "tb"
    
    rtl_srcs, tb_srcs = get_sources(rtl_dir, tb_dir)
    sim_dir.mkdir(parents=True, exist_ok=True)
    
    out_file = sim_dir / f"{args.top}_tb.vvp"
    
    iverilog_cmd = [IVERILOG, "-o", str(out_file), "-I", str(rtl_dir)] + rtl_srcs + tb_srcs
    run_cmd(iverilog_cmd)
    
    vvp_cmd = [VVP, f"{args.top}_tb.vvp", "-fst"]
    run_cmd(vvp_cmd, cwd=sim_dir)

def cmd_wave(args):
    cmd_sim(args)
    sim_dir = Path("projects") / args.project / "build" / "sim"
    fst_file = f"{args.top}_tb.fst"
    run_cmd([GTKWAVE, fst_file], cwd=sim_dir)

def cmd_schematic(args):
    proj_dir = Path("projects") / args.project
    build_dir = proj_dir / "build"
    rtl_dir = proj_dir / "rtl"
    
    rtl_srcs, _ = get_sources(rtl_dir)
    build_dir.mkdir(parents=True, exist_ok=True)
    
    json_out = build_dir / f"{args.top}.json"
    svg_out = build_dir / f"{args.top}_schematic.svg"
    
    yosys_script = f"prep -top {args.top}; write_json {json_out}"
    run_cmd([YOSYS, "-p", yosys_script] + rtl_srcs)
    
    run_cmd([NETLISTSVG, str(json_out), "-o", str(svg_out)])
    print(f"Elaborated schematic generated at {svg_out}")

def cmd_schematic_synth(args):
    proj_dir = Path("projects") / args.project
    build_dir = proj_dir / "build"
    rtl_dir = proj_dir / "rtl"
    
    rtl_srcs, _ = get_sources(rtl_dir)
    build_dir.mkdir(parents=True, exist_ok=True)
    
    json_out = build_dir / f"{args.top}_synth.json"
    svg_out = build_dir / f"{args.top}_synth_schematic.svg"
    
    yosys_script = f"synth_xilinx -top {args.top}; write_json {json_out}"
    run_cmd([YOSYS, "-p", yosys_script] + rtl_srcs)
    
    # Patch the JSON (equivalent to sed)
    with open(json_out, "r") as f:
        content = f.read()
    with open(json_out, "w") as f:
        f.write(content.replace('"inout"', '"input"'))
        
    run_cmd([NETLISTSVG, str(json_out), "-o", str(svg_out)])
    print(f"Synthesized schematic generated at {svg_out}")

def cmd_bitstream(args):
    proj_dir = Path("projects") / args.project
    f4pga_dir = proj_dir / "build" / "f4pga"
    rtl_dir = proj_dir / "rtl"
    
    rtl_srcs, _ = get_sources(rtl_dir)
    # Rewrite paths to use forward slashes for the Linux container
    docker_rtl_srcs = [f"/wrk/{p.replace(os.sep, '/')}" for p in rtl_srcs]
    
    f4pga_dir.mkdir(parents=True, exist_ok=True)
    
    f4pga_command = f"source /usr/local/conda/etc/profile.d/conda.sh || true && f4pga -m xc7 -c xc7z010-clg400-1 -t {args.top} -p /wrk/{proj_dir.as_posix()}/xdc/{args.top}.xdc " + " ".join(docker_rtl_srcs)

    env = load_env()
    container_engine = env.get("CONTAINER_ENGINE", "docker")

    # In docker/podman, we mount the current working directory to /wrk
    docker_cmd = [
        container_engine, "run", "--rm", 
        "-v", f"{Path.cwd()}:/wrk", 
        "-w", f"/wrk/{f4pga_dir}", 
        F4PGA_IMAGE,
        "bash", "-c", 
        f4pga_command
    ]
    
    run_cmd(docker_cmd)
    print(f"Bitstream generated in {f4pga_dir}/build/{args.top}.bit")

def cmd_upload(args):
    proj_dir = Path("projects") / args.project
    bitstream = proj_dir / "build" / "f4pga" / "build" / f"{args.top}.bit"
    
    if not bitstream.exists():
        print(f"Error: Bitstream not found at {bitstream}")
        print(f"Run 'uv run ./build.py bitstream {args.project}' first.")
        sys.exit(1)
        
    print(f"Uploading {bitstream} to FPGA...")
    upload_cmd = ["openFPGALoader", "-c", "digilent", str(bitstream)]
    run_cmd(upload_cmd)

def cmd_clean(args):
    proj_dir = Path("projects") / args.project
    
    def rm_rf(path: Path):
        if path.is_dir():
            shutil.rmtree(path)
        elif path.is_file():
            path.unlink()
            
    rm_rf(proj_dir / "build" / "sim")
    rm_rf(proj_dir / "build" / "f4pga")
    rm_rf(proj_dir / "build" / ".Xil")
    
    build_dir = proj_dir / "build"
    if build_dir.exists():
        for p in build_dir.glob("*.jou"): rm_rf(p)
        for p in build_dir.glob("*.log"): rm_rf(p)
        for p in build_dir.glob("usage_statistics_webtalk.*"): rm_rf(p)

    print(f"Cleaned build artifacts for project '{args.project}'")


def main():
    parser = argparse.ArgumentParser(description="HDL Playground Build Script")
    subparsers = parser.add_subparsers(dest="command", required=True)
    
    # Common arguments parser
    parent_parser = argparse.ArgumentParser(add_help=False)
    parent_parser.add_argument("project", nargs="?", default="default", help="Project name (default: 'default')")
    parent_parser.add_argument("--top", default="top", help="Top-level module name (default: 'top')")

    # 'new' command
    parser_new = subparsers.add_parser("new", help="Scaffold a new project structure")
    parser_new.add_argument("name", help="Name of the new project")
    parser_new.set_defaults(func=cmd_new)
    
    # 'sim' command
    parser_sim = subparsers.add_parser("sim", parents=[parent_parser], help="Run simulation")
    parser_sim.set_defaults(func=cmd_sim)
    
    # 'wave' command
    parser_wave = subparsers.add_parser("wave", parents=[parent_parser], help="Run simulation and open waveform in GTKWave")
    parser_wave.set_defaults(func=cmd_wave)
    
    # 'schematic' command
    parser_schematic = subparsers.add_parser("schematic", parents=[parent_parser], help="Generate elaborated schematic")
    parser_schematic.set_defaults(func=cmd_schematic)
    
    # 'schematic-synth' command
    parser_schematic_synth = subparsers.add_parser("schematic-synth", parents=[parent_parser], help="Generate synthesized schematic")
    parser_schematic_synth.set_defaults(func=cmd_schematic_synth)
    
    # 'bitstream' command
    parser_bitstream = subparsers.add_parser("bitstream", parents=[parent_parser], help="Generate bitstream using F4PGA")
    parser_bitstream.set_defaults(func=cmd_bitstream)

    # 'upload' command
    parser_upload = subparsers.add_parser("upload", parents=[parent_parser], help="Upload bitstream to FPGA using openFPGALoader")
    parser_upload.set_defaults(func=cmd_upload)
    
    # 'clean' command
    parser_clean = subparsers.add_parser("clean", parents=[parent_parser], help="Clean all build artifacts")
    parser_clean.set_defaults(func=cmd_clean)

    args = parser.parse_args()
    args.func(args)

if __name__ == "__main__":
    main()
