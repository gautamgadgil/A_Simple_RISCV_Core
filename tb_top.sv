`timescale 1ns/1ps

module tb_top;
    // Simulation Signals
    logic clk;
    logic reset;
    wire [5:0] leds_wire;

    // Instantiate wrapper
    riscv_3_stage_top u_dut (
        .clk(clk),
        .reset(reset),
        .leds(leds_wire)
    );

    // Clock Generation: 50 MHz (20ns period)
    initial begin
        clk = 0;
        forever #10 clk = ~clk; 
    end

    // The Test Sequence
    initial begin
        // Record all wires for GTKWave
        $dumpfile("tb_top.vcd");
        $dumpvars(0, tb_top);

        $display("Starting RV32I Simulation...");

        // Pulse reset
        reset = 1;
        #25;       
        reset = 0;

        // 250 clock cycles
        #5000;
        
        $display("Simulation Timeout Reached.");
        $finish; // End
    end

endmodule
