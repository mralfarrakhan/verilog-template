`timescale 1ns/1ps

module dht11_controller_tb;

    // =========================================================
    // SIGNAL
    // =========================================================

    reg clk;
    reg rst;
    reg start;

    wire dht_data;

    wire busy;
    wire done;

    wire [7:0] humidity_int;
    wire [7:0] humidity_dec;

    wire [7:0] temperature_int;
    wire [7:0] temperature_dec;

    wire [7:0] checksum;

    wire checksum_ok;


    // =========================================================
    // DHT11 DATA DRIVER
    // =========================================================

    reg dht_data_drive;
    reg dht_data_enable;

    assign dht_data =
        dht_data_enable ?
        dht_data_drive :
        1'bz;


    // =========================================================
    // CLOCK 50 MHz
    //
    // Period = 20 ns
    // =========================================================

    always #10 clk = ~clk;


    // =========================================================
    // DUT
    // =========================================================

    dht11_controller uut (

        .clk(clk),
        .rst(rst),

        .start(start),

        .dht_data(dht_data),

        .busy(busy),
        .done(done),

        .humidity_int(humidity_int),
        .humidity_dec(humidity_dec),

        .temperature_int(temperature_int),
        .temperature_dec(temperature_dec),

        .checksum(checksum),

        .checksum_ok(checksum_ok)

    );


    // =========================================================
    // TASK : SEND ONE DHT11 BIT
    //
    // BIT 0
    // HIGH = 26 us
    //
    // BIT 1
    // HIGH = 70 us
    // =========================================================

    task send_bit;

        input bit_value;

        begin

            // -------------------------------------------------
            // LOW ~50 us
            // -------------------------------------------------

            dht_data_enable = 1'b1;

            dht_data_drive = 1'b0;

            #50000;


            // -------------------------------------------------
            // HIGH
            // -------------------------------------------------

            dht_data_drive = 1'b1;

            if (bit_value == 1'b0)

                #26000;

            else

                #70000;


            // -------------------------------------------------
            // LOW
            // -------------------------------------------------

            dht_data_drive = 1'b0;

            #2000;

        end

    endtask


    // =========================================================
    // TASK : SEND ONE BYTE
    // =========================================================

    task send_byte;

        input [7:0] data;

        begin

            // Beri waktu DUT masuk WAIT_LOW

            #100;


            send_bit(data[7]);
            send_bit(data[6]);
            send_bit(data[5]);
            send_bit(data[4]);

            send_bit(data[3]);
            send_bit(data[2]);
            send_bit(data[1]);
            send_bit(data[0]);

        end

    endtask


    // =========================================================
    // MAIN TEST
    // =========================================================

    initial begin

        // =====================================================
        // INITIAL
        // =====================================================

        clk = 1'b0;

        rst = 1'b1;

        start = 1'b0;

        dht_data_enable = 1'b0;

        dht_data_drive = 1'b1;


        // =====================================================
        // RESET
        // =====================================================

        #200;

        rst = 1'b0;

        #1000;


        // =====================================================
        // STEP 5 START
        // =====================================================

        $display("");
        $display("========================================");
        $display("");
        $display("       STEP 5 DHT11 CONTROLLER");
        $display("");
        $display("========================================");
        $display("");

        $display("Expected BYTE 1 = 01001010 = 4A");
        $display("Expected BYTE 2 = 00000000 = 00");
        $display("Expected BYTE 3 = 00011110 = 1E");
        $display("Expected BYTE 4 = 00000000 = 00");
        $display("Expected BYTE 5 = 01101000 = 68");
        $display("");

        $display("Expected Humidity    = 74 %%");
        $display("Expected Temperature = 30 C");
        $display("Expected Checksum    = 104");
        $display("");


        // =====================================================
        // START CONTROLLER
        // =====================================================

        start = 1'b1;

        #20;

        start = 1'b0;


        // =====================================================
        // DHT11 START
        //
        // Controller sekarang menjalankan LOW 18 ms.
        //
        // Kita tunggu sampai busy.
        // =====================================================

        wait(busy);

        $display("");
        $display("DHT11 CONTROLLER BUSY");
        $display("");


        // =====================================================
        // TUNGGU START 18 ms
        //
        // Setelah start selesai, controller akan masuk
        // ke pembacaan 40 bit.
        //
        // Beri waktu tambahan sedikit.
        // =====================================================

        #18200000;


        // =====================================================
        // BYTE 1
        // 01001010 = 74
        // =====================================================

        $display("");
        $display("******** BYTE 1 ********");
        $display("");

        send_byte(8'b01001010);

        $display("");
        $display("BYTE 1 SEND FINISHED");
        $display("");


        // =====================================================
        // BYTE 2
        // 00000000
        // =====================================================

        $display("");
        $display("******** BYTE 2 ********");
        $display("");

        send_byte(8'b00000000);

        $display("");
        $display("BYTE 2 SEND FINISHED");
        $display("");


        // =====================================================
        // BYTE 3
        // 00011110 = 30
        // =====================================================

        $display("");
        $display("******** BYTE 3 ********");
        $display("");

        send_byte(8'b00011110);

        $display("");
        $display("BYTE 3 SEND FINISHED");
        $display("");


        // =====================================================
        // BYTE 4
        // 00000000
        // =====================================================

        $display("");
        $display("******** BYTE 4 ********");
        $display("");

        send_byte(8'b00000000);

        $display("");
        $display("BYTE 4 SEND FINISHED");
        $display("");


        // =====================================================
        // BYTE 5
        // 01101000 = 104
        // =====================================================

        $display("");
        $display("******** BYTE 5 ********");
        $display("");

        send_byte(8'b01101000);

        $display("");
        $display("BYTE 5 SEND FINISHED");
        $display("");


        // =====================================================
        // WAIT DONE
        // =====================================================

        wait(done);


        // =====================================================
        // FINAL RESULT
        // =====================================================

        #1000;

        $display("");
        $display("========================================");
        $display("");
        $display("       FINAL STEP 5 RESULT");
        $display("");
        $display("========================================");
        $display("");

        $display(
            "HUMIDITY    = %0d.%0d %%",
            humidity_int,
            humidity_dec
        );

        $display(
            "TEMPERATURE = %0d.%0d C",
            temperature_int,
            temperature_dec
        );

        $display(
            "CHECKSUM    = %0d",
            checksum
        );

        $display("");


        // =====================================================
        // CHECK RESULT
        // =====================================================

        if (
            humidity_int == 8'd74 &&
            humidity_dec == 8'd0 &&
            temperature_int == 8'd30 &&
            temperature_dec == 8'd0 &&
            checksum == 8'd104 &&
            checksum_ok == 1'b1
        ) begin

            $display("RESULT = PASS");

        end

        else begin

            $display("RESULT = FAIL");

        end


        $display("");
        $display("========================================");
        $display("");


        // =====================================================
        // FINISH
        // =====================================================

        #1000;

        $finish;

    end

endmodule