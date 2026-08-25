# Example Vivado constraints file (XDC)
# Uncomment and modify these according to your target board.

# Clock signal
# set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { clk }]; # IO_L12P_T1_MRCC_35 Sch=clk100mhz
# create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {clk}];

# Reset button
# set_property -dict { PACKAGE_PIN C2    IOSTANDARD LVCMOS33 } [get_ports { rst }]; # IO_L16P_T2_CSI_B_14 Sch=reset

# LEDs
# set_property -dict { PACKAGE_PIN H5    IOSTANDARD LVCMOS33 } [get_ports { led }]; # IO_L24N_T3_35 Sch=led[0]
