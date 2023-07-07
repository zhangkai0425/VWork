`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2023/07/05 16:00:00
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

	input	I_clk_10M	,
	input	I_rst_n	,
	input   rxb	,
	input[4:0]   GA,
    // Write : UART->RAM
    // Write Enable port 1-4
    output           O_WEA_RAM1  ,
    output           O_WEA_RAM2  ,
    output           O_WEA_RAM3  ,
    output           O_WEA_RAM4  ,

    // Write Wave ID port 1-4
    output    [10:0] O_WRITE_ADDR_RAM1 ,
    output    [10:0] O_WRITE_ADDR_RAM2 ,
    output    [10:0] O_WRITE_ADDR_RAM3 ,
    output    [10:0] O_WRITE_ADDR_RAM4 ,

    // Write Data:Delay
    output    [23:0] O_WRITE_DELAY_RAM1,
    output    [23:0] O_WRITE_DELAY_RAM2,
    output    [23:0] O_WRITE_DELAY_RAM3,
    output    [23:0] O_WRITE_DELAY_RAM4
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
	.clk(I_clk_10M),
	.rst_n(I_rst_n),
	.frame_data_in(W_rx_data),
	.frame_data_ena(W_rx_data_vld),
	.GA(GA),
	// UART->RAM
	// Write Enable
	.O_WEA_RAM1(O_WEA_RAM1)  ,
	.O_WEA_RAM2(O_WEA_RAM2)  ,
	.O_WEA_RAM3(O_WEA_RAM3)  ,
	.O_WEA_RAM4(O_WEA_RAM4)  ,
	// Wave ID
	.O_WRITE_ADDR_RAM1(O_WRITE_ADDR_RAM1),
	.O_WRITE_ADDR_RAM2(O_WRITE_ADDR_RAM2),
	.O_WRITE_ADDR_RAM3(O_WRITE_ADDR_RAM3),
	.O_WRITE_ADDR_RAM4(O_WRITE_ADDR_RAM4),
	// Delay
	.O_WRITE_DELAY_RAM1(O_WRITE_DELAY_RAM1),
	.O_WRITE_DELAY_RAM2(O_WRITE_DELAY_RAM2),
	.O_WRITE_DELAY_RAM3(O_WRITE_DELAY_RAM3),
	.O_WRITE_DELAY_RAM4(O_WRITE_DELAY_RAM4)
);

endmodule
