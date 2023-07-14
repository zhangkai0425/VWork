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
	
	input	I_clk_10M	,
	input	I_rst_n	,
	input   rxb	,
	input[4:0]   GA,

	output [23:0] R_AWG_CH1_DELAY1   ,
	output [23:0] R_AWG_CH2_DELAY1   ,
	output [23:0] R_AWG_CH3_DELAY1   ,
	output [23:0] R_AWG_CH4_DELAY1   ,
	output [23:0] R_AWG_CH1_DELAY2   ,
	output [23:0] R_AWG_CH2_DELAY2   ,
	output [23:0] R_AWG_CH3_DELAY2   ,
	output [23:0] R_AWG_CH4_DELAY2   ,
	output [23:0] R_AWG_CH1_DELAY3   ,
	output [23:0] R_AWG_CH2_DELAY3   ,
	output [23:0] R_AWG_CH3_DELAY3   ,
	output [23:0] R_AWG_CH4_DELAY3   ,
	output [23:0]  R_AWG_CH1_LEN1	 ,
	output [23:0]  R_AWG_CH2_LEN1	 ,
	output [23:0]  R_AWG_CH3_LEN1	 ,
	output [23:0]  R_AWG_CH4_LEN1	 ,
	output [23:0]  R_AWG_CH1_LEN2	 ,
	output [23:0]  R_AWG_CH2_LEN2	 ,
	output [23:0]  R_AWG_CH3_LEN2	 ,
	output [23:0]  R_AWG_CH4_LEN2	 ,
	output [23:0]  R_AWG_CH1_LEN3	 ,
	output [23:0]  R_AWG_CH2_LEN3	 ,
	output [23:0]  R_AWG_CH3_LEN3	 ,
	output [23:0]  R_AWG_CH4_LEN3	 ,
	output [23:0]  R_AWG_CH1_ADDR1	 ,
	output [23:0]  R_AWG_CH2_ADDR1	 ,
	output [23:0]  R_AWG_CH3_ADDR1	 ,
	output [23:0]  R_AWG_CH4_ADDR1	 ,
	output [23:0]  R_AWG_CH1_ADDR2	 ,
	output [23:0]  R_AWG_CH2_ADDR2	 ,
	output [23:0]  R_AWG_CH3_ADDR2	 ,
	output [23:0]  R_AWG_CH4_ADDR2	 ,
	output [23:0]  R_AWG_CH1_ADDR3	 ,
	output [23:0]  R_AWG_CH2_ADDR3	 ,
	output [23:0]  R_AWG_CH3_ADDR3	 ,
    output [23:0]  R_AWG_CH4_ADDR3
			
			
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
	.R_AWG_CH1_DELAY1(R_AWG_CH1_DELAY1 ),
	.R_AWG_CH2_DELAY1(R_AWG_CH2_DELAY1 ),
	.R_AWG_CH3_DELAY1(R_AWG_CH3_DELAY1 ),
	.R_AWG_CH4_DELAY1(R_AWG_CH4_DELAY1 ),
	.R_AWG_CH1_DELAY2(R_AWG_CH1_DELAY2 ),
	.R_AWG_CH2_DELAY2(R_AWG_CH2_DELAY2 ),
	.R_AWG_CH3_DELAY2(R_AWG_CH3_DELAY2 ),
	.R_AWG_CH4_DELAY2(R_AWG_CH4_DELAY2 ),
	.R_AWG_CH1_DELAY3(R_AWG_CH1_DELAY3 ),
	.R_AWG_CH2_DELAY3(R_AWG_CH2_DELAY3 ),
	.R_AWG_CH3_DELAY3(R_AWG_CH3_DELAY3 ),
	.R_AWG_CH4_DELAY3(R_AWG_CH4_DELAY3 ),
	.R_AWG_CH1_LEN1(R_AWG_CH1_LEN1)  ,
	.R_AWG_CH2_LEN1(R_AWG_CH2_LEN1)  ,
	.R_AWG_CH3_LEN1(R_AWG_CH3_LEN1)  ,
	.R_AWG_CH4_LEN1(R_AWG_CH4_LEN1)  ,
	.R_AWG_CH1_LEN2(R_AWG_CH1_LEN2)  ,
	.R_AWG_CH2_LEN2(R_AWG_CH2_LEN2)  ,
	.R_AWG_CH3_LEN2(R_AWG_CH3_LEN2)  ,
	.R_AWG_CH4_LEN2(R_AWG_CH4_LEN2)  ,
	.R_AWG_CH1_LEN3(R_AWG_CH1_LEN3)  ,
	.R_AWG_CH2_LEN3(R_AWG_CH2_LEN3)  ,
	.R_AWG_CH3_LEN3(R_AWG_CH3_LEN3)  ,
	.R_AWG_CH4_LEN3(R_AWG_CH4_LEN3)  ,
	.R_AWG_CH1_ADDR1(R_AWG_CH1_ADDR1) ,
	.R_AWG_CH2_ADDR1(R_AWG_CH2_ADDR1) ,
	.R_AWG_CH3_ADDR1(R_AWG_CH3_ADDR1) ,
	.R_AWG_CH4_ADDR1(R_AWG_CH4_ADDR1) ,
	.R_AWG_CH1_ADDR2(R_AWG_CH1_ADDR2) ,
	.R_AWG_CH2_ADDR2(R_AWG_CH2_ADDR2) ,
	.R_AWG_CH3_ADDR2(R_AWG_CH3_ADDR2) ,
	.R_AWG_CH4_ADDR2(R_AWG_CH4_ADDR2) ,
	.R_AWG_CH1_ADDR3(R_AWG_CH1_ADDR3) ,
	.R_AWG_CH2_ADDR3(R_AWG_CH2_ADDR3) ,
	.R_AWG_CH3_ADDR3(R_AWG_CH3_ADDR3) ,
	.R_AWG_CH4_ADDR3(R_AWG_CH4_ADDR3) 
	

);

	ila_uart test_uart (
	.clk(I_clk_10M), // input wire clk


	.probe0(rxb), // input wire [0:0]  probe0  
	.probe1(R_AWG_CH3_DELAY1), // input wire [31:0]  probe1 
	.probe2(R_AWG_CH4_LEN1), // input wire [31:0]  probe2 
	.probe3(R_AWG_CH1_ADDR2) // input wire [31:0]  probe3
);
	
	
	
	
endmodule
