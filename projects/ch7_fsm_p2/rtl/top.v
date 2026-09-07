`timescale 1ns / 1ps

module top (
    input wire clk,
    input wire rst,
    input wire sensor,
    output reg door_command
);
    reg state;
    localparam CLOSED = 1'b0;
    localparam OPEN = 1'b1;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= CLOSED;
        end
        else begin
            case (state)
                CLOSED: begin
                    if (sensor == 1'b1) begin
                        state <= OPEN;
                    end
                    else begin
                        state <= CLOSED;    
                    end
                end 
                OPEN: begin
                    if (sensor == 1'b1) begin
                        state <= OPEN;
                    end
                    else begin
                        state <= CLOSED;    
                    end
                end
                default: begin
                    state <= CLOSED;
                end 
            endcase
        end
    end

    always @(*) begin
        case (state)
            CLOSED: begin
                if (sensor) begin
                    door_command = 1'b1;
                end
                else begin
                    door_command = 1'b0;
                end
            end 
            OPEN: begin
                if (sensor) begin
                    door_command = 1'b1;
                end
                else begin
                    door_command = 1'b0;
                end
            end
            default: begin
                door_command = 1'b0;
            end 
        endcase
    end
endmodule
