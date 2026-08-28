`timescale 1ns / 1ps

module top_tb;
    reg clk;
    reg rst;
    wire [3:0] count;

    top uut (
        .clk(clk),
        .rst(rst),
        .count(count)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $display("Simulation start");

        rst = 1;
        #20;

        rst = 0;
        #300;

        $finish;
    end

    initial begin
        $dumpfile("top_tb.fst");
        $dumpvars(0, top_tb);
    end

endmodule
