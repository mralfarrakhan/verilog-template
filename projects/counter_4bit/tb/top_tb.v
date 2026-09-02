`timescale 1ns / 1ps

module top_tb;
    reg clk;
    reg rst;
    wire [3:0] count;

    integer logfile;

    top uut (
        .clk(clk),
        .rst(rst),
        .count(count)
    );

    task write_log;
        begin
            #1;

            $fwrite(
                logfile,
                "%0t,%b,%b,%x\n",
                $time, clk, rst, count
            );
        end
    endtask

    initial clk = 0;
    
    always begin 
        #5;
        clk = ~clk;
        write_log;
    end

    initial begin
        $display("Simulation start");

        logfile = $fopen("counter_4bit.csv", "w");
        $fwrite(
            logfile,
            "TIME,CLK,RST,COUNTER\n"
        );

        rst = 1;
        #20;

        rst = 0;
        #300;

        $fclose(logfile);
        $finish;
    end

    initial begin
        $dumpfile("top_tb.fst");
        $dumpvars(0, top_tb);
    end

endmodule
