`timescale 1ns / 1ps

module cpu_top_tb();

reg clk, reset, load_en;
reg [31:0] load_data;
reg [4:0] load_rd;

cpu_top cpu1 (.clk(clk), .reset(reset), .load_en(load_en), .load_data(load_data), .load_rd(load_rd));

always #5 clk = ~clk;

initial begin
    reset = 1;
    load_en = 0;
    clk = 0;
    
    #1;
    cpu1.m1.mem[0] = 32'd10;
    cpu1.m1.mem[1] = 32'd20;
    
    @(posedge clk);
    #1;
    reset = 1;
    #1;
    reset = 0;
    repeat (10) @(posedge clk);

    $finish;

end

endmodule
