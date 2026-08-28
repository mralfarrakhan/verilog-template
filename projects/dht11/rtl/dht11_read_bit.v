`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:32:17 08/24/2026 
// Design Name: 
// Module Name:    dht11_read_bit 
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


module dht11_read_bit (
    input  wire clk,
    input  wire rst,
    input  wire tick_us,

    inout  wire dht_data,

    input  wire bit_start,

    output reg bit_done,
    output reg bit_value,

    output reg [15:0] high_time_us,

    // DEBUG
    output reg [15:0] high_count_debug
);

    // =========================================================
    // STATE
    // =========================================================

    localparam IDLE       = 2'd0;
    localparam WAIT_LOW   = 2'd1;
    localparam WAIT_HIGH  = 2'd2;
    localparam MEASURE    = 2'd3;

    reg [1:0] state;


    // =========================================================
    // HIGH COUNTER
    // =========================================================

    reg [15:0] high_count;


    // =========================================================
    // FSM
    // =========================================================

    always @(posedge clk or posedge rst) begin

        if (rst) begin

            state <= IDLE;

            high_count <= 16'd0;

            high_time_us <= 16'd0;

            high_count_debug <= 16'd0;

            bit_value <= 1'b0;
            bit_done  <= 1'b0;

        end

        else begin

            // DONE hanya satu clock
            bit_done <= 1'b0;


            case (state)

                // =================================================
                // IDLE
                // =================================================

                IDLE: begin

                    if (bit_start) begin

                        high_count <= 16'd0;

                        high_count_debug <= 16'd0;

                        state <= WAIT_LOW;

                    end

                end


                // =================================================
                // TUNGGU LOW
                // =================================================

                WAIT_LOW: begin

                    if (dht_data == 1'b0) begin

                        state <= WAIT_HIGH;

                    end

                end


                // =================================================
                // TUNGGU HIGH
                // =================================================

                WAIT_HIGH: begin

                    if (dht_data == 1'b1) begin

                        high_count <= 16'd0;

                        state <= MEASURE;

                    end

                end


                // =================================================
                // MEASURE HIGH
                // =================================================

                MEASURE: begin

                    // ---------------------------------------------
                    // DATA masih HIGH
                    // ---------------------------------------------

                    if (dht_data == 1'b1) begin

                        if (tick_us) begin

                            high_count <= high_count + 1'b1;

                            high_count_debug <=
                                high_count + 1'b1;

                        end

                    end


                    // ---------------------------------------------
                    // DATA sudah LOW / dilepas
                    // ---------------------------------------------

                    else begin

                        // Simpan hasil pengukuran
                        high_time_us <= high_count;

                        // -----------------------------------------
                        // Threshold
                        //
                        // HIGH < 50 us  -> BIT 0
                        // HIGH >= 50 us -> BIT 1
                        // -----------------------------------------

                        if (high_count < 16'd50)
                            bit_value <= 1'b0;
                        else
                            bit_value <= 1'b1;

                        bit_done <= 1'b1;

                        state <= IDLE;

                    end

                end


                default: begin

                    state <= IDLE;

                end

            endcase

        end

    end

endmodule