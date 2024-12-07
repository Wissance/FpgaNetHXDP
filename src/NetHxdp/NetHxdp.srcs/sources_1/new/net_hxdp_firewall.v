`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.12.2024 20:21:37
// Design Name: 
// Module Name: net_hxdp_firewall
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module net_hxdp_firewall# (  
  parameter C_DATA_WIDTH  = 256,         // RX/TX interface data width
  parameter C_TUSER_WIDTH = 128          // RX/TX interface data width    
) 
(
  // PCI Express
  input  [7:0]pcie_7x_mgt_rxn,
  input  [7:0]pcie_7x_mgt_rxp,
  output [7:0]pcie_7x_mgt_txn,
  output [7:0]pcie_7x_mgt_txp,
  
  // 10G Interface (QSFP)
  // SFP1A
  input  sfp0_rx_p,
  input  sfp0_rx_n,
  output sfp0_tx_p,
  output sfp0_tx_n,
  // input  sfp0_tx_fault,  // missing in Kintex7 BAse-C
  input  sfp0_tx_abs,   
  output sfp0_tx_disable,
  
  // SFP1B
  input  sfp1_rx_p,
  input  sfp1_rx_n,
  output sfp1_tx_p,
  output sfp1_tx_n,
  // input  sfp1_tx_fault,  // missing in Kintex7 BAse-C
  input  sfp1_tx_abs,   
  output sfp1_tx_disable,  
  
  /*    
  input  sfp2_rx_p,
  input  sfp2_rx_n,
  output sfp2_tx_p,
  output sfp2_tx_n,
  input  sfp2_tx_fault,  
  input  sfp2_tx_abs,   
  output sfp2_tx_disable,
  
      
  input  sfp3_rx_p,
  input  sfp3_rx_n,
  output sfp3_tx_p,
  output sfp3_tx_n,
  input  sfp3_tx_fault,  
  input  sfp3_tx_abs,   
  output sfp3_tx_disable,
  */ 
  
  // 100MHz PCIe Clock
  // ????????
  // input        sys_clkp,
  // input        sys_clkn,
  
  //  50MHz FPGA Clock
  input fpga_cry_clk,
  //  in hXDP used 25 MHz, therefore here should be a PLL (x8)
  input fpga_sysclk_1,
  input fpga_sysclk_2,
  input fpga_reset,
  
  // + Present in board Kintex-7 Base-C
  // 156.25MHz Si5324 clock 
  input xphy_refclk_p,
  input xphy_refclk_n,
 
 // debug features 
  output [7:0] leds,
     
  output sfp0_rx_led,
  output sfp0_tx_led,
  output sfp1_rx_led,
  output sfp1_tx_led,

  // -SI5324 I2C programming interface 
  inout i2c_clk,
  inout i2c_data,
  output [1:0] i2c_reset,

  // UART interface
  input  uart_rxd,
  output uart_txd,    

  input  sys_reset_n 
);

  //----------------------------------------------------------------------------------------------------------------//
  //    System(SYS) Interface                                                                                       //
  //----------------------------------------------------------------------------------------------------------------//
  wire clk_100MHz;  // according to comments this is for PCI-E
  wire clk_200MHz;  // according to comments this for other (???) purposes
  wire clk_150MHz;
  wire out_clk_locked;
  
  // ???????????
  // clk_200 -> clk_200MHz, clk_200_locked -> out_clk_locked, clk_1xx -> clk_150MHz
  // TODO(UMV): probably all these lines should be removed ...
  wire pci_sys_clk;
  // wire clk_200;
  // wire clk_1XX;
  wire aresetn_clk_1XX;
  wire sys_rst_n_c;
  // wire clk_200_locked;
  
  //----------------------------------------------------------------------------------------------------------------//
  // axis interface                                                                                                 //
  //----------------------------------------------------------------------------------------------------------------//

  // axi0 input
  wire[C_DATA_WIDTH-1:0] axis_i_0_tdata;
  wire axis_i_0_tvalid;
  wire axis_i_0_tlast;
  wire[C_TUSER_WIDTH-1:0] axis_i_0_tuser;
  wire[(C_DATA_WIDTH/8)-1:0] axis_i_0_tkeep;
  wire axis_i_0_tready;
  
  // axi0 output
  wire[C_DATA_WIDTH-1:0] axis_o_0_tdata;
  wire axis_o_0_tvalid;
  wire axis_o_0_tlast;
  wire[C_TUSER_WIDTH-1:0] axis_o_0_tuser;
  wire[(C_DATA_WIDTH/8)-1:0] axis_o_0_tkeep;
  wire axis_o_0_tready;

  // axi1 input
  wire[C_DATA_WIDTH-1:0] axis_i_1_tdata;
  wire axis_i_1_tvalid;
  wire axis_i_1_tlast;
  wire[C_TUSER_WIDTH-1:0] axis_i_1_tuser;
  wire[C_DATA_WIDTH/8-1:0] axis_i_1_tkeep;
  wire axis_i_1_tready;

  // axi1 output
  wire[C_DATA_WIDTH-1:0] axis_o_1_tdata;
  wire axis_o_1_tvalid;
  wire axis_o_1_tlast;
  wire[C_TUSER_WIDTH-1:0] axis_o_1_tuser;
  wire[C_DATA_WIDTH/8-1:0] axis_o_1_tkeep;
  wire axis_o_1_tready;

  // axi2 input
  wire[C_DATA_WIDTH-1:0] axis_i_2_tdata;
  wire axis_i_2_tvalid;
  wire axis_i_2_tlast;
  wire[C_TUSER_WIDTH-1:0] axis_i_2_tuser;
  wire[C_DATA_WIDTH/8-1:0] axis_i_2_tkeep;
  wire axis_i_2_tready;

  // axi2 output
  wire[C_DATA_WIDTH-1:0] axis_o_2_tdata;
  wire axis_o_2_tvalid;
  wire axis_o_2_tlast;
  wire[C_TUSER_WIDTH-1:0] axis_o_2_tuser;
  wire[C_DATA_WIDTH/8-1:0] axis_o_2_tkeep;
  wire axis_o_2_tready;

  // axi3 input
  wire[C_DATA_WIDTH-1:0] axis_i_3_tdata;
  wire axis_i_3_tvalid;
  wire axis_i_3_tlast;
  wire[C_TUSER_WIDTH-1:0] axis_i_3_tuser;
  wire[C_DATA_WIDTH/8-1:0] axis_i_3_tkeep;
  wire axis_i_3_tready;

  // axi3 output
  wire[C_DATA_WIDTH-1:0] axis_o_3_tdata;
  wire axis_o_3_tvalid;
  wire axis_o_3_tlast;
  wire[C_TUSER_WIDTH-1:0] axis_o_3_tuser;
  wire[C_DATA_WIDTH/8-1:0] axis_o_3_tkeep;
  wire axis_o_3_tready;

  // AXIS DMA interfaces
  wire[255:0] axis_dma_i_tdata ;
  wire[31:0] axis_dma_i_tkeep ;
  wire axis_dma_i_tlast ;
  wire axis_dma_i_tready;
  wire[255:0] axis_dma_i_tuser ;
  wire axis_dma_i_tvalid;
  
  wire[255:0] axis_dma_o_tdata;
  wire[31:0] axis_dma_o_tkeep;
  wire axis_dma_o_tlast;
  wire axis_dma_o_tready;
  wire[127:0] axis_dma_o_tuser;
  wire axis_dma_o_tvalid;
  
  //----------------------------------------------------------------------------------------------------------------//
 // AXI Lite interface                                                                                                 //
 //----------------------------------------------------------------------------------------------------------------//
  wire [31:0]   M00_AXI_araddr;
  wire [2:0]    M00_AXI_arprot;
  wire [0:0]    M00_AXI_arready;
  wire [0:0]    M00_AXI_arvalid;
  wire [31:0]   M00_AXI_awaddr;
  wire [2:0]    M00_AXI_awprot;
  wire [0:0]    M00_AXI_awready;
  wire [0:0]    M00_AXI_awvalid;
  wire [0:0]    M00_AXI_bready;
  wire [1:0]    M00_AXI_bresp;
  wire [0:0]    M00_AXI_bvalid;
  wire [31:0]   M00_AXI_rdata;
  wire [0:0]    M00_AXI_rready;
  wire [1:0]    M00_AXI_rresp;
  wire [0:0]    M00_AXI_rvalid;
  wire [31:0]   M00_AXI_wdata;
  wire [0:0]    M00_AXI_wready;
  wire [3:0]    M00_AXI_wstrb;
  wire [0:0]    M00_AXI_wvalid;
  
  wire [11:0]   M01_AXI_araddr;
  wire [2:0]    M01_AXI_arprot;
  wire [0:0]    M01_AXI_arready;
  wire [0:0]    M01_AXI_arvalid;
  wire [11:0]   M01_AXI_awaddr;
  wire [2:0]    M01_AXI_awprot;
  wire [0:0]    M01_AXI_awready;
  wire [0:0]    M01_AXI_awvalid;
  wire [0:0]    M01_AXI_bready;
  wire [1:0]    M01_AXI_bresp;
  wire [0:0]    M01_AXI_bvalid;
  wire [31:0]   M01_AXI_rdata;
  wire [0:0]    M01_AXI_rready;
  wire [1:0]    M01_AXI_rresp;
  wire [0:0]    M01_AXI_rvalid;
  wire [31:0]   M01_AXI_wdata;
  wire [0:0]    M01_AXI_wready;
  wire [3:0]    M01_AXI_wstrb;
  wire [0:0]    M01_AXI_wvalid;

  wire [31:0]   M02_AXI_araddr;
  wire [2:0]    M02_AXI_arprot;
  wire [0:0]    M02_AXI_arready;
  wire [0:0]    M02_AXI_arvalid;
  wire [31:0]   M02_AXI_awaddr;
  wire [2:0]    M02_AXI_awprot;
  wire [0:0]    M02_AXI_awready;
  wire [0:0]    M02_AXI_awvalid;
  wire [0:0]    M02_AXI_bready;
  wire [1:0]    M02_AXI_bresp;
  wire [0:0]    M02_AXI_bvalid;
  wire [31:0]   M02_AXI_rdata;
  wire [0:0]    M02_AXI_rready;
  wire [1:0]    M02_AXI_rresp;
  wire [0:0]    M02_AXI_rvalid;
  wire [31:0]   M02_AXI_wdata;
  wire [0:0]    M02_AXI_wready;
  wire [3:0]    M02_AXI_wstrb;
  wire [0:0]    M02_AXI_wvalid;
  
  wire [11:0]   M03_AXI_araddr;
  wire [2:0]    M03_AXI_arprot;
  wire [0:0]    M03_AXI_arready;
  wire [0:0]    M03_AXI_arvalid;
  wire [11:0]   M03_AXI_awaddr;
  wire [2:0]    M03_AXI_awprot;
  wire [0:0]    M03_AXI_awready;
  wire [0:0]    M03_AXI_awvalid;
  wire [0:0]    M03_AXI_bready;
  wire [1:0]    M03_AXI_bresp;
  wire [0:0]    M03_AXI_bvalid;
  wire [31:0]   M03_AXI_rdata;
  wire [0:0]    M03_AXI_rready;
  wire [1:0]    M03_AXI_rresp;
  wire [0:0]    M03_AXI_rvalid;
  wire [31:0]   M03_AXI_wdata;
  wire [0:0]    M03_AXI_wready;
  wire [3:0]    M03_AXI_wstrb;
  wire [0:0]    M03_AXI_wvalid;
  
  wire [11:0]   M04_AXI_araddr;
  wire [2:0]    M04_AXI_arprot;
  wire [0:0]    M04_AXI_arready;
  wire [0:0]    M04_AXI_arvalid;
  wire [11:0]   M04_AXI_awaddr;
  wire [2:0]    M04_AXI_awprot;
  wire [0:0]    M04_AXI_awready;
  wire [0:0]    M04_AXI_awvalid;
  wire [0:0]    M04_AXI_bready;
  wire [1:0]    M04_AXI_bresp;
  wire [0:0]    M04_AXI_bvalid;
  wire [31:0]   M04_AXI_rdata;
  wire [0:0]    M04_AXI_rready;
  wire [1:0]    M04_AXI_rresp;
  wire [0:0]    M04_AXI_rvalid;
  wire [31:0]   M04_AXI_wdata;
  wire [0:0]    M04_AXI_wready;
  wire [3:0]    M04_AXI_wstrb;
  wire [0:0]    M04_AXI_wvalid;
  
  wire [11:0]   M05_AXI_araddr;
  wire [2:0]    M05_AXI_arprot;
  wire [0:0]    M05_AXI_arready;
  wire [0:0]    M05_AXI_arvalid;
  wire [11:0]   M05_AXI_awaddr;
  wire [2:0]    M05_AXI_awprot;
  wire [0:0]    M05_AXI_awready;
  wire [0:0]    M05_AXI_awvalid;
  wire [0:0]    M05_AXI_bready;
  wire [1:0]    M05_AXI_bresp;
  wire [0:0]    M05_AXI_bvalid;
  wire [31:0]   M05_AXI_rdata;
  wire [0:0]    M05_AXI_rready;
  wire [1:0]    M05_AXI_rresp;
  wire [0:0]    M05_AXI_rvalid;
  wire [31:0]   M05_AXI_wdata;
  wire [0:0]    M05_AXI_wready;
  wire [3:0]    M05_AXI_wstrb;
  wire [0:0]    M05_AXI_wvalid;
  
  wire [11:0]   M06_AXI_araddr;
  wire [2:0]    M06_AXI_arprot;
  wire [0:0]    M06_AXI_arready;
  wire [0:0]    M06_AXI_arvalid;
  wire [11:0]   M06_AXI_awaddr;
  wire [2:0]    M06_AXI_awprot;
  wire [0:0]    M06_AXI_awready;
  wire [0:0]    M06_AXI_awvalid;
  wire [0:0]    M06_AXI_bready;
  wire [1:0]    M06_AXI_bresp;
  wire [0:0]    M06_AXI_bvalid;
  wire [31:0]   M06_AXI_rdata;
  wire [0:0]    M06_AXI_rready;
  wire [1:0]    M06_AXI_rresp;
  wire [0:0]    M06_AXI_rvalid;
  wire [31:0]   M06_AXI_wdata;
  wire [0:0]    M06_AXI_wready;
  wire [3:0]    M06_AXI_wstrb;
  wire [0:0]    M06_AXI_wvalid;
  
  wire [11:0]   M07_AXI_araddr;
  wire [2:0]    M07_AXI_arprot;
  wire [0:0]    M07_AXI_arready;
  wire [0:0]    M07_AXI_arvalid;
  wire [11:0]   M07_AXI_awaddr;
  wire [2:0]    M07_AXI_awprot;
  wire [0:0]    M07_AXI_awready;
  wire [0:0]    M07_AXI_awvalid;
  wire [0:0]    M07_AXI_bready;
  wire [1:0]    M07_AXI_bresp;
  wire [0:0]    M07_AXI_bvalid;
  wire [31:0]   M07_AXI_rdata;
  wire [0:0]    M07_AXI_rready;
  wire [1:0]    M07_AXI_rresp;
  wire [0:0]    M07_AXI_rvalid;
  wire [31:0]   M07_AXI_wdata;
  wire [0:0]    M07_AXI_wready;
  wire [3:0]    M07_AXI_wstrb;
  wire [0:0]    M07_AXI_wvalid;
  
  // 10G Interfaces
  // Port 0
  wire sfp_qplllock     ;
  wire sfp_qplloutrefclk;
  wire sfp_qplloutclk   ;
  wire sfp_clk156;
  wire sfp_areset_clk156;      
  wire sfp_gttxreset;          
  wire sfp_gtrxreset;          
  wire sfp_txuserrdy;          
  wire sfp_txusrclk;           
  wire sfp_txusrclk2;          
  wire sfp_reset_counter_done; 
  wire sfp_tx_axis_areset;     
  wire sfp_tx_axis_aresetn;    
  wire sfp_rx_axis_aresetn; 

  wire port0_ready;
  wire block0_lock; 
  wire sfp0_resetdone;
  wire sfp0_txclk322;

  wire port1_ready;
  wire block1_lock; 
  wire sfp1_tx_resetdone;
  wire sfp1_rx_resetdone;
  wire sfp1_txclk322;

  wire port2_ready;
  wire block2_lock; 
  wire sfp2_tx_resetdone;
  wire sfp2_rx_resetdone;
  wire sfp2_txclk322;

  wire port3_ready;
  wire block3_lock; 
  wire sfp3_tx_resetdone;
  wire sfp3_rx_resetdone;
  wire sfp3_txclk322;
 
  wire i2c_scl_o;
  wire i2c_scl_i;
  wire i2c_scl_t;
  wire i2c_sda_o;
  wire i2c_sda_i;
  wire i2c_sda_t;
  
  wire axi_clk;
  wire axi_aresetn;
  wire sys_reset;
  wire fpga_reset_n;
  
  (* ASYNC_REG = "TRUE" *) reg [3:0] core200_reset_sync_n;
  wire axis_resetn;
  wire axi_datapath_resetn;
  wire peripheral_reset;
  
  // Assign interface numbers to ports
  // Odd bits are ports and even bits are DMA
  localparam IF_SFP0 = 8'b00000001;
  localparam IF_SFP1 = 8'b00000100;
  localparam IF_SFP2 = 8'b00010000;
  localparam IF_SFP3 = 8'b01000000;
  
  ///////////////////////////// DEBUG ONLY ///////////////////////////
  // system clk heartbeat 
  reg [27:0] sfp_clk156_count;
  reg [27:0] sfp_clk100_count;  
  reg [7:0]  led;

  supply0 gnd;

  //---------------------------------------------------------------------
  //---------------------------------------------------------------------
  // Misc 
  //---------------------------------------------------------------------
  
  // Debug LEDs  
  // 156MHz clk heartbeat ~ every second
  OBUF led_0_obuf (.I(led[0]), .O(leds[0]));

  // 100MHz clk heartbeat ~ every 1.5 seconds  
  OBUF led_1_obuf (.I(led[1]), .O(leds[1]));
  
  /////////////////////////////////////////////////////////////////////
  // clock generation and buffer, active 0 reset
  IBUF sys_reset_n_ibuf(.I(sys_reset_n), .O(sys_rst_n_c));
  
  // hXDP build diff clk 100MHz && 200 MHz, this IP Core allows to generate single line clk only
  // clk1_out is 100 MHz, clk2_out is 200 MHz
  // TODO(UMV): there is a question about what reset to use ???
  clk_inner_gen clk_gen(.clk_in1( fpga_cry_clk), .reset(~sys_rst_n_c),
                        .clk_out1(clk_100MHz), .clk_out2(clk_200MHz), 
                        .locked(out_clk_locked));

  IBUFDS_GTE2 #(.CLKCM_CFG("TRUE"), .CLKRCV_TRST("TRUE"), .CLKSWING_CFG(2'b11)) 
  IBUFDS_GTE2_inst (
    .O(pci_sys_clk),              // 1-bit output: Refer to Transceiver User Guide
    .ODIV2(),                     // 1-bit output: Refer to Transceiver User Guide
    .CEB(1'b0),                   // 1-bit input: Refer to Transceiver User Guide
    .I(clk_100MHz/*sys_clkp*/),   // 1-bit input: Refer to Transceiver User Guide
    .IB(gnd/*sys_clkn*/)          // 1-bit input: Refer to Transceiver User Guide
  );  
  
  IOBUF i2c_scl_iobuf (
    .I(i2c_scl_o),
    .IO(i2c_clk),
    .O(i2c_scl_i),
    .T(i2c_scl_t)
  );
          
  IOBUF i2c_sda_iobuf (
    .I(i2c_sda_o),
    .IO(i2c_data),
    .O(i2c_sda_i),
    .T(i2c_sda_t)
  );  

  /////////////////////////////////////////////////////////////////////
  
  /*axi_clocking axi_clocking_i (
    .clk_in_p               (fpga_sysclk_p),
    .clk_in_n               (fpga_sysclk_n),
    .clk_200                (clk_200),       // generates 200MHz clk
    .clk_1XX                (clk_1XX),
    .clk_100                (axi_clk),
    .locked                 (clk_200_locked),
    .reset                  (fpga_reset)
  );*/
  
  // todo(UMV) : according 2 that rhis is a reset sybsytem for axi (axi_resetn)
  proc_sys_reset_ip proc_sys_reset_i (
    .slowest_sync_clk(clk_200MHz),          // input wire slowest_sync_clk
    .ext_reset_in(fpga_reset_n),            // input wire ext_reset_in
    .aux_reset_in(1'b1),                    // input wire aux_reset_in
    .mb_debug_sys_rst(1'b0),                // input wire mb_debug_sys_rst
    .dcm_locked(out_clk_locked),            // input wire dcm_locked
    .mb_reset(),                            // output wire mb_reset
    .bus_struct_reset(),                    // output wire [0 : 0] bus_struct_reset
    .peripheral_reset(),                    // output wire [0 : 3] peripheral_reset
    .interconnect_aresetn(),                // output wire [0 : 0] interconnect_aresetn
    .peripheral_aresetn(axis_resetn)        // output wire [0 : 7] peripheral_aresetn
  );

  // todo(UMV) : according 2 that rhis is a reset sybsytem for axi (aresetn_clk_1XX)
  proc_sys_reset_ip proc_sys_reset_i2 (
    .slowest_sync_clk(clk_150MHz),          // input wire slowest_sync_clk ??? //todo(UMV): previously there was clk_1xx
    .ext_reset_in(fpga_reset_n),            // input wire ext_reset_in
    .aux_reset_in(1'b1),                    // input wire aux_reset_in
    .mb_debug_sys_rst(1'b0),                // input wire mb_debug_sys_rst
    .dcm_locked(out_clk_locked),            // input wire dcm_locked
    .mb_reset(),                            // output wire mb_reset
    .bus_struct_reset(),                    // output wire [0 : 0] bus_struct_reset
    .peripheral_reset(),                    // output wire [0 : 3] peripheral_reset
    .interconnect_aresetn(),                // output wire [0 : 0] interconnect_aresetn
    .peripheral_aresetn(aresetn_clk_1XX)    // output wire [0 : 7] peripheral_aresetn
  );

  proc_sys_reset_ip proc_sys_reset_i3 (
    .slowest_sync_clk(axi_clk),             // input wire slowest_sync_clk
    .ext_reset_in(fpga_reset_n),            // input wire ext_reset_in
    .aux_reset_in(1'b1),                    // input wire aux_reset_in
    .mb_debug_sys_rst(1'b0),                // input wire mb_debug_sys_rst
    .dcm_locked(out_clk_locked),            // input wire dcm_locked
    .mb_reset(),                            // output wire mb_reset
    .bus_struct_reset(),                    // output wire [0 : 0] bus_struct_reset
    .peripheral_reset(peripheral_reset),    // output wire [0 : 3] peripheral_reset
    .interconnect_aresetn(),                // output wire [0 : 0] interconnect_aresetn
    .peripheral_aresetn()                   // output wire [0 : 7] peripheral_aresetn
  );

  assign sys_reset = !sys_rst_n_c;

  always @ (posedge clk_200MHz) 
  begin
    if (!fpga_reset_n)  
        core200_reset_sync_n <= 4'h0; 
    else
        core200_reset_sync_n <= #1 {core200_reset_sync_n[2:0],sys_rst_n_c};
  end

  assign axi_clk = clk_100MHz;
  assign fpga_reset_n = !fpga_reset;  
  assign axi_aresetn  = !peripheral_reset;
  assign axi_datapath_resetn = axis_resetn;
    
//-----------------------------------------------------------------------------------------------//
// Network modules                                                                               //
//-----------------------------------------------------------------------------------------------//

  // SFP Port 0
  nf_10g_interface_shared_ip nf_10g_interface_0(   
    //Clocks and resets
    .core_clk(clk_200MHz),
    .refclk_n(xphy_refclk_n),
    .refclk_p(xphy_refclk_p),
    .rst(peripheral_reset), 
    .core_resetn(axis_resetn), 
     
    //Shared logic 
    .clk156_out(sfp_clk156),
    .gtrxreset_out(sfp_gtrxreset),
    .gttxreset_out(sfp_gttxreset),
    .qplllock_out(sfp_qplllock),
    .qplloutclk_out(sfp_qplloutclk),
    .qplloutrefclk_out(sfp_qplloutrefclk),
    .txuserrdy_out(sfp_txuserrdy),
    .txusrclk_out(sfp_txusrclk),
    .txusrclk2_out(sfp_txusrclk2),
    .areset_clk156_out(sfp_areset_clk156),
    .reset_counter_done_out(sfp_reset_counter_done),

        
    //SFP Controls and indications
    .resetdone(sfp0_resetdone), 
    // .tx_fault(sfp0_tx_fault),    
    .tx_abs(sfp0_tx_abs), 
    .tx_disable(sfp0_tx_disable),          

    //AXI Interface
    .m_axis_tdata(axis_i_0_tdata),
    .m_axis_tkeep(axis_i_0_tkeep),
    .m_axis_tuser(axis_i_0_tuser), 
    .m_axis_tvalid(axis_i_0_tvalid),
    .m_axis_tready(axis_i_0_tready),
    .m_axis_tlast(axis_i_0_tlast),
                                     
    .s_axis_tdata(axis_o_0_tdata),
    .s_axis_tkeep(axis_o_0_tkeep),
    .s_axis_tuser(axis_o_0_tuser),
    .s_axis_tvalid(axis_o_0_tvalid),
    .s_axis_tready(axis_o_0_tready),
    .s_axis_tlast(axis_o_0_tlast),
        
    .S_AXI_ACLK(clk_200MHz),
    .S_AXI_ARESETN(axi_datapath_resetn),
    .S_AXI_AWADDR(M04_AXI_awaddr),        
    .S_AXI_AWVALID(M04_AXI_awvalid),       
    .S_AXI_WDATA(M04_AXI_wdata),         
    .S_AXI_WSTRB(M04_AXI_wstrb),         
    .S_AXI_WVALID(M04_AXI_wvalid),        
    .S_AXI_BREADY(M04_AXI_bready),        
    .S_AXI_ARADDR(M04_AXI_araddr),        
    .S_AXI_ARVALID(M04_AXI_arvalid),       
    .S_AXI_RREADY(M04_AXI_rready),        
    .S_AXI_ARREADY(M04_AXI_arready),       
    .S_AXI_RDATA(M04_AXI_rdata),         
    .S_AXI_RRESP(M04_AXI_rresp),         
    .S_AXI_RVALID(M04_AXI_rvalid),        
    .S_AXI_WREADY(M04_AXI_wready),        
    .S_AXI_BRESP(M04_AXI_bresp),         
    .S_AXI_BVALID(M04_AXI_bvalid),        
    .S_AXI_AWREADY(M04_AXI_awready),       
          
   //Serial I/O from/to transceiver
   .rxn(sfp0_rx_n),
   .rxp(sfp0_rx_p),
   .txn(sfp0_tx_n),
   .txp(sfp0_tx_p),
        
   //Interface number
   .interface_number(IF_SFP0)        

  );
  
  assign sfp0_tx_led = sfp0_resetdone ;
  assign sfp0_rx_led = sfp0_resetdone ;

  //SFP Port 1
  nf_10g_interface_ip nf_10g_interface_1(
    //Clocks and resets
    .core_clk(clk_200MHz),
    .core_resetn(axis_resetn), 
       
    //Shared logic 
    .clk156(sfp_clk156),       
    .qplllock(sfp_qplllock),
    .qplloutclk(sfp_qplloutclk),
    .qplloutrefclk(sfp_qplloutrefclk),
    .txuserrdy(sfp_txuserrdy),
    .txusrclk(sfp_txusrclk),
    .txusrclk2(sfp_txusrclk2),
    .areset_clk156(sfp_areset_clk156), 
    .reset_counter_done(sfp_reset_counter_done),  
      
    //SFP Controls and indications
    .tx_abs(sfp1_tx_abs),
    .tx_disable(sfp1_tx_disable),
    // .tx_fault(sfp1_tx_fault),
    .tx_resetdone(sfp1_tx_resetdone),
    .rx_resetdone(sfp1_rx_resetdone),        
    .gtrxreset(sfp_gtrxreset),
    .gttxreset(sfp_gttxreset), 
                  
    //AXI Interface    
    .m_axis_tdata(axis_i_1_tdata),
    .m_axis_tkeep(axis_i_1_tkeep),
    .m_axis_tuser(axis_i_1_tuser),
    .m_axis_tvalid(axis_i_1_tvalid),
    .m_axis_tready(axis_i_1_tready),
    .m_axis_tlast(axis_i_1_tlast),
                                                
    .s_axis_tdata(axis_o_1_tdata),
    .s_axis_tkeep(axis_o_1_tkeep),
    .s_axis_tuser(axis_o_1_tuser),
    .s_axis_tvalid(axis_o_1_tvalid),
    .s_axis_tready(axis_o_1_tready),
    .s_axis_tlast(axis_o_1_tlast),
        
    .S_AXI_ACLK(clk_200MHz),
    .S_AXI_ARESETN(axi_datapath_resetn),
    .S_AXI_AWADDR(M05_AXI_awaddr),        
    .S_AXI_AWVALID(M05_AXI_awvalid),       
    .S_AXI_WDATA(M05_AXI_wdata),         
    .S_AXI_WSTRB(M05_AXI_wstrb),         
    .S_AXI_WVALID(M05_AXI_wvalid),        
    .S_AXI_BREADY(M05_AXI_bready),        
    .S_AXI_ARADDR(M05_AXI_araddr),        
    .S_AXI_ARVALID(M05_AXI_arvalid),       
    .S_AXI_RREADY(M05_AXI_rready),        
    .S_AXI_ARREADY(M05_AXI_arready),       
    .S_AXI_RDATA(M05_AXI_rdata),         
    .S_AXI_RRESP(M05_AXI_rresp),         
    .S_AXI_RVALID(M05_AXI_rvalid),        
    .S_AXI_WREADY(M05_AXI_wready),        
    .S_AXI_BRESP(M05_AXI_bresp),         
    .S_AXI_BVALID(M05_AXI_bvalid),        
    .S_AXI_AWREADY(M05_AXI_awready),           
        
    //Serial I/O from/to transceiver  
    .txp(sfp1_tx_p),
    .txn(sfp1_tx_n),               
    .rxp(sfp1_rx_p),
    .rxn(sfp1_rx_n),
                             
    //Interface number
    .interface_number (IF_SFP1)                       
  );

  assign sfp1_tx_led = sfp1_tx_resetdone ;
  assign sfp1_rx_led = sfp1_rx_resetdone ;
  
  //Identifier Block
  identifier_ip identifier (
    .s_aclk(clk_200MHz),                
    .s_aresetn(axi_datapath_resetn),          
    .s_axi_awaddr(M00_AXI_awaddr),    
    .s_axi_awvalid(M00_AXI_awvalid),  
    .s_axi_awready(M00_AXI_awready),  
    .s_axi_wdata(M00_AXI_wdata),      
    .s_axi_wstrb(M00_AXI_wstrb),      
    .s_axi_wvalid(M00_AXI_wvalid),    
    .s_axi_wready(M00_AXI_wready),    
    .s_axi_bresp(M00_AXI_bresp),      
    .s_axi_bvalid(M00_AXI_bvalid),    
    .s_axi_bready(M00_AXI_bready),    
    .s_axi_araddr(M00_AXI_araddr),   
    .s_axi_arvalid(M00_AXI_arvalid),  
    .s_axi_arready(M00_AXI_arready),  
    .s_axi_rdata(M00_AXI_rdata),      
    .s_axi_rresp(M00_AXI_rresp),      
    .s_axi_rvalid(M00_AXI_rvalid),    
    .s_axi_rready(M00_AXI_rready)    
  );


//////////////////////// DEBUG ONLY ////////////////////////////////
// 100MHz PCIe clk heartbeat ~ every 1.5 seconds
always @ (posedge axi_clk) begin
       sfp_clk100_count <= sfp_clk100_count + 1'b1;
       if (!sfp_clk100_count) begin
            led[1] <= ~led[1];
       end  
end
  
// 156MHz sfp clock heartbeat ~ every second
always @ (posedge sfp_clk156) begin
       sfp_clk156_count <= sfp_clk156_count + 1'b1;
       if (!sfp_clk156_count) begin
            led[0] <= ~led[0];
       end  
end

endmodule


