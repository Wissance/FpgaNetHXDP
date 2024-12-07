`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.12.2024 10:49:54
// Design Name: 
// Module Name: axi_clocking
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


`timescale 1ps / 1ps
(* dont_touch = "yes" *)
module axi_clocking (
   // Inputs
  input clk_in_p,
  input clk_in_n,
  input reset,
  // Status outputs
  
  // IBUFDS 200MHz  
  output locked, 
  //output clk_100, 
  output clk_200, 
  output clk_100,
  output clk_1XX 
   
);

  // Signal declarations
  wire s_axi_dcm_aclk0;
  wire clkfbout;
  wire resetn;
  wire clkin1;
  
  assign resetn= ~reset;  

  // 200MHz differencial into single-rail     
  IBUFDS clkin1_buf
   (.O  (clkin1),
    .I  (clk_in_p),
    .IB (clk_in_n)
    );

clk_wiz_ip clk_wiz_i
       (
       // Clock in ports
        .clk_in1(clkin1),      // input clk_in1
        // Clock out ports
        .clk_out1(clk_200),     // output clk_out1
        .clk_out2(clk_1XX),     // output clk_out1
        .clk_out3(clk_100),     // output clk_out1
        // Status and control signals
        .resetn(resetn), // input resetn
        .locked(locked));

endmodule
