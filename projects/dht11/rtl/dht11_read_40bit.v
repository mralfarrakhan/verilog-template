`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:28:39 08/24/2026 
// Design Name: 
// Module Name:    dht11_read_40bit 
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


module dht11_read_40bit (

    input wire clk,
    input wire rst,
    input wire tick_us,

    inout wire dht_data,

    input wire start,

    output reg done,

    output reg [7:0] humidity_int,
    output reg [7:0] humidity_dec,
    output reg [7:0] temperature_int,
    output reg [7:0] temperature_dec,
    output reg [7:0] checksum,

    output reg checksum_ok,

    output reg [2:0] byte_count,

    output wire byte_start_debug,
    output wire byte_done_debug,
    output wire [7:0] byte_data_debug,

    output wire bit_start_debug,
    output wire bit_done_debug,
    output wire bit_value_debug,

    output wire [15:0] high_time_debug

);


    // =========================================================
    // INTERNAL
    // =========================================================

    reg byte_start;

    wire byte_done;

    wire [7:0] data_byte;

    wire [3:0] bit_count_debug;
    wire [7:0] shift_reg_debug;


    // =========================================================
    // STATE
    // =========================================================

    localparam IDLE           = 4'd0;
    localparam START_BYTE     = 4'd1;
    localparam WAIT_BYTE      = 4'd2;
    localparam SAVE_BYTE      = 4'd3;
    localparam WAIT_NEXT      = 4'd4;
    localparam FINISH         = 4'd5;

    reg [3:0] state;


    // =========================================================
    // DEBUG
    // =========================================================

    assign byte_start_debug = byte_start;

    assign byte_done_debug = byte_done;

    assign byte_data_debug = data_byte;


    // =========================================================
    // DHT11 BYTE READER
    // =========================================================

    dht11_read_byte u_read_byte (

        .clk(clk),
        .rst(rst),
        .tick_us(tick_us),

        .dht_data(dht_data),

        .byte_start(byte_start),

        .byte_done(byte_done),
        .data_byte(data_byte),

        .bit_count(bit_count_debug),
        .shift_reg(shift_reg_debug),

        .bit_start_debug(bit_start_debug),
        .bit_done_debug(bit_done_debug),
        .bit_value_debug(bit_value_debug),

        .high_time_debug(high_time_debug)

    );


    // =========================================================
    // FSM
    // =========================================================

    always @(posedge clk or posedge rst) begin

        if (rst) begin

            state <= IDLE;

            byte_start <= 1'b0;

            done <= 1'b0;

            byte_count <= 3'd0;

            humidity_int <= 8'd0;
            humidity_dec <= 8'd0;

            temperature_int <= 8'd0;
            temperature_dec <= 8'd0;

            checksum <= 8'd0;

            checksum_ok <= 1'b0;

        end

        else begin

            // -------------------------------------------------
            // DEFAULT
            // -------------------------------------------------

            byte_start <= 1'b0;

            done <= 1'b0;


            case (state)


                // =================================================
                // IDLE
                // =================================================

                IDLE: begin

                    if (start) begin

                        byte_count <= 3'd0;

                        state <= START_BYTE;

                    end

                end


                // =================================================
                // START BYTE
                // =================================================

                START_BYTE: begin

                    $display("");
                    $display("START BYTE %0d",
                             byte_count + 1);

                    byte_start <= 1'b1;

                    state <= WAIT_BYTE;

                end


                // =================================================
                // WAIT BYTE DONE
                // =================================================

                WAIT_BYTE: begin

                    if (byte_done) begin

                        state <= SAVE_BYTE;

                    end

                end


                // =================================================
                // SAVE BYTE
                // =================================================

                SAVE_BYTE: begin

                    $display("");
                    $display("----------------------------------------");

                    $display(
                        "BYTE %0d = %b",
                        byte_count + 1,
                        data_byte
                    );

                    $display(
                        "BYTE %0d HEX = %h",
                        byte_count + 1,
                        data_byte
                    );


                    case (byte_count)

                        3'd0:
                            humidity_int <= data_byte;

                        3'd1:
                            humidity_dec <= data_byte;

                        3'd2:
                            temperature_int <= data_byte;

                        3'd3:
                            temperature_dec <= data_byte;

                        3'd4:
                            checksum <= data_byte;

                        default:
                            ;

                    endcase


                    // -------------------------------------------------
                    // BYTE 5
                    // -------------------------------------------------

                    if (byte_count == 3'd4) begin

                        state <= FINISH;

                    end

                    else begin

                        byte_count <= byte_count + 1'b1;

                        // IMPORTANT:
                        // jangan langsung START_BYTE
                        state <= WAIT_NEXT;

                    end

                end


                // =================================================
                // WAIT NEXT
                //
                // Beri waktu dht11_read_byte kembali IDLE
                // =================================================

                WAIT_NEXT: begin

                    state <= START_BYTE;

                end


                // =================================================
                // FINISH
                // =================================================

                FINISH: begin

                    done <= 1'b1;


                    // -------------------------------------------------
                    // CHECKSUM
                    // -------------------------------------------------

                    if (
                        (
                            humidity_int +
                            humidity_dec +
                            temperature_int +
                            temperature_dec
                        ) == checksum
                    ) begin

                        checksum_ok <= 1'b1;

                    end

                    else begin

                        checksum_ok <= 1'b0;

                    end


                    // -------------------------------------------------
                    // DISPLAY
                    // -------------------------------------------------

                    $display("");
                    $display("========================================");
                    $display("");
                    $display("        STEP 4C FINISHED");
                    $display("");
                    $display("========================================");

                    $display(
                        "HUMIDITY INTEGER    = %0d",
                        humidity_int
                    );

                    $display(
                        "HUMIDITY DECIMAL    = %0d",
                        humidity_dec
                    );

                    $display(
                        "TEMPERATURE INTEGER = %0d",
                        temperature_int
                    );

                    $display(
                        "TEMPERATURE DECIMAL = %0d",
                        temperature_dec
                    );

                    $display(
                        "CHECKSUM            = %0d",
                        checksum
                    );


                    if (
                        (
                            humidity_int +
                            humidity_dec +
                            temperature_int +
                            temperature_dec
                        ) == checksum
                    )

                        $display(
                            "CHECKSUM RESULT     = PASS"
                        );

                    else

                        $display(
                            "CHECKSUM RESULT     = FAIL"
                        );


                    $display("");
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