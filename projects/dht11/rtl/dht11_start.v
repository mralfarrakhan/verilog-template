`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:43:12 08/22/2026 
// Design Name: 
// Module Name:    dht11_start 
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
module dht11_start (
    input  wire clk,
    input  wire rst,
    input  wire start,
    input  wire tick_us,

    inout  wire dht_data,

    output reg busy,
    output reg done
);

// =========================================================
    // DHT11 START
    //
    // DATA LOW selama 18 ms
    //
    // 18 ms = 18,000 us
    // =========================================================

    reg data_out;
    reg data_oe;

    reg [14:0] us_count;

    assign dht_data = data_oe ? data_out : 1'bz;


always @(posedge clk or posedge rst) begin

        if (rst) begin
            data_out <= 1'b1;
            data_oe  <= 1'b0;
            us_count <= 15'd0;
            busy     <= 1'b0;
            done     <= 1'b0;
        end

        else begin

		  // done hanya satu clock
            done <= 1'b0;

            if (start && !busy) begin

                busy     <= 1'b1;
                data_oe  <= 1'b1;
                data_out <= 1'b0;
                us_count <= 15'd0;

            end
            // =================================================
            // SEDANG MENJALANKAN START
            // =================================================

            else if (busy && tick_us) begin

                if (us_count < 15'd18000) begin

                    us_count <= us_count + 1'b1;

                end

                else begin
                     // Lepaskan DATA
                    data_oe  <= 1'b0;
                    data_out <= 1'b1;

                    busy <= 1'b0;
                    done <= 1'b1;

                    end
            end

        end

    end

endmodule
