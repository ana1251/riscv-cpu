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

reg [31:0] data_p1 [15:0], data_p2 [15:0];
reg [25:0] tag_p1 [15:0], tag_p2 [15:0];
reg valid_p1 [15:0], valid_p2 [15:0], lru [15:0];

reg [31:0] miss_pc;
reg [3:0] miss_index;
reg [25:0] miss_tag;
reg miss;
wire [3:0] index;
wire [25:0] pc_tag;
wire hit_p1, hit_p2, hit;
integer i;

assign index = pc[5:2];
assign pc_tag = pc[31:6];
assign hit_p1 = (valid_p1[index] && tag_p1[index] == pc_tag);
assign hit_p2 = (valid_p2[index] && tag_p2[index] == pc_tag);
assign hit = hit_p1 || hit_p2;
assign mem_pc = miss ? miss_pc : pc;
assign miss_pulse = (!miss && !hit);
assign cache_stall = miss;
assign instr_out = instr_valid ? (hit_p1 ? data_p1[index] : hit_p2 ? data_p2[index] : 32'h00000013) : 
                   32'h00000013;
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
            data_p1[i] <= 32'h00000013;
            data_p2[i] <= 32'h00000013;
            tag_p1[i] <= 0;
            tag_p2[i] <= 0;
            valid_p1[i] <= 0;
            valid_p2[i] <= 0;
            lru[i] <= 0;
        end
        
    end else begin
        if (miss) begin
            if (ready) begin
                if (!valid_p1[miss_index]) begin
                    data_p1[miss_index] <= mem_instr;
                    tag_p1[miss_index] <= miss_tag;
                    valid_p1[miss_index] <= 1'b1;
                    lru[miss_index] <= 1'b0;
                end else if (!valid_p2[miss_index]) begin
                    data_p2[miss_index] <= mem_instr;
                    tag_p2[miss_index] <= miss_tag;
                    valid_p2[miss_index] <= 1'b1;
                    lru[miss_index] <= 1'b1;
                end else if (lru[miss_index] == 1'b0)begin
                    data_p2[miss_index] <= mem_instr;
                    tag_p2[miss_index] <= miss_tag;
                    valid_p2[miss_index] <= 1'b1;
                    lru[miss_index] <= 1'b1;
                end else begin
                    data_p1[miss_index] <= mem_instr;
                    tag_p1[miss_index] <= miss_tag;
                    valid_p1[miss_index] <= 1'b1;
                    lru[miss_index] <= 1'b0;
                end
                miss <= 0;
                request <= 0;
            end
        end else if (!hit) begin
            miss <= 1;
            request <= 1;
            miss_pc <= pc;
            miss_index <= index;
            miss_tag <= pc_tag;
        end else if (hit_p1) begin
            lru[index] <= 1'b0;        // path 1 recently used
        end else if (hit_p2) begin
            lru[index] <= 1'b1;        // path 2 recently used
        end
    end
    
    if (fetch_req) begin
        cache_access_ctr <= cache_access_ctr + 1;
    end
end

endmodule
