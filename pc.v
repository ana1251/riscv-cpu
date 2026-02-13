`timescale 1ns / 1ps

module pc(
    input clk,
    input reset,
    output [31:0] pc_reg
);

reg [31:0] current_pc = 32'd0;
wire [31:0] next_pc;

assign next_pc = current_pc + 32'd4;

always @ (posedge clk) begin
    if (reset)
        current_pc <= 0;
    else
        current_pc <= next_pc;
end

assign pc_reg = current_pc;

endmodule
