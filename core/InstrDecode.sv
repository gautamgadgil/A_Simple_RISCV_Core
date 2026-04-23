module InstrDecode(
    input               [31:0]       instruction,
    output              [4:0]        rs1_addr,              // Register 1
    output              [4:0]        rs2_addr,              // Register 2
    output              [4:0]        wb_addr,               // Write-back register
    output     logic                 we,                    // Write enable
    output     logic                 alu_src,               // R/I multiplexing signal
    output     logic    [3:0]        alu_ctrl,              // ALU code
    output              [31:0]       imm_out
);

assign opcode           = instruction [6:0];
assign wb_addr          = instruction [11:7];
assign func3_func7      = {instruction [14:12], instruction [31:25]};
assign rs1_addr         = instruction [19:15];
assign rs2_addr         = instruction [24:20];
//assign func7          = instruction [31:25];
assign imm_out          = {{20{instruction [31]}}, instruction [31:20]};

always_comb begin
    case (opcode)
        // R-Type instructions
        7'b0110011: begin
            alu_src = 0;
            we      = 1'b1;
            case (func3_func7)
                10'b0000000000: begin
                    alu_ctrl = 4'd1;        // Add
                end
                10'b0000100000: begin
                    alu_ctrl = 4'd2;        // Sub
                end
                10'b0010000000: begin
                    alu_ctrl = 4'd6;        // SLL
                end
                10'b0100000000: begin
                    alu_ctrl = 4'd9;        // SLT
                end
                10'b0110000000: begin
                    alu_ctrl = 4'd10;       // SLTU
                end
                10'b1000000000: begin
                    alu_ctrl = 4'd5;        // XOR
                end
                10'b1010000000: begin
                    alu_ctrl = 4'd7;        // SRL
                end 
                10'b1010100000: begin
                    alu_ctrl = 4'd8;        // SRA
                end 
                10'b1100000000: begin
                    alu_ctrl = 4'd4;        // OR
                end
                10'b1110000000: begin
                    alu_ctrl = 4'd3;        // AND
                end
                default: alu_ctrl = 4'd0;
            endcase
        end
        // I-Type instructions
        7'b0010011: begin
            alu_src = 1;
            we      = 1'b1; 
            case (instruction [14:12])
                3'b000: begin
                    alu_ctrl = 4'd1;        // Add
                end
                3'b001: begin
                    if (instruction [31:25] == 7'b0) begin
                        alu_ctrl = 4'd6;        // SLL
                    end
                    else begin
                        alu_ctrl = 4'd0;
                    end
                end
                3'b010: begin
                    alu_ctrl = 4'd9;        // SLT
                end
                3'b011: begin
                    alu_ctrl = 4'd10;       // SLTU
                end
                3'b100: begin
                    alu_ctrl = 4'd5;        // XOR
                end
                3'b101: begin
                    if (instruction [31:25] == 7'b0) begin
                        alu_ctrl = 4'd7;        // SRL
                    end
                    else if (instruction [31:25] == 7'b0100000) begin
                        alu_ctrl = 4'd8;        // SRA
                    end
                    else
                        alu_ctrl = 4'd0;
                    end
                end 
                3'b110: begin
                    alu_ctrl = 4'd4;        // OR
                end
                3'b111: begin
                    alu_ctrl = 4'd3;        // AND
                end
                default: alu_ctrl = 4'd0;
            endcase
        end
        default: begin
            alu_src  = 0;
            we       = 0;
            alu_ctrl = 4'd0;
        end
    endcase
end

endmodule        
