`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Alibaba
// Engineer: Xing Zhu
//
// Create Date: 2020/03/17 11:08:45
// Design Name:
// Module Name: AQLAD02_TOP
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

module AQLAD02_TOP(
	input			clk_i,
	input			rstn_ex_i,
//--adc1--------------------------------------------------------------------------
	//data&clk
	input	[11:0]	adc1_I_p,
	input	[11:0]	adc1_I_n,
	input	[11:0]	adc1_Q_p,
	input	[11:0]	adc1_Q_n,
	input	[11:0]	adc1_Id_p,
	input	[11:0]	adc1_Id_n,
	input	[11:0]	adc1_Qd_p,
	input	[11:0]	adc1_Qd_n,
	input			adc1_clkI_p,
	input			adc1_clkI_n,
	input			adc1_clkQ_p,
	input			adc1_clkQ_n,
	//test
	input			adc1_ORI_p,
	input			adc1_ORI_n,
	input			adc1_ORQ_p,
	input			adc1_ORQ_n,
	//input			adc1_Tdiode_p,
	//input			adc1_Tdiode_n,
	output			adc1_caldly,
	output			adc1_cal,
	input			adc1_calrun,
	//spi
	output			adc1_scsn,
	output			adc1_sclk,
	output			adc1_sdi,
	input			adc1_sdo,
//--adc2--------------------------------------------------------------------------
	//data&clk
	input	[11:0]	adc2_I_p,
	input	[11:0]	adc2_I_n,
	input	[11:0]	adc2_Q_p,
	input	[11:0]	adc2_Q_n,
	input	[11:0]	adc2_Id_p,
	input	[11:0]	adc2_Id_n,
	input	[11:0]	adc2_Qd_p,
	input	[11:0]	adc2_Qd_n,
	input			adc2_clkI_p,
	input			adc2_clkI_n,
	input			adc2_clkQ_p,
	input			adc2_clkQ_n,
	//test
	input			adc2_ORI_p,
	input			adc2_ORI_n,
	input			adc2_ORQ_p,
	input			adc2_ORQ_n,
	//input			adc2_Tdiode_p,
	//input			adc2_Tdiode_n,
	output			adc2_caldly,
	output			adc2_cal,
	input			adc2_calrun,
	//spi
	output			adc2_scsn,
	output			adc2_sclk,
	output			adc2_sdi,
	input			adc2_sdo,
//--ddr1--------------------------------------------------------------------------
	output	[15:0]	ddr1_A,				// address
	output	[2:0]	ddr1_BA,			// bank
	inout	[7:0]	ddr1_DQ,			// data input and output
	output			ddr1_clkp,			// 250 MHz
	output			ddr1_clkn,			// 250 MHz
	inout			ddr1_DQSp,			// for use in data capture
	inout			ddr1_DQSn,			// for use in data capture
	output			ddr1_cke,			// clock enable
	output			ddr1_rstn,			//
	output			ddr1_csn,			// chip select
	output			ddr1_DM,
	output			ddr1_ODT,
	output			ddr1_CASn,			// command
	output			ddr1_RASn,			// command
	output			ddr1_WEn,			// command
	input 			ddr1_sysclk_p,
	input 			ddr1_sysclk_n,
//--ddr2--------------------------------------------------------------------------
	output	[15:0]	ddr2_A,
	output	[2:0]	ddr2_BA,
	inout	[7:0]	ddr2_DQ,
	output			ddr2_clkp,
	output			ddr2_clkn,
	inout			ddr2_DQSp,
	inout			ddr2_DQSn,
	output			ddr2_cke,
	output			ddr2_rstn,
	output			ddr2_csn,
	output			ddr2_DM,
	output			ddr2_ODT,
	output			ddr2_CASn,
	output			ddr2_RASn,
	output			ddr2_WEn,
	input 			ddr2_sysclk_p,
	input 			ddr2_sysclk_n,
//--lmk04610----------------------------------------------------------------------
	output			lmk_resetn,
	output			lmk_sel,
	output			lmk_sclk,			//spi
	output			lmk_scs,			//spi
	output			lmk_sdio,			//spi
	inout			lmk_st0,			//debug
	inout			lmk_st1,			//debug
	inout			lmk_sync,			//sync
	input			clock5_p,
	input			clock5_n,
	input			clock6_p,
	input			clock6_n,
	input			clock8_p,
	input			clock8_n,
//--PXIe--------------------------------------------------------------------------
	input	[4:0]	local_ga_pin,
	output	[3:0]	pcie_txp,
	output	[3:0]	pcie_txn,
	input	[3:0]	pcie_rxp,
	input	[3:0]	pcie_rxn,
	input 			pcie_star,
	input			pcie_dstarb_p,		// from CT to AD
	input			pcie_dstarb_n, 		// from CT to AD
	output			pcie_dstarc_p,		// from AD to CT
	output			pcie_dstarc_n, 		// from AD to CT
	input			pcie_sys_clk_p,		// differential clk from pcie backplane
	input			pcie_sys_clk_n,		// differential clk from pcie backplane
	input			pcie_sys_rst_n,		// rst from pcie backplane
	input			pcie_clk_100_p,
	input			pcie_clk_100_n,
//--led---------------------------------------------------------------------------
	output 			trigger,
	output	[2:0]	led
	);

//--statement---------------------------------------------------------------------
//rst
wire 		global_rstn;
wire 		pll_rstn;
wire 		pll_rstn_s;
wire 		adc_rstn;
wire 		adc_rstn_s;
wire 		ddr_rstn;
wire 		ddr_rstn_s;
wire 		pcie_rstn;
wire 		pcie_rstn_s;
wire 		global_rstn_s;
wire 		global_rstn_h = rstn_ex_i;
assign 		global_rstn = global_rstn_h || global_rstn_s;
assign 		pll_rstn = global_rstn || pll_rstn_s;
assign 		adc_rst = ~(global_rstn || adc_rstn_s);
assign 		ddr_rstn = global_rstn || ddr_rstn_s;
assign 		pcie_rstn = global_rstn || pcie_rstn_s;
//led
assign 		led[0] = adc_calrun;
assign 		led[1] = adc1_calrun;
assign 		led[2] = adc2_calrun;
//cfg
wire 		[7:0] adc_modereg;
wire 		pcie_dstarb;
assign 		trigger = trig_star; //trig_star
//pcie
wire 		pcie_user_clk;
wire [127:0]pcie_data_out;
wire        pcie_data_en;
wire [127:0]c2h_tdata_sig;
wire 		c2h_tvalid_sig;
wire		c2h_tlast_sig;
wire [15:0]	c2h_tkeep_sig;
wire 		c2h_tready_sig;
wire [4:0] 	ga_pins;
assign 		ga_pins = local_ga_pin;
//cfg parameter
wire [3:0] 	data_mode_sig;
wire [3:0]	analysis_mode_sig;
//--submodule---------------------------------------------------------------------
//--clock-------------------------------------------------------------------------
// clk_50M clk_100M : local osc
// clk_125M : sync clock
wire clk_100M;
wire clk_125M;
wire clk_50M;
wire clk_10M;
wire clk_5;
wire clk_6;
wire clk_8;

clk_wiz_0  clk_wiz_0_inst(
	// Clock out ports
	.clk_50M 	(clk_50M),
	.clk_100M 	(clk_100M),
	// Status and control signals
	.reset 		(!rstn_ex_i),
	.locked 	(),
	// Clock in ports
	.clk_in1 	(clk_i)
);

clk_wiz_1  clk_wiz_1_inst(
	// Clock out ports
	.clk_10M_o 	    (clk_10M),
	// Status and control signals
	.reset 	        (!rstn_ex_i),
	.locked         (),
	// Clock in ports
	.clk_125M_i     (clk_125M)
);


//trigger
wire trig_star;
IBUF #(
.IBUF_LOW_PWR("TRUE"), // Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
.IOSTANDARD("DEFAULT") // Specify the input I/O standard
) IBUF_inst (
.O(trig_star), // Buffer output
.I(pcie_star) // Buffer input (connect directly to top-level port)
);

IBUFDS #(
    .DIFF_TERM("TRUE"),        // Differential Termination
    .IBUF_LOW_PWR("FALSE"),    // Low power="TRUE", Highest performance="FALSE"
    .IOSTANDARD("DEFAULT")     // Specify the input I/O standard
) IBUFDS1_inst (
    .O(pcie_dstarb),                 	// Buffer output
    .I(pcie_dstarb_p),               	// Diff_p buffer input (connect directly to top-level port)
    .IB(pcie_dstarb_n)               	// Diff_n buffer input (connect directly to top-level port)
);

//sync clock 125MHz
IBUFDS #(
    .DIFF_TERM("TRUE"),        // Differential Termination
    .IBUF_LOW_PWR("FALSE"),    // Low power="TRUE", Highest performance="FALSE"
    .IOSTANDARD("DEFAULT")     // Specify the input I/O standard
) IBUFDS2_inst (
    .O(clk_125M),                 		// Buffer output
    .I(clock5_p),                 		// Diff_p buffer input (connect directly to top-level port)
    .IB(clock5_n)                 		// Diff_n buffer input (connect directly to top-level port)
);

//ad 2 tc
OBUFDS #(
    // .DIFF_TERM("TRUE"),        // Differential Termination
    // .IBUF_LOW_PWR("FALSE"),    // Low power="TRUE", Highest performance="FALSE"
    .IOSTANDARD("DEFAULT")     // Specify the input I/O standard
	) OBUF_dstarc_inst(
	.O(pcie_dstarc_p),
	.OB(pcie_dstarc_n),
	.I(UART_txb)
            );
//--adc--------------------------------------------------------------------------
//statement
wire [511:0] adc_data;
wire adc_data_valid;
wire fifo_empty_sig;
wire prog_full_sig;
wire [15:0] wave_fre;
wire [31:0] I0;
wire [31:0] Q0;
wire [31:0] I1;
wire [31:0] Q1;
wire 		isa_mode_vld_sig;
//inst
adc_mdl adc_inst(
	.clk_pcie_user 	(pcie_user_clk),
	.clk_50M 		(clk_50M),
	.clk_125M 		(clk_125M),
	.reset 			(~global_rstn_h),
	// parameters
	.wave_fre 		(wave_fre),
	.trig_ex 		(trig_star), // pcie_dstarb trig_star
	.dma_start 		(c2h_tready_sig),
    .wave_len_i 	(wave_len_sig), //UART_length wave_len_sig
    .cycle_i 		(UART_cycle), //UART_cycle cycle_sig
    .delay_i 		(UART_wait_time), //UART_wait_time delay_sig
    .fifo_empty 	(fifo_empty_sig),
    .prog_full 		(prog_full_sig),
    .data_mode 		(data_mode_sig),
    .isa_mode_vld 	(isa_mode_vld_sig),
    .I0 					  (I0),
	.Q0 				      (Q0),
	.I1 					  (I1),
	.Q1 					  (Q1),

	//adc1
	.adc1_dclki_p 	(adc1_clkI_p),
	.adc1_dclki_n 	(adc1_clkI_n),
	.adc1_di_p 		(adc1_I_p),
	.adc1_di_n 		(adc1_I_n),
	.adc1_did_p 	(adc1_Id_p),
	.adc1_did_n 	(adc1_Id_n),
	.adc1_dclkq_p 	(adc1_clkQ_p),
	.adc1_dclkq_n 	(adc1_clkQ_n),
	.adc1_dq_p 		(adc1_Q_p),
	.adc1_dq_n 		(adc1_Q_n),
	.adc1_dqd_p 	(adc1_Qd_p),
	.adc1_dqd_n 	(adc1_Qd_n),
	//adc2
	.adc2_dclki_p 	(adc2_clkI_p),
	.adc2_dclki_n 	(adc2_clkI_n),
	.adc2_di_p 		(adc2_I_p),
	.adc2_di_n 		(adc2_I_n),
	.adc2_did_p 	(adc2_Id_p),
	.adc2_did_n 	(adc2_Id_n),
	.adc2_dclkq_p 	(adc2_clkQ_p),
	.adc2_dclkq_n 	(adc2_clkQ_n),
	.adc2_dq_p 		(adc2_Q_p),
	.adc2_dq_n 		(adc2_Q_n),
	.adc2_dqd_p 	(adc2_Qd_p),
	.adc2_dqd_n 	(adc2_Qd_n),
	//
    .uart_data      (W_UART_DATA),
    .uart_en        (W_UART_DATA_VLD),
    .uart_clk       (clk_10M),
    .uart_tx_ready  (W_tx_ready),

	.adc_data_o 	(adc_data),
	.adc_data_valid_o(adc_data_valid)
);
//--ADC config---------------------------------------------------------
wire adc1_cfgen_sig;
wire [23:0]	adc1_cfgdata_sig;
wire adc2_cfgen_sig;
wire [23:0]	adc2_cfgdata_sig;
wire adc1_sclk_sig;
wire adc2_sclk_sig;
wire adc1_scsn_sig;
wire adc2_scsn_sig;
wire adc1_sdi_sig;
wire adc2_sdi_sig;
wire adc_calrun;
wire adc_cal;
wire adc_caldly;

assign adc_calrun= adc1_calrun && adc2_calrun;
assign adc1_cal  = adc_cal;
assign adc1_caldly	= adc_caldly;
assign adc2_cal  = adc_cal;
assign adc2_caldly	= adc_caldly;
assign adc1_sclk = adc1_sclk_sig;
assign adc1_scsn = adc1_scsn_sig;
assign adc1_sdi = adc1_sdi_sig;
assign adc2_sclk = adc2_sclk_sig;
assign adc2_scsn = adc2_scsn_sig;
assign adc2_sdi = adc2_sdi_sig;

adc_cfg_mdl adc_cfg_mdl_inst1(
	.clk			(clk_50M),
	.rstn			(global_rstn_h),
	.adc_reinit 	(1'b0),
	.adc_init_en_i	(1'b1),
	.adc_pinreg_i	(2'b01),
	.adc_cfgen_i	(adc1_cfgen_sig),
	.adc_cfgdata_i	(adc1_cfgdata_sig),
	.adc_cfgdone_o	(),
	.adc_rben_i		(),
	.adc_rbdata_o	(),
	.adc_rbdone_o	(),

	.adc_resetn		(),
	.adc_sel		(),
	.adc_clk		(adc1_sclk_sig),
	.adc_cs			(adc1_scsn_sig),
	.adc_sdio		(adc1_sdi_sig),
	.adc_sync		()
	);

adc_cfg_mdl adc_cfg_mdl_inst2(
	.clk			(clk_50M),
	.rstn			(global_rstn_h),
	.adc_reinit 	(1'b0),
	.adc_init_en_i	(1'b1),
	.adc_pinreg_i	(2'b01),
	.adc_cfgen_i	(adc2_cfgen_sig),
	.adc_cfgdata_i	(adc2_cfgdata_sig),
	.adc_cfgdone_o	(),
	.adc_rben_i		(),
	.adc_rbdata_o	(),
	.adc_rbdone_o	(),

	.adc_resetn		(),
	.adc_sel		(),
	.adc_clk		(adc2_sclk_sig),
	.adc_cs			(adc2_scsn_sig),
	.adc_sdio		(adc2_sdi_sig),
	.adc_sync		()
	);

calibration calibration_inst(
	.clk			(clk_50M),
	.rstn 			(rstn_ex_i),
	.cali_run 		(adc_calrun),
	.autocali_en	(adc_calen_sig),
	.cal 			(adc_cal),
	.caldly 		(adc_caldly)
	);

//--jitter cleaner config---------------------------------------------------------
//function: initial config lmk04610 & adjust it by command from pcie
//statement
wire pll_reinit_sig;
wire pll_init_en_sig;
wire [1:0]	pll_pinreg_sig;
wire pll_cfgen_sig;
wire [23:0]	pll_cfgdata_sig;
//init
pll_mdl pll_mdl_inst(
	.clk			(clk_50M),
	.rstn			(global_rstn_h),
	.pll_reinit 	(pll_reinit_sig),
	.pll_init_en_i	(pll_init_en_sig),
	.pll_pinreg_i	(pll_pinreg_sig),
	.pll_cfgen_i	(pll_cfgen_sig),
	.pll_cfgdata_i	(pll_cfgdata_sig),
	.pll_cfgdone_o	(),
	.pll_rben_i		(),
	.pll_rbdata_o	(),
	.pll_rbdone_o	(),
	//lmk04610 interface
	.pll_resetn		(lmk_resetn),
	.pll_sel		(lmk_sel),
	.pll_clk		(lmk_sclk),
	.pll_cs			(lmk_scs),
	.pll_sdio		(lmk_sdio),
	.pll_sync		(lmk_sync)
	);
//--Xbuf--------------------------------------------------------------------------
//statement
wire pcie_data_clk;
//inst
Xbuf_mdl Xbuf_mdl_inst(
	.ddr_rstn 		(ddr_rstn),
	.rstn 			(global_rstn_h),
    //parameter
    .clk_cmd 		(clk_50M),
    .data_mode 		(data_mode_sig),
	.wave_len_i 	(wave_len_sig),
	.cycle_i 		(UART_cycle), //cycle_sig
	.delay_i 		(UART_wait_time), //delay_sig
	.fifo_empty		(fifo_empty_sig),
	.prog_full 		(prog_full_sig),
    //tx_pxie
	.pcie_data_clk	(pcie_data_clk),
	.dma_start 		(dma_start_sig),
	.pcie_user_clk 	(pcie_user_clk),
	.c2h_tdata 		(c2h_tdata_sig),
	.c2h_tvalid 	(c2h_tvalid_sig),
	.c2h_tlast 		(c2h_tlast_sig),
	.c2h_tkeep 		(c2h_tkeep_sig),
	.c2h_tready 	(c2h_tready_sig),
    //adc interface
	.clk_adc 		(clk_125M),
	.adc_data 		(adc_data),
   	.adc_data_en 	(adc_data_valid),
	//ddr1 interface
	.ddr1_A 		(ddr1_A),				// address
	.ddr1_BA 		(ddr1_BA),			    // bank
	.ddr1_DQ 		(ddr1_DQ),			    // data input and output
	.ddr1_clkp 		(ddr1_clkp),			// 250 MHz
	.ddr1_clkn 		(ddr1_clkn),			// 250 MHz
	.ddr1_DQSp 		(ddr1_DQSp),			// for use in data capture
	.ddr1_DQSn 		(ddr1_DQSn),			// for use in data capture
	.ddr1_cke 		(ddr1_cke),			    // clock enable
	.ddr1_rstn 		(ddr1_rstn),			//
	.ddr1_csn 		(ddr1_csn),			    // chip select
	.ddr1_DM 		(ddr1_DM),
	.ddr1_ODT 		(ddr1_ODT),
	.ddr1_CASn 		(ddr1_CASn),			// command
	.ddr1_RASn 		(ddr1_RASn),			// command
	.ddr1_WEn 		(ddr1_WEn),			    // command
	.ddr1_sysclk_p 	(ddr1_sysclk_p),
	.ddr1_sysclk_n 	(ddr1_sysclk_n),
	.ddr1_refclk_p 	(clock6_p),
	.ddr1_refclk_n 	(clock6_n),
	//ddr2 interface
	.ddr2_A 		(),
	.ddr2_BA 		(),
	.ddr2_DQ 		(),
	.ddr2_clkp 		(),
	.ddr2_clkn 		(),
	.ddr2_DQSp 		(),
	.ddr2_DQSn 		(),
	.ddr2_cke 		(),
	.ddr2_rstn 		(),
	.ddr2_csn 		(),
	.ddr2_DM 		(),
	.ddr2_ODT 		(),
	.ddr2_CASn 		(),
	.ddr2_RASn 		(),
	.ddr2_WEn 		()
	);

//--PCIe--------------------------------------------------------------------------
//inst
pcie_mdl pcie_mdl_inst(
    .pci_exp_txp              (pcie_txp),
    .pci_exp_txn              (pcie_txn),
    .pci_exp_rxp              (pcie_rxp),
    .pci_exp_rxn              (pcie_rxn),

    .pcie_user_clk 			  (pcie_user_clk),
    .sys_clk_p                (pcie_sys_clk_p),
    .sys_clk_n                (pcie_sys_clk_n),
    .sys_rst_n                (pcie_sys_rst_n),

    .c2h_tdata 				  (c2h_tdata_sig),
    .c2h_tvalid 			  (c2h_tvalid_sig),
    .c2h_tlast 				  (c2h_tlast_sig),
    .c2h_tkeep   			  (c2h_tkeep_sig),
    .c2h_tready 			  (c2h_tready_sig),

    .h2c_data                 (pcie_data_out),
    .h2c_valid                (pcie_data_en)
    );
//PCIe_parser///////////////////////////////////////////////////////////////////////////
wire [13:0] cycle_sig;
wire [19:0]  delay_sig;
wire [13:0] wave_len_sig;
wire [1:0]  led_test;
wire 		dma_start_sig;
wire 		adc_calen_sig;


pcie_parser pcie_parser_inst(
    .pxie_clk                 (pcie_user_clk),
    .clk_50m                  (clk_50M),
    .resetn                   (rstn_ex_i),

    .pxie_rddata_in           (pcie_data_out),
    .pxie_rden_in             (pcie_data_en),
    //pll
    .pll_reinit_out 		  (pll_reinit_sig),
    .pll_init_en_out          (pll_init_en_sig),
    .pll_cfgen_out            (pll_cfgen_sig),
    .pll_cfgdata_out          (pll_cfgdata_sig),
    .pll_pinreg_out           (pll_pinreg_sig),
    //adc
    .adc_cfg_numb_out         (),
    .adc1_cfgen_out           (adc1_cfgen_sig),
    .adc1_cfgdata_out         (adc1_cfgdata_sig),
    .adc2_cfgen_out           (adc2_cfgen_sig),
    .adc2_cfgdata_out         (adc2_cfgdata_sig),
    .adc_trig_out             (),
    .adc_modereg_out          (adc_modereg),
    .adc_trig_thresh_out      (),
    .adc_calen_out 			  (adc_calen_sig),
    .wave_fre 				  (wave_fre),

    .dma_start_out            (dma_start_sig),
    .tdata_start_out          (),
    .delay_out                (delay_sig),
    .cycle_out                (cycle_sig),
    .wave_len_out             (wave_len_sig),
    .data_mode 				  (data_mode_sig),
    .analysis_mode 			  (analysis_mode_sig),
    .isa_mode_vld 			  (isa_mode_vld_sig),

    .pll_rstn_out             (pll_rstn_s),
    .adc_rstn_out             (adc_rstn_s),
    .ddr_rstn_out             (ddr_rstn_s),
    .pcie_rstn_out            (pcie_rstn_s),
    .global_rstn_out          (global_rstn_s),

    .I0 					  (I0),
	.Q0 				      (Q0),
	.I1 					  (I1),
	.Q1 					  (Q1),
    .test_led                 (led_test)
);

//To AQTC
(*mark_debug="true"*)wire        UART_txb;
(*mark_debug="true"*)wire [63:0] W_UART_DATA;
(*mark_debug="true"*)wire        W_UART_DATA_VLD;
(*mark_debug="true"*)wire        W_tx_ready;

UART_TX_DATA  inst_tx_data(
    .I_clk_10M      (clk_10M),
    .I_rst_n        (rstn_ex_i),
    .txb            (UART_txb),
    .I_data         (W_UART_DATA),
    .I_data_valid   (W_UART_DATA_VLD),
    .O_tx_ready     (W_tx_ready)
    );
//From AQTC
wire [31:0] UART_cycle;
wire [31:0] UART_length;
wire [31:0] UART_wait_time;

UART_RX_DATA inst_uart_rx_data(
	.I_clk_10M      (clk_10M),
	.I_rst_n        (rstn_ex_i),
	.rxb            (pcie_dstarb), //pcie_dstarb
	.GA             (ga_pins),
	.cycle_num      (UART_cycle),
	.sample_length  (UART_length),
    .wait_time      (UART_wait_time)
);

endmodule
