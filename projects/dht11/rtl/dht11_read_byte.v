`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:59:11 08/24/2026 
// Design Name: 
// Module Name:    dht11_read_byte 
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



module dht11_read_byte (

    input  wire clk,
    input  wire rst,
    input  wire tick_us,

    inout  wire dht_data,

    input  wire byte_start,

    output reg       byte_done,
    output reg [7:0] data_byte,

    // DEBUG
    output reg [3:0] bit_count,
    output reg [7:0] shift_reg,

    output wire        bit_start_debug,
    output wire        bit_done_debug,
    output wire        bit_value_debug,
    output wire [15:0] high_time_debug

);


    // =========================================================
    // INTERNAL SIGNAL
    // =========================================================

    reg bit_start;

    wire bit_done;
    wire bit_value;

    wire [15:0] high_time_us;
    wire [15:0] high_count_debug;


    // =========================================================
    // STATE
    // =========================================================

    localparam IDLE      = 3'd0;
    localparam START_BIT = 3'd1;
    localparam WAIT_DONE = 3'd2;
    localparam NEXT_BIT  = 3'd3;
    localparam FINISH    = 3'd4;

    reg [2:0] state;


    // =========================================================
    // DEBUG CONNECTION
    // =========================================================

    assign bit_start_debug = bit_start;

    assign bit_done_debug = bit_done;

    assign bit_value_debug = bit_value;

    assign high_time_debug = high_time_us;


    // =========================================================
    // READ ONE BIT
    // =========================================================

    dht11_read_bit u_read_bit (

        .clk(clk),
        .rst(rst),
        .tick_us(tick_us),

        .dht_data(dht_data),

        .bit_start(bit_start),

        .bit_done(bit_done),

        .bit_value(bit_value),

        .high_time_us(high_time_us),

        .high_count_debug(high_count_debug)

    );


    // =========================================================
    // BYTE FSM
    // =========================================================

    always @(posedge clk or posedge rst) begin

        if (rst) begin

            state <= IDLE;

            bit_start <= 1'b0;

            bit_count <= 4'd0;

            shift_reg <= 8'd0;

            data_byte <= 8'd0;

            byte_done <= 1'b0;

        end

        else begin

            // -------------------------------------------------
            // DEFAULT
            // -------------------------------------------------

            bit_start <= 1'b0;

            byte_done <= 1'b0;


            case (state)


                // =================================================
                // IDLE
                // =================================================

                IDLE: begin

                    if (byte_start) begin

                        bit_count <= 4'd0;

                        shift_reg <= 8'd0;

                        state <= START_BIT;

                    end

                end


                // =================================================
                // START BIT
                // =================================================

                START_BIT: begin

                    bit_start <= 1'b1;

                    state <= WAIT_DONE;

                end


                // =================================================
                // WAIT BIT DONE
                // =================================================

                WAIT_DONE: begin

                    if (bit_done) begin

                        // -----------------------------------------
                        // SHIFT
                        // -----------------------------------------

                        shift_reg <=
                            {shift_reg[6:0], bit_value};


                        // -----------------------------------------
                        // DEBUG
                        // -----------------------------------------

                        $display(
                            "BIT %0d RESULT = %b",
                            bit_count + 1,
                            bit_value
                        );

                        $display(
                            "HIGH TIME = %0d us",
                            high_time_us
                        );


                        // -----------------------------------------
                        // CHECK 8 BITS
                        // -----------------------------------------

                        if (bit_count == 4'd7) begin

                            state <= FINISH;

                        end

                        else begin

                            state <= NEXT_BIT;

                        end

                    end

                end


                // =================================================
                // NEXT BIT
                // =================================================

                NEXT_BIT: begin

                    bit_count <= bit_count + 1'b1;

                    state <= START_BIT;

                end


                // =================================================
                // FINISH
                // =================================================

                FINISH: begin

                    data_byte <= shift_reg;

                    byte_done <= 1'b1;


                    $display("");
                    $display("========================================");
                    $display("        STEP 4B FINISHED");
                    $display("========================================");

                    $display(
                        "DATA BYTE = %b",
                        shift_reg
                    );

                    $display(
                        "HEX       = %h",
                        shift_reg
                    );

                    $display("========================================");
                    $display("");


                    state <= IDLE;

                end


                // =================================================
                // DEFAULT
                // =================================================

                default: begin

                    state <= IDLE;

                end

            endcase

        end

    end

endmodule