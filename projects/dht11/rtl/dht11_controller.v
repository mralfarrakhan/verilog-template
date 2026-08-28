`timescale 1ns/1ps

module dht11_controller (

    input wire clk,
    input wire rst,

    input wire start,

    inout wire dht_data,

    output reg busy,
    output reg done,

    output reg [7:0] humidity_int,
    output reg [7:0] humidity_dec,

    output reg [7:0] temperature_int,
    output reg [7:0] temperature_dec,

    output reg [7:0] checksum,

    output reg checksum_ok

);


    // =========================================================
    // 1 us TICK
    // =========================================================

    wire tick_us;


    us_tick u_tick (

        .clk(clk),
        .rst(rst),

        .tick_us(tick_us)

    );


    // =========================================================
    // START SIGNAL
    // =========================================================

    reg start_begin;

    wire start_done;

    wire start_wait;


    dht11_start u_start (

        .clk(clk),
        .rst(rst),

        .tick_us(tick_us),

        .start(start_begin),

        .dht_data(dht_data),

        .busy(start_wait),

        .done(start_done)

    );


    // =========================================================
    // READ 40 BIT
    // =========================================================

    reg read_start;

    wire read_done;

    wire [7:0] read_humidity_int;
    wire [7:0] read_humidity_dec;

    wire [7:0] read_temperature_int;
    wire [7:0] read_temperature_dec;

    wire [7:0] read_checksum;

    wire read_checksum_ok;


    dht11_read_40bit u_read40 (

        .clk(clk),
        .rst(rst),

        .tick_us(tick_us),

        .dht_data(dht_data),

        .start(read_start),

        .done(read_done),

        .humidity_int(read_humidity_int),
        .humidity_dec(read_humidity_dec),

        .temperature_int(read_temperature_int),
        .temperature_dec(read_temperature_dec),

        .checksum(read_checksum),

        .checksum_ok(read_checksum_ok),

        // DEBUG tidak diperlukan di controller
        .byte_count(),

        .byte_start_debug(),
        .byte_done_debug(),
        .byte_data_debug(),

        .bit_start_debug(),
        .bit_done_debug(),
        .bit_value_debug(),

        .high_time_debug()

    );


    // =========================================================
    // CONTROLLER STATE
    // =========================================================

    localparam IDLE       = 3'd0;
    localparam START_DHT  = 3'd1;
    localparam WAIT_START = 3'd2;
    localparam START_READ = 3'd3;
    localparam WAIT_READ  = 3'd4;
    localparam FINISH     = 3'd5;


    reg [2:0] state;


    // =========================================================
    // MAIN FSM
    // =========================================================

    always @(posedge clk or posedge rst) begin

        if (rst) begin

            state <= IDLE;

            start_begin <= 1'b0;
            read_start <= 1'b0;

            busy <= 1'b0;
            done <= 1'b0;

            humidity_int <= 8'd0;
            humidity_dec <= 8'd0;

            temperature_int <= 8'd0;
            temperature_dec <= 8'd0;

            checksum <= 8'd0;

            checksum_ok <= 1'b0;

        end

        else begin

            // -------------------------------------------------
            // Default pulse signals
            // -------------------------------------------------

            start_begin <= 1'b0;
            read_start <= 1'b0;

            done <= 1'b0;


            case (state)


                // =================================================
                // IDLE
                // =================================================

                IDLE: begin

                    busy <= 1'b0;

                    if (start) begin

                        busy <= 1'b1;

                        checksum_ok <= 1'b0;

                        state <= START_DHT;

                    end

                end


                // =================================================
                // START DHT11
                // =================================================

                START_DHT: begin

                    $display("");
                    $display("========================================");
                    $display("        DHT11 CONTROLLER START");
                    $display("========================================");
                    $display("");

                    $display("Sending DHT11 START signal...");

                    start_begin <= 1'b1;

                    state <= WAIT_START;

                end


                // =================================================
                // WAIT START DONE
                // =================================================

                WAIT_START: begin

                    if (start_done) begin

                        $display("DHT11 START FINISHED");
                        $display("");

                        state <= START_READ;

                    end

                end


                // =================================================
                // START READ 40 BIT
                // =================================================

                START_READ: begin

                    $display("Starting 40-bit data read...");

                    read_start <= 1'b1;

                    state <= WAIT_READ;

                end


                // =================================================
                // WAIT 40 BIT DONE
                // =================================================

                WAIT_READ: begin

                    if (read_done) begin

                        state <= FINISH;

                    end

                end


                // =================================================
                // FINISH
                // =================================================

                FINISH: begin

                    // -------------------------------------------------
                    // Copy result
                    // -------------------------------------------------

                    humidity_int <= read_humidity_int;
                    humidity_dec <= read_humidity_dec;

                    temperature_int <= read_temperature_int;
                    temperature_dec <= read_temperature_dec;

                    checksum <= read_checksum;

                    checksum_ok <= read_checksum_ok;


                    // -------------------------------------------------
                    // DISPLAY RESULT
                    // -------------------------------------------------

                    $display("");
                    $display("========================================");
                    $display("        DHT11 CONTROLLER RESULT");
                    $display("========================================");
                    $display("");

                    $display(
                        "Humidity    = %0d.%0d %%",
                        read_humidity_int,
                        read_humidity_dec
                    );

                    $display(
                        "Temperature = %0d.%0d C",
                        read_temperature_int,
                        read_temperature_dec
                    );

                    $display(
                        "Checksum    = %0d",
                        read_checksum
                    );

                    if (read_checksum_ok)

                        $display(
                            "Checksum    = PASS"
                        );

                    else

                        $display(
                            "Checksum    = FAIL"
                        );

                    $display("");

                    $display("========================================");


                    // -------------------------------------------------
                    // DONE
                    // -------------------------------------------------

                    done <= 1'b1;

                    busy <= 1'b0;

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