`timescale 1ns / 1ps

module pc(
    input clk,
    input reset,
    input [31:0] next_pc,
    output reg [31:0] pc_reg
);

always @ (posedge clk) begin
    if (reset)
        pc_reg <= 32'd0;
    else
        pc_reg <= next_pc;
end

endmodule
