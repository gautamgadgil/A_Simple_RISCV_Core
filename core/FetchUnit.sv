module FetchUnit(
    input                       clk,
    input                       reset,
    input                       pc_src,
    input             [31:0]    branch_target,
    output    logic   [31:0]    pc
);

always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
        pc <= 32'b0;
    end
    else begin
        if (pc_src) begin
            pc <= branch_target;
        end
        else begin
            pc <= pc + 4;
        end
    end
end

endmodule
