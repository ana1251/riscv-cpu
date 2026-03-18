`timescale 1ns / 1ps

module board_display(
    input clk,
    input reset,
    input left_scroll,
    input right_scroll,
    input [1:0] program_sel,
    input [4:0] reg_view_sel,
    output stop,
    output reg dp, 
    output reg [6:0] seg,
    output reg [3:0] an
    );

wire [1:0] disp_sel;
reg [3:0] num_disp;
wire [31:0] reg_view_data;
reg [2:0] scroll_pos;
reg [19:0] ctr;
wire [15:0] display_data;
reg edge_det_l, edge_det_r;

cpu_top cpu1 (.clk(clk), .reset(reset), .program_sel(program_sel), .reg_view_sel(reg_view_sel),
              .reg_view_data(reg_view_data), .stop(stop));

assign disp_sel = ctr[17:16];
assign display_data = reg_view_data >> (scroll_pos * 4);

always @(posedge clk) begin
    ctr <= ctr + 1;
    edge_det_l <= left_scroll;
    edge_det_r <= right_scroll;
    
    if(reset) begin
        scroll_pos <= 3'd0;
    end else begin
        if (!edge_det_r && right_scroll && scroll_pos > 0)
            scroll_pos <= scroll_pos - 1;
        if (!edge_det_l && left_scroll && scroll_pos < 4)
            scroll_pos <= scroll_pos + 1;
    end
end

always @(*) begin
    dp = 1'b1;
    an = 4'b1111;
    num_disp = 4'h0;
    
    case (disp_sel)
        2'b00: begin an = 4'b1110; num_disp = display_data[3:0]; end
        2'b01: begin an = 4'b1101; num_disp = display_data[7:4]; end
        2'b10: begin an = 4'b1011; num_disp = display_data[11:8]; end
        2'b11: begin an = 4'b0111; num_disp = display_data[15:12]; end
    endcase

    case (num_disp)
        4'h0: seg = 7'b0000001;
        4'h1: seg = 7'b1001111;
        4'h2: seg = 7'b0010010;
        4'h3: seg = 7'b0000110;
        4'h4: seg = 7'b1001100;
        4'h5: seg = 7'b0100100;
        4'h6: seg = 7'b0100000;
        4'h7: seg = 7'b0001111;
        4'h8: seg = 7'b0000000;
        4'h9: seg = 7'b0000100;
        4'hA: seg = 7'b0001000;
        4'hB: seg = 7'b1100000;
        4'hC: seg = 7'b0110001;
        4'hD: seg = 7'b1000010;
        4'hE: seg = 7'b0110000;
        4'hF: seg = 7'b0111000;
        default: seg = 7'b1111111;
    endcase
end
endmodule
