// (c) Copyright 1995-2024 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: xilinx.com:ip:axi_10g_ethernet:3.1
// IP Revision: 10

`timescale 1ns/1ps

(* DowngradeIPIdentifiedWarnings = "yes" *)
module axi_10g_ethernet_shared (
  tx_axis_aresetn,
  rx_axis_aresetn,
  tx_ifg_delay,
  dclk,
  txp,
  txn,
  rxp,
  rxn,
  signal_detect,
  tx_fault,
  tx_disable,
  pcspma_status,
  sim_speedup_control,
  rxrecclk_out,
  mac_tx_configuration_vector,
  mac_rx_configuration_vector,
  mac_status_vector,
  pcs_pma_configuration_vector,
  pcs_pma_status_vector,
  areset_datapathclk_out,
  txusrclk_out,
  txusrclk2_out,
  gttxreset_out,
  gtrxreset_out,
  txuserrdy_out,
  coreclk_out,
  resetdone_out,
  reset_counter_done_out,
  qplllock_out,
  qplloutclk_out,
  qplloutrefclk_out,
  refclk_p,
  refclk_n,
  reset,
  s_axis_tx_tdata,
  s_axis_tx_tkeep,
  s_axis_tx_tlast,
  s_axis_tx_tready,
  s_axis_tx_tuser,
  s_axis_tx_tvalid,
  s_axis_pause_tdata,
  s_axis_pause_tvalid,
  m_axis_rx_tdata,
  m_axis_rx_tkeep,
  m_axis_rx_tlast,
  m_axis_rx_tuser,
  m_axis_rx_tvalid,
  tx_statistics_valid,
  tx_statistics_vector,
  rx_statistics_valid,
  rx_statistics_vector
);

(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.tx_axis_aresetn, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.tx_axis_aresetn RST" *)
input wire tx_axis_aresetn;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.rx_axis_aresetn, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.rx_axis_aresetn RST" *)
input wire rx_axis_aresetn;
input wire [7 : 0] tx_ifg_delay;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.dclk, FREQ_HZ 100000000, PHASE 0.000, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.dclk CLK" *)
input wire dclk;
output wire txp;
output wire txn;
input wire rxp;
input wire rxn;
input wire signal_detect;
input wire tx_fault;
output wire tx_disable;
output wire [7 : 0] pcspma_status;
input wire sim_speedup_control;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.rxrecclk_out, FREQ_HZ 322265625, PHASE 0.000, CLK_DOMAIN bd_a1aa_xpcs_0_rxrecclk_out, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.rxrecclk_out CLK" *)
output wire rxrecclk_out;
input wire [79 : 0] mac_tx_configuration_vector;
input wire [79 : 0] mac_rx_configuration_vector;
output wire [2 : 0] mac_status_vector;
input wire [535 : 0] pcs_pma_configuration_vector;
output wire [447 : 0] pcs_pma_status_vector;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.areset_datapathclk_out, POLARITY ACTIVE_HIGH, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.areset_datapathclk_out RST" *)
output wire areset_datapathclk_out;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.txusrclk_out, FREQ_HZ 322265625, PHASE 0.000, CLK_DOMAIN bd_a1aa_xpcs_0_txusrclk_out, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.txusrclk_out CLK" *)
output wire txusrclk_out;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.txusrclk2_out, FREQ_HZ 322265625, PHASE 0.000, CLK_DOMAIN bd_a1aa_xpcs_0_txusrclk2_out, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.txusrclk2_out CLK" *)
output wire txusrclk2_out;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.gttxreset_out, POLARITY ACTIVE_HIGH, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.gttxreset_out RST" *)
output wire gttxreset_out;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.gtrxreset_out, POLARITY ACTIVE_HIGH, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.gtrxreset_out RST" *)
output wire gtrxreset_out;
output wire txuserrdy_out;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.coreclk_out, FREQ_HZ 156250000, PHASE 0.000, CLK_DOMAIN bd_a1aa_xpcs_0_coreclk_out, ASSOCIATED_BUSIF m_axis_rx:s_axis_pause:s_axis_tx, INSERT_VIP 0, ASSOCIATED_ASYNC_RESET tx_axis_aresetn:rx_axis_aresetn" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.coreclk_out CLK" *)
output wire coreclk_out;
output wire resetdone_out;
output wire reset_counter_done_out;
output wire qplllock_out;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.qplloutclk_out, FREQ_HZ 156250000, PHASE 0.000, CLK_DOMAIN bd_a1aa_xpcs_0_qplloutclk_out, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.qplloutclk_out CLK" *)
output wire qplloutclk_out;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.qplloutrefclk_out, FREQ_HZ 156250000, PHASE 0.000, CLK_DOMAIN bd_a1aa_xpcs_0_qplloutrefclk_out, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.qplloutrefclk_out CLK" *)
output wire qplloutrefclk_out;
input wire refclk_p;
input wire refclk_n;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.reset, POLARITY ACTIVE_HIGH, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.reset RST" *)
input wire reset;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_tx TDATA" *)
input wire [63 : 0] s_axis_tx_tdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_tx TKEEP" *)
input wire [7 : 0] s_axis_tx_tkeep;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_tx TLAST" *)
input wire s_axis_tx_tlast;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_tx TREADY" *)
output wire s_axis_tx_tready;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_tx TUSER" *)
input wire [0 : 0] s_axis_tx_tuser;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axis_tx, TDATA_NUM_BYTES 8, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 1, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 156250000, PHASE 0.000, CLK_DOMAIN bd_a1aa_xpcs_0_coreclk_out, LAYERED_METADATA undef, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_tx TVALID" *)
input wire s_axis_tx_tvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_pause TDATA" *)
input wire [15 : 0] s_axis_pause_tdata;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axis_pause, TDATA_NUM_BYTES 2, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 0, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 156250000, PHASE 0.000, CLK_DOMAIN bd_a1aa_xpcs_0_coreclk_out, LAYERED_METADATA undef, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_pause TVALID" *)
input wire s_axis_pause_tvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis_rx TDATA" *)
output wire [63 : 0] m_axis_rx_tdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis_rx TKEEP" *)
output wire [7 : 0] m_axis_rx_tkeep;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis_rx TLAST" *)
output wire m_axis_rx_tlast;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis_rx TUSER" *)
output wire m_axis_rx_tuser;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME m_axis_rx, TDATA_NUM_BYTES 8, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 1, HAS_TREADY 0, HAS_TSTRB 0, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 156250000, PHASE 0.000, CLK_DOMAIN bd_a1aa_xpcs_0_coreclk_out, LAYERED_METADATA undef, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis_rx TVALID" *)
output wire m_axis_rx_tvalid;
(* X_INTERFACE_INFO = "xilinx.com:display_ten_gig_eth_mac:statistics:2.0 tx_statistics valid" *)
output wire tx_statistics_valid;
(* X_INTERFACE_INFO = "xilinx.com:display_ten_gig_eth_mac:statistics:2.0 tx_statistics vector" *)
output wire [25 : 0] tx_statistics_vector;
(* X_INTERFACE_INFO = "xilinx.com:display_ten_gig_eth_mac:statistics:2.0 rx_statistics valid" *)
output wire rx_statistics_valid;
(* X_INTERFACE_INFO = "xilinx.com:display_ten_gig_eth_mac:statistics:2.0 rx_statistics vector" *)
output wire [29 : 0] rx_statistics_vector;

  bd_a1aa inst (
    .tx_axis_aresetn(tx_axis_aresetn),
    .rx_axis_aresetn(rx_axis_aresetn),
    .tx_ifg_delay(tx_ifg_delay),
    .dclk(dclk),
    .txp(txp),
    .txn(txn),
    .rxp(rxp),
    .rxn(rxn),
    .signal_detect(signal_detect),
    .tx_fault(tx_fault),
    .tx_disable(tx_disable),
    .pcspma_status(pcspma_status),
    .sim_speedup_control(sim_speedup_control),
    .rxrecclk_out(rxrecclk_out),
    .mac_tx_configuration_vector(mac_tx_configuration_vector),
    .mac_rx_configuration_vector(mac_rx_configuration_vector),
    .mac_status_vector(mac_status_vector),
    .pcs_pma_configuration_vector(pcs_pma_configuration_vector),
    .pcs_pma_status_vector(pcs_pma_status_vector),
    .areset_datapathclk_out(areset_datapathclk_out),
    .txusrclk_out(txusrclk_out),
    .txusrclk2_out(txusrclk2_out),
    .gttxreset_out(gttxreset_out),
    .gtrxreset_out(gtrxreset_out),
    .txuserrdy_out(txuserrdy_out),
    .coreclk_out(coreclk_out),
    .resetdone_out(resetdone_out),
    .reset_counter_done_out(reset_counter_done_out),
    .qplllock_out(qplllock_out),
    .qplloutclk_out(qplloutclk_out),
    .qplloutrefclk_out(qplloutrefclk_out),
    .refclk_p(refclk_p),
    .refclk_n(refclk_n),
    .reset(reset),
    .s_axis_tx_tdata(s_axis_tx_tdata),
    .s_axis_tx_tkeep(s_axis_tx_tkeep),
    .s_axis_tx_tlast(s_axis_tx_tlast),
    .s_axis_tx_tready(s_axis_tx_tready),
    .s_axis_tx_tuser(s_axis_tx_tuser),
    .s_axis_tx_tvalid(s_axis_tx_tvalid),
    .s_axis_pause_tdata(s_axis_pause_tdata),
    .s_axis_pause_tvalid(s_axis_pause_tvalid),
    .m_axis_rx_tdata(m_axis_rx_tdata),
    .m_axis_rx_tkeep(m_axis_rx_tkeep),
    .m_axis_rx_tlast(m_axis_rx_tlast),
    .m_axis_rx_tuser(m_axis_rx_tuser),
    .m_axis_rx_tvalid(m_axis_rx_tvalid),
    .tx_statistics_valid(tx_statistics_valid),
    .tx_statistics_vector(tx_statistics_vector),
    .rx_statistics_valid(rx_statistics_valid),
    .rx_statistics_vector(rx_statistics_vector)
  );
endmodule
