module alu(
    input           [31:0]   op_a,
    input           [31:0]   op_b,
    input           [3:0]    ctrl,
    output  logic   [31:0]   result,
    output  logic            zero      
);

localparam ADD  = 4'd1;
localparam SUB  = 4'd2;
localparam AND  = 4'd3;
localparam OR   = 4'd4;
localparam XOR  = 4'd5;
localparam SLL  = 4'd6;
localparam SRL  = 4'd7;
localparam SRA  = 4'd8;
localparam SLT  = 4'd9;
localparam SLTU = 4'd10;

wire [4:0] shamt = op_b[4:0];       // For iverilog

always_comb begin
    case (ctrl)
        ADD: begin
            result = op_a + op_b;
        end
        SUB: begin
            result = op_a - op_b;
        end
        AND: begin
            result = op_a & op_b;
        end
        OR: begin
            result = op_a | op_b;
        end
        XOR: begin
            result = op_a ^ op_b;
        end
        SLL: begin
            result = op_a << shamt;
        end
        SRL: begin
            result = op_a >> shamt;
        end
        SRA: begin
            result = $signed(op_a) >>> $signed(shamt);
        end
        SLT: begin
            if ($signed(op_a) < $signed(op_b)) begin
                result = 32'b1;
            end
            else begin
                result = 32'b0;
            end
        end
        SLTU: begin
            if (op_a < op_b) begin
                result = 32'b1;
            end
            else begin
                result = 32'b0;
            end
        end
        default: result = 32'b0;
    endcase

    zero = (result == 32'b0);
end

endmodule
