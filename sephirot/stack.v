module stack #(
  parameter value_size = 64,
  parameter max_entries = 64)
(
  input clk,
  input reset,

  input [63:0] read_add_0,
  input [63:0] read_add_1,
  input [63:0] read_add_2,
  input [63:0] read_add_3,

  output reg [63:0] data_out_0,
  output reg [63:0] data_out_1,
  output reg [63:0] data_out_2,
  output reg [63:0] data_out_3,

  input [63:0] wrt_add_0,
  input [63:0] wrt_add_1,
  input [63:0] wrt_add_2,
  input [63:0] wrt_add_3,

  input wrt_en_0,
  input wrt_en_1,
  input wrt_en_2,
  input wrt_en_3,

  input [63:0] data_in_0,
  input [63:0] data_in_1,
  input [63:0] data_in_2,
  input [63:0] data_in_3
);

  wire [3 : 0] Wenb;
  wire [4 * log2(max_entries) - 1 : 0] WAddr;
  wire [4 * value_size - 1 : 0] WData;
  wire [4 * log2(max_entries) - 1 : 0] RAddr;
  wire [4 * value_size - 1 : 0] RData;

  assign Wenb = {wrt_en_3, wrt_en_2, wrt_en_1, wrt_en_0};
  assign WAddr = {wrt_add_3, wrt_add_2, wrt_add_1, wrt_add_0};
  assign WData = {data_in_3, data_in_2, data_in_1, data_in_0};
  assign RAddr = {read_add_3, read_add_2, read_add_1, read_add_0};
  
  mpram_lvt #(.MEMD(max_entries),
              .DATAW(value_size),
              .nRPORTS(4),
              .nWPORTS(4),
              .RDW(0),
              .IFILE(""))
  mpram_lvt_i (.clk(clk),
               .WEnb(WEnb),
               .WAddr(WAddr),
               .WData(WData),
               .RAddr(RAddr),
               .RData(RData));
  
  assign data_out_0 = RData[0 * value_size +: value_size];
  assign data_out_1 = RData[1 * value_size +: value_size];
  assign data_out_2 = RData[2 * value_size +: value_size];
  assign data_out_3 = RData[3 * value_size +: value_size];

endmodule
