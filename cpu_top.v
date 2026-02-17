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
wire [31:0] op2, alu_out, mem_rd;
wire [4:0] rs1, rs2, rd;
wire we, op2_sel, is_sw;

pc p2 (.clk(clk), .reset(reset), .pc_reg(pc_reg));

instr_memory m2 (.pc_address(pc_reg), .instruction(instruction));

decoder d2 (.instruction(instruction), .rs1(rs1), .rs2(rs2), .rd(rd), .we(we),
            .op2_sel(op2_sel), .is_sw(is_sw));
            
datapath dp1 (.clk(clk), .we(we), .rs1(rs1), .rs2(rs2), .rd(rd), .load_rd(load_rd),
              .load_en(load_en), .load_data(load_data), .op2_sel(op2_sel), .is_sw(is_sw),
              .instruction(instruction), .mem_rd(mem_rd), .op2(op2), .alu_out(alu_out));

memory m1 (.clk(clk), .addr(alu_out), .we(we), .read_data(), .write_data(op2));

endmodule
