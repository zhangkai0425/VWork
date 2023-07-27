`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/08/24 16:02:43
// Design Name:
// Module Name: UART_RX_DATA
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


module UART_RX_DATA(

	input	I_clk_10M,
	input	I_rst_n,
	input   rxb,
	input   [4:0]   GA,

	output  [31:0]  cycle_num,
	output  [31:0]  sample_length,
	output  [31:0]  wait_time

    );

wire[7:0]	W_rx_data	;
wire		W_rx_data_vld	;

UART_driver inst_uart_driver(
	.rst_n(I_rst_n),
	.clk_10M(I_clk_10M),
	.rxb(rxb),
	.txb(),
	.rx_reg(W_rx_data),
	.rx_ready(W_rx_data_vld),
	.FE(),
	.tx_ready(),
	.tx_ena(),
	.tx_data()
);

UART_Rx inst_rx(
	.clk            (I_clk_10M),
	.rst_n          (I_rst_n),
	.frame_data_in  (W_rx_data),
	.frame_data_ena (W_rx_data_vld),
	.GA             (GA),
	.cycle_num      (cycle_num),
	.sample_length  (sample_length),
	.wait_time      (wait_time)
);

endmodule
