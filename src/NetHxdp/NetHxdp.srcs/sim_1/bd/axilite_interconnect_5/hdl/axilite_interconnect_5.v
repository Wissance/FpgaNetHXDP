//Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2016.4 (lin64) Build 1756540 Mon Jan 23 19:11:19 MST 2017
//Date        : Thu Sep  3 18:41:09 2020
//Host        : ercole running 64-bit Ubuntu 16.04.6 LTS
//Command     : generate_target axilite_interconnect_5.bd
//Design      : axilite_interconnect_5
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "axilite_interconnect_5,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=axilite_interconnect_5,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=1,numReposBlks=1,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "axilite_interconnect_5.hwdef" *) 
module axilite_interconnect_5
   (ACLK,
    ARESETN,
    M00_AXI_araddr,
    M00_AXI_arprot,
    M00_AXI_arready,
    M00_AXI_arvalid,
    M00_AXI_awaddr,
    M00_AXI_awprot,
    M00_AXI_awready,
    M00_AXI_awvalid,
    M00_AXI_bready,
    M00_AXI_bresp,
    M00_AXI_bvalid,
    M00_AXI_rdata,
    M00_AXI_rready,
    M00_AXI_rresp,
    M00_AXI_rvalid,
    M00_AXI_wdata,
    M00_AXI_wready,
    M00_AXI_wstrb,
    M00_AXI_wvalid,
    M01_AXI_araddr,
    M01_AXI_arprot,
    M01_AXI_arready,
    M01_AXI_arvalid,
    M01_AXI_awaddr,
    M01_AXI_awprot,
    M01_AXI_awready,
    M01_AXI_awvalid,
    M01_AXI_bready,
    M01_AXI_bresp,
    M01_AXI_bvalid,
    M01_AXI_rdata,
    M01_AXI_rready,
    M01_AXI_rresp,
    M01_AXI_rvalid,
    M01_AXI_wdata,
    M01_AXI_wready,
    M01_AXI_wstrb,
    M01_AXI_wvalid,
    M02_AXI_araddr,
    M02_AXI_arprot,
    M02_AXI_arready,
    M02_AXI_arvalid,
    M02_AXI_awaddr,
    M02_AXI_awprot,
    M02_AXI_awready,
    M02_AXI_awvalid,
    M02_AXI_bready,
    M02_AXI_bresp,
    M02_AXI_bvalid,
    M02_AXI_rdata,
    M02_AXI_rready,
    M02_AXI_rresp,
    M02_AXI_rvalid,
    M02_AXI_wdata,
    M02_AXI_wready,
    M02_AXI_wstrb,
    M02_AXI_wvalid,
    M03_AXI_araddr,
    M03_AXI_arprot,
    M03_AXI_arready,
    M03_AXI_arvalid,
    M03_AXI_awaddr,
    M03_AXI_awprot,
    M03_AXI_awready,
    M03_AXI_awvalid,
    M03_AXI_bready,
    M03_AXI_bresp,
    M03_AXI_bvalid,
    M03_AXI_rdata,
    M03_AXI_rready,
    M03_AXI_rresp,
    M03_AXI_rvalid,
    M03_AXI_wdata,
    M03_AXI_wready,
    M03_AXI_wstrb,
    M03_AXI_wvalid,
    M04_AXI_araddr,
    M04_AXI_arprot,
    M04_AXI_arready,
    M04_AXI_arvalid,
    M04_AXI_awaddr,
    M04_AXI_awprot,
    M04_AXI_awready,
    M04_AXI_awvalid,
    M04_AXI_bready,
    M04_AXI_bresp,
    M04_AXI_bvalid,
    M04_AXI_rdata,
    M04_AXI_rready,
    M04_AXI_rresp,
    M04_AXI_rvalid,
    M04_AXI_wdata,
    M04_AXI_wready,
    M04_AXI_wstrb,
    M04_AXI_wvalid,
    S00_AXI_araddr,
    S00_AXI_arprot,
    S00_AXI_arready,
    S00_AXI_arvalid,
    S00_AXI_awaddr,
    S00_AXI_awprot,
    S00_AXI_awready,
    S00_AXI_awvalid,
    S00_AXI_bready,
    S00_AXI_bresp,
    S00_AXI_bvalid,
    S00_AXI_rdata,
    S00_AXI_rready,
    S00_AXI_rresp,
    S00_AXI_rvalid,
    S00_AXI_wdata,
    S00_AXI_wready,
    S00_AXI_wstrb,
    S00_AXI_wvalid);
  input ACLK;
  input ARESETN;
  output [31:0]M00_AXI_araddr;
  output [2:0]M00_AXI_arprot;
  input [0:0]M00_AXI_arready;
  output [0:0]M00_AXI_arvalid;
  output [31:0]M00_AXI_awaddr;
  output [2:0]M00_AXI_awprot;
  input [0:0]M00_AXI_awready;
  output [0:0]M00_AXI_awvalid;
  output [0:0]M00_AXI_bready;
  input [1:0]M00_AXI_bresp;
  input [0:0]M00_AXI_bvalid;
  input [31:0]M00_AXI_rdata;
  output [0:0]M00_AXI_rready;
  input [1:0]M00_AXI_rresp;
  input [0:0]M00_AXI_rvalid;
  output [31:0]M00_AXI_wdata;
  input [0:0]M00_AXI_wready;
  output [3:0]M00_AXI_wstrb;
  output [0:0]M00_AXI_wvalid;
  output [31:0]M01_AXI_araddr;
  output [2:0]M01_AXI_arprot;
  input [0:0]M01_AXI_arready;
  output [0:0]M01_AXI_arvalid;
  output [31:0]M01_AXI_awaddr;
  output [2:0]M01_AXI_awprot;
  input [0:0]M01_AXI_awready;
  output [0:0]M01_AXI_awvalid;
  output [0:0]M01_AXI_bready;
  input [1:0]M01_AXI_bresp;
  input [0:0]M01_AXI_bvalid;
  input [31:0]M01_AXI_rdata;
  output [0:0]M01_AXI_rready;
  input [1:0]M01_AXI_rresp;
  input [0:0]M01_AXI_rvalid;
  output [31:0]M01_AXI_wdata;
  input [0:0]M01_AXI_wready;
  output [3:0]M01_AXI_wstrb;
  output [0:0]M01_AXI_wvalid;
  output [31:0]M02_AXI_araddr;
  output [2:0]M02_AXI_arprot;
  input [0:0]M02_AXI_arready;
  output [0:0]M02_AXI_arvalid;
  output [31:0]M02_AXI_awaddr;
  output [2:0]M02_AXI_awprot;
  input [0:0]M02_AXI_awready;
  output [0:0]M02_AXI_awvalid;
  output [0:0]M02_AXI_bready;
  input [1:0]M02_AXI_bresp;
  input [0:0]M02_AXI_bvalid;
  input [31:0]M02_AXI_rdata;
  output [0:0]M02_AXI_rready;
  input [1:0]M02_AXI_rresp;
  input [0:0]M02_AXI_rvalid;
  output [31:0]M02_AXI_wdata;
  input [0:0]M02_AXI_wready;
  output [3:0]M02_AXI_wstrb;
  output [0:0]M02_AXI_wvalid;
  output [31:0]M03_AXI_araddr;
  output [2:0]M03_AXI_arprot;
  input [0:0]M03_AXI_arready;
  output [0:0]M03_AXI_arvalid;
  output [31:0]M03_AXI_awaddr;
  output [2:0]M03_AXI_awprot;
  input [0:0]M03_AXI_awready;
  output [0:0]M03_AXI_awvalid;
  output [0:0]M03_AXI_bready;
  input [1:0]M03_AXI_bresp;
  input [0:0]M03_AXI_bvalid;
  input [31:0]M03_AXI_rdata;
  output [0:0]M03_AXI_rready;
  input [1:0]M03_AXI_rresp;
  input [0:0]M03_AXI_rvalid;
  output [31:0]M03_AXI_wdata;
  input [0:0]M03_AXI_wready;
  output [3:0]M03_AXI_wstrb;
  output [0:0]M03_AXI_wvalid;
  output [31:0]M04_AXI_araddr;
  output [2:0]M04_AXI_arprot;
  input [0:0]M04_AXI_arready;
  output [0:0]M04_AXI_arvalid;
  output [31:0]M04_AXI_awaddr;
  output [2:0]M04_AXI_awprot;
  input [0:0]M04_AXI_awready;
  output [0:0]M04_AXI_awvalid;
  output [0:0]M04_AXI_bready;
  input [1:0]M04_AXI_bresp;
  input [0:0]M04_AXI_bvalid;
  input [31:0]M04_AXI_rdata;
  output [0:0]M04_AXI_rready;
  input [1:0]M04_AXI_rresp;
  input [0:0]M04_AXI_rvalid;
  output [31:0]M04_AXI_wdata;
  input [0:0]M04_AXI_wready;
  output [3:0]M04_AXI_wstrb;
  output [0:0]M04_AXI_wvalid;
  input [31:0]S00_AXI_araddr;
  input [2:0]S00_AXI_arprot;
  output [0:0]S00_AXI_arready;
  input [0:0]S00_AXI_arvalid;
  input [31:0]S00_AXI_awaddr;
  input [2:0]S00_AXI_awprot;
  output [0:0]S00_AXI_awready;
  input [0:0]S00_AXI_awvalid;
  input [0:0]S00_AXI_bready;
  output [1:0]S00_AXI_bresp;
  output [0:0]S00_AXI_bvalid;
  output [31:0]S00_AXI_rdata;
  input [0:0]S00_AXI_rready;
  output [1:0]S00_AXI_rresp;
  output [0:0]S00_AXI_rvalid;
  input [31:0]S00_AXI_wdata;
  output [0:0]S00_AXI_wready;
  input [3:0]S00_AXI_wstrb;
  input [0:0]S00_AXI_wvalid;

  wire ACLK_1;
  wire ARESETN_1;
  wire [31:0]S00_AXI_1_ARADDR;
  wire [2:0]S00_AXI_1_ARPROT;
  wire [0:0]S00_AXI_1_ARREADY;
  wire [0:0]S00_AXI_1_ARVALID;
  wire [31:0]S00_AXI_1_AWADDR;
  wire [2:0]S00_AXI_1_AWPROT;
  wire [0:0]S00_AXI_1_AWREADY;
  wire [0:0]S00_AXI_1_AWVALID;
  wire [0:0]S00_AXI_1_BREADY;
  wire [1:0]S00_AXI_1_BRESP;
  wire [0:0]S00_AXI_1_BVALID;
  wire [31:0]S00_AXI_1_RDATA;
  wire [0:0]S00_AXI_1_RREADY;
  wire [1:0]S00_AXI_1_RRESP;
  wire [0:0]S00_AXI_1_RVALID;
  wire [31:0]S00_AXI_1_WDATA;
  wire [0:0]S00_AXI_1_WREADY;
  wire [3:0]S00_AXI_1_WSTRB;
  wire [0:0]S00_AXI_1_WVALID;
  wire [31:0]axi_crossbar_0_M00_AXI_ARADDR;
  wire [2:0]axi_crossbar_0_M00_AXI_ARPROT;
  wire [0:0]axi_crossbar_0_M00_AXI_ARREADY;
  wire [0:0]axi_crossbar_0_M00_AXI_ARVALID;
  wire [31:0]axi_crossbar_0_M00_AXI_AWADDR;
  wire [2:0]axi_crossbar_0_M00_AXI_AWPROT;
  wire [0:0]axi_crossbar_0_M00_AXI_AWREADY;
  wire [0:0]axi_crossbar_0_M00_AXI_AWVALID;
  wire [0:0]axi_crossbar_0_M00_AXI_BREADY;
  wire [1:0]axi_crossbar_0_M00_AXI_BRESP;
  wire [0:0]axi_crossbar_0_M00_AXI_BVALID;
  wire [31:0]axi_crossbar_0_M00_AXI_RDATA;
  wire [0:0]axi_crossbar_0_M00_AXI_RREADY;
  wire [1:0]axi_crossbar_0_M00_AXI_RRESP;
  wire [0:0]axi_crossbar_0_M00_AXI_RVALID;
  wire [31:0]axi_crossbar_0_M00_AXI_WDATA;
  wire [0:0]axi_crossbar_0_M00_AXI_WREADY;
  wire [3:0]axi_crossbar_0_M00_AXI_WSTRB;
  wire [0:0]axi_crossbar_0_M00_AXI_WVALID;
  wire [63:32]axi_crossbar_0_M01_AXI_ARADDR;
  wire [5:3]axi_crossbar_0_M01_AXI_ARPROT;
  wire [0:0]axi_crossbar_0_M01_AXI_ARREADY;
  wire [1:1]axi_crossbar_0_M01_AXI_ARVALID;
  wire [63:32]axi_crossbar_0_M01_AXI_AWADDR;
  wire [5:3]axi_crossbar_0_M01_AXI_AWPROT;
  wire [0:0]axi_crossbar_0_M01_AXI_AWREADY;
  wire [1:1]axi_crossbar_0_M01_AXI_AWVALID;
  wire [1:1]axi_crossbar_0_M01_AXI_BREADY;
  wire [1:0]axi_crossbar_0_M01_AXI_BRESP;
  wire [0:0]axi_crossbar_0_M01_AXI_BVALID;
  wire [31:0]axi_crossbar_0_M01_AXI_RDATA;
  wire [1:1]axi_crossbar_0_M01_AXI_RREADY;
  wire [1:0]axi_crossbar_0_M01_AXI_RRESP;
  wire [0:0]axi_crossbar_0_M01_AXI_RVALID;
  wire [63:32]axi_crossbar_0_M01_AXI_WDATA;
  wire [0:0]axi_crossbar_0_M01_AXI_WREADY;
  wire [7:4]axi_crossbar_0_M01_AXI_WSTRB;
  wire [1:1]axi_crossbar_0_M01_AXI_WVALID;
  wire [95:64]axi_crossbar_0_M02_AXI_ARADDR;
  wire [8:6]axi_crossbar_0_M02_AXI_ARPROT;
  wire [0:0]axi_crossbar_0_M02_AXI_ARREADY;
  wire [2:2]axi_crossbar_0_M02_AXI_ARVALID;
  wire [95:64]axi_crossbar_0_M02_AXI_AWADDR;
  wire [8:6]axi_crossbar_0_M02_AXI_AWPROT;
  wire [0:0]axi_crossbar_0_M02_AXI_AWREADY;
  wire [2:2]axi_crossbar_0_M02_AXI_AWVALID;
  wire [2:2]axi_crossbar_0_M02_AXI_BREADY;
  wire [1:0]axi_crossbar_0_M02_AXI_BRESP;
  wire [0:0]axi_crossbar_0_M02_AXI_BVALID;
  wire [31:0]axi_crossbar_0_M02_AXI_RDATA;
  wire [2:2]axi_crossbar_0_M02_AXI_RREADY;
  wire [1:0]axi_crossbar_0_M02_AXI_RRESP;
  wire [0:0]axi_crossbar_0_M02_AXI_RVALID;
  wire [95:64]axi_crossbar_0_M02_AXI_WDATA;
  wire [0:0]axi_crossbar_0_M02_AXI_WREADY;
  wire [11:8]axi_crossbar_0_M02_AXI_WSTRB;
  wire [2:2]axi_crossbar_0_M02_AXI_WVALID;
  wire [127:96]axi_crossbar_0_M03_AXI_ARADDR;
  wire [11:9]axi_crossbar_0_M03_AXI_ARPROT;
  wire [0:0]axi_crossbar_0_M03_AXI_ARREADY;
  wire [3:3]axi_crossbar_0_M03_AXI_ARVALID;
  wire [127:96]axi_crossbar_0_M03_AXI_AWADDR;
  wire [11:9]axi_crossbar_0_M03_AXI_AWPROT;
  wire [0:0]axi_crossbar_0_M03_AXI_AWREADY;
  wire [3:3]axi_crossbar_0_M03_AXI_AWVALID;
  wire [3:3]axi_crossbar_0_M03_AXI_BREADY;
  wire [1:0]axi_crossbar_0_M03_AXI_BRESP;
  wire [0:0]axi_crossbar_0_M03_AXI_BVALID;
  wire [31:0]axi_crossbar_0_M03_AXI_RDATA;
  wire [3:3]axi_crossbar_0_M03_AXI_RREADY;
  wire [1:0]axi_crossbar_0_M03_AXI_RRESP;
  wire [0:0]axi_crossbar_0_M03_AXI_RVALID;
  wire [127:96]axi_crossbar_0_M03_AXI_WDATA;
  wire [0:0]axi_crossbar_0_M03_AXI_WREADY;
  wire [15:12]axi_crossbar_0_M03_AXI_WSTRB;
  wire [3:3]axi_crossbar_0_M03_AXI_WVALID;
  wire [159:128]axi_crossbar_0_M04_AXI_ARADDR;
  wire [14:12]axi_crossbar_0_M04_AXI_ARPROT;
  wire [0:0]axi_crossbar_0_M04_AXI_ARREADY;
  wire [4:4]axi_crossbar_0_M04_AXI_ARVALID;
  wire [159:128]axi_crossbar_0_M04_AXI_AWADDR;
  wire [14:12]axi_crossbar_0_M04_AXI_AWPROT;
  wire [0:0]axi_crossbar_0_M04_AXI_AWREADY;
  wire [4:4]axi_crossbar_0_M04_AXI_AWVALID;
  wire [4:4]axi_crossbar_0_M04_AXI_BREADY;
  wire [1:0]axi_crossbar_0_M04_AXI_BRESP;
  wire [0:0]axi_crossbar_0_M04_AXI_BVALID;
  wire [31:0]axi_crossbar_0_M04_AXI_RDATA;
  wire [4:4]axi_crossbar_0_M04_AXI_RREADY;
  wire [1:0]axi_crossbar_0_M04_AXI_RRESP;
  wire [0:0]axi_crossbar_0_M04_AXI_RVALID;
  wire [159:128]axi_crossbar_0_M04_AXI_WDATA;
  wire [0:0]axi_crossbar_0_M04_AXI_WREADY;
  wire [19:16]axi_crossbar_0_M04_AXI_WSTRB;
  wire [4:4]axi_crossbar_0_M04_AXI_WVALID;

  assign ACLK_1 = ACLK;
  assign ARESETN_1 = ARESETN;
  assign M00_AXI_araddr[31:0] = axi_crossbar_0_M00_AXI_ARADDR;
  assign M00_AXI_arprot[2:0] = axi_crossbar_0_M00_AXI_ARPROT;
  assign M00_AXI_arvalid[0] = axi_crossbar_0_M00_AXI_ARVALID;
  assign M00_AXI_awaddr[31:0] = axi_crossbar_0_M00_AXI_AWADDR;
  assign M00_AXI_awprot[2:0] = axi_crossbar_0_M00_AXI_AWPROT;
  assign M00_AXI_awvalid[0] = axi_crossbar_0_M00_AXI_AWVALID;
  assign M00_AXI_bready[0] = axi_crossbar_0_M00_AXI_BREADY;
  assign M00_AXI_rready[0] = axi_crossbar_0_M00_AXI_RREADY;
  assign M00_AXI_wdata[31:0] = axi_crossbar_0_M00_AXI_WDATA;
  assign M00_AXI_wstrb[3:0] = axi_crossbar_0_M00_AXI_WSTRB;
  assign M00_AXI_wvalid[0] = axi_crossbar_0_M00_AXI_WVALID;
  assign M01_AXI_araddr[31:0] = axi_crossbar_0_M01_AXI_ARADDR;
  assign M01_AXI_arprot[2:0] = axi_crossbar_0_M01_AXI_ARPROT;
  assign M01_AXI_arvalid[0] = axi_crossbar_0_M01_AXI_ARVALID;
  assign M01_AXI_awaddr[31:0] = axi_crossbar_0_M01_AXI_AWADDR;
  assign M01_AXI_awprot[2:0] = axi_crossbar_0_M01_AXI_AWPROT;
  assign M01_AXI_awvalid[0] = axi_crossbar_0_M01_AXI_AWVALID;
  assign M01_AXI_bready[0] = axi_crossbar_0_M01_AXI_BREADY;
  assign M01_AXI_rready[0] = axi_crossbar_0_M01_AXI_RREADY;
  assign M01_AXI_wdata[31:0] = axi_crossbar_0_M01_AXI_WDATA;
  assign M01_AXI_wstrb[3:0] = axi_crossbar_0_M01_AXI_WSTRB;
  assign M01_AXI_wvalid[0] = axi_crossbar_0_M01_AXI_WVALID;
  assign M02_AXI_araddr[31:0] = axi_crossbar_0_M02_AXI_ARADDR;
  assign M02_AXI_arprot[2:0] = axi_crossbar_0_M02_AXI_ARPROT;
  assign M02_AXI_arvalid[0] = axi_crossbar_0_M02_AXI_ARVALID;
  assign M02_AXI_awaddr[31:0] = axi_crossbar_0_M02_AXI_AWADDR;
  assign M02_AXI_awprot[2:0] = axi_crossbar_0_M02_AXI_AWPROT;
  assign M02_AXI_awvalid[0] = axi_crossbar_0_M02_AXI_AWVALID;
  assign M02_AXI_bready[0] = axi_crossbar_0_M02_AXI_BREADY;
  assign M02_AXI_rready[0] = axi_crossbar_0_M02_AXI_RREADY;
  assign M02_AXI_wdata[31:0] = axi_crossbar_0_M02_AXI_WDATA;
  assign M02_AXI_wstrb[3:0] = axi_crossbar_0_M02_AXI_WSTRB;
  assign M02_AXI_wvalid[0] = axi_crossbar_0_M02_AXI_WVALID;
  assign M03_AXI_araddr[31:0] = axi_crossbar_0_M03_AXI_ARADDR;
  assign M03_AXI_arprot[2:0] = axi_crossbar_0_M03_AXI_ARPROT;
  assign M03_AXI_arvalid[0] = axi_crossbar_0_M03_AXI_ARVALID;
  assign M03_AXI_awaddr[31:0] = axi_crossbar_0_M03_AXI_AWADDR;
  assign M03_AXI_awprot[2:0] = axi_crossbar_0_M03_AXI_AWPROT;
  assign M03_AXI_awvalid[0] = axi_crossbar_0_M03_AXI_AWVALID;
  assign M03_AXI_bready[0] = axi_crossbar_0_M03_AXI_BREADY;
  assign M03_AXI_rready[0] = axi_crossbar_0_M03_AXI_RREADY;
  assign M03_AXI_wdata[31:0] = axi_crossbar_0_M03_AXI_WDATA;
  assign M03_AXI_wstrb[3:0] = axi_crossbar_0_M03_AXI_WSTRB;
  assign M03_AXI_wvalid[0] = axi_crossbar_0_M03_AXI_WVALID;
  assign M04_AXI_araddr[31:0] = axi_crossbar_0_M04_AXI_ARADDR;
  assign M04_AXI_arprot[2:0] = axi_crossbar_0_M04_AXI_ARPROT;
  assign M04_AXI_arvalid[0] = axi_crossbar_0_M04_AXI_ARVALID;
  assign M04_AXI_awaddr[31:0] = axi_crossbar_0_M04_AXI_AWADDR;
  assign M04_AXI_awprot[2:0] = axi_crossbar_0_M04_AXI_AWPROT;
  assign M04_AXI_awvalid[0] = axi_crossbar_0_M04_AXI_AWVALID;
  assign M04_AXI_bready[0] = axi_crossbar_0_M04_AXI_BREADY;
  assign M04_AXI_rready[0] = axi_crossbar_0_M04_AXI_RREADY;
  assign M04_AXI_wdata[31:0] = axi_crossbar_0_M04_AXI_WDATA;
  assign M04_AXI_wstrb[3:0] = axi_crossbar_0_M04_AXI_WSTRB;
  assign M04_AXI_wvalid[0] = axi_crossbar_0_M04_AXI_WVALID;
  assign S00_AXI_1_ARADDR = S00_AXI_araddr[31:0];
  assign S00_AXI_1_ARPROT = S00_AXI_arprot[2:0];
  assign S00_AXI_1_ARVALID = S00_AXI_arvalid[0];
  assign S00_AXI_1_AWADDR = S00_AXI_awaddr[31:0];
  assign S00_AXI_1_AWPROT = S00_AXI_awprot[2:0];
  assign S00_AXI_1_AWVALID = S00_AXI_awvalid[0];
  assign S00_AXI_1_BREADY = S00_AXI_bready[0];
  assign S00_AXI_1_RREADY = S00_AXI_rready[0];
  assign S00_AXI_1_WDATA = S00_AXI_wdata[31:0];
  assign S00_AXI_1_WSTRB = S00_AXI_wstrb[3:0];
  assign S00_AXI_1_WVALID = S00_AXI_wvalid[0];
  assign S00_AXI_arready[0] = S00_AXI_1_ARREADY;
  assign S00_AXI_awready[0] = S00_AXI_1_AWREADY;
  assign S00_AXI_bresp[1:0] = S00_AXI_1_BRESP;
  assign S00_AXI_bvalid[0] = S00_AXI_1_BVALID;
  assign S00_AXI_rdata[31:0] = S00_AXI_1_RDATA;
  assign S00_AXI_rresp[1:0] = S00_AXI_1_RRESP;
  assign S00_AXI_rvalid[0] = S00_AXI_1_RVALID;
  assign S00_AXI_wready[0] = S00_AXI_1_WREADY;
  assign axi_crossbar_0_M00_AXI_ARREADY = M00_AXI_arready[0];
  assign axi_crossbar_0_M00_AXI_AWREADY = M00_AXI_awready[0];
  assign axi_crossbar_0_M00_AXI_BRESP = M00_AXI_bresp[1:0];
  assign axi_crossbar_0_M00_AXI_BVALID = M00_AXI_bvalid[0];
  assign axi_crossbar_0_M00_AXI_RDATA = M00_AXI_rdata[31:0];
  assign axi_crossbar_0_M00_AXI_RRESP = M00_AXI_rresp[1:0];
  assign axi_crossbar_0_M00_AXI_RVALID = M00_AXI_rvalid[0];
  assign axi_crossbar_0_M00_AXI_WREADY = M00_AXI_wready[0];
  assign axi_crossbar_0_M01_AXI_ARREADY = M01_AXI_arready[0];
  assign axi_crossbar_0_M01_AXI_AWREADY = M01_AXI_awready[0];
  assign axi_crossbar_0_M01_AXI_BRESP = M01_AXI_bresp[1:0];
  assign axi_crossbar_0_M01_AXI_BVALID = M01_AXI_bvalid[0];
  assign axi_crossbar_0_M01_AXI_RDATA = M01_AXI_rdata[31:0];
  assign axi_crossbar_0_M01_AXI_RRESP = M01_AXI_rresp[1:0];
  assign axi_crossbar_0_M01_AXI_RVALID = M01_AXI_rvalid[0];
  assign axi_crossbar_0_M01_AXI_WREADY = M01_AXI_wready[0];
  assign axi_crossbar_0_M02_AXI_ARREADY = M02_AXI_arready[0];
  assign axi_crossbar_0_M02_AXI_AWREADY = M02_AXI_awready[0];
  assign axi_crossbar_0_M02_AXI_BRESP = M02_AXI_bresp[1:0];
  assign axi_crossbar_0_M02_AXI_BVALID = M02_AXI_bvalid[0];
  assign axi_crossbar_0_M02_AXI_RDATA = M02_AXI_rdata[31:0];
  assign axi_crossbar_0_M02_AXI_RRESP = M02_AXI_rresp[1:0];
  assign axi_crossbar_0_M02_AXI_RVALID = M02_AXI_rvalid[0];
  assign axi_crossbar_0_M02_AXI_WREADY = M02_AXI_wready[0];
  assign axi_crossbar_0_M03_AXI_ARREADY = M03_AXI_arready[0];
  assign axi_crossbar_0_M03_AXI_AWREADY = M03_AXI_awready[0];
  assign axi_crossbar_0_M03_AXI_BRESP = M03_AXI_bresp[1:0];
  assign axi_crossbar_0_M03_AXI_BVALID = M03_AXI_bvalid[0];
  assign axi_crossbar_0_M03_AXI_RDATA = M03_AXI_rdata[31:0];
  assign axi_crossbar_0_M03_AXI_RRESP = M03_AXI_rresp[1:0];
  assign axi_crossbar_0_M03_AXI_RVALID = M03_AXI_rvalid[0];
  assign axi_crossbar_0_M03_AXI_WREADY = M03_AXI_wready[0];
  assign axi_crossbar_0_M04_AXI_ARREADY = M04_AXI_arready[0];
  assign axi_crossbar_0_M04_AXI_AWREADY = M04_AXI_awready[0];
  assign axi_crossbar_0_M04_AXI_BRESP = M04_AXI_bresp[1:0];
  assign axi_crossbar_0_M04_AXI_BVALID = M04_AXI_bvalid[0];
  assign axi_crossbar_0_M04_AXI_RDATA = M04_AXI_rdata[31:0];
  assign axi_crossbar_0_M04_AXI_RRESP = M04_AXI_rresp[1:0];
  assign axi_crossbar_0_M04_AXI_RVALID = M04_AXI_rvalid[0];
  assign axi_crossbar_0_M04_AXI_WREADY = M04_AXI_wready[0];
  axilite_interconnect_5_axi_crossbar_0_0 axi_crossbar_0
       (.aclk(ACLK_1),
        .aresetn(ARESETN_1),
        .m_axi_araddr({axi_crossbar_0_M04_AXI_ARADDR,axi_crossbar_0_M03_AXI_ARADDR,axi_crossbar_0_M02_AXI_ARADDR,axi_crossbar_0_M01_AXI_ARADDR,axi_crossbar_0_M00_AXI_ARADDR}),
        .m_axi_arprot({axi_crossbar_0_M04_AXI_ARPROT,axi_crossbar_0_M03_AXI_ARPROT,axi_crossbar_0_M02_AXI_ARPROT,axi_crossbar_0_M01_AXI_ARPROT,axi_crossbar_0_M00_AXI_ARPROT}),
        .m_axi_arready({axi_crossbar_0_M04_AXI_ARREADY,axi_crossbar_0_M03_AXI_ARREADY,axi_crossbar_0_M02_AXI_ARREADY,axi_crossbar_0_M01_AXI_ARREADY,axi_crossbar_0_M00_AXI_ARREADY}),
        .m_axi_arvalid({axi_crossbar_0_M04_AXI_ARVALID,axi_crossbar_0_M03_AXI_ARVALID,axi_crossbar_0_M02_AXI_ARVALID,axi_crossbar_0_M01_AXI_ARVALID,axi_crossbar_0_M00_AXI_ARVALID}),
        .m_axi_awaddr({axi_crossbar_0_M04_AXI_AWADDR,axi_crossbar_0_M03_AXI_AWADDR,axi_crossbar_0_M02_AXI_AWADDR,axi_crossbar_0_M01_AXI_AWADDR,axi_crossbar_0_M00_AXI_AWADDR}),
        .m_axi_awprot({axi_crossbar_0_M04_AXI_AWPROT,axi_crossbar_0_M03_AXI_AWPROT,axi_crossbar_0_M02_AXI_AWPROT,axi_crossbar_0_M01_AXI_AWPROT,axi_crossbar_0_M00_AXI_AWPROT}),
        .m_axi_awready({axi_crossbar_0_M04_AXI_AWREADY,axi_crossbar_0_M03_AXI_AWREADY,axi_crossbar_0_M02_AXI_AWREADY,axi_crossbar_0_M01_AXI_AWREADY,axi_crossbar_0_M00_AXI_AWREADY}),
        .m_axi_awvalid({axi_crossbar_0_M04_AXI_AWVALID,axi_crossbar_0_M03_AXI_AWVALID,axi_crossbar_0_M02_AXI_AWVALID,axi_crossbar_0_M01_AXI_AWVALID,axi_crossbar_0_M00_AXI_AWVALID}),
        .m_axi_bready({axi_crossbar_0_M04_AXI_BREADY,axi_crossbar_0_M03_AXI_BREADY,axi_crossbar_0_M02_AXI_BREADY,axi_crossbar_0_M01_AXI_BREADY,axi_crossbar_0_M00_AXI_BREADY}),
        .m_axi_bresp({axi_crossbar_0_M04_AXI_BRESP,axi_crossbar_0_M03_AXI_BRESP,axi_crossbar_0_M02_AXI_BRESP,axi_crossbar_0_M01_AXI_BRESP,axi_crossbar_0_M00_AXI_BRESP}),
        .m_axi_bvalid({axi_crossbar_0_M04_AXI_BVALID,axi_crossbar_0_M03_AXI_BVALID,axi_crossbar_0_M02_AXI_BVALID,axi_crossbar_0_M01_AXI_BVALID,axi_crossbar_0_M00_AXI_BVALID}),
        .m_axi_rdata({axi_crossbar_0_M04_AXI_RDATA,axi_crossbar_0_M03_AXI_RDATA,axi_crossbar_0_M02_AXI_RDATA,axi_crossbar_0_M01_AXI_RDATA,axi_crossbar_0_M00_AXI_RDATA}),
        .m_axi_rready({axi_crossbar_0_M04_AXI_RREADY,axi_crossbar_0_M03_AXI_RREADY,axi_crossbar_0_M02_AXI_RREADY,axi_crossbar_0_M01_AXI_RREADY,axi_crossbar_0_M00_AXI_RREADY}),
        .m_axi_rresp({axi_crossbar_0_M04_AXI_RRESP,axi_crossbar_0_M03_AXI_RRESP,axi_crossbar_0_M02_AXI_RRESP,axi_crossbar_0_M01_AXI_RRESP,axi_crossbar_0_M00_AXI_RRESP}),
        .m_axi_rvalid({axi_crossbar_0_M04_AXI_RVALID,axi_crossbar_0_M03_AXI_RVALID,axi_crossbar_0_M02_AXI_RVALID,axi_crossbar_0_M01_AXI_RVALID,axi_crossbar_0_M00_AXI_RVALID}),
        .m_axi_wdata({axi_crossbar_0_M04_AXI_WDATA,axi_crossbar_0_M03_AXI_WDATA,axi_crossbar_0_M02_AXI_WDATA,axi_crossbar_0_M01_AXI_WDATA,axi_crossbar_0_M00_AXI_WDATA}),
        .m_axi_wready({axi_crossbar_0_M04_AXI_WREADY,axi_crossbar_0_M03_AXI_WREADY,axi_crossbar_0_M02_AXI_WREADY,axi_crossbar_0_M01_AXI_WREADY,axi_crossbar_0_M00_AXI_WREADY}),
        .m_axi_wstrb({axi_crossbar_0_M04_AXI_WSTRB,axi_crossbar_0_M03_AXI_WSTRB,axi_crossbar_0_M02_AXI_WSTRB,axi_crossbar_0_M01_AXI_WSTRB,axi_crossbar_0_M00_AXI_WSTRB}),
        .m_axi_wvalid({axi_crossbar_0_M04_AXI_WVALID,axi_crossbar_0_M03_AXI_WVALID,axi_crossbar_0_M02_AXI_WVALID,axi_crossbar_0_M01_AXI_WVALID,axi_crossbar_0_M00_AXI_WVALID}),
        .s_axi_araddr(S00_AXI_1_ARADDR),
        .s_axi_arprot(S00_AXI_1_ARPROT),
        .s_axi_arready(S00_AXI_1_ARREADY),
        .s_axi_arvalid(S00_AXI_1_ARVALID),
        .s_axi_awaddr(S00_AXI_1_AWADDR),
        .s_axi_awprot(S00_AXI_1_AWPROT),
        .s_axi_awready(S00_AXI_1_AWREADY),
        .s_axi_awvalid(S00_AXI_1_AWVALID),
        .s_axi_bready(S00_AXI_1_BREADY),
        .s_axi_bresp(S00_AXI_1_BRESP),
        .s_axi_bvalid(S00_AXI_1_BVALID),
        .s_axi_rdata(S00_AXI_1_RDATA),
        .s_axi_rready(S00_AXI_1_RREADY),
        .s_axi_rresp(S00_AXI_1_RRESP),
        .s_axi_rvalid(S00_AXI_1_RVALID),
        .s_axi_wdata(S00_AXI_1_WDATA),
        .s_axi_wready(S00_AXI_1_WREADY),
        .s_axi_wstrb(S00_AXI_1_WSTRB),
        .s_axi_wvalid(S00_AXI_1_WVALID));
endmodule
