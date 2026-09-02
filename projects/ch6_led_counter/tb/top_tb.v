`timescale 1ns / 1ps

module top_tb;
    reg clk;
    reg rst;
    wire [3:0] led;

    top uut (
        .clk(clk),
        .rst(rst),
        .led(led)
    );

    defparam uut.u_tick.MAX_COUNT = 10;

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rst = 1;
                
        #100;
        rst = 0;
 
        #2000;
        
        $finish;
    end

    initial begin
        $dumpfile("top_tb.fst");
        $dumpvars(0, top_tb);
    end
endmodule
