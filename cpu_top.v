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
wire [31:0] op1, op2, alu_out, mem_rd, imm_b, imm_j;
wire [4:0] rs1, rs2, rd;
wire reg_we, mem_we, op2_sel, is_sw, mem_sel, branch, branch_taken;
wire [1:0] alu_op;
wire [2:0] funct3;
wire [6:0] funct7;
wire [3:0] alu_sel;
wire [31:0] pc4_IF, pc4_ID, pc_branch, next_pc, pc_jal, pc_jalr;
wire jal, jalr;
wire [31:0] alu_b;
wire [4:0] WB_reg_sel;
wire [31:0] WB_data;
wire WB_we_sel;

// pipeline registers
reg [31:0] IF_ID_instr, IF_ID_pc;
reg [31:0] ID_EX_op1, ID_EX_op2, ID_EX_alub;
reg [3:0] ID_EX_alusel, ID_EX_pc4;
reg [4:0] ID_EX_rd;
reg ID_EX_reg_we, ID_EX_mem_we, ID_EX_mem_sel;
reg ID_EX_jal, ID_EX_jalr;
reg [31:0] MEM_WB_alu_out, MEM_WB_mem_rd, MEM_WB_pc4;
reg [4:0] MEM_WB_rd;
reg MEM_WB_reg_we, MEM_WB_mem_sel, MEM_WB_jal, MEM_WB_jalr;


assign imm_b = {{19{IF_ID_instr[31]}}, IF_ID_instr[31], IF_ID_instr[7], IF_ID_instr[30:25], IF_ID_instr[11:8], 1'b0};
assign imm_j = {{11{IF_ID_instr[31]}}, IF_ID_instr[31], IF_ID_instr[19:12], IF_ID_instr[20], IF_ID_instr[30:21], 1'b0};

assign pc4_IF = pc_reg + 4;
assign pc4_ID = IF_ID_pc + 4;
assign pc_branch = IF_ID_pc + imm_b;
assign next_pc = jal ? pc_jal : jalr ? pc_jalr : branch_taken ? pc_branch : pc4_IF;

assign pc_jal = IF_ID_pc + imm_j;
assign pc_jalr = (op1+ imm_j) & ~32'd1;

// IF/ID stage
always @(posedge clk) begin
    if (reset) begin
        IF_ID_instr <= 32'h00000013;
        IF_ID_pc <= 32'd0;
    end else begin
        IF_ID_instr <= instruction;
        IF_ID_pc <= pc_reg;
    end
end

// ID/EX stage
always @(posedge clk) begin
    if (reset) begin
        ID_EX_op1 <= 0;
        ID_EX_op2 <= 0;
        ID_EX_alub <= 0;
        ID_EX_alusel <= 0;
        ID_EX_pc4 <= 0;
        ID_EX_rd <= 0;
        ID_EX_reg_we <= 0;
        ID_EX_mem_we <= 0;
        ID_EX_mem_sel <= 0;
        ID_EX_jal <= 0;
        ID_EX_jalr <= 0;
    end else begin
        ID_EX_op1 <= op1;
        ID_EX_op2 <= op2;
        ID_EX_alub <= alu_b;
        ID_EX_alusel <= alu_sel;
        ID_EX_pc4 <= pc4_ID;
        ID_EX_rd <= rd;
        ID_EX_reg_we <= reg_we;
        ID_EX_mem_we <= mem_we;
        ID_EX_mem_sel <= mem_sel;
        ID_EX_jal <= jal;
        ID_EX_jalr <= jalr; 
    end
end

// MEM/WB stage
always @(posedge clk) begin
    if (reset) begin
        MEM_WB_alu_out <= 0;
        MEM_WB_mem_rd <= 0;
        MEM_WB_pc4 <= 0;
        MEM_WB_rd <= 0;
        MEM_WB_reg_we <= 0;
        MEM_WB_mem_sel <= 0;
        MEM_WB_jal <= 0;
        MEM_WB_jalr <= 0;
    end else begin
        MEM_WB_alu_out <= alu_out;
        MEM_WB_mem_rd <= mem_rd;
        MEM_WB_pc4 <= ID_EX_pc4;
        MEM_WB_rd <= ID_EX_rd;
        MEM_WB_reg_we <= ID_EX_reg_we;
        MEM_WB_mem_sel <= ID_EX_mem_sel;
        MEM_WB_jal <= ID_EX_jal;
        MEM_WB_jalr <= ID_EX_jalr;
    end
end

// WB Stage
assign WB_data = (load_en == 1) ? load_data :
                 (MEM_WB_mem_sel == 1) ? MEM_WB_mem_rd :
                 (MEM_WB_jal || MEM_WB_jalr) ? MEM_WB_pc4 : MEM_WB_alu_out;
assign WB_reg_sel = (load_en == 1) ? load_rd : MEM_WB_rd;
assign WB_we_sel = (load_en == 1) ? 1 : MEM_WB_reg_we;

// IF/ID stage
pc p2 (.clk(clk), .reset(reset), .next_pc(next_pc), .pc_reg(pc_reg));
instr_memory m2 (.pc_address(pc_reg), .instruction(instruction));


//ID/EX stage
decoder d2 (.instruction(IF_ID_instr), .rs1(rs1), .rs2(rs2), .rd(rd), .reg_we(reg_we),
            .mem_we(mem_we), .op2_sel(op2_sel), .is_sw(is_sw), .mem_sel(mem_sel), .funct3(funct3),
            .funct7(funct7), .alu_op(alu_op), .branch(branch), .jal(jal), .jalr(jalr));                
ID_stage id1 (.clk(clk), .instruction(IF_ID_instr), .rs1(rs1), .rs2(rs2), .funct3(funct3),
              .WB_reg_sel(WB_reg_sel), .WB_data(WB_data), .op2_sel(op2_sel), .WB_we_sel(WB_we_sel),
              .is_sw(is_sw), .branch(branch), .op1(op1), .op2(op2), .alu_b(alu_b), .branch_taken(branch_taken));

//EX stage
alu_control a1 (.alu_op(alu_op), .funct3(funct3), .funct7(funct7), .alu_sel(alu_sel));
alu num1 (.a(ID_EX_op1), .b(ID_EX_alub), .alu_sel(ID_EX_alusel), .c(alu_out));

// MEM stage
memory m1 (.clk(clk), .addr(alu_out), .mem_we(ID_EX_mem_we), .read_data(mem_rd), .write_data(ID_EX_op2));

endmodule
