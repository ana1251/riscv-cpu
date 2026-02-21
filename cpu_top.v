`timescale 1ns / 1ps

module cpu_top(
    input clk,
    input reset,
    input load_en,
    input [31:0] load_data,
    input [4:0] load_rd
);

wire [31:0] instruction;
wire [31:0] pc_reg;
wire [31:0] op2, alu_out, mem_rd, imm_b;
wire [4:0] rs1, rs2, rd;
wire reg_we, mem_we, op2_sel, is_sw, mem_sel, branch, branch_taken;
wire [1:0] alu_op;
wire [2:0] funct3;
wire [6:0] funct7;
wire [3:0] alu_sel;
wire [31:0] pc4, pc_branch, next_pc;

assign imm_b = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
assign pc4 = pc_reg + 4;
assign pc_branch = pc_reg + imm_b;
assign next_pc = branch_taken ? pc_branch : pc4;

pc p2 (.clk(clk), .reset(reset), .next_pc(next_pc), .pc_reg(pc_reg));

instr_memory m2 (.pc_address(pc_reg), .instruction(instruction));

alu_control a1 (.alu_op(alu_op), .funct3(funct3), .funct7(funct7), .alu_sel(alu_sel));

decoder d2 (.instruction(instruction), .rs1(rs1), .rs2(rs2), .rd(rd), .reg_we(reg_we),
            .mem_we(mem_we), .op2_sel(op2_sel), .is_sw(is_sw), .mem_sel(mem_sel), .funct3(funct3),
            .funct7(funct7), .alu_op(alu_op), .branch(branch));
            
datapath dp1 (.clk(clk), .we(reg_we), .rs1(rs1), .rs2(rs2), .rd(rd), .load_rd(load_rd),
              .load_en(load_en), .load_data(load_data), .op2_sel(op2_sel), .is_sw(is_sw),
              .mem_sel(mem_sel), .instruction(instruction), .mem_rd(mem_rd), .funct3(funct3), 
              .op2(op2), .alu_out(alu_out), .alu_sel(alu_sel), .branch(branch),
              .branch_taken(branch_taken));

memory m1 (.clk(clk), .addr(alu_out), .mem_we(mem_we), .read_data(mem_rd), .write_data(op2));

endmodule
