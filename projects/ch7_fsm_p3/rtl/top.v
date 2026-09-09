`timescale 1ns / 1ps

module top (clk, rstn, btn, w100, ret, sale, valve);
    input clk, rstn, btn, w100;
    output ret, sale, valve;
    
    reg enable_valve;
    reg [1:0] st, nst;
    localparam ST0 = 2'b00, ST100 = 2'b01, ST200 = 2'b10, ST300 = 2'b11;
    reg [3:0] vct;

    wire ce_1hz;
    wire timer_clear = sale && !enable_valve;

    clock_divider u_clock_divider (
        .clk(clk),
        .rst(~rstn),
        .clear(timer_clear),
        .ce_1hz(ce_1hz)
    );

    always @(st or btn or w100) 
        case (st)
            ST0: begin
               if (w100) nst = ST100;
               else nst = ST0; 
            end
            ST100: begin
                if (w100) nst = ST200;
                else if (btn) nst = ST0;
                else nst = ST100;
            end
            ST200: begin
                if (w100) nst = ST300;
                else if (btn) nst = ST0;
                else nst = ST200;
            end
            ST300: begin
                if (w100) nst = ST0;
                else if (btn) nst = ST0;
                else nst = ST300;
            end
        endcase

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin 
            st <= ST0;
            enable_valve <= 1'b0;
            vct <= 4'b0;
        end
        else begin
            st <= nst;

            if (timer_clear) begin
                enable_valve <= 1'b1;
                vct <= 4'b0;
            end
            else if (enable_valve && ce_1hz) begin
                if (vct < 4'd1) begin
                    vct <= vct + 4'b1;
                end
                else begin
                    enable_valve <= 1'b0;
                end
            end
        end
    end

    assign ret = (st == ST100) && btn && !w100
            || (st == ST200) && btn &&!w100
            || (st == ST300) && w100;
    assign sale = (st == ST300) && btn && !w100;
    assign valve = enable_valve;
endmodule
