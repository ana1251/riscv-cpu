`timescale 1ns / 1ps

module instr_cache(
    input clk,
    input reset,
    input [31:0] pc,
    input [31:0] mem_instr,
    output reg [31:0] instr_out,
    output reg [31:0] instr_pc,
    output reg instr_valid,
    output cache_stall,
    output wire [31:0] mem_pc,
    output miss_pulse
);

reg [31:0] data [15:0];
reg [25:0] tag [15:0];
reg valid [15:0];
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
assign mem_pc = miss ? miss_pc : pc;
assign miss_pulse = (!miss && !hit);
assign cache_stall = miss || miss_pulse;


always @(posedge clk) begin
    if (reset) begin
        miss <= 0;
        miss_timer <= 0;
        miss_pc <= 0;
        miss_index <= 0;
        miss_tag <= 0;
        instr_out <= 32'h00000013;
        instr_pc <= 32'h00000000;
        instr_valid <= 0;
                
        for (i = 0; i < 16; i = i+1) begin
            data[i] <= 32'h00000013;
            tag[i] <= 0;
            valid[i] <= 0;
        end
        
    end else begin
        instr_valid <= 0;
    
        if (miss) begin            
            if (miss_timer != 0) begin
                miss_timer <= miss_timer - 1;
            end else begin
                data[miss_index] <= mem_instr;
                tag[miss_index] <= miss_tag;
                valid[miss_index] <= 1'b1;
                instr_out <= mem_instr;
                instr_pc <= miss_pc;
                instr_valid <= 1;
                miss <= 0;
            end
            
        end else begin
            if (hit) begin
                instr_out <= data[index];
                instr_pc <= pc;
                instr_valid <= 1;
            end else begin
                miss <= 1;
                miss_pc <= pc;
                miss_index <= index;
                miss_tag <= pc_tag;
                miss_timer <= 2'd3;
            end
        end
    end
end
endmodule
