module rv32i_core(
    input   logic               clk,
    input   logic               reset,
    input   logic   [31:0]      instr_data,
    output  logic   [31:0]      instr_addr
);

wire [31:0] pc_wire, imm_out_wire, rs1_data_wire, rs2_data_wire, alu_result_wire, alu_operand_b_wire, branch_target_wire;
wire [4:0]  rs1_addr_wire, rs2_addr_wire, wb_addr_wire;
wire [3:0]  alu_ctrl_wire;
wire        we_wire, alu_src_wire, alu_zero_wire;


assign instr_addr = pc_wire;                                                    // Pull instr from current PC
assign alu_operand_b_wire = alu_src_wire ? imm_out_wire : rs2_data_wire;        // Operand B is either immidiate or rs2 value
assign branch_target_wire = pc_wire + imm_out_wire;                             // Branch calculation


// FETCH
FetchUnit u_fetch (
    .clk(clk),
    .reset(reset),
    .pc_src(1'b0),                          // Hardcoded to 0 for Phase 1 (no branching yet)
    .branch_target(branch_target_wire),
    .pc(pc_wire)
);

// DECODE
InstrDecode u_decode (
    .instruction(instr_data),               // Comes directly from the module input
    .rs1_addr(rs1_addr_wire),
    .rs2_addr(rs2_addr_wire),
    .wb_addr(wb_addr_wire),
    .we(we_wire),
    .alu_src(alu_src_wire),
    .alu_ctrl(alu_ctrl_wire),
    .imm_out(imm_out_wire)
);

// REGISTER
RegisterFile u_regfile (
    .clk(clk),
    .reset(reset),
    .we(we_wire),
    .wb_addr(wb_addr_wire),
    .wb_data(alu_result_wire),              // The ALU result gets written back
    .rs1_addr(rs1_addr_wire),
    .rs1_data(rs1_data_wire),
    .rs2_addr(rs2_addr_wire),
    .rs2_data(rs2_data_wire)
);

// EXECUTE
alu u_alu (
    .op_a(rs1_data_wire),
    .op_b(alu_operand_b_wire),              // Comes from the assign MUX above
    .ctrl(alu_ctrl_wire),
    .result(alu_result_wire),
    .zero(alu_zero_wire)
);

endmodule
