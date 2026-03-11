`timescale 1ns / 1ps

module instr_cache(
    input clk,
    input reset,
    input [31:0] pc,
    input [31:0] mem_instr,
    output reg [31:0] instr_out,
    output reg cache_stall,
    output wire [31:0] mem_pc,
    output miss_pulse
);

reg [31:0] data [0:15];
reg [25:0] tag [0:15];
reg valid [0:15];
reg [31:0] miss_pc;
reg [3:0] miss_index;
reg [25:0] miss_tag;
reg [1:0] miss_timer = 2'd3;
reg miss;
wire [3:0] index;
wire [25:0] pc_tag;
wire hit;
integer i;

assign index = pc[5:2];
assign pc_tag = pc[31:6];
assign hit = (valid[index] && tag[index] == pc_tag);
assign miss_pulse = (!miss && !hit);
assign mem_pc = miss ? miss_pc : pc;

always @ (posedge clk) begin
    if (reset) begin
        instr_out <= 32'h00000013;
        cache_stall <= 0;
        miss <= 0;
        miss_timer <= 0;
        miss_pc <= 0;
        miss_index <= 0;
        miss_tag <= 0;
        
        for (i = 0; i < 16; i = i+1) begin
            data[i] <= 0;
            tag[i] <= 0;
            valid[i] <= 0;
        end
        
    end else begin
        if (miss) begin
            cache_stall <= 1'b1;
            
            if (miss_timer != 0) begin
                instr_out <= 32'h00000013;
                miss_timer = miss_timer - 1;
            end else begin
                data[miss_index] <= mem_instr;
                tag[miss_index] <= miss_tag;
                valid[miss_index] <= 1'b1;
                instr_out <= mem_instr;
                cache_stall <= 0;
                miss <= 0;
            end
            
        end else begin
            if (hit) begin
                instr_out <= data[index];
                cache_stall <= 0;
            end else begin
                miss <= 1;
                cache_stall <= 1;
                miss_index <= index;
                miss_tag <= pc_tag;
                miss_timer <= 2'd3;
                instr_out <= 32'h00000013;
            end
        end
    end
end
endmodule
