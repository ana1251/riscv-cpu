`timescale 1ns / 1ps

module cpu_top(
    input clk,
    input reset,
    input load_en,
    input [31:0] load_data,
    input [4:0] load_rd
);

wire [31:0] instruction, op1, op2, alu_out, mem_rd, imm_b, imm_i, imm_j, imm32, store_data, WB_data;
wire [31:0] pc_reg, pc4_IF, pc4_ID, pc_branch, next_pc, pc_jal, pc_jalr, pc_stall;
wire [6:0] funct7;
wire [4:0] rs1, rs2, rd, WB_reg_sel;
wire [3:0] alu_sel;
wire [2:0] funct3;
wire [1:0] alu_op;
wire reg_we, mem_we, op2_sel, is_sw, mem_sel, WB_we_sel, branch, branch_taken;
wire jal, jalr, redirect, load_hazard;

// pipeline registers
reg [31:0] IF_ID_instr, IF_ID_pc;

reg [31:0] ID_EX_op1, ID_EX_op2, ID_EX_pc4, ID_EX_imm32, ID_EX_immb, ID_EX_immj, ID_EX_pc;
reg [6:0] ID_EX_funct7;
reg [4:0] ID_EX_rd, ID_EX_rs1, ID_EX_rs2;
reg [2:0] ID_EX_funct3;
reg [1:0] ID_EX_aluop;
reg ID_EX_reg_we, ID_EX_mem_we, ID_EX_mem_sel, ID_EX_op2_sel, ID_EX_branch, ID_EX_jal, ID_EX_jalr;

reg [31:0] EX_MEM_alu_out, EX_MEM_sd, EX_MEM_pc4, EX_MEM_pcbr, EX_MEM_wbval;
reg [4:0] EX_MEM_rd;
reg EX_MEM_reg_we, EX_MEM_mem_sel, EX_MEM_mem_we, EX_MEM_jal, EX_MEM_jalr, EX_MEM_bt;

reg [31:0] MEM_WB_alu_out, MEM_WB_mem_rd, MEM_WB_pc4;
reg [4:0] MEM_WB_rd;
reg MEM_WB_reg_we, MEM_WB_mem_sel, MEM_WB_jal, MEM_WB_jalr;


assign imm_b = {{19{IF_ID_instr[31]}}, IF_ID_instr[31], IF_ID_instr[7], IF_ID_instr[30:25], IF_ID_instr[11:8], 1'b0};
assign imm_i = {{20{IF_ID_instr[31]}}, IF_ID_instr[31:20]};
assign imm_j = {{11{IF_ID_instr[31]}}, IF_ID_instr[31], IF_ID_instr[19:12], IF_ID_instr[20], IF_ID_instr[30:21], 1'b0};

assign pc4_IF = pc_reg + 4;
assign pc4_ID = IF_ID_pc + 4;
assign next_pc = branch_taken ? pc_branch : (ID_EX_jal ? pc_jal : ID_EX_jalr ? pc_jalr : pc4_IF);
assign pc_stall = redirect ? next_pc : load_hazard ? pc_reg : next_pc;

// Hazards          
assign load_hazard = ID_EX_mem_sel && (ID_EX_rd != 0) && ((ID_EX_rd == rs1) || (ID_EX_rd == rs2));
assign redirect = branch_taken || ID_EX_jal || ID_EX_jalr;

// IF/ID stage
always @(posedge clk) begin
    if (reset) begin
        IF_ID_instr <= 32'h00000013;
        IF_ID_pc <= 32'd0;
    end else if (redirect) begin
        IF_ID_instr <= 32'h00000013;
        IF_ID_pc <= IF_ID_pc;
    end else if (load_hazard) begin
        IF_ID_instr <= IF_ID_instr;
        IF_ID_pc <= IF_ID_pc;
    end else begin
        IF_ID_instr <= instruction;
        IF_ID_pc <= pc_reg;
    end
end

// ID/EX stage
always @(posedge clk) begin
    if (reset) begin
        ID_EX_rs1 <= 0;
        ID_EX_rs2 <= 0;
        ID_EX_op1 <= 0;
        ID_EX_op2 <= 0;
        ID_EX_pc4 <= 0;
        ID_EX_rd <= 0;
        ID_EX_reg_we <= 0;
        ID_EX_mem_we <= 0;
        ID_EX_mem_sel <= 0;
        ID_EX_op2_sel <= 0;
        ID_EX_imm32 <= 0;
        ID_EX_immb <= 0;
        ID_EX_immj <= 0;
        ID_EX_branch <= 0;
        ID_EX_pc <= 0;
        ID_EX_funct3 <= 0;
        ID_EX_aluop <= 0;
        ID_EX_funct7 <= 0;
        ID_EX_jal <= 0;
        ID_EX_jalr <= 0;
    end else if (load_hazard) begin
        ID_EX_reg_we <= 0;
        ID_EX_mem_we <= 0;
        ID_EX_mem_sel <= 0;
        ID_EX_branch <= 0;
        ID_EX_rd <= 0;
        ID_EX_jal <= 0;
        ID_EX_jalr <= 0;
        ID_EX_op2_sel <= 0;
        ID_EX_funct3 <= 0;
        ID_EX_aluop <= 0;
        ID_EX_funct7 <= 0;
    end else if (redirect) begin
        ID_EX_reg_we <= 0;
        ID_EX_mem_we <= 0;
        ID_EX_mem_sel <= 0;
        ID_EX_branch <= 0;
        ID_EX_rd <= 0;
        ID_EX_jal <= 0;
        ID_EX_jalr <= 0;
        ID_EX_rd <= 0;
        ID_EX_op2_sel <= 0;
        ID_EX_funct3 <= 0;
        ID_EX_aluop <= 0;
        ID_EX_funct7 <= 0; 
    end else begin
        ID_EX_rs1 <= rs1;
        ID_EX_rs2 <= rs2;
        ID_EX_op1 <= op1;
        ID_EX_op2 <= op2;
        ID_EX_pc4 <= pc4_ID;
        ID_EX_rd <= rd;
        ID_EX_reg_we <= reg_we;
        ID_EX_mem_we <= mem_we;
        ID_EX_mem_sel <= mem_sel;
        ID_EX_op2_sel <= op2_sel;
        ID_EX_branch <= branch;
        ID_EX_imm32 <= imm32;
        ID_EX_immb <= imm_b;
        ID_EX_immj <= imm_j;
        ID_EX_pc <= IF_ID_pc;
        ID_EX_funct3 <= funct3;
        ID_EX_aluop <= alu_op;
        ID_EX_funct7 <= funct7;
        ID_EX_jal <= jal;
        ID_EX_jalr <= jalr; 
    end
end

// EX/MEM stage
always @(posedge clk) begin
    if(reset) begin
        EX_MEM_rd <= 0;
        EX_MEM_alu_out <= 0;
        EX_MEM_reg_we <= 0;
        EX_MEM_mem_sel <= 0;
        EX_MEM_mem_we <= 0;
        EX_MEM_sd <= 0;
        EX_MEM_pc4 <= 0;
        EX_MEM_jal <= 0;
        EX_MEM_jalr <= 0;
        EX_MEM_pcbr <= 0;
        EX_MEM_bt <= 0;
        EX_MEM_wbval <= 0;
    end else begin
        EX_MEM_rd <= ID_EX_rd;
        EX_MEM_alu_out <= alu_out;
        EX_MEM_reg_we <= ID_EX_reg_we;
        EX_MEM_mem_sel <= ID_EX_mem_sel;
        EX_MEM_mem_we <= ID_EX_mem_we;
        EX_MEM_sd <= store_data;
        EX_MEM_pc4 <= ID_EX_pc4;
        EX_MEM_jal <= ID_EX_jal;
        EX_MEM_jalr <= ID_EX_jalr;
        EX_MEM_pcbr <= pc_branch;
        EX_MEM_bt <= branch_taken;
        EX_MEM_wbval <= (ID_EX_jal || ID_EX_jalr) ? ID_EX_pc4 : alu_out;
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
        MEM_WB_alu_out <= EX_MEM_alu_out;
        MEM_WB_mem_rd <= mem_rd;
        MEM_WB_pc4 <= EX_MEM_pc4;
        MEM_WB_rd <= EX_MEM_rd;
        MEM_WB_reg_we <= EX_MEM_reg_we;
        MEM_WB_mem_sel <= EX_MEM_mem_sel;
        MEM_WB_jal <= EX_MEM_jal;
        MEM_WB_jalr <= EX_MEM_jalr;
    end
end

// WB Stage
assign WB_data = (load_en == 1) ? load_data :
                 (MEM_WB_mem_sel == 1) ? MEM_WB_mem_rd :
                 (MEM_WB_jal || MEM_WB_jalr) ? MEM_WB_pc4 : MEM_WB_alu_out;
assign WB_reg_sel = (load_en == 1) ? load_rd : MEM_WB_rd;
assign WB_we_sel = (load_en == 1) ? 1 : MEM_WB_reg_we;


pc p2 (.clk(clk), .reset(reset), .next_pc(pc_stall), .pc_reg(pc_reg));

instr_memory m2 (.pc_address(pc_reg), .instruction(instruction));

decoder d2 (.instruction(IF_ID_instr), .rs1(rs1), .rs2(rs2), .rd(rd), .reg_we(reg_we),
            .mem_we(mem_we), .op2_sel(op2_sel), .is_sw(is_sw), .mem_sel(mem_sel), .funct3(funct3),
            .funct7(funct7), .alu_op(alu_op), .branch(branch), .jal(jal), .jalr(jalr));                
ID_stage id1 (.clk(clk), .instruction(IF_ID_instr), .rs1(rs1), .rs2(rs2), .WB_reg_sel(WB_reg_sel),
              .WB_data(WB_data), .op2_sel(op2_sel), .WB_we_sel(WB_we_sel), .is_sw(is_sw), .op1(op1),
              .op2(op2), .imm32(imm32));

alu_control a1 (.alu_op(ID_EX_aluop), .funct3(ID_EX_funct3), .funct7(ID_EX_funct7), .alu_sel(alu_sel));

EX_stage ex1 (.idex_rs1(ID_EX_rs1), .idex_rs2(ID_EX_rs2), .idex_op1(ID_EX_op1), .idex_op2(ID_EX_op2),
              .idex_imm32(ID_EX_imm32), .idex_immj(ID_EX_immj), .idex_op2_sel(ID_EX_op2_sel), .idex_alusel(alu_sel),
              .idex_branch(ID_EX_branch), .idex_funct3(ID_EX_funct3), .idex_pc(ID_EX_pc), .idex_immb(ID_EX_immb),
              .exmem_rd(EX_MEM_rd), .exmem_alu_out(EX_MEM_alu_out), .exmem_wbval(EX_MEM_wbval), .exmem_reg_we(EX_MEM_reg_we),
              .exmem_memsel(EX_MEM_mem_sel), .memwb_reg_we(MEM_WB_reg_we), .memwb_rd(MEM_WB_rd), .wb_data(WB_data),
              .alu_out(alu_out), .store_data(store_data), .branch_taken(branch_taken), .pc_branch(pc_branch),
              .pc_jal(pc_jal), .pc_jalr(pc_jalr));

memory m1 (.clk(clk), .addr(EX_MEM_alu_out), .mem_we(EX_MEM_mem_we), .read_data(mem_rd), .write_data(EX_MEM_sd));

endmodule
