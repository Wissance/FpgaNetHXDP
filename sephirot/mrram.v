module mrram
 #(  parameter MEMD = 16,
     parameter DATAW = 32,
     parameter nRPORTS = 3,
     parameter BYPASS = 1,
     parameter IZERO = 0,
     parameter IFILE = ""
  )( input clk,
     input WEnb,
     input [`log2(MEMD) - 1 : 0] WAddr,
     input [DATAW - 1 : 0] WData,
     input [`log2(MEMD) * nRPORTS - 1 : 0] RAddr,
     output reg [DATAW * nRPORTS - 1 : 0] RData);

  localparam ADDRW = `log2(MEMD);
  genvar rpi;
  
  generate
    for (rpi = 0; rpi < nRPORTS; rpi = rpi + 1) begin: RPORTrpi
      dpram  #( .MEMD(MEMD),
                .DATAW(DATAW,
                .BYPASS(BYPASS),
                .IZERO(IZERO),
                .IFILE(IFILE))
      dpram_i ( .clk(clk),
                .WEnb(WEnb),
                .WAddr(WAddr),
                .WData(WData),
                .RAddr(RAddr[rpi * ADDRW +: ADDRW]),
                .RData(RData[rpi * DATAW +: DATAW]));
    end
  endgenerate
endmodule
