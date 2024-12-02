module ram (
  input clk,
  input reset,
  
  input [7:0] read_add_0,
  input [7:0] read_add_1,
  input [7:0] read_add_2,
  input [7:0] read_add_3,

  output [63:0] data_out_0,
  output [63:0] data_out_1,
  output [63:0] data_out_2,
  output [63:0] data_out_3,

  input [7:0] wrt_add_0,
  input [7:0] wrt_add_1,
  input [7:0] wrt_add_2,
  input [7:0] wrt_add_3,

  input [7:0] wrt_en_0,
  input [7:0] wrt_en_1,
  input [7:0] wrt_en_2,
  input [7:0] wrt_en_3,

  input [7:0] data_in_0,  
  input [7:0] data_in_1, 
  input [7:0] data_in_2, 
  input [7:0] data_in_3);

  reg [31:0] ram_lower [0:255];
  reg [31:0] ram_upper [0:255];

  always @ (posedge clk) begin
    if (reset == 1'b1) begin
      for (i = 0; i < 256; i = i + 1) begin
        ram_lower[i] <= 32'h00000000;
        ram_upper[i] <= 32'h00000000;
      end
    end
    
    else begin
      data_out_0[31:0] <= ram_lower[read_add_0];
      data_out_0[63:32] <= ram_upper[read_add_0];
      data_out_1[31:0] <= ram_lower[read_add_1];
      data_out_1[63:32] <= ram_upper[read_add_1];
      data_out_2[31:0] <= ram_lower[read_add_2];
      data_out_2[63:32] <= ram_upper[read_add_2];
      data_out_3[31:0] <= ram_lower[read_add_3];
      data_out_3[63:32] <= ram_upper[read_add_3];
      
      if (wrt_en_0 = 1'b1) begin
        ram_lower[wrt_add_0] <= data_in_0[31:0];
        ram_upper[wrt_add_0] <= data_in_0[63:32];
      end

      if (wrt_en_1 = 1'b1) begin
        ram_lower[wrt_add_1] <= data_in_1[31:0];
        ram_upper[wrt_add_1] <= data_in_1[63:32];
      end
      
      if (wrt_en_2 = 1'b1) begin
        ram_lower[wrt_add_2] <= data_in_2[31:0];
        ram_upper[wrt_add_2] <= data_in_2[63:32];
      end
      
      if (wrt_en_3 = 1'b1) begin
        ram_lower[wrt_add_3] <= data_in_3[31:0];
        ram_upper[wrt_add_3] <= data_in_3[63:32];
      end
    end
  end
endmodule
