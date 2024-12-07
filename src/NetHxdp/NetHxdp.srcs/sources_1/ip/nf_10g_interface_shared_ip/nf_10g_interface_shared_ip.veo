// (c) Copyright 1995-2020 Xilinx, Inc. All rights reserved.
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

// IP VLNV: NetFPGA:NetFPGA:nf_10ge_interface_shared:1.00
// IP Revision: 1

// The following must be inserted into your Verilog file for this
// core to be instantiated. Change the instance name and port connections
// (in parentheses) to your own signal names.

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
nf_10g_interface_shared_ip your_instance_name (
  .areset_clk156_out(areset_clk156_out),            // output wire areset_clk156_out
  .clk156_out(clk156_out),                          // output wire clk156_out
  .gtrxreset_out(gtrxreset_out),                    // output wire gtrxreset_out
  .gttxreset_out(gttxreset_out),                    // output wire gttxreset_out
  .qplllock_out(qplllock_out),                      // output wire qplllock_out
  .qplloutclk_out(qplloutclk_out),                  // output wire qplloutclk_out
  .qplloutrefclk_out(qplloutrefclk_out),            // output wire qplloutrefclk_out
  .txuserrdy_out(txuserrdy_out),                    // output wire txuserrdy_out
  .txusrclk_out(txusrclk_out),                      // output wire txusrclk_out
  .txusrclk2_out(txusrclk2_out),                    // output wire txusrclk2_out
  .reset_counter_done_out(reset_counter_done_out),  // output wire reset_counter_done_out
  .core_clk(core_clk),                              // input wire core_clk
  .core_resetn(core_resetn),                        // input wire [0 : 0] core_resetn
  .rst(rst),                                        // input wire rst
  .refclk_n(refclk_n),                              // input wire refclk_n
  .refclk_p(refclk_p),                              // input wire refclk_p
  .resetdone(resetdone),                            // output wire resetdone
  .tx_fault(tx_fault),                              // input wire tx_fault
  .tx_abs(tx_abs),                                  // input wire tx_abs
  .tx_disable(tx_disable),                          // output wire tx_disable
  .interface_number(interface_number),              // input wire [7 : 0] interface_number
  .m_axis_tdata(m_axis_tdata),                      // output wire [255 : 0] m_axis_tdata
  .m_axis_tkeep(m_axis_tkeep),                      // output wire [31 : 0] m_axis_tkeep
  .m_axis_tuser(m_axis_tuser),                      // output wire [127 : 0] m_axis_tuser
  .m_axis_tvalid(m_axis_tvalid),                    // output wire m_axis_tvalid
  .m_axis_tlast(m_axis_tlast),                      // output wire m_axis_tlast
  .m_axis_tready(m_axis_tready),                    // input wire m_axis_tready
  .s_axis_tdata(s_axis_tdata),                      // input wire [255 : 0] s_axis_tdata
  .s_axis_tkeep(s_axis_tkeep),                      // input wire [31 : 0] s_axis_tkeep
  .s_axis_tlast(s_axis_tlast),                      // input wire s_axis_tlast
  .s_axis_tuser(s_axis_tuser),                      // input wire [127 : 0] s_axis_tuser
  .s_axis_tvalid(s_axis_tvalid),                    // input wire s_axis_tvalid
  .s_axis_tready(s_axis_tready),                    // output wire s_axis_tready
  .S_AXI_ACLK(S_AXI_ACLK),                          // input wire S_AXI_ACLK
  .S_AXI_ARESETN(S_AXI_ARESETN),                    // input wire S_AXI_ARESETN
  .S_AXI_AWADDR(S_AXI_AWADDR),                      // input wire [11 : 0] S_AXI_AWADDR
  .S_AXI_AWVALID(S_AXI_AWVALID),                    // input wire S_AXI_AWVALID
  .S_AXI_WDATA(S_AXI_WDATA),                        // input wire [31 : 0] S_AXI_WDATA
  .S_AXI_WSTRB(S_AXI_WSTRB),                        // input wire [3 : 0] S_AXI_WSTRB
  .S_AXI_WVALID(S_AXI_WVALID),                      // input wire S_AXI_WVALID
  .S_AXI_BREADY(S_AXI_BREADY),                      // input wire S_AXI_BREADY
  .S_AXI_ARADDR(S_AXI_ARADDR),                      // input wire [11 : 0] S_AXI_ARADDR
  .S_AXI_ARVALID(S_AXI_ARVALID),                    // input wire S_AXI_ARVALID
  .S_AXI_RREADY(S_AXI_RREADY),                      // input wire S_AXI_RREADY
  .S_AXI_ARREADY(S_AXI_ARREADY),                    // output wire S_AXI_ARREADY
  .S_AXI_RDATA(S_AXI_RDATA),                        // output wire [31 : 0] S_AXI_RDATA
  .S_AXI_RRESP(S_AXI_RRESP),                        // output wire [1 : 0] S_AXI_RRESP
  .S_AXI_RVALID(S_AXI_RVALID),                      // output wire S_AXI_RVALID
  .S_AXI_WREADY(S_AXI_WREADY),                      // output wire S_AXI_WREADY
  .S_AXI_BRESP(S_AXI_BRESP),                        // output wire [1 : 0] S_AXI_BRESP
  .S_AXI_BVALID(S_AXI_BVALID),                      // output wire S_AXI_BVALID
  .S_AXI_AWREADY(S_AXI_AWREADY),                    // output wire S_AXI_AWREADY
  .rxn(rxn),                                        // input wire rxn
  .rxp(rxp),                                        // input wire rxp
  .txn(txn),                                        // output wire txn
  .txp(txp)                                        // output wire txp
);
// INST_TAG_END ------ End INSTANTIATION Template ---------

