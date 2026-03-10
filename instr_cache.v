`timescale 1ns / 1ps

module instr_cache(
    input clk,
    input reset,
    input [31:0] pc,
    input [31:0] mem_instr,
    output [31:0] instr_out,
    output cache_stall,
    output miss_pulse
);

assign instr_out = mem_instr;
assign cache_stall = 1'b0;
assign miss_pulse = 1'b0;

endmodule
