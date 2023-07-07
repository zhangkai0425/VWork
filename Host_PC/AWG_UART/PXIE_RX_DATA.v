`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/28 10:43:47
// Design Name: 
// Module Name: PXIE_RX_DATA
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


module PXIE_RX_DATA
#(
	parameter MAXIMUM_WIDTH_OF_EACH_CH = 11			//每个通道可以存下的最大波形数目
)
(
	input			I_PXIE_CLK	,
	input [127:0]	I_PXIE_DATA	,
	input			I_PXIE_DATA_VLD	,
	input			I_Rst_n	,
	input			I_CLK_250mhz,

	input	[MAXIMUM_WIDTH_OF_EACH_CH-1:0]	I_dac1_tx_id	,
	input 									I_dac1_tx_ena	,
	output	[23:0]							O_dac1_tx_delay	,

	input	[MAXIMUM_WIDTH_OF_EACH_CH-1:0]	I_dac2_tx_id	,
	input 									I_dac2_tx_ena	,
	output	[23:0]							O_dac2_tx_delay	,

	input	[MAXIMUM_WIDTH_OF_EACH_CH-1:0]	I_dac3_tx_id	,
	input 									I_dac3_tx_ena	,
	output	[23:0]							O_dac3_tx_delay	,

	input	[MAXIMUM_WIDTH_OF_EACH_CH-1:0]	I_dac4_tx_id	,
	input 									I_dac4_tx_ena	,
	output	[23:0]							O_dac4_tx_delay	,

	output [MAXIMUM_WIDTH_OF_EACH_CH-1:0] AWG_CH1_WAVENUM	,
	output [MAXIMUM_WIDTH_OF_EACH_CH-1:0] AWG_CH2_WAVENUM	,
	output [MAXIMUM_WIDTH_OF_EACH_CH-1:0] AWG_CH3_WAVENUM	,
	output [MAXIMUM_WIDTH_OF_EACH_CH-1:0] AWG_CH4_WAVENUM	,

	output [23:0] AWG_CH1_INITIAL_PHASE	,
	output		  AWG_CH1_INITIAL_PHASE_vld,
	output [23:0] AWG_CH2_INITIAL_PHASE	,
	output		  AWG_CH2_INITIAL_PHASE_vld,
	output [23:0] AWG_CH3_INITIAL_PHASE	,
	output		  AWG_CH3_INITIAL_PHASE_vld,
	output [23:0] AWG_CH4_INITIAL_PHASE	,
	output		  AWG_CH4_INITIAL_PHASE_vld,

	output [26:0]	AWG_CH1_PINC		,
	output			AWG_CH1_PINC_vld	,
	output [26:0]	AWG_CH2_PINC		,
	output			AWG_CH2_PINC_vld	,
	output [26:0]	AWG_CH3_PINC		,
	output			AWG_CH3_PINC_vld	,
	output [26:0]	AWG_CH4_PINC		,
	output			AWG_CH4_PINC_vld	,

	output			AWG_WORK_MODE		,

	output			O_DAC1_RAM_data_vld	,
	output [127:0]	O_DAC1_RAM_data,
	output			O_DAC2_RAM_data_vld	,
	output [127:0]	O_DAC2_RAM_data,
	output			O_DAC3_RAM_data_vld	,
	output [127:0]	O_DAC3_RAM_data,
	output			O_DAC4_RAM_data_vld	,
	output [127:0]	O_DAC4_RAM_data,

	output	[7:0]   Config_Group1_ram      	,
	output	[7:0]   Config_Group1_port      ,
	output			Config_Group1_mixer_on  ,
	output	[7:0]   Config_Group2_ram      	,
	output	[7:0]   Config_Group2_port      ,
	output			Config_Group2_mixer_on  ,

	output 			O_Rst	,
	output          O_Rst_vld	,

	output reg [13:0]	R_offset1	,
	output reg [13:0]	R_offset2	,
	output reg [13:0]	R_offset3	,
	output reg [13:0]	R_offset4	,

	output			O_trig			,
	output [3:0]	O_trig_valid	,

	output [6:0]	R_RAM1_State	,
	output [6:0]	R_RAM2_State	,
	output [6:0]	R_RAM3_State	,
	output [6:0]	R_RAM4_State	,

    //1X滤波参数
    output   [15:0]  alpha_in_1X                         ,

    output   [15:0]  complement_alpha_06_1X              ,
    output   [15:0]  complement_alpha_05_1X              ,
    output   [15:0]  complement_alpha_04_1X              ,
    output   [15:0]  complement_alpha_03_1X              ,
    output   [15:0]  complement_alpha_02_1X              ,
    output   [15:0]  complement_alpha_01_1X              ,
    output   [15:0]  complement_alpha_00_1X              ,

    output   [15:0]  alpha_complement_alpha_05_1X        ,
    output   [15:0]  alpha_complement_alpha_04_1X        ,
    output   [15:0]  alpha_complement_alpha_03_1X        ,
    output   [15:0]  alpha_complement_alpha_02_1X        ,
    output   [15:0]  alpha_complement_alpha_01_1X        ,
    output   [15:0]  alpha_complement_alpha_00_1X        ,

    output   [15:0]  k_in_1X                             ,
    output   [15:0]  complement_k_in_1X                  ,

    //2X滤波参数
    output   [15:0]  alpha_in_2X                         ,

    output   [15:0]  complement_alpha_06_2X              ,
    output   [15:0]  complement_alpha_05_2X              ,
    output   [15:0]  complement_alpha_04_2X              ,
    output   [15:0]  complement_alpha_03_2X              ,
    output   [15:0]  complement_alpha_02_2X              ,
    output   [15:0]  complement_alpha_01_2X              ,
    output   [15:0]  complement_alpha_00_2X              ,

    output   [15:0]  alpha_complement_alpha_05_2X        ,
    output   [15:0]  alpha_complement_alpha_04_2X        ,
    output   [15:0]  alpha_complement_alpha_03_2X        ,
    output   [15:0]  alpha_complement_alpha_02_2X        ,
    output   [15:0]  alpha_complement_alpha_01_2X        ,
    output   [15:0]  alpha_complement_alpha_00_2X        ,

    output   [15:0]  k_in_2X                             ,
    output   [15:0]  complement_k_in_2X                  ,

    //3X滤波参数
    output   [15:0]  alpha_in_3X                         ,

    output   [15:0]  complement_alpha_06_3X              ,
    output   [15:0]  complement_alpha_05_3X              ,
    output   [15:0]  complement_alpha_04_3X              ,
    output   [15:0]  complement_alpha_03_3X              ,
    output   [15:0]  complement_alpha_02_3X              ,
    output   [15:0]  complement_alpha_01_3X              ,
    output   [15:0]  complement_alpha_00_3X              ,

    output   [15:0]  alpha_complement_alpha_05_3X        ,
    output   [15:0]  alpha_complement_alpha_04_3X        ,
    output   [15:0]  alpha_complement_alpha_03_3X        ,
    output   [15:0]  alpha_complement_alpha_02_3X        ,
    output   [15:0]  alpha_complement_alpha_01_3X        ,
    output   [15:0]  alpha_complement_alpha_00_3X        ,

    output   [15:0]  k_in_3X                             ,
    output   [15:0]  complement_k_in_3X                  ,

    //4X滤波参数
    output   [15:0]  alpha_in_4X                         ,

    output   [15:0]  complement_alpha_06_4X              ,
    output   [15:0]  complement_alpha_05_4X              ,
    output   [15:0]  complement_alpha_04_4X              ,
    output   [15:0]  complement_alpha_03_4X              ,
    output   [15:0]  complement_alpha_02_4X              ,
    output   [15:0]  complement_alpha_01_4X              ,
    output   [15:0]  complement_alpha_00_4X              ,

    output   [15:0]  alpha_complement_alpha_05_4X        ,
    output   [15:0]  alpha_complement_alpha_04_4X        ,
    output   [15:0]  alpha_complement_alpha_03_4X        ,
    output   [15:0]  alpha_complement_alpha_02_4X        ,
    output   [15:0]  alpha_complement_alpha_01_4X        ,
    output   [15:0]  alpha_complement_alpha_00_4X        ,

    output   [15:0]  k_in_4X                             ,
    output   [15:0]  complement_k_in_4X                  ,

    //5X滤波参数
    output   [15:0]  alpha_in_5X                         ,

    output   [15:0]  complement_alpha_06_5X              ,
    output   [15:0]  complement_alpha_05_5X              ,
    output   [15:0]  complement_alpha_04_5X              ,
    output   [15:0]  complement_alpha_03_5X              ,
    output   [15:0]  complement_alpha_02_5X              ,
    output   [15:0]  complement_alpha_01_5X              ,
    output   [15:0]  complement_alpha_00_5X              ,

    output   [15:0]  alpha_complement_alpha_05_5X        ,
    output   [15:0]  alpha_complement_alpha_04_5X        ,
    output   [15:0]  alpha_complement_alpha_03_5X        ,
    output   [15:0]  alpha_complement_alpha_02_5X        ,
    output   [15:0]  alpha_complement_alpha_01_5X        ,
    output   [15:0]  alpha_complement_alpha_00_5X        ,

    output   [15:0]  k_in_5X                             ,
    output   [15:0]  complement_k_in_5X                  ,

	output	 [3:0]	 IIR_on								 ,
	output	 [3:0]	 IIR_reset							 ,

	output	 [23:0]	 Group1_Delta_Phase_I				 ,
	output	 [23:0]	 Group1_Delta_Phase_Q				 ,
	output			 Group1_Delta_Phase_vld				 ,

	output	 [23:0]	 Group2_Delta_Phase_I				 ,
	output	 [23:0]	 Group2_Delta_Phase_Q				 ,
	output			 Group2_Delta_Phase_vld				 ,

	output	 [23:0]	 Group1_Epsilon_Amp_I				 ,
	output	 [23:0]	 Group1_Epsilon_Amp_Q				 ,
	output	 [23:0]	 Group2_Epsilon_Amp_I				 ,
	output	 [23:0]	 Group2_Epsilon_Amp_Q				 ,

	output	[8:0]	PXIE_Value_Delay_Dci1				 ,
	output	[8:0]	PXIE_Value_Delay_Dci2				 ,	
	output	[8:0]	PXIE_Value_Delay_Dci3				 ,	
	output	[8:0]	PXIE_Value_Delay_Dci4				 ,	
	output 			PXIE_LOAD				

    );

//给四个AD9739芯片的时钟相位修正
reg[8:0]	PXIE_Value_Delay_Dci1	;
reg[8:0]	PXIE_Value_Delay_Dci2	;
reg[8:0]	PXIE_Value_Delay_Dci3	;
reg[8:0]	PXIE_Value_Delay_Dci4	;
reg 		PXIE_LOAD				;

//告知AWG的工作模式 (模式0：发送原始波形 ； 模式1：发送原始波形与dds产生的正余弦波形相乘的结果)
reg				AWG_WORK_MODE				;

//通过IIR_on来设置4个通道的IIR滤波设否开启
reg		[3:0]	IIR_on						;

//IIR_reset的复位信号(低电平有效)
reg		[3:0]	IIR_reset				    ;

//存储四个通道里各个波形的地址信息
reg				wea_to_awg_addr_ram1		;
reg 	[10:0]	write_addr_to_awg_addr_ram1	;
reg 	[23:0]	write_data_to_awg_addr_ram1	;
reg 	[10:0]	R1_write_addr_to_awg_addr_ram1	;
reg 	[23:0]	R1_write_data_to_awg_addr_ram1	;
reg		[10:0]	read_addr_to_awg_addr_ram1	;
wire	[23:0]	read_data_to_awg_addr_ram1	;
blk_mem_gen_1 awg_addr_ram1 (
  .clka(I_PXIE_CLK),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(wea_to_awg_addr_ram1),      // input wire [0 : 0] wea
  .addra(write_addr_to_awg_addr_ram1),  // input wire [10 : 0] addra
  .dina(write_data_to_awg_addr_ram1),    // input wire [23 : 0] dina
  .clkb(I_CLK_250mhz),    // input wire clkb
  .enb(1'b1),      // input wire enb
  .addrb(read_addr_to_awg_addr_ram1),  // input wire [10 : 0] addrb
  .doutb(read_data_to_awg_addr_ram1)  // output wire [23 : 0] doutb
);

reg				wea_to_awg_addr_ram2		;
reg 	[10:0]	write_addr_to_awg_addr_ram2	;
reg 	[23:0]	write_data_to_awg_addr_ram2	;
reg 	[10:0]	R1_write_addr_to_awg_addr_ram2	;
reg 	[23:0]	R1_write_data_to_awg_addr_ram2	;
reg		[10:0]	read_addr_to_awg_addr_ram2	;
wire	[23:0]	read_data_to_awg_addr_ram2	;
blk_mem_gen_1 awg_addr_ram2 (
  .clka(I_PXIE_CLK),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(wea_to_awg_addr_ram2),      // input wire [0 : 0] wea
  .addra(write_addr_to_awg_addr_ram2),  // input wire [10 : 0] addra
  .dina(write_data_to_awg_addr_ram2),    // input wire [23 : 0] dina
  .clkb(I_CLK_250mhz),    // input wire clkb
  .enb(1'b1),      // input wire enb
  .addrb(read_addr_to_awg_addr_ram2),  // input wire [10 : 0] addrb
  .doutb(read_data_to_awg_addr_ram2)  // output wire [23 : 0] doutb
);

reg				wea_to_awg_addr_ram3		;
reg 	[10:0]	write_addr_to_awg_addr_ram3	;
reg 	[23:0]	write_data_to_awg_addr_ram3	;
reg 	[10:0]	R1_write_addr_to_awg_addr_ram3	;
reg 	[23:0]	R1_write_data_to_awg_addr_ram3	;
reg		[10:0]	read_addr_to_awg_addr_ram3	;
wire	[23:0]	read_data_to_awg_addr_ram3	;
blk_mem_gen_1 awg_addr_ram3 (
  .clka(I_PXIE_CLK),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(wea_to_awg_addr_ram3),      // input wire [0 : 0] wea
  .addra(write_addr_to_awg_addr_ram3),  // input wire [10 : 0] addra
  .dina(write_data_to_awg_addr_ram3),    // input wire [23 : 0] dina
  .clkb(I_CLK_250mhz),    // input wire clkb
  .enb(1'b1),      // input wire enb
  .addrb(read_addr_to_awg_addr_ram3),  // input wire [10 : 0] addrb
  .doutb(read_data_to_awg_addr_ram3)  // output wire [23 : 0] doutb
);

reg				wea_to_awg_addr_ram4		;
reg 	[10:0]	write_addr_to_awg_addr_ram4	;
reg 	[23:0]	write_data_to_awg_addr_ram4	;
reg 	[10:0]	R1_write_addr_to_awg_addr_ram4	;
reg 	[23:0]	R1_write_data_to_awg_addr_ram4	;
reg		[10:0]	read_addr_to_awg_addr_ram4	;
wire	[23:0]	read_data_to_awg_addr_ram4	;
blk_mem_gen_1 awg_addr_ram4 (
  .clka(I_PXIE_CLK),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(wea_to_awg_addr_ram4),      // input wire [0 : 0] wea
  .addra(write_addr_to_awg_addr_ram4),  // input wire [10 : 0] addra
  .dina(write_data_to_awg_addr_ram4),    // input wire [23 : 0] dina
  .clkb(I_CLK_250mhz),    // input wire clkb
  .enb(1'b1),      // input wire enb
  .addrb(read_addr_to_awg_addr_ram4),  // input wire [10 : 0] addrb
  .doutb(read_data_to_awg_addr_ram4)  // output wire [23 : 0] doutb
);

//存储四个通道里各个波形的长度信息
reg				wea_to_awg_len_ram1			;
reg	 	[10:0]	write_addr_to_awg_len_ram1	;
reg	 	[23:0]	write_data_to_awg_len_ram1	;
reg	 	[10:0]	R1_write_addr_to_awg_len_ram1	;
reg	 	[23:0]	R1_write_data_to_awg_len_ram1	;
reg		[10:0]	read_addr_to_awg_len_ram1	;
wire	[23:0]	read_data_to_awg_len_ram1	;
blk_mem_gen_1 awg_len_ram1 (
  .clka(I_PXIE_CLK),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(wea_to_awg_len_ram1),      // input wire [0 : 0] wea
  .addra(write_addr_to_awg_len_ram1),  // input wire [10 : 0] addra
  .dina(write_data_to_awg_len_ram1),    // input wire [23 : 0] dina
  .clkb(I_CLK_250mhz),    // input wire clkb
  .enb(1'b1),      // input wire enb
  .addrb(read_addr_to_awg_len_ram1),  // input wire [10 : 0] addrb
  .doutb(read_data_to_awg_len_ram1)  // output wire [23 : 0] doutb
);

reg				wea_to_awg_len_ram2			;
reg	 	[10:0]	write_addr_to_awg_len_ram2	;
reg	 	[23:0]	write_data_to_awg_len_ram2	;
reg	 	[10:0]	R1_write_addr_to_awg_len_ram2	;
reg	 	[23:0]	R1_write_data_to_awg_len_ram2	;
reg		[10:0]	read_addr_to_awg_len_ram2	;
wire	[23:0]	read_data_to_awg_len_ram2	;
blk_mem_gen_1 awg_len_ram2 (
  .clka(I_PXIE_CLK),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(wea_to_awg_len_ram2),      // input wire [0 : 0] wea
  .addra(write_addr_to_awg_len_ram2),  // input wire [10 : 0] addra
  .dina(write_data_to_awg_len_ram2),    // input wire [23 : 0] dina
  .clkb(I_CLK_250mhz),    // input wire clkb
  .enb(1'b1),      // input wire enb
  .addrb(read_addr_to_awg_len_ram2),  // input wire [10 : 0] addrb
  .doutb(read_data_to_awg_len_ram2)  // output wire [23 : 0] doutb
);

reg				wea_to_awg_len_ram3			;
reg	 	[10:0]	write_addr_to_awg_len_ram3	;
reg	 	[23:0]	write_data_to_awg_len_ram3	;
reg	 	[10:0]	R1_write_addr_to_awg_len_ram3	;
reg	 	[23:0]	R1_write_data_to_awg_len_ram3	;
reg		[10:0]	read_addr_to_awg_len_ram3	;
wire	[23:0]	read_data_to_awg_len_ram3	;
blk_mem_gen_1 awg_len_ram3 (
  .clka(I_PXIE_CLK),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(wea_to_awg_len_ram3),      // input wire [0 : 0] wea
  .addra(write_addr_to_awg_len_ram3),  // input wire [10 : 0] addra
  .dina(write_data_to_awg_len_ram3),    // input wire [23 : 0] dina
  .clkb(I_CLK_250mhz),    // input wire clkb
  .enb(1'b1),      // input wire enb
  .addrb(read_addr_to_awg_len_ram3),  // input wire [10 : 0] addrb
  .doutb(read_data_to_awg_len_ram3)  // output wire [23 : 0] doutb
);

reg				wea_to_awg_len_ram4			;
reg	 	[10:0]	write_addr_to_awg_len_ram4	;
reg	 	[23:0]	write_data_to_awg_len_ram4	;
reg	 	[10:0]	R1_write_addr_to_awg_len_ram4	;
reg	 	[23:0]	R1_write_data_to_awg_len_ram4	;
reg		[10:0]	read_addr_to_awg_len_ram4	;
wire	[23:0]	read_data_to_awg_len_ram4	;
blk_mem_gen_1 awg_len_ram4 (
  .clka(I_PXIE_CLK),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(wea_to_awg_len_ram4),      // input wire [0 : 0] wea
  .addra(write_addr_to_awg_len_ram4),  // input wire [10 : 0] addra
  .dina(write_data_to_awg_len_ram4),    // input wire [23 : 0] dina
  .clkb(I_CLK_250mhz),    // input wire clkb
  .enb(1'b1),      // input wire enb
  .addrb(read_addr_to_awg_len_ram4),  // input wire [10 : 0] addrb
  .doutb(read_data_to_awg_len_ram4)  // output wire [23 : 0] doutb
);

//存储四个通道里各个波形的延迟信息
reg				wea_to_awg_delay_ram1		;
reg	 	[10:0]	write_addr_to_awg_delay_ram1;
reg	 	[23:0]	write_data_to_awg_delay_ram1;
reg	 	[10:0]	R1_write_addr_to_awg_delay_ram1;
reg	 	[23:0]	R1_write_data_to_awg_delay_ram1;
reg		[10:0]	read_addr_to_awg_delay_ram1	;
wire	[23:0]	read_data_to_awg_delay_ram1	;
blk_mem_gen_1 awg_delay_ram1 (
  .clka(I_PXIE_CLK),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(wea_to_awg_delay_ram1),      // input wire [0 : 0] wea
  .addra(write_addr_to_awg_delay_ram1),  // input wire [10 : 0] addra
  .dina(write_data_to_awg_delay_ram1),    // input wire [23 : 0] dina
  .clkb(I_CLK_250mhz),    // input wire clkb
  .enb(1'b1),      // input wire enb
  .addrb(read_addr_to_awg_delay_ram1),  // input wire [10 : 0] addrb
  .doutb(read_data_to_awg_delay_ram1)  // output wire [23 : 0] doutb
);

reg				wea_to_awg_delay_ram2		;
reg	 	[10:0]	write_addr_to_awg_delay_ram2;
reg	 	[23:0]	write_data_to_awg_delay_ram2;
reg	 	[10:0]	R1_write_addr_to_awg_delay_ram2;
reg	 	[23:0]	R1_write_data_to_awg_delay_ram2;
reg		[10:0]	read_addr_to_awg_delay_ram2	;
wire	[23:0]	read_data_to_awg_delay_ram2	;
blk_mem_gen_1 awg_delay_ram2 (
  .clka(I_PXIE_CLK),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(wea_to_awg_delay_ram2),      // input wire [0 : 0] wea
  .addra(write_addr_to_awg_delay_ram2),  // input wire [10 : 0] addra
  .dina(write_data_to_awg_delay_ram2),    // input wire [23 : 0] dina
  .clkb(I_CLK_250mhz),    // input wire clkb
  .enb(1'b1),      // input wire enb
  .addrb(read_addr_to_awg_delay_ram2),  // input wire [10 : 0] addrb
  .doutb(read_data_to_awg_delay_ram2)  // output wire [23 : 0] doutb
);

reg				wea_to_awg_delay_ram3		;
reg	 	[10:0]	write_addr_to_awg_delay_ram3;
reg	 	[23:0]	write_data_to_awg_delay_ram3;
reg	 	[10:0]	R1_write_addr_to_awg_delay_ram3;
reg	 	[23:0]	R1_write_data_to_awg_delay_ram3;
reg		[10:0]	read_addr_to_awg_delay_ram3	;
wire	[23:0]	read_data_to_awg_delay_ram3	;
blk_mem_gen_1 awg_delay_ram3 (
  .clka(I_PXIE_CLK),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(wea_to_awg_delay_ram3),      // input wire [0 : 0] wea
  .addra(write_addr_to_awg_delay_ram3),  // input wire [10 : 0] addra
  .dina(write_data_to_awg_delay_ram3),    // input wire [23 : 0] dina
  .clkb(I_CLK_250mhz),    // input wire clkb
  .enb(1'b1),      // input wire enb
  .addrb(read_addr_to_awg_delay_ram3),  // input wire [10 : 0] addrb
  .doutb(read_data_to_awg_delay_ram3)  // output wire [23 : 0] doutb
);

reg				wea_to_awg_delay_ram4		;
reg	 	[10:0]	write_addr_to_awg_delay_ram4;
reg	 	[23:0]	write_data_to_awg_delay_ram4;
reg	 	[10:0]	R1_write_addr_to_awg_delay_ram4;
reg	 	[23:0]	R1_write_data_to_awg_delay_ram4;
reg		[10:0]	read_addr_to_awg_delay_ram4	;
wire	[23:0]	read_data_to_awg_delay_ram4	;
blk_mem_gen_1 awg_delay_ram4 (
  .clka(I_PXIE_CLK),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(wea_to_awg_delay_ram4),      // input wire [0 : 0] wea
  .addra(write_addr_to_awg_delay_ram4),  // input wire [10 : 0] addra
  .dina(write_data_to_awg_delay_ram4),    // input wire [23 : 0] dina
  .clkb(I_CLK_250mhz),    // input wire clkb
  .enb(1'b1),      // input wire enb
  .addrb(read_addr_to_awg_delay_ram4),  // input wire [10 : 0] addrb
  .doutb(read_data_to_awg_delay_ram4)  // output wire [23 : 0] doutb
);

always @(posedge I_PXIE_CLK or negedge I_Rst_n) begin
	if (~I_Rst_n) begin
		R1_write_addr_to_awg_addr_ram1	<=	11'd0	;
		R1_write_data_to_awg_addr_ram1	<=	24'd0	;
		R1_write_addr_to_awg_addr_ram2	<=	11'd0	;
		R1_write_data_to_awg_addr_ram2	<=	24'd0	;
		R1_write_addr_to_awg_addr_ram3	<=	11'd0	;
		R1_write_data_to_awg_addr_ram3	<=	24'd0	;
		R1_write_addr_to_awg_addr_ram4	<=	11'd0	;
		R1_write_data_to_awg_addr_ram4	<=	24'd0	;

		R1_write_addr_to_awg_delay_ram1	<=	11'd0	;
		R1_write_data_to_awg_delay_ram1	<=	24'd0	;
		R1_write_addr_to_awg_delay_ram2	<=	11'd0	;
		R1_write_data_to_awg_delay_ram2	<=	24'd0	;
		R1_write_addr_to_awg_delay_ram3	<=	11'd0	;
		R1_write_data_to_awg_delay_ram3	<=	24'd0	;
		R1_write_addr_to_awg_delay_ram4	<=	11'd0	;
		R1_write_data_to_awg_delay_ram4	<=	24'd0	;
		
		R1_write_addr_to_awg_len_ram1	<=	11'd0	;
		R1_write_data_to_awg_len_ram1	<=	24'd0	;
		R1_write_addr_to_awg_len_ram2	<=	11'd0	;
		R1_write_data_to_awg_len_ram2	<=	24'd0	;
		R1_write_addr_to_awg_len_ram3	<=	11'd0	;
		R1_write_data_to_awg_len_ram3	<=	24'd0	;
		R1_write_addr_to_awg_len_ram4	<=	11'd0	;
		R1_write_data_to_awg_len_ram4	<=	24'd0	;
	end
	else begin
		R1_write_addr_to_awg_addr_ram1	<=	write_addr_to_awg_addr_ram1	;
		R1_write_data_to_awg_addr_ram1	<=	write_data_to_awg_addr_ram1	;
		R1_write_addr_to_awg_addr_ram2	<=	write_addr_to_awg_addr_ram2	;
		R1_write_data_to_awg_addr_ram2	<=	write_data_to_awg_addr_ram2	;
		R1_write_addr_to_awg_addr_ram3	<=	write_addr_to_awg_addr_ram3	;
		R1_write_data_to_awg_addr_ram3	<=	write_data_to_awg_addr_ram3	;
		R1_write_addr_to_awg_addr_ram4	<=	write_addr_to_awg_addr_ram4	;
		R1_write_data_to_awg_addr_ram4	<=	write_data_to_awg_addr_ram4	;

		R1_write_addr_to_awg_delay_ram1	<=	write_addr_to_awg_delay_ram1;
		R1_write_data_to_awg_delay_ram1	<=	write_data_to_awg_delay_ram1;
		R1_write_addr_to_awg_delay_ram2	<=	write_addr_to_awg_delay_ram2;
		R1_write_data_to_awg_delay_ram2	<=	write_data_to_awg_delay_ram2;
		R1_write_addr_to_awg_delay_ram3	<=	write_addr_to_awg_delay_ram3;
		R1_write_data_to_awg_delay_ram3	<=	write_data_to_awg_delay_ram3;
		R1_write_addr_to_awg_delay_ram4	<=	write_addr_to_awg_delay_ram4;
		R1_write_data_to_awg_delay_ram4	<=	write_data_to_awg_delay_ram4;
		
		R1_write_addr_to_awg_len_ram1	<=	write_addr_to_awg_len_ram1	;
		R1_write_data_to_awg_len_ram1	<=	write_data_to_awg_len_ram1	;
		R1_write_addr_to_awg_len_ram2	<=	write_addr_to_awg_len_ram2	;
		R1_write_data_to_awg_len_ram2	<=	write_data_to_awg_len_ram2	;
		R1_write_addr_to_awg_len_ram3	<=	write_addr_to_awg_len_ram3	;
		R1_write_data_to_awg_len_ram3	<=	write_data_to_awg_len_ram3	;
		R1_write_addr_to_awg_len_ram4	<=	write_addr_to_awg_len_ram4	;
		R1_write_data_to_awg_len_ram4	<=	write_data_to_awg_len_ram4	;
		
	end
end

//读取各个RAM的地址线设置
always @(posedge I_CLK_250mhz or negedge I_Rst_n) begin
	if (~I_Rst_n) begin
		read_addr_to_awg_addr_ram1	<=	11'd0;
		read_addr_to_awg_addr_ram2	<=	11'd0;
		read_addr_to_awg_addr_ram3	<=	11'd0;
		read_addr_to_awg_addr_ram4	<=	11'd0;

		read_addr_to_awg_len_ram1	<=	11'd0;
		read_addr_to_awg_len_ram2	<=	11'd0;
		read_addr_to_awg_len_ram3	<=	11'd0;
		read_addr_to_awg_len_ram4	<=	11'd0;

		read_addr_to_awg_delay_ram1	<=	11'd0;
		read_addr_to_awg_delay_ram2	<=	11'd0;
		read_addr_to_awg_delay_ram3	<=	11'd0;
		read_addr_to_awg_delay_ram4	<=	11'd0;
	end
	else begin
		read_addr_to_awg_addr_ram1	<=	I_dac1_tx_id;
		read_addr_to_awg_addr_ram2	<=	I_dac2_tx_id;
		read_addr_to_awg_addr_ram3	<=	I_dac3_tx_id;
		read_addr_to_awg_addr_ram4	<=	I_dac4_tx_id;

		read_addr_to_awg_len_ram1	<=	I_dac1_tx_id;
		read_addr_to_awg_len_ram2	<=	I_dac2_tx_id;
		read_addr_to_awg_len_ram3	<=	I_dac3_tx_id;
		read_addr_to_awg_len_ram4	<=	I_dac4_tx_id;

		read_addr_to_awg_delay_ram1	<=	I_dac1_tx_id;
		read_addr_to_awg_delay_ram2	<=	I_dac2_tx_id;
		read_addr_to_awg_delay_ram3	<=	I_dac3_tx_id;
		read_addr_to_awg_delay_ram4	<=	I_dac4_tx_id;
	end
end

//输出delay信息给Trig_Delay_MDL
assign	O_dac1_tx_delay	=	read_data_to_awg_delay_ram1;
assign	O_dac2_tx_delay	=	read_data_to_awg_delay_ram2;
assign	O_dac3_tx_delay	=	read_data_to_awg_delay_ram3;
assign	O_dac4_tx_delay	=	read_data_to_awg_delay_ram4;

//分别存储四个通道里有效波形的数目
reg [MAXIMUM_WIDTH_OF_EACH_CH-1:0] AWG_CH1_WAVENUM	;
reg [MAXIMUM_WIDTH_OF_EACH_CH-1:0] AWG_CH2_WAVENUM	;
reg [MAXIMUM_WIDTH_OF_EACH_CH-1:0] AWG_CH3_WAVENUM	;
reg [MAXIMUM_WIDTH_OF_EACH_CH-1:0] AWG_CH4_WAVENUM	;

//分别存储四个通道初始相位的信息
reg [23:0] AWG_CH1_INITIAL_PHASE		;
reg		   AWG_CH1_INITIAL_PHASE_vld	;
reg [23:0] AWG_CH2_INITIAL_PHASE		;
reg		   AWG_CH2_INITIAL_PHASE_vld	;
reg [23:0] AWG_CH3_INITIAL_PHASE		;
reg		   AWG_CH3_INITIAL_PHASE_vld	;
reg [23:0] AWG_CH4_INITIAL_PHASE		;
reg		   AWG_CH4_INITIAL_PHASE_vld	;

//分别存储四个通道的频率控制字
reg [26:0]	AWG_CH1_PINC		;
reg		   	AWG_CH1_PINC_vld	;
reg [26:0] 	AWG_CH2_PINC		;
reg		   	AWG_CH2_PINC_vld	;
reg [26:0] 	AWG_CH3_PINC		;
reg		   	AWG_CH3_PINC_vld	;
reg [26:0] 	AWG_CH4_PINC		;
reg		   	AWG_CH4_PINC_vld	;

//控制总体状态机
parameter [3:0]	ST_IDLE		= 4'd0	;
parameter [3:0]	ST_HEAD		= 4'd1	;
parameter [3:0]	ST_WRITE1	= 4'd2	;
parameter [3:0]	ST_WRITE2	= 4'd3	;
parameter [3:0]	ST_WRITE3	= 4'd4	;
parameter [3:0]	ST_WRITE4	= 4'd5	;
parameter [3:0]	ST_RST		= 4'd6	;
parameter [3:0]	ST_DONE		= 4'd7	;

reg[3:0]	R_State				;
reg[3:0]	R_NextState			;

//控制RAM1的状态机
parameter [6:0]	ST_RAM1_IDLE			= 7'b0000001	;
parameter [6:0]	ST_RAM1_WAIT			= 7'b0000010	;
parameter [6:0]	ST_RAM1_READ			= 7'b0000100	;
parameter [6:0]	ST_RAM1_READ_DONE		= 7'b0001000	;

reg[6:0]	R_RAM1_State				;
reg[6:0]	R_RAM1_NextState			;

//控制RAM2的状态机
parameter [6:0]	ST_RAM2_IDLE			= 7'b0000001	;
parameter [6:0]	ST_RAM2_WAIT			= 7'b0000010	;
parameter [6:0]	ST_RAM2_READ			= 7'b0000100	;
parameter [6:0]	ST_RAM2_READ_DONE		= 7'b0001000	;

reg[6:0]	R_RAM2_State				;
reg[6:0]	R_RAM2_NextState			;

//控制RAM3的状态机
parameter [6:0]	ST_RAM3_IDLE			= 7'b0000001	;
parameter [6:0]	ST_RAM3_WAIT			= 7'b0000010	;
parameter [6:0]	ST_RAM3_READ			= 7'b0000100	;
parameter [6:0]	ST_RAM3_READ_DONE		= 7'b0001000	;

reg[6:0]	R_RAM3_State				;
reg[6:0]	R_RAM3_NextState			;

//控制RAM4的状态机
parameter [6:0]	ST_RAM4_IDLE			= 7'b0000001	;
parameter [6:0]	ST_RAM4_WAIT			= 7'b0000010	;
parameter [6:0]	ST_RAM4_READ			= 7'b0000100	;
parameter [6:0]	ST_RAM4_READ_DONE		= 7'b0001000	;

reg[6:0]	R_RAM4_State				;
reg[6:0]	R_RAM4_NextState			;

//PXIE传输的数据
reg[127:0]	R1_PXIE_DATA		;
reg[127:0]	R_PXIE_DATA			;
reg			R1_PXIE_DATA_VLD	;
reg			R_PXIE_DATA_VLD		;

//来自PXIE且用于更新RAM1、RAM2、RAM3、RAM4的数据
reg[127:0]	R_DAC1_data	        ;
reg[127:0]  R_DAC2_data	        ;
reg[127:0]  R_DAC3_data	        ;
reg[127:0]  R_DAC4_data	        ;

//更新RAM1、RAM2、RAM3、RAM4的使能信号
reg	        R_DAC1_ena	        ;
reg	        R_DAC2_ena	        ;
reg	        R_DAC3_ena	        ;
reg	        R_DAC4_ena	        ;

//PXIE的初始化信号
reg			R_Rst				;
reg			R_Rst_vld			;

//偏置电压
reg[13:0]	R_offset1			;
reg[13:0]	R_offset2			;
reg[13:0]	R_offset3			;
reg[13:0]	R_offset4			;

//记录已写入RAM的数据次数（单位：八个点为一次）
reg[23:0]    R_Cnt_Data	        ;
//将要写入RAM的数据总次数（单位：八个点为一次）
reg[23:0]	R_length			;
//将要写入RAN的数据的地址
reg[23:0]	R_addr		;


//A信号：写四块RAM
reg[23:0]	R_DAC1_RAM_addrA		;
reg[23:0]	R_DAC2_RAM_addrA		;
reg[23:0]	R_DAC3_RAM_addrA		;
reg[23:0]	R_DAC4_RAM_addrA		;

reg[23:0]	R1_DAC1_RAM_addrA		;
reg[23:0]	R1_DAC2_RAM_addrA		;
reg[23:0]	R1_DAC3_RAM_addrA		;
reg[23:0]	R1_DAC4_RAM_addrA		;

//B信号：读四块RAM
reg[23:0]	R_DAC1_RAM_addrB		;
reg[23:0]	R_DAC2_RAM_addrB		;
reg[23:0]	R_DAC3_RAM_addrB		;
reg[23:0]	R_DAC4_RAM_addrB		;

wire[127:0]	W_DAC1_RAM_data			;
wire[127:0]	W_DAC2_RAM_data			;
wire[127:0]	W_DAC3_RAM_data			;
wire[127:0]	W_DAC4_RAM_data			;

// ila_12 debug_top_data (
// 	.clk(I_CLK_250mhz), // input wire clk
// 	.probe0(W_DAC1_RAM_data), // input wire [127:0]  probe0  
// 	.probe1(W_DAC2_RAM_data), // input wire [127:0]  probe1 
// 	.probe2(W_DAC3_RAM_data), // input wire [127:0]  probe2 
// 	.probe3(W_DAC4_RAM_data) // input wire [127:0]  probe3
// );



//告知DDS_DataProcess的数据处理方式
reg	[7:0]   Config_Group1_ram      	;
reg	[7:0]   Config_Group1_port      ;
reg			Config_Group1_mixer_on  ;
reg	[7:0]   Config_Group2_ram      	;
reg	[7:0]   Config_Group2_port      ;
reg			Config_Group2_mixer_on  ;

reg			CW_MODE			;

reg			O_trig			;
reg[3:0]	O_trig_valid	;	//控制一次trig应该触发哪几个通道




//*****************************************PXIE data to fifo**********************************************
assign O_Rst		=   R_Rst	;
assign O_Rst_vld	=	R_Rst_vld	;

always @ (posedge I_PXIE_CLK or negedge I_Rst_n)
begin
	if(~I_Rst_n)
	begin
		R_State	<=	ST_IDLE	;
		R_PXIE_DATA	<=	128'd0	;
		R1_PXIE_DATA	<=	128'd0	;
		R_PXIE_DATA_VLD	<=	1'b0	;
		R1_PXIE_DATA_VLD	<=	1'b0	;
		R1_DAC1_RAM_addrA	<=	24'd0	;
		R1_DAC2_RAM_addrA	<=	24'd0	;
		R1_DAC3_RAM_addrA	<=	24'd0	;
		R1_DAC4_RAM_addrA	<=	24'd0	;
	end
	else
	begin
		R_State	<=	R_NextState	;
		R_PXIE_DATA	<=	I_PXIE_DATA	;
		R1_PXIE_DATA	<=	R_PXIE_DATA	;
		R_PXIE_DATA_VLD	<=	I_PXIE_DATA_VLD	;
		R1_PXIE_DATA_VLD	<=	R_PXIE_DATA_VLD	;
		R1_DAC1_RAM_addrA	<=	R_DAC1_RAM_addrA;
		R1_DAC2_RAM_addrA	<=	R_DAC2_RAM_addrA;
		R1_DAC3_RAM_addrA	<=	R_DAC3_RAM_addrA;
		R1_DAC4_RAM_addrA	<=	R_DAC4_RAM_addrA;
	end
end	
	

always @(*)
begin
	case(R_State)
		ST_IDLE:
		begin
			R_NextState	=	ST_HEAD	;
		end
	
		ST_HEAD:
		begin
			if((I_PXIE_DATA[127:112] == 16'h9ceb)&&(I_PXIE_DATA[111:96] == 16'h0001)&&(I_PXIE_DATA_VLD))
			begin
				R_NextState	=	ST_WRITE1	;
			end
			else if((I_PXIE_DATA[127:112] == 16'h9ceb)&&(I_PXIE_DATA[111:96] == 16'h0002)&&(I_PXIE_DATA_VLD))
			begin
				R_NextState	=	ST_WRITE2	;
			end
			else if((I_PXIE_DATA[127:112] == 16'h9ceb)&&(I_PXIE_DATA[111:96] == 16'h0003)&&(I_PXIE_DATA_VLD))
			begin
				R_NextState	=	ST_WRITE3	;
			end
			else if((I_PXIE_DATA[127:112] == 16'h9ceb)&&(I_PXIE_DATA[111:96] == 16'h0004)&&(I_PXIE_DATA_VLD))
			begin
				R_NextState	=	ST_WRITE4	;
			end
			else if((I_PXIE_DATA[127:112] == 16'h9ceb)&&(I_PXIE_DATA[95:80] == 16'hffff)&&(I_PXIE_DATA_VLD))
			begin
				R_NextState	=	ST_RST	;
			end
			else
			begin
				R_NextState	=	ST_HEAD		;
			end
		end
		
		ST_WRITE1:
		begin
			if(I_PXIE_DATA_VLD == 0)
			begin
				R_NextState	=	ST_WRITE1	;
			end
			else
			begin
				if(R_Cnt_Data == R_length-1'b1)
				begin
					R_NextState	=	ST_DONE	;
				end
				else
				begin	
					R_NextState	=	ST_WRITE1	;
				end
			end
		end
		
		ST_WRITE2:
		begin
			if(I_PXIE_DATA_VLD == 0)
			begin
				R_NextState	=	ST_WRITE2	;
			end	
			else
			begin
				if(R_Cnt_Data == R_length-1'b1)
				begin
					R_NextState	=	ST_DONE	;
				end
				else
				begin	
					R_NextState	=	ST_WRITE2	;
				end
			end
		end
		
		ST_WRITE3:
		begin
			if(I_PXIE_DATA_VLD == 0)
			begin
				R_NextState	=	ST_WRITE3	;
			end	
			else
			begin		
				if(R_Cnt_Data == R_length-1'b1)
				begin
					R_NextState	=	ST_DONE	;
				end
				else
				begin	
					R_NextState	=	ST_WRITE3	;
				end
			end
		end
		
		ST_WRITE4:
		begin
			if(I_PXIE_DATA_VLD == 0)
			begin
				R_NextState	=	ST_WRITE4	;
			end	
			else
			begin			
				if(R_Cnt_Data == R_length-1'b1)
				begin
					R_NextState	=	ST_DONE	;
				end
				else
				begin	
					R_NextState	=	ST_WRITE4	;
				end
			end
		end
		
		ST_RST:
		begin
			if(R_Cnt_Data == 24'd100)
			begin
				R_NextState	=	ST_DONE	;
			end
			else
			begin	
				R_NextState	=	ST_RST	;
			end
		end
		
	
		ST_DONE:
		begin
			R_NextState	=	ST_IDLE	;
		end	
		
		default:	
			R_NextState	=	ST_IDLE	;
	endcase
end	


//1X滤波参数
reg   [15:0]  alpha_in_1X                         ;

reg   [15:0]  complement_alpha_06_1X              ;
reg   [15:0]  complement_alpha_05_1X              ;
reg   [15:0]  complement_alpha_04_1X              ;
reg   [15:0]  complement_alpha_03_1X              ;
reg   [15:0]  complement_alpha_02_1X              ;
reg   [15:0]  complement_alpha_01_1X              ;
reg   [15:0]  complement_alpha_00_1X              ;

reg   [15:0]  alpha_complement_alpha_05_1X        ;
reg   [15:0]  alpha_complement_alpha_04_1X        ;
reg   [15:0]  alpha_complement_alpha_03_1X        ;
reg   [15:0]  alpha_complement_alpha_02_1X        ;
reg   [15:0]  alpha_complement_alpha_01_1X        ;
reg   [15:0]  alpha_complement_alpha_00_1X        ;

reg   [15:0]  k_in_1X                             ;
reg   [15:0]  complement_k_in_1X                  ;

//2X滤波参数
reg   [15:0]  alpha_in_2X                         ;

reg   [15:0]  complement_alpha_06_2X              ;
reg   [15:0]  complement_alpha_05_2X              ;
reg   [15:0]  complement_alpha_04_2X              ;
reg   [15:0]  complement_alpha_03_2X              ;
reg   [15:0]  complement_alpha_02_2X              ;
reg   [15:0]  complement_alpha_01_2X              ;
reg   [15:0]  complement_alpha_00_2X              ;

reg   [15:0]  alpha_complement_alpha_05_2X        ;
reg   [15:0]  alpha_complement_alpha_04_2X        ;
reg   [15:0]  alpha_complement_alpha_03_2X        ;
reg   [15:0]  alpha_complement_alpha_02_2X        ;
reg   [15:0]  alpha_complement_alpha_01_2X        ;
reg   [15:0]  alpha_complement_alpha_00_2X        ;

reg   [15:0]  k_in_2X                             ;
reg   [15:0]  complement_k_in_2X                  ;

//3X滤波参数
reg   [15:0]  alpha_in_3X                         ;

reg   [15:0]  complement_alpha_06_3X              ;
reg   [15:0]  complement_alpha_05_3X              ;
reg   [15:0]  complement_alpha_04_3X              ;
reg   [15:0]  complement_alpha_03_3X              ;
reg   [15:0]  complement_alpha_02_3X              ;
reg   [15:0]  complement_alpha_01_3X              ;
reg   [15:0]  complement_alpha_00_3X              ;

reg   [15:0]  alpha_complement_alpha_05_3X        ;
reg   [15:0]  alpha_complement_alpha_04_3X        ;
reg   [15:0]  alpha_complement_alpha_03_3X        ;
reg   [15:0]  alpha_complement_alpha_02_3X        ;
reg   [15:0]  alpha_complement_alpha_01_3X        ;
reg   [15:0]  alpha_complement_alpha_00_3X        ;

reg   [15:0]  k_in_3X                             ;
reg   [15:0]  complement_k_in_3X                  ;

//4X滤波参数
reg   [15:0]  alpha_in_4X                         ;

reg   [15:0]  complement_alpha_06_4X              ;
reg   [15:0]  complement_alpha_05_4X              ;
reg   [15:0]  complement_alpha_04_4X              ;
reg   [15:0]  complement_alpha_03_4X              ;
reg   [15:0]  complement_alpha_02_4X              ;
reg   [15:0]  complement_alpha_01_4X              ;
reg   [15:0]  complement_alpha_00_4X              ;

reg   [15:0]  alpha_complement_alpha_05_4X        ;
reg   [15:0]  alpha_complement_alpha_04_4X        ;
reg   [15:0]  alpha_complement_alpha_03_4X        ;
reg   [15:0]  alpha_complement_alpha_02_4X        ;
reg   [15:0]  alpha_complement_alpha_01_4X        ;
reg   [15:0]  alpha_complement_alpha_00_4X        ;

reg   [15:0]  k_in_4X                             ;
reg   [15:0]  complement_k_in_4X                  ;

//5X滤波参数
reg   [15:0]  alpha_in_5X                         ;

reg   [15:0]  complement_alpha_06_5X              ;
reg   [15:0]  complement_alpha_05_5X              ;
reg   [15:0]  complement_alpha_04_5X              ;
reg   [15:0]  complement_alpha_03_5X              ;
reg   [15:0]  complement_alpha_02_5X              ;
reg   [15:0]  complement_alpha_01_5X              ;
reg   [15:0]  complement_alpha_00_5X              ;

reg   [15:0]  alpha_complement_alpha_05_5X        ;
reg   [15:0]  alpha_complement_alpha_04_5X        ;
reg   [15:0]  alpha_complement_alpha_03_5X        ;
reg   [15:0]  alpha_complement_alpha_02_5X        ;
reg   [15:0]  alpha_complement_alpha_01_5X        ;
reg   [15:0]  alpha_complement_alpha_00_5X        ;

reg   [15:0]  k_in_5X                             ;
reg   [15:0]  complement_k_in_5X                  ;


reg	 [23:0]	 Group1_Delta_Phase_I				 ;
reg	 [23:0]	 Group1_Delta_Phase_Q				 ;
reg	 		 Group1_Delta_Phase_vld				 ;

reg	 [23:0]	 Group2_Delta_Phase_I				 ;
reg	 [23:0]	 Group2_Delta_Phase_Q				 ;
reg	 		 Group2_Delta_Phase_vld				 ;

reg	 [23:0]	 Group1_Epsilon_Amp_I				 ;
reg	 [23:0]	 Group1_Epsilon_Amp_Q				 ;
reg	 [23:0]	 Group2_Epsilon_Amp_I				 ;
reg	 [23:0]	 Group2_Epsilon_Amp_Q				 ;


always	@ (posedge I_PXIE_CLK or negedge I_Rst_n)	
begin
	if(~I_Rst_n)
	begin
		R_DAC1_data		<=	128'd0	;
		R_DAC2_data		<=	128'd0	;
		R_DAC3_data		<=	128'd0	;
		R_DAC4_data		<=	128'd0	;

		R_DAC1_ena		<=	1'b0	;
		R_DAC2_ena		<=	1'b0	;
		R_DAC3_ena		<=	1'b0	;
		R_DAC4_ena		<=	1'b0	;

		R_Cnt_Data		<=	24'd0	;

		R_Rst			<=  1'b0	;
        R_Rst_vld		<=	1'b0	;

		R_offset1       <=	14'd0	;
		R_offset2       <=	14'd0	;
		R_offset3       <=	14'd0	;
		R_offset4       <=	14'd0	;

		R_length  		<=  24'd250 ;

		R_addr  		<=  24'd0   ;

		R_DAC1_RAM_addrA	<=	24'd0	;
		R_DAC2_RAM_addrA	<=	24'd0	;
		R_DAC3_RAM_addrA	<=	24'd0	;
		R_DAC4_RAM_addrA	<=	24'd0	;

		AWG_CH1_WAVENUM		<=	11'd0	;
		AWG_CH2_WAVENUM		<=	11'd0	;
		AWG_CH3_WAVENUM		<=	11'd0	;
		AWG_CH4_WAVENUM		<=	11'd0	;

		AWG_CH1_INITIAL_PHASE	<=	24'd0	;
		AWG_CH2_INITIAL_PHASE	<=	24'd0	;
		AWG_CH3_INITIAL_PHASE	<=	24'd0	;
		AWG_CH4_INITIAL_PHASE	<=	24'd0	;

		AWG_CH1_PINC		<=	27'd0	;
		AWG_CH2_PINC		<=	27'd0	;
		AWG_CH3_PINC		<=	27'd0	;
		AWG_CH4_PINC		<=	27'd0	;

		AWG_CH1_PINC_vld	<=	1'b0	;
		AWG_CH2_PINC_vld	<=	1'b0	;
		AWG_CH3_PINC_vld	<=	1'b0	;
		AWG_CH4_PINC_vld	<=	1'b0	;

		Config_Group1_ram      	<=	8'b00010010	;
		Config_Group1_port      <=	8'b00010010	;
		Config_Group1_mixer_on  <=	1'b1		;
		Config_Group2_ram      	<=	8'b00110100	;
		Config_Group2_port      <=	8'b00110100	;
		Config_Group2_mixer_on  <=	1'b1		;

		AWG_CH1_INITIAL_PHASE_vld	<=	1'b0	;
		AWG_CH2_INITIAL_PHASE_vld	<=	1'b0	;
		AWG_CH3_INITIAL_PHASE_vld	<=	1'b0	;
		AWG_CH4_INITIAL_PHASE_vld	<=	1'b0	;

		AWG_WORK_MODE		<=	1'b0	;

		PXIE_Value_Delay_Dci1	<=	9'h070	;
		PXIE_Value_Delay_Dci2	<=	9'h060	;
		PXIE_Value_Delay_Dci3	<=	9'h000	;
		PXIE_Value_Delay_Dci4	<=	9'h081	;
		PXIE_LOAD			<=	1'b1	;

		// IIR_on				<=	4'b1111	;
		IIR_on				<=	4'b0000	;
		
		IIR_reset			<=	4'b1111 ;

		CW_MODE	<=	1'b0	;
		
		O_trig			<= 	1'b0	;
		O_trig_valid	<=	4'b0000;

		wea_to_awg_delay_ram1	<= 	1'b0	;
		wea_to_awg_delay_ram2	<= 	1'b0	;
		wea_to_awg_delay_ram3	<= 	1'b0	;
		wea_to_awg_delay_ram4	<= 	1'b0	;

		wea_to_awg_delay_ram1	<= 	1'b0	;
		wea_to_awg_delay_ram2	<= 	1'b0	;
		wea_to_awg_delay_ram3	<= 	1'b0	;
		wea_to_awg_delay_ram4	<= 	1'b0	;

		wea_to_awg_addr_ram1	<= 	1'b0	;
		wea_to_awg_addr_ram2	<= 	1'b0	;
		wea_to_awg_addr_ram3	<= 	1'b0	;
		wea_to_awg_addr_ram4	<= 	1'b0	;

		//1X滤波参数
        alpha_in_1X                 <=    16'd0    ; 

        complement_alpha_06_1X      <=    16'd0    ; 
        complement_alpha_05_1X      <=    16'd0    ; 
        complement_alpha_04_1X      <=    16'd0    ; 
        complement_alpha_03_1X      <=    16'd0    ; 
        complement_alpha_02_1X      <=    16'd0    ; 
        complement_alpha_01_1X      <=    16'd0    ; 
        complement_alpha_00_1X      <=    16'd0    ; 

        alpha_complement_alpha_05_1X<=    16'd0    ; 
        alpha_complement_alpha_04_1X<=    16'd0    ; 
        alpha_complement_alpha_03_1X<=    16'd0    ; 
        alpha_complement_alpha_02_1X<=    16'd0    ; 
        alpha_complement_alpha_01_1X<=    16'd0    ; 
        alpha_complement_alpha_00_1X<=    16'd0    ; 

        k_in_1X                     <=    16'd0    ; 
        complement_k_in_1X          <=    16'd0    ; 

		//2X滤波参数
        alpha_in_2X                 <=    16'd0    ; 

        complement_alpha_06_2X      <=    16'd0    ; 
        complement_alpha_05_2X      <=    16'd0    ; 
        complement_alpha_04_2X      <=    16'd0    ; 
        complement_alpha_03_2X      <=    16'd0    ; 
        complement_alpha_02_2X      <=    16'd0    ; 
        complement_alpha_01_2X      <=    16'd0    ; 
        complement_alpha_00_2X      <=    16'd0    ; 

        alpha_complement_alpha_05_2X<=    16'd0    ; 
        alpha_complement_alpha_04_2X<=    16'd0    ; 
        alpha_complement_alpha_03_2X<=    16'd0    ; 
        alpha_complement_alpha_02_2X<=    16'd0    ; 
        alpha_complement_alpha_01_2X<=    16'd0    ; 
        alpha_complement_alpha_00_2X<=    16'd0    ; 

        k_in_2X                     <=    16'd0    ; 
        complement_k_in_2X          <=    16'd0    ; 

		//3X滤波参数
        alpha_in_3X                 <=    16'd0    ; 

        complement_alpha_06_3X      <=    16'd0    ; 
        complement_alpha_05_3X      <=    16'd0    ; 
        complement_alpha_04_3X      <=    16'd0    ; 
        complement_alpha_03_3X      <=    16'd0    ; 
        complement_alpha_02_3X      <=    16'd0    ; 
        complement_alpha_01_3X      <=    16'd0    ; 
        complement_alpha_00_3X      <=    16'd0    ; 

        alpha_complement_alpha_05_3X<=    16'd0    ; 
        alpha_complement_alpha_04_3X<=    16'd0    ; 
        alpha_complement_alpha_03_3X<=    16'd0    ; 
        alpha_complement_alpha_02_3X<=    16'd0    ; 
        alpha_complement_alpha_01_3X<=    16'd0    ; 
        alpha_complement_alpha_00_3X<=    16'd0    ; 

        k_in_3X                     <=    16'd0    ; 
        complement_k_in_3X          <=    16'd0    ; 

		//4X滤波参数
        alpha_in_4X                 <=    16'd0    ; 

        complement_alpha_06_4X      <=    16'd0    ; 
        complement_alpha_05_4X      <=    16'd0    ; 
        complement_alpha_04_4X      <=    16'd0    ; 
        complement_alpha_03_4X      <=    16'd0    ; 
        complement_alpha_02_4X      <=    16'd0    ; 
        complement_alpha_01_4X      <=    16'd0    ; 
        complement_alpha_00_4X      <=    16'd0    ; 

        alpha_complement_alpha_05_4X<=    16'd0    ; 
        alpha_complement_alpha_04_4X<=    16'd0    ; 
        alpha_complement_alpha_03_4X<=    16'd0    ; 
        alpha_complement_alpha_02_4X<=    16'd0    ; 
        alpha_complement_alpha_01_4X<=    16'd0    ; 
        alpha_complement_alpha_00_4X<=    16'd0    ; 

        k_in_4X                     <=    16'd0    ; 
        complement_k_in_4X          <=    16'd0    ; 

		//5X滤波参数
        alpha_in_5X                 <=    16'd0    ; 

        complement_alpha_06_5X      <=    16'd0    ; 
        complement_alpha_05_5X      <=    16'd0    ; 
        complement_alpha_04_5X      <=    16'd0    ; 
        complement_alpha_03_5X      <=    16'd0    ; 
        complement_alpha_02_5X      <=    16'd0    ; 
        complement_alpha_01_5X      <=    16'd0    ; 
        complement_alpha_00_5X      <=    16'd0    ; 

        alpha_complement_alpha_05_5X<=    16'd0    ; 
        alpha_complement_alpha_04_5X<=    16'd0    ; 
        alpha_complement_alpha_03_5X<=    16'd0    ; 
        alpha_complement_alpha_02_5X<=    16'd0    ; 
        alpha_complement_alpha_01_5X<=    16'd0    ; 
        alpha_complement_alpha_00_5X<=    16'd0    ; 

        k_in_5X                     <=    16'd0    ; 
        complement_k_in_5X          <=    16'd0    ; 

		Group1_Delta_Phase_I		<=    24'd0    ;
		Group1_Delta_Phase_Q		<=    24'd0    ;
		Group1_Delta_Phase_vld		<=	  1'b0	   ;

		Group2_Delta_Phase_I		<=    24'd0    ;
		Group2_Delta_Phase_Q		<=    24'd0    ;
		Group2_Delta_Phase_vld		<=	  1'b0	   ;

		Group1_Epsilon_Amp_I		<=    24'd0    ;
		Group1_Epsilon_Amp_Q		<=    24'd0    ;
		Group2_Epsilon_Amp_I		<=    24'd0    ;
		Group2_Epsilon_Amp_Q		<=    24'd0    ;

	end	

	else
	begin
		case(R_State)
			ST_IDLE:
			begin
				R_DAC1_data		<=	128'd0	;
				R_DAC2_data		<=	128'd0	;
				R_DAC3_data		<=	128'd0	;
				R_DAC4_data		<=	128'd0	;

				R_DAC1_ena		<=	1'b0	;
				R_DAC2_ena		<=	1'b0	;
				R_DAC3_ena		<=	1'b0	;
				R_DAC4_ena		<=	1'b0	;

				R_Cnt_Data		<=	24'd0	;

				R_Rst			<=  1'b0	;
                R_Rst_vld		<=	1'b0	;

				R_offset1		<=	R_offset1	;
				R_offset2		<=	R_offset2	;
				R_offset3		<=	R_offset3	;
				R_offset4		<=	R_offset4	;

				R_length  		<=  24'd250	;

				R_addr  		<=  24'd0	;

				R_DAC1_RAM_addrA	<=	24'd0	;
				R_DAC2_RAM_addrA	<=	24'd0	;
				R_DAC3_RAM_addrA	<=	24'd0	;
				R_DAC4_RAM_addrA	<=	24'd0	;

				AWG_CH1_WAVENUM		<=	AWG_CH1_WAVENUM	;
				AWG_CH2_WAVENUM		<=	AWG_CH2_WAVENUM	;
				AWG_CH3_WAVENUM		<=	AWG_CH3_WAVENUM	;
				AWG_CH4_WAVENUM		<=	AWG_CH4_WAVENUM	;

				AWG_CH1_INITIAL_PHASE	<=	AWG_CH1_INITIAL_PHASE	;
				AWG_CH2_INITIAL_PHASE	<=	AWG_CH2_INITIAL_PHASE	;
				AWG_CH3_INITIAL_PHASE	<=	AWG_CH3_INITIAL_PHASE	;
				AWG_CH4_INITIAL_PHASE	<=	AWG_CH4_INITIAL_PHASE	;

				AWG_CH1_PINC		<=	AWG_CH1_PINC	;
				AWG_CH2_PINC		<=	AWG_CH2_PINC	;
				AWG_CH3_PINC		<=	AWG_CH3_PINC	;
				AWG_CH4_PINC		<=	AWG_CH4_PINC	;
				
				AWG_CH1_PINC_vld	<=	1'b0	;
				AWG_CH2_PINC_vld	<=	1'b0	;
				AWG_CH3_PINC_vld	<=	1'b0	;
				AWG_CH4_PINC_vld	<=	1'b0	;

				Config_Group1_ram      <=	Config_Group1_ram		;
				Config_Group1_port      <=	Config_Group1_port		;
				Config_Group1_mixer_on  <=	Config_Group1_mixer_on	;
				Config_Group2_ram      <=	Config_Group2_ram		;
				Config_Group2_port      <=	Config_Group2_port		;
				Config_Group2_mixer_on  <=	Config_Group2_mixer_on	;

				AWG_CH1_INITIAL_PHASE_vld	<=	1'b0	;
				AWG_CH2_INITIAL_PHASE_vld	<=	1'b0	;
				AWG_CH3_INITIAL_PHASE_vld	<=	1'b0	;
				AWG_CH4_INITIAL_PHASE_vld	<=	1'b0	;

				CW_MODE			<=	CW_MODE	;

				AWG_WORK_MODE	<=	AWG_WORK_MODE	;

				PXIE_Value_Delay_Dci1	<=	PXIE_Value_Delay_Dci1	;
				PXIE_Value_Delay_Dci2	<=	PXIE_Value_Delay_Dci2	;
				PXIE_Value_Delay_Dci3	<=	PXIE_Value_Delay_Dci3	;
				PXIE_Value_Delay_Dci4	<=	PXIE_Value_Delay_Dci4	;
				PXIE_LOAD			<=	PXIE_LOAD	;

				IIR_on			<=	IIR_on			;

				IIR_reset		<=	IIR_reset		;

				O_trig			<= 	1'b0			;
				O_trig_valid	<=	O_trig_valid	;

				wea_to_awg_delay_ram1	<= 	1'b0	;
				wea_to_awg_delay_ram2	<= 	1'b0	;
				wea_to_awg_delay_ram3	<= 	1'b0	;
				wea_to_awg_delay_ram4	<= 	1'b0	;

				wea_to_awg_len_ram1	<= 	1'b0	;
				wea_to_awg_len_ram2	<= 	1'b0	;
				wea_to_awg_len_ram3	<= 	1'b0	;
				wea_to_awg_len_ram4	<= 	1'b0	;

				wea_to_awg_addr_ram1	<= 	1'b0	;
				wea_to_awg_addr_ram2	<= 	1'b0	;
				wea_to_awg_addr_ram3	<= 	1'b0	;
				wea_to_awg_addr_ram4	<= 	1'b0	;

				//1X滤波参数
				alpha_in_1X                 <=    alpha_in_1X    				; 
				complement_alpha_06_1X      <=    complement_alpha_06_1X    	; 
				complement_alpha_05_1X      <=    complement_alpha_05_1X   		; 
				complement_alpha_04_1X      <=    complement_alpha_04_1X    	;

				complement_alpha_03_1X      <=    complement_alpha_03_1X   		; 
				complement_alpha_02_1X      <=    complement_alpha_02_1X    	; 
				complement_alpha_01_1X      <=    complement_alpha_01_1X   		; 
				complement_alpha_00_1X      <=    complement_alpha_00_1X    	; 

				alpha_complement_alpha_05_1X<=    alpha_complement_alpha_05_1X  ; 
				alpha_complement_alpha_04_1X<=    alpha_complement_alpha_04_1X  ; 
				alpha_complement_alpha_03_1X<=    alpha_complement_alpha_03_1X  ; 
				alpha_complement_alpha_02_1X<=    alpha_complement_alpha_02_1X  ;

				alpha_complement_alpha_01_1X<=    alpha_complement_alpha_01_1X  ; 
				alpha_complement_alpha_00_1X<=    alpha_complement_alpha_00_1X  ;
				k_in_1X                     <=    k_in_1X    					; 
				complement_k_in_1X          <=    complement_k_in_1X    		;

				//2X滤波参数
				alpha_in_2X                 <=    alpha_in_2X    				; 
				complement_alpha_06_2X      <=    complement_alpha_06_2X    	; 
				complement_alpha_05_2X      <=    complement_alpha_05_2X   		; 
				complement_alpha_04_2X      <=    complement_alpha_04_2X    	;

				complement_alpha_03_2X      <=    complement_alpha_03_2X   		; 
				complement_alpha_02_2X      <=    complement_alpha_02_2X    	; 
				complement_alpha_01_2X      <=    complement_alpha_01_2X   		; 
				complement_alpha_00_2X      <=    complement_alpha_00_2X    	; 

				alpha_complement_alpha_05_2X<=    alpha_complement_alpha_05_2X  ; 
				alpha_complement_alpha_04_2X<=    alpha_complement_alpha_04_2X  ; 
				alpha_complement_alpha_03_2X<=    alpha_complement_alpha_03_2X  ; 
				alpha_complement_alpha_02_2X<=    alpha_complement_alpha_02_2X  ;

				alpha_complement_alpha_01_2X<=    alpha_complement_alpha_01_2X  ; 
				alpha_complement_alpha_00_2X<=    alpha_complement_alpha_00_2X  ;
				k_in_2X                     <=    k_in_2X    					; 
				complement_k_in_2X          <=    complement_k_in_2X    		;

				//3X滤波参数
				alpha_in_3X                 <=    alpha_in_3X    				; 
				complement_alpha_06_3X      <=    complement_alpha_06_3X    	; 
				complement_alpha_05_3X      <=    complement_alpha_05_3X   		; 
				complement_alpha_04_3X      <=    complement_alpha_04_3X    	;

				complement_alpha_03_3X      <=    complement_alpha_03_3X   		; 
				complement_alpha_02_3X      <=    complement_alpha_02_3X    	; 
				complement_alpha_01_3X      <=    complement_alpha_01_3X   		; 
				complement_alpha_00_3X      <=    complement_alpha_00_3X    	; 

				alpha_complement_alpha_05_3X<=    alpha_complement_alpha_05_3X  ; 
				alpha_complement_alpha_04_3X<=    alpha_complement_alpha_04_3X  ; 
				alpha_complement_alpha_03_3X<=    alpha_complement_alpha_03_3X  ; 
				alpha_complement_alpha_02_3X<=    alpha_complement_alpha_02_3X  ;

				alpha_complement_alpha_01_3X<=    alpha_complement_alpha_01_3X  ; 
				alpha_complement_alpha_00_3X<=    alpha_complement_alpha_00_3X  ;
				k_in_3X                     <=    k_in_3X    					; 
				complement_k_in_3X          <=    complement_k_in_3X    		;  

				//4X滤波参数
				alpha_in_4X                 <=    alpha_in_4X    				; 
				complement_alpha_06_4X      <=    complement_alpha_06_4X    	; 
				complement_alpha_05_4X      <=    complement_alpha_05_4X   		; 
				complement_alpha_04_4X      <=    complement_alpha_04_4X    	;

				complement_alpha_03_4X      <=    complement_alpha_03_4X   		; 
				complement_alpha_02_4X      <=    complement_alpha_02_4X    	; 
				complement_alpha_01_4X      <=    complement_alpha_01_4X   		; 
				complement_alpha_00_4X      <=    complement_alpha_00_4X    	; 

				alpha_complement_alpha_05_4X<=    alpha_complement_alpha_05_4X  ; 
				alpha_complement_alpha_04_4X<=    alpha_complement_alpha_04_4X  ; 
				alpha_complement_alpha_03_4X<=    alpha_complement_alpha_03_4X  ; 
				alpha_complement_alpha_02_4X<=    alpha_complement_alpha_02_4X  ;

				alpha_complement_alpha_01_4X<=    alpha_complement_alpha_01_4X  ; 
				alpha_complement_alpha_00_4X<=    alpha_complement_alpha_00_4X  ;
				k_in_4X                     <=    k_in_4X    					; 
				complement_k_in_4X          <=    complement_k_in_4X    		; 

				//5X滤波参数
				alpha_in_5X                 <=    alpha_in_5X    				; 
				complement_alpha_06_5X      <=    complement_alpha_06_5X    	; 
				complement_alpha_05_5X      <=    complement_alpha_05_5X   		; 
				complement_alpha_04_5X      <=    complement_alpha_04_5X    	;

				complement_alpha_03_5X      <=    complement_alpha_03_5X   		; 
				complement_alpha_02_5X      <=    complement_alpha_02_5X    	; 
				complement_alpha_01_5X      <=    complement_alpha_01_5X   		; 
				complement_alpha_00_5X      <=    complement_alpha_00_5X    	; 

				alpha_complement_alpha_05_5X<=    alpha_complement_alpha_05_5X  ; 
				alpha_complement_alpha_04_5X<=    alpha_complement_alpha_04_5X  ; 
				alpha_complement_alpha_03_5X<=    alpha_complement_alpha_03_5X  ; 
				alpha_complement_alpha_02_5X<=    alpha_complement_alpha_02_5X  ;

				alpha_complement_alpha_01_5X<=    alpha_complement_alpha_01_5X  ; 
				alpha_complement_alpha_00_5X<=    alpha_complement_alpha_00_5X  ;
				k_in_5X                     <=    k_in_5X    					; 
				complement_k_in_5X          <=    complement_k_in_5X    		;

				Group1_Delta_Phase_I		<=    Group1_Delta_Phase_I    		;
				Group1_Delta_Phase_Q		<=    Group1_Delta_Phase_Q    		;
				Group1_Delta_Phase_vld		<=	  Group1_Delta_Phase_vld		;

				Group2_Delta_Phase_I		<=    Group2_Delta_Phase_I   		;
				Group2_Delta_Phase_Q		<=    Group2_Delta_Phase_Q    		;
				Group2_Delta_Phase_vld		<=	  Group2_Delta_Phase_vld		;

				Group1_Epsilon_Amp_I		<=    Group1_Epsilon_Amp_I    		;
				Group1_Epsilon_Amp_Q		<=    Group1_Epsilon_Amp_Q    		;
				Group2_Epsilon_Amp_I		<=    Group2_Epsilon_Amp_I    		;
				Group2_Epsilon_Amp_Q		<=    Group2_Epsilon_Amp_Q    		;

			end

			ST_HEAD:
			begin
				R_DAC1_data		<=	128'd0	;
				R_DAC2_data		<=	128'd0	;
				R_DAC3_data		<=	128'd0	;
				R_DAC4_data		<=	128'd0	;

				R_DAC1_ena		<=	1'b0	;
				R_DAC2_ena		<=	1'b0	;
				R_DAC3_ena		<=	1'b0	;
				R_DAC4_ena		<=	1'b0	;

				R_Cnt_Data		<=	24'd0	;

				R_Rst			<=  1'b0	;
                R_Rst_vld		<=	1'b0	;

				//每个通道的offset设置
				if((I_PXIE_DATA[127:112] == 16'h1ceb)&&(I_PXIE_DATA_VLD))
				begin
					R_offset1  <= I_PXIE_DATA[15:0]	;
				end
				else if((I_PXIE_DATA[127:112] == 16'h2ceb)&&(I_PXIE_DATA_VLD))
				begin
					R_offset2  <= I_PXIE_DATA[15:0]	;
				end
				else if((I_PXIE_DATA[127:112] == 16'h3ceb)&&(I_PXIE_DATA_VLD))
				begin
					R_offset3  <= I_PXIE_DATA[15:0]	;	
				end
				else if((I_PXIE_DATA[127:112] == 16'h4ceb)&&(I_PXIE_DATA_VLD))
				begin
					R_offset4  <= I_PXIE_DATA[15:0]	;						
				end
				else
				begin
					R_offset1	<=	R_offset1	;
					R_offset2	<=	R_offset2	;
					R_offset3	<=	R_offset3	;
					R_offset4	<=	R_offset4	;	
				end

				//记录将要写入RAM的总次数，一次写入八个数据点
				//记录将要写入RAM的起始地址
				if((I_PXIE_DATA[127:112] == 16'h9ceb)&&(I_PXIE_DATA[111:96] == 16'h0001)&&(I_PXIE_DATA_VLD))
				begin
					R_length  <= I_PXIE_DATA[23:0]		;	
					R_addr  <= I_PXIE_DATA[55:32]		;
					R_DAC1_RAM_addrA <= I_PXIE_DATA[55:32] ;
				end
				else if((I_PXIE_DATA[127:112] == 16'h9ceb)&&(I_PXIE_DATA[111:96] == 16'h0002)&&(I_PXIE_DATA_VLD))
				begin
					R_length  <= I_PXIE_DATA[23:0]		;	
					R_addr  <= I_PXIE_DATA[55:32]		;
					R_DAC2_RAM_addrA <= I_PXIE_DATA[55:32] ;
				end
				else if((I_PXIE_DATA[127:112] == 16'h9ceb)&&(I_PXIE_DATA[111:96] == 16'h0003)&&(I_PXIE_DATA_VLD))
				begin
					R_length  <= I_PXIE_DATA[23:0]		;	
					R_addr  <= I_PXIE_DATA[55:32]		;
					R_DAC3_RAM_addrA <= I_PXIE_DATA[55:32] ;
				end
				else if((I_PXIE_DATA[127:112] == 16'h9ceb)&&(I_PXIE_DATA[111:96] == 16'h0004)&&(I_PXIE_DATA_VLD))
				begin
					R_length  <= I_PXIE_DATA[23:0]		;	
					R_addr  <= I_PXIE_DATA[55:32]		;
					R_DAC4_RAM_addrA <= I_PXIE_DATA[55:32] ;
				end
				else
				begin
					R_length  <=   R_length	;

					R_addr    <=   R_addr	  ;

					R_DAC1_RAM_addrA	<=	R_DAC1_RAM_addrA;
					R_DAC2_RAM_addrA	<=	R_DAC2_RAM_addrA;
					R_DAC3_RAM_addrA	<=	R_DAC3_RAM_addrA;
					R_DAC4_RAM_addrA	<=	R_DAC4_RAM_addrA;
				end

				//每个通道里有效波形的总个数
				if((I_PXIE_DATA[127:112] == 16'ha21b)&&(I_PXIE_DATA[111:96] == 16'h0001)&&(I_PXIE_DATA_VLD))
				begin
					AWG_CH1_WAVENUM <= I_PXIE_DATA[MAXIMUM_WIDTH_OF_EACH_CH - 1:0];		
				end
				else if((I_PXIE_DATA[127:112] == 16'ha21b)&&(I_PXIE_DATA[111:96] == 16'h0002)&&(I_PXIE_DATA_VLD))
				begin
					AWG_CH2_WAVENUM <= I_PXIE_DATA[MAXIMUM_WIDTH_OF_EACH_CH - 1:0];		
				end
				else if((I_PXIE_DATA[127:112] == 16'ha21b)&&(I_PXIE_DATA[111:96] == 16'h0003)&&(I_PXIE_DATA_VLD))
				begin
					AWG_CH3_WAVENUM <= I_PXIE_DATA[MAXIMUM_WIDTH_OF_EACH_CH - 1:0];		
				end
				else if((I_PXIE_DATA[127:112] == 16'ha21b)&&(I_PXIE_DATA[111:96] == 16'h0004)&&(I_PXIE_DATA_VLD))
				begin
					AWG_CH4_WAVENUM <= I_PXIE_DATA[MAXIMUM_WIDTH_OF_EACH_CH - 1:0];		
				end
				else
				begin
					AWG_CH1_WAVENUM		<=	AWG_CH1_WAVENUM	;
					AWG_CH2_WAVENUM		<=	AWG_CH2_WAVENUM	;
					AWG_CH3_WAVENUM		<=	AWG_CH3_WAVENUM	;
					AWG_CH4_WAVENUM		<=	AWG_CH4_WAVENUM	;					
				end

				//每个通道初始相位字的设置
				if((I_PXIE_DATA[127:112] == 16'h5c3b)&&(I_PXIE_DATA[111:96] == 16'h0001)&&(I_PXIE_DATA_VLD))
				begin
					AWG_CH1_INITIAL_PHASE <= I_PXIE_DATA[23:0];

					AWG_CH1_INITIAL_PHASE_vld	<=	1'b1	;
					AWG_CH2_INITIAL_PHASE_vld	<=	1'b0	;
					AWG_CH3_INITIAL_PHASE_vld	<=	1'b0	;
					AWG_CH4_INITIAL_PHASE_vld	<=	1'b0	;		
				end
				else if((I_PXIE_DATA[127:112] == 16'h5c3b)&&(I_PXIE_DATA[111:96] == 16'h0002)&&(I_PXIE_DATA_VLD))
				begin
					AWG_CH2_INITIAL_PHASE <= I_PXIE_DATA[23:0];	

					AWG_CH1_INITIAL_PHASE_vld	<=	1'b0	;
					AWG_CH2_INITIAL_PHASE_vld	<=	1'b1	;
					AWG_CH3_INITIAL_PHASE_vld	<=	1'b0	;
					AWG_CH4_INITIAL_PHASE_vld	<=	1'b0	;			
				end
				else if((I_PXIE_DATA[127:112] == 16'h5c3b)&&(I_PXIE_DATA[111:96] == 16'h0003)&&(I_PXIE_DATA_VLD))
				begin
					AWG_CH3_INITIAL_PHASE <= I_PXIE_DATA[23:0];

					AWG_CH1_INITIAL_PHASE_vld	<=	1'b0	;
					AWG_CH2_INITIAL_PHASE_vld	<=	1'b0	;
					AWG_CH3_INITIAL_PHASE_vld	<=	1'b1	;
					AWG_CH4_INITIAL_PHASE_vld	<=	1'b0	;		
				end
				else if((I_PXIE_DATA[127:112] == 16'h5c3b)&&(I_PXIE_DATA[111:96] == 16'h0004)&&(I_PXIE_DATA_VLD))
				begin
					AWG_CH4_INITIAL_PHASE <= I_PXIE_DATA[23:0];

					AWG_CH1_INITIAL_PHASE_vld	<=	1'b0	;
					AWG_CH2_INITIAL_PHASE_vld	<=	1'b0	;
					AWG_CH3_INITIAL_PHASE_vld	<=	1'b0	;
					AWG_CH4_INITIAL_PHASE_vld	<=	1'b1	;			
				end
				else
				begin
					AWG_CH1_INITIAL_PHASE	<=	AWG_CH1_INITIAL_PHASE	;
					AWG_CH2_INITIAL_PHASE	<=	AWG_CH2_INITIAL_PHASE	;
					AWG_CH3_INITIAL_PHASE	<=	AWG_CH3_INITIAL_PHASE	;
					AWG_CH4_INITIAL_PHASE	<=	AWG_CH4_INITIAL_PHASE	;

					AWG_CH1_INITIAL_PHASE_vld	<=	1'b0	;
					AWG_CH2_INITIAL_PHASE_vld	<=	1'b0	;
					AWG_CH3_INITIAL_PHASE_vld	<=	1'b0	;
					AWG_CH4_INITIAL_PHASE_vld	<=	1'b0	;						
				end


				//每个通道里频率控制字参数的设置
				if((I_PXIE_DATA[127:112] == 16'h31ef)&&(I_PXIE_DATA[111:96] == 16'h0001)&&(I_PXIE_DATA_VLD))
				begin
					AWG_CH1_PINC <= I_PXIE_DATA[26:0];
					AWG_CH1_PINC_vld	<=	1'b1	;
					AWG_CH2_PINC_vld	<=	1'b0	;
					AWG_CH3_PINC_vld	<=	1'b0	;
					AWG_CH4_PINC_vld	<=	1'b0	;		
				end
				else if((I_PXIE_DATA[127:112] == 16'h31ef)&&(I_PXIE_DATA[111:96] == 16'h0002)&&(I_PXIE_DATA_VLD))
				begin
					AWG_CH2_PINC <= I_PXIE_DATA[26:0];
					AWG_CH1_PINC_vld	<=	1'b0	;
					AWG_CH2_PINC_vld	<=	1'b1	;
					AWG_CH3_PINC_vld	<=	1'b0	;
					AWG_CH4_PINC_vld	<=	1'b0	;		
				end
				else if((I_PXIE_DATA[127:112] == 16'h31ef)&&(I_PXIE_DATA[111:96] == 16'h0003)&&(I_PXIE_DATA_VLD))
				begin
					AWG_CH3_PINC <= I_PXIE_DATA[26:0];	
					AWG_CH1_PINC_vld	<=	1'b0	;
					AWG_CH2_PINC_vld	<=	1'b0	;
					AWG_CH3_PINC_vld	<=	1'b1	;
					AWG_CH4_PINC_vld	<=	1'b0	;	
				end
				else if((I_PXIE_DATA[127:112] == 16'h31ef)&&(I_PXIE_DATA[111:96] == 16'h0004)&&(I_PXIE_DATA_VLD))
				begin
					AWG_CH4_PINC <= I_PXIE_DATA[26:0];
					AWG_CH1_PINC_vld	<=	1'b0	;
					AWG_CH2_PINC_vld	<=	1'b0	;
					AWG_CH3_PINC_vld	<=	1'b0	;
					AWG_CH4_PINC_vld	<=	1'b1	;		
				end
				else
				begin
					AWG_CH1_PINC		<=	AWG_CH1_PINC	;
					AWG_CH2_PINC		<=	AWG_CH2_PINC	;
					AWG_CH3_PINC		<=	AWG_CH3_PINC	;
					AWG_CH4_PINC		<=	AWG_CH4_PINC	;

					AWG_CH1_PINC_vld	<=	1'b0	;
					AWG_CH2_PINC_vld	<=	1'b0	;
					AWG_CH3_PINC_vld	<=	1'b0	;
					AWG_CH4_PINC_vld	<=	1'b0	;					
				end

				//告知DDS_DataProcess的数据处理方式
				if((I_PXIE_DATA[127:112] == 16'h16cb)&&(I_PXIE_DATA[111:96] == 16'h0001)&&(I_PXIE_DATA_VLD))
				begin
					Config_Group1_ram      	<=	{I_PXIE_DATA[15:12],I_PXIE_DATA[11:8]}	;
					Config_Group1_port      <=	{I_PXIE_DATA[7:4],I_PXIE_DATA[3:0]}		;
					Config_Group1_mixer_on  <=	I_PXIE_DATA[31]							;
					Config_Group2_ram      	<=	Config_Group2_ram						;
					Config_Group2_port      <=	Config_Group2_port						;
					Config_Group2_mixer_on  <=	Config_Group2_mixer_on					;					
				end
				else if((I_PXIE_DATA[127:112] == 16'h16cb)&&(I_PXIE_DATA[111:96] == 16'h0002)&&(I_PXIE_DATA_VLD))
				begin
					Config_Group1_ram      	<=	Config_Group1_ram						;
					Config_Group1_port      <=	Config_Group1_port						;
					Config_Group1_mixer_on  <=	Config_Group1_mixer_on					;
					Config_Group2_ram      	<=	{I_PXIE_DATA[15:12],I_PXIE_DATA[11:8]}	;
					Config_Group2_port      <=	{I_PXIE_DATA[7:4],I_PXIE_DATA[3:0]}		;
					Config_Group2_mixer_on  <=	I_PXIE_DATA[31]							;					
				end
				else
				begin
					Config_Group1_ram      	<=	Config_Group1_ram						;
					Config_Group1_port      <=	Config_Group1_port						;
					Config_Group1_mixer_on  <=	Config_Group1_mixer_on					;
					Config_Group2_ram      	<=	Config_Group2_ram						;
					Config_Group2_port      <=	Config_Group2_port						;
					Config_Group2_mixer_on  <=	Config_Group2_mixer_on					;					
				end

				//AWG工作模式的选择
				if((I_PXIE_DATA[127:112] == 16'hbc56)&&(I_PXIE_DATA_VLD))
				begin
					AWG_WORK_MODE	<=	I_PXIE_DATA[0]	;
				end
				else
				begin
					AWG_WORK_MODE	<=	AWG_WORK_MODE	;
				end

				//给四个AD9739芯片的相位设置
				if((I_PXIE_DATA[127:112] == 16'hcc46)&&(I_PXIE_DATA_VLD))
				begin
					PXIE_LOAD		<=	1'b0		;
				end
				else
				begin
					PXIE_LOAD		<=	1'b1		;
				end

				if((I_PXIE_DATA[127:112] == 16'hac46)&&(I_PXIE_DATA_VLD))
				begin
					PXIE_Value_Delay_Dci1	<=	I_PXIE_DATA[8:0]	;
					PXIE_Value_Delay_Dci2	<=	I_PXIE_DATA[40:32]	;
					PXIE_Value_Delay_Dci3	<=	I_PXIE_DATA[72:64]	;
					PXIE_Value_Delay_Dci4	<=	I_PXIE_DATA[114:96]	;
				end
				else
				begin
					PXIE_Value_Delay_Dci1	<=	PXIE_Value_Delay_Dci1	;
					PXIE_Value_Delay_Dci2	<=	PXIE_Value_Delay_Dci2	;
					PXIE_Value_Delay_Dci3	<=	PXIE_Value_Delay_Dci3	;
					PXIE_Value_Delay_Dci4	<=	PXIE_Value_Delay_Dci4	;
				end

				//IIR滤波通道的选择
				if((I_PXIE_DATA[127:112] == 16'hbcff)&&(I_PXIE_DATA_VLD))
				begin
					IIR_on	<=	I_PXIE_DATA[3:0]	;
				end
				else
				begin
					IIR_on	<=	IIR_on				;
				end

				//IIR复位信号的选择
				if((I_PXIE_DATA[127:112] == 16'hbcfe)&&(I_PXIE_DATA_VLD))
				begin
					IIR_reset	<=	I_PXIE_DATA[3:0]		;
				end
				else
				begin
					IIR_reset	<=	4'b1111					;
				end				

				//模式参数的设置
				if((I_PXIE_DATA[127:112] == 16'haceb)&&(I_PXIE_DATA_VLD))
				begin
					CW_MODE  <= I_PXIE_DATA[0]		;						
				end
				else
				begin
					CW_MODE	<=	CW_MODE	;
				end	                                 		
				
				//AWG的trig命令设置
				if((I_PXIE_DATA[127:112] == 16'h76cb)&&(I_PXIE_DATA_VLD))
				begin
					O_trig			<= 	1'b1			;						
				end
				else
				begin
					O_trig			<=	1'b0			;
				end

				//AWG的trig_mask命令设置
				if((I_PXIE_DATA[127:112] == 16'hbc67)&&(I_PXIE_DATA_VLD))
				begin
					O_trig_valid	<=	I_PXIE_DATA[3:0];						
				end
				else
				begin
					O_trig_valid	<=	O_trig_valid	;
				end

				//每个通道里各个波形的DELAY参数设置
				if((I_PXIE_DATA[127:112] == 16'hcceb)&&(I_PXIE_DATA[111:96] == 16'h0001)&&(I_PXIE_DATA_VLD))
				begin
					wea_to_awg_delay_ram1			<= 	1'b1												;
					wea_to_awg_delay_ram2			<= 	1'b0												;
					wea_to_awg_delay_ram3			<= 	1'b0												;
					wea_to_awg_delay_ram4			<= 	1'b0												;
					write_addr_to_awg_delay_ram1	<=	I_PXIE_DATA[80 + MAXIMUM_WIDTH_OF_EACH_CH - 1:80]	;
					write_data_to_awg_delay_ram1	<=	I_PXIE_DATA[23:0]									;						
				end
				else if((I_PXIE_DATA[127:112] == 16'hcceb)&&(I_PXIE_DATA[111:96] == 16'h0002)&&(I_PXIE_DATA_VLD))
				begin
					wea_to_awg_delay_ram1			<= 	1'b0												;
					wea_to_awg_delay_ram2			<= 	1'b1												;
					wea_to_awg_delay_ram3			<= 	1'b0												;
					wea_to_awg_delay_ram4			<= 	1'b0												;
					write_addr_to_awg_delay_ram2	<=	I_PXIE_DATA[80 + MAXIMUM_WIDTH_OF_EACH_CH - 1:80]	;
					write_data_to_awg_delay_ram2	<=	I_PXIE_DATA[23:0]									;	
				end
				else if((I_PXIE_DATA[127:112] == 16'hcceb)&&(I_PXIE_DATA[111:96] == 16'h0003)&&(I_PXIE_DATA_VLD))
				begin
					wea_to_awg_delay_ram1			<= 	1'b0												;
					wea_to_awg_delay_ram2			<= 	1'b0												;
					wea_to_awg_delay_ram3			<= 	1'b1												;
					wea_to_awg_delay_ram4			<= 	1'b0												;
					write_addr_to_awg_delay_ram3	<=	I_PXIE_DATA[80 + MAXIMUM_WIDTH_OF_EACH_CH - 1:80]	;
					write_data_to_awg_delay_ram3	<=	I_PXIE_DATA[23:0]									;	
				end
				else if((I_PXIE_DATA[127:112] == 16'hcceb)&&(I_PXIE_DATA[111:96] == 16'h0004)&&(I_PXIE_DATA_VLD))
				begin
					wea_to_awg_delay_ram1			<= 	1'b0												;
					wea_to_awg_delay_ram2			<= 	1'b0												;
					wea_to_awg_delay_ram3			<= 	1'b0												;
					wea_to_awg_delay_ram4			<= 	1'b1												;
					write_addr_to_awg_delay_ram4	<=	I_PXIE_DATA[80 + MAXIMUM_WIDTH_OF_EACH_CH - 1:80]	;
					write_data_to_awg_delay_ram4	<=	I_PXIE_DATA[23:0]									;	
				end
				else
				begin
					wea_to_awg_delay_ram1			<= 	1'b0												;
					wea_to_awg_delay_ram2			<= 	1'b0												;
					wea_to_awg_delay_ram3			<= 	1'b0												;
					wea_to_awg_delay_ram4			<= 	1'b0												;					
				end
				
				//每个通道里各个波形的LENGTH参数设置
				if((I_PXIE_DATA[127:112] == 16'hd1eb)&&(I_PXIE_DATA[111:96] == 16'h0001)&&(I_PXIE_DATA_VLD))
				begin
					wea_to_awg_len_ram1				<= 	1'b1												;
					wea_to_awg_len_ram2				<= 	1'b0												;
					wea_to_awg_len_ram3				<= 	1'b0												;
					wea_to_awg_len_ram4				<= 	1'b0												;
					write_addr_to_awg_len_ram1		<=	I_PXIE_DATA[80 + MAXIMUM_WIDTH_OF_EACH_CH - 1:80]	;
					write_data_to_awg_len_ram1		<=	I_PXIE_DATA[23:0]									;				
				end
				else if((I_PXIE_DATA[127:112] == 16'hd1eb)&&(I_PXIE_DATA[111:96] == 16'h0002)&&(I_PXIE_DATA_VLD))
				begin
					wea_to_awg_len_ram1				<= 	1'b0												;
					wea_to_awg_len_ram2				<= 	1'b1												;
					wea_to_awg_len_ram3				<= 	1'b0												;
					wea_to_awg_len_ram4				<= 	1'b0												;
					write_addr_to_awg_len_ram2		<=	I_PXIE_DATA[80 + MAXIMUM_WIDTH_OF_EACH_CH - 1:80]	;
					write_data_to_awg_len_ram2		<=	I_PXIE_DATA[23:0]									;			
				end
				else if((I_PXIE_DATA[127:112] == 16'hd1eb)&&(I_PXIE_DATA[111:96] == 16'h0003)&&(I_PXIE_DATA_VLD))
				begin
					wea_to_awg_len_ram1				<= 	1'b0												;
					wea_to_awg_len_ram2				<= 	1'b0												;
					wea_to_awg_len_ram3				<= 	1'b1												;
					wea_to_awg_len_ram4				<= 	1'b0												;
					write_addr_to_awg_len_ram3		<=	I_PXIE_DATA[80 + MAXIMUM_WIDTH_OF_EACH_CH - 1:80]	;
					write_data_to_awg_len_ram3		<=	I_PXIE_DATA[23:0]									;		
				end
				else if((I_PXIE_DATA[127:112] == 16'hd1eb)&&(I_PXIE_DATA[111:96] == 16'h0004)&&(I_PXIE_DATA_VLD))
				begin
					wea_to_awg_len_ram1				<= 	1'b0												;
					wea_to_awg_len_ram2				<= 	1'b0												;
					wea_to_awg_len_ram3				<= 	1'b0												;
					wea_to_awg_len_ram4				<= 	1'b1												;
					write_addr_to_awg_len_ram4		<=	I_PXIE_DATA[80 + MAXIMUM_WIDTH_OF_EACH_CH - 1:80]	;
					write_data_to_awg_len_ram4		<=	I_PXIE_DATA[23:0]									;				
				end
				else
				begin
					wea_to_awg_len_ram1				<= 	1'b0												;
					wea_to_awg_len_ram2				<= 	1'b0												;
					wea_to_awg_len_ram3				<= 	1'b0												;
					wea_to_awg_len_ram4				<= 	1'b0												;					
				end

				//每个通道里各个波形的ADDR参数设置
				if((I_PXIE_DATA[127:112] == 16'hf1eb)&&(I_PXIE_DATA[111:96] == 16'h0001)&&(I_PXIE_DATA_VLD))
				begin
					wea_to_awg_addr_ram1			<= 	1'b1												;
					wea_to_awg_addr_ram2			<= 	1'b0												;
					wea_to_awg_addr_ram3			<= 	1'b0												;
					wea_to_awg_addr_ram4			<= 	1'b0												;
					write_addr_to_awg_addr_ram1		<=	I_PXIE_DATA[80 + MAXIMUM_WIDTH_OF_EACH_CH - 1:80]	;
					write_data_to_awg_addr_ram1		<=	I_PXIE_DATA[23:0]									;			
				end
				else if((I_PXIE_DATA[127:112] == 16'hf1eb)&&(I_PXIE_DATA[111:96] == 16'h0002)&&(I_PXIE_DATA_VLD))
				begin
					wea_to_awg_addr_ram1			<= 	1'b0												;
					wea_to_awg_addr_ram2			<= 	1'b1												;
					wea_to_awg_addr_ram3			<= 	1'b0												;
					wea_to_awg_addr_ram4			<= 	1'b0												;
					write_addr_to_awg_addr_ram2		<=	I_PXIE_DATA[80 + MAXIMUM_WIDTH_OF_EACH_CH - 1:80]	;
					write_data_to_awg_addr_ram2		<=	I_PXIE_DATA[23:0]									;		
				end
				else if((I_PXIE_DATA[127:112] == 16'hf1eb)&&(I_PXIE_DATA[111:96] == 16'h0003)&&(I_PXIE_DATA_VLD))
				begin
					wea_to_awg_addr_ram1			<= 	1'b0												;
					wea_to_awg_addr_ram2			<= 	1'b0												;
					wea_to_awg_addr_ram3			<= 	1'b1												;
					wea_to_awg_addr_ram4			<= 	1'b0												;
					write_addr_to_awg_addr_ram3		<=	I_PXIE_DATA[80 + MAXIMUM_WIDTH_OF_EACH_CH - 1:80]	;
					write_data_to_awg_addr_ram3		<=	I_PXIE_DATA[23:0]									;		
				end
				else if((I_PXIE_DATA[127:112] == 16'hf1eb)&&(I_PXIE_DATA[111:96] == 16'h0004)&&(I_PXIE_DATA_VLD))
				begin
					wea_to_awg_addr_ram1			<= 	1'b0												;
					wea_to_awg_addr_ram2			<= 	1'b0												;
					wea_to_awg_addr_ram3			<= 	1'b0												;
					wea_to_awg_addr_ram4			<= 	1'b1												;
					write_addr_to_awg_addr_ram4		<=	I_PXIE_DATA[80 + MAXIMUM_WIDTH_OF_EACH_CH - 1:80]	;
					write_data_to_awg_addr_ram4		<=	I_PXIE_DATA[23:0]									;			
				end
				else
				begin
					wea_to_awg_addr_ram1			<= 	1'b0												;
					wea_to_awg_addr_ram2			<= 	1'b0												;
					wea_to_awg_addr_ram3			<= 	1'b0												;
					wea_to_awg_addr_ram4			<= 	1'b0												;					
				end


				//1X滤波系数的设置
				if((I_PXIE_DATA[127:112] == 16'h12bc) && (I_PXIE_DATA[111:104] == 8'd1) && (I_PXIE_DATA_VLD)) begin
					if((I_PXIE_DATA[71:64] == 8'd0)) begin
						alpha_in_1X                 	<=    I_PXIE_DATA[15:0]    		; 
						complement_alpha_06_1X      	<=    I_PXIE_DATA[31:16]    	; 
						complement_alpha_05_1X      	<=    I_PXIE_DATA[47:32]   		; 
						complement_alpha_04_1X      	<=    I_PXIE_DATA[63:48]    	;
					end
					else if((I_PXIE_DATA[71:64] == 8'd1)) begin
						complement_alpha_03_1X      	<=    I_PXIE_DATA[15:0]    		; 
						complement_alpha_02_1X      	<=    I_PXIE_DATA[31:16]    	; 
						complement_alpha_01_1X      	<=    I_PXIE_DATA[47:32]   		; 
						complement_alpha_00_1X      	<=    I_PXIE_DATA[63:48]    	;
					end
					else if((I_PXIE_DATA[71:64] == 8'd2)) begin
						alpha_complement_alpha_05_1X    <=    I_PXIE_DATA[15:0]    		; 
						alpha_complement_alpha_04_1X    <=    I_PXIE_DATA[31:16]    	; 
						alpha_complement_alpha_03_1X    <=    I_PXIE_DATA[47:32]   		; 
						alpha_complement_alpha_02_1X    <=    I_PXIE_DATA[63:48]    	;
					end
					else if((I_PXIE_DATA[71:64] == 8'd3)) begin
						alpha_complement_alpha_01_1X    <=    I_PXIE_DATA[15:0]    		; 
						alpha_complement_alpha_00_1X    <=    I_PXIE_DATA[31:16]    	; 
						k_in_1X      					<=    I_PXIE_DATA[47:32]   		; 
						complement_k_in_1X      		<=    I_PXIE_DATA[63:48]    	;
					end
				end
				else begin
					alpha_in_1X                 <=    alpha_in_1X    				; 
					complement_alpha_06_1X      <=    complement_alpha_06_1X    	; 
					complement_alpha_05_1X      <=    complement_alpha_05_1X   		; 
					complement_alpha_04_1X      <=    complement_alpha_04_1X    	;

					complement_alpha_03_1X      <=    complement_alpha_03_1X   		; 
					complement_alpha_02_1X      <=    complement_alpha_02_1X    	; 
					complement_alpha_01_1X      <=    complement_alpha_01_1X   		; 
					complement_alpha_00_1X      <=    complement_alpha_00_1X    	; 

					alpha_complement_alpha_05_1X<=    alpha_complement_alpha_05_1X  ; 
					alpha_complement_alpha_04_1X<=    alpha_complement_alpha_04_1X  ; 
					alpha_complement_alpha_03_1X<=    alpha_complement_alpha_03_1X  ; 
					alpha_complement_alpha_02_1X<=    alpha_complement_alpha_02_1X  ;

					alpha_complement_alpha_01_1X<=    alpha_complement_alpha_01_1X  ; 
					alpha_complement_alpha_00_1X<=    alpha_complement_alpha_00_1X  ;
					k_in_1X                     <=    k_in_1X    					; 
					complement_k_in_1X          <=    complement_k_in_1X    		;

				end

				//2X滤波系数的设置
				if((I_PXIE_DATA[127:112] == 16'h12bc) && (I_PXIE_DATA[111:104] == 8'd2) && (I_PXIE_DATA_VLD)) begin
					if((I_PXIE_DATA[71:64] == 8'd0)) begin
						alpha_in_2X                 	<=    I_PXIE_DATA[15:0]    		; 
						complement_alpha_06_2X      	<=    I_PXIE_DATA[31:16]    	; 
						complement_alpha_05_2X      	<=    I_PXIE_DATA[47:32]   		; 
						complement_alpha_04_2X      	<=    I_PXIE_DATA[63:48]    	;
					end
					else if((I_PXIE_DATA[71:64] == 8'd1)) begin
						complement_alpha_03_2X      	<=    I_PXIE_DATA[15:0]    		; 
						complement_alpha_02_2X      	<=    I_PXIE_DATA[31:16]    	; 
						complement_alpha_01_2X      	<=    I_PXIE_DATA[47:32]   		; 
						complement_alpha_00_2X      	<=    I_PXIE_DATA[63:48]    	;
					end
					else if((I_PXIE_DATA[71:64] == 8'd2)) begin
						alpha_complement_alpha_05_2X    <=    I_PXIE_DATA[15:0]    		; 
						alpha_complement_alpha_04_2X    <=    I_PXIE_DATA[31:16]    	; 
						alpha_complement_alpha_03_2X    <=    I_PXIE_DATA[47:32]   		; 
						alpha_complement_alpha_02_2X    <=    I_PXIE_DATA[63:48]    	;
					end
					else if((I_PXIE_DATA[71:64] == 8'd3)) begin
						alpha_complement_alpha_01_2X    <=    I_PXIE_DATA[15:0]    		; 
						alpha_complement_alpha_00_2X    <=    I_PXIE_DATA[31:16]    	; 
						k_in_2X      					<=    I_PXIE_DATA[47:32]   		; 
						complement_k_in_2X      		<=    I_PXIE_DATA[63:48]    	;
					end
				end
				else begin
					alpha_in_2X                 <=    alpha_in_2X    				; 
					complement_alpha_06_2X      <=    complement_alpha_06_2X    	; 
					complement_alpha_05_2X      <=    complement_alpha_05_2X   		; 
					complement_alpha_04_2X      <=    complement_alpha_04_2X    	;

					complement_alpha_03_2X      <=    complement_alpha_03_2X   		; 
					complement_alpha_02_2X      <=    complement_alpha_02_2X    	; 
					complement_alpha_01_2X      <=    complement_alpha_01_2X   		; 
					complement_alpha_00_2X      <=    complement_alpha_00_2X    	; 

					alpha_complement_alpha_05_2X<=    alpha_complement_alpha_05_2X  ; 
					alpha_complement_alpha_04_2X<=    alpha_complement_alpha_04_2X  ; 
					alpha_complement_alpha_03_2X<=    alpha_complement_alpha_03_2X  ; 
					alpha_complement_alpha_02_2X<=    alpha_complement_alpha_02_2X  ;

					alpha_complement_alpha_01_2X<=    alpha_complement_alpha_01_2X  ; 
					alpha_complement_alpha_00_2X<=    alpha_complement_alpha_00_2X  ;
					k_in_2X                     <=    k_in_2X    					; 
					complement_k_in_2X          <=    complement_k_in_2X    		;
				end

				//3X滤波系数的设置
				if((I_PXIE_DATA[127:112] == 16'h12bc) && (I_PXIE_DATA[111:104] == 8'd3) && (I_PXIE_DATA_VLD)) begin
					if((I_PXIE_DATA[71:64] == 8'd0)) begin
						alpha_in_3X                 	<=    I_PXIE_DATA[15:0]    		; 
						complement_alpha_06_3X      	<=    I_PXIE_DATA[31:16]    	; 
						complement_alpha_05_3X      	<=    I_PXIE_DATA[47:32]   		; 
						complement_alpha_04_3X      	<=    I_PXIE_DATA[63:48]    	;
					end
					else if((I_PXIE_DATA[71:64] == 8'd1)) begin
						complement_alpha_03_3X      	<=    I_PXIE_DATA[15:0]    		; 
						complement_alpha_02_3X      	<=    I_PXIE_DATA[31:16]    	; 
						complement_alpha_01_3X      	<=    I_PXIE_DATA[47:32]   		; 
						complement_alpha_00_3X      	<=    I_PXIE_DATA[63:48]    	;
					end
					else if((I_PXIE_DATA[71:64] == 8'd2)) begin
						alpha_complement_alpha_05_3X    <=    I_PXIE_DATA[15:0]    		; 
						alpha_complement_alpha_04_3X    <=    I_PXIE_DATA[31:16]    	; 
						alpha_complement_alpha_03_3X    <=    I_PXIE_DATA[47:32]   		; 
						alpha_complement_alpha_02_3X    <=    I_PXIE_DATA[63:48]    	;
					end
					else if((I_PXIE_DATA[71:64] == 8'd3)) begin
						alpha_complement_alpha_01_3X    <=    I_PXIE_DATA[15:0]    		; 
						alpha_complement_alpha_00_3X    <=    I_PXIE_DATA[31:16]    	; 
						k_in_3X      					<=    I_PXIE_DATA[47:32]   		; 
						complement_k_in_3X      		<=    I_PXIE_DATA[63:48]    	;
					end
				end
				else begin
					alpha_in_3X                 <=    alpha_in_3X    				; 
					complement_alpha_06_3X      <=    complement_alpha_06_3X    	; 
					complement_alpha_05_3X      <=    complement_alpha_05_3X   		; 
					complement_alpha_04_3X      <=    complement_alpha_04_3X    	;

					complement_alpha_03_3X      <=    complement_alpha_03_3X   		; 
					complement_alpha_02_3X      <=    complement_alpha_02_3X    	; 
					complement_alpha_01_3X      <=    complement_alpha_01_3X   		; 
					complement_alpha_00_3X      <=    complement_alpha_00_3X    	; 

					alpha_complement_alpha_05_3X<=    alpha_complement_alpha_05_3X  ; 
					alpha_complement_alpha_04_3X<=    alpha_complement_alpha_04_3X  ; 
					alpha_complement_alpha_03_3X<=    alpha_complement_alpha_03_3X  ; 
					alpha_complement_alpha_02_3X<=    alpha_complement_alpha_02_3X  ;

					alpha_complement_alpha_01_3X<=    alpha_complement_alpha_01_3X  ; 
					alpha_complement_alpha_00_3X<=    alpha_complement_alpha_00_3X  ;
					k_in_3X                     <=    k_in_3X    					; 
					complement_k_in_3X          <=    complement_k_in_3X    		;
				end

				//4X滤波系数的设置
				if((I_PXIE_DATA[127:112] == 16'h12bc) && (I_PXIE_DATA[111:104] == 8'd4) && (I_PXIE_DATA_VLD)) begin
					if((I_PXIE_DATA[71:64] == 8'd0)) begin
						alpha_in_4X                 	<=    I_PXIE_DATA[15:0]    		; 
						complement_alpha_06_4X      	<=    I_PXIE_DATA[31:16]    	; 
						complement_alpha_05_4X      	<=    I_PXIE_DATA[47:32]   		; 
						complement_alpha_04_4X      	<=    I_PXIE_DATA[63:48]    	;
					end
					else if((I_PXIE_DATA[71:64] == 8'd1)) begin
						complement_alpha_03_4X      	<=    I_PXIE_DATA[15:0]    		; 
						complement_alpha_02_4X      	<=    I_PXIE_DATA[31:16]    	; 
						complement_alpha_01_4X      	<=    I_PXIE_DATA[47:32]   		; 
						complement_alpha_00_4X      	<=    I_PXIE_DATA[63:48]    	;
					end
					else if((I_PXIE_DATA[71:64] == 8'd2)) begin
						alpha_complement_alpha_05_4X    <=    I_PXIE_DATA[15:0]    		; 
						alpha_complement_alpha_04_4X    <=    I_PXIE_DATA[31:16]    	; 
						alpha_complement_alpha_03_4X    <=    I_PXIE_DATA[47:32]   		; 
						alpha_complement_alpha_02_4X    <=    I_PXIE_DATA[63:48]    	;
					end
					else if((I_PXIE_DATA[71:64] == 8'd3)) begin
						alpha_complement_alpha_01_4X    <=    I_PXIE_DATA[15:0]    		; 
						alpha_complement_alpha_00_4X    <=    I_PXIE_DATA[31:16]    	; 
						k_in_4X      					<=    I_PXIE_DATA[47:32]   		; 
						complement_k_in_4X      		<=    I_PXIE_DATA[63:48]    	;
					end
				end
				else begin
					alpha_in_4X                 <=    alpha_in_4X    				; 
					complement_alpha_06_4X      <=    complement_alpha_06_4X    	; 
					complement_alpha_05_4X      <=    complement_alpha_05_4X   		; 
					complement_alpha_04_4X      <=    complement_alpha_04_4X    	;

					complement_alpha_03_4X      <=    complement_alpha_03_4X   		; 
					complement_alpha_02_4X      <=    complement_alpha_02_4X    	; 
					complement_alpha_01_4X      <=    complement_alpha_01_4X   		; 
					complement_alpha_00_4X      <=    complement_alpha_00_4X    	; 

					alpha_complement_alpha_05_4X<=    alpha_complement_alpha_05_4X  ; 
					alpha_complement_alpha_04_4X<=    alpha_complement_alpha_04_4X  ; 
					alpha_complement_alpha_03_4X<=    alpha_complement_alpha_03_4X  ; 
					alpha_complement_alpha_02_4X<=    alpha_complement_alpha_02_4X  ;

					alpha_complement_alpha_01_4X<=    alpha_complement_alpha_01_4X  ; 
					alpha_complement_alpha_00_4X<=    alpha_complement_alpha_00_4X  ;
					k_in_4X                     <=    k_in_4X    					; 
					complement_k_in_4X          <=    complement_k_in_4X    		;
				end

				//5X滤波系数的设置
				if((I_PXIE_DATA[127:112] == 16'h12bc) && (I_PXIE_DATA[111:104] == 8'd5) && (I_PXIE_DATA_VLD)) begin
					if((I_PXIE_DATA[71:64] == 8'd0)) begin
						alpha_in_5X                 	<=    I_PXIE_DATA[15:0]    		; 
						complement_alpha_06_5X      	<=    I_PXIE_DATA[31:16]    	; 
						complement_alpha_05_5X      	<=    I_PXIE_DATA[47:32]   		; 
						complement_alpha_04_5X      	<=    I_PXIE_DATA[63:48]    	;
					end
					else if((I_PXIE_DATA[71:64] == 8'd1)) begin
						complement_alpha_03_5X      	<=    I_PXIE_DATA[15:0]    		; 
						complement_alpha_02_5X      	<=    I_PXIE_DATA[31:16]    	; 
						complement_alpha_01_5X      	<=    I_PXIE_DATA[47:32]   		; 
						complement_alpha_00_5X      	<=    I_PXIE_DATA[63:48]    	;
					end
					else if((I_PXIE_DATA[71:64] == 8'd2)) begin
						alpha_complement_alpha_05_5X    <=    I_PXIE_DATA[15:0]    		; 
						alpha_complement_alpha_04_5X    <=    I_PXIE_DATA[31:16]    	; 
						alpha_complement_alpha_03_5X    <=    I_PXIE_DATA[47:32]   		; 
						alpha_complement_alpha_02_5X    <=    I_PXIE_DATA[63:48]    	;
					end
					else if((I_PXIE_DATA[71:64] == 8'd3)) begin
						alpha_complement_alpha_01_5X    <=    I_PXIE_DATA[15:0]    		; 
						alpha_complement_alpha_00_5X    <=    I_PXIE_DATA[31:16]    	; 
						k_in_5X      					<=    I_PXIE_DATA[47:32]   		; 
						complement_k_in_5X      		<=    I_PXIE_DATA[63:48]    	;
					end
				end
				else begin
					alpha_in_5X                 <=    alpha_in_5X    				; 
					complement_alpha_06_5X      <=    complement_alpha_06_5X    	; 
					complement_alpha_05_5X      <=    complement_alpha_05_5X   		; 
					complement_alpha_04_5X      <=    complement_alpha_04_5X    	;

					complement_alpha_03_5X      <=    complement_alpha_03_5X   		; 
					complement_alpha_02_5X      <=    complement_alpha_02_5X    	; 
					complement_alpha_01_5X      <=    complement_alpha_01_5X   		; 
					complement_alpha_00_5X      <=    complement_alpha_00_5X    	; 

					alpha_complement_alpha_05_5X<=    alpha_complement_alpha_05_5X  ; 
					alpha_complement_alpha_04_5X<=    alpha_complement_alpha_04_5X  ; 
					alpha_complement_alpha_03_5X<=    alpha_complement_alpha_03_5X  ; 
					alpha_complement_alpha_02_5X<=    alpha_complement_alpha_02_5X  ;

					alpha_complement_alpha_01_5X<=    alpha_complement_alpha_01_5X  ; 
					alpha_complement_alpha_00_5X<=    alpha_complement_alpha_00_5X  ;
					k_in_5X                     <=    k_in_5X    					; 
					complement_k_in_5X          <=    complement_k_in_5X    		;
				end

				//IQ Correction Delta_Phase的参数传递
				if((I_PXIE_DATA[127:112] == 16'h45ab)&&(I_PXIE_DATA[111:96] == 16'h0001)&&(I_PXIE_DATA_VLD))
				begin
					Group1_Delta_Phase_I		<=    I_PXIE_DATA[23:0]    			;
					Group1_Delta_Phase_Q		<=    I_PXIE_DATA[55:32]    		;
					Group1_Delta_Phase_vld		<=	  1'b1							;						
				end
				else
				begin
					Group1_Delta_Phase_I		<=    Group1_Delta_Phase_I    		;
					Group1_Delta_Phase_Q		<=    Group1_Delta_Phase_Q    		;
					Group1_Delta_Phase_vld		<=	  1'b0							;	
				end
				
				if((I_PXIE_DATA[127:112] == 16'h45ab)&&(I_PXIE_DATA[111:96] == 16'h0002)&&(I_PXIE_DATA_VLD))
				begin
					Group2_Delta_Phase_I		<=    I_PXIE_DATA[23:0]    			;
					Group2_Delta_Phase_Q		<=    I_PXIE_DATA[55:32]    		;
					Group2_Delta_Phase_vld		<=	  1'b1							;						
				end
				else
				begin
					Group2_Delta_Phase_I		<=    Group2_Delta_Phase_I    		;
					Group2_Delta_Phase_Q		<=    Group2_Delta_Phase_Q    		;
					Group2_Delta_Phase_vld		<=	  1'b0							;
				end

				//IQ Correction Epsilon_Amp的参数传递
				if((I_PXIE_DATA[127:112] == 16'h12ab)&&(I_PXIE_DATA[111:96] == 16'h0001)&&(I_PXIE_DATA_VLD))
				begin
					Group1_Epsilon_Amp_I		<=    I_PXIE_DATA[23:0]    			;
					Group1_Epsilon_Amp_Q		<=    I_PXIE_DATA[55:32]    		;						
				end
				else
				begin
					Group1_Epsilon_Amp_I		<=    Group1_Epsilon_Amp_I    		;
					Group1_Epsilon_Amp_Q		<=    Group1_Epsilon_Amp_Q    		;
				end
				
				if((I_PXIE_DATA[127:112] == 16'h12ab)&&(I_PXIE_DATA[111:96] == 16'h0002)&&(I_PXIE_DATA_VLD))
				begin
					Group2_Epsilon_Amp_I		<=    I_PXIE_DATA[23:0]    			;
					Group2_Epsilon_Amp_Q		<=    I_PXIE_DATA[55:32]    		;						
				end
				else
				begin
					Group2_Epsilon_Amp_I		<=    Group2_Epsilon_Amp_I    		;
					Group2_Epsilon_Amp_Q		<=    Group2_Epsilon_Amp_Q    		;
				end


			end
			
			ST_WRITE1:
			begin
				R_DAC1_ena		<=	I_PXIE_DATA_VLD	;
				R_DAC1_data		<=	I_PXIE_DATA		;

				if(I_PXIE_DATA_VLD)
				begin
					R_Cnt_Data			<=	R_Cnt_Data	+ 1'b1		;
					R_DAC1_RAM_addrA	<=	R_DAC1_RAM_addrA + 1'b1	;
				end
				else
				begin
					R_Cnt_Data			<=	R_Cnt_Data				;
					R_DAC1_RAM_addrA	<=	R_DAC1_RAM_addrA		;
				end	
			end	
			
			ST_WRITE2:
			begin
				R_DAC2_ena		<=	I_PXIE_DATA_VLD	;
				R_DAC2_data		<=	I_PXIE_DATA		;
				if(I_PXIE_DATA_VLD)
				begin
					R_Cnt_Data			<=	R_Cnt_Data	+ 1'b1		;
					R_DAC2_RAM_addrA	<=	R_DAC2_RAM_addrA + 1'b1	;
				end
				else
				begin
					R_Cnt_Data			<=	R_Cnt_Data				;
					R_DAC2_RAM_addrA	<=	R_DAC2_RAM_addrA		;
				end	
			end	
			
			
			ST_WRITE3:
			begin
				R_DAC3_ena		<=	I_PXIE_DATA_VLD	;
				R_DAC3_data		<=	I_PXIE_DATA		;
				if(I_PXIE_DATA_VLD)
				begin
					R_Cnt_Data			<=	R_Cnt_Data	+ 1'b1		;
					R_DAC3_RAM_addrA	<=	R_DAC3_RAM_addrA + 1'b1	;
				end
				else
				begin
					R_Cnt_Data			<=	R_Cnt_Data				;
					R_DAC3_RAM_addrA	<=	R_DAC3_RAM_addrA		;
				end	
			end	
			
			
			ST_WRITE4:
			begin
				R_DAC4_ena		<=	I_PXIE_DATA_VLD	;
				R_DAC4_data 	<=	I_PXIE_DATA		;
				if(I_PXIE_DATA_VLD)
				begin
					R_Cnt_Data			<=	R_Cnt_Data	+ 1'b1		;
					R_DAC4_RAM_addrA	<=	R_DAC4_RAM_addrA + 1'b1	;
				end
				else
				begin
					R_Cnt_Data			<=	R_Cnt_Data				;
					R_DAC4_RAM_addrA	<=	R_DAC4_RAM_addrA		;
				end		
			end	
			
			ST_RST:
			begin
				R_Rst			<=  1'b1	;
				R_Rst_vld		<=	1'b1	;
				R_Cnt_Data		<=	R_Cnt_Data	+ 1'b1		;
			end	
			
			
			ST_DONE:
			begin
				R_DAC1_data		<=	128'd0	;
				R_DAC2_data		<=	128'd0	;
				R_DAC3_data		<=	128'd0	;
				R_DAC4_data		<=	128'd0	;

				R_DAC1_ena		<=	1'b0	;
				R_DAC2_ena		<=	1'b0	;
				R_DAC3_ena		<=	1'b0	;
				R_DAC4_ena		<=	1'b0	;

				R_Cnt_Data		<=	24'd0	;

				R_Rst			<=  1'b0	;
                R_Rst_vld		<=	1'b0	;

				//1X滤波参数
				alpha_in_1X                 <=    alpha_in_1X    				; 
				complement_alpha_06_1X      <=    complement_alpha_06_1X    	; 
				complement_alpha_05_1X      <=    complement_alpha_05_1X   		; 
				complement_alpha_04_1X      <=    complement_alpha_04_1X    	;

				complement_alpha_03_1X      <=    complement_alpha_03_1X   		; 
				complement_alpha_02_1X      <=    complement_alpha_02_1X    	; 
				complement_alpha_01_1X      <=    complement_alpha_01_1X   		; 
				complement_alpha_00_1X      <=    complement_alpha_00_1X    	; 

				alpha_complement_alpha_05_1X<=    alpha_complement_alpha_05_1X  ; 
				alpha_complement_alpha_04_1X<=    alpha_complement_alpha_04_1X  ; 
				alpha_complement_alpha_03_1X<=    alpha_complement_alpha_03_1X  ; 
				alpha_complement_alpha_02_1X<=    alpha_complement_alpha_02_1X  ;

				alpha_complement_alpha_01_1X<=    alpha_complement_alpha_01_1X  ; 
				alpha_complement_alpha_00_1X<=    alpha_complement_alpha_00_1X  ;
				k_in_1X                     <=    k_in_1X    					; 
				complement_k_in_1X          <=    complement_k_in_1X    		;

				//2X滤波参数
				alpha_in_2X                 <=    alpha_in_2X    				; 
				complement_alpha_06_2X      <=    complement_alpha_06_2X    	; 
				complement_alpha_05_2X      <=    complement_alpha_05_2X   		; 
				complement_alpha_04_2X      <=    complement_alpha_04_2X    	;

				complement_alpha_03_2X      <=    complement_alpha_03_2X   		; 
				complement_alpha_02_2X      <=    complement_alpha_02_2X    	; 
				complement_alpha_01_2X      <=    complement_alpha_01_2X   		; 
				complement_alpha_00_2X      <=    complement_alpha_00_2X    	; 

				alpha_complement_alpha_05_2X<=    alpha_complement_alpha_05_2X  ; 
				alpha_complement_alpha_04_2X<=    alpha_complement_alpha_04_2X  ; 
				alpha_complement_alpha_03_2X<=    alpha_complement_alpha_03_2X  ; 
				alpha_complement_alpha_02_2X<=    alpha_complement_alpha_02_2X  ;

				alpha_complement_alpha_01_2X<=    alpha_complement_alpha_01_2X  ; 
				alpha_complement_alpha_00_2X<=    alpha_complement_alpha_00_2X  ;
				k_in_2X                     <=    k_in_2X    					; 
				complement_k_in_2X          <=    complement_k_in_2X    		;

				//3X滤波参数
				alpha_in_3X                 <=    alpha_in_3X    				; 
				complement_alpha_06_3X      <=    complement_alpha_06_3X    	; 
				complement_alpha_05_3X      <=    complement_alpha_05_3X   		; 
				complement_alpha_04_3X      <=    complement_alpha_04_3X    	;

				complement_alpha_03_3X      <=    complement_alpha_03_3X   		; 
				complement_alpha_02_3X      <=    complement_alpha_02_3X    	; 
				complement_alpha_01_3X      <=    complement_alpha_01_3X   		; 
				complement_alpha_00_3X      <=    complement_alpha_00_3X    	; 

				alpha_complement_alpha_05_3X<=    alpha_complement_alpha_05_3X  ; 
				alpha_complement_alpha_04_3X<=    alpha_complement_alpha_04_3X  ; 
				alpha_complement_alpha_03_3X<=    alpha_complement_alpha_03_3X  ; 
				alpha_complement_alpha_02_3X<=    alpha_complement_alpha_02_3X  ;

				alpha_complement_alpha_01_3X<=    alpha_complement_alpha_01_3X  ; 
				alpha_complement_alpha_00_3X<=    alpha_complement_alpha_00_3X  ;
				k_in_3X                     <=    k_in_3X    					; 
				complement_k_in_3X          <=    complement_k_in_3X    		;  

				//4X滤波参数
				alpha_in_4X                 <=    alpha_in_4X    				; 
				complement_alpha_06_4X      <=    complement_alpha_06_4X    	; 
				complement_alpha_05_4X      <=    complement_alpha_05_4X   		; 
				complement_alpha_04_4X      <=    complement_alpha_04_4X    	;

				complement_alpha_03_4X      <=    complement_alpha_03_4X   		; 
				complement_alpha_02_4X      <=    complement_alpha_02_4X    	; 
				complement_alpha_01_4X      <=    complement_alpha_01_4X   		; 
				complement_alpha_00_4X      <=    complement_alpha_00_4X    	; 

				alpha_complement_alpha_05_4X<=    alpha_complement_alpha_05_4X  ; 
				alpha_complement_alpha_04_4X<=    alpha_complement_alpha_04_4X  ; 
				alpha_complement_alpha_03_4X<=    alpha_complement_alpha_03_4X  ; 
				alpha_complement_alpha_02_4X<=    alpha_complement_alpha_02_4X  ;

				alpha_complement_alpha_01_4X<=    alpha_complement_alpha_01_4X  ; 
				alpha_complement_alpha_00_4X<=    alpha_complement_alpha_00_4X  ;
				k_in_4X                     <=    k_in_4X    					; 
				complement_k_in_4X          <=    complement_k_in_4X    		; 

				//5X滤波参数
				alpha_in_5X                 <=    alpha_in_5X    				; 
				complement_alpha_06_5X      <=    complement_alpha_06_5X    	; 
				complement_alpha_05_5X      <=    complement_alpha_05_5X   		; 
				complement_alpha_04_5X      <=    complement_alpha_04_5X    	;

				complement_alpha_03_5X      <=    complement_alpha_03_5X   		; 
				complement_alpha_02_5X      <=    complement_alpha_02_5X    	; 
				complement_alpha_01_5X      <=    complement_alpha_01_5X   		; 
				complement_alpha_00_5X      <=    complement_alpha_00_5X    	; 

				alpha_complement_alpha_05_5X<=    alpha_complement_alpha_05_5X  ; 
				alpha_complement_alpha_04_5X<=    alpha_complement_alpha_04_5X  ; 
				alpha_complement_alpha_03_5X<=    alpha_complement_alpha_03_5X  ; 
				alpha_complement_alpha_02_5X<=    alpha_complement_alpha_02_5X  ;

				alpha_complement_alpha_01_5X<=    alpha_complement_alpha_01_5X  ; 
				alpha_complement_alpha_00_5X<=    alpha_complement_alpha_00_5X  ;
				k_in_5X                     <=    k_in_5X    					; 
				complement_k_in_5X          <=    complement_k_in_5X    		;

				Group1_Delta_Phase_I		<=    Group1_Delta_Phase_I    		;
				Group1_Delta_Phase_Q		<=    Group1_Delta_Phase_Q    		;
				Group1_Delta_Phase_vld		<=	  Group1_Delta_Phase_vld		;

				Group2_Delta_Phase_I		<=    Group2_Delta_Phase_I   		;
				Group2_Delta_Phase_Q		<=    Group2_Delta_Phase_Q    		;
				Group2_Delta_Phase_vld		<=	  Group2_Delta_Phase_vld		;

				Group1_Epsilon_Amp_I		<=    Group1_Epsilon_Amp_I    		;
				Group1_Epsilon_Amp_Q		<=    Group1_Epsilon_Amp_Q    		;
				Group2_Epsilon_Amp_I		<=    Group2_Epsilon_Amp_I    		;
				Group2_Epsilon_Amp_Q		<=    Group2_Epsilon_Amp_Q    		;

			end	
			
			default:
			begin
				R_DAC1_data		<=	128'd0	;
				R_DAC2_data		<=	128'd0	;
				R_DAC3_data		<=	128'd0	;
				R_DAC4_data		<=	128'd0	;

				R_DAC1_ena		<=	1'b0	;
				R_DAC2_ena		<=	1'b0	;
				R_DAC3_ena		<=	1'b0	;
				R_DAC4_ena		<=	1'b0	;

				R_Cnt_Data		<=	24'd0	;

				R_Rst			<=  1'b0	;
                R_Rst_vld		<=	1'b0	;

				R_offset1		<=	R_offset1	;
				R_offset2		<=	R_offset2	;
				R_offset3		<=	R_offset3	;
				R_offset4		<=	R_offset4	;

				R_length  		<=  24'd250	;

				R_addr  		<=  24'd0	;

				R_DAC1_RAM_addrA	<=	24'd0	;
				R_DAC2_RAM_addrA	<=	24'd0	;
				R_DAC3_RAM_addrA	<=	24'd0	;
				R_DAC4_RAM_addrA	<=	24'd0	;

				AWG_CH1_WAVENUM		<=	AWG_CH1_WAVENUM	;
				AWG_CH2_WAVENUM		<=	AWG_CH2_WAVENUM	;
				AWG_CH3_WAVENUM		<=	AWG_CH3_WAVENUM	;
				AWG_CH4_WAVENUM		<=	AWG_CH4_WAVENUM	;

				AWG_CH1_INITIAL_PHASE	<=	AWG_CH1_INITIAL_PHASE	;
				AWG_CH2_INITIAL_PHASE	<=	AWG_CH2_INITIAL_PHASE	;
				AWG_CH3_INITIAL_PHASE	<=	AWG_CH3_INITIAL_PHASE	;
				AWG_CH4_INITIAL_PHASE	<=	AWG_CH4_INITIAL_PHASE	;

				AWG_CH1_PINC		<=	AWG_CH1_PINC	;
				AWG_CH2_PINC		<=	AWG_CH2_PINC	;
				AWG_CH3_PINC		<=	AWG_CH3_PINC	;
				AWG_CH4_PINC		<=	AWG_CH4_PINC	;

				AWG_CH1_PINC_vld	<=	1'b0	;
				AWG_CH2_PINC_vld	<=	1'b0	;
				AWG_CH3_PINC_vld	<=	1'b0	;
				AWG_CH4_PINC_vld	<=	1'b0	;
				
				Config_Group1_ram      	<=	8'b00010010	;
				Config_Group1_port      <=	8'b00010010	;
				Config_Group1_mixer_on  <=	1'b1		;
				Config_Group2_ram      	<=	8'b00010010	;
				Config_Group2_port      <=	8'b00110100	;
				Config_Group2_mixer_on  <=	1'b1		;

				AWG_CH1_INITIAL_PHASE_vld	<=	1'b0	;
				AWG_CH2_INITIAL_PHASE_vld	<=	1'b0	;
				AWG_CH3_INITIAL_PHASE_vld	<=	1'b0	;
				AWG_CH4_INITIAL_PHASE_vld	<=	1'b0	;
				
				CW_MODE			<=	CW_MODE	;

				AWG_WORK_MODE	<=	AWG_WORK_MODE	;

				PXIE_Value_Delay_Dci1	<=	PXIE_Value_Delay_Dci1	;
				PXIE_Value_Delay_Dci2	<=	PXIE_Value_Delay_Dci2	;
				PXIE_Value_Delay_Dci3	<=	PXIE_Value_Delay_Dci3	;
				PXIE_Value_Delay_Dci4	<=	PXIE_Value_Delay_Dci4	;
				PXIE_LOAD			<=	PXIE_LOAD	;

				IIR_on			<=	IIR_on			;

				IIR_reset		<=	IIR_reset		;

				O_trig			<= 	1'b0			;
				O_trig_valid	<=	O_trig_valid	;

				wea_to_awg_delay_ram1	<= 	1'b0	;
				wea_to_awg_delay_ram2	<= 	1'b0	;
				wea_to_awg_delay_ram3	<= 	1'b0	;
				wea_to_awg_delay_ram4	<= 	1'b0	;

				wea_to_awg_len_ram1	<= 	1'b0	;
				wea_to_awg_len_ram2	<= 	1'b0	;
				wea_to_awg_len_ram3	<= 	1'b0	;
				wea_to_awg_len_ram4	<= 	1'b0	;

				wea_to_awg_addr_ram1	<= 	1'b0	;
				wea_to_awg_addr_ram2	<= 	1'b0	;
				wea_to_awg_addr_ram3	<= 	1'b0	;
				wea_to_awg_addr_ram4	<= 	1'b0	;

				//1X滤波参数
				alpha_in_1X                 <=    alpha_in_1X    				; 
				complement_alpha_06_1X      <=    complement_alpha_06_1X    	; 
				complement_alpha_05_1X      <=    complement_alpha_05_1X   		; 
				complement_alpha_04_1X      <=    complement_alpha_04_1X    	;

				complement_alpha_03_1X      <=    complement_alpha_03_1X   		; 
				complement_alpha_02_1X      <=    complement_alpha_02_1X    	; 
				complement_alpha_01_1X      <=    complement_alpha_01_1X   		; 
				complement_alpha_00_1X      <=    complement_alpha_00_1X    	; 

				alpha_complement_alpha_05_1X<=    alpha_complement_alpha_05_1X  ; 
				alpha_complement_alpha_04_1X<=    alpha_complement_alpha_04_1X  ; 
				alpha_complement_alpha_03_1X<=    alpha_complement_alpha_03_1X  ; 
				alpha_complement_alpha_02_1X<=    alpha_complement_alpha_02_1X  ;

				alpha_complement_alpha_01_1X<=    alpha_complement_alpha_01_1X  ; 
				alpha_complement_alpha_00_1X<=    alpha_complement_alpha_00_1X  ;
				k_in_1X                     <=    k_in_1X    					; 
				complement_k_in_1X          <=    complement_k_in_1X    		;

				//2X滤波参数
				alpha_in_2X                 <=    alpha_in_2X    				; 
				complement_alpha_06_2X      <=    complement_alpha_06_2X    	; 
				complement_alpha_05_2X      <=    complement_alpha_05_2X   		; 
				complement_alpha_04_2X      <=    complement_alpha_04_2X    	;

				complement_alpha_03_2X      <=    complement_alpha_03_2X   		; 
				complement_alpha_02_2X      <=    complement_alpha_02_2X    	; 
				complement_alpha_01_2X      <=    complement_alpha_01_2X   		; 
				complement_alpha_00_2X      <=    complement_alpha_00_2X    	; 

				alpha_complement_alpha_05_2X<=    alpha_complement_alpha_05_2X  ; 
				alpha_complement_alpha_04_2X<=    alpha_complement_alpha_04_2X  ; 
				alpha_complement_alpha_03_2X<=    alpha_complement_alpha_03_2X  ; 
				alpha_complement_alpha_02_2X<=    alpha_complement_alpha_02_2X  ;

				alpha_complement_alpha_01_2X<=    alpha_complement_alpha_01_2X  ; 
				alpha_complement_alpha_00_2X<=    alpha_complement_alpha_00_2X  ;
				k_in_2X                     <=    k_in_2X    					; 
				complement_k_in_2X          <=    complement_k_in_2X    		;

				//3X滤波参数
				alpha_in_3X                 <=    alpha_in_3X    				; 
				complement_alpha_06_3X      <=    complement_alpha_06_3X    	; 
				complement_alpha_05_3X      <=    complement_alpha_05_3X   		; 
				complement_alpha_04_3X      <=    complement_alpha_04_3X    	;

				complement_alpha_03_3X      <=    complement_alpha_03_3X   		; 
				complement_alpha_02_3X      <=    complement_alpha_02_3X    	; 
				complement_alpha_01_3X      <=    complement_alpha_01_3X   		; 
				complement_alpha_00_3X      <=    complement_alpha_00_3X    	; 

				alpha_complement_alpha_05_3X<=    alpha_complement_alpha_05_3X  ; 
				alpha_complement_alpha_04_3X<=    alpha_complement_alpha_04_3X  ; 
				alpha_complement_alpha_03_3X<=    alpha_complement_alpha_03_3X  ; 
				alpha_complement_alpha_02_3X<=    alpha_complement_alpha_02_3X  ;

				alpha_complement_alpha_01_3X<=    alpha_complement_alpha_01_3X  ; 
				alpha_complement_alpha_00_3X<=    alpha_complement_alpha_00_3X  ;
				k_in_3X                     <=    k_in_3X    					; 
				complement_k_in_3X          <=    complement_k_in_3X    		;  

				//4X滤波参数
				alpha_in_4X                 <=    alpha_in_4X    				; 
				complement_alpha_06_4X      <=    complement_alpha_06_4X    	; 
				complement_alpha_05_4X      <=    complement_alpha_05_4X   		; 
				complement_alpha_04_4X      <=    complement_alpha_04_4X    	;

				complement_alpha_03_4X      <=    complement_alpha_03_4X   		; 
				complement_alpha_02_4X      <=    complement_alpha_02_4X    	; 
				complement_alpha_01_4X      <=    complement_alpha_01_4X   		; 
				complement_alpha_00_4X      <=    complement_alpha_00_4X    	; 

				alpha_complement_alpha_05_4X<=    alpha_complement_alpha_05_4X  ; 
				alpha_complement_alpha_04_4X<=    alpha_complement_alpha_04_4X  ; 
				alpha_complement_alpha_03_4X<=    alpha_complement_alpha_03_4X  ; 
				alpha_complement_alpha_02_4X<=    alpha_complement_alpha_02_4X  ;

				alpha_complement_alpha_01_4X<=    alpha_complement_alpha_01_4X  ; 
				alpha_complement_alpha_00_4X<=    alpha_complement_alpha_00_4X  ;
				k_in_4X                     <=    k_in_4X    					; 
				complement_k_in_4X          <=    complement_k_in_4X    		; 

				//5X滤波参数
				alpha_in_5X                 <=    alpha_in_5X    				; 
				complement_alpha_06_5X      <=    complement_alpha_06_5X    	; 
				complement_alpha_05_5X      <=    complement_alpha_05_5X   		; 
				complement_alpha_04_5X      <=    complement_alpha_04_5X    	;

				complement_alpha_03_5X      <=    complement_alpha_03_5X   		; 
				complement_alpha_02_5X      <=    complement_alpha_02_5X    	; 
				complement_alpha_01_5X      <=    complement_alpha_01_5X   		; 
				complement_alpha_00_5X      <=    complement_alpha_00_5X    	; 

				alpha_complement_alpha_05_5X<=    alpha_complement_alpha_05_5X  ; 
				alpha_complement_alpha_04_5X<=    alpha_complement_alpha_04_5X  ; 
				alpha_complement_alpha_03_5X<=    alpha_complement_alpha_03_5X  ; 
				alpha_complement_alpha_02_5X<=    alpha_complement_alpha_02_5X  ;

				alpha_complement_alpha_01_5X<=    alpha_complement_alpha_01_5X  ; 
				alpha_complement_alpha_00_5X<=    alpha_complement_alpha_00_5X  ;
				k_in_5X                     <=    k_in_5X    					; 
				complement_k_in_5X          <=    complement_k_in_5X    		;


				Group1_Delta_Phase_I		<=    Group1_Delta_Phase_I    		;
				Group1_Delta_Phase_Q		<=    Group1_Delta_Phase_Q    		;
				Group1_Delta_Phase_vld		<=	  Group1_Delta_Phase_vld		;

				Group2_Delta_Phase_I		<=    Group2_Delta_Phase_I   		;
				Group2_Delta_Phase_Q		<=    Group2_Delta_Phase_Q    		;
				Group2_Delta_Phase_vld		<=	  Group2_Delta_Phase_vld		;

				Group1_Epsilon_Amp_I		<=    Group1_Epsilon_Amp_I    		;
				Group1_Epsilon_Amp_Q		<=    Group1_Epsilon_Amp_Q    		;
				Group2_Epsilon_Amp_I		<=    Group2_Epsilon_Amp_I    		;
				Group2_Epsilon_Amp_Q		<=    Group2_Epsilon_Amp_Q    		;
			end
		endcase
	end
end

reg[23:0]	R1_DAC1_RAM_addrB		;
reg[23:0]	R1_DAC2_RAM_addrB		;
reg[23:0]	R1_DAC3_RAM_addrB		;
reg[23:0]	R1_DAC4_RAM_addrB		;

always @(posedge I_CLK_250mhz or negedge I_Rst_n) begin
	if(~I_Rst_n) begin
		R1_DAC1_RAM_addrB	<= 24'd0 ;
		R1_DAC2_RAM_addrB	<= 24'd0 ;
		R1_DAC3_RAM_addrB	<= 24'd0 ;
		R1_DAC4_RAM_addrB	<= 24'd0 ;
	end
	else begin
		R1_DAC1_RAM_addrB	<=	R_DAC1_RAM_addrB		;
		R1_DAC2_RAM_addrB	<=	R_DAC2_RAM_addrB		;
		R1_DAC3_RAM_addrB	<=	R_DAC3_RAM_addrB		;
		R1_DAC4_RAM_addrB	<=	R_DAC4_RAM_addrB		;
	end
end

reg	[127:0]		R_DAC1_RAM_data			;
reg	[127:0]		R_DAC2_RAM_data			;
reg	[127:0]		R_DAC3_RAM_data			;
reg	[127:0]		R_DAC4_RAM_data			;

reg			R1_DAC1_RAM_ena			;
reg			R1_DAC2_RAM_ena			;
reg			R1_DAC3_RAM_ena			;
reg			R1_DAC4_RAM_ena			;

reg			R2_DAC1_RAM_ena			;
reg			R2_DAC2_RAM_ena			;
reg			R2_DAC3_RAM_ena			;
reg			R2_DAC4_RAM_ena			;

reg			R3_DAC1_RAM_ena			;
reg			R3_DAC2_RAM_ena			;
reg			R3_DAC3_RAM_ena			;
reg			R3_DAC4_RAM_ena			;

reg			R4_DAC1_RAM_ena			;
reg			R4_DAC2_RAM_ena			;
reg			R4_DAC3_RAM_ena			;
reg			R4_DAC4_RAM_ena			;

reg			R5_DAC1_RAM_ena			;
reg			R5_DAC2_RAM_ena			;
reg			R5_DAC3_RAM_ena			;
reg			R5_DAC4_RAM_ena			;

reg			R6_DAC1_RAM_ena			;
reg			R6_DAC2_RAM_ena			;
reg			R6_DAC3_RAM_ena			;
reg			R6_DAC4_RAM_ena			;


always @(posedge I_CLK_250mhz or negedge I_Rst_n) begin
	if(~I_Rst_n) begin
		R1_DAC1_RAM_ena	<=	1'b0	;
		R1_DAC2_RAM_ena	<=	1'b0	;
		R1_DAC3_RAM_ena	<=	1'b0	;
		R1_DAC4_RAM_ena	<=	1'b0	;

		R2_DAC1_RAM_ena	<=	1'b0	;
		R2_DAC2_RAM_ena	<=	1'b0	;
		R2_DAC3_RAM_ena	<=	1'b0	;
		R2_DAC4_RAM_ena	<=	1'b0	;

		R3_DAC1_RAM_ena	<=	1'b0	;
		R3_DAC2_RAM_ena	<=	1'b0	;
		R3_DAC3_RAM_ena	<=	1'b0	;
		R3_DAC4_RAM_ena	<=	1'b0	;

		R4_DAC1_RAM_ena	<=	1'b0	;
		R4_DAC2_RAM_ena	<=	1'b0	;
		R4_DAC3_RAM_ena	<=	1'b0	;
		R4_DAC4_RAM_ena	<=	1'b0	;

		R5_DAC1_RAM_ena	<=	1'b0	;
		R5_DAC2_RAM_ena	<=	1'b0	;
		R5_DAC3_RAM_ena	<=	1'b0	;
		R5_DAC4_RAM_ena	<=	1'b0	;

		R6_DAC1_RAM_ena	<=	1'b0	;
		R6_DAC2_RAM_ena	<=	1'b0	;
		R6_DAC3_RAM_ena	<=	1'b0	;
		R6_DAC4_RAM_ena	<=	1'b0	;

		R_DAC1_RAM_data	<=	128'd0	;
		R_DAC2_RAM_data	<=	128'd0	;
		R_DAC3_RAM_data	<=	128'd0	;
		R_DAC4_RAM_data	<=	128'd0	;

	end
	else begin
		R1_DAC1_RAM_ena	<=	R_DAC1_RAM_ena	;
		R1_DAC2_RAM_ena	<=	R_DAC2_RAM_ena	;
		R1_DAC3_RAM_ena	<=	R_DAC3_RAM_ena	;
		R1_DAC4_RAM_ena	<=	R_DAC4_RAM_ena	;

		R2_DAC1_RAM_ena	<=	R1_DAC1_RAM_ena	;
		R2_DAC2_RAM_ena	<=	R1_DAC2_RAM_ena	;
		R2_DAC3_RAM_ena	<=	R1_DAC3_RAM_ena	;
		R2_DAC4_RAM_ena	<=	R1_DAC4_RAM_ena	;

		R3_DAC1_RAM_ena	<=	R2_DAC1_RAM_ena	;
		R3_DAC2_RAM_ena	<=	R2_DAC2_RAM_ena	;
		R3_DAC3_RAM_ena	<=	R2_DAC3_RAM_ena	;
		R3_DAC4_RAM_ena	<=	R2_DAC4_RAM_ena	;

		R4_DAC1_RAM_ena	<=	R3_DAC1_RAM_ena	;
		R4_DAC2_RAM_ena	<=	R3_DAC2_RAM_ena	;
		R4_DAC3_RAM_ena	<=	R3_DAC3_RAM_ena	;
		R4_DAC4_RAM_ena	<=	R3_DAC4_RAM_ena	;

		R5_DAC1_RAM_ena	<=	R4_DAC1_RAM_ena	;
		R5_DAC2_RAM_ena	<=	R4_DAC2_RAM_ena	;
		R5_DAC3_RAM_ena	<=	R4_DAC3_RAM_ena	;
		R5_DAC4_RAM_ena	<=	R4_DAC4_RAM_ena	;

		R6_DAC1_RAM_ena	<=	R5_DAC1_RAM_ena	;
		R6_DAC2_RAM_ena	<=	R5_DAC2_RAM_ena	;
		R6_DAC3_RAM_ena	<=	R5_DAC3_RAM_ena	;
		R6_DAC4_RAM_ena	<=	R5_DAC4_RAM_ena	;

		if(R4_DAC1_RAM_ena == 1'b1) begin
			R_DAC1_RAM_data	<=	W_DAC1_RAM_data	;
		end
		else begin
			R_DAC1_RAM_data	<=	R_DAC1_RAM_data	;
		end

		if(R4_DAC2_RAM_ena == 1'b1) begin
			R_DAC2_RAM_data	<=	W_DAC2_RAM_data	;
		end
		else begin
			R_DAC2_RAM_data	<=	R_DAC2_RAM_data	;
		end

		if(R4_DAC3_RAM_ena == 1'b1) begin
			R_DAC3_RAM_data	<=	W_DAC3_RAM_data	;
		end
		else begin
			R_DAC3_RAM_data	<=	R_DAC3_RAM_data	;
		end

		if(R4_DAC4_RAM_ena == 1'b1) begin
			R_DAC4_RAM_data	<=	W_DAC4_RAM_data	;
		end
		else begin
			R_DAC4_RAM_data	<=	R_DAC4_RAM_data	;
		end		
		
	end
end

//*****************************************DAC1 Read Data*************************************************
reg			R_DAC1_RAM_ena			;

reg	[23:0]	R_DAC1_VisitWave_addr	;
reg	[23:0]	R_DAC1_VisitWave_len	;
	
pxie_dac_ram ram_dac1 (
  .clka(I_PXIE_CLK),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(R_DAC1_ena),      // input wire [0 : 0] wea
  .addra(R1_DAC1_RAM_addrA),  // input wire [16 : 0] addra
  .dina(R_DAC1_data),    // input wire [127 : 0] dina
  .clkb(I_CLK_250mhz),    // input wire clkb
  .enb(1'b1),      // input wire enb
  .addrb(R1_DAC1_RAM_addrB),  // input wire [16 : 0] addrb
  .doutb(W_DAC1_RAM_data)  // output wire [127 : 0] doutb
);

always @ (posedge I_CLK_250mhz or negedge I_Rst_n)
begin
	if(~I_Rst_n)
	begin
		R_RAM1_State		<=	ST_RAM1_IDLE	;
	end
	else
	begin
		R_RAM1_State		<=	R_RAM1_NextState;
	end
end	


always @(*)
begin
	case(R_RAM1_State)
		ST_RAM1_IDLE:
		begin
			R_RAM1_NextState	=	ST_RAM1_WAIT	;
		end	
		
		ST_RAM1_WAIT:
		begin
			if(I_dac1_tx_ena)
			begin	
				R_RAM1_NextState	=	ST_RAM1_READ	;
			end
			else
			begin
				R_RAM1_NextState 	=	ST_RAM1_WAIT	;
			end	
		end
		
		ST_RAM1_READ:
		begin
			if((I_dac1_tx_ena)&&(CW_MODE == 1'b0))
			begin
				R_RAM1_NextState	=	ST_RAM1_READ	;
			end
			else
			begin
				if((R_DAC1_RAM_addrB == R_DAC1_VisitWave_addr + R_DAC1_VisitWave_len - 11'd1)&&(CW_MODE == 1'b0))
				begin
					R_RAM1_NextState	=	ST_RAM1_READ_DONE;
				end
				else
				begin	
					R_RAM1_NextState	=	ST_RAM1_READ	;
				end			
			end
		end		
	
		ST_RAM1_READ_DONE:
		begin
			if(I_dac1_tx_ena)
			begin	
				R_RAM1_NextState	=	ST_RAM1_READ	;
			end
			else
			begin
				R_RAM1_NextState 	=	ST_RAM1_WAIT	;
			end	
		end	
		
		default:	R_RAM1_NextState	=	ST_RAM1_IDLE	;
	endcase
end	


always	@ (posedge I_CLK_250mhz or negedge I_Rst_n)	
begin
	if(~I_Rst_n)
	begin
		R_DAC1_RAM_addrB	<=	24'd0	;
		R_DAC1_RAM_ena		<=	1'b0	;

	end
	else
	begin
		case(R_RAM1_State)
			ST_RAM1_IDLE:
			begin
				R_DAC1_RAM_addrB		<=	24'd0	;
				R_DAC1_RAM_ena		<=	1'b0	;
			end		
										
			ST_RAM1_WAIT:
			begin
				R_DAC1_RAM_ena		<=	1'b0	;	
				if(I_dac1_tx_ena)	
				begin	
					R_DAC1_VisitWave_addr 	<=	read_data_to_awg_addr_ram1	; 
					R_DAC1_VisitWave_len	<=	read_data_to_awg_len_ram1	;					
					R_DAC1_RAM_addrB		<=	read_data_to_awg_addr_ram1	;		
				end
				else
				begin
					R_DAC1_VisitWave_addr 	<=	read_data_to_awg_addr_ram1	; 
					R_DAC1_VisitWave_len	<=	read_data_to_awg_len_ram1	;					
					R_DAC1_RAM_addrB		<=	R_DAC1_RAM_addrB			;
				end
			end	
			
			
			ST_RAM1_READ:
			begin
				R_DAC1_RAM_ena		<=	1'b1	;
				if((I_dac1_tx_ena)&&(CW_MODE == 1'b0))
				begin
					R_DAC1_VisitWave_addr 	<=	read_data_to_awg_addr_ram1	; 
					R_DAC1_VisitWave_len	<=	read_data_to_awg_len_ram1	;					
					R_DAC1_RAM_addrB		<=	read_data_to_awg_addr_ram1	;
				end
				else
				begin
					if((R_DAC1_RAM_addrB == R_DAC1_VisitWave_addr + R_DAC1_VisitWave_len - 11'd2) && (CW_MODE == 1'b1))
						R_DAC1_RAM_addrB		<=	R_DAC1_VisitWave_addr  		;
					else
						R_DAC1_RAM_addrB		<=	R_DAC1_RAM_addrB + 11'd1 	;
				end
			end	
			
			
			ST_RAM1_READ_DONE:
			begin
				R_DAC1_RAM_ena		<=	1'b0	;	
				if(I_dac1_tx_ena)	
				begin	
					R_DAC1_VisitWave_addr 	<=	read_data_to_awg_addr_ram1	; 
					R_DAC1_VisitWave_len	<=	read_data_to_awg_len_ram1	;					
					R_DAC1_RAM_addrB		<=	read_data_to_awg_addr_ram1	;		
				end
				else
				begin
					R_DAC1_VisitWave_addr 	<=	read_data_to_awg_addr_ram1	; 
					R_DAC1_VisitWave_len	<=	read_data_to_awg_len_ram1	;					
					R_DAC1_RAM_addrB		<=	R_DAC1_RAM_addrB			;
				end
				
			end	
			
			
			default:
			begin
				R_DAC1_RAM_addrB		<=	24'd0	;
				R_DAC1_RAM_ena		<=	1'b0	;

			end
		endcase
	end
end

assign O_DAC1_RAM_data	=	R_DAC1_RAM_data	;
assign O_DAC1_RAM_data_vld	=	R5_DAC1_RAM_ena	;


//*****************************************DAC2 Read Data*************************************************
reg			R_DAC2_RAM_ena			;

reg	[23:0]	R_DAC2_VisitWave_addr	;
reg	[23:0]	R_DAC2_VisitWave_len	;

pxie_dac_ram ram_dac2 (
  .clka(I_PXIE_CLK),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(R_DAC2_ena),      // input wire [0 : 0] wea
  .addra(R1_DAC2_RAM_addrA),  // input wire [16 : 0] addra
  .dina(R_DAC2_data),    // input wire [127 : 0] dina
  .clkb(I_CLK_250mhz),    // input wire clkb
  .enb(1'b1),      // input wire enb
  .addrb(R1_DAC2_RAM_addrB),  // input wire [16 : 0] addrb
  .doutb(W_DAC2_RAM_data)  // output wire [127 : 0] doutb
);

always @ (posedge I_CLK_250mhz or negedge I_Rst_n)
begin
	if(~I_Rst_n)
	begin
		R_RAM2_State		<=	ST_RAM2_IDLE	;
	end
	else
	begin
		R_RAM2_State		<=	R_RAM2_NextState;
	end
end	


always @(*)
begin
	case(R_RAM2_State)
		ST_RAM2_IDLE:
		begin
			R_RAM2_NextState	=	ST_RAM2_WAIT	;
		end	
		
		ST_RAM2_WAIT:
		begin
			if(I_dac2_tx_ena)
			begin	
				R_RAM2_NextState	=	ST_RAM2_READ	;
			end
			else
			begin
				R_RAM2_NextState 	=	ST_RAM2_WAIT	;
			end	
		end
		
		ST_RAM2_READ:
		begin
			if((I_dac2_tx_ena)&&(CW_MODE == 1'b0))
			begin
				R_RAM2_NextState	=	ST_RAM2_READ	;
			end
			else
			begin
				if((R_DAC2_RAM_addrB == R_DAC2_VisitWave_addr + R_DAC2_VisitWave_len - 11'd1)&&(CW_MODE == 1'b0))
				begin
					R_RAM2_NextState	=	ST_RAM2_READ_DONE;
				end
				else
				begin	
					R_RAM2_NextState	=	ST_RAM2_READ	;
				end
			end
		end		
	
		ST_RAM2_READ_DONE:
		begin
			if(I_dac2_tx_ena)
			begin	
				R_RAM2_NextState	=	ST_RAM2_READ	;
			end
			else
			begin
				R_RAM2_NextState 	=	ST_RAM2_WAIT	;
			end	
		end	
		
		default:	R_RAM2_NextState	=	ST_RAM2_IDLE	;
	endcase
end	


always	@ (posedge I_CLK_250mhz or negedge I_Rst_n)	
begin
	if(~I_Rst_n)
	begin
		R_DAC2_RAM_addrB	<=	24'd0	;
		R_DAC2_RAM_ena		<=	1'b0	;

	end
	else
	begin
		case(R_RAM2_State)
			ST_RAM2_IDLE:
			begin
				R_DAC2_RAM_addrB		<=	24'd0	;
				R_DAC2_RAM_ena		<=	1'b0	;
			end		
										
			ST_RAM2_WAIT:
			begin
				R_DAC2_RAM_ena		<=	1'b0	;	
				if(I_dac2_tx_ena)	
				begin	
					R_DAC2_VisitWave_addr 	<=	read_data_to_awg_addr_ram2	; 
					R_DAC2_VisitWave_len	<=	read_data_to_awg_len_ram2	;	
					R_DAC2_RAM_addrB		<=	read_data_to_awg_addr_ram2	;		
				end
				else
				begin
					R_DAC2_VisitWave_addr 	<=	read_data_to_awg_addr_ram2	; 
					R_DAC2_VisitWave_len	<=	read_data_to_awg_len_ram2	;	
					R_DAC2_RAM_addrB		<=	R_DAC2_RAM_addrB			;
				end
			end	
			
			
			ST_RAM2_READ:
			begin
				R_DAC2_RAM_ena		<=	1'b1	;
				if((I_dac2_tx_ena)&&(CW_MODE == 1'b0))
				begin
					R_DAC2_VisitWave_addr 	<=	read_data_to_awg_addr_ram2	; 
					R_DAC2_VisitWave_len	<=	read_data_to_awg_len_ram2	;	
					R_DAC2_RAM_addrB		<=	read_data_to_awg_addr_ram2	;
				end
				else
				begin
					if((R_DAC2_RAM_addrB == R_DAC2_VisitWave_addr + R_DAC2_VisitWave_len - 11'd2) && (CW_MODE == 1'b1))
						R_DAC2_RAM_addrB		<=	R_DAC2_VisitWave_addr	 	;
					else
						R_DAC2_RAM_addrB		<=	R_DAC2_RAM_addrB + 11'd1 	;
				end
			end	
			
			
			ST_RAM2_READ_DONE:
			begin
				R_DAC2_RAM_ena		<=	1'b0	;	
				if(I_dac2_tx_ena)	
				begin	
					R_DAC2_VisitWave_addr 	<=	read_data_to_awg_addr_ram2	; 
					R_DAC2_VisitWave_len	<=	read_data_to_awg_len_ram2	;	
					R_DAC2_RAM_addrB		<=	read_data_to_awg_addr_ram2	;			
				end
				else
				begin
					R_DAC2_VisitWave_addr 	<=	read_data_to_awg_addr_ram2	; 
					R_DAC2_VisitWave_len	<=	read_data_to_awg_len_ram2	;	
					R_DAC2_RAM_addrB		<=	R_DAC2_RAM_addrB			;
				end
				
			end	
			
			
			default:
			begin
				R_DAC2_RAM_addrB		<=	24'd0	;
				R_DAC2_RAM_ena		<=	1'b0	;

			end
		endcase
	end
end

assign O_DAC2_RAM_data	=	R_DAC2_RAM_data	;
assign O_DAC2_RAM_data_vld	=	R5_DAC2_RAM_ena	;


//*****************************************DAC3 Read Data*************************************************
reg			R_DAC3_RAM_ena			;

reg	[23:0]	R_DAC3_VisitWave_addr	;
reg	[23:0]	R_DAC3_VisitWave_len	;

pxie_dac_ram ram_dac3 (
  .clka(I_PXIE_CLK),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(R_DAC3_ena),      // input wire [0 : 0] wea
  .addra(R1_DAC3_RAM_addrA),  // input wire [16 : 0] addra
  .dina(R_DAC3_data),    // input wire [127 : 0] dina
  .clkb(I_CLK_250mhz),    // input wire clkb
  .enb(1'b1),      // input wire enb
  .addrb(R1_DAC3_RAM_addrB),  // input wire [16 : 0] addrb
  .doutb(W_DAC3_RAM_data)  // output wire [127 : 0] doutb
);

always @ (posedge I_CLK_250mhz or negedge I_Rst_n)
begin
	if(~I_Rst_n)
	begin
		R_RAM3_State		<=	ST_RAM3_IDLE	;
	end
	else
	begin
		R_RAM3_State		<=	R_RAM3_NextState;
	end
end	


always @(*)
begin
	case(R_RAM3_State)
		ST_RAM3_IDLE:
		begin
			R_RAM3_NextState	=	ST_RAM3_WAIT	;
		end	
		
		ST_RAM3_WAIT:
		begin
			if(I_dac3_tx_ena)
			begin	
				R_RAM3_NextState	=	ST_RAM3_READ	;
			end
			else
			begin
				R_RAM3_NextState 	=	ST_RAM3_WAIT	;
			end	
		end
		
		ST_RAM3_READ:
		begin
			if((I_dac3_tx_ena)&&(CW_MODE == 1'b0))
			begin
				R_RAM3_NextState	=	ST_RAM3_READ	;
			end
			else
			begin
				if((R_DAC3_RAM_addrB == R_DAC3_VisitWave_addr + R_DAC3_VisitWave_len - 11'd1)&&(CW_MODE == 1'b0))
				begin
					R_RAM3_NextState	=	ST_RAM3_READ_DONE;
				end
				else
				begin	
					R_RAM3_NextState	=	ST_RAM3_READ	;
				end
			end
		end		
	
		ST_RAM3_READ_DONE:
		begin
			if(I_dac3_tx_ena)
			begin	
				R_RAM3_NextState	=	ST_RAM3_READ	;
			end
			else
			begin
				R_RAM3_NextState 	=	ST_RAM3_WAIT	;
			end
		end	
		
		default:	R_RAM3_NextState	=	ST_RAM3_IDLE	;
	endcase
end	


always	@ (posedge I_CLK_250mhz or negedge I_Rst_n)	
begin
	if(~I_Rst_n)
	begin
		R_DAC3_RAM_addrB	<=	24'd0	;
		R_DAC3_RAM_ena		<=	1'b0	;

	end
	else
	begin
		case(R_RAM3_State)
			ST_RAM3_IDLE:
			begin
				R_DAC3_RAM_addrB		<=	24'd0	;
				R_DAC3_RAM_ena		<=	1'b0	;
			end		
										
			ST_RAM3_WAIT:
			begin
				R_DAC3_RAM_ena		<=	1'b0	;	
				if(I_dac3_tx_ena)	
				begin	
					R_DAC3_VisitWave_addr 	<=	read_data_to_awg_addr_ram3	; 
					R_DAC3_VisitWave_len	<=	read_data_to_awg_len_ram3	;
					R_DAC3_RAM_addrB		<=	read_data_to_awg_addr_ram3	;		
				end
				else
				begin
					R_DAC3_VisitWave_addr 	<=	read_data_to_awg_addr_ram3	; 
					R_DAC3_VisitWave_len	<=	read_data_to_awg_len_ram3	;
					R_DAC3_RAM_addrB		<=	R_DAC3_RAM_addrB			;
				end
			end	
			
			
			ST_RAM3_READ:
			begin
				R_DAC3_RAM_ena		<=	1'b1	;
				if((I_dac3_tx_ena)&&(CW_MODE == 1'b0))
				begin
					R_DAC3_VisitWave_addr 	<=	read_data_to_awg_addr_ram3	; 
					R_DAC3_VisitWave_len	<=	read_data_to_awg_len_ram3	;
					R_DAC3_RAM_addrB		<=	read_data_to_awg_addr_ram3	;
				end
				else
				begin
					if((R_DAC3_RAM_addrB == R_DAC3_VisitWave_addr + R_DAC3_VisitWave_len - 11'd2) && (CW_MODE == 1'b1))
						R_DAC3_RAM_addrB		<=	R_DAC3_VisitWave_addr		;
					else
						R_DAC3_RAM_addrB		<=	R_DAC3_RAM_addrB + 11'd1 	;
				end
			end	
			
			
			ST_RAM3_READ_DONE:
			begin
				R_DAC3_RAM_ena		<=	1'b0	;	
				if(I_dac3_tx_ena)	
				begin	
					R_DAC3_VisitWave_addr 	<=	read_data_to_awg_addr_ram3	; 
					R_DAC3_VisitWave_len	<=	read_data_to_awg_len_ram3	;
					R_DAC3_RAM_addrB		<=	read_data_to_awg_addr_ram3	;		
				end
				else
				begin
					R_DAC3_VisitWave_addr 	<=	read_data_to_awg_addr_ram3	; 
					R_DAC3_VisitWave_len	<=	read_data_to_awg_len_ram3	;
					R_DAC3_RAM_addrB		=	R_DAC3_RAM_addrB			;
				end
				
			end	
			
			
			default:
			begin
				R_DAC3_RAM_addrB		<=	24'd0	;
				R_DAC3_RAM_ena		<=	1'b0	;

			end
		endcase
	end
end

assign O_DAC3_RAM_data	=	R_DAC3_RAM_data	;
assign O_DAC3_RAM_data_vld	=	R5_DAC3_RAM_ena	;


//*****************************************DAC4 Read Data*************************************************
reg			R_DAC4_RAM_ena			;

reg	[23:0]	R_DAC4_VisitWave_addr	;
reg	[23:0]	R_DAC4_VisitWave_len	;

pxie_dac_ram ram_dac4 (
  .clka(I_PXIE_CLK),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(R_DAC4_ena),      // input wire [0 : 0] wea
  .addra(R1_DAC4_RAM_addrA),  // input wire [16 : 0] addra
  .dina(R_DAC4_data),    // input wire [127 : 0] dina
  .clkb(I_CLK_250mhz),    // input wire clkb
  .enb(1'b1),      // input wire enb
  .addrb(R1_DAC4_RAM_addrB),  // input wire [16 : 0] addrb
  .doutb(W_DAC4_RAM_data)  // output wire [127 : 0] doutb
);

always @ (posedge I_CLK_250mhz or negedge I_Rst_n)
begin
	if(~I_Rst_n)
	begin
		R_RAM4_State		<=	ST_RAM4_IDLE	;
	end
	else
	begin
		R_RAM4_State		<=	R_RAM4_NextState;
	end
end	


always @(*)
begin
	case(R_RAM4_State)
		ST_RAM4_IDLE:
		begin
			R_RAM4_NextState	=	ST_RAM4_WAIT	;
		end	
		
		ST_RAM4_WAIT:
		begin
			if(I_dac4_tx_ena)
			begin	
				R_RAM4_NextState	=	ST_RAM4_READ	;
			end
			else
			begin
				R_RAM4_NextState 	=	ST_RAM4_WAIT	;
			end	
		end
		
		ST_RAM4_READ:
		begin
			if((I_dac4_tx_ena)&&(CW_MODE == 1'b0))
			begin
				R_RAM4_NextState	=	ST_RAM4_READ	;
			end
			else
			begin
				if((R_DAC4_RAM_addrB == R_DAC4_VisitWave_addr + R_DAC4_VisitWave_len - 11'd1)&&(CW_MODE == 1'b0))
				begin
					R_RAM4_NextState	=	ST_RAM4_READ_DONE;
				end
				else
				begin	
					R_RAM4_NextState	=	ST_RAM4_READ	;
				end
			end
		end		
	
		ST_RAM4_READ_DONE:
		begin
			if(I_dac4_tx_ena)
			begin	
				R_RAM4_NextState	=	ST_RAM4_READ	;
			end
			else
			begin
				R_RAM4_NextState 	=	ST_RAM4_WAIT	;
			end	
		end	
		
		default:	R_RAM4_NextState	=	ST_RAM4_IDLE	;
	endcase
end	


always	@ (posedge I_CLK_250mhz or negedge I_Rst_n)	
begin
	if(~I_Rst_n)
	begin
		R_DAC4_RAM_addrB	<=	24'd0	;
		R_DAC4_RAM_ena		<=	1'b0	;

	end
	else
	begin
		case(R_RAM4_State)
			ST_RAM4_IDLE:
			begin
				R_DAC4_RAM_addrB		<=	24'd0	;
				R_DAC4_RAM_ena		<=	1'b0	;
			end		
										
			ST_RAM4_WAIT:
			begin
				R_DAC4_RAM_ena		<=	1'b0	;	
				if(I_dac4_tx_ena)	
				begin	
					R_DAC4_VisitWave_addr 	<=	read_data_to_awg_addr_ram4	; 
					R_DAC4_VisitWave_len	<=	read_data_to_awg_len_ram4	;
					R_DAC4_RAM_addrB		<=	read_data_to_awg_addr_ram4	;		
				end
				else
				begin
					R_DAC4_VisitWave_addr 	<=	read_data_to_awg_addr_ram4	; 
					R_DAC4_VisitWave_len	<=	read_data_to_awg_len_ram4	;
					R_DAC4_RAM_addrB		<=	R_DAC4_RAM_addrB			;
				end
			end	
			
			
			ST_RAM4_READ:
			begin
				R_DAC4_RAM_ena		<=	1'b1	;
				if((I_dac4_tx_ena)&&(CW_MODE == 1'b0))
				begin
					R_DAC4_VisitWave_addr 	<=	read_data_to_awg_addr_ram4	; 
					R_DAC4_VisitWave_len	<=	read_data_to_awg_len_ram4	;
					R_DAC4_RAM_addrB		<=	read_data_to_awg_addr_ram4	;
				end
				else
				begin
					if((R_DAC4_RAM_addrB == R_DAC4_VisitWave_addr + R_DAC4_VisitWave_len - 11'd2) && (CW_MODE == 1'b1))
						R_DAC4_RAM_addrB		<=	R_DAC4_VisitWave_addr		;
					else
						R_DAC4_RAM_addrB		<=	R_DAC4_RAM_addrB + 11'd1 	;
				end
			end	
			
			
			ST_RAM4_READ_DONE:
			begin
				R_DAC4_RAM_ena		<=	1'b0	;	
				if(I_dac4_tx_ena)	
				begin	
					R_DAC4_VisitWave_addr 	<=	read_data_to_awg_addr_ram4	; 
					R_DAC4_VisitWave_len	<=	read_data_to_awg_len_ram4	;
					R_DAC4_RAM_addrB		<=	read_data_to_awg_addr_ram4	;		
				end
				else
				begin
					R_DAC4_VisitWave_addr 	<=	read_data_to_awg_addr_ram4	; 
					R_DAC4_VisitWave_len	<=	read_data_to_awg_len_ram4	;
					R_DAC4_RAM_addrB		<=	R_DAC4_RAM_addrB			;
				end
				
			end	
			
			
			default:
			begin
				R_DAC4_RAM_addrB		<=	24'd0	;
				R_DAC4_RAM_ena		<=	1'b0	;

			end
		endcase
	end
end

assign O_DAC4_RAM_data	=	R_DAC4_RAM_data	;
assign O_DAC4_RAM_data_vld	=	R5_DAC4_RAM_ena	;


// ila_read_pxie_ram_addr ila_read_pxie_ram_addr (
// 	.clk(I_CLK_250mhz), // input wire clk

// 	.probe0(R1_DAC1_RAM_addrB), // input wire [23:0]  probe0  
// 	.probe1(R1_DAC2_RAM_addrB), // input wire [23:0]  probe1 
// 	.probe2(R1_DAC3_RAM_addrB), // input wire [23:0]  probe2 
// 	.probe3(R1_DAC4_RAM_addrB) // input wire [23:0]  probe3
// 	// .probe4(R_DAC1_RAM_data[15:0]), // input wire [15:0]  probe4 
// 	// .probe5(R_DAC2_RAM_data[15:0]), // input wire [15:0]  probe5 
// 	// .probe6(R_DAC3_RAM_data[15:0]), // input wire [15:0]  probe6 
// 	// .probe7(R_DAC4_RAM_data[15:0]) // input wire [15:0]  probe7
// 	// .probe4(R_DAC1_RAM_data), // input wire [127:0]  probe4 
// 	// .probe5(R_DAC2_RAM_data), // input wire [127:0]  probe5 
// 	// .probe6(R_DAC3_RAM_data), // input wire [127:0]  probe6 
// 	// .probe7(R_DAC4_RAM_data) // input wire [127:0]  probe7
// );

// ila_13 ila_13 (
// 	.clk(I_CLK_250mhz), // input wire clk

// 	// .probe0(W_dac1_tx_id), // input wire [10:0]  probe0  
// 	// .probe1(W_dac2_tx_id), // input wire [10:0]  probe1 
// 	// .probe2(W_dac3_tx_id), // input wire [10:0]  probe2 
// 	// .probe3(W_dac4_tx_id), // input wire [10:0]  probe3 

// 	.probe0(O_DAC1_RAM_data), // input wire [127:0]  probe4 
// 	.probe1(O_DAC2_RAM_data), // input wire [127:0]  probe5 
// 	.probe2(O_DAC3_RAM_data), // input wire [127:0]  probe6 
// 	.probe3(O_DAC4_RAM_data) // input wire [127:0]  probe7 

// );

// ila_14 ila_14 (
// 	.clk(I_CLK_250mhz), // input wire clk

// 	.probe0(R1_DAC1_RAM_addrB), // input wire [23:0]  probe0  
// 	.probe1(R1_DAC2_RAM_addrB), // input wire [23:0]  probe1 
// 	.probe2(R1_DAC3_RAM_addrB), // input wire [23:0]  probe2 
// 	.probe3(R1_DAC4_RAM_addrB) // input wire [23:0]  probe3
// );

// reg flag_12;
// reg flag_13;
// reg flag_14;
// reg flag_23;
// reg flag_24;
// reg flag_34;
// reg flag_total;

// always @(posedge I_CLK_250mhz or negedge I_Rst_n) begin
// 	if(~I_Rst_n) begin
// 		flag_12 <= 1'b0;
// 		flag_13 <= 1'b0;
// 		flag_14 <= 1'b0;
// 		flag_23 <= 1'b0;
// 		flag_24 <= 1'b0;
// 		flag_34 <= 1'b0;
// 		flag_total <= 1'b0;
// 	end
// 	else begin
// 		flag_total <= flag_12 & flag_23 & flag_34;
// 		if(O_DAC1_RAM_data == O_DAC2_RAM_data) begin
// 			flag_12 <= 1'b1;
// 		end
// 		else begin
// 			flag_12 <= 1'b0;
// 		end

// 		if(O_DAC1_RAM_data == O_DAC3_RAM_data) begin
// 			flag_13 <= 1'b1;
// 		end
// 		else begin
// 			flag_13 <= 1'b0;
// 		end

// 		if(O_DAC1_RAM_data == O_DAC4_RAM_data) begin
// 			flag_14 <= 1'b1;
// 		end
// 		else begin
// 			flag_14 <= 1'b0;
// 		end

// 		if(O_DAC2_RAM_data == O_DAC3_RAM_data) begin
// 			flag_23 <= 1'b1;
// 		end
// 		else begin
// 			flag_23 <= 1'b0;
// 		end

// 		if(O_DAC2_RAM_data == O_DAC4_RAM_data) begin
// 			flag_24 <= 1'b1;
// 		end
// 		else begin
// 			flag_24 <= 1'b0;
// 		end
		
// 		if(O_DAC3_RAM_data == O_DAC4_RAM_data) begin
// 			flag_34 <= 1'b1;
// 		end
// 		else begin
// 			flag_34 <= 1'b0;
// 		end
// 	end
// end

// ila_15 ila_15_pxie_ram_data (
// 	.clk(I_CLK_250mhz), // input wire clk


// 	.probe0(flag_12), // input wire [0:0]  probe0  
// 	.probe1(flag_13), // input wire [0:0]  probe1 
// 	.probe2(flag_14), // input wire [0:0]  probe2 
// 	.probe3(flag_23), // input wire [0:0]  probe3 
// 	.probe4(flag_24), // input wire [0:0]  probe4 
// 	.probe5(flag_34), // input wire [0:0]  probe5
// 	.probe6(O_DAC1_RAM_data_vld), // input wire [0:0]  probe6 
// 	.probe7(O_DAC2_RAM_data_vld), // input wire [0:0]  probe7 
// 	.probe8(O_DAC3_RAM_data_vld), // input wire [0:0]  probe8 
// 	.probe9(O_DAC4_RAM_data_vld), // input wire [0:0]  probe9
// 	.probe10(flag_total) // input wire [0:0]  probe10
// );

endmodule
