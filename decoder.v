`timescale 1ns / 1ps

module decoder(
    input [31:0] instruction,
    output [4:0] rs1,
    output [4:0] rs2,
    output [4:0] rd,
    output reg_we,
    output mem_we,
    output op2_sel,
    output is_sw,
    output mem_sel
);

wire is_add, is_addi, is_lw;
wire [6:0] opcode = instruction[31:25];
wire [6:0] funct7 = instruction[6:0];
wire [2:0] funct3 = instruction[14:12];

assign is_add = (opcode == 7'b0110011) && (funct3 == 3'b000) && (funct7 == 7'b0000000);
assign is_addi = (opcode == 7'b0010011) && (funct3 == 3'b000);
assign is_lw = (opcode == 7'b0000011) && (funct3 == 3'b010);
assign is_sw = (opcode == 7'b0100011) && (funct3 == 3'b010);

assign op2_sel = is_addi| is_lw | is_sw;
assign reg_we = is_add | is_addi | is_lw;
assign mem_we = is_sw;
assign mem_sel = is_lw;

assign rs1 = instruction[19:15];
assign rs2 = instruction[24:20];
assign rd = instruction[11:7];

endmodule


// R-type instruction format for ADD rd, rs1, rs2:
// funct7, rs2, rs1, funct3, rd, opcode
// 7       5    5    3       5   7 (number of bits)
// 0000 000x xxxx yyyy y000 zzzz z011 0011
// rd = z, rs2 = x, rs1 = y
// Opcode = 011 0011, funct3 = 000, funct7 bits = 000 0000


// I-type instruction format for ADDI rd, rs1, imm
// imm, rs1, funct3, rd, opcode
// 12   5    3       5   7
// xxxx xxxx xxxx yyyy y000 zzzz z001 0011
// imm = x, rs1 = y, rd = z
// Opcode: 001 0011, funct3 = 000


// I-type instruction format for load word (LW)
// rd = M[rs1 + imm][0:31]
// imm, rs1, funct3, rd, opcode
// 12   5    3       5   7
// xxxx xxxx xxxx yyyy y010 zzzz z000 0011
// imm = x, rs1 = y, rd = z
// Opcode: 000 0011, funct3 = 010


// S-type instruction format for store word (SW)
// M[rs1 + imm][0:31] = rs2[0:31]
// imm[11:5], rs2, rs1, funct3, imm[4:0], opcode
// 7          5    5    3       5         7
// xxxx xxxy yyyy zzzz z010 xxxx x010 0011
// imm = x, rs2 = y, rs1 = z
// Opcode: 010 0011, funct3 = 010


