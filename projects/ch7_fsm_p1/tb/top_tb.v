`timescale 1ns / 1ps

module top_tb;
    reg clk;
    reg rst;
    wire red_led;
    wire green_led;
    wire yellow_led;

    top uut (
        .clk(clk),
        .rst(rst),
        .red_led(red_led),
        .green_led(green_led),
        .yellow_led(yellow_led)
    );

    initial begin
        clk = 0;
        rst = 1;
        #10 rst = 0;
        #5000;
        $finish;
    end

    always #5 clk = ~clk;

    initial begin
        $dumpfile("top_tb.fst");
        $dumpvars(0, top_tb);
    end
endmodule
