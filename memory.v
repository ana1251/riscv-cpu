`timescale 1ns / 1ps

module memory(
    input clk,
    input [31:0] addr,
    input mem_we,
    input [31:0] write_data,
    output [31:0] read_data
);

reg [31:0] mem [0:31];
wire [4:0] index;
integer i;

assign index = addr >> 2;
assign read_data = mem[index];

always @ (posedge clk) begin
    if (mem_we == 1)
         mem[index] <= write_data;
end

initial begin
    for (i = 0; i < 32; i = i+1)
        mem[i] <= 32'h00000000;
end

endmodule
