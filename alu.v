`timescale 1ns / 1ps

`define ALU_ADD     4'b0000
`define ALU_SUB     4'b0001
`define ALU_AND     4'b0010
`define ALU_OR      4'b0011
`define ALU_XOR     4'b0100
`define ALU_SLT     4'b0101
`define ALU_SLTU    4'b0110
`define ALU_SLL     4'b0111
`define ALU_SRL     4'b1000
`define ALU_SRA     4'b1001

module alu(
    input [31:0] a,
    input [31:0] b,
    input [3:0] alu_sel,
    output reg [31:0] c
);

always @(*) begin
    case (alu_sel)
        `ALU_ADD: c = a + b;
        `ALU_SUB: c = a - b;
        `ALU_AND: c = a & b;
        `ALU_OR: c = a | b;
        `ALU_XOR: c = a ^ b;
        `ALU_SLT: c = ($signed(a) < $signed(b)) ? 1 : 0;
        `ALU_SLTU: c = (a < b) ? 1 : 0;
        `ALU_SLL: c = a << b[4:0];
        `ALU_SRL: c = a >> b[4:0];
        `ALU_SRA: c = $signed(a) >>> b[4:0];
        default: c = 0;
    endcase
end

endmodule
