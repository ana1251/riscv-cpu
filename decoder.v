`timescale 1ns / 1ps

module decoder(
    input [31:0] instruction,
    output [4:0] rs1,
    output [4:0] rs2,
    output [4:0] rd,
    output reg reg_we,
    output reg mem_we,
    output reg op2_sel,
    output reg is_sw,
    output reg mem_sel,
    output [2:0] funct3,
    output [6:0] funct7,
    output reg [1:0] alu_op,
    output reg branch
);

wire is_r, is_i, is_lw, is_s, is_br;
wire [6:0] opcode = instruction[6:0];

assign funct7 = instruction[31:25];
assign funct3 = instruction[14:12];

assign is_r = (opcode == 7'b0110011);
assign is_i = (opcode == 7'b0010011);
assign is_lw = (opcode == 7'b0000011);
assign is_s = (opcode == 7'b0100011);
assign is_br = (opcode == 7'b1100011);

always @ (*) begin
    branch = 0;
    reg_we = 0;
    mem_we = 0;
    op2_sel = 0;
    is_sw = 0;
    mem_sel = 0;
    alu_op = 2'b00;
    
    if (is_r) begin
        reg_we = 1;
        op2_sel = 0;
        mem_sel = 0;
        alu_op = 2'b10;
    end else if (is_i) begin
        reg_we = 1;
        op2_sel = 1;
        mem_sel = 0;
        alu_op = 2'b11;
    end else if (is_lw) begin
        reg_we = 1;
        op2_sel = 1;
        mem_sel = 1;
        alu_op = 2'b00;   
    end else if (is_s) begin
        reg_we = 0;
        mem_we = 1;
        op2_sel = 1;
        is_sw = 1;
        alu_op = 2'b00;
    end else if (is_br) begin
        branch = 1;
        reg_we = 0;
        mem_we = 0;
        op2_sel = 0;
        mem_sel = 0;
        alu_op = 2'b01; 
    end
end

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


