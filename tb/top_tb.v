`timescale 1ns / 1ps

module top_tb;

    // Inputs
    reg a;
    reg b;

    // Outputs
    wire ld0;
    wire ld1;
    wire ld2;
    wire ld3;
    wire ld4;

    // Instantiate the Unit Under Test (UUT)
    top uut (
        .a(a),
        .b(b),
        .ld0(ld0),
        .ld1(ld1),
        .ld2(ld2),
        .ld3(ld3),
        .ld4(ld4)
    );

    // Test sequence
    initial begin
        // Initialize Inputs
        a = 0;
        b = 0;

        $display("Time\t a b | ld0(AND) ld1(OR) ld2(NOT a) ld3(NAND) ld4(XOR)");
        $display("---------------------------------------------------------");

        // Wait a bit and display initial state
        #10;
        $display("%0t\t %b %b | %b        %b       %b          %b         %b", $time, a, b, ld0, ld1, ld2, ld3, ld4);

        // Apply stimulus
        a = 0; b = 1; #10;
        $display("%0t\t %b %b | %b        %b       %b          %b         %b", $time, a, b, ld0, ld1, ld2, ld3, ld4);

        a = 1; b = 0; #10;
        $display("%0t\t %b %b | %b        %b       %b          %b         %b", $time, a, b, ld0, ld1, ld2, ld3, ld4);

        a = 1; b = 1; #10;
        $display("%0t\t %b %b | %b        %b       %b          %b         %b", $time, a, b, ld0, ld1, ld2, ld3, ld4);

        #10;
        $display("Test completed.");
        $finish;
    end

    // Dump waves for gtkwave
    initial begin
        $dumpfile("top_tb.fst");
        $dumpvars(0, top_tb);
    end

endmodule
