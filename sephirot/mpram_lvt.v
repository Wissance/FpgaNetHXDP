`include "clog2_function.vh"

module mpram_lvt
 #(  parameter MEMD = 16,
     parameter DATAW = 32,
     parameter nRPORTS = 2,
     parameter nWPORTS = 2,
     parameter RDW = 0,
     parameter IFILE = ""
  )( input clk  ,
     input [nWPORTS - 1 : 0] WEnb,
     input [$clog2(MEMD) * nWPORTS - 1 : 0] WAddr,
     input [DATAW * nWPORTS - 1 : 0] WData,
     input [$clog2(MEMD) * nRPORTS - 1 : 0] RAddr,
     output reg [DATAW * nRPORTS - 1 : 0] RData);

  localparam ADDRW = $clog2(MEMD);
  localparam LVTW  = $clog2(nWPORTS);

  wire [DATAW * nRPORTS * nWPORTS - 1 : 0] RDatai;
  wire [LVTW * nRPORTS  - 1 : 0] RBank;

  lvt #(.MEMD(MEMD),
        .nRPORTS(nRPORTS),
        .nWPORTS(nWPORTS),
        .RDW(RDW),
        .IZERO(IFILE!=""),
        .IFILE(""))
  lvt_i (.clk(clk),
         .WEnb(WEnb),
         .WAddr(WAddr),
         .RAddr(RAddr),
         .RBank(RBank));

  genvar wpi;
  generate
    for (wpi = 0; wpi < nWPORTS; wpi = wpi + 1) begin: RPORTwpi
      mrram #(.MEMD(MEMD),
              .DATAW(DATAW),
              .nRPORTS(nRPORTS),
              .BYPASS(RDW),
              .IZERO(1),
              .IFILE(wpi?"":IFILE ))
      mrram_i (.clk(clk),
               .WEnb(WEnb[wpi]),
               .WAddr(WAddr[wpi * ADDRW +: ADDRW]),
               .WData(WData[wpi * DATAW +: DATAW]),
               .RAddr(RAddr),
               .RData(RDatai[wpi * DATAW * nRPORTS +: DATAW * nRPORTS]));
    end
  endgenerate

  integer i;
  integer j;
  always @* begin
    for(i = 0; i < nRPORTS; i = i + 1) begin
      RData[i * DATAW +: DATAW] = RDatai[RBank[i * LVTW +: LVTW] * nWPORTS * DATAW + i * DATAW +: DATAW];
    end
  end
endmodule
