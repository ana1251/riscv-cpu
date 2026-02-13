`timescale 1ns / 1ps

module alu(
    input [31:0] a,
    input [31:0] b,
    output [31:0] c
);
   
assign c = a + b;

endmodule
