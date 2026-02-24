`timescale 1ns / 1ps

module ID_stage(
    input clk,
    input [31:0] instruction,
    input [4:0] rs1,
    input [4:0] rs2,
    input [2:0] funct3,
    input [4:0] WB_reg_sel,
    input [31:0] WB_data,
    input op2_sel,
    input WB_we_sel,
    input is_sw,
    input branch,
    output [31:0] op1,
    output [31:0] op2,
    output [31:0] alu_b,
    output reg branch_taken
);

wire [31:0] imm32;
wire [11:0] imm12;
wire [11:0] imm_s, imm_l;
wire beq, blt, bltu;

assign imm_l = instruction[31:20];
assign imm_s = {instruction[31:25], instruction[11:7]};
assign imm12 = (is_sw == 1) ? imm_s : imm_l;
assign imm32 = {{20{imm12[11]}}, imm12};
assign alu_b = (op2_sel == 1) ? imm32 : op2;

assign beq = (op1 == alu_b);
assign blt = ($signed(op1) < $signed(alu_b));
assign bltu = (op1 < alu_b);

always @(*) begin
    branch_taken = 0;
    if (branch) begin
        case (funct3)
            3'b000: branch_taken = beq;
            3'b001: branch_taken = ~beq;
            3'b100: branch_taken = blt;
            3'b101: branch_taken = ~blt;
            3'b110: branch_taken = bltu;
            3'b111: branch_taken = ~bltu;
            default: branch_taken = 0;
        endcase
     end
 end

regfile dut (
    .clk(clk), .write_enable(WB_we_sel), .read_ad1(rs1), .read_ad2(rs2),
    .write_ad(WB_reg_sel), .write_data(WB_data), .rd1(op1), .rd2(op2));
   
endmodule
