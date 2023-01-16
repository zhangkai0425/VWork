`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/11/18 11:23:10
// Design Name:
// Module Name: AQE_driver
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


module AQE_driver(
	//AHB_lite from CPU
	input           pll_core_cpuclk,
	input           biu_pad_hsel, 		//trans[1]
	input   [31:0]  biu_pad_haddr, 		//addr
	input   [2 :0]  biu_pad_hsize, 		//size
	input   [1 :0]  biu_pad_htrans, 	//trans
	input   [31:0]  biu_pad_hwdata, 	//write data
	input           biu_pad_hwrite, 	//write enable
	input           pad_biu_bigend_b, 	//-
	input           pad_cpu_rst_b, 		//-

	//RAM IO from SYS bus
	input 			sys_ram_wen,
  	output 			sys_ram_din,
  	input 			sys_ram_dout,
  	input 			sys_ram_addr

  	//bus from AQTC to other slots



    );


reg [5:0] 	isa_state;
reg [5:0]   state_next;
parameter	[5:0]	st_idle		= 6'b0000;
parameter	[5:0]	st_exe  	= 6'b0001;

parameter 	[5:0]	st_TRIG		= 6'b0001;
parameter   [5:0]	st_PLAY		= 6'b0001;
parameter   [5:0]	st_QWAIT	= 6'b0011;
parameter   [5:0]	st_ACQ		= 6'b0010;
parameter   [5:0]	st_FMR		= 6'b0001;

ISACapturer ISACapturer_inst(
	);

ISAParser ISAParser_inst(
	);

ISAExe ISAExe_inst(
	);

ISASer ISASer_inst(
	);




endmodule
