`include "clog2_function.vh"

module mpram
 #(  parameter MEMD = 16,
     parameter DATAW = 32,
     parameter nRPORTS = 3 ,
     parameter nWPORTS = 2 ,
     parameter IZERO = 0 ,
     parameter IFILE = ""
  )( input clk,
     input [nWPORTS - 1 : 0] WEnb,
     input [$clog2(MEMD) * nWPORTS - 1 : 0] WAddr,
     input [DATAW * nWPORTS - 1 : 0] WData,
     input [$clog2(MEMD) * nRPORTS - 1 : 0] RAddr,
     output reg [DATAW * nRPORTS - 1 : 0] RData
  );

  localparam ADDRW = $clog2(MEMD);
  integer i;
  reg [DATAW - 1 : 0] mem [0 : MEMD - 1];
  
  initial begin
    if (IZERO) begin
      for (i = 0; i < MEMD; i = i + 1) begin
        mem[i] = {DATAW{1'b0}};
      end
    end
    else begin
      if (IFILE != "") begin
        $readmemh({IFILE,".hex"}, mem);
      end
    end
  end

  always @(posedge clk) begin
      for (i = 0; i < nWPORTS; i = i + 1)
        if (WEnb[i]) begin
          mem[WAddr[i * ADDRW +: ADDRW]] <= WData[i * DATAW +: DATAW];
        end
      end

      for (i = 0; i < nRPORTS; i = i + 1) begin
        RData[i * DATAW +: DATAW] <= mem[RAddr[i * ADDRW +: ADDRW]];
      end
  end
endmodule
