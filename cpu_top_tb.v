`timescale 1ns / 1ps

module cpu_top_tb();

reg clk, reset, load_en;
reg [31:0] load_data;
reg [4:0] load_rd;
wire stop;
wire [31:0] cycle_ctr, instr_ret_ctr, stall_ctr, br_flush_ctr, flush_instr_ctr, miss_pulse_ctr, cache_stall_ctr;
real cpi, ipc;
integer timeout;

cpu_top cpu1 (.clk(clk), .reset(reset), .load_en(load_en), .load_data(load_data), .load_rd(load_rd),
              .stop(stop), .cycle_ctr(cycle_ctr), .instr_ret_ctr(instr_ret_ctr), .stall_ctr(stall_ctr),
              .br_flush_ctr(br_flush_ctr), .flush_instr_ctr(flush_instr_ctr), .miss_pulse_ctr(miss_pulse_ctr),
              .cache_stall_ctr(cache_stall_ctr));

always #1 clk = ~clk;

initial begin
    timeout = 2_000_000;
    reset = 1;
    load_en = 0;
    load_data = 0;
    load_rd = 0;
    clk = 0;
    
    @(posedge clk);
    reset = 1;
    #5;
    reset = 0;
    
    while (!stop && timeout > 0) begin
        @(posedge clk);
        timeout = timeout - 1;
    end
    
    repeat (4) @(posedge clk);

  // ALU Tests 
    check_reg(14, 32'h7FFFFFFE);
    check_reg(15, 32'hFFFFFFFE);
    check_reg(7, 32'd1);
    check_reg(8, 32'd0);   
    check_reg(19, 32'd1);
    
    $display("PASS: values are correct.");
    
    @(posedge clk);
    
    if (instr_ret_ctr != 0 || cycle_ctr != 0) begin
        cpi = $itor(cycle_ctr) / $itor(instr_ret_ctr);
        ipc = 1.0 / cpi;
        $display("\nCycle Count: %0d,    Instructions Retired: %0d", cycle_ctr, instr_ret_ctr);
        $display("Miss Counter: %0d,   Cache Stall Counter: %0d", miss_pulse_ctr, cache_stall_ctr);
        $display("Stall Count: %0d,     Branch Flush Count: %0d", stall_ctr, br_flush_ctr);
        $display("Flushed Instructions Count: %0d", flush_instr_ctr);
        $display("CPI: %0f", cpi);
        $display("IPC: %0f\n", ipc);
    end else begin
        $display("Could not calculate CPI/IPC");
    end 

    $finish;

end


task check_reg(
    input [4:0] regnum,
    input [31:0] expected
);

reg [31:0] actual;

begin
    actual = cpu1.id1.dut.regs[regnum];

    if (actual != expected) begin
        $display("REGISTER FAIL: x%0d expected %h but got %h.", regnum, expected, actual);
        $finish;
    end
end
endtask


task check_mem(
    input [4:0] memnum,
    input [31:0] expected
);

reg [31:0] actual;

begin
    actual = cpu1.m1.mem[memnum];

    if (actual != expected) begin
        $display("MEMORY FAIL: index %0d expected %h but got %h.", memnum, expected, actual);
        $finish;
    end
end
endtask


endmodule


/*

 
  // Control Tests  
    check_reg(2, 32'd0);
    check_reg(1, 32'd28);
    check_reg(4, 32'd10);
    check_reg(6, 32'd7);
  
   // Memory Tests
    check_reg(4, 32'd8);
    check_reg(5, 32'd9); 
    check_reg(6, 32'd7);
    check_mem(0, 32'h00000008);
    check_mem(1, 32'h00000009); 

*/
