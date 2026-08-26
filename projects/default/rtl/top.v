`timescale 1ns / 1ps

module top (
    input a,
    input b,
    output ld0,
    output ld1,
    output ld2,
    output ld3,
    output ld4
);

    assign ld0 = a & b;
    assign ld1 = a | b;
    assign ld2 = ~a;
    assign ld3 = ~(a & b);
    assign ld4 = a ^ b;

endmodule
