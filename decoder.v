`timescale 1ns / 1ps

module decoder(
    input [31:0] instruction,
    output [4:0] rs1,
    output [4:0] rs2,
    output [4:0] rd,
    output we
);
   
// R-type instruction format for ADD rd, rs1, rs2:
// funct7, rs2, rs1, funct3, rd, opcode
// 7       5    5    3       5   7 (number of bits)
// 0000 000x xxxx yyyy y000 zzzz z011 0011
// rd = z, rs2 = x, rs1 = y
//if instruction opcode = 011 0011, if funct3 bits = 000, and if funct7 bits = 0000000

wire [31:0] ins;

assign ins = instruction & 32'hFE00707F;

assign we = (ins == 32'h00000033) ? 1 : 0;

assign rs1 = (instruction >> 15) & 5'b11111;
assign rs2 = (instruction >> 20) & 5'b11111;
assign rd = (instruction >> 7) & 5'b11111;

endmodule 
