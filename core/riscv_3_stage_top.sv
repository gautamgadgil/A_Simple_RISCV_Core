module riscv_3_stage_top(
    input                       clk,
    input                       reset,

    output logic    [5:0]       leds                // LED output for testing on the Tang Nano 20k
);

wire [31:0] instr_addr_wire, instr_data_wire;
wire [31:0] dmem_addr_wire, dmem_wdata_wire, dmem_rdata_wire;
wire        dmem_we_wire;

// Instruction memory
logic [31:0] instr_mem [0:1023];

// Data memory
logic [31:0] data_mem [0:1023];

// Load text file
initial begin
    $readmemh("firmware.hex", instr_mem);
end

// Asyncronous read instr with instr address from the cpu with the last 2 bits dropped for word addressability (accessed continually)
assign instr_data_wire = instr_mem[instr_addr_wire[31:2]];

// Async read data with data address from the cpu same as instr address
assign dmem_rdata_wire = data_mem[dmem_addr_wire[31:2]];

// Syncronous write to data memory
always_ff @(posedge clk) begin
    if (dmem_we_wire) begin
        data_mem [dmem_addr_wire[31:2]] <= dmem_wdata_wire; 
    end
end

rv32i_core u_rv32i_core (
    .clk(clk),
    .reset(reset),
    .instr_data(instr_data_wire),
    .instr_addr(instr_addr_wire),
    .dmem_rdata(dmem_rdata_wire),
    .dmem_we(dmem_we_wire),
    .dmem_addr(dmem_addr_wire),
    .dmem_wdata(dmem_wdata_wire)
);

// Memory mapped I/O for the Tang Nano 20k
always_ff @(posedge clk) begin
    if (reset) begin
        leds <= 6'b111111;                      // Turn off all LEDs at reset
    end
    else if (dmem_we_wire && dmem_addr_wire == 32'h00000000) begin
        leds <= ~dmem_wdata_wire[5:0];          // LEDs are last 6 bits of data written to address 0
    end
end

endmodule
