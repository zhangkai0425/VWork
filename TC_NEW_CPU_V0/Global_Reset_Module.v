`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/13 11:06:50
// Design Name: 
// Module Name: Global_Reset_Module
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Global_Reset_Module(

	input I_clk,
    input I_locked,
    output O_Rst_n,
	output O_pll_rst_n,
    output O_pll_trig
	
    );

reg[19:0]    rst_cnt;
reg[19:0]    rst_cnt1;
reg          O_Rst_n;
reg          O_pll_rst_n;
reg          O_pll_trig;

always @ (posedge I_clk)begin
	if (I_locked == 1'b0) 
		rst_cnt <= 20'h00000;
	else begin
		if (rst_cnt == 20'hfffff) 	
			rst_cnt <= 20'hfffff;
		else 
			rst_cnt <= rst_cnt + 1'b1;
	end
end	

always @(posedge I_clk)begin
	if (rst_cnt >= 20'h1fff)
		O_pll_rst_n <= 1'b1	;
    else
        O_pll_rst_n <= 1'b0	;
end

always @(posedge I_clk)begin
	if (rst_cnt >= 20'hfff00)
		O_Rst_n <= 1'b1	;
    else
        O_Rst_n <= 1'b0	;
end

always @(posedge I_clk)begin
	if (rst_cnt == 20'hfffff)
		O_pll_trig <= 1'b1	;
    else
        O_pll_trig <= 1'b0	;
end
	
endmodule
