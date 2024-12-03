`include "clog2_function.vh"

module lvt
#(
  parameter MEMD = 16,
  parameter nRPORTS = 2,
  parameter nWPORTS = 2,
  parameter RDW = 0,
  parameter IZERO = 1,
  parameter IFILE = ""
)
(
  input clk,
  input [nWPORTS - 1 : 0] WEnb,
  input [$clog2(MEMD) * nWPORTS - 1 : 0] WAddr,
  input [$clog2(MEMD) * nRPORTS - 1 : 0] RAddr,
  output [$clog2(nWPORTS) * nRPORTS - 1 : 0] RBank
);

  localparam ADDRW = $clog2(MEMD);
  localparam LVTW = $clog2(nWPORTS);

  reg [LVTW * nWPORTS - 1 : 0] WData;
  integer i;
  
  (* ramstyle = "logic" *) reg [LVTW - 1 : 0] mem [0 : MEMD - 1];
  initial begin
    if (IZERO) begin
      for (i = 0; i < MEMD; i = i + 1) begin
        mem[i] = {LVTW{1'b0}};
      end
    end
    else if (IFILE != "") begin
      $readmemh({IFILE,".hex"}, mem);
    end
  end
  
  always @* begin
    for (i = 0; i < nWPORTS; i = i + 1) begin
      WData[i * LVTW +: LVTW] = i;
    end
  end
  
  /*
  WData[0 * LVTW +: LVTW] = 0;
  WData[1 * LVTW +: LVTW] = 1;
  WData[2 * LVTW +: LVTW] = 2;
  WData[3 * LVTW +: LVTW] = 3;
  ...
  */

  always @(posedge clk) begin
    for (i = 0; i < nWPORTS; i = i + 1) begin
      if (WEnb[i]) begin
        if (RDW) begin
          mem[WAddr[i * ADDRW +: ADDRW]] = WData[i * LVTW +: LVTW];
        end
        else begin
          mem[WAddr[i * ADDRW +: ADDRW]] <= WData[i * LVTW +: LVTW];
        end
      end
    end
    for (i = 0; i < nRPORTS; i = i + 1) begin
      if (RDW) begin
        RBank[i * LVTW +: LVTW] = mem[RAddr[i * ADDRW +: ADDRW]];
      end
      else begin
        RBank[i * LVTW +: LVTW] <= mem[RAddr[i * ADDRW +: ADDRW]];
      end
    end
  end

endmodule
