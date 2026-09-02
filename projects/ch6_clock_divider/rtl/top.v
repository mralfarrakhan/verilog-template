`timescale 1ns / 1ps

module top (
    input clk,
    input rst,
    output reg clk_1hz,
    output reg [25:0] clk_count
);
    // clock divider
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            clk_count <= 0;
            clk_1hz <= 0;
        end
        else begin
            if (clk_count == 62_499_999) begin
                clk_count <= 0;
                clk_1hz <= ~clk_1hz;
            end
            else begin
                clk_count <= clk_count + 1;
            end
        end
    end

endmodule
