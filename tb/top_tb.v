`timescale 1ns / 1ps

module top_tb;

    reg  clk;
    reg  rst;
    wire led;

    // Instantiate the Unit Under Test (UUT)
    top uut (
        .clk(clk),
        .rst(rst),
        .led(led)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end

    // Test sequence
    initial begin
        // Initialize Inputs
        rst = 1;
        
        // Wait 100 ns for global reset to finish
        #100;
        rst = 0;
        
        // Add stimulus here
        #500;
        
        $display("Test completed.");
        $finish;
    end

    // Dump waves for gtkwave
    initial begin
        $dumpfile("top_tb.fst");
        $dumpvars(0, top_tb);
    end

endmodule
