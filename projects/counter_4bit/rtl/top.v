`timescale 1ns / 1ps

module top(
    input clk, rst,
    output reg [3:0] count
);

    always @(posedge clk or posedge rst) begin
        if(rst) count <= 0; 
        else count <= count + 1;
    end

endmodule
