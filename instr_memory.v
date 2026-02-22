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
        
    mem[0] = 32'h00000093; // addi x1, x0, 0 ; sum = 0
    mem[1] = 32'h00500113; // addi x2, x0, 5 ; counter = 5
    mem[2] = 32'h00100193; // addi x3, x0, 1 ; x3 = 1

    // loop:
    mem[3] = 32'h002080b3; // add x1, x1, x2 ; sum += counter
    mem[4] = 32'hfff10113; // addi x2, x2, -1 ; counter--
    mem[5] = 32'hfe011ce3; // bne x2, x0, -8 ; if counter != 0, jump to loop

    // call subroutine at +12 bytes (to mem[9])
    mem[6] = 32'h00c002ef; // jal x5, +12 ; x5 = return addr (pc+4)

    // after return:
    mem[7] = 32'h00a00213; // addi x4, x0, 10 ; x4 = 10
    mem[8] = 32'h0100006f; // jal x0, +16 ; jump over subroutine to done

    // subroutine (starts here at mem[9]):
    mem[9] = 32'h0030c0b3; // xor x1, x1, x3 ; x1 ^= 1
    mem[10] = 32'h00109093; // slli x1, x1, 1 ; x1 <<= 1
    mem[11] = 32'h00028067; // jalr x0, 0(x5) ; return to x5

    // done:
    mem[12] = 32'h00700313; // addi x6, x0, 7 ; x6 = 7 (marker that we reached done)
    mem[13] = 32'h00000063; // beq x0, x0, 0 ; infinite loop (halts)

end

assign index = pc_address / 4;
assign instruction = mem[index];
 
endmodule
