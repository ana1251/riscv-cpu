`timescale 1ns / 1ps

module memory(
    input clk,
    input [31:0] addr,
    input we,
    input [31:0] write_data,
    output [31:0] read_data
);

reg [31:0] mem [0:31];
wire [4:0] index;

assign index = addr >> 2;

always @ (posedge clk) begin
    if (we == 1)
         mem[index] = write_data;
    else
        mem[index] = read_data;
end

endmodule
