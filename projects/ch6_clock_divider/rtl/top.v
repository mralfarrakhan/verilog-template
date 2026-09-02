`timescale 1ns / 1ps

module top (
    input clk, rst,
    output reg clk_1hz,
    output reg [25:0] clk_count_div,
    output reg tick,
    output reg [26:0] clk_count_tick
);
    // clock divider
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            clk_count_div <= 0;
            clk_1hz <= 0;
        end
        else begin
            if (clk_count_div == 62_499_999) begin
                clk_count_div <= 0;
                clk_1hz <= ~clk_1hz;
            end
            else begin
                clk_count_div <= clk_count_div + 1;
            end
        end
    end

    // tick 
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            clk_count_tick <= 0;
            tick <= 0;
        end
        else begin
            if (clk_count_tick == 124_999_999) begin
                clk_count_tick <= 0;
                tick <= 1;
            end
            else begin
                clk_count_tick <= clk_count_tick + 1;
                tick <= 0;
            end
        end
    end

endmodule
