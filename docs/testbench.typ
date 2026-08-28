= Simulation

counter:

```verilog
// top.v

module top(
    input clk, rst,
    output reg [3:0] count
);

    always @(posedge clk or posedge rst) begin
        if(rst) count <= 0;
        else count <= count + 1;
    end

endmodule
```

testbench:

```verilog
// top_tb.v
`timescale 1ns / 1ps

module top_tb;
    // simulation input/output
    reg clk;
    reg rst;
    wire [3:0] count;

    // simulation i/o wiring
    top uut (
        .clk(clk),
        .rst(rst),
        .count(count)
    );

    // initialize clock val and generate clock
    initial clk = 0;
    always #5 clk = ~clk;

    // one-shot simulation
    initial begin
        $display("Simulation start");

        rst = 1;
        #20;

        rst = 0;
        #300;

        $finish;
    end

    // waveform dump
    initial begin
        $dumpfile("top_tb.fst");
        $dumpvars(0, top_tb);
    end

endmodule
```

== Report

#image("testbench.png")

based on waveform view:

+ when ```verilog rst = 1```, `count` does remain `0`.
+ when ```verilog rst = 0```, `count` value change sequentially on each `clk` cycle.
+ `count` does overflow after reaching `1111`
