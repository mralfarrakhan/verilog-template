`timescale 1ns / 1ps

module top_tb;
    reg clk;
    reg rst;
    reg sensor;
    wire door_command;

    top uut (
        .clk(clk),
        .rst(rst),
        .sensor(sensor),
        .door_command(door_command)
    );

    initial begin
        clk = 0;
        rst = 1;
        sensor = 0;
        
        #20;
        rst = 0;
        
        #20;
        sensor = 1;
        
        #30;
        sensor = 0;
        
        #40;
        sensor = 1;
        
        #30;
        sensor = 0;

        #20;
        $finish;
    end

    always #5 clk = ~clk;

    initial begin
        $dumpfile("top_tb.fst");
        $dumpvars(0, top_tb);
    end
endmodule
