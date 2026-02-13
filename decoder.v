`timescale 1ns / 1ps

module decoder(
    input [31:0] instruction,
    output [4:0] rs1,
    output [4:0] rs2,
    output [4:0] rd,
    output we,
    output op2_sel
);

wire [31:0] add_ins, addi_ins;
wire [11:0] imm;

assign add_ins = instruction & 32'hFE00707F;
assign addi_ins = instruction & 32'h0000707F;
assign imm = instruction[31:20];

// choose whether to store in rs2 or imm
assign op2_sel = (addi_ins == 32'h00000013) ? 1 : 0;
assign we = (add_ins == 32'h00000033 || addi_ins == 32'h00000013) ? 1 : 0;

assign rs1 = (instruction >> 15) & 5'b11111;
assign rs2 = (instruction >> 20) & 5'b11111;
assign rd = (instruction >> 7) & 5'b11111;

endmodule


// R-type instruction format for ADD rd, rs1, rs2:
// funct7, rs2, rs1, funct3, rd, opcode
// 7       5    5    3       5   7 (number of bits)
// 0000 000x xxxx yyyy y000 zzzz z011 0011
// rd = z, rs2 = x, rs1 = y
// Opcode = 011 0011, funct3 = 000, funct7 bits = 000 0000


// I-type instructions format for ADDI rd, rs1, imm
// imm, rs1, funct3, rd, opcode
// 12   5    3       5   7
// xxxx xxxx xxxx yyyy y000 zzzz z001 0011
// imm = x, rs1 = y, rd = z
// Opcode: 001 0011, funct3 = 000
