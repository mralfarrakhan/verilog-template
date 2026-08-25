# Makefile for Verilog Simulation and Vivado Build

PROJECT_NAME = top
RTL_DIR = rtl
TB_DIR = tb
SIM_DIR = build/sim
VIVADO_DIR = build/vivado
BUILD_DIR = build

# Tools
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave
YOSYS = yosys
NETLISTSVG = netlistsvg
VIVADO = vivado

# Sources
RTL_SRCS = $(wildcard $(RTL_DIR)/*.v $(RTL_DIR)/*.sv)
TB_SRCS = $(wildcard $(TB_DIR)/*.v $(TB_DIR)/*.sv)

# Default target
all: sim

# Simulation targets
.PHONY: sim wave clean

sim: $(SIM_DIR)/$(PROJECT_NAME)_tb.vvp
	cd $(SIM_DIR) && $(VVP) $(PROJECT_NAME)_tb.vvp -fst

$(SIM_DIR)/$(PROJECT_NAME)_tb.vvp: $(RTL_SRCS) $(TB_SRCS)
	mkdir -p $(SIM_DIR)
	$(IVERILOG) -o $@ -I $(RTL_DIR) $^

wave: sim
	cd $(SIM_DIR) && $(GTKWAVE) $(PROJECT_NAME)_tb.fst

# Schematic targets
.PHONY: schematic schematic-synth

schematic:
	mkdir -p $(BUILD_DIR)
	$(YOSYS) -p "prep -top $(PROJECT_NAME); write_json $(BUILD_DIR)/$(PROJECT_NAME).json" $(RTL_SRCS)
	$(NETLISTSVG) $(BUILD_DIR)/$(PROJECT_NAME).json -o $(BUILD_DIR)/$(PROJECT_NAME)_schematic.svg
	@echo "Elaborated schematic generated at $(BUILD_DIR)/$(PROJECT_NAME)_schematic.svg"

schematic-synth:
	mkdir -p $(BUILD_DIR)
	$(YOSYS) -p "synth_xilinx -top $(PROJECT_NAME); write_json $(BUILD_DIR)/$(PROJECT_NAME)_synth.json" $(RTL_SRCS)
	sed -i.bak 's/"inout"/"input"/g' $(BUILD_DIR)/$(PROJECT_NAME)_synth.json
	$(NETLISTSVG) $(BUILD_DIR)/$(PROJECT_NAME)_synth.json -o $(BUILD_DIR)/$(PROJECT_NAME)_synth_schematic.svg
	@echo "Synthesized schematic generated at $(BUILD_DIR)/$(PROJECT_NAME)_synth_schematic.svg"

# Vivado targets
.PHONY: project bitstream vivado-clean

project:
	$(VIVADO) -mode batch -source scripts/create_project.tcl

bitstream:
	$(VIVADO) -mode batch -source scripts/build.tcl

# Clean up
clean: vivado-clean
	rm -rf $(SIM_DIR)
	rm -f *.jou *.log

vivado-clean:
	rm -rf $(VIVADO_DIR) $(BUILD_DIR)
	rm -rf .Xil
	rm -f *.jou *.log usage_statistics_webtalk.html usage_statistics_webtalk.xml
