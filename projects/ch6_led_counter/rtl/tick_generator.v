module tick_generator #(
    parameter MAX_COUNT = 124_999_999
) (
    input wire clk,
    input wire rst,
    output reg tick
);
    reg [26:0] count;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 0;
            tick <= 0;
        end else begin
            if (count == MAX_COUNT) begin
                count <= 0;
                tick <= 1;
            end else begin
                count <= count + 1;
                tick <= 0;
            end
        end
    end
    
endmodule