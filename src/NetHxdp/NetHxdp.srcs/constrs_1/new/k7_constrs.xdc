#####
# File:
#   k7_constrs.xdc
#
# Description:
#   System general constraints for K7-baseC board.
#   The file includes constraints for:
#   - Clocks (50 MHz, 156.25 MHz, 100 MHz);
#   - FPGA (Clock, Reset);
#   - SFP (Clocks, RX/TX, TX Disable);
#   - I2C (Clock, Data);
#   - PCIe (Clocks, RXP/RXN, TXP/TXN, System Reset);
#   - UART (RX/TX);
#   - Debug Features (SFP Leds, Clock Leds).
#####

# --- GENERAL ---
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

# --- Clocks ---
# 50 MHz Clock - FPGA.
create_clock -period 20.000 -name fpga_cry_clk  [get_ports fpga_cry_clk]
# 156.25 MHz Clock - SFP.     
create_clock -period  6.400 -name xphy_refclk_p [get_ports xphy_refclk_p]
# 100 MHz Clock - PCIe.    
create_clock -period 10.000 -name sys_clkp      [get_ports sys_clkp]         

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
set_property IOSTANDARD LVCMOS33 [get_ports xphy_refclk_p]
set_property PACKAGE_PIN D6 [get_ports xphy_refclk_p]
set_property IOSTANDARD LVCMOS33 [get_ports xphy_refclk_n]
set_property PACKAGE_PIN D5 [get_ports xphy_refclk_n]

# SFP0 RX/TX.
set_property IOSTANDARD LVCMOS33 [get_ports sfp0_rx_p]
set_property PACKAGE_PIN E4 [get_ports sfp0_rx_p]
set_property IOSTANDARD LVCMOS33 [get_ports sfp0_rx_n]
set_property PACKAGE_PIN E3 [get_ports sfp0_rx_n]
set_property IOSTANDARD LVCMOS33 [get_ports sfp0_tx_p]
set_property PACKAGE_PIN D2 [get_ports sfp0_tx_p]
set_property IOSTANDARD LVCMOS33 [get_ports sfp0_tx_n]
set_property PACKAGE_PIN D1 [get_ports sfp0_tx_n]

# SFP1 RX/TX.
set_property IOSTANDARD LVCMOS33 [get_ports sfp1_rx_p]
set_property PACKAGE_PIN C4 [get_ports sfp1_rx_p]
set_property IOSTANDARD LVCMOS33 [get_ports sfp1_rx_n]
set_property PACKAGE_PIN C3 [get_ports sfp1_rx_n]
set_property IOSTANDARD LVCMOS33 [get_ports sfp1_tx_p]
set_property PACKAGE_PIN B2 [get_ports sfp1_tx_p]
set_property IOSTANDARD LVCMOS33 [get_ports sfp1_tx_n]
set_property PACKAGE_PIN B1 [get_ports sfp1_tx_n]

# SFP0 TX Disable.
set_property IOSTANDARD LVCMOS33 [get_ports sfp0_tx_disable]
set_property PACKAGE_PIN H23 [get_ports sfp0_tx_disable]

# SFP1 TX Disable.
set_property IOSTANDARD LVCMOS33 [get_ports sfp1_tx_disable]
set_property PACKAGE_PIN H24 [get_ports sfp1_tx_disable]

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
#set_property PACKAGE_PIN H2 [get_ports {pcie_7x_mgt_txp[0]}]
#set_property PACKAGE_PIN K2 [get_ports {pcie_7x_mgt_txp[1]}]
#set_property PACKAGE_PIN M2 [get_ports {pcie_7x_mgt_txp[2]}]
#set_property PACKAGE_PIN P2 [get_ports {pcie_7x_mgt_txp[3]}]

# PCIe TXN.
#set_property PACKAGE_PIN H1 [get_ports {pcie_7x_mgt_txn[0]}]
#set_property PACKAGE_PIN K1 [get_ports {pcie_7x_mgt_txn[1]}]
#set_property PACKAGE_PIN M1 [get_ports {pcie_7x_mgt_txn[2]}]
#set_property PACKAGE_PIN P1 [get_ports {pcie_7x_mgt_txn[3]}]

# PCIe System Reset.
set_property IOSTANDARD LVCMOS33 [get_ports sys_reset_n]
set_property PACKAGE_PIN A12 [get_ports sys_reset_n]
set_property PULLUP true [get_ports sys_reset_n]

set_false_path -from [get_ports sys_reset_n]

# --- UART ---
# UART RX/TX.
set_property IOSTANDARD LVCMOS33 [get_ports uart_rxd]
set_property IOSTANDARD LVCMOS33 [get_ports uart_txd]
set_property PACKAGE_PIN B20 [get_ports uart_rxd]
set_property PACKAGE_PIN C22 [get_ports uart_txd]

# --- Debug Features ---
# SFP Leds.
# SFP0. RX. LED1.
set_property IOSTANDARD LVCMOS33 [get_ports sfp0_rx_led]
set_property PACKAGE_PIN A23 [get_ports sfp0_rx_led]

# SFP1. RX. LED2.
set_property IOSTANDARD LVCMOS33 [get_ports sfp1_rx_led]
set_property PACKAGE_PIN A24 [get_ports sfp1_rx_led]

# SFP0. TX. LED3.
set_property IOSTANDARD LVCMOS33 [get_ports sfp0_tx_led]
set_property PACKAGE_PIN D23 [get_ports sfp0_tx_led]

# SFP1. TX. LED4.
set_property IOSTANDARD LVCMOS33 [get_ports sfp1_tx_led]
set_property PACKAGE_PIN C24 [get_ports sfp1_tx_led]

# Clock Leds.
# 100 MHz Clock Heartbeat. LED7.
set_property IOSTANDARD LVCMOS33 [get_ports {leds[1]}]
set_property PACKAGE_PIN D25 [get_ports {leds[1]}]

# 156.25 MHz Clock Heartbeat. LED8.
set_property IOSTANDARD LVCMOS33 [get_ports {leds[0]}]
set_property PACKAGE_PIN E25 [get_ports {leds[0]}]





