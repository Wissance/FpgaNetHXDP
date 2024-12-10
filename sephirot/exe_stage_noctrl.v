`include "common.vh"

module exe_stage_noctrl (
  parameter QUEUES_PAGE = 4'b0000,
  input wire clk,
  input wire reset,
  input wire [63:0] syllable,
  input wire [63:0] exe_operand_src,
  input wire [63:0] exe_operand_dst,
  input wire [3:0] exe_address_src,
  input wire [3:0] exe_address_dst,
  input wire [31:0] exe_immediate,
  input wire [1:0] exe_opc,
  input wire [15:0] exe_offset,

  output reg [63:0] exe_result,
  output reg w_e_wb,
  output reg [3:0] wb_reg_add,

  input wire [63:0] mem_data_in,
  output reg [63:0] mem_data_out,
  output reg [63:0] mem_wrt_addr,
  output reg mem_wrt_en,
  output reg [63:0] mem_wrt_mask,
  input wire pc_idle
);

  reg [7:0] opc;
  reg [39:0] opc_string;

  reg [63:0] exe_result_s;
  reg [63:0] exe_operand_dst_s;
  reg [63:0] exe_operand_src_s;
  reg w_e_wb_s;
  reg w_e_mem_s;
  reg [3:0] wb_reg_add_s;
  reg [63:0] mem_data_out_s;

  always @(posedge clk) begin
    opc <= syllable[7:0];
    exe_result_s <= 64'b0;
    mem_data_out_s <= 64'b0;
    mem_wrt_mask <= 64'b0;
    mem_wrt_addr <= exe_operand_dst_s + exe_offset;
    w_e_mem_s <= 1'b0;
    w_e_wb_s <= 1'b0;

    if (syllable[7:0] === ALU64) begin
      case (syllable[7:0])
        NOP_OPC: begin
          exe_result_s <= 64'b0;
          wb_reg_add_s <= 4'b0;
          opc_string <= "_____";
          w_e_mem_s <= 1'b0;
          w_e_wb_s <= 1'b0;
          mem_data_out_s <= 64'b0;
          mem_wrt_mask <= 64'b0;
        end
        ADDI_OPC: begin
          exe_result_s <= exe_operand_dst_s + {{32{1'b0}}, exe_immediate};
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "_ADDI";
        end
        ADD_OPC: begin
          exe_result_s <= exe_operand_dst_s + exe_operand_src_s;
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "__ADD";
        end
        SUBI_OPC: begin
          exe_result_s <= exe_operand_dst_s - {{32{1'b0}}, exe_immediate};
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "_SUBI";
        end
        SUB_OPC: begin
          exe_result_s <= exe_operand_dst_s - exe_operand_src_s;
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "__SUB";
        end
        ORI_OPC: begin
          exe_result_s <= exe_operand_dst_s | {{32{1'b0}}, exe_immediate};
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "__ORI";
        end
        OR_OPC: begin
          exe_result_s <= exe_operand_dst_s | exe_operand_src_s;
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "___OR";
        end
        ANDI_OPC: begin
          exe_result_s <= exe_operand_dst_s & {{32{1'b0}}, exe_immediate};
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "_ANDI";
        end
        AND_OPC: begin
          exe_result_s <= exe_operand_dst_s & exe_operand_src_s;
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "__AND";
        end
        LSHI_OPC: begin
          exe_result_s <= exe_operand_dst_s << exe_immediate;
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "_LSHI";
        end
        LSH_OPC: begin
          exe_result_s <= exe_operand_dst_s << exe_operand_src_s;
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "__LSH";
        end
        RSHI_OPC: begin
          exe_result_s <= exe_operand_dst_s >> exe_immediate;
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "_RSHI";
        end
        RSH_OPC: begin
          exe_result_s <= exe_operand_dst_s >> exe_operand_src_s;
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "__RSH";
        end
        NEG_OPC: begin
          exe_result_s <= ~exe_operand_dst_s + 1;
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "__NEG";
        end
        XORI_OPC: begin
          exe_result_s <= exe_operand_dst_s ^ {{32{1'b0}}, exe_immediate};
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "_XORI";
        end
        XOR_OPC: begin
          exe_result_s <= exe_operand_dst_s ^ exe_operand_src_s;
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "__XOR";
        end
        MOVI_OPC: begin
          exe_result_s <= {{32{1'b0}}, exe_immediate};
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "_MOVI";
        end
        MOV_OPC: begin
          exe_result_s <= exe_operand_src_s;
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "__MOV";
        end
        ARSHI_OPC: begin
          exe_result_s <= $signed(exe_operand_dst_s) >>> exe_immediate;
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "ARSHI";
        end
        ARSH_OPC: begin
          exe_result_s <= $signed(exe_operand_dst_s) >>> exe_operand_src_s;
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "_ARSH";
        end
        SUM_CMP_OPC: begin
          exe_result_s <= exe_operand_src_s + {{32{1'b0}}, exe_immediate};
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "SUMCM";
        end
        SUB_CMP_OPC: begin
          exe_result_s <= exe_operand_src_s - {{32{1'b0}}, exe_immediate};
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "SUBCM";
        end
        OR_CMP_OPC: begin
          exe_result_s <= exe_operand_src_s | {{32{1'b0}}, exe_immediate};
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "ORCMP";
        end
        AND_CMP_OPC: begin
          exe_result_s <= exe_operand_src_s & {{32{1'b0}}, exe_immediate};
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "ANDCM";
        end
        LSH_CMP_OPC: begin
          exe_result_s <= exe_operand_src_s << exe_immediate;
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "LSHCM";
        end
        RSH_CMP_OPC: begin
          exe_result_s <= exe_operand_src_s >> exe_immediate;
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "RSHCM";
        end
        XOR_CMP_OPC: begin
          exe_result_s <= exe_operand_src_s ^ {32'b0, exe_immediate};
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "XORCM";
        end
        default: begin
          exe_result_s <= 64'b0;
          wb_reg_add_s <= 4'b0;
          opc_string <= "_____";
          mem_data_out_s <= 64'b0;
          mem_wrt_mask <= 64'b0;
          w_e_mem_s <= 1'b0;
          w_e_wb_s <= 1'b0;
        end
      endcase
    end
    else if (syllable[7:0] === ALU32) begin
      case (syllable[7:0])
        ADDI32_OPC: begin
          exe_result_s[31:0] <= exe_operand_dst_s[31:0] + exe_immediate;
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "_ADDI";
        end
        ADD32_OPC: begin
          exe_result_s[31:0] <= exe_operand_dst_s[31:0] + exe_operand_src_s[31:0];
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "__ADD";
        end
        SUBI32_OPC: begin
          exe_result_s[31:0] <= exe_operand_dst_s[31:0] - exe_immediate;
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "_SUBI";
        end
        SUB32_OPC: begin
          exe_result_s[31:0] <= exe_operand_dst_s[31:0] - exe_operand_src_s[31:0];
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "__SUB";
        end
        ORI32_OPC: begin
          exe_result_s[31:0] <= exe_operand_dst_s[31:0] | exe_immediate;
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "__ORI";
        end
        OR32_OPC: begin
          exe_result_s[31:0] <= exe_operand_dst_s[31:0] | exe_operand_src_s[31:0];
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "___OR";
        end
        ANDI32_OPC: begin
          exe_result_s[31:0] <= exe_operand_dst_s[31:0] & exe_immediate;
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "_ANDI";
        end
        AND32_OPC: begin
          exe_result_s[31:0] <= exe_operand_dst_s[31:0] & exe_operand_src_s[31:0];
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "__AND";
        end
        LSHI32_OPC: begin
          exe_result_s[31:0] <= exe_operand_dst_s[31:0] << exe_immediate;
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "_LSHI";
        end
        LSH32_OPC: begin
          exe_result_s[31:0] <= exe_operand_dst_s[31:0] << exe_operand_src_s[31:0];
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "__LSH";
        end
        RSHI32_OPC: begin
          exe_result_s[31:0] <= exe_operand_dst_s[31:0] >> exe_immediate;
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "_RSHI";
        end
        RSH32_OPC: begin
          exe_result_s[31:0] <= exe_operand_dst_s[31:0] >> exe_operand_src_s[31:0];
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "__RSH";
        end
        NEG32_OPC: begin
          exe_result_s[31:0] <= -exe_operand_dst_s[31:0];
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "__NEG";
        end
        XORI32_OPC: begin
          exe_result_s[31:0] <= exe_operand_dst_s[31:0] ^ exe_immediate;
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "_XORI";
        end
        XOR32_OPC: begin
          exe_result_s[31:0] <= exe_operand_dst_s[31:0] ^ exe_operand_src_s[31:0];
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "__XOR";
        end
        MOVI32_OPC: begin
          exe_result_s[31:0] <= exe_immediate;
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "_MOVI";
        end
        MOV32_OPC: begin
          exe_result_s[31:0] <= exe_operand_dst_s[31:0];
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "__MOV";
        end
        ARSHI32_OPC: begin
          exe_result_s[31:0] <= $signed(exe_operand_dst_s[31:0]) >>> exe_immediate;
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "ARSHI";
        end
        ARSH32_OPC: begin
          exe_result_s[31:0] <= $signed(exe_operand_dst_s[31:0]) >>> exe_operand_src_s[31:0];
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "_ARSH";
        end
        SUM32_CMP_OPC: begin
          exe_result_s[31:0] <= exe_operand_src_s[31:0] + exe_immediate;
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "SUMCM";
        end
        SUB32_CMP_OPC: begin
          exe_result_s[31:0] <= exe_operand_src_s[31:0] - exe_immediate;
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "SUBCM";
        end
        LSH32_CMP_OPC: begin
          exe_result_s[31:0] <= exe_operand_src_s[31:0] << exe_immediate;
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "LSHCM";
        end
        RSH32_CMP_OPC: begin
          exe_result_s[31:0] <= exe_operand_src_s[31:0] >> exe_immediate;
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "RSHCM";
        end
        XOR32_CMP_OPC: begin
          exe_result_s[31:0] <= exe_operand_src_s[31:0] ^ exe_immediate;
          wb_reg_add_s <= exe_address_dst;
          w_e_wb_s <= 1'b1;
          opc_string <= "XORCM";
        end
        default: begin
          exe_result_s <= 64'b0;
          wb_reg_add_s <= 4'b0;
          opc_string <= "_____";
          mem_data_out_s <= 64'b0;
          mem_wrt_mask <= 64'b0;
          w_e_mem_s <= 1'b0;
          w_e_wb_s <= 1'b0;
        end
      endcase
    end
    else if (syllable[7:0] === MEM) begin
      case (syllable[7:0])
        LDDW_OPC: begin
          exe_result_s = {32'b0, exe_immediate};
          wb_reg_add_s = exe_address_dst;
          w_e_wb_s = 1'b1;
          opc_string = "LDDW_";
        end
        LDXW_OPC: begin
          exe_result_s[31:0] = mem_data_in[31:0];
          wb_reg_add_s = exe_address_dst;
          w_e_wb_s = 1'b1;
          opc_string = "LDXW_";
        end
        LDXH_OPC: begin
          exe_result_s[15:0] = mem_data_in[15:0];
          wb_reg_add_s = exe_address_dst;
          w_e_wb_s = 1'b1;
          opc_string = "LDXHW";
        end
        LDXB_OPC: begin
          exe_result_s[7:0] = mem_data_in[7:0];
          wb_reg_add_s = exe_address_dst;
          w_e_wb_s = 1'b1;
          opc_string = "LDXB_";
        end
        LDXDW_OPC: begin
          exe_result_s = mem_data_in;
          wb_reg_add_s = exe_address_dst;
          w_e_wb_s = 1'b1;
          opc_string = "LDXDW";
        end
        LDX48_OPC: begin
          exe_result_s = {16'b0, mem_data_in[47:0]};
          wb_reg_add_s = exe_address_dst;
          w_e_wb_s = 1'b1;
          opc_string = "LDX48";
        end
        ST48_OPC: begin
          opc_string = "ST48_";
          mem_data_out_s[47:0] = mem_data_in[47:0];
          w_e_mem_s = 1'b1;
          mem_wrt_mask = 64'h0000FFFFFFFFFFFF;
        end
        STW_OPC: begin
          opc_string = "STW__";
          mem_data_out_s[31:0] = mem_data_in[31:0];
          w_e_mem_s = 1'b1;
          mem_wrt_mask = 64'h00000000FFFFFFFF;
        end
        STH_OPC: begin
          opc_string = "_STH_";
          mem_data_out_s[15:0] = mem_data_in[15:0];
          w_e_mem_s = 1'b1;
          mem_wrt_mask = 64'h000000000000ffff;
        end
        STB_OPC: begin
          opc_string = "_STB_";
          mem_data_out_s[7:0] = mem_data_in[7:0];
          w_e_mem_s = 1'b1;
          mem_wrt_mask = 64'h00000000000000ff;
        end
        STDW_OPC: begin
          opc_string = "_STDW";
          mem_data_out_s = mem_data_in;
          w_e_mem_s = 1'b1;
          mem_wrt_mask = 64'hffffffffffffffff;
        end
        STX48_OPC: begin
          opc_string = "STX48";
          mem_data_out_s[47:0] = mem_data_in[47:0];
          w_e_mem_s = 1'b1;
          mem_wrt_mask = 64'h0000ffffffffffff;
        end
        STXW_OPC: begin
          opc_string = "_STXW";
          mem_data_out_s[31:0] = mem_data_in[31:0];
          w_e_mem_s = 1'b1;
          mem_wrt_mask = 64'h00000000ffffffff;
        end
        STXH_OPC: begin
          opc_string = "STXH_";
          mem_data_out_s[15:0] = mem_data_in[15:0];
          w_e_mem_s = 1'b1;
          mem_wrt_mask = 64'h000000000000ffff;
        end
        STXB_OPC: begin
          opc_string = "_STXB";
          mem_data_out_s[7:0] = mem_data_in[7:0];
          w_e_mem_s = 1'b1;
          mem_wrt_mask = 64'h00000000000000ff;
        end
        STXDW_OPC: begin
          opc_string = "STXDW";
          mem_data_out_s = mem_data_in;
          w_e_mem_s = 1'b1;
          mem_wrt_mask = 64'hffffffffffffffff;
        end
        default: begin
          exe_result_s = 64'b0;
          wb_reg_add_s = 4'b0;
          opc_string = "_____";
          mem_data_out_s = 64'b0;
          mem_wrt_mask = 64'b0;
          w_e_mem_s = 1'b0;
          w_e_wb_s = 1'b0;
        end
      endcase
    end
  end

  always @(*) begin
    if (exe_address_src == wb_reg_add_s) begin
      exe_operand_src_s = exe_result_s;
      $display("SRC FORWARDED");
    end
    else begin
      exe_operand_src_s = exe_operand_src;
    end

    if (exe_address_dst == wb_reg_add_s) begin
      exe_operand_dst_s = exe_result_s;
      $display("DST FORWARDED");
    end
    else begin
      exe_operand_dst_s = exe_operand_dst;
    end
  end

  assign exe_result = exe_result_s;
  assign wb_reg_add = wb_reg_add_s;
  assign mem_wrt_en = (pc_idle == 1'b0) ? w_e_mem_s : 1'b0;
  assign w_e_wb = (pc_idle == 1'b0) ? w_e_wb_s : 1'b0;
  assign mem_data_out = (mem_wrt_addr[63:60] == QUEUES_PAGE) ? (mem_data_out_s ^ mem_data_in) : mem_data_out_s;

endmodule
