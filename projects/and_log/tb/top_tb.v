`timescale 1ns/1ps

module top_tb;

    // =========================================================
    // SIGNAL
    // =========================================================
    reg  a;
    reg  b;
    wire y;

    reg expected;

    // File handle
    integer logfile;

    // =========================================================
    // INSTANTIATE DESIGN
    // =========================================================
    top uut (
        .a(a),
        .b(b),
        .y(y)
    );

    // =========================================================
    // LOGGER
    // =========================================================
    task check_result;
        begin

            #1;

            if (y === expected) begin

                $display(
                    "TIME=%0t | A=%b B=%b | Y=%b | EXPECTED=%b | PASS",
                    $time, a, b, y, expected
                );

                $fwrite(
                    logfile,
                    "%0t,%b,%b,%b,%b,PASS\n",
                    $time, a, b, y, expected
                );

            end
            else begin

                $display(
                    "TIME=%0t | A=%b B=%b | Y=%b | EXPECTED=%b | FAIL",
                    $time, a, b, y, expected
                );

                $fwrite(
                    logfile,
                    "%0t,%b,%b,%b,%b,FAIL\n",
                    $time, a, b, y, expected
                );

            end

        end
    endtask

    // =========================================================
    // TEST
    // =========================================================
    initial begin

        // -----------------------------------------------------
        // Buka file log
        // -----------------------------------------------------
        logfile = $fopen("and_gate_log.csv", "w");

        if (logfile == 0) begin
            $display("ERROR: Tidak dapat membuka file log!");
            $finish;
        end

        // Header CSV
        $fwrite(
            logfile,
            "TIME,A,B,Y,EXPECTED,RESULT\n"
        );

        $display("");
        $display("==============================================");
        $display("       AND GATE TESTBENCH START");
        $display("==============================================");

        // =====================================================
        // TEST 1
        // =====================================================
        a = 0;
        b = 0;
        expected = 0;
        check_result;

        #10;

        // =====================================================
        // TEST 2
        // =====================================================
        a = 0;
        b = 1;
        expected = 0;
        check_result;

        #10;

        // =====================================================
        // TEST 3
        // =====================================================
        a = 1;
        b = 0;
        expected = 0;
        check_result;

        #10;

        // =====================================================
        // TEST 4
        // =====================================================
        a = 1;
        b = 1;
        expected = 1;
        check_result;

        #10;

        // =====================================================
        // Tutup file
        // =====================================================
        $fclose(logfile);

        $display("");
        $display("Log disimpan sebagai: and_gate_log.csv");

        $display("");
        $display("==============================================");
        $display("        AND GATE TESTBENCH FINISHED");
        $display("==============================================");

        $finish;

    end

    initial begin
        $dumpfile("top_tb.fst");
        $dumpvars(0, top_tb);
    end

endmodule