# HDL Playground

A minimal Verilog playground/template built with reproducible tools for quick iteration, simulation, synthesis, and FPGA bitstream generation.

## Dependencies

- **[devenv](https://devenv.sh/)**: Nix-based dependency management (installs `iverilog`, `gtkwave`, `yosys`, `netlistsvg`, and `just`).
- **[Just](https://github.com/casey/just)**: Command runner (replacing Make) used for triggering workflows.
- **Docker**: Required if you want to generate bitstreams (uses the `f4pga` container to synthesize for Xilinx 7-series).

## Project Structure

This playground supports multiple subprojects located inside the `projects/` directory.

- `projects/default/`: The default project (if no project name is provided).
- `projects/<name>/rtl/`: Verilog source files.
- `projects/<name>/tb/`: Testbench files.
- `projects/<name>/xdc/`: FPGA constraints files (e.g. for a Zynq-7000).

## Usage (Quickstart)

Before running commands, ensure your environment is loaded via `devenv shell` or `direnv allow` if you have it configured.

### 1. Create a new subproject
```bash
just new my_project
```
This scaffolds a new project with boilerplate code in `projects/my_project/`.

### 2. Run simulation
```bash
just sim my_project
just wave my_project    # Runs sim and opens waveforms in GTKWave
```

### 3. View Schematics
```bash
just schematic my_project          # Generates and opens an elaborated SVG schematic
just schematic-synth my_project    # Generates and opens a synthesized SVG schematic
```

### 4. Build Bitstream (FPGA)
```bash
just bitstream my_project
```

*Note: You can omit the project name from any of these commands to run them against the `default` project.*

## Cleaning Up

```bash
just clean my_project
```
