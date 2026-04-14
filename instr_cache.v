`timescale 1ns / 1ps

module instr_cache(
    input clk,
    input reset,
    input [31:0] pc,
    input [31:0] mem_instr,
    input fetch_req,
    input ready,
    output reg request,
    output [31:0] instr_out,
    output instr_valid,
    output cache_stall,
    output [31:0] mem_pc,
    output miss_pulse,
    output reg [31:0] cache_access_ctr
);

reg [31:0] data [15:0];
reg [25:0] tag [15:0];
reg valid [15:0];

reg [31:0] miss_pc;
reg [3:0] miss_index;
reg [25:0] miss_tag;
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
assign cache_stall = miss;
assign instr_out = instr_valid ? data[index] : 32'h00000013;
assign instr_valid = hit && !miss && !reset;


always @(posedge clk) begin
    if (reset) begin
        miss <= 0;
        miss_pc <= 0;
        miss_index <= 0;
        miss_tag <= 0;
        request <= 0;
        cache_access_ctr <= 0;
                
        for (i = 0; i < 16; i = i+1) begin
            data[i] <= 32'h00000013;
            tag[i] <= 0;
            valid[i] <= 0;
        end
        
    end else begin
        if (miss) begin
            if (ready) begin
                data[miss_index] <= mem_instr;
                tag[miss_index] <= miss_tag;
                valid[miss_index] <= 1'b1;
                miss <= 0;
                request <= 0;
            end
        end else if (!hit) begin
            miss <= 1;
            request <= 1;
            miss_pc <= pc;
            miss_index <= index;
            miss_tag <= pc_tag;
        end
    end
    
    if (fetch_req) begin
        cache_access_ctr <= cache_access_ctr + 1;
    end
end

endmodule
