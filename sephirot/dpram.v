`include "clog2_function.vh"

module dpram
 #(  parameter MEMD = 16,
     parameter DATAW = 32,
     parameter BYPASS = 1,
     parameter IZERO = 0,
     parameter IFILE = ""
  )( input clk,
     input WEnb,
     input [$clog2(MEMD) - 1:0] WAddr,
     input [DATAW - 1:0] WData,
     input [$clog2(MEMD) - 1:0] RAddr,
     output reg [DATAW - 1:0] RData
  );

  wire [DATAW-1:0] RData_i;
  mpram #(.MEMD(MEMD),
          .DATAW  (DATAW),
          .nRPORTS(1),
          .nWPORTS(1),
          .IZERO(IZERO),
          .IFILE(IFILE))
  dpram_inst (.clk(clk),
              .WEnb(WEnb),
              .WAddr(WAddr),
              .WData(WData),
              .RAddr(RAddr),
              .RData(RData_i));

  reg WEnb_r;
  reg [$clog2(MEMD) - 1 : 0] WAddr_r;
  reg [$clog2(MEMD) - 1 : 0] RAddr_r;
  reg [DATAW - 1 : 0] WData_r;
  
  always @(posedge clk) begin
    WEnb_r <= WEnb ;
    WAddr_r <= WAddr;
    RAddr_r <= RAddr;
    WData_r <= WData;
  end
  
  wire bypass1, bypass2;
  assign bypass1 = (BYPASS >= 1) && WEnb_r && (WAddr_r == RAddr_r);
  assign bypass2 = (BYPASS == 2) && WEnb && (WAddr == RAddr_r);

  always @*
    if (bypass2) begin
      RData = WData;
    end
    else if (bypass1) begin
      RData = WData_r;
    end
    else begin
      RData = RData_i;
    end
endmodule
