`timescale 1ns / 1ps

module EX_stage(
    input clk,
    input reset,
    input idex_valid,
    input [4:0] idex_rs1,
    input [4:0] idex_rs2,
    input [4:0] idex_rd,
    input [31:0] idex_op1,
    input [31:0] idex_op2,
    input [31:0] idex_imm32,
    input [31:0] idex_immj,
    input idex_op2_sel,
    input [3:0] idex_alusel,
    input idex_branch,
    input [2:0] idex_funct3,
    input [31:0] idex_pc,
    input [31:0] idex_immb,
    input [4:0] exmem_rd,
    input [31:0] exmem_alu_out,
    input [31:0] exmem_wbval,
    input exmem_reg_we,
    input exmem_memsel,
    input memwb_reg_we,
    input [4:0] memwb_rd,
    input [31:0] wb_data,
    output [31:0] alu_out,
    output [31:0] store_data,
    output reg branch_taken,
    output [31:0] pc_branch,
    output [31:0] pc_jal,
    output [31:0] pc_jalr,
    output alu_compare_stall,
    output alu_error_flag
);

reg [31:0] saved_a, saved_b, saved_oldc, saved_alusel, saved_c;
reg alu_compare, error_flag;
wire [31:0] forward_a, forward_rs2, forward_rdval, copy_aluout, copy_aluout_val, alu_b, old_c, fault;
wire beq, blt, bltu;

assign forward_a = (exmem_reg_we && (exmem_rd != 0) && (exmem_rd == idex_rs1) && !exmem_memsel) ? exmem_wbval :
                   (memwb_reg_we && (memwb_rd != 0) && (memwb_rd == idex_rs1)) ? wb_data : idex_op1;
assign forward_rs2 = (exmem_reg_we && (exmem_rd != 0) && (exmem_rd == idex_rs2) && !exmem_memsel) ? exmem_wbval :
                     (memwb_reg_we && (memwb_rd != 0) && (memwb_rd == idex_rs2)) ? wb_data : idex_op2; 
assign forward_rdval = (exmem_reg_we && (exmem_rd != 0) && (exmem_rd == idex_rs2) && !exmem_memsel) ? exmem_wbval :
                     (memwb_reg_we && (memwb_rd != 0) && (memwb_rd == idex_rs2)) ? wb_data : idex_rd; 

assign store_data = forward_rs2;
assign alu_b = (idex_op2_sel) ? idex_imm32 : forward_rs2;

alu main_alu (.a(forward_a), .b(alu_b), .old_c(forward_rdval), .alu_sel(idex_alusel), .c(alu_out));


assign pc_branch = idex_pc + idex_immb;
assign pc_jal = idex_pc + idex_immj;
assign pc_jalr = (forward_a + idex_imm32) & 32'hfffffffe;

assign beq = (forward_a == forward_rs2);
assign blt = ($signed(forward_a) < $signed(forward_rs2));
assign bltu = (forward_a < forward_rs2);

always @(*) begin
    branch_taken = 0;
    if (idex_branch) begin
        case (idex_funct3)
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


alu copy_alu (.a(saved_a), .b(saved_b), .old_c(saved_oldc), .alu_sel(saved_alusel), .c(copy_aluout));

assign alu_compare_stall = alu_compare;
assign alu_error_flag = error_flag;

// No fault:
assign copy_aluout_val = copy_aluout;

// Fault injection test: 
//assign fault = saved_c + 32'd5;
//assign copy_aluout_val = fault;

always @(posedge clk) begin
    if(reset) begin
        alu_compare <= 0;
        error_flag <= 0;
    end else begin
        if (alu_compare) begin
            if (copy_aluout_val != saved_c) begin
                error_flag <= 1;
            end
            alu_compare <= 0;
        end else if (idex_valid) begin
            saved_a <= forward_a;
            saved_b <= alu_b;
            saved_oldc <= forward_rdval;
            saved_alusel <= idex_alusel;
            saved_c <= alu_out;
            alu_compare <= 1;
        end
    end
end

endmodule
