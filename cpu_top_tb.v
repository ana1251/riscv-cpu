reg clk, reset, load_en;
reg [31:0] load_data;
reg [4:0] load_rd;
wire [31:0] cycle_ctr, instr_ret_ctr, stall_ctr, br_flush_ctr;
wire [31:0] cycle_ctr, instr_ret_ctr, stall_ctr, br_flush_ctr, flush_instr_ctr;
real cpi, ipc;
integer timeout, stable;

cpu_top cpu1 (.clk(clk), .reset(reset), .load_en(load_en), .load_data(load_data), .load_rd(load_rd),
.cycle_ctr(cycle_ctr), .instr_ret_ctr(instr_ret_ctr), .stall_ctr(stall_ctr),
              .br_flush_ctr(br_flush_ctr));
              .br_flush_ctr(br_flush_ctr), .flush_instr_ctr(flush_instr_ctr));

always #5 clk = ~clk;

initial begin
    timeout = 2_000_000;
    stable = 0;
reset = 1;
load_en = 0;
load_data = 0;
@@ -26,16 +29,22 @@ initial begin
reset = 1;
#50;
reset = 0;
    repeat (50) @(posedge clk);

    #100;
    while (stable < 1 && timeout > 0) begin
        @(posedge clk);
        timeout = timeout - 1;
        if (cpu1.IF_ID_instr == 32'h00000063)
            stable = stable + 1;
    end
    
    repeat (4) @(posedge clk);

   // Memory Tests
    check_reg(4, 32'd8);
    check_reg(5, 32'd9); 
    check_reg(6, 32'd7);
    check_mem(0, 32'h00000008);
    check_mem(1, 32'h00000009); 
  // ALU Tests 
    check_reg(14, 32'h7FFFFFFE);
    check_reg(15, 32'hFFFFFFFE);
    check_reg(7, 32'd1);
    check_reg(8, 32'd0);   
    check_reg(19, 32'd1); 

$display("PASS: values are correct.");

@@ -46,6 +55,7 @@ initial begin
assign ipc = 1 / cpi;
$display("Cycle Count: %0d,  Instructions Retired: %0d", cycle_ctr, instr_ret_ctr);
$display("Stall Count: %0d,  Branch Flush Count: %0d", stall_ctr, br_flush_ctr);
        $display("Flushed Instructions Count: %0d", flush_instr_ctr);
$display("CPI: %0f", cpi);
$display("IPC: %0f", ipc);
end else begin
@@ -97,21 +107,20 @@ endmodule


/*
  // ALU Tests 
    check_reg(14, 32'h7FFFFFFE);
    check_reg(15, 32'hFFFFFFFE);
    check_reg(7, 32'd1);
    check_reg(8, 32'd0);   
    check_reg(19, 32'd1); 


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

