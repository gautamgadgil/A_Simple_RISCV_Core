module (
    input                       clk,
    input                       reset,
    
);

wire [31:0] instr_addr_wire, instr_data_wire;

// Instruction memory
logic [31:0] instr_mem [0:1023];


// Load text file
initial begin
    $readmemh("firmware.hex", instr_mem);
end

// Instr address from the cpu with the last 2 bits dropped for word addressability (accessed continually)
assign instr_data_wire = instr_mem[instr_addr_wire[31:2]];

rv32i_core u_rv32i_core (
    .clk(clk)
    .reset(reset)
    .instr_data(instr_data_wire)
    .instr_addr(instr_addr_wire)
)
