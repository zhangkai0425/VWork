`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Alibaba Quantum Lab
// Engineer: ZhuXing
//
// Create Date: 2020/03/20 08:59:53
// Design Name: AQLAD02
// Module Name: adc_mdl
// Project Name: AQLAD02
// Target Devices: ADC12D1000
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

module adc_mdl (
	input 			clk_pcie_user,
	input           clk_50M,
	input 			clk_125M,
	input           reset,
	// parameters
	input [31:0] 	wave_fre,
	input 			trig_ex,
	input  			dma_start,
    input [13:0]    wave_len_i,
    input [13:0]    cycle_i,
    input [19:0]    delay_i,
    input 			fifo_empty,
    input           prog_full,
    input [3:0] 	data_mode,
    input [31:0]   I0,
    input [31:0]   Q0,
    input [31:0]   I1,
    input [31:0]   Q1,
	//adc1
	input           adc1_dclki_p,
	input           adc1_dclki_n,
	input  [11:0]   adc1_di_p,
	input  [11:0]   adc1_di_n,
	input  [11:0]   adc1_did_p,
	input  [11:0]   adc1_did_n,
	input           adc1_dclkq_p,
	input           adc1_dclkq_n,
	input  [11:0]   adc1_dq_p,
	input  [11:0]   adc1_dq_n,
	input  [11:0]   adc1_dqd_p,
	input  [11:0]   adc1_dqd_n,
	//adc2
	input           adc2_dclki_p,
	input           adc2_dclki_n,
	input  [11:0]   adc2_di_p,
	input  [11:0]   adc2_di_n,
	input  [11:0]   adc2_did_p,
	input  [11:0]   adc2_did_n,
	input           adc2_dclkq_p,
	input           adc2_dclkq_n,
	input  [11:0]   adc2_dq_p,
	input  [11:0]   adc2_dq_n,
	input  [11:0]   adc2_dqd_p,
	input  [11:0]   adc2_dqd_n,
	//
    output          trig_fb,
	output [511:0]  adc_data_o,
	output 			adc_data_valid_o
);

wire [95:0] ch1_data_sig;
wire [95:0] ch2_data_sig;
wire [95:0] ch3_data_sig;
wire [95:0] ch4_data_sig;

wire [3:0]  lock_clk;
wire 		clk_ch1_sig;
wire 		clk_ch2_sig;
wire 		clk_ch3_sig;
wire 		clk_ch4_sig;

adc2fpga adc2fpga_inst (
    .reset 			(reset),
    .clk_50M 		(clk_50M),
    .clk_125M       (clk_125M),
    .lock_clk 		(lock_clk),
    //ch1
    .adc1_dclki_p 	(adc1_dclki_p),
    .adc1_dclki_n 	(adc1_dclki_n),
    .adc1_di_p 		(adc1_di_p),
    .adc1_di_n 		(adc1_di_n),
    .adc1_did_p 	(adc1_did_p),
    .adc1_did_n 	(adc1_did_n),
    //ch2
	.adc1_dclkq_p 	(adc1_dclkq_p),
    .adc1_dclkq_n 	(adc1_dclkq_n),
    .adc1_dq_p 		(adc1_dq_p),
    .adc1_dq_n 		(adc1_dq_n),
    .adc1_dqd_p 	(adc1_dqd_p),
    .adc1_dqd_n 	(adc1_dqd_n),
    //ch3
    .adc2_dclki_p 	(adc2_dclki_p),
    .adc2_dclki_n 	(adc2_dclki_n),
    .adc2_di_p 		(adc2_di_p),
    .adc2_di_n 		(adc2_di_n),
    .adc2_did_p 	(adc2_did_p),
    .adc2_did_n 	(adc2_did_n),
    //ch4
    .adc2_dclkq_p 	(adc2_dclkq_p),
    .adc2_dclkq_n 	(adc2_dclkq_n),
    .adc2_dq_p 		(adc2_dq_p),
    .adc2_dq_n 		(adc2_dq_n),
    .adc2_dqd_p 	(adc2_dqd_p),
    .adc2_dqd_n 	(adc2_dqd_n),
    //data out
    .clk_ch1_o 		(clk_ch1_sig),
    .clk_ch2_o 		(clk_ch2_sig),
    .clk_ch3_o 		(clk_ch3_sig),
    .clk_ch4_o 		(clk_ch4_sig),
    .ch1_data_o 	(ch1_data_sig),
    .ch2_data_o 	(ch2_data_sig),
    .ch3_data_o 	(ch3_data_sig),
    .ch4_data_o 	(ch4_data_sig)
);

wire [511:0] adc_data_sig;
wire adc_data_valid_sig;

adc_wavebuf adc_wavebuf_inst (
	.clk_pcie_user 	(clk_pcie_user),
	.reset 			(reset),

	.wave_fre 		(wave_fre),
	.trig_i 		(trig_ex),
    .clk_cmd 		(clk_50M),
    .dma_start 		(dma_start),
    .wave_len_i 	(wave_len_i),
    .cycle_i 		(cycle_i),
    .delay_i 		(delay_i),
    .prog_full      (prog_full),
    .data_mode 		(data_mode),

    .I0                       (I0),
    .Q0                       (Q0),
    .I1                       (I1),
    .Q1                       (Q1),
	//adc rx
	.clk_125M 		(clk_125M),
	.ch1_data 		(ch1_data_sig),
	.ch2_data 		(ch2_data_sig),
	.ch3_data 		(ch3_data_sig),
	.ch4_data 		(ch4_data_sig),

    .trig_fb        (trig_fb),
    .adc_data_o 	(adc_data_o),
    .adc_data_valid_o(adc_data_valid_o)
);


endmodule

