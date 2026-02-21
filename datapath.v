`timescale 1ns / 1ps

module datapath(
    input clk,
    input we,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input [4:0] load_rd,
    input load_en,             // when load_en = 1, write the immediate value
    input [31:0] load_data,     // load the actual data into the registers from ALU
    input op2_sel,
    input is_sw,
    input [31:0] instruction,
    input mem_sel,
    input [31:0] mem_rd,
    input [2:0] funct3,
    output [31:0] op2,
    output [31:0] alu_out,
    output [3:0] alu_sel,
    input branch,
    output reg branch_taken
);

wire [31:0] op1;
wire [31:0] wb;
wire [4:0] reg_sel;
wire we_sel;
wire [31:0] alu_b, imm32;
wire [11:0] imm12;
wire [11:0] imm_s, imm_l;
wire beq, blt, bltu;

assign wb = (load_en == 1) ? load_data : (mem_sel == 1) ? mem_rd : alu_out;
assign reg_sel = (load_en == 1) ? load_rd : rd;
assign we_sel = (load_en == 1) ? 1 : we;

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
    .clk(clk), .write_enable(we_sel), .read_ad1(rs1), .read_ad2(rs2),
    .write_ad(reg_sel), .write_data(wb), .rd1(op1), .rd2(op2));

alu num1 (.a(op1), .b(alu_b), .alu_sel(alu_sel), .c(alu_out));

endmodule
