module lane_noctrl (
    input wire clk,
    input wire reset,
    input wire pc_idle,
    input wire decode_flush,
    input wire [63:0] syllable,
    input wire [3:0] add_src,
    input wire [3:0] add_dst,
    input wire [63:0] gr_src_cont,
    input wire [63:0] gr_dst_cont,

    input wire [3:0] addr_wb_0,
    input wire [3:0] addr_wb_1,
    input wire [3:0] addr_wb_2,
    input wire [3:0] addr_wb_3,

    input wire wb_wrt_en_0,
    input wire wb_wrt_en_1,
    input wire wb_wrt_en_2,
    input wire wb_wrt_en_3,

    input wire [63:0] cont_wb_0,
    input wire [63:0] cont_wb_1,
    input wire [63:0] cont_wb_2,
    input wire [63:0] cont_wb_3,

    output reg [63:0] exe_result,
    output reg w_e_wb,
    output reg [3:0] wb_reg_add,

    input wire [63:0] mem_data_in,
    output reg [63:0] mem_data_out,
    output reg [63:0] mem_read_addr,
    output reg [63:0] mem_wrt_addr,
    output reg mem_wrt_en,
    output reg [63:0] mem_wrt_mask
);

    reg [63:0] exe_syllable_s = 64'b0;
    reg [63:0] exe_operand_src_s = 64'b0;
    reg [63:0] exe_operand_dst_s = 64'b0;
    reg [31:0] exe_immediate_s = 32'b0;
    reg [1:0] exe_opc_s = 2'b0;
    reg [3:0] exe_dest_reg_s = 4'b0;
    reg [15:0] exe_offset_s = 16'b0;
    reg [3:0] add_src_to_exe = 4'b0;
    reg [3:0] add_dst_to_exe = 4'b0;

    reg [3:0] exe_out_dst_addr_s = 4'b0;
    reg [63:0] exe_out_result_s = 64'b0;

    reg flush_pipeline_s;

    decode_stage ID_STAGE (
        .clk(clk),
        .reset(reset),
        .decode_flush(decode_flush),
        .syllable(syllable),
        .src_reg_add_in(add_src),
        .src_reg_add_out(add_src_to_exe),
        .src_reg_cont(gr_src_cont),
        .dst_reg_add_in(add_dst),
        .dst_reg_add_out(add_dst_to_exe),
        .dst_reg_cont(gr_dst_cont),
        .addr_wb_0(addr_wb_0),
        .addr_wb_1(addr_wb_1),
        .addr_wb_2(addr_wb_2),
        .addr_wb_3(addr_wb_3),
        .wb_wrt_en_0(wb_wrt_en_0),
        .wb_wrt_en_1(wb_wrt_en_1),
        .wb_wrt_en_2(wb_wrt_en_2),
        .wb_wrt_en_3(wb_wrt_en_3),
        .cont_wb_0(cont_wb_0),
        .cont_wb_1(cont_wb_1),
        .cont_wb_2(cont_wb_2),
        .cont_wb_3(cont_wb_3),
        .exe_wb_addr(exe_out_dst_addr_s),
        .exe_wb_result(exe_out_result_s),
        .exe_operand_src(exe_operand_src_s),
        .exe_syllable(exe_syllable_s),
        .exe_operand_dst(exe_operand_dst_s),
        .exe_immediate(exe_immediate_s),
        .exe_opc(exe_opc_s),
        .exe_dest_reg(exe_dest_reg_s),
        .exe_offset(exe_offset_s),
        .dbus_addr_read(mem_read_addr)
    );

    exe_stage_noctrl IE_STAGE (
        .clk(clk),
        .reset(reset),
        .pc_idle(pc_idle),
        .syllable(exe_syllable_s),
        .exe_operand_src(exe_operand_src_s),
        .exe_operand_dst(exe_operand_dst_s),
        .exe_address_src(add_src_to_exe),
        .exe_address_dst(add_dst_to_exe),
        .exe_immediate(exe_immediate_s),
        .exe_opc(exe_opc_s),
        .exe_offset(exe_offset_s),
        .exe_result(exe_out_result_s),
        .w_e_wb(w_e_wb),
        .wb_reg_add(exe_out_dst_addr_s),
        .mem_data_in(mem_data_in),
        .mem_data_out(mem_data_out),
        .mem_wrt_addr(mem_wrt_addr),
        .mem_wrt_en(mem_wrt_en),
        .mem_wrt_mask(mem_wrt_mask)
    );

    always @* begin
        exe_result = exe_out_result_s;
        wb_reg_add = exe_out_dst_addr_s;
    end

endmodule
