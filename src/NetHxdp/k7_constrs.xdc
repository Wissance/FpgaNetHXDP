#####
# File:
#   k7_constrs.xdc
#
# Description:
#   System general constraints for K7-baseC board.
#   The file includes constraints for:
#   - FPGA (fpga_cry_clk);
#   - SFP ();
#   - I2C (i2c_clk, i2c_data, ???);
#   - PCIe ();
#   - UART (115200-8N1);
#   - Btn0 is used as system sys_reset_n (active high)?
#####

# --- GENERAL ---
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

# --- Clocks ---
create_clock -period 20.000 -name fpga_cry_clk  [get_ports fpga_cry_clk]     # 50 MHz Clock - FPGA.
create_clock -period  6.400 -name xphy_refclk_p [get_ports xphy_refclk_p]    # 156 MHz Clock - SFP.
create_clock -period 10.000 -name sys_clkp      [get_ports sys_clkp]         # 100 MHz Clock - PCIe.

# --- FPGA ---
# FPGA Clock.
set_property IOSTANDARD LVCMOS33 [get_ports fpga_cry_clk]
set_property PACKAGE_PIN G22 [get_ports fpga_cry_clk]

# FPGA Reset.
set_property IOSTANDARD LVCMOS33 [get_ports fpga_reset]
set_property PACKAGE_PIN D26 [get_ports fpga_reset]

set_false_path -from [get_ports fpga_reset]

# --- SFP ---
# SFP Clocks.
set_property PACKAGE_PIN D6 [get_ports xphy_refclk_p]
set_property PACKAGE_PIN D5 [get_ports xphy_refclk_n]

# --- I2C ---
# I2C Clock.
set_property IOSTANDARD LVCMOS33 [get_ports i2c_clk]
set_property PACKAGE_PIN B21 [get_ports i2c_clk]

# I2C Data.
set_property IOSTANDARD LVCMOS33 [get_ports i2c_data]
set_property PACKAGE_PIN C21 [get_ports i2c_data]

# --- PCIe ---
# PCIe Clocks.
set_property IOSTANDARD LVCMOS33 [get_ports sys_clkp]
set_property PACKAGE_PIN K6 [get_ports sys_clkp]
set_property IOSTANDARD LVCMOS33 [get_ports sys_clkn]
set_property PACKAGE_PIN K5 [get_ports sys_clkn]

# PCIe RXP.
set_property PACKAGE_PIN J4 [get_ports {pcie_7x_mgt_rxp[0]}]
set_property PACKAGE_PIN L4 [get_ports {pcie_7x_mgt_rxp[1]}]
set_property PACKAGE_PIN N4 [get_ports {pcie_7x_mgt_rxp[2]}]
set_property PACKAGE_PIN R4 [get_ports {pcie_7x_mgt_rxp[3]}]

# PCIe RXN.
set_property PACKAGE_PIN J3 [get_ports {pcie_7x_mgt_rxn[0]}]
set_property PACKAGE_PIN L3 [get_ports {pcie_7x_mgt_rxn[1]}]
set_property PACKAGE_PIN N3 [get_ports {pcie_7x_mgt_rxn[2]}]
set_property PACKAGE_PIN R3 [get_ports {pcie_7x_mgt_rxn[3]}]

# PCIe TXP.
set_property PACKAGE_PIN H2 [get_ports {pcie_7x_mgt_txp[0]}]
set_property PACKAGE_PIN K2 [get_ports {pcie_7x_mgt_txp[1]}]
set_property PACKAGE_PIN M2 [get_ports {pcie_7x_mgt_txp[2]}]
set_property PACKAGE_PIN P2 [get_ports {pcie_7x_mgt_txp[3]}]

# PCIe TXP.
set_property PACKAGE_PIN H1 [get_ports {pcie_7x_mgt_txn[0]}]
set_property PACKAGE_PIN K1 [get_ports {pcie_7x_mgt_txn[1]}]
set_property PACKAGE_PIN M1 [get_ports {pcie_7x_mgt_txn[2]}]
set_property PACKAGE_PIN P1 [get_ports {pcie_7x_mgt_txn[3]}]

# PCIe System Reset.
set_property IOSTANDARD LVCMOS33 [get_ports sys_reset_n]
set_property PACKAGE_PIN A12 [get_ports sys_reset_n]
set_property PULLUP true [get_ports sys_reset_n]

set_false_path -from [get_ports sys_reset_n]

# --- UART ---
# UART RX and TX.
set_property IOSTANDARD LVCMOS33 [get_ports uart_rxd]
set_property IOSTANDARD LVCMOS33 [get_ports uart_txd]
set_property PACKAGE_PIN B20 [get_ports uart_rxd]
set_property PACKAGE_PIN C22 [get_ports uart_txd]

# --- Timing Constraints ---

