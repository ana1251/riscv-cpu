`timescale 1ns / 1ps


module regfile(
    input clk,
    input reset,
    input write_enable,
    input [4:0] read_ad1,
    input [4:0] read_ad2,
    input [4:0] write_ad,
    input [31:0] write_data,
    output [31:0] rd1,
    output [31:0] rd2
);

reg [31:0] regs [31:0];
integer i;

assign rd1 = (read_ad1 == 0) ? 32'b0 : regs[read_ad1];
assign rd2 = (read_ad2 == 0) ? 32'b0 : regs[read_ad2];

always @ (posedge clk) begin
    if (reset) begin
        for (i = 0; i < 32; i = i+1) begin
            regs[i] = 0;
        end
    end else begin
        if((write_enable != 0) && (write_ad != 0))
            regs[write_ad] <= write_data;
    end
end

endmodule
