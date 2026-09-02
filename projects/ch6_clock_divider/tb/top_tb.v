`timescale 1ns / 1ps

module top_tb;
    reg clk;
    reg rst;
    wire clk_1hz;
    wire [25:0] clk_count_div;
    wire tick;
    wire [26:0] clk_count_tick;

    top uut (
        .clk(clk),
        .rst(rst),
        .clk_1hz(clk_1hz),
        .clk_count_div(clk_count_div),
        .tick(tick),
        .clk_count_tick(clk_count_tick)
    );

    initial clk = 0;
    always #4 clk = ~clk;

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
