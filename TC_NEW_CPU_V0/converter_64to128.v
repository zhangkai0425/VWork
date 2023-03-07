`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Zhangkai
//
// Create Date: 2023/3/7 10:59
// Design Name:
// Module Name: converter_64to128
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


module converter_64to128(
	input 			clk_i,
	input  [63:0]   isa_data_i,
    input           isa_wren_i,
    input  [31:0]   isa_addr_i,

    input           clk_cpu;
	input 			rstn,
	output [127:0] 	isa_data_o,
	output 			isa_wren_o,
	output [31:0] 	isa_addr_o
    );

endmodule
