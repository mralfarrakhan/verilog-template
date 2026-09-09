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

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rstn = 0;
        btn = 0;
        w100 = 0;
        
        #7 rstn=1; 
        #30 w100=1;//100 
        #10 w100=0; 
        #30 w100=1;//200
        #10 w100=0; 
        #30 w100=1;//300 
        #10 w100=0; 
        #30 btn=1;//sale 
        #10 btn=0; 
        #30 w100=1;//100 
        #10 w100=0; 
        #30 w100=1;//200 
        #10 w100=0; 
        #30 btn=1;//ret 
        #10 btn=0; 
      #100 $finish; 
    end

    initial begin
        $dumpfile("top_tb.fst");
        $dumpvars(0, top_tb);
    end

endmodule
