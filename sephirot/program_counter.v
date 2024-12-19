module PMP_control_unit (
    input wire clk,
    input wire start,
    input wire reset,

    output reg reset_units,
    output reg fetch_flush,
    output reg decode_flush,
    output reg gpr_flush,
    output reg exe_masquerade,

    input wire [15:0] pc_addr,
    input wire pc_add,
    input wire pc_load,
    input wire pc_stop,
    input wire pc_resume,

    output reg [15:0] PC
);

    reg [15:0] pc_s = 16'hFFFF;
    reg [2:0] STATE;

    localparam RESET = 3'b000,
               INCREMENT = 3'b001,
               ADD = 3'b010,
               LOAD = 3'b011,
               STOP = 3'b100,
               TRAP = 3'b101,
               IDLE = 3'b110;

    reg error_s = 0;
    reg stop_toggle = 0;
    wire [4:0] status_vector;

    assign status_vector = {start, pc_add, pc_load, pc_stop, pc_resume};

    always @(posedge clk) begin
        if (reset) begin
            STATE <= RESET;
            pc_s <= 16'h0000;
        end else begin
            case (status_vector)
                5'b10000: begin
                    if (stop_toggle == 1) begin
                        STATE <= STOP;
                    end else begin
                        STATE <= INCREMENT;
                        pc_s <= pc_s + 1;
                    end
                end
                5'b1xxx1: begin
                    STATE <= INCREMENT;
                    pc_s <= pc_s + 1;
                end
                5'b0xxxx: STATE <= IDLE;
                5'b11000: begin
                    STATE <= ADD;
                    pc_s <= pc_s + pc_addr - 1;
                end
                5'b10100: begin
                    STATE <= LOAD;
                    pc_s <= pc_addr - 1;
                end
                5'b10010: begin
                    STATE <= STOP;
                end
                default: STATE <= TRAP;
            endcase
        end
    end

    always @(*) begin
        error_s = 0;
        reset_units = 0;
        fetch_flush = 0;
        decode_flush = 0;
        gpr_flush = 0;
        stop_toggle = 0;
        exe_masquerade = 0;

        case (STATE)
            RESET: reset_units = 1;
            INCREMENT: ;
            ADD, LOAD: begin
                fetch_flush = 1;
                decode_flush = 1;
                gpr_flush = 1;
            end
            STOP: begin
                stop_toggle = 1;
                exe_masquerade = 1;
            end
            TRAP: begin
                error_s = 1;
                reset_units = 1;
            end
            IDLE: reset_units = 1;
        endcase
    end

    assign PC = pc_s;

endmodule
