# Makefile for Verilog Simulation and F4PGA Build

PROJECT_NAME = top
RTL_DIR = rtl
TB_DIR = tb
SIM_DIR = build/sim
F4PGA_DIR = build/f4pga
BUILD_DIR = build

# Tools
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave
YOSYS = yosys
NETLISTSVG = netlistsvg

# Docker settings for F4PGA
F4PGA_IMAGE = gcr.io/hdl-containers/conda/f4pga/xc7/z010

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

# F4PGA targets
.PHONY: bitstream f4pga-clean

bitstream:
	mkdir -p $(F4PGA_DIR)
	docker run --rm -v $$(pwd):/wrk -w /wrk/$(F4PGA_DIR) $(F4PGA_IMAGE) \
		bash -c "source /usr/local/conda/etc/profile.d/conda.sh || true && \
		f4pga -m xc7 -c xc7z010-clg400-1 -t $(PROJECT_NAME) -p ../../xdc/top.xdc ../../rtl/top.v"
	@echo "Bitstream generated in $(F4PGA_DIR)/build/$(PROJECT_NAME).bit"

# Clean up
clean: f4pga-clean
	rm -rf $(SIM_DIR)
	rm -f *.jou *.log

f4pga-clean:
	rm -rf $(F4PGA_DIR)
	rm -rf .Xil
	rm -f *.jou *.log usage_statistics_webtalk.html usage_statistics_webtalk.xml
