`timescale 1ns / 1ps

module top (
    input  wire clk,
    input  wire rst,
    output reg  led
);

    always @(posedge clk) begin
        if (rst) begin
            led <= 1'b0;
        end else begin
            led <= ~led;
        end
    end

endmodule
