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
    load_data = 0;
    load_rd = 0;
    clk = 0;
    
    @(posedge clk);
    #1;
    reset = 1;
    #1;
    reset = 0;
    repeat (30) @(posedge clk);
    
    #100;

    check_reg(1, 32'd28);
    check_reg(2, 32'd0);
    check_reg(3, 32'd1);
    check_reg(4, 32'd10);   
    check_reg(5, 32'h0000001c);
    check_reg(6, 32'd7);
    
    $display("PASS: values are correct.");

    $finish;

end

task check_reg(
    input [4:0] regnum,
    input [31:0] expected
);

reg [31:0] actual;

begin
    actual = cpu1.dp1.dut.regs[regnum];

    if (actual != expected) begin
        $display("FAIL: x%0d expected %h but got %h.", regnum, expected, actual);
        $finish;
    end
end
endtask

endmodule




