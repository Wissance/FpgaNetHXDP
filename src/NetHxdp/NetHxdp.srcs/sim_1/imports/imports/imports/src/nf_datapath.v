`timescale 1ns / 1ps
//-
// Copyright (c) 2015 Noa Zilberman
// All rights reserved.
//
// This software was developed by Stanford University and the University of Cambridge Computer Laboratory 
// under National Science Foundation under Grant No. CNS-0855268,
// the University of Cambridge Computer Laboratory under EPSRC INTERNET Project EP/H040536/1 and
// by the University of Cambridge Computer Laboratory under DARPA/AFRL contract FA8750-11-C-0249 ("MRC2"), 
// as part of the DARPA MRC research programme.
//
//  File:
//        nf_datapath.v
//
//  Module:
//        nf_datapath
//
//  Author: Noa Zilberman
//
//  Description:
//        NetFPGA user data path wrapper, wrapping input arbiter, output port lookup and output queues
//
//
// @NETFPGA_LICENSE_HEADER_START@
//
// Licensed to NetFPGA C.I.C. (NetFPGA) under one or more contributor
// license agreements.  See the NOTICE file distributed with this work for
// additional information regarding copyright ownership.  NetFPGA licenses this
// file to you under the NetFPGA Hardware-Software License, Version 1.0 (the
// "License"); you may not use this file except in compliance with the
// License.  You may obtain a copy of the License at:
//
//   http://www.netfpga-cic.org
//
// Unless required by applicable law or agreed to in writing, Work distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations under the License.
//
// @NETFPGA_LICENSE_HEADER_END@
//


module nf_datapath #(
    //Slave AXI parameters
    parameter C_S_AXI_DATA_WIDTH    = 32,          
    parameter C_S_AXI_ADDR_WIDTH    = 32,          
    parameter C_BASEADDR            = 32'h00000000,

    // Master AXI Stream Data Width
    parameter C_M_AXIS_DATA_WIDTH=256,
    parameter C_S_AXIS_DATA_WIDTH=256,
    parameter C_M_AXIS_TUSER_WIDTH=128,
    parameter C_S_AXIS_TUSER_WIDTH=128,
    parameter NUM_STAGES=2,
    parameter NUM_QUEUES=5
)
(
    //Datapath clock
    input                                     axis_aclk,
    input                                     axis_resetn,
    //Registers clock
    input                                     axi_aclk,
    input                                     axi_resetn,
    input                                     clk_1XX,
    input                                     resetn_1XX,

    // Slave AXI Ports
    input      [11 : 0]                       S0_AXI_AWADDR,
    input                                     S0_AXI_AWVALID,
    input      [C_S_AXI_DATA_WIDTH-1 : 0]     S0_AXI_WDATA,
    input      [C_S_AXI_DATA_WIDTH/8-1 : 0]   S0_AXI_WSTRB,
    input                                     S0_AXI_WVALID,
    input                                     S0_AXI_BREADY,
    input      [11 : 0]                       S0_AXI_ARADDR,
    input                                     S0_AXI_ARVALID,
    input                                     S0_AXI_RREADY,
    output                                    S0_AXI_ARREADY,
    output     [C_S_AXI_DATA_WIDTH-1 : 0]     S0_AXI_RDATA,
    output     [1 : 0]                        S0_AXI_RRESP,
    output                                    S0_AXI_RVALID,
    output                                    S0_AXI_WREADY,
    output     [1 :0]                         S0_AXI_BRESP,
    output                                    S0_AXI_BVALID,
    output                                    S0_AXI_AWREADY,
    
    input      [31 : 0]                       S1_AXI_AWADDR,
    input                                     S1_AXI_AWVALID,
    input      [C_S_AXI_DATA_WIDTH-1 : 0]     S1_AXI_WDATA,
    input      [C_S_AXI_DATA_WIDTH/8-1 : 0]   S1_AXI_WSTRB,
    input                                     S1_AXI_WVALID,
    input                                     S1_AXI_BREADY,
    input      [31 : 0]                       S1_AXI_ARADDR,
    input                                     S1_AXI_ARVALID,
    input                                     S1_AXI_RREADY,
    output                                    S1_AXI_ARREADY,
    output     [C_S_AXI_DATA_WIDTH-1 : 0]     S1_AXI_RDATA,
    output     [1 : 0]                        S1_AXI_RRESP,
    output                                    S1_AXI_RVALID,
    output                                    S1_AXI_WREADY,
    output     [1 :0]                         S1_AXI_BRESP,
    output                                    S1_AXI_BVALID,
    output                                    S1_AXI_AWREADY,

    input      [11 : 0]                       S2_AXI_AWADDR,
    input                                     S2_AXI_AWVALID,
    input      [C_S_AXI_DATA_WIDTH-1 : 0]     S2_AXI_WDATA,
    input      [C_S_AXI_DATA_WIDTH/8-1 : 0]   S2_AXI_WSTRB,
    input                                     S2_AXI_WVALID,
    input                                     S2_AXI_BREADY,
    input      [11 : 0]                       S2_AXI_ARADDR,
    input                                     S2_AXI_ARVALID,
    input                                     S2_AXI_RREADY,
    output                                    S2_AXI_ARREADY,
    output     [C_S_AXI_DATA_WIDTH-1 : 0]     S2_AXI_RDATA,
    output     [1 : 0]                        S2_AXI_RRESP,
    output                                    S2_AXI_RVALID,
    output                                    S2_AXI_WREADY,
    output     [1 :0]                         S2_AXI_BRESP,
    output                                    S2_AXI_BVALID,
    output                                    S2_AXI_AWREADY,

    
    // Slave Stream Ports (interface from Rx queues)
    input [C_S_AXIS_DATA_WIDTH - 1:0]         s_axis_0_tdata,
    input [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_0_tkeep,
    input [C_S_AXIS_TUSER_WIDTH-1:0]          s_axis_0_tuser,
    input                                     s_axis_0_tvalid,
    output                                    s_axis_0_tready,
    input                                     s_axis_0_tlast,
    input [C_S_AXIS_DATA_WIDTH - 1:0]         s_axis_1_tdata,
    input [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_1_tkeep,
    input [C_S_AXIS_TUSER_WIDTH-1:0]          s_axis_1_tuser,
    input                                     s_axis_1_tvalid,
    output                                    s_axis_1_tready,
    input                                     s_axis_1_tlast,
    input [C_S_AXIS_DATA_WIDTH - 1:0]         s_axis_2_tdata,
    input [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_2_tkeep,
    input [C_S_AXIS_TUSER_WIDTH-1:0]          s_axis_2_tuser,
    input                                     s_axis_2_tvalid,
    output                                    s_axis_2_tready,
    input                                     s_axis_2_tlast,
    input [C_S_AXIS_DATA_WIDTH - 1:0]         s_axis_3_tdata,
    input [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_3_tkeep,
    input [C_S_AXIS_TUSER_WIDTH-1:0]          s_axis_3_tuser,
    input                                     s_axis_3_tvalid,
    output                                    s_axis_3_tready,
    input                                     s_axis_3_tlast,
    input [C_S_AXIS_DATA_WIDTH - 1:0]         s_axis_4_tdata,
    input [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_4_tkeep,
    input [C_S_AXIS_TUSER_WIDTH-1:0]          s_axis_4_tuser,
    input                                     s_axis_4_tvalid,
    output                                    s_axis_4_tready,
    input                                     s_axis_4_tlast,


    // Master Stream Ports (interface to TX queues)
    output [C_M_AXIS_DATA_WIDTH - 1:0]         m_axis_0_tdata,
    output [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0] m_axis_0_tkeep,
    output [C_M_AXIS_TUSER_WIDTH-1:0]          m_axis_0_tuser,
    output                                     m_axis_0_tvalid,
    input                                      m_axis_0_tready,
    output                                     m_axis_0_tlast,
    output [C_M_AXIS_DATA_WIDTH - 1:0]         m_axis_1_tdata,
    output [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0] m_axis_1_tkeep,
    output [C_M_AXIS_TUSER_WIDTH-1:0]          m_axis_1_tuser,
    output                                     m_axis_1_tvalid,
    input                                      m_axis_1_tready,
    output                                     m_axis_1_tlast,
    output [C_M_AXIS_DATA_WIDTH - 1:0]         m_axis_2_tdata,
    output [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0] m_axis_2_tkeep,
    output [C_M_AXIS_TUSER_WIDTH-1:0]          m_axis_2_tuser,
    output                                     m_axis_2_tvalid,
    input                                      m_axis_2_tready,
    output                                     m_axis_2_tlast,
    output [C_M_AXIS_DATA_WIDTH - 1:0]         m_axis_3_tdata,
    output [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0] m_axis_3_tkeep,
    output [C_M_AXIS_TUSER_WIDTH-1:0]          m_axis_3_tuser,
    output                                     m_axis_3_tvalid,
    input                                      m_axis_3_tready,
    output                                     m_axis_3_tlast,
    output [C_M_AXIS_DATA_WIDTH - 1:0]         m_axis_4_tdata,
    output [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0] m_axis_4_tkeep,
    output [C_M_AXIS_TUSER_WIDTH-1:0]          m_axis_4_tuser,
    output                                     m_axis_4_tvalid,
    input                                      m_axis_4_tready,
    output                                     m_axis_4_tlast


    );
    
    //internal connectivity
(* mark_debug = "true" *)  
    wire [C_M_AXIS_DATA_WIDTH - 1:0]         axis_from_dut_tdata;
(* mark_debug = "true" *)
    wire [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0] axis_from_dut_tkeep;
(* mark_debug = "true" *)
    wire [C_M_AXIS_TUSER_WIDTH-1:0]          axis_from_dut_tuser;
(* mark_debug = "true" *)
    wire                                     axis_from_dut_tvalid;
(* mark_debug = "true" *)
    wire                                     axis_from_dut_tready;
(* mark_debug = "true" *)
    wire                                     axis_from_dut_tlast;

(* mark_debug = "true" *)     
    wire [C_M_AXIS_DATA_WIDTH - 1:0]         axis_to_dut_tdata;
(* mark_debug = "true" *)
    wire [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0] axis_to_dut_tkeep;
(* mark_debug = "true" *)
    wire [C_M_AXIS_TUSER_WIDTH-1:0]          axis_to_dut_tuser;
(* mark_debug = "true" *)
    wire                                     axis_to_dut_tvalid;
(* mark_debug = "true" *)
    wire                                     axis_to_dut_tready;
(* mark_debug = "true" *)
    wire                                     axis_to_dut_tlast;
   
   
   
   
   wire [C_M_AXIS_DATA_WIDTH - 1:0] axis_loop_back_tdata;
   wire [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0] axis_loop_back_tkeep;        
   wire [C_M_AXIS_TUSER_WIDTH-1:0] axis_loop_back_tuser_in; 
   wire [C_M_AXIS_TUSER_WIDTH-1:0] axis_loop_back_tuser;       
   wire axis_loop_back_tvalid;        
   wire axis_loop_back_tlast;      
   wire axis_loop_back_tready; 

   wire [C_M_AXIS_DATA_WIDTH - 1:0] axis_loop_back_tdata_oq_fifo;
   wire [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0] axis_loop_back_tkeep_oq_fifo;        
   wire [C_M_AXIS_TUSER_WIDTH-1:0] axis_loop_back_tuser_oq_fifo;       
   wire axis_loop_back_tvalid_oq_fifo;        
   wire axis_loop_back_tlast_oq_fifo;      
   wire axis_loop_back_tready_oq_fifo; 



   wire [C_M_AXIS_DATA_WIDTH - 1:0] s_axis_pkt_tdata;
   wire [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_pkt_tkeep;        
   wire [C_M_AXIS_TUSER_WIDTH-1:0] s_axis_pkt_tuser;        
   wire s_axis_pkt_tvalid;        
   wire s_axis_pkt_tlast;      
   wire s_axis_pkt_tready; 


   
    wire [C_M_AXIS_DATA_WIDTH - 1:0] m_axis_debug_tdata;        
    wire [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0] m_axis_debug_tkeep;        
    wire [C_M_AXIS_TUSER_WIDTH-1:0] m_axis_debug_tuser;        
    wire m_axis_debug_tvalid;        
    wire m_axis_debug_tlast;      
    wire m_axis_debug_tready;       
                    
   
      
       
    
       wire     [31 : 0]                       S10_AXI_AWADDR;
       wire     [0 : 0]                        S10_AXI_AWVALID;
       wire     [C_S_AXI_DATA_WIDTH-1 : 0]     S10_AXI_WDATA;
       wire     [C_S_AXI_DATA_WIDTH/8-1 : 0]   S10_AXI_WSTRB;
       wire     [0 : 0]                        S10_AXI_WVALID;
       wire     [0 : 0]                        S10_AXI_BREADY;
       wire     [31 : 0]                       S10_AXI_ARADDR;
       wire     [0 : 0]                        S10_AXI_ARVALID;
       wire     [0 : 0]                        S10_AXI_RREADY;
       wire     [0 : 0]                        S10_AXI_ARREADY;
       wire     [C_S_AXI_DATA_WIDTH-1 : 0]     S10_AXI_RDATA;
       wire     [1 : 0]                        S10_AXI_RRESP;
       wire     [0 : 0]                        S10_AXI_RVALID;
       wire     [0 : 0]                        S10_AXI_WREADY;
       wire     [1 :0]                         S10_AXI_BRESP;
       wire     [0 : 0]                        S10_AXI_BVALID;
       wire     [0 : 0]                        S10_AXI_AWREADY;
       
       
       
       wire     [31 : 0]                       S11_AXI_AWADDR;
       wire     [0 : 0]                        S11_AXI_AWVALID;
       wire     [C_S_AXI_DATA_WIDTH-1 : 0]     S11_AXI_WDATA;
       wire     [C_S_AXI_DATA_WIDTH/8-1 : 0]   S11_AXI_WSTRB;
       wire     [0 : 0]                        S11_AXI_WVALID;
       wire     [0 : 0]                        S11_AXI_BREADY;
       wire     [31 : 0]                       S11_AXI_ARADDR;
       wire     [0 : 0]                        S11_AXI_ARVALID;
       wire     [0 : 0]                        S11_AXI_RREADY;
       wire     [0 : 0]                        S11_AXI_ARREADY;
       wire     [C_S_AXI_DATA_WIDTH-1 : 0]     S11_AXI_RDATA;
       wire     [1 : 0]                        S11_AXI_RRESP;
       wire     [0 : 0]                        S11_AXI_RVALID;
       wire     [0 : 0]                        S11_AXI_WREADY;
       wire     [1 :0]                         S11_AXI_BRESP;
       wire                                    S11_AXI_BVALID;
       wire                                    S11_AXI_AWREADY;
    
             wire      [31 : 0]                      S12_AXI_AWADDR;
             wire                                    S12_AXI_AWVALID;
             wire      [C_S_AXI_DATA_WIDTH-1 : 0]    S12_AXI_WDATA;
             wire      [C_S_AXI_DATA_WIDTH/8-1 : 0]  S12_AXI_WSTRB;
             wire                                    S12_AXI_WVALID;
             wire                                    S12_AXI_BREADY;
             wire      [31 : 0]                      S12_AXI_ARADDR;
             wire                                    S12_AXI_ARVALID;
             wire                                    S12_AXI_RREADY;
             wire                                    S12_AXI_ARREADY;
             wire     [C_S_AXI_DATA_WIDTH-1 : 0]     S12_AXI_RDATA;
             wire     [1 : 0]                        S12_AXI_RRESP;
             wire                                    S12_AXI_RVALID;
             wire                                    S12_AXI_WREADY;
             wire     [1 :0]                         S12_AXI_BRESP;
             wire                                    S12_AXI_BVALID;
             wire                                    S12_AXI_AWREADY;
              
      
   
   
   
  //Input Arbiter
 input_arbiter_ip
 input_arbiter_v1_0 (
      .axis_aclk(axis_aclk), 
      .axis_resetn(axis_resetn), 
      .m_axis_tdata (axis_to_dut_tdata), 
      .m_axis_tkeep (axis_to_dut_tkeep), 
      .m_axis_tuser (axis_to_dut_tuser), 
      .m_axis_tvalid(axis_to_dut_tvalid), 
      .m_axis_tready(axis_to_dut_tready), 
      .m_axis_tlast (axis_to_dut_tlast), 
      .s_axis_0_tdata (s_axis_0_tdata), 
      .s_axis_0_tkeep (s_axis_0_tkeep), 
      .s_axis_0_tuser (s_axis_0_tuser), 
      .s_axis_0_tvalid(s_axis_0_tvalid), 
      .s_axis_0_tready(s_axis_0_tready), 
      .s_axis_0_tlast (s_axis_0_tlast), 
      .s_axis_1_tdata (s_axis_1_tdata), 
      .s_axis_1_tkeep (s_axis_1_tkeep), 
      .s_axis_1_tuser (s_axis_1_tuser), 
      .s_axis_1_tvalid(s_axis_1_tvalid), 
      .s_axis_1_tready(s_axis_1_tready), 
      .s_axis_1_tlast (s_axis_1_tlast), 
      .s_axis_2_tdata (s_axis_2_tdata), 
      .s_axis_2_tkeep (s_axis_2_tkeep), 
      .s_axis_2_tuser (s_axis_2_tuser), 
      .s_axis_2_tvalid(s_axis_2_tvalid), 
      .s_axis_2_tready(s_axis_2_tready), 
      .s_axis_2_tlast (s_axis_2_tlast), 
      .s_axis_3_tdata (s_axis_3_tdata), 
      .s_axis_3_tkeep (s_axis_3_tkeep), 
      .s_axis_3_tuser (s_axis_3_tuser), 
      .s_axis_3_tvalid(s_axis_3_tvalid), 
      .s_axis_3_tready(s_axis_3_tready), 
      .s_axis_3_tlast (s_axis_3_tlast), 
      .s_axis_4_tdata (s_axis_4_tdata), 
      .s_axis_4_tkeep (s_axis_4_tkeep), 
      .s_axis_4_tuser (s_axis_4_tuser), 
      .s_axis_4_tvalid(s_axis_4_tvalid), 
      .s_axis_4_tready(s_axis_4_tready), 
      .s_axis_4_tlast (s_axis_4_tlast),
      
     
      .S_AXI_AWADDR(S0_AXI_AWADDR), 
      .S_AXI_AWVALID(S0_AXI_AWVALID),
      .S_AXI_WDATA(S0_AXI_WDATA),  
      .S_AXI_WSTRB(S0_AXI_WSTRB),  
      .S_AXI_WVALID(S0_AXI_WVALID), 
      .S_AXI_BREADY(S0_AXI_BREADY), 
      .S_AXI_ARADDR(S0_AXI_ARADDR), 
      .S_AXI_ARVALID(S0_AXI_ARVALID),
      .S_AXI_RREADY(S0_AXI_RREADY), 
      .S_AXI_ARREADY(S0_AXI_ARREADY),
      .S_AXI_RDATA(S0_AXI_RDATA),  
      .S_AXI_RRESP(S0_AXI_RRESP),  
      .S_AXI_RVALID(S0_AXI_RVALID), 
      .S_AXI_WREADY(S0_AXI_WREADY), 
      .S_AXI_BRESP(S0_AXI_BRESP),  
      .S_AXI_BVALID(S0_AXI_BVALID), 
      .S_AXI_AWREADY(S0_AXI_AWREADY),
      .S_AXI_ACLK (axi_aclk), 
      .S_AXI_ARESETN(axi_resetn),
      .pkt_fwd() 
    );
    
assign axis_loop_back_tuser_in = {axis_loop_back_tuser[127:24],8'h02,axis_loop_back_tuser[15:0]};

ebpf4fpga_datapath eBPF4FPGA_DATAPTH_i( 
               
               .clk   (axis_aclk),   //: in std_logic;
               .reset (axis_resetn),      //: in std_logic;
                                         
                //-- Master Stream Ports.
              .m0_axis_tvalid  (axis_from_dut_tvalid ),   //: out std_logic;
              .m0_axis_tdata   (axis_from_dut_tdata  ) ,   // : out std_logic_vector(C_M00_AXIS_DATA_WIDTH-1 downto 0;
              .m0_axis_tkeep   (axis_from_dut_tkeep  ) ,   // : out std_logic_vector((C_M00_AXIS_DATA_WIDTH/8-1 downto 0;
              .m0_axis_tuser   (axis_from_dut_tuser  ) ,   // : out std_logic_vector(C_M00_AXIS_TUSER_WIDTH-1 downto 0;
              .m0_axis_tlast   (axis_from_dut_tlast  ) ,   // : out std_logic;
              .m0_axis_tready  (axis_from_dut_tready ),   // : in std_logic;
    
                //-- Ports of Axi Stream Slave Bus Interface S00_AXIS
                .s0_axis_tvalid (axis_to_dut_tvalid ),  //: in std_logic;
                .s0_axis_tdata  (axis_to_dut_tdata  ), //: in std_logic_vector(C_S00_AXIS_DATA_WIDTH-1 downto 0;
                .s0_axis_tkeep  (axis_to_dut_tkeep  ), //: in std_logic_vector((C_S00_AXIS_DATA_WIDTH/8-1 downto 0;
                .s0_axis_tuser  (axis_to_dut_tuser  ), //: in std_logic_vector(C_S00_AXIS_TUSER_WIDTH-1 downto 0;
                .s0_axis_tlast  (axis_to_dut_tlast  ), //: in std_logic;
                .s0_axis_tready (axis_to_dut_tready ),  //: out std_logic;

                 
                //-- Ports of Axi Slave Bus Interface S_AXI
                .S_AXI_ACLK       (axi_aclk 	),  
                .S_AXI_ARESETN    (axi_resetn	),  
                .S_AXI_AWADDR     (S10_AXI_AWADDR  ),   //: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0;     
                .S_AXI_AWVALID    (S10_AXI_AWVALID ),   //: in std_logic; 
                .S_AXI_WDATA      (S10_AXI_WDATA   ),  //: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0; 
                .S_AXI_WSTRB      (S10_AXI_WSTRB   ),   //: in std_logic_vector(C_S00_AXI_DATA_WIDTH/8-1 downto 0;   
                .S_AXI_WVALID     (S10_AXI_WVALID  ),    //: in std_logic;                                    
                .S_AXI_BREADY     (S10_AXI_BREADY  ),   //: in std_logic;                                    
                .S_AXI_ARADDR     (S10_AXI_ARADDR  ),   //: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0;
                .S_AXI_ARVALID    (S10_AXI_ARVALID ),     //: in std_logic;                                     
                .S_AXI_RREADY     (S10_AXI_RREADY  ),   //: in std_logic;                                     
                .S_AXI_ARREADY    (S10_AXI_ARREADY ),    //: out std_logic;             
                .S_AXI_RDATA      (S10_AXI_RDATA   ),     //: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0;
                .S_AXI_RRESP      (S10_AXI_RRESP   ),     //: out std_logic_vector(1 downto 0;
                .S_AXI_RVALID     (S10_AXI_RVALID  ),  //: out std_logic;                                   
                .S_AXI_WREADY     (S10_AXI_WREADY  ),    //: out std_logic; 
                .S_AXI_BRESP      (S10_AXI_BRESP   ),       //: out std_logic_vector(1 downto 0;                         
                .S_AXI_BVALID     (S10_AXI_BVALID  ),   //: out std_logic;                                    
                .S_AXI_AWREADY    (S10_AXI_AWREADY )      //: out std_logic
                
             );



assign m_axis_4_tvalid =1'b0;
assign m_axis_4_tdata = 256'b0;
assign m_axis_4_tkeep = 32'b0;
assign m_axis_4_tlast = 1'b0;
assign m_axis_4_tuser = 128'b0;        

      //Output queues
       output_queues_ip  
     bram_output_queues_1 (
      .axis_aclk(axis_aclk), 
      .axis_resetn(axis_resetn),           // for bypass:
      .s_axis_tdata   (axis_from_dut_tdata),  //.s_axis_tdata   (s_axis_from_dut_tdata),
      .s_axis_tkeep   (axis_from_dut_tkeep),  //.s_axis_tkeep   (s_axis_from_dut_tkeep),
      .s_axis_tuser   (axis_from_dut_tuser),  //.s_axis_tuser   (s_axis_from_dut_tuser),
      .s_axis_tvalid  (axis_from_dut_tvalid), //.s_axis_tvalid  (s_axis_from_dut_tvalid) 
      .s_axis_tready  (axis_from_dut_tready), //.s_axis_tready  (s_axis_from_dut_tready) 
      .s_axis_tlast   (axis_from_dut_tlast),  //.s_axis_tlast   (s_axis_from_dut_tlast),
      .m_axis_0_tdata (m_axis_0_tdata), 
      .m_axis_0_tkeep (m_axis_0_tkeep), 
      .m_axis_0_tuser (m_axis_0_tuser), 
      .m_axis_0_tvalid(m_axis_0_tvalid), 
      .m_axis_0_tready(m_axis_0_tready), 
      .m_axis_0_tlast (m_axis_0_tlast), 
      .m_axis_1_tdata (m_axis_1_tdata), 
      .m_axis_1_tkeep (m_axis_1_tkeep), 
      .m_axis_1_tuser (m_axis_1_tuser), 
      .m_axis_1_tvalid(m_axis_1_tvalid), 
      .m_axis_1_tready(m_axis_1_tready), 
      .m_axis_1_tlast (m_axis_1_tlast), 
      .m_axis_2_tdata (m_axis_2_tdata), 
      .m_axis_2_tkeep (m_axis_2_tkeep), 
      .m_axis_2_tuser (m_axis_2_tuser), 
      .m_axis_2_tvalid(m_axis_2_tvalid), 
      .m_axis_2_tready(m_axis_2_tready), 
      .m_axis_2_tlast (m_axis_2_tlast), 
      .m_axis_3_tdata (m_axis_3_tdata), 
      .m_axis_3_tkeep (m_axis_3_tkeep), 
      .m_axis_3_tuser (m_axis_3_tuser), 
      .m_axis_3_tvalid(m_axis_3_tvalid), 
      .m_axis_3_tready(m_axis_3_tready), 
      .m_axis_3_tlast (m_axis_3_tlast), 
      .m_axis_4_tdata  (axis_loop_back_tdata_oq_fifo),     //(m_axis_4_tdata), 
      .m_axis_4_tkeep  (axis_loop_back_tkeep_oq_fifo),    //(m_axis_4_tkeep), 
      .m_axis_4_tuser  (axis_loop_back_tuser_oq_fifo),    //(m_axis_4_tuser), 
      .m_axis_4_tvalid (axis_loop_back_tvalid_oq_fifo),    //(m_axis_4_tvalid), 
      .m_axis_4_tready (axis_loop_back_tready_oq_fifo),     //(m_axis_4_tready), 
      .m_axis_4_tlast  (axis_loop_back_tlast_oq_fifo),     //(m_axis_4_tlast), 
      .bytes_stored(), 
      .pkt_stored(), 
      .bytes_removed_0(), 
      .bytes_removed_1(), 
      .bytes_removed_2(), 
      .bytes_removed_3(), 
      .bytes_removed_4(), 
      .pkt_removed_0(), 
      .pkt_removed_1(), 
      .pkt_removed_2(), 
      .pkt_removed_3(), 
      .pkt_removed_4(), 
      .bytes_dropped(), 
      .pkt_dropped(), 

      .S_AXI_AWADDR(S2_AXI_AWADDR), 
      .S_AXI_AWVALID(S2_AXI_AWVALID),
      .S_AXI_WDATA(S2_AXI_WDATA),  
      .S_AXI_WSTRB(S2_AXI_WSTRB),  
      .S_AXI_WVALID(S2_AXI_WVALID), 
      .S_AXI_BREADY(S2_AXI_BREADY), 
      .S_AXI_ARADDR(S2_AXI_ARADDR), 
      .S_AXI_ARVALID(S2_AXI_ARVALID),
      .S_AXI_RREADY(S2_AXI_RREADY), 
      .S_AXI_ARREADY(S2_AXI_ARREADY),
      .S_AXI_RDATA(S2_AXI_RDATA),  
      .S_AXI_RRESP(S2_AXI_RRESP),  
      .S_AXI_RVALID(S2_AXI_RVALID), 
      .S_AXI_WREADY(S2_AXI_WREADY), 
      .S_AXI_BRESP(S2_AXI_BRESP),  
      .S_AXI_BVALID(S2_AXI_BVALID), 
      .S_AXI_AWREADY(S2_AXI_AWREADY),
      .S_AXI_ACLK (axi_aclk), 
      .S_AXI_ARESETN(axi_resetn)
    ); 
   

axilite_interconnect_5 axilite_interconnect_i( 
    .ACLK              (axi_aclk),
    .ARESETN           (axi_resetn),
    .M00_AXI_araddr    (S10_AXI_ARADDR),  
    .M00_AXI_arprot    (),  
    .M00_AXI_arready   (S10_AXI_ARREADY), 
    .M00_AXI_arvalid   (S10_AXI_ARVALID),  
    .M00_AXI_awaddr    (S10_AXI_AWADDR),  
    .M00_AXI_awprot    (),  
    .M00_AXI_awready   (S10_AXI_AWREADY),  
    .M00_AXI_awvalid   (S10_AXI_AWVALID),  
    .M00_AXI_bready    (S10_AXI_BREADY),  
    .M00_AXI_bresp     (S10_AXI_BRESP),  
    .M00_AXI_bvalid    (S10_AXI_BVALID),  
    .M00_AXI_rdata     (S10_AXI_RDATA),  
    .M00_AXI_rready    (S10_AXI_RREADY),  
    .M00_AXI_rresp     (S10_AXI_RRESP),  
    .M00_AXI_rvalid    (S10_AXI_RVALID),  
    .M00_AXI_wdata     (S10_AXI_WDATA),  
    .M00_AXI_wready    (S10_AXI_WREADY),  
    .M00_AXI_wstrb     (S10_AXI_WSTRB),  
    .M00_AXI_wvalid    (S10_AXI_WVALID), 
     
    .M01_AXI_araddr    (S11_AXI_ARADDR),    
    .M01_AXI_arprot    (),                   
    .M01_AXI_arready   (S11_AXI_ARREADY),   
    .M01_AXI_arvalid   (S11_AXI_ARVALID),   
    .M01_AXI_awaddr    (S11_AXI_AWADDR),    
    .M01_AXI_awprot    (),                                   
    .M01_AXI_awready   (S11_AXI_AWREADY),   
    .M01_AXI_awvalid   (S11_AXI_AWVALID),   
    .M01_AXI_bready    (S11_AXI_BREADY),    
    .M01_AXI_bresp     (S11_AXI_BRESP),     
    .M01_AXI_bvalid    (S11_AXI_BVALID),    
    .M01_AXI_rdata     (S11_AXI_RDATA),     
    .M01_AXI_rready    (S11_AXI_RREADY),    
    .M01_AXI_rresp     (S11_AXI_RRESP),     
    .M01_AXI_rvalid    (S11_AXI_RVALID),    
    .M01_AXI_wdata     (S11_AXI_WDATA),     
    .M01_AXI_wready    (S11_AXI_WREADY),    
    .M01_AXI_wstrb     (S11_AXI_WSTRB),     
    .M01_AXI_wvalid    (S11_AXI_WVALID),  

     
    .M02_AXI_araddr    (S12_AXI_ARADDR),    
    .M02_AXI_arprot    (),                   
    .M02_AXI_arready   (S12_AXI_ARREADY),   
    .M02_AXI_arvalid   (S12_AXI_ARVALID),   
    .M02_AXI_awaddr    (S12_AXI_AWADDR),    
    .M02_AXI_awprot    (),                                   
    .M02_AXI_awready   (S12_AXI_AWREADY),   
    .M02_AXI_awvalid   (S12_AXI_AWVALID),   
    .M02_AXI_bready    (S12_AXI_BREADY),    
    .M02_AXI_bresp     (S12_AXI_BRESP),     
    .M02_AXI_bvalid    (S12_AXI_BVALID),    
    .M02_AXI_rdata     (S12_AXI_RDATA),     
    .M02_AXI_rready    (S12_AXI_RREADY),    
    .M02_AXI_rresp     (S12_AXI_RRESP),     
    .M02_AXI_rvalid    (S12_AXI_RVALID),    
    .M02_AXI_wdata     (S12_AXI_WDATA),     
    .M02_AXI_wready    (S12_AXI_WREADY),    
    .M02_AXI_wstrb     (S12_AXI_WSTRB),     
    .M02_AXI_wvalid    (S12_AXI_WVALID),
          
    .S00_AXI_araddr    (S1_AXI_ARADDR),     
    .S00_AXI_arprot    (3'b000),  
    .S00_AXI_arready   (S1_AXI_ARREADY),    
    .S00_AXI_arvalid   (S1_AXI_ARVALID),    
    .S00_AXI_awaddr    (S1_AXI_AWADDR),     
    .S00_AXI_awprot    (3'b000), 
    .S00_AXI_awready   (S1_AXI_AWREADY),    
    .S00_AXI_awvalid   (S1_AXI_AWVALID),    
    .S00_AXI_bready    (S1_AXI_BREADY),     
    .S00_AXI_bresp     (S1_AXI_BRESP),      
    .S00_AXI_bvalid    (S1_AXI_BVALID),     
    .S00_AXI_rdata     (S1_AXI_RDATA),      
    .S00_AXI_rready    (S1_AXI_RREADY),     
    .S00_AXI_rresp     (S1_AXI_RRESP),      
    .S00_AXI_rvalid    (S1_AXI_RVALID),     
    .S00_AXI_wdata     (S1_AXI_WDATA),      
    .S00_AXI_wready    (S1_AXI_WREADY),     
    .S00_AXI_wstrb     (S1_AXI_WSTRB),      
    .S00_AXI_wvalid    (S1_AXI_WVALID)     
);            

endmodule

