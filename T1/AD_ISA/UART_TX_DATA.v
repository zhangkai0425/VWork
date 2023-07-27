`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/08/24 18:49:46
// Design Name:
// Module Name: UART_TX_DATA
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


module UART_TX_DATA(
	input	I_clk_10M	,
	input	I_rst_n	,
	output	txb	,
	input	I_data_valid	,
	input[63:0] I_data,

	output  O_tx_ready
    );



wire		tx_ready	;
wire		tx_ena		;
wire[7:0]	tx_data		;



UART_driver inst_uart_driver(
	.rst_n(I_rst_n),
	.clk_10M(I_clk_10M),
	.rxb(),
	.txb(txb),
	.rx_reg(),
	.rx_ready(),
	.FE(),
	.tx_ready(tx_ready),
	.tx_ena(tx_ena),
	.tx_data(tx_data)

);

UART_Tx  inst_tx(
	.rst_n(I_rst_n),
	.clk(I_clk_10M),
	.I_tx_ready(tx_ready),
	.I_data(I_data),
	.I_data_valid(I_data_valid),
	.tx_en(tx_ena),
	.tx_data(tx_data),
	.O_tx_ready(O_tx_ready)
);
endmodule
