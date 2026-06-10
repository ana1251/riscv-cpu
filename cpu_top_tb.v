`timescale 1ns / 1ps

module cpu_top_tb();

reg clk, reset;
reg [4:0] reg_view_sel;
reg [2:0] program_sel;
wire [31:0] reg_view_data;
wire stop;
real cpi, ipc, miss_rate, miss_penalty;
integer timeout;

cpu_top cpu1 (.clk(clk), .reset(reset), .program_sel(program_sel), .reg_view_sel(reg_view_sel), 
              .stop(stop), .reg_view_data(reg_view_data));
              
always #1 clk = ~clk;

initial begin
    timeout = 2_000_000;
    clk = 0;
    program_sel = 2'b11;
    
    #2;
    reset = 1;
    #2;
    reset = 0;
        
    while (!stop && timeout > 0) begin
        @(posedge clk);
        timeout = timeout - 1;
    end
    
    repeat (4) @(posedge clk);

    if (cpu1.alu_error_flag == 0) begin
        case (program_sel)
            2'b000:  begin
                    check_reg(14, 32'h7FFFFFFE);
                    check_reg(15, 32'hFFFFFFFE);
                    check_reg(7, 32'd1);
                    check_reg(8, 32'd0);   
                    check_reg(19, 32'd1);
                    end
            2'b001:  begin
                    check_reg(2, 32'd0);
                    check_reg(1, 32'd28);
                    check_reg(4, 32'd10);
                    check_reg(6, 32'd7);
                    end
            2'b010:  begin
                    check_reg(4, 32'd8);
                    check_reg(5, 32'd9); 
                    check_reg(6, 32'd7);
                    check_mem(0, 32'h00000008);
                    check_mem(1, 32'h00000009);
                    end
            2'b011:  begin
                    check_reg(1, 32'd5050);
                    check_reg(2, 32'd0);
                    check_mem(0, 32'd5050); 
                    end
            default: begin end
        endcase 
        
        $display("PASS: values are correct.");
        
        if (cpu1.instr_ret_ctr != 0 || cpu1.cycle_ctr != 0) begin
            cpi = $itor(cpu1.cycle_ctr) / $itor(cpu1.instr_ret_ctr);
            ipc = 1.0 / cpi;
            miss_rate = $itor(cpu1.miss_ctr) / $itor(cpu1.cache_access_ctr);
            miss_penalty = $itor(cpu1.cache_stall_ctr) /  $itor(cpu1.miss_ctr);
            $display("\nCycle Count: %0d,    Instructions Retired: %0d", cpu1.cycle_ctr, cpu1.instr_ret_ctr);
            $display("Cache Access Count: %0d\n", cpu1.cache_access_ctr);
            $display("Miss Count: %0d,   Cache Stall Count: %0d", cpu1.miss_ctr, cpu1.cache_stall_ctr);
            $display("Load/Fetch Stall Count: %0d,     Branch Flush Count: %0d", cpu1.stall_ctr, cpu1.br_flush_ctr);
            $display("Flushed Instructions Count: %0d", cpu1.flush_instr_ctr);
            $display("Miss Rate: %0f,   Miss Penalty: %0f", miss_rate, miss_penalty);
            $display("\nTotal Branches Taken: %0d", cpu1.total_br_ctr);
            $display("Correct Branch Predictions: %0d,   Branch Mispredictions: %0d", cpu1.correct_br_ctr, cpu1.br_mispredict_ctr);
            $display("\nCPI: %0f", cpi);
            $display("IPC: %0f\n", ipc);
        end else begin
            $display("Could not calculate CPI/IPC");
        end
        $finish;
    end else begin
        $display ("\nProgram has been stopped due to an ERROR in ALU.\n");
        $finish;
    end
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
