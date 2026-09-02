`timescale 1ns / 1ps

module top (
    input wire clk,
    input wire rst,
    output wire [3:0] led
);

    wire tick;
    wire [3:0] counter;

    tick_generator u_tick (
        .clk(clk),
        .rst(rst),
        .tick(tick)
    );

    counter_4bit u_counter (
        .clk(clk),
        .rst(rst),
        .tick(tick),
        .counter(counter)
    );

    assign led = counter;

endmodule
