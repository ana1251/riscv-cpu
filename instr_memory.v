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
