module counter_4bit (
    input wire clk,
    input wire rst,
    input wire tick,
    output reg [3:0] counter
);

    always @(posedge clk or posedge rst) begin
        if (rst) counter <= 4'b0000;
        else if (tick) begin
            counter <= counter + 1;
        end
    end

endmodule