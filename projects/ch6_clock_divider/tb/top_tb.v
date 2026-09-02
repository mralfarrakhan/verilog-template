`timescale 1ns / 1ps

module top_tb;
    reg clk;
    reg rst;
    wire clk_1hz;
    wire [25:0] clk_count;

    top uut (
        .clk(clk),
        .rst(rst),
        .clk_1hz(clk_1hz),
        .clk_count(clk_count)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rst = 1;

        #100;
        rst = 0;
        
        #1000;
        
        $finish;
    end

    initial begin
        $dumpfile("top_tb.fst");
        $dumpvars(0, top_tb);
    end
endmodule
