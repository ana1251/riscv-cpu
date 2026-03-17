`timescale 1ns / 1ps

module cpu_top(
    input clk,
    input reset,
    input load_en,
    input [31:0] load_data,
    input [4:0] load_rd,
    output stop,
    output reg [31:0] cycle_ctr,
    output reg [31:0] instr_ret_ctr,
    output reg [31:0] stall_ctr,
    output reg [31:0] br_flush_ctr,
    output reg [31:0] flush_instr_ctr,
    output reg [31:0] miss_pulse_ctr,
    output reg [31:0] cache_stall_ctr
);

wire [31:0] cache_instr, mem_pc;
wire [31:0] op1, op2, alu_out, mem_rd, imm_b, imm_i, imm_j, imm32, store_data, WB_data, mem_instr;
wire [31:0] pc_reg, pc4_IF, pc4_ID, pc_branch, next_pc, pc_jal, pc_jalr, pc_stall;
wire [6:0] funct7;
wire [4:0] rs1, rs2, rd, WB_reg_sel;
wire [3:0] alu_sel;
wire [2:0] funct3;
wire [1:0] alu_op;
wire reg_we, mem_we, op2_sel, is_sw, mem_sel, WB_we_sel, branch, branch_taken, cache_stall, instr_valid;
wire jal, jalr, redirect, load_hazard, miss_pulse, stall, fetch_stall;

// pipeline registers
reg [31:0] IF_ID_instr, IF_ID_pc;
reg IF_ID_valid;

reg [31:0] ID_EX_op1, ID_EX_op2, ID_EX_pc4, ID_EX_imm32, ID_EX_immb, ID_EX_immj, ID_EX_pc;
reg [6:0] ID_EX_funct7;
reg [4:0] ID_EX_rd, ID_EX_rs1, ID_EX_rs2;
reg [2:0] ID_EX_funct3;
reg [1:0] ID_EX_aluop;
reg ID_EX_reg_we, ID_EX_mem_we, ID_EX_mem_sel, ID_EX_op2_sel, ID_EX_branch, ID_EX_jal, ID_EX_jalr, ID_EX_valid;

reg [31:0] EX_MEM_alu_out, EX_MEM_sd, EX_MEM_pc4, EX_MEM_pcbr, EX_MEM_wbval;
reg [4:0] EX_MEM_rd;
reg EX_MEM_reg_we, EX_MEM_mem_sel, EX_MEM_mem_we, EX_MEM_jal, EX_MEM_jalr, EX_MEM_bt, EX_MEM_valid;

reg [31:0] MEM_WB_alu_out, MEM_WB_mem_rd, MEM_WB_pc4, MEM_WB_wbval;
reg [4:0] MEM_WB_rd;
reg MEM_WB_reg_we, MEM_WB_mem_sel, MEM_WB_jal, MEM_WB_jalr, MEM_WB_valid;


assign imm_b = {{19{IF_ID_instr[31]}}, IF_ID_instr[31], IF_ID_instr[7], IF_ID_instr[30:25], IF_ID_instr[11:8], 1'b0};
assign imm_i = {{20{IF_ID_instr[31]}}, IF_ID_instr[31:20]};
assign imm_j = {{11{IF_ID_instr[31]}}, IF_ID_instr[31], IF_ID_instr[19:12], IF_ID_instr[20], IF_ID_instr[30:21], 1'b0};

assign pc4_IF = pc_reg + 4;
assign pc4_ID = IF_ID_pc + 4;
assign next_pc = (ID_EX_valid && branch_taken) ? pc_branch : 
                 (ID_EX_valid && ID_EX_jal) ? pc_jal : 
                 (ID_EX_valid && ID_EX_jalr) ? pc_jalr : pc4_IF;
assign stop = ID_EX_valid && ID_EX_branch && branch_taken && (pc_branch == ID_EX_pc);

// Hazards          
assign load_hazard = ID_EX_mem_sel && (ID_EX_rd != 0) && ((ID_EX_rd == rs1) || (ID_EX_rd == rs2));
assign redirect = ID_EX_valid && (branch_taken || ID_EX_jal || ID_EX_jalr);

assign fetch_stall = cache_stall || miss_pulse;
assign stall = fetch_stall || load_hazard;
assign pc_stall = redirect ? next_pc : stall ? pc_reg : pc4_IF;


// IF/ID stage
always @(posedge clk) begin
    if (reset) begin
        IF_ID_instr <= 32'h00000013;
        IF_ID_pc <= 32'd0;
        IF_ID_valid <= 0;
    end else if (redirect) begin
        IF_ID_instr <= 32'h00000013;
        IF_ID_pc <= 0;
        IF_ID_valid <= 0;
    end else if (load_hazard) begin
        IF_ID_instr <= IF_ID_instr;
        IF_ID_pc <= IF_ID_pc;
        IF_ID_valid <= IF_ID_valid;
    end else if (instr_valid) begin
        IF_ID_instr <= cache_instr;
        IF_ID_pc <= pc_reg;
        IF_ID_valid <= 1;    
    end else begin
        IF_ID_instr <= IF_ID_instr;
        IF_ID_pc <= IF_ID_pc;
        IF_ID_valid <= 1'b0;
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
        ID_EX_valid <= 0;
    end else if (redirect || load_hazard) begin
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
        ID_EX_valid <= 0;
    end else begin
        ID_EX_rs1 <= rs1;
        ID_EX_rs2 <= rs2;
        ID_EX_op1 <= op1;
        ID_EX_op2 <= op2;
        ID_EX_pc4 <= pc4_ID;
        ID_EX_rd <= rd; 
        ID_EX_imm32 <= imm32;
        ID_EX_immb <= imm_b;
        ID_EX_immj <= imm_j;
        ID_EX_pc <= IF_ID_pc;
        ID_EX_valid <= IF_ID_valid;
        ID_EX_funct3 <= IF_ID_valid ? funct3 : 0;
        ID_EX_aluop <= IF_ID_valid ? alu_op : 0;
        ID_EX_funct7 <= IF_ID_valid ? funct7 : 0;
        ID_EX_jal <= IF_ID_valid ? jal : 0;
        ID_EX_jalr <= IF_ID_valid ? jalr : 0;
        ID_EX_reg_we <= IF_ID_valid ? reg_we : 0;
        ID_EX_mem_we <= IF_ID_valid ? mem_we : 0;
        ID_EX_mem_sel <= IF_ID_valid ? mem_sel : 0;
        ID_EX_op2_sel <= IF_ID_valid ? op2_sel : 0;
        ID_EX_branch <= IF_ID_valid ? branch : 0;
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
        EX_MEM_valid <= 0;
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
        EX_MEM_valid <= ID_EX_valid;
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
        MEM_WB_valid <= 0;
        MEM_WB_wbval <= 0;
    end else begin
        MEM_WB_alu_out <= EX_MEM_alu_out;
        MEM_WB_mem_rd <= mem_rd;
        MEM_WB_pc4 <= EX_MEM_pc4;
        MEM_WB_rd <= EX_MEM_rd;
        MEM_WB_reg_we <= EX_MEM_reg_we;
        MEM_WB_mem_sel <= EX_MEM_mem_sel;
        MEM_WB_jal <= EX_MEM_jal;
        MEM_WB_jalr <= EX_MEM_jalr;
        MEM_WB_valid <= EX_MEM_valid;
        MEM_WB_wbval <= EX_MEM_wbval;
    end
end

// WB Stage
assign WB_data = (load_en == 1) ? load_data : (MEM_WB_mem_sel == 1) ? MEM_WB_mem_rd : MEM_WB_wbval;
assign WB_reg_sel = (load_en == 1) ? load_rd : MEM_WB_rd;
assign WB_we_sel = (load_en == 1) ? 1 : MEM_WB_reg_we;


// Functions called
pc p2 (.clk(clk), .reset(reset), .next_pc(pc_stall), .pc_reg(pc_reg));

instr_memory m2 (.pc_address(mem_pc), .instruction(mem_instr));

instr_cache c1 (.clk(clk), .reset(reset), .pc(pc_reg), .mem_instr(mem_instr), .instr_out(cache_instr),
                .instr_valid(instr_valid), .cache_stall(cache_stall), .mem_pc(mem_pc), .miss_pulse(miss_pulse));

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


// Counters
always @(posedge clk) begin
    if (reset) begin
        cycle_ctr <= 0;
    end else begin
        cycle_ctr <= cycle_ctr + 1;
    end
end

always @(posedge clk) begin
    if (reset) begin
        instr_ret_ctr <= 0;
        stall_ctr <= 0;
        br_flush_ctr <= 0;
        flush_instr_ctr <= 0;
        miss_pulse_ctr <= 0;
        cache_stall_ctr <= 0;
    end else begin
        if (MEM_WB_valid)
            instr_ret_ctr <= instr_ret_ctr + 1;
        if (load_hazard && !fetch_stall)
            stall_ctr <= stall_ctr + 1;
        if (ID_EX_valid && ID_EX_branch && branch_taken && !fetch_stall)
            br_flush_ctr <= br_flush_ctr + 1;
        if (ID_EX_valid && redirect && !fetch_stall)
            flush_instr_ctr <= flush_instr_ctr + ((IF_ID_instr != 32'h00000013) + (cache_instr != 32'h00000013));
        if (miss_pulse)
            miss_pulse_ctr <= miss_pulse_ctr + 1;
        if (fetch_stall)
            cache_stall_ctr <= cache_stall_ctr + 1;
    end
end

endmodule
