`timescale 1ns / 1ps

module instr_memory(
    input [31:0] pc_address,
    output [31:0] instruction
);
    
reg [31:0] mem [31:0];
wire [4:0] index;
integer i;

initial begin
    for (i = 0; i <= 31; i = i+1) 
        mem[i] = 32'h00000000;
        
    mem[0] = 32'h00000093;   // ADDI x1, x0, 0
    mem[1] = 32'h0000a103;   // LW x2, 0(x1)
    mem[2] = 32'h0040a183;   // lw x3, 4(x1)
    mem[3] = 32'h00310233;   // add x4, x2, x3
    mem[4] = 32'h0040a423;   // sw x4, 8(x1)
end

assign index = pc_address / 4;
assign instruction = mem[index];
 
endmodule









`timescale 1ns / 1ps

module instr_memory(
    input [31:0] pc_address,
    output [31:0] instruction
);
    
reg [31:0] mem [31:0];
wire [4:0] index;
integer i;

initial begin
    for (i = 0; i <= 31; i = i+1) 
        mem[i] = 32'h00000000;
        
  //  mem[0] = 32'h00000093;   // ADDI x1, x0, 0
  //  mem[1] = 32'h0000a103;   // LW x2, 0(x1)
  //  mem[2] = 32'h0040a183;   // LW x3, 4(x1)
    mem[3] = 32'h00500093; // addi x1, x0, 5
    mem[4] = 32'hFFD00113; // addi x2, x0, -3
    mem[5] = 32'h00100193; // addi x3, x0, 1
    mem[6] = 32'h01F00213; // addi x4, x0, 31

    mem[7] = 32'h002082B3; // add x5, x1, x2
    mem[8] = 32'h40208333; // sub x6, x1, x2

    mem[9] = 32'h001123B3; // slt x7, x2, x1
    mem[10] = 32'h00113433; // sltu x8, x2, x1
    mem[11] = 32'h00012493; // slti x9, x2, 0
    mem[12] = 32'h00013513; // sltiu x10, x2, 0

    mem[13] = 32'h003195B3; // sll x11, x3, x3
    mem[14] = 32'h00419613; // slli x12, x3, 4
    mem[15] = 32'h00265693; // srli x13, x12, 2
    mem[16] = 32'h00115713; // srli x14, x2, 1
    mem[17] = 32'h40115793; // srai x15, x2, 1

    mem[18] = 32'h00315833; // srl x16, x2, x3
    mem[19] = 32'h403158B3; // sra x17, x2, x3

    mem[20] = 32'h01F19913; // slli x18, x3, 31
    mem[21] = 32'h01F95993; // srli x19, x18, 31

end

assign index = pc_address / 4;
assign instruction = mem[index];
 
endmodule
