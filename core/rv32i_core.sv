module rv32i_core(
    input   logic               clk,
    input   logic               reset,
    input   logic   [31:0]      instr_data,
    output  logic   [31:0]      instr_addr,
    input   logic   [31:0]      dmem_rdata,              // Data memory read port
    output  logic               dmem_we,                 // Data memory write enable
    output  logic   [31:0]      dmem_addr,               // Data memory address
    output  logic   [31:0]      dmem_wdata               // Data memory write port
);

wire [31:0] pc_wire, imm_out_wire, rs1_data_wire, rs2_data_wire, alu_result_wire, alu_operand_b_wire, branch_target_wire;
wire [4:0]  rs1_addr_wire, rs2_addr_wire, wb_addr_wire;
wire [3:0]  alu_ctrl_wire;
wire        we_wire, alu_src_wire, alu_zero_wire;
wire        branch_wire, jump_wire, pc_src_wire;
wire        jalr_wire;
wire        mem_we_wire, mem_to_reg_wire;

logic       branch_taken;


assign instr_addr = pc_wire;                                                    // Pull instr from current PC
assign alu_operand_b_wire = alu_src_wire ? imm_out_wire : rs2_data_wire;        // Operand B is either immidiate or rs2 value

// Branch target calculation
wire [31:0] target_base_wire = jalr_wire ? rs1_data_wire : pc_wire;
wire [31:0] raw_target_wire  = target_base_wire + imm_out_wire;

// Only JALR forces the LSB to 0 per the RISC-V spec
// JAL and Branches are naturally aligned because their immediates end in 0
assign branch_target_wire = jalr_wire ? (raw_target_wire & 32'hFFFFFFFE) : raw_target_wire;

// Check branch condition
always_comb begin
    branch_taken = 1'b0; // Default branch not taken
    if (branch_wire) begin
        case (instr_data[14:12])
            3'b000: branch_taken = alu_zero_wire;    // BEQ
            3'b001: branch_taken = ~alu_zero_wire;   // BNE
            default: branch_taken = 1'b0;
        endcase
    end
end

// Update pc_src_wire to indicate fetcher to fetch branch target
assign pc_src_wire = jump_wire | branch_taken;

wire [31:0] pc_plus_4_wire;                                       // Used to store current address+1 for JAL instruction
assign pc_plus_4_wire = pc_wire + 4;

// Writeback MUX: If fetching data, chosse data mem read port, otherwise if jumping, choose PC+4 or use ALU result
wire [31:0] writeback_data_wire;
assign writeback_data_wire = mem_to_reg_wire ? dmem_rdata : jump_wire ? pc_plus_4_wire : alu_result_wire;

// Data memory port assignments
assign dmem_addr  = alu_result_wire;
assign dmem_wdata = rs2_data_wire;
assign dmem_we    = mem_we_wire;

// FETCH
FetchUnit u_fetch (
    .clk(clk),
    .reset(reset),
    .pc_src(pc_src_wire),
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
    .imm_out(imm_out_wire),
    .branch(branch_wire),
    .jump(jump_wire),
    .jalr(jalr_wire),
    .mem_we(mem_we_wire),
    .mem_to_reg(mem_to_reg_wire)
);

// REGISTER
RegisterFile u_regfile (
    .clk(clk),
    .reset(reset),
    .we(we_wire),
    .wb_addr(wb_addr_wire),
    .wb_data(writeback_data_wire),              // The ALU result gets written back
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
