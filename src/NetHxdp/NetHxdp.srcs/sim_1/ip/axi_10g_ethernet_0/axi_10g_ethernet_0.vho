-- (c) Copyright 1995-2018 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- DO NOT MODIFY THIS FILE.

-- IP VLNV: xilinx.com:ip:axi_10g_ethernet:3.1
-- IP Revision: 3

-- The following code must appear in the VHDL architecture header.

------------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG
COMPONENT axi_10g_ethernet_0
  PORT (
    tx_axis_aresetn : IN STD_LOGIC;
    rx_axis_aresetn : IN STD_LOGIC;
    tx_ifg_delay : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    dclk : IN STD_LOGIC;
    txp : OUT STD_LOGIC;
    txn : OUT STD_LOGIC;
    rxp : IN STD_LOGIC;
    rxn : IN STD_LOGIC;
    signal_detect : IN STD_LOGIC;
    tx_fault : IN STD_LOGIC;
    tx_disable : OUT STD_LOGIC;
    pcspma_status : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    sim_speedup_control : IN STD_LOGIC;
    rxrecclk_out : OUT STD_LOGIC;
    is_eval : OUT STD_LOGIC;
    s_axi_aclk : IN STD_LOGIC;
    s_axi_aresetn : IN STD_LOGIC;
    xgmacint : OUT STD_LOGIC;
    areset_datapathclk_out : OUT STD_LOGIC;
    txusrclk_out : OUT STD_LOGIC;
    txusrclk2_out : OUT STD_LOGIC;
    gttxreset_out : OUT STD_LOGIC;
    gtrxreset_out : OUT STD_LOGIC;
    txuserrdy_out : OUT STD_LOGIC;
    coreclk_out : OUT STD_LOGIC;
    resetdone_out : OUT STD_LOGIC;
    reset_counter_done_out : OUT STD_LOGIC;
    qplllock_out : OUT STD_LOGIC;
    qplloutclk_out : OUT STD_LOGIC;
    qplloutrefclk_out : OUT STD_LOGIC;
    refclk_p : IN STD_LOGIC;
    refclk_n : IN STD_LOGIC;
    reset : IN STD_LOGIC;
    training_addr : IN STD_LOGIC_VECTOR(20 DOWNTO 0);
    training_drp_cs : IN STD_LOGIC;
    training_enable : IN STD_LOGIC;
    training_ipif_cs : IN STD_LOGIC;
    training_rdack : OUT STD_LOGIC;
    training_rddata : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    training_rnw : IN STD_LOGIC;
    training_wrack : OUT STD_LOGIC;
    training_wrdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    s_axi_araddr : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
    s_axi_arready : OUT STD_LOGIC;
    s_axi_arvalid : IN STD_LOGIC;
    s_axi_awaddr : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
    s_axi_awready : OUT STD_LOGIC;
    s_axi_awvalid : IN STD_LOGIC;
    s_axi_bready : IN STD_LOGIC;
    s_axi_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_bvalid : OUT STD_LOGIC;
    s_axi_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_rready : IN STD_LOGIC;
    s_axi_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_rvalid : OUT STD_LOGIC;
    s_axi_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_wready : OUT STD_LOGIC;
    s_axi_wvalid : IN STD_LOGIC;
    s_axis_tx_tdata : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    s_axis_tx_tkeep : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    s_axis_tx_tlast : IN STD_LOGIC;
    s_axis_tx_tready : OUT STD_LOGIC;
    s_axis_tx_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    s_axis_tx_tvalid : IN STD_LOGIC;
    s_axis_pause_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    s_axis_pause_tvalid : IN STD_LOGIC;
    m_axis_rx_tdata : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    m_axis_rx_tkeep : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    m_axis_rx_tlast : OUT STD_LOGIC;
    m_axis_rx_tuser : OUT STD_LOGIC;
    m_axis_rx_tvalid : OUT STD_LOGIC;
    tx_statistics_valid : OUT STD_LOGIC;
    tx_statistics_vector : OUT STD_LOGIC_VECTOR(25 DOWNTO 0);
    rx_statistics_valid : OUT STD_LOGIC;
    rx_statistics_vector : OUT STD_LOGIC_VECTOR(29 DOWNTO 0)
  );
END COMPONENT;
-- COMP_TAG_END ------ End COMPONENT Declaration ------------

-- The following code must appear in the VHDL architecture
-- body. Substitute your own instance name and net names.

------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
your_instance_name : axi_10g_ethernet_0
  PORT MAP (
    tx_axis_aresetn => tx_axis_aresetn,
    rx_axis_aresetn => rx_axis_aresetn,
    tx_ifg_delay => tx_ifg_delay,
    dclk => dclk,
    txp => txp,
    txn => txn,
    rxp => rxp,
    rxn => rxn,
    signal_detect => signal_detect,
    tx_fault => tx_fault,
    tx_disable => tx_disable,
    pcspma_status => pcspma_status,
    sim_speedup_control => sim_speedup_control,
    rxrecclk_out => rxrecclk_out,
    is_eval => is_eval,
    s_axi_aclk => s_axi_aclk,
    s_axi_aresetn => s_axi_aresetn,
    xgmacint => xgmacint,
    areset_datapathclk_out => areset_datapathclk_out,
    txusrclk_out => txusrclk_out,
    txusrclk2_out => txusrclk2_out,
    gttxreset_out => gttxreset_out,
    gtrxreset_out => gtrxreset_out,
    txuserrdy_out => txuserrdy_out,
    coreclk_out => coreclk_out,
    resetdone_out => resetdone_out,
    reset_counter_done_out => reset_counter_done_out,
    qplllock_out => qplllock_out,
    qplloutclk_out => qplloutclk_out,
    qplloutrefclk_out => qplloutrefclk_out,
    refclk_p => refclk_p,
    refclk_n => refclk_n,
    reset => reset,
    training_addr => training_addr,
    training_drp_cs => training_drp_cs,
    training_enable => training_enable,
    training_ipif_cs => training_ipif_cs,
    training_rdack => training_rdack,
    training_rddata => training_rddata,
    training_rnw => training_rnw,
    training_wrack => training_wrack,
    training_wrdata => training_wrdata,
    s_axi_araddr => s_axi_araddr,
    s_axi_arready => s_axi_arready,
    s_axi_arvalid => s_axi_arvalid,
    s_axi_awaddr => s_axi_awaddr,
    s_axi_awready => s_axi_awready,
    s_axi_awvalid => s_axi_awvalid,
    s_axi_bready => s_axi_bready,
    s_axi_bresp => s_axi_bresp,
    s_axi_bvalid => s_axi_bvalid,
    s_axi_rdata => s_axi_rdata,
    s_axi_rready => s_axi_rready,
    s_axi_rresp => s_axi_rresp,
    s_axi_rvalid => s_axi_rvalid,
    s_axi_wdata => s_axi_wdata,
    s_axi_wready => s_axi_wready,
    s_axi_wvalid => s_axi_wvalid,
    s_axis_tx_tdata => s_axis_tx_tdata,
    s_axis_tx_tkeep => s_axis_tx_tkeep,
    s_axis_tx_tlast => s_axis_tx_tlast,
    s_axis_tx_tready => s_axis_tx_tready,
    s_axis_tx_tuser => s_axis_tx_tuser,
    s_axis_tx_tvalid => s_axis_tx_tvalid,
    s_axis_pause_tdata => s_axis_pause_tdata,
    s_axis_pause_tvalid => s_axis_pause_tvalid,
    m_axis_rx_tdata => m_axis_rx_tdata,
    m_axis_rx_tkeep => m_axis_rx_tkeep,
    m_axis_rx_tlast => m_axis_rx_tlast,
    m_axis_rx_tuser => m_axis_rx_tuser,
    m_axis_rx_tvalid => m_axis_rx_tvalid,
    tx_statistics_valid => tx_statistics_valid,
    tx_statistics_vector => tx_statistics_vector,
    rx_statistics_valid => rx_statistics_valid,
    rx_statistics_vector => rx_statistics_vector
  );
-- INST_TAG_END ------ End INSTANTIATION Template ---------

-- You must compile the wrapper file axi_10g_ethernet_0.vhd when simulating
-- the core, axi_10g_ethernet_0. When compiling the wrapper file, be sure to
-- reference the VHDL simulation library.

