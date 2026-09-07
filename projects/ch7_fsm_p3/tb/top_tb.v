`timescale 1ns / 1ps

module top_tb;
    reg clk;
    reg rstn;
    reg btn;
    reg w100;
    wire ret;
    wire sale;

    top uut (
        .clk(clk),
        .rstn(rstn),
        .btn(btn),
        .w100(w100),
        .ret(ret),
        .sale(sale)
    );

    initial begin
        $dumpfile("top_tb.fst");
        $dumpvars(0, top_tb);
        
        clk = 0;
        rstn = 0;
        btn = 0;
        w100 = 0;
        
        #20;
        rstn = 1;
        
        // Insert w100 to reach 300, then press button for sale
        #10;
        w100 = 1;
        #10; w100 = 0;
        
        #20;
        w100 = 1;
        #10; w100 = 0;
        
        #20;
        w100 = 1;
        #10; w100 = 0;
        
        #20;
        btn = 1;
        #10; btn = 0;
        
        // Insert w100 to reach 200, then return
        #20;
        w100 = 1;
        #10; w100 = 0;
        
        #20;
        w100 = 1;
        #10; w100 = 0;
        
        #20;
        btn = 1;
        #10; btn = 0;

        // Insert w100 4 times
        #20;
        w100 = 1;
        #10; w100 = 0;
        
        #20;
        w100 = 1;
        #10; w100 = 0;
        
        #20;
        w100 = 1;
        #10; w100 = 0;
        
        #20;
        w100 = 1;
        #10; w100 = 0;

        #40;
        $finish;
    end

    always #5 clk = ~clk;
endmodule
