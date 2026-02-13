`timescale 1ns / 1ps

//have 32 registers, need 5 bits to select one (log2 (32) = 5)

module regfile(
    input clk,
    input write_enable,      //read (1) or write (0)
    input [4:0] read_ad1,    //select which register to read for first operand
    input [4:0] read_ad2,    //select which register to read for second operand
    input [4:0] write_ad,    //select which register to write to
    input [31:0] write_data, //the result from ALU that is written into the register above
    output [31:0] rd1,       //outputs the contents of the first operand's register
    output [31:0] rd2        //outputs the contents of the second operand's register
);

reg [31:0] regs [31:0];
integer i;

 initial begin
    for (i = 0; i < 32; i = i+1)
        regs[i] = 0;
    end  

assign rd1 = (read_ad1 == 0) ? 32'b0 : regs[read_ad1];
assign rd2 = (read_ad2 == 0) ? 32'b0 : regs[read_ad2];

always @ (posedge clk) begin
    if((write_enable != 0) && (write_ad != 0))
       regs[write_ad] <= write_data;
end

endmodule
