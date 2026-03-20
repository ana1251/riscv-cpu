`timescale 1ns / 1ps

`define ALU_ADD     4'b0000
`define ALU_SUB     4'b0001
`define ALU_AND     4'b0010
`define ALU_OR      4'b0011
`define ALU_XOR     4'b0100
`define ALU_SLT     4'b0101
`define ALU_SLTU    4'b0110
`define ALU_SLL     4'b0111
`define ALU_SRL     4'b1000
`define ALU_SRA     4'b1001

module alu_control(
    input [1:0] alu_op,
    input [2:0] funct3,
    input [6:0] funct7,
    output reg [3:0] alu_sel
);

always @(*) begin
    case (alu_op)
        2'b00: alu_sel = `ALU_ADD;     // for load/store
        2'b01: alu_sel = `ALU_SUB;     // for branches
        2'b10: begin               // R-type
               case ({funct7, funct3})
                    10'b0000000000: alu_sel = `ALU_ADD;
                    10'b0100000000: alu_sel = `ALU_SUB;
                    10'b0000000111: alu_sel = `ALU_AND;
                    10'b0000000110: alu_sel = `ALU_OR;
                    10'b0000000100: alu_sel = `ALU_XOR;
                    10'b0000000010: alu_sel = `ALU_SLT;
                    10'b0000000011: alu_sel = `ALU_SLTU;
                    10'b0000000001: alu_sel = `ALU_SLL;
                    10'b0000000101: alu_sel = `ALU_SRL;
                    10'b0100000101: alu_sel = `ALU_SRA;
                    default: alu_sel = 0;
               endcase
               end
        2'b11: begin               // I-type
               case (funct3)
                    3'b000: alu_sel = `ALU_ADD;   // addi
                    3'b111: alu_sel = `ALU_AND;   // andi
                    3'b110: alu_sel = `ALU_OR;    // ori
                    3'b100: alu_sel = `ALU_XOR;   // xori
                    3'b010: alu_sel = `ALU_SLT;   // slti
                    3'b011: alu_sel = `ALU_SLTU;  // sltiu
                    3'b001: alu_sel = `ALU_SLL;   // slli
                    3'b101: begin
                            if (funct7 == 7'b0000000)
                                alu_sel = `ALU_SRL;   // srli
                            else if (funct7 == 7'b0100000)
                                alu_sel = `ALU_SRA;   // srai
                            end
                    default: alu_sel = 0;
               endcase
               end
        default: alu_sel = 0;
    endcase
end

endmodule
