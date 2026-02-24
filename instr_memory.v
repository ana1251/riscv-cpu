`timescale 1ns / 1ps

module instr_memory(
    input [31:0] pc_address,
    output [31:0] instruction
);
    
reg [31:0] mem [31:0];
wire [4:0] index;
integer i;

initial begin
    for(i = 0; i < 32; i = i+1)
        mem[i] = 32'h00000000;

    mem[0] = 32'h00500093;   // addi x1, x0, 5
    mem[1] = 32'h00300113;   // addi x2, x0, 3
    mem[2] = 32'h002081b3;   // add x3, x1, x2

end

assign index = pc_address / 4;
assign instruction = mem[index];
 
endmodule

/*
// ALU tests
    mem[0]  = 32'h00500093; // addi x1, x0, 5
    mem[1]  = 32'hFFD00113; // addi x2, x0, -3
    mem[2]  = 32'h00100193; // addi x3, x0, 1
    mem[3]  = 32'h01F00213; // addi x4, x0, 31
    mem[4]  = 32'h002082B3; // add  x5, x1, x2
    mem[5]  = 32'h40208333; // sub  x6, x1, x2
    mem[6]  = 32'h001123B3; // slt  x7, x2, x1
    mem[7]  = 32'h00113433; // sltu x8, x2, x1
    mem[8]  = 32'h00012493; // slti x9, x2, 0
    mem[9]  = 32'h00013513; // sltiu x10, x2, 0
    mem[10] = 32'h003195B3; // sll  x11, x3, x3
    mem[11] = 32'h00419613; // slli x12, x3, 4
    mem[12] = 32'h00265693; // srli x13, x12, 2
    mem[13] = 32'h00115713; // srli x14, x2, 1
    mem[14] = 32'h40115793; // srai x15, x2, 1
    mem[15] = 32'h00315833; // srl  x16, x2, x3
    mem[16] = 32'h403158B3; // sra  x17, x2, x3
    mem[17] = 32'h01F19913; // slli x18, x3, 31
    mem[18] = 32'h01F95993; // srli x19, x18, 31
    // pad / stop
    mem[19] = 32'h00000063; // beq x0, x0, 0 (loop)

// Control Test
    mem[0] = 32'h00000093; // addi x1, x0, 0
    mem[1] = 32'h00500113; // addi x2, x0, 5
    mem[2] = 32'h00100193; // addi x3, x0, 1
    mem[3] = 32'h002080b3; // add  x1, x1, x2
    mem[4] = 32'hfff10113; // addi x2, x2, -1
    mem[5] = 32'hfe011ce3; // bne  x2, x0, -8   (loop)
    mem[6] = 32'h00c002ef; // jal  x5, +12
    mem[7] = 32'h00a00213; // addi x4, x0, 10
    mem[8] = 32'h0100006f; // jal  x0, +16
    mem[9] = 32'h0030c0b3; // xor  x1, x1, x3
    mem[10]= 32'h00109093; // slli x1, x1, 1
    mem[11]= 32'h00028067; // jalr x0, 0(x5)
    mem[12]= 32'h00700313; // addi x6, x0, 7
    mem[13]= 32'h00000063; // beq x0, x0, 0

// Memory Test
    mem[0] = 32'h00000093; // addi x1, x0, 0
    mem[1] = 32'h00800113; // addi x2, x0, 8
    mem[2] = 32'h00900193; // addi x3, x0, 9
    mem[3] = 32'h0020A023; // sw x2, 0(x1)
    mem[4] = 32'h0030A223; // sw x3, 4(x1)
    mem[5] = 32'h0000A203; // lw x4, 0(x1)
    mem[6] = 32'h0040A283; // lw x5, 4(x1)
    mem[7] = 32'h00700313; // addi x6, x0, 7 done marker
    mem[8] = 32'h00000063; // beq x0, x0, 0

*/
