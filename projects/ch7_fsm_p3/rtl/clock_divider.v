module clock_divider #(
    parameter MAX_COUNT = 124_999_999
) (
    input wire clk,
    input wire rst,
    input wire clear,
    output reg ce_1hz
);

    reg [26:0] clk_count_div;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            clk_count_div <= 0;
            ce_1hz <= 0;
        end
        else begin
            if (clear) begin
                clk_count_div <= 0;
                ce_1hz <= 0;
            end
            else if (clk_count_div == MAX_COUNT) begin
                clk_count_div <= 0;
                ce_1hz <= 1;
            end
            else begin
                clk_count_div <= clk_count_div + 1;
                ce_1hz <= 0;
            end
        end
    end

endmodule