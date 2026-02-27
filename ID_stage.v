`timescale 1ns / 1ps

module ID_stage(
    input clk,
    input [31:0] instruction,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] WB_reg_sel,
    input [31:0] WB_data,
    input op2_sel,
    input WB_we_sel,
    input is_sw,
    output [31:0] op1,
    output [31:0] op2,
    output [31:0] imm32
);

wire [11:0] imm12, imm_s, imm_l;
wire [31:0] op1_f, op2_f;

assign imm_l = instruction[31:20];
assign imm_s = {instruction[31:25], instruction[11:7]};
assign imm12 = (is_sw == 1) ? imm_s : imm_l;
assign imm32 = {{20{imm12[11]}}, imm12};

regfile dut (
    .clk(clk), .write_enable(WB_we_sel), .read_ad1(rs1), .read_ad2(rs2),
    .write_ad(WB_reg_sel), .write_data(WB_data), .rd1(op1_f), .rd2(op2_f));
   
assign op1 = (WB_we_sel &&(WB_reg_sel != 0) && (WB_reg_sel == rs1)) ? WB_data : op1_f;
assign op2 = (WB_we_sel &&(WB_reg_sel != 0) && (WB_reg_sel == rs2)) ? WB_data : op2_f;
   
endmodule
