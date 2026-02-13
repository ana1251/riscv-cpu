`timescale 1ns / 1ps

module instr_memory(
    input [31:0] pc_address,
    output [31:0] instruction
);
   
reg [31:0] mem [31:0];
wire [4:0] index;
integer i;

// general format: 0000 000x xxxx yyyy y000 zzzz z011 0011
// ADD rd, rs1, rs2

initial begin
    for (i = 0; i <= 31; i = i+1)
        mem[i] = 32'h00000000;
       
    mem[0] = 32'h00510193;  // ADDI r3, r2, 5
    mem[1] = 32'h003102b3;  // ADD r5, r2, r3
    mem[2] = 32'h00228333;  // ADD r6, r5, r2
end

assign index = pc_address / 4;
assign instruction = mem[index];
 
endmodule
