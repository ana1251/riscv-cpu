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
        
 //   mem[0] = 32'h00000093;   // ADDI x1, x0, 0
 //   mem[1] = 32'h0000a103;   // LW x2, 0(x1)
 //   mem[2] = 32'h0040a183;   // LW x3, 4(x1)
    mem[3] = 32'h00310463;   // beq x2, x3, 8 (offset)
    mem[4] = 32'h00100213;   // addi x4, x0, 1
    mem[5] = 32'h00200293;   // addi x5, x0, 2

end

assign index = pc_address / 4;
assign instruction = mem[index];
 
endmodule
