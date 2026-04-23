module RegisterFile(
    input            clk,                  
    input            reset,
    input            we,                  // Write enable
    input   [4:0]    wb_addr,             // Write back address
    input   [31:0]   wb_data,             // Write back port
    input   [4:0]    rs1_addr,            // Read port 1 address
    output  [31:0]   rs1_data,            // Read port 1
    input   [4:0]    rs2_addr,             // Read port 2 address
    output  [31:0]   rs2_data,            // Read port 2
);

logic [31:0] RegFile [0:31];              // RegFile array

// Asyncronous Read
assign rs1_data = (rs1_addr == 5'b0) ? 32'b0 : RegFile [rs1_addr];
assign rs2_data = (rs2_addr == 5'b0) ? 32'b0 : RegFile [rs2_addr];

// Syncronous Write
always_ff @ (posedge clk, posedge reset) begin
    // Wipe all registers if reset is true
    if (reset) begin
        for (int i = 0; i < 32; i = i + 1) begin
            RegFile [i] <= 32'b0;
        end
    end
    // Only write to RegFile if write enable is true and write address is not 0
    else if (we) begin
        if (wb_addr != 5'b0) begin
            RegFile[wb_addr] <= wb_data;
        end
    end
end

endmodule