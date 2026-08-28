`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:02:40 08/22/2026 
// Design Name: 
// Module Name:    us_tick 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module us_tick (
    input  wire clk,
    input  wire rst,
    output reg  tick_us
);

    // 50 MHz clock
    // 1 clock = 20 ns
    // 50 clock = 1 us

    reg [5:0] counter;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 6'd0;
            tick_us <= 1'b0;
        end
        else begin

        if (counter == 6'd49) begin
                counter <= 6'd0;
                tick_us <= 1'b1;
            end
            else begin
                counter <= counter + 1'b1;
                tick_us <= 1'b0;
            end
        end
    end
endmodule










