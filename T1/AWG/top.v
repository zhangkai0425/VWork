
`timescale 1ps/1ps
// N-Pulse
// Non-ISA Version
module top
#(
	parameter MAXIMUM_OF_EACH_CH = 2048			,	//每个通道的最大存储波形数
	parameter MAXIMUM_WIDTH_OF_EACH_CH = 11			//比特带宽
)
(
//	input I_SYS_Rst_n,
    output [3 : 0] pci_exp_txp,
    output [3 : 0] pci_exp_txn,
    input [3 : 0]  pci_exp_rxp,
    input [3 : 0]  pci_exp_rxn,
    input 	sys_clk_p,
    input 	sys_clk_n,
    input 	sys_rst_n,
	

(* DIFF_TERM = "TRUE" *)	input I_SYS_Clk_P,			// system 50MHz synchronous clock
(* DIFF_TERM = "TRUE" *)	input I_SYS_Clk_N,			// system 50MHz synchronous clock

(* DIFF_TERM = "TRUE" *)	input I_PXIE_Dstarb_p	,
(* DIFF_TERM = "TRUE" *)	input I_PXIE_Dstarb_n	,

	input I_PXIE_STAR	,
	input[4:0] I_PXIE_GA ,
	
	
	input I_LMK_Holdover,
	input I_LMK_LD,
	input I_LMK_STA_Clk1,
	input I_LMK_STA_Clk2,
(* DIFF_TERM = "TRUE" *)	input I_DAC1_DCO_Clk_P, //500Mhz
(* DIFF_TERM = "TRUE" *)	input I_DAC1_DCO_Clk_N, //500Mhz
(* DIFF_TERM = "TRUE" *)	input I_DAC2_DCO_Clk_P, //500Mhz
(* DIFF_TERM = "TRUE" *)	input I_DAC2_DCO_Clk_N, //500Mhz
(* DIFF_TERM = "TRUE" *)	input I_DAC3_DCO_Clk_P, //500Mhz
(* DIFF_TERM = "TRUE" *)	input I_DAC3_DCO_Clk_N, //500Mhz
(* DIFF_TERM = "TRUE" *)	input I_DAC4_DCO_Clk_P, //500Mhz
(* DIFF_TERM = "TRUE" *)	input I_DAC4_DCO_Clk_N, //500Mhz

	input LMK_DCO_P,
	input LMK_DCO_N,
	
	output O_DAC1_SDIO,
	output O_DAC3_SDIO,
	output O_DAC2_SDIO,
//	output IO_DAC3_SDIO,
	output O_DAC4_SDIO,

	output O_DAC1_DCI_Clk_P,
	output O_DAC1_DCI_Clk_N,
	output O_DAC2_DCI_Clk_P,
	output O_DAC2_DCI_Clk_N,
	output O_DAC3_DCI_Clk_P,
	output O_DAC3_DCI_Clk_N,
	output O_DAC4_DCI_Clk_P,
	output O_DAC4_DCI_Clk_N,
	
	output O_DAC1_Rst,
	output O_DAC1_CS,
	input  I_DAC1_SDO,
	output O_DAC1_SCLK,
	input  I_DAC1_IRQ,
	
	output O_DAC2_Rst,
	output O_DAC2_CS,
	input  I_DAC2_SDO,
	output O_DAC2_SCLK,
	input  I_DAC2_IRQ,
	
	output O_DAC3_Rst,
	output O_DAC3_CS,
	input  I_DAC3_SDO,
	output O_DAC3_SCLK,
	input  I_DAC3_IRQ,
	
	output O_DAC4_Rst,
	output O_DAC4_CS,
	input  I_DAC4_SDO,
	output O_DAC4_SCLK,
	input  I_DAC4_IRQ,
	
	output[13:0] O_DAC1_DA_P,
	output[13:0] O_DAC1_DA_N,
	output[13:0] O_DAC2_DA_P,
	output[13:0] O_DAC2_DA_N,
	output[13:0] O_DAC3_DA_P,
	output[13:0] O_DAC3_DA_N,
	output[13:0] O_DAC4_DA_P,
	output[13:0] O_DAC4_DA_N,
	output[13:0] O_DAC1_DB_P,
	output[13:0] O_DAC1_DB_N,
	output[13:0] O_DAC2_DB_P,
	output[13:0] O_DAC2_DB_N,
	output[13:0] O_DAC3_DB_P,
	output[13:0] O_DAC3_DB_N,
	output[13:0] O_DAC4_DB_P,
	output[13:0] O_DAC4_DB_N,	
	
	output O_LMK_Sync,
	output O_LMK_LE,
	output O_LMK_CLK,
	output O_LMK_DATA,
	
	
	input RXB
	

    );
	
//-----------------------DAC------------------------	

wire 	W_DAC1_DCI	;
wire 	W_DAC2_DCI	;
wire 	W_DAC3_DCI	;
wire 	W_DAC4_DCI	;
wire	W_DAC1_DCO_DIV2	;
wire	W_DAC2_DCO_DIV2	;
wire	W_DAC3_DCO_DIV2	;
wire	W_DAC4_DCO_DIV2	;

wire   W_DAC1_DCO; 
wire   W_DAC2_DCO;
wire   W_DAC3_DCO;
wire   W_DAC4_DCO;

 

wire[13:0] O_DAC1_DA_P;
wire[13:0] O_DAC1_DA_N;
wire[13:0] O_DAC1_DB_P;
wire[13:0] O_DAC1_DB_N;

wire[13:0] O_DAC2_DA_P;
wire[13:0] O_DAC2_DA_N;
wire[13:0] O_DAC2_DB_P;
wire[13:0] O_DAC2_DB_N;

wire[13:0] O_DAC3_DA_P;
wire[13:0] O_DAC3_DA_N;
wire[13:0] O_DAC3_DB_P;
wire[13:0] O_DAC3_DB_N;

wire[13:0] O_DAC4_DA_P;
wire[13:0] O_DAC4_DA_N;
wire[13:0] O_DAC4_DB_P;
wire[13:0] O_DAC4_DB_N;



//---------------------

wire	W_clk_250mhz	;
wire	W_clk_50mhz	;
wire	W_clk_20mhz	;
wire 	W_clk_10mhz ;

wire	W1_clk_250mhz	;
wire	W1_clk_50mhz	;
wire	W1_clk_20mhz	;
wire 	W1_clk_10mhz ;

wire   O_LMK_Sync;
wire   O_LMK_LE;
wire   O_LMK_CLK;
wire   O_LMK_DATA; 

wire	locked	;
//wire	W_Dac1_locked	;
//wire	W_Dac2_locked	;
//wire	W_Dac3_locked	;
//wire	W_Dac4_locked	;
wire	W_Pll_Trig	;
wire    W_rst_n ;
wire    W_DAC_rst_n;
wire	W_rst1_n	;



wire[13:0]    dds_i_b0  ;
wire[13:0]    dds_i_b1  ;
wire[13:0]    dds_i_b2  ;
wire[13:0]    dds_i_b3  ;
wire[13:0]    dds_i_b4  ;
wire[13:0]    dds_i_b5  ;
wire[13:0]    dds_i_b6  ;
wire[13:0]    dds_i_b7  ;
wire[15:0]     spi_reg1  ;  
wire[15:0]     spi_reg2  ; 
wire[15:0]     spi_reg3  ;
wire[15:0]     spi_reg4  ;
wire[31:0]    W_PLL_DATA_R0 ;

wire[8:0]	Value_Delay_Dci1;
wire[8:0]	Value_Delay_Dci2;
wire[8:0]	Value_Delay_Dci3;
wire[8:0]	Value_Delay_Dci4;

wire[8:0]	PXIE_Value_Delay_Dci1	;
wire[8:0]	PXIE_Value_Delay_Dci2	;
wire[8:0]	PXIE_Value_Delay_Dci3	;
wire[8:0]	PXIE_Value_Delay_Dci4	;
wire 		PXIE_LOAD				;

wire test_point1;
wire test_point2;
wire test_point3;

wire W_SYS_50Mhz;

wire W_Pulse_ena;

wire Delay_rst;


wire[8:0]	Value_Delay_Trig;
	
//----------------------------main programme begin here-------------------------------------//
wire DCO_locked;
wire clk_out1;
wire srst;
wire ena1;
wire test_locked;
wire W_LMK_DCO;
wire LOAD;

wire	W_Logic1_Rst_n	;
wire	W_Logic2_Rst_n	;
wire	W_Logic3_Rst_n	;
wire	W_PLL_Rst_n		;
wire	W_DAC_Rst_n		;
wire	W_FIFO_Rst		;
wire	W_PLL_SYNC		;
wire	Vio_DAC_rst_n	;
wire	Vio_DAC1_rst_n	;
wire	Vio_DAC2_rst_n	;
wire	Vio_DAC3_rst_n	;
wire	Vio_DAC4_rst_n	;
wire	W_ser_rst		;
wire	Vio_rst_n		;
wire	W_rst2_n		;
wire	W_rst3_n		;

wire	Vio_LMK_Sync	;

assign  O_LMK_Sync	=	Vio_LMK_Sync && W_PLL_SYNC	;	

wire	W_Trig_in	;
wire	W1_Trig_in	;

wire	W_PXIE_Rst	;
wire	W_PXIE_Rst_vld	;

wire	W_PXIE_Rstn_dac1	;
wire	W_PXIE_Rstn_dac2	;
wire	W_PXIE_Rstn_dac3	;
wire	W_PXIE_Rstn_dac4	;
wire	W_PXIE_Rstn_serdes	;
wire	W_PXIE_Rst_fifo		;
wire	W_PXIE_STAR		;
wire	W_UART_RXB	;

IBUFDS IBUFDS_SYS_CLK (
.O(W_SYS_50Mhz), // 1-bit output: Buffer output
.I(I_SYS_Clk_P), // 1-bit input: Diff_p buffer input (connect directly to top-level port)
.IB(I_SYS_Clk_N) // 1-bit input: Diff_n buffer input (connect directly to top-level port)
);

IBUFDS IBUFDS_DATA (
.O(W_UART_RXB), // 1-bit output: Buffer output
.I(I_PXIE_Dstarb_p), // 1-bit input: Diff_p buffer input (connect directly to top-level port)
.IB(I_PXIE_Dstarb_n) // 1-bit input: Diff_n buffer input (connect directly to top-level port)
);

IBUF #(
.IBUF_LOW_PWR("TRUE"), // Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
.IOSTANDARD("DEFAULT") // Specify the input I/O standard
) IBUF_trig (
.O(W_PXIE_STAR), // Buffer output
.I(I_PXIE_STAR) // Buffer input (connect directly to top-level port)
);

(* IODELAY_GROUP = "trig_delay" *)
IDELAYCTRL #(
.SIM_DEVICE("ULTRASCALE") // Must be set to "ULTRASCALE"
)
IDELAYCTRL_inst (
.RDY(), // 1-bit output: Ready output
.REFCLK(W_clk_250mhz), // 1-bit input: Reference clock input
.RST(!Delay_rst) // 1-bit input: Active high reset input. Asynchronous assert, synchronous deassert to
// REFCLK.
);

(* IODELAY_GROUP = "trig_delay" *)
IDELAYE3 #(
.CASCADE("NONE"), // Cascade setting (MASTER, NONE, SLAVE_END, SLAVE_MIDDLE)
.DELAY_FORMAT("COUNT"), // Units of the DELAY_VALUE (COUNT, TIME)
.DELAY_SRC("IDATAIN"), // Delay input (DATAIN, IDATAIN)
.DELAY_TYPE("VARIABLE"), // Set the type of tap delay line (FIXED, VARIABLE, VAR_LOAD)
.DELAY_VALUE(0), // Input delay value setting
.IS_CLK_INVERTED(1'b0), // Optional inversion for CLK
.IS_RST_INVERTED(1'b0), // Optional inversion for RST
.REFCLK_FREQUENCY(250.0), // IDELAYCTRL clock input frequency in MHz (200.0-2667.0)
.SIM_DEVICE("ULTRASCALE"), // Set the device version (ULTRASCALE)
.UPDATE_MODE("ASYNC") // Determines when updates to the delay will take effect (ASYNC, MANUAL, SYNC)
)
IDELAYE3_inst (
.CASC_OUT(), // 1-bit output: Cascade delay output to ODELAY input cascade
.CNTVALUEOUT(), // 9-bit output: Counter value output
.DATAOUT(W1_Trig_in), // 1-bit output: Delayed data output
.CASC_IN(), // 1-bit input: Cascade delay input from slave ODELAY CASCADE_OUT
.CASC_RETURN(), // 1-bit input: Cascade delay returning from slave ODELAY DATAOUT
.CE(1'b0), // 1-bit input: Active high enable increment/decrement input
.CLK(W_clk_250mhz), // 1-bit input: Clock input
.CNTVALUEIN(Value_Delay_Trig), // 9-bit input: Counter value input
.DATAIN(), // 1-bit input: Data input from the logic
.EN_VTC(1'b0), // 1-bit input: Keep delay constant over VT
.IDATAIN(W_Trig_in), // 1-bit input: Data input from the IOBUF
.INC(1'b0), // 1-bit input: Increment / Decrement tap delay input
.LOAD(1'b0), // 1-bit input: Load DELAY_VALUE input
.RST(!Delay_rst) // 1-bit input: Asynchronous Reset to the DELAY_VALUE
);



clk1 clk_gen(
  // Clock out ports
  .clk_out1(W_clk_50mhz),     // output clk_out1
  .clk_out2(W_clk_250mhz),     // output clk_out2
  .clk_out3(W_clk_20mhz),     // output clk_out3
  .clk_out4(W_clk_10mhz),     // output clk_out4
  // Status and control signals
  .locked(locked),       // output locked
 // Clock in ports
  .clk_in1(W_SYS_50Mhz)      // input clk_in1
);
  
global_reset_module  inst_reset_mdl(
	.I_clk_10mhz(W_SYS_50Mhz)	,
	.I_Rst_n(Vio_rst_n)	,
	.I_clk_locked(locked),
	.locked2(test_locked),
	.O_Logic1_Rst_n(W_Logic1_Rst_n),
	.O_Logic2_Rst_n(W_Logic2_Rst_n),
	.O_Logic3_Rst_n(W_Logic3_Rst_n),
	.O_PLL_Rst_n(W_PLL_Rst_n),	
	.O_DAC_Rst_n(W_DAC_Rst_n),	
	.O_FIFO_Rst(W_FIFO_Rst),
	.O_PLL_SYNC(W_PLL_SYNC)
);	

PXIE_RST_MDL   inst_pxie_rst(
	.I_clk_10mhz(W_clk_10mhz),
	.I_Rst_n(W_Logic1_Rst_n)	,
	.I_PXIE_Rst(W_PXIE_Rst),
	.I_PXIE_Rst_vld(W_PXIE_Rst_vld),
	.O_PXIE_Rstn_dac1(W_PXIE_Rstn_dac1),
	.O_PXIE_Rstn_dac2(W_PXIE_Rstn_dac2),
	.O_PXIE_Rstn_dac3(W_PXIE_Rstn_dac3),
	.O_PXIE_Rstn_dac4(W_PXIE_Rstn_dac4),
	.O_PXIE_Rstn_serdes(W_PXIE_Rstn_serdes),
	.O_PXIE_Rst_fifo(W_PXIE_Rst_fifo)
);
	

IBUFDS IBUFDS_DAC1_DCO (
.O(W_DAC1_DCO), // 1-bit output: Buffer output
.I(I_DAC1_DCO_Clk_P), // 1-bit input: Diff_p buffer input (connect directly to top-level port)
.IB(I_DAC1_DCO_Clk_N) // 1-bit input: Diff_n buffer input (connect directly to top-level port)
);

IBUFDS IBUFDS_DAC2_DCO (
.O(W_DAC2_DCO), // 1-bit output: Buffer output
.I(I_DAC2_DCO_Clk_P), // 1-bit input: Diff_p buffer input (connect directly to top-level port)
.IB(I_DAC2_DCO_Clk_N) // 1-bit input: Diff_n buffer input (connect directly to top-level port)
);

IBUFDS IBUFDS_DAC3_DCO (
.O(W_DAC3_DCO), // 1-bit output: Buffer output
.I(I_DAC3_DCO_Clk_P), // 1-bit input: Diff_p buffer input (connect directly to top-level port)
.IB(I_DAC3_DCO_Clk_N) // 1-bit input: Diff_n buffer input (connect directly to top-level port)
);

IBUFDS IBUFDS_DAC4_DCO (
.O(W_DAC4_DCO), // 1-bit output: Buffer output
.I(I_DAC4_DCO_Clk_P), // 1-bit input: Diff_p buffer input (connect directly to top-level port)
.IB(I_DAC4_DCO_Clk_N) // 1-bit input: Diff_n buffer input (connect directly to top-level port)
);

IBUFDS IBUFDS_LMK_DCO (
.O(W_LMK_DCO), // 1-bit output: Buffer output
.I(LMK_DCO_P), // 1-bit input: Diff_p buffer input (connect directly to top-level port)
.IB(LMK_DCO_N) // 1-bit input: Diff_n buffer input (connect directly to top-level port)
);


wire rdy;

(* IODELAY_GROUP = "idelay1" *)
IDELAYCTRL #(
.SIM_DEVICE("ULTRASCALE") // Must be set to "ULTRASCALE"
)
IDELAYCTRL_inst_trig (
.RDY(), // 1-bit output: Ready output
.REFCLK(W_clk_250mhz), // 1-bit input: Reference clock input
.RST(!Delay_rst) // 1-bit input: Active high reset input. Asynchronous assert, synchronous deassert to
// REFCLK.
);


(* IODELAY_GROUP = "idelay1" *)
ODELAYE3 #(
.CASCADE("NONE"), // Cascade setting (MASTER, NONE, SLAVE_END, SLAVE_MIDDLE)
.DELAY_FORMAT("COUNT"), // (COUNT, TIME)
.DELAY_TYPE("VAR_LOAD"), // Set the type of tap delay line (FIXED, VARIABLE, VAR_LOAD)
.DELAY_VALUE(0), // Output delay tap setting
.IS_CLK_INVERTED(1'b0), // Optional inversion for CLK
.IS_RST_INVERTED(1'b0), // Optional inversion for RST
.REFCLK_FREQUENCY(250.0), // IDELAYCTRL clock input frequency in MHz (200.0-2667.0).
.SIM_DEVICE("ULTRASCALE"), // Set the device version (ULTRASCALE)
.UPDATE_MODE("ASYNC") // Determines when updates to the delay will take effect (ASYNC, MANUAL, SYNC)
)
ODELAYE3_inst_trig (
.CASC_OUT(), // 1-bit output: Cascade delay output to IDELAY input cascade
.CNTVALUEOUT(), // 9-bit output: Counter value output
.DATAOUT(W_DAC1_DCI), // 1-bit output: Delayed data from ODATAIN input port
.CASC_IN(), // 1-bit input: Cascade delay input from slave IDELAY CASCADE_OUT
.CASC_RETURN(), // 1-bit input: Cascade delay returning from slave IDELAY DATAOUT
.CE(1'b0), // 1-bit input: Active high enable increment/decrement input
.CLK(W_clk_250mhz), // 1-bit input: Clock input
.CNTVALUEIN(PXIE_Value_Delay_Dci1), // 9-bit input: Counter value input
.EN_VTC(1'b0), // 1-bit input: Keep delay constant over VT
.INC(1'b0), // 1-bit input: Increment/Decrement tap delay input
.LOAD(LOAD & PXIE_LOAD), // 1-bit input: Load DELAY_VALUE input
.ODATAIN(W_DAC1_DCO), // 1-bit input: Data input
.RST(!Delay_rst) // 1-bit input: Asynchronous Reset to the DELAY_VALUE
);

OBUFDS OBUFDS_DAC1_DCI (
.O(O_DAC1_DCI_Clk_P), // 1-bit output: Diff_p output (connect directly to top-level port)
.OB(O_DAC1_DCI_Clk_N), // 1-bit output: Diff_n output (connect directly to top-level port)
.I(W_DAC1_DCI) // 1-bit input: Buffer input
);


(* IODELAY_GROUP = "idelay2" *)
IDELAYCTRL #(
.SIM_DEVICE("ULTRASCALE") // Must be set to "ULTRASCALE"
)
IDELAYCTRL_inst2 (
.RDY(), // 1-bit output: Ready output
.REFCLK(W_clk_250mhz), // 1-bit input: Reference clock input
.RST(!Delay_rst) // 1-bit input: Active high reset input. Asynchronous assert, synchronous deassert to
// REFCLK.
);

(* IODELAY_GROUP = "idelay2" *)
ODELAYE3 #(
.CASCADE("NONE"), // Cascade setting (MASTER, NONE, SLAVE_END, SLAVE_MIDDLE)
.DELAY_FORMAT("COUNT"), // (COUNT, TIME)
.DELAY_TYPE("VAR_LOAD"), // Set the type of tap delay line (FIXED, VARIABLE, VAR_LOAD)
.DELAY_VALUE(0), // Output delay tap setting
.IS_CLK_INVERTED(1'b0), // Optional inversion for CLK
.IS_RST_INVERTED(1'b0), // Optional inversion for RST
.REFCLK_FREQUENCY(250.0), // IDELAYCTRL clock input frequency in MHz (200.0-2667.0).
.SIM_DEVICE("ULTRASCALE"), // Set the device version (ULTRASCALE)
.UPDATE_MODE("ASYNC") // Determines when updates to the delay will take effect (ASYNC, MANUAL, SYNC)
)
ODELAYE3_inst2 (
.CASC_OUT(), // 1-bit output: Cascade delay output to IDELAY input cascade
.CNTVALUEOUT(), // 9-bit output: Counter value output
.DATAOUT(W_DAC2_DCI), // 1-bit output: Delayed data from ODATAIN input port
.CASC_IN(), // 1-bit input: Cascade delay input from slave IDELAY CASCADE_OUT
.CASC_RETURN(), // 1-bit input: Cascade delay returning from slave IDELAY DATAOUT
.CE(1'b0), // 1-bit input: Active high enable increment/decrement input
.CLK(W_clk_250mhz), // 1-bit input: Clock input
.CNTVALUEIN(PXIE_Value_Delay_Dci2), // 9-bit input: Counter value input
.EN_VTC(1'b0), // 1-bit input: Keep delay constant over VT
.INC(1'b0), // 1-bit input: Increment/Decrement tap delay input
.LOAD(LOAD & PXIE_LOAD), // 1-bit input: Load DELAY_VALUE input
.ODATAIN(W_DAC1_DCO), // 1-bit input: Data input
.RST(!Delay_rst) // 1-bit input: Asynchronous Reset to the DELAY_VALUE
);


OBUFDS OBUFDS_DAC2_DCI (
.O(O_DAC2_DCI_Clk_P), // 1-bit output: Diff_p output (connect directly to top-level port)
.OB(O_DAC2_DCI_Clk_N), // 1-bit output: Diff_n output (connect directly to top-level port)
.I(W_DAC2_DCI) // 1-bit input: Buffer input
);


(* IODELAY_GROUP = "idelay3" *)
IDELAYCTRL #(
.SIM_DEVICE("ULTRASCALE") // Must be set to "ULTRASCALE"
)
IDELAYCTRL_inst3 (
.RDY(rdy), // 1-bit output: Ready output
.REFCLK(W_clk_250mhz), // 1-bit input: Reference clock input
.RST(!Delay_rst) // 1-bit input: Active high reset input. Asynchronous assert, synchronous deassert to
// REFCLK.
);

wire[8:0]	CNTVALUEOUT;
(* IODELAY_GROUP = "idelay3" *)
ODELAYE3 #(
.CASCADE("NONE"), // Cascade setting (MASTER, NONE, SLAVE_END, SLAVE_MIDDLE)
.DELAY_FORMAT("COUNT"), // (COUNT, TIME)
.DELAY_TYPE("VAR_LOAD"), // Set the type of tap delay line (FIXED, VARIABLE, VAR_LOAD)
.DELAY_VALUE(0), // Output delay tap setting
.IS_CLK_INVERTED(1'b0), // Optional inversion for CLK
.IS_RST_INVERTED(1'b0), // Optional inversion for RST
.REFCLK_FREQUENCY(250.0), // IDELAYCTRL clock input frequency in MHz (200.0-2667.0).
.SIM_DEVICE("ULTRASCALE"), // Set the device version (ULTRASCALE)
.UPDATE_MODE("ASYNC") // Determines when updates to the delay will take effect (ASYNC, MANUAL, SYNC)
)
ODELAYE3_inst3 (
.CASC_OUT(), // 1-bit output: Cascade delay output to IDELAY input cascade
.CNTVALUEOUT(CNTVALUEOUT), // 9-bit output: Counter value output
.DATAOUT(W_DAC3_DCI), // 1-bit output: Delayed data from ODATAIN input port
.CASC_IN(), // 1-bit input: Cascade delay input from slave IDELAY CASCADE_OUT
.CASC_RETURN(), // 1-bit input: Cascade delay returning from slave IDELAY DATAOUT
.CE(1'b0), // 1-bit input: Active high enable increment/decrement input
.CLK(W_clk_250mhz), // 1-bit input: Clock input
.CNTVALUEIN(PXIE_Value_Delay_Dci3), // 9-bit input: Counter value input
.EN_VTC(1'b0), // 1-bit input: Keep delay constant over VT
.INC(1'b0), // 1-bit input: Increment/Decrement tap delay input
.LOAD(LOAD & PXIE_LOAD), // 1-bit input: Load DELAY_VALUE input
.ODATAIN(W_DAC1_DCO), // 1-bit input: Data input
.RST(!Delay_rst) // 1-bit input: Asynchronous Reset to the DELAY_VALUE
);


OBUFDS OBUFDS_DAC3_DCI (
.O(O_DAC3_DCI_Clk_P), // 1-bit output: Diff_p output (connect directly to top-level port)
.OB(O_DAC3_DCI_Clk_N), // 1-bit output: Diff_n output (connect directly to top-level port)
.I(W_DAC3_DCI) // 1-bit input: Buffer input
);


(* IODELAY_GROUP = "idelay4" *)
IDELAYCTRL #(
.SIM_DEVICE("ULTRASCALE") // Must be set to "ULTRASCALE"
)
IDELAYCTRL_inst4 (
.RDY(), // 1-bit output: Ready output
.REFCLK(W_clk_250mhz), // 1-bit input: Reference clock input
.RST(!Delay_rst) // 1-bit input: Active high reset input. Asynchronous assert, synchronous deassert to
// REFCLK.
);

(* IODELAY_GROUP = "idelay4" *)
ODELAYE3 #(
.CASCADE("NONE"), // Cascade setting (MASTER, NONE, SLAVE_END, SLAVE_MIDDLE)
.DELAY_FORMAT("COUNT"), // (COUNT, TIME)
.DELAY_TYPE("VAR_LOAD"), // Set the type of tap delay line (FIXED, VARIABLE, VAR_LOAD)
.DELAY_VALUE(0), // Output delay tap setting
.IS_CLK_INVERTED(1'b0), // Optional inversion for CLK
.IS_RST_INVERTED(1'b0), // Optional inversion for RST
.REFCLK_FREQUENCY(250.0), // IDELAYCTRL clock input frequency in MHz (200.0-2667.0).
.SIM_DEVICE("ULTRASCALE"), // Set the device version (ULTRASCALE)
.UPDATE_MODE("ASYNC") // Determines when updates to the delay will take effect (ASYNC, MANUAL, SYNC)
)
ODELAYE3_inst4 (
.CASC_OUT(), // 1-bit output: Cascade delay output to IDELAY input cascade
.CNTVALUEOUT(), // 9-bit output: Counter value output
.DATAOUT(W_DAC4_DCI), // 1-bit output: Delayed data from ODATAIN input port
.CASC_IN(), // 1-bit input: Cascade delay input from slave IDELAY CASCADE_OUT
.CASC_RETURN(), // 1-bit input: Cascade delay returning from slave IDELAY DATAOUT
.CE(1'b0), // 1-bit input: Active high enable increment/decrement input
.CLK(W_clk_250mhz), // 1-bit input: Clock input
.CNTVALUEIN(PXIE_Value_Delay_Dci4), // 9-bit input: Counter value input
.EN_VTC(1'b0), // 1-bit input: Keep delay constant over VT
.INC(1'b0), // 1-bit input: Increment/Decrement tap delay input
.LOAD(LOAD & PXIE_LOAD), // 1-bit input: Load DELAY_VALUE input
.ODATAIN(W_DAC1_DCO), // 1-bit input: Data input
.RST(!Delay_rst) // 1-bit input: Asynchronous Reset to the DELAY_VALUE
);


OBUFDS OBUFDS_DAC4_DCI (
.O(O_DAC4_DCI_Clk_P), // 1-bit output: Diff_p output (connect directly to top-level port)
.OB(O_DAC4_DCI_Clk_N), // 1-bit output: Diff_n output (connect directly to top-level port)
.I(W_DAC4_DCI) // 1-bit input: Buffer input
);


BUFGCE_DIV #(
.BUFGCE_DIVIDE(2), // 1-8
// Programmable Inversion Attributes: Specifies built-in programmable inversion on specific pins
.IS_CE_INVERTED(1'b0), // Optional inversion for CE
.IS_CLR_INVERTED(1'b0), // Optional inversion for CLR
.IS_I_INVERTED(1'b0) // Optional inversion for I
)
BUFGCE_DIV_inst0 (
.O(W_DAC1_DCO_DIV2), // 1-bit output: Buffer
.CE(1'b1), // 1-bit input: Buffer enable
.CLR(1'b0), // 1-bit input: Asynchronous clear
.I(W_DAC1_DCO) // 1-bit input: Buffer
);


BUFGCE_DIV #(
.BUFGCE_DIVIDE(2), // 1-8
// Programmable Inversion Attributes: Specifies built-in programmable inversion on specific pins
.IS_CE_INVERTED(1'b0), // Optional inversion for CE
.IS_CLR_INVERTED(1'b0), // Optional inversion for CLR
.IS_I_INVERTED(1'b0) // Optional inversion for I
)
BUFGCE_DIV_inst1 (
.O(W_DAC2_DCO_DIV2), // 1-bit output: Buffer
.CE(1'b1), // 1-bit input: Buffer enable
.CLR(1'b0), // 1-bit input: Asynchronous clear
.I(W_DAC2_DCO) // 1-bit input: Buffer
);

BUFGCE_DIV #(
.BUFGCE_DIVIDE(2), // 1-8
// Programmable Inversion Attributes: Specifies built-in programmable inversion on specific pins
.IS_CE_INVERTED(1'b0), // Optional inversion for CE
.IS_CLR_INVERTED(1'b0), // Optional inversion for CLR
.IS_I_INVERTED(1'b0) // Optional inversion for I
)
BUFGCE_DIV_inst2(
.O(W_DAC3_DCO_DIV2), // 1-bit output: Buffer
.CE(1'b1), // 1-bit input: Buffer enable
.CLR(1'b0), // 1-bit input: Asynchronous clear
.I(W_DAC3_DCO) // 1-bit input: Buffer
);

BUFGCE_DIV #(
.BUFGCE_DIVIDE(2), // 1-8
// Programmable Inversion Attributes: Specifies built-in programmable inversion on specific pins
.IS_CE_INVERTED(1'b0), // Optional inversion for CE
.IS_CLR_INVERTED(1'b0), // Optional inversion for CLR
.IS_I_INVERTED(1'b0) // Optional inversion for I
)
BUFGCE_DIV_inst3(
.O(W_DAC4_DCO_DIV2), // 1-bit output: Buffer
.CE(1'b1), // 1-bit input: Buffer enable
.CLR(1'b0), // 1-bit input: Asynchronous clear
.I(W_DAC4_DCO) // 1-bit input: Buffer
);



// AD9739 DAC SPI interface module instantiation
// master channel
ad9739_spi_master DAC1_interface(
	.rst_n(Vio_DAC1_rst_n && W_DAC_Rst_n && W_PXIE_Rstn_dac1),
	.clk_20mhz(W_clk_10mhz),
	.sdo(I_DAC1_SDO),
	.spi_reg1(spi_reg1),
    .spi_reg2(spi_reg2),
    .spi_reg3(spi_reg3),
    .spi_reg4(spi_reg4),
	.sdio(O_DAC1_SDIO),
	.sclk(O_DAC1_SCLK),
	.cs_n(O_DAC1_CS),
	.dac_rst(O_DAC1_Rst),
	.dac_locked(W_Dac1_locked)
	);

ad9739_spi_interface DAC2_interface(
	.rst_n(Vio_DAC2_rst_n && W_DAC_Rst_n  && W_PXIE_Rstn_dac2),
	.clk_20mhz(W_clk_10mhz),
	.sdo(I_DAC2_SDO),
	.spi_reg1(spi_reg1),
    .spi_reg2(spi_reg2),
    .spi_reg3(spi_reg3),
    .spi_reg4(spi_reg4),
	.sdio(O_DAC2_SDIO),
	.sclk(O_DAC2_SCLK),
	.cs_n(O_DAC2_CS),
	.dac_rst(O_DAC2_Rst),
	.dac_locked(W_Dac2_locked)
	);	

ad9739_spi_interface DAC3_interface(
	.rst_n(Vio_DAC3_rst_n && W_DAC_Rst_n && W_PXIE_Rstn_dac3),
	.clk_20mhz(W_clk_10mhz),
	.sdo(I_DAC3_SDO),
	.spi_reg1(spi_reg1),
	.spi_reg2(spi_reg2),
	.spi_reg3(spi_reg3),
	.spi_reg4(spi_reg4),
	.sdio(O_DAC3_SDIO),
	.sclk(O_DAC3_SCLK),
	.cs_n(O_DAC3_CS),
	.dac_rst(O_DAC3_Rst),
	.dac_locked(W_Dac3_locked)
	);
	
ad9739_spi_interface DAC4_interface(
	.rst_n(Vio_DAC4_rst_n && W_DAC_Rst_n && W_PXIE_Rstn_dac4),
	.clk_20mhz(W_clk_10mhz),
	.sdo(I_DAC4_SDO),
	.spi_reg1(spi_reg1),
	.spi_reg2(spi_reg2),
	.spi_reg3(spi_reg3),
	.spi_reg4(spi_reg4),
	.sdio(O_DAC4_SDIO),
	.sclk(O_DAC4_SCLK),
	.cs_n(O_DAC4_CS),
	.dac_rst(O_DAC4_Rst),
	.dac_locked(W_Dac4_locked)
	);	

wire[127:0]	W_DAC1_RAM_DATA		;
wire		W_DAC1_RAM_DATA_VLD	;
wire[127:0]	W_DAC2_RAM_DATA		;
wire		W_DAC2_RAM_DATA_VLD	;
wire[127:0]	W_DAC3_RAM_DATA		;
wire		W_DAC3_RAM_DATA_VLD	;
wire[127:0]	W_DAC4_RAM_DATA		;
wire		W_DAC4_RAM_DATA_VLD	;

wire[13:0]	W_offset1	;
wire[13:0]	W_offset2	;
wire[13:0]	W_offset3	;
wire[13:0]	W_offset4	;

wire          ch1_data_vld        ;
wire  [127:0] ch1_data            ;

wire          ch2_data_vld        ;
wire  [127:0] ch2_data            ;

wire          ch3_data_vld        ;
wire  [127:0] ch3_data            ;

wire          ch4_data_vld        ;
wire  [127:0] ch4_data            ;

wire          DDS_DataProcess_ch1_data_vld        ;
wire  [127:0] DDS_DataProcess_ch1_data            ;

wire          DDS_DataProcess_ch2_data_vld        ;
wire  [127:0] DDS_DataProcess_ch2_data            ;

wire          DDS_DataProcess_ch3_data_vld        ;
wire  [127:0] DDS_DataProcess_ch3_data            ;

wire          DDS_DataProcess_ch4_data_vld        ;
wire  [127:0] DDS_DataProcess_ch4_data            ;

wire	[7:0]   Config_Group1_ram      	;
wire	[7:0]   Config_Group1_port      ;
wire			Config_Group1_mixer_on  ;
wire	[7:0]   Config_Group2_ram      	;
wire	[7:0]   Config_Group2_port      ;
wire			Config_Group2_mixer_on  ;

wire	 [23:0]	 Group1_Delta_Phase_I				 ;
wire	 [23:0]	 Group1_Delta_Phase_Q				 ;
wire	 	 	 Group1_Delta_Phase_vld				 ;

wire	 [23:0]	 Group2_Delta_Phase_I				 ;
wire	 [23:0]	 Group2_Delta_Phase_Q				 ;
wire	 	 	 Group2_Delta_Phase_vld				 ;

wire	 [23:0]	 Group1_Epsilon_Amp_I				 ;
wire	 [23:0]	 Group1_Epsilon_Amp_Q				 ;
wire	 [23:0]	 Group2_Epsilon_Amp_I				 ;
wire	 [23:0]	 Group2_Epsilon_Amp_Q				 ;

wire [55:0]	ch1_serdes_even_data	;
wire [55:0]	ch1_serdes_odd_data		;

wire [55:0]	ch2_serdes_even_data	;
wire [55:0]	ch2_serdes_odd_data		;

wire [55:0]	ch3_serdes_even_data	;
wire [55:0]	ch3_serdes_odd_data		;

wire [55:0]	ch4_serdes_even_data	;
wire [55:0]	ch4_serdes_odd_data		;

ad9739_data_interface DAC1_Data_Interface(
	.rst_n(W_rst2_n && W_Logic2_Rst_n),
	.rst_fifo(W_FIFO_Rst || srst || W_PXIE_Rst_fifo),
	.rst_serdes(W_rst3_n && W_Logic3_Rst_n  && W_PXIE_Rstn_serdes),
	.dds_clk(W_clk_250mhz),
	.dci_clk(W_DAC1_DCO),
	.dci_clk_d4(W_DAC1_DCO_DIV2),
	.clk_200mhz(W_clk_20mhz),
	.clk_20mhz(W_clk_20mhz),
//	.dac_locked(dac_locked),
	.dac_locked(1'b1),
	.I_offset(W_offset1),
	.dds_in_b0(DDS_DataProcess_ch1_data[15:0]),
	.dds_in_b1(DDS_DataProcess_ch1_data[31:16]),
	.dds_in_b2(DDS_DataProcess_ch1_data[47:32]),
	.dds_in_b3(DDS_DataProcess_ch1_data[63:48]),
	.dds_in_b4(DDS_DataProcess_ch1_data[79:64]),
	.dds_in_b5(DDS_DataProcess_ch1_data[95:80]),
	.dds_in_b6(DDS_DataProcess_ch1_data[111:96]),
	.dds_in_b7(DDS_DataProcess_ch1_data[127:112]),
	.db_0_p(O_DAC1_DA_P),
	.db_0_n(O_DAC1_DA_N),
	.db_1_p(O_DAC1_DB_P),
	.db_1_n(O_DAC1_DB_N),
	.wr_ena(DDS_DataProcess_ch1_data_vld),
	.O_trig(O_trig),

	.W_serdes_even_data(ch1_serdes_even_data),
	.W_serdes_odd_data(ch1_serdes_odd_data)

	);


ad9739_data_interface DAC2_Data_Interface(
	.rst_n(W_rst2_n && W_Logic2_Rst_n),
	.rst_fifo(W_FIFO_Rst || srst || W_PXIE_Rst_fifo),
	.rst_serdes(W_rst3_n && W_Logic3_Rst_n && W_PXIE_Rstn_serdes),
	.dds_clk(W_clk_250mhz),
	.dci_clk(W_DAC1_DCO),
	.dci_clk_d4(W_DAC1_DCO_DIV2),
	.clk_200mhz(W_clk_20mhz),
	.clk_20mhz(W_clk_20mhz),
//	.dac_locked(dac_locked),
	.dac_locked(1'b1),
	.I_offset(W_offset2),
	.dds_in_b0(DDS_DataProcess_ch2_data[15:0]),
	.dds_in_b1(DDS_DataProcess_ch2_data[31:16]),
	.dds_in_b2(DDS_DataProcess_ch2_data[47:32]),
	.dds_in_b3(DDS_DataProcess_ch2_data[63:48]),
	.dds_in_b4(DDS_DataProcess_ch2_data[79:64]),
	.dds_in_b5(DDS_DataProcess_ch2_data[95:80]),
	.dds_in_b6(DDS_DataProcess_ch2_data[111:96]),
	.dds_in_b7(DDS_DataProcess_ch2_data[127:112]),
	.db_0_p(O_DAC2_DA_P),
	.db_0_n(O_DAC2_DA_N),
	.db_1_p(O_DAC2_DB_P),
	.db_1_n(O_DAC2_DB_N),
	.wr_ena(DDS_DataProcess_ch2_data_vld),
	.O_trig(),

	.W_serdes_even_data(ch2_serdes_even_data),
	.W_serdes_odd_data(ch2_serdes_odd_data)
	);
	

ad9739_data_interface DAC3_Data_Interface(
	.rst_n(W_rst2_n && W_Logic2_Rst_n),
	.rst_fifo(W_FIFO_Rst || srst || W_PXIE_Rst_fifo),
	.rst_serdes(W_rst3_n && W_Logic3_Rst_n && W_PXIE_Rstn_serdes),
	.dds_clk(W_clk_250mhz),
	.dci_clk(W_DAC1_DCO),
	.dci_clk_d4(W_DAC1_DCO_DIV2),
	.clk_200mhz(W_clk_20mhz),
	.clk_20mhz(W_clk_20mhz),
//	.dac_locked(dac_locked),
	.dac_locked(1'b1),
	.I_offset(W_offset3),
	.dds_in_b0(DDS_DataProcess_ch3_data[15:0]),
	.dds_in_b1(DDS_DataProcess_ch3_data[31:16]),
	.dds_in_b2(DDS_DataProcess_ch3_data[47:32]),
	.dds_in_b3(DDS_DataProcess_ch3_data[63:48]),
	.dds_in_b4(DDS_DataProcess_ch3_data[79:64]),
	.dds_in_b5(DDS_DataProcess_ch3_data[95:80]),
	.dds_in_b6(DDS_DataProcess_ch3_data[111:96]),
	.dds_in_b7(DDS_DataProcess_ch3_data[127:112]),
	.db_0_p(O_DAC3_DA_P),
	.db_0_n(O_DAC3_DA_N),
	.db_1_p(O_DAC3_DB_P),
	.db_1_n(O_DAC3_DB_N),
	.wr_ena(DDS_DataProcess_ch3_data_vld),
	.O_trig(),

	.W_serdes_even_data(ch3_serdes_even_data),
	.W_serdes_odd_data(ch3_serdes_odd_data)
		);


ad9739_data_interface DAC4_Data_Interface(
	.rst_n(W_rst2_n && W_Logic2_Rst_n),
	.rst_fifo(W_FIFO_Rst || srst || W_PXIE_Rst_fifo),
	.rst_serdes(W_rst3_n && W_Logic3_Rst_n && W_PXIE_Rstn_serdes),
	.dds_clk(W_clk_250mhz),
	.dci_clk(W_DAC1_DCO),
	.dci_clk_d4(W_DAC1_DCO_DIV2),
	.clk_200mhz(W_clk_20mhz),
	.clk_20mhz(W_clk_20mhz),
//	.dac_locked(dac_locked),
	.dac_locked(1'b1),
	.I_offset(W_offset4),
	.dds_in_b0(DDS_DataProcess_ch4_data[15:0]),
	.dds_in_b1(DDS_DataProcess_ch4_data[31:16]),
	.dds_in_b2(DDS_DataProcess_ch4_data[47:32]),
	.dds_in_b3(DDS_DataProcess_ch4_data[63:48]),
	.dds_in_b4(DDS_DataProcess_ch4_data[79:64]),
	.dds_in_b5(DDS_DataProcess_ch4_data[95:80]),
	.dds_in_b6(DDS_DataProcess_ch4_data[111:96]),
	.dds_in_b7(DDS_DataProcess_ch4_data[127:112]),
	.db_0_p(O_DAC4_DA_P),
	.db_0_n(O_DAC4_DA_N),
	.db_1_p(O_DAC4_DB_P),
	.db_1_n(O_DAC4_DB_N),
	.wr_ena(DDS_DataProcess_ch4_data_vld),
	.O_trig(),

	.W_serdes_even_data(ch4_serdes_even_data),
	.W_serdes_odd_data(ch4_serdes_odd_data)
		);

wire flag_12;
wire flag_13;
wire flag_14;
wire flag_23;
wire flag_24;
wire flag_34;

// compare_data compare_data_0(
// 	.dci_clk_d4(W_DAC1_DCO_DIV2),
// 	.I_Rst_n(W_rst2_n && W_Logic2_Rst_n),

// 	.ch1_serdes_even_data(ch1_serdes_even_data),
// 	.ch1_serdes_odd_data(ch1_serdes_odd_data),

// 	.ch2_serdes_even_data(ch2_serdes_even_data),
// 	.ch2_serdes_odd_data(ch2_serdes_odd_data),

// 	.ch3_serdes_even_data(ch3_serdes_even_data),
// 	.ch3_serdes_odd_data(ch3_serdes_odd_data),

// 	.ch4_serdes_even_data(ch4_serdes_even_data),
// 	.ch4_serdes_odd_data(ch4_serdes_odd_data),

// 	.DDS_DataProcess_ch1_data_vld(DDS_DataProcess_ch1_data_vld),
// 	.DDS_DataProcess_ch2_data_vld(DDS_DataProcess_ch2_data_vld),
// 	.DDS_DataProcess_ch3_data_vld(DDS_DataProcess_ch3_data_vld),
// 	.DDS_DataProcess_ch4_data_vld(DDS_DataProcess_ch4_data_vld),

// 	.flag_12(flag_12),
// 	.flag_13(flag_13),
// 	.flag_14(flag_14),
// 	.flag_23(flag_23),
// 	.flag_24(flag_24),
// 	.flag_34(flag_34)

// );
	
Pll_lmk04803 Pll_Lmk04803(
    .I_Clk(W_clk_20mhz)	,
	.I_Rst_n(W_rst_n && W_Logic1_Rst_n)	,
	.I_Trig(W_Pll_Trig && W_PLL_Rst_n)	,
	.O_uWire_LE(O_LMK_LE)	,
	.O_uWire_CLK(O_LMK_CLK)	,
	.O_uWire_DATA(O_LMK_DATA)	,
	.O_flag()
);	


// ila_16 ila_16 (
// 	.clk(W_clk_250mhz), // input wire clk

// 	.probe0(W_dac1_tx_id), // input wire [23:0]  probe0  
// 	.probe1(W_dac2_tx_id), // input wire [23:0]  probe1 
// 	.probe2(W_dac3_tx_id), // input wire [23:0]  probe2 
// 	.probe3(W_dac4_tx_id), // input wire [23:0]  probe3 
// 	.probe4(ch1_data), // input wire [127:0]  probe4 
// 	.probe5(ch2_data), // input wire [127:0]  probe5 
// 	.probe6(ch3_data), // input wire [127:0]  probe6 
// 	.probe7(ch4_data) // input wire [127:0]  probe7
// );


wire[127:0]	h2c_tdata			;
wire		h2c_tlast			;
wire		h2c_tvalid			;
wire[15:0]	h2c_tkeep			;
wire		c2h_tready			;
wire		W_pxie_user_clk		;

wire [MAXIMUM_WIDTH_OF_EACH_CH-1:0]	W_dac1_tx_id	;
wire 								W_dac1_tx_ena	;
wire [MAXIMUM_WIDTH_OF_EACH_CH-1:0]	W_dac2_tx_id	;
wire 								W_dac2_tx_ena	;
wire [MAXIMUM_WIDTH_OF_EACH_CH-1:0]	W_dac3_tx_id	;
wire 								W_dac3_tx_ena	;
wire [MAXIMUM_WIDTH_OF_EACH_CH-1:0]	W_dac4_tx_id	;
wire 								W_dac4_tx_ena	;

wire [23:0] W_dac1_tx_delay;
wire [23:0] W_dac2_tx_delay;
wire [23:0] W_dac3_tx_delay;
wire [23:0] W_dac4_tx_delay;

wire [MAXIMUM_WIDTH_OF_EACH_CH-1:0] W_AWG_CH1_WAVENUM;
wire [MAXIMUM_WIDTH_OF_EACH_CH-1:0] W_AWG_CH2_WAVENUM;
wire [MAXIMUM_WIDTH_OF_EACH_CH-1:0] W_AWG_CH3_WAVENUM;
wire [MAXIMUM_WIDTH_OF_EACH_CH-1:0] W_AWG_CH4_WAVENUM;

wire [23:0]	W_AWG_CH1_INITIAL_PHASE;
wire [23:0]	W_AWG_CH2_INITIAL_PHASE;
wire [23:0]	W_AWG_CH3_INITIAL_PHASE;
wire [23:0]	W_AWG_CH4_INITIAL_PHASE;

wire W_AWG_CH1_INITIAL_PHASE_vld;
wire W_AWG_CH2_INITIAL_PHASE_vld;
wire W_AWG_CH3_INITIAL_PHASE_vld;
wire W_AWG_CH4_INITIAL_PHASE_vld;

wire [26:0] W_AWG_CH1_PINC      ;
wire        W_AWG_CH1_PINC_vld  ;
wire [26:0] W_AWG_CH2_PINC      ;
wire        W_AWG_CH2_PINC_vld  ;
wire [26:0] W_AWG_CH3_PINC      ;
wire        W_AWG_CH3_PINC_vld  ;
wire [26:0] W_AWG_CH4_PINC      ;
wire        W_AWG_CH4_PINC_vld  ;

wire		W_AWG_WORK_MODE		;

wire W_PXIE_AWG_TRIG	;
wire [3:0] W_TRIG_VALID	;

wire W_VIO_AWG_TRIG;

wire [6:0]	PXIE_RAM1_State				;
wire [6:0]	PXIE_RAM2_State				;
wire [6:0]	PXIE_RAM3_State				;
wire [6:0]	PXIE_RAM4_State				;

wire [3:0]	Delay_RAM1_State			;
wire [3:0]	Delay_RAM2_State			;
wire [3:0]	Delay_RAM3_State			;
wire [3:0]	Delay_RAM4_State			;

wire 			data_vld_out	;
wire [127:0]	data_out		;

wire [3:0]		IIR_on			;

//复位信号低电平有效
wire [3:0]		IIR_reset		;

//1X滤波参数
wire   [15:0]  alpha_in_1X                         ;

wire   [15:0]  complement_alpha_06_1X              ;
wire   [15:0]  complement_alpha_05_1X              ;
wire   [15:0]  complement_alpha_04_1X              ;
wire   [15:0]  complement_alpha_03_1X              ;
wire   [15:0]  complement_alpha_02_1X              ;
wire   [15:0]  complement_alpha_01_1X              ;
wire   [15:0]  complement_alpha_00_1X              ;

wire   [15:0]  alpha_complement_alpha_05_1X        ;
wire   [15:0]  alpha_complement_alpha_04_1X        ;
wire   [15:0]  alpha_complement_alpha_03_1X        ;
wire   [15:0]  alpha_complement_alpha_02_1X        ;
wire   [15:0]  alpha_complement_alpha_01_1X        ;
wire   [15:0]  alpha_complement_alpha_00_1X        ;

wire   [15:0]  k_in_1X                             ;
wire   [15:0]  complement_k_in_1X                  ;

//2X滤波参数
wire   [15:0]  alpha_in_2X                         ;

wire   [15:0]  complement_alpha_06_2X              ;
wire   [15:0]  complement_alpha_05_2X              ;
wire   [15:0]  complement_alpha_04_2X              ;
wire   [15:0]  complement_alpha_03_2X              ;
wire   [15:0]  complement_alpha_02_2X              ;
wire   [15:0]  complement_alpha_01_2X              ;
wire   [15:0]  complement_alpha_00_2X              ;

wire   [15:0]  alpha_complement_alpha_05_2X        ;
wire   [15:0]  alpha_complement_alpha_04_2X        ;
wire   [15:0]  alpha_complement_alpha_03_2X        ;
wire   [15:0]  alpha_complement_alpha_02_2X        ;
wire   [15:0]  alpha_complement_alpha_01_2X        ;
wire   [15:0]  alpha_complement_alpha_00_2X        ;

wire   [15:0]  k_in_2X                             ;
wire   [15:0]  complement_k_in_2X                  ;

//3X滤波参数
wire   [15:0]  alpha_in_3X                         ;

wire   [15:0]  complement_alpha_06_3X              ;
wire   [15:0]  complement_alpha_05_3X              ;
wire   [15:0]  complement_alpha_04_3X              ;
wire   [15:0]  complement_alpha_03_3X              ;
wire   [15:0]  complement_alpha_02_3X              ;
wire   [15:0]  complement_alpha_01_3X              ;
wire   [15:0]  complement_alpha_00_3X              ;

wire   [15:0]  alpha_complement_alpha_05_3X        ;
wire   [15:0]  alpha_complement_alpha_04_3X        ;
wire   [15:0]  alpha_complement_alpha_03_3X        ;
wire   [15:0]  alpha_complement_alpha_02_3X        ;
wire   [15:0]  alpha_complement_alpha_01_3X        ;
wire   [15:0]  alpha_complement_alpha_00_3X        ;

wire   [15:0]  k_in_3X                             ;
wire   [15:0]  complement_k_in_3X                  ;

//4X滤波参数
wire   [15:0]  alpha_in_4X                         ;

wire   [15:0]  complement_alpha_06_4X              ;
wire   [15:0]  complement_alpha_05_4X              ;
wire   [15:0]  complement_alpha_04_4X              ;
wire   [15:0]  complement_alpha_03_4X              ;
wire   [15:0]  complement_alpha_02_4X              ;
wire   [15:0]  complement_alpha_01_4X              ;
wire   [15:0]  complement_alpha_00_4X              ;

wire   [15:0]  alpha_complement_alpha_05_4X        ;
wire   [15:0]  alpha_complement_alpha_04_4X        ;
wire   [15:0]  alpha_complement_alpha_03_4X        ;
wire   [15:0]  alpha_complement_alpha_02_4X        ;
wire   [15:0]  alpha_complement_alpha_01_4X        ;
wire   [15:0]  alpha_complement_alpha_00_4X        ;

wire   [15:0]  k_in_4X                             ;
wire   [15:0]  complement_k_in_4X                  ;

//5X滤波参数
wire   [15:0]  alpha_in_5X                         ;

wire   [15:0]  complement_alpha_06_5X              ;
wire   [15:0]  complement_alpha_05_5X              ;
wire   [15:0]  complement_alpha_04_5X              ;
wire   [15:0]  complement_alpha_03_5X              ;
wire   [15:0]  complement_alpha_02_5X              ;
wire   [15:0]  complement_alpha_01_5X              ;
wire   [15:0]  complement_alpha_00_5X              ;

wire   [15:0]  alpha_complement_alpha_05_5X        ;
wire   [15:0]  alpha_complement_alpha_04_5X        ;
wire   [15:0]  alpha_complement_alpha_03_5X        ;
wire   [15:0]  alpha_complement_alpha_02_5X        ;
wire   [15:0]  alpha_complement_alpha_01_5X        ;
wire   [15:0]  alpha_complement_alpha_00_5X        ;

wire   [15:0]  k_in_5X                             ;
wire   [15:0]  complement_k_in_5X                  ;

DDS_DataProcess DDS_DataProcess(
    .I_clk_250m(W_clk_250mhz),
    .I_rst_n(W_rst2_n && W_Logic2_Rst_n),

    .AWG_CH1_PINC(W_AWG_CH1_PINC),
    .AWG_CH1_PINC_vld(W_AWG_CH1_PINC_vld),
    .AWG_CH2_PINC(W_AWG_CH2_PINC),
    .AWG_CH2_PINC_vld(W_AWG_CH2_PINC_vld),
    .AWG_CH3_PINC(W_AWG_CH3_PINC),
    .AWG_CH3_PINC_vld(W_AWG_CH3_PINC_vld),
    .AWG_CH4_PINC(W_AWG_CH4_PINC),
    .AWG_CH4_PINC_vld(W_AWG_CH4_PINC_vld),

	.AWG_WORK_MODE(W_AWG_WORK_MODE),

	.I_trig_valid(W_TRIG_VALID),

	.I_DAC1_RAM_data_vld(W_DAC1_RAM_DATA_VLD) ,
	.I_DAC1_RAM_data(W_DAC1_RAM_DATA)     ,
	.I_DAC2_RAM_data_vld(W_DAC2_RAM_DATA_VLD) ,
	.I_DAC2_RAM_data(W_DAC2_RAM_DATA)     ,
	.I_DAC3_RAM_data_vld(W_DAC3_RAM_DATA_VLD) ,
	.I_DAC3_RAM_data(W_DAC3_RAM_DATA)     ,
	.I_DAC4_RAM_data_vld(W_DAC4_RAM_DATA_VLD) ,
	.I_DAC4_RAM_data(W_DAC4_RAM_DATA)     ,

    .DDS_DataProcess_ch1_data_vld(DDS_DataProcess_ch1_data_vld),
    .DDS_DataProcess_ch1_data(DDS_DataProcess_ch1_data),
	.DDS_DataProcess_ch2_data_vld(DDS_DataProcess_ch2_data_vld),
    .DDS_DataProcess_ch2_data(DDS_DataProcess_ch2_data),
	.DDS_DataProcess_ch3_data_vld(DDS_DataProcess_ch3_data_vld),
    .DDS_DataProcess_ch3_data(DDS_DataProcess_ch3_data),
	.DDS_DataProcess_ch4_data_vld(DDS_DataProcess_ch4_data_vld),
    .DDS_DataProcess_ch4_data(DDS_DataProcess_ch4_data),

	.Config_Group1_ram(Config_Group1_ram),
	.Config_Group1_port(Config_Group1_port),
	.Config_Group1_mixer_on(Config_Group1_mixer_on),
	.Config_Group2_ram(Config_Group2_ram),
	.Config_Group2_port(Config_Group2_port),
	.Config_Group2_mixer_on(Config_Group2_mixer_on),

	.CH1_INITIAL_PHASE(W_AWG_CH1_INITIAL_PHASE),
	.CH1_INITIAL_PHASE_vld(W_AWG_CH1_INITIAL_PHASE_vld),
	.CH2_INITIAL_PHASE(W_AWG_CH2_INITIAL_PHASE),
	.CH2_INITIAL_PHASE_vld(W_AWG_CH2_INITIAL_PHASE_vld),
	.CH3_INITIAL_PHASE(W_AWG_CH3_INITIAL_PHASE),
	.CH3_INITIAL_PHASE_vld(W_AWG_CH3_INITIAL_PHASE_vld),
	.CH4_INITIAL_PHASE(W_AWG_CH4_INITIAL_PHASE),
	.CH4_INITIAL_PHASE_vld(W_AWG_CH4_INITIAL_PHASE_vld),
	
	.PXIE_RAM1_State(PXIE_RAM1_State),
	.PXIE_RAM2_State(PXIE_RAM2_State),
	.PXIE_RAM3_State(PXIE_RAM3_State),
	.PXIE_RAM4_State(PXIE_RAM4_State),

	.Delay_RAM1_State(Delay_RAM1_State),
	.Delay_RAM2_State(Delay_RAM2_State),
	.Delay_RAM3_State(Delay_RAM3_State),
	.Delay_RAM4_State(Delay_RAM4_State),

	.Group1_Delta_Phase_I(Group1_Delta_Phase_I),
	.Group1_Delta_Phase_Q(Group1_Delta_Phase_Q),
	.Group1_Delta_Phase_vld(Group1_Delta_Phase_vld),

	.Group2_Delta_Phase_I(Group2_Delta_Phase_I),
	.Group2_Delta_Phase_Q(Group2_Delta_Phase_Q),
	.Group2_Delta_Phase_vld(Group2_Delta_Phase_vld),

	.Group1_Epsilon_Amp_I(Group1_Epsilon_Amp_I),
	.Group1_Epsilon_Amp_Q(Group1_Epsilon_Amp_Q),
	.Group2_Epsilon_Amp_I(Group2_Epsilon_Amp_I),
	.Group2_Epsilon_Amp_Q(Group2_Epsilon_Amp_Q)

    );

Trig_Delay_MDL Trig_Delay_MDL(
	. I_clk_250mhz(W_clk_250mhz),
	. I_rst_n(W_rst2_n && W_Logic2_Rst_n),

	.AWG_CH1_WAVENUM(W_AWG_CH1_WAVENUM),
	.AWG_CH2_WAVENUM(W_AWG_CH2_WAVENUM),
	.AWG_CH3_WAVENUM(W_AWG_CH3_WAVENUM),
	.AWG_CH4_WAVENUM(W_AWG_CH4_WAVENUM),

	.I_trig(W_PXIE_STAR || W_PXIE_AWG_TRIG || W_VIO_AWG_TRIG),

	.O_dac1_tx_id(W_dac1_tx_id),
	.O_dac1_tx_ena(W_dac1_tx_ena),
    .I_dac1_tx_delay(W_dac1_tx_delay),

	.O_dac2_tx_id(W_dac2_tx_id),
	.O_dac2_tx_ena(W_dac2_tx_ena),
    .I_dac2_tx_delay(W_dac2_tx_delay),

	.O_dac3_tx_id(W_dac3_tx_id),
	.O_dac3_tx_ena(W_dac3_tx_ena),
    .I_dac3_tx_delay(W_dac3_tx_delay),

	.O_dac4_tx_id(W_dac4_tx_id),
	.O_dac4_tx_ena(W_dac4_tx_ena),
    .I_dac4_tx_delay(W_dac4_tx_delay),

	.R_State1(Delay_RAM1_State),
	.R_State2(Delay_RAM2_State),
	.R_State3(Delay_RAM3_State),
	.R_State4(Delay_RAM4_State)

    );	

xilinx_dma_pcie_ep inst0_pcie(
	.pci_exp_txp(pci_exp_txp),
	.pci_exp_txn(pci_exp_txn),
	.pci_exp_rxp(pci_exp_rxp),
	.pci_exp_rxn(pci_exp_rxn),
	.sys_clk_p(sys_clk_p),
	.sys_clk_n(sys_clk_n),
	.sys_rst_n(sys_rst_n),
	.m_axis_c2h_tdata_0(c2h_tdata),
	.m_axis_c2h_tlast_0(c2h_tlast),
	.m_axis_c2h_tvalid_0(c2h_tvalid),
	.m_axis_c2h_tready_0(c2h_tready),
	.m_axis_c2h_tkeep_0(c2h_tkeep),
	.m_axis_h2c_tdata_0(h2c_tdata),
	.m_axis_h2c_tlast_0(h2c_tlast),
	.m_axis_h2c_tvalid_0(h2c_tvalid),
	.m_axis_h2c_tready_0(1'b1),
	.m_axis_h2c_tkeep_0(h2c_tkeep),
	.user_clk(W_pxie_user_clk)
	);



PXIE_RX_DATA  inst_pxie_rx_data(
	.I_PXIE_CLK(W_pxie_user_clk)	,
	.I_PXIE_DATA(h2c_tdata)	,
	.I_PXIE_DATA_VLD(h2c_tvalid)	,
	.I_Rst_n(W_rst2_n && W_Logic2_Rst_n)	,
	.I_CLK_250mhz(W_clk_250mhz),

	.I_dac1_tx_id(W_dac1_tx_id)	,
	.I_dac1_tx_ena(W_dac1_tx_ena)	,
//    .O_dac1_tx_delay(W_dac1_tx_delay),

	.I_dac2_tx_id(W_dac2_tx_id)	,
	.I_dac2_tx_ena(W_dac2_tx_ena)	,
//    .O_dac2_tx_delay(W_dac2_tx_delay),

	.I_dac3_tx_id(W_dac3_tx_id)	,
	.I_dac3_tx_ena(W_dac3_tx_ena)	,
//    .O_dac3_tx_delay(W_dac3_tx_delay),

	.I_dac4_tx_id(W_dac4_tx_id)	,
	.I_dac4_tx_ena(W_dac4_tx_ena)	,
//    .O_dac4_tx_delay(W_dac4_tx_delay),

	.AWG_CH1_WAVENUM(W_AWG_CH1_WAVENUM),
	.AWG_CH2_WAVENUM(W_AWG_CH2_WAVENUM),
	.AWG_CH3_WAVENUM(W_AWG_CH3_WAVENUM),
	.AWG_CH4_WAVENUM(W_AWG_CH4_WAVENUM),

	.AWG_CH1_INITIAL_PHASE(W_AWG_CH1_INITIAL_PHASE),
	.AWG_CH1_INITIAL_PHASE_vld(W_AWG_CH1_INITIAL_PHASE_vld),
	.AWG_CH2_INITIAL_PHASE(W_AWG_CH2_INITIAL_PHASE),
	.AWG_CH2_INITIAL_PHASE_vld(W_AWG_CH2_INITIAL_PHASE_vld),
	.AWG_CH3_INITIAL_PHASE(W_AWG_CH3_INITIAL_PHASE),
	.AWG_CH3_INITIAL_PHASE_vld(W_AWG_CH3_INITIAL_PHASE_vld),
	.AWG_CH4_INITIAL_PHASE(W_AWG_CH4_INITIAL_PHASE),
	.AWG_CH4_INITIAL_PHASE_vld(W_AWG_CH4_INITIAL_PHASE_vld),

    .AWG_CH1_PINC(W_AWG_CH1_PINC),
    .AWG_CH1_PINC_vld(W_AWG_CH1_PINC_vld),
    .AWG_CH2_PINC(W_AWG_CH2_PINC),
    .AWG_CH2_PINC_vld(W_AWG_CH2_PINC_vld),
    .AWG_CH3_PINC(W_AWG_CH3_PINC),
    .AWG_CH3_PINC_vld(W_AWG_CH3_PINC_vld),
    .AWG_CH4_PINC(W_AWG_CH4_PINC),
    .AWG_CH4_PINC_vld(W_AWG_CH4_PINC_vld),

	.AWG_WORK_MODE(W_AWG_WORK_MODE),

	.O_DAC1_RAM_data_vld(W_DAC1_RAM_DATA_VLD),
	.O_DAC1_RAM_data(W_DAC1_RAM_DATA),
	.O_DAC2_RAM_data_vld(W_DAC2_RAM_DATA_VLD),
	.O_DAC2_RAM_data(W_DAC2_RAM_DATA),
	.O_DAC3_RAM_data_vld(W_DAC3_RAM_DATA_VLD),
	.O_DAC3_RAM_data(W_DAC3_RAM_DATA),
	.O_DAC4_RAM_data_vld(W_DAC4_RAM_DATA_VLD),
	.O_DAC4_RAM_data(W_DAC4_RAM_DATA),

	.Config_Group1_ram(Config_Group1_ram),
	.Config_Group1_port(Config_Group1_port),
	.Config_Group1_mixer_on(Config_Group1_mixer_on),
	.Config_Group2_ram(Config_Group2_ram),
	.Config_Group2_port(Config_Group2_port),
	.Config_Group2_mixer_on(Config_Group2_mixer_on),

	.O_Rst(W_PXIE_Rst),
	.O_Rst_vld(W_PXIE_Rst_vld),

	.R_offset1(W_offset1),
	.R_offset2(W_offset2),
	.R_offset3(W_offset3),
	.R_offset4(W_offset4),

	.O_trig(W_PXIE_AWG_TRIG),
	.O_trig_valid(W_TRIG_VALID),

	.R_RAM1_State(PXIE_RAM1_State),
	.R_RAM2_State(PXIE_RAM2_State),
	.R_RAM3_State(PXIE_RAM3_State),
	.R_RAM4_State(PXIE_RAM4_State),

	//1X婊ゆ尝鍙傛暟
	.alpha_in_1X(alpha_in_1X),

	.complement_alpha_06_1X(complement_alpha_06_1X),
	.complement_alpha_05_1X(complement_alpha_05_1X),
	.complement_alpha_04_1X(complement_alpha_04_1X),
	.complement_alpha_03_1X(complement_alpha_03_1X),
	.complement_alpha_02_1X(complement_alpha_02_1X),
	.complement_alpha_01_1X(complement_alpha_01_1X),
	.complement_alpha_00_1X(complement_alpha_00_1X),

	.alpha_complement_alpha_05_1X(alpha_complement_alpha_05_1X),
	.alpha_complement_alpha_04_1X(alpha_complement_alpha_04_1X),
	.alpha_complement_alpha_03_1X(alpha_complement_alpha_03_1X),
	.alpha_complement_alpha_02_1X(alpha_complement_alpha_02_1X),
	.alpha_complement_alpha_01_1X(alpha_complement_alpha_01_1X),
	.alpha_complement_alpha_00_1X(alpha_complement_alpha_00_1X),

	.k_in_1X(k_in_1X),
	.complement_k_in_1X(complement_k_in_1X),

	//2X婊ゆ尝鍙傛暟
	.alpha_in_2X(alpha_in_2X),

	.complement_alpha_06_2X(complement_alpha_06_2X),
	.complement_alpha_05_2X(complement_alpha_05_2X),
	.complement_alpha_04_2X(complement_alpha_04_2X),
	.complement_alpha_03_2X(complement_alpha_03_2X),
	.complement_alpha_02_2X(complement_alpha_02_2X),
	.complement_alpha_01_2X(complement_alpha_01_2X),
	.complement_alpha_00_2X(complement_alpha_00_2X),

	.alpha_complement_alpha_05_2X(alpha_complement_alpha_05_2X),
	.alpha_complement_alpha_04_2X(alpha_complement_alpha_04_2X),
	.alpha_complement_alpha_03_2X(alpha_complement_alpha_03_2X),
	.alpha_complement_alpha_02_2X(alpha_complement_alpha_02_2X),
	.alpha_complement_alpha_01_2X(alpha_complement_alpha_01_2X),
	.alpha_complement_alpha_00_2X(alpha_complement_alpha_00_2X),

	.k_in_2X(k_in_2X),
	.complement_k_in_2X(complement_k_in_2X),

	//3X婊ゆ尝鍙傛暟
	.alpha_in_3X(alpha_in_3X),

	.complement_alpha_06_3X(complement_alpha_06_3X),
	.complement_alpha_05_3X(complement_alpha_05_3X),
	.complement_alpha_04_3X(complement_alpha_04_3X),
	.complement_alpha_03_3X(complement_alpha_03_3X),
	.complement_alpha_02_3X(complement_alpha_02_3X),
	.complement_alpha_01_3X(complement_alpha_01_3X),
	.complement_alpha_00_3X(complement_alpha_00_3X),

	.alpha_complement_alpha_05_3X(alpha_complement_alpha_05_3X),
	.alpha_complement_alpha_04_3X(alpha_complement_alpha_04_3X),
	.alpha_complement_alpha_03_3X(alpha_complement_alpha_03_3X),
	.alpha_complement_alpha_02_3X(alpha_complement_alpha_02_3X),
	.alpha_complement_alpha_01_3X(alpha_complement_alpha_01_3X),
	.alpha_complement_alpha_00_3X(alpha_complement_alpha_00_3X),

	.k_in_3X(k_in_3X),
	.complement_k_in_3X(complement_k_in_3X),

	//4X婊ゆ尝鍙傛暟
	.alpha_in_4X(alpha_in_4X),

	.complement_alpha_06_4X(complement_alpha_06_4X),
	.complement_alpha_05_4X(complement_alpha_05_4X),
	.complement_alpha_04_4X(complement_alpha_04_4X),
	.complement_alpha_03_4X(complement_alpha_03_4X),
	.complement_alpha_02_4X(complement_alpha_02_4X),
	.complement_alpha_01_4X(complement_alpha_01_4X),
	.complement_alpha_00_4X(complement_alpha_00_4X),

	.alpha_complement_alpha_05_4X(alpha_complement_alpha_05_4X),
	.alpha_complement_alpha_04_4X(alpha_complement_alpha_04_4X),
	.alpha_complement_alpha_03_4X(alpha_complement_alpha_03_4X),
	.alpha_complement_alpha_02_4X(alpha_complement_alpha_02_4X),
	.alpha_complement_alpha_01_4X(alpha_complement_alpha_01_4X),
	.alpha_complement_alpha_00_4X(alpha_complement_alpha_00_4X),

	.k_in_4X(k_in_4X),
	.complement_k_in_4X(complement_k_in_4X),

	//5X婊ゆ尝鍙傛暟
	.alpha_in_5X(alpha_in_5X),

	.complement_alpha_06_5X(complement_alpha_06_5X),
	.complement_alpha_05_5X(complement_alpha_05_5X),
	.complement_alpha_04_5X(complement_alpha_04_5X),
	.complement_alpha_03_5X(complement_alpha_03_5X),
	.complement_alpha_02_5X(complement_alpha_02_5X),
	.complement_alpha_01_5X(complement_alpha_01_5X),
	.complement_alpha_00_5X(complement_alpha_00_5X),

	.alpha_complement_alpha_05_5X(alpha_complement_alpha_05_5X),
	.alpha_complement_alpha_04_5X(alpha_complement_alpha_04_5X),
	.alpha_complement_alpha_03_5X(alpha_complement_alpha_03_5X),
	.alpha_complement_alpha_02_5X(alpha_complement_alpha_02_5X),
	.alpha_complement_alpha_01_5X(alpha_complement_alpha_01_5X),
	.alpha_complement_alpha_00_5X(alpha_complement_alpha_00_5X),

	.k_in_5X(k_in_5X),
	.complement_k_in_5X(complement_k_in_5X),

	.IIR_on(IIR_on),
	.IIR_reset(IIR_reset),

	.Group1_Delta_Phase_I(Group1_Delta_Phase_I),
	.Group1_Delta_Phase_Q(Group1_Delta_Phase_Q),
	.Group1_Delta_Phase_vld(Group1_Delta_Phase_vld),

	.Group2_Delta_Phase_I(Group2_Delta_Phase_I),
	.Group2_Delta_Phase_Q(Group2_Delta_Phase_Q),
	.Group2_Delta_Phase_vld(Group2_Delta_Phase_vld),

	.Group1_Epsilon_Amp_I(Group1_Epsilon_Amp_I),
	.Group1_Epsilon_Amp_Q(Group1_Epsilon_Amp_Q),
	.Group2_Epsilon_Amp_I(Group2_Epsilon_Amp_I),
	.Group2_Epsilon_Amp_Q(Group2_Epsilon_Amp_Q),

	.PXIE_Value_Delay_Dci1(PXIE_Value_Delay_Dci1),
	.PXIE_Value_Delay_Dci2(PXIE_Value_Delay_Dci2),
	.PXIE_Value_Delay_Dci3(PXIE_Value_Delay_Dci3),
	.PXIE_Value_Delay_Dci4(PXIE_Value_Delay_Dci4),

	.PXIE_LOAD(PXIE_LOAD)
	);	

wire WEA_RAM1;
wire WEA_RAM2;
wire WEA_RAM3;
wire WEA_RAM4;

wire [10:0] WRITE_ADDR_RAM1;
wire [10:0] WRITE_ADDR_RAM2;
wire [10:0] WRITE_ADDR_RAM3;
wire [10:0] WRITE_ADDR_RAM4;

wire [23:0] WRITE_DELAY_RAM1;
wire [23:0] WRITE_DELAY_RAM2;
wire [23:0] WRITE_DELAY_RAM3;
wire [23:0] WRITE_DELAY_RAM4;

Delay_RAM inst_delay_ram(
	.I_UART_CLK(W_clk_10mhz)			,
	.I_DELY_CLK(W_clk_250mhz)  			,
	.I_Rst_n(W_rst2_n && W_Logic2_Rst_n),

	.I_WEA_RAM1(WEA_RAM1)  				,
	.I_WEA_RAM2(WEA_RAM2)  				,
	.I_WEA_RAM3(WEA_RAM3)  				,
	.I_WEA_RAM4(WEA_RAM4)  				,
	.I_WRITE_ADDR_RAM1(WRITE_ADDR_RAM1) ,
	.I_WRITE_ADDR_RAM2(WRITE_ADDR_RAM2) ,
	.I_WRITE_ADDR_RAM3(WRITE_ADDR_RAM3) ,
	.I_WRITE_ADDR_RAM4(WRITE_ADDR_RAM4) ,
	.I_WRITE_DELAY_RAM1(WRITE_DELAY_RAM1),
	.I_WRITE_DELAY_RAM2(WRITE_DELAY_RAM2),
	.I_WRITE_DELAY_RAM3(WRITE_DELAY_RAM3),
	.I_WRITE_DELAY_RAM4(WRITE_DELAY_RAM4),

	.I_READ_ADDR_RAM1(W_dac1_tx_id) 	,
	.I_READ_ADDR_RAM2(W_dac2_tx_id) 	,
	.I_READ_ADDR_RAM3(W_dac3_tx_id) 	,
	.I_READ_ADDR_RAM4(W_dac4_tx_id) 	,
	.O_DAC1_DELAY(W_dac1_tx_delay)		,
	.O_DAC2_DELAY(W_dac2_tx_delay)		,
	.O_DAC3_DELAY(W_dac3_tx_delay)		,
	.O_DAC4_DELAY(W_dac4_tx_delay)	
);



UART_RX_DATA inst_uart_rx_data(
	.I_clk_10M(W_clk_10mhz)	,
	.I_rst_n(W_rst2_n && W_Logic2_Rst_n)	,
	.rxb(W_UART_RXB)	,
	.GA(I_PXIE_GA),
	.O_WEA_RAM1(WEA_RAM1),
	.O_WEA_RAM2(WEA_RAM2),
	.O_WEA_RAM3(WEA_RAM3),
	.O_WEA_RAM4(WEA_RAM4),
	.O_WRITE_ADDR_RAM1(WRITE_ADDR_RAM1),
	.O_WRITE_ADDR_RAM2(WRITE_ADDR_RAM2),
	.O_WRITE_ADDR_RAM3(WRITE_ADDR_RAM3),
	.O_WRITE_ADDR_RAM4(WRITE_ADDR_RAM4),
	.O_WRITE_DELAY_RAM1(WRITE_DELAY_RAM1),
	.O_WRITE_DELAY_RAM2(WRITE_DELAY_RAM2),
	.O_WRITE_DELAY_RAM3(WRITE_DELAY_RAM3),
	.O_WRITE_DELAY_RAM4(WRITE_DELAY_RAM4)
);


vio_0 VIO1 (
  .clk(W_clk_20mhz),                  // input wire clk
  .probe_out0(W_rst_n),    // output wire [0 : 0] probe_out0
  .probe_out1(W_Pll_Trig),    // output wire [0 : 0] probe_out1
  .probe_out2(Vio_DAC_rst_n),    // output wire [0 : 0] probe_out2
  .probe_out3(Vio_LMK_Sync),    // output wire [0 : 0] probe_out3
  .probe_out4(Value_Delay_Dci1),    // output wire [8 : 0] probe_out4
  .probe_out5(Value_Delay_Dci2),    // output wire [8 : 0] probe_out5
  .probe_out6(Value_Delay_Dci3),    // output wire [8 : 0] probe_out6
  .probe_out7(LOAD),    // output wire [0 : 0] probe_out7
  .probe_out8(W_Pulse_ena),    // output wire [0 : 0] probe_out8
  .probe_out9(srst),    // output wire [0 : 0] probe_out9
  .probe_out10(Value_Delay_Dci4),  // output wire [8 : 0] probe_out10
  .probe_out11(W_rst2_n),  // output wire [0 : 0] probe_out11
  .probe_out12(Delay_rst),  // output wire [0 : 0] probe_out12
  .probe_out13(W_rst3_n),  // output wire [0 : 0] probe_out13
  .probe_out14(W_rst1_n),  // output wire [0 : 0] probe_out14
  .probe_out15(Vio_rst_n),  // output wire [0 : 0] probe_out15
  .probe_out16(Vio_DAC1_rst_n),  // output wire [0 : 0] probe_out16
  .probe_out17(Vio_DAC2_rst_n),  // output wire [0 : 0] probe_out17
  .probe_out18(Vio_DAC3_rst_n),  // output wire [0 : 0] probe_out18
  .probe_out19(Vio_DAC4_rst_n), // output wire [0 : 0] probe_out19
  .probe_out20(Value_Delay_Trig) // output wire [0 : 0] probe_out19

);


ila_0 ila1 (
	.clk(W_clk_20mhz), // input wire clk
	.probe0(O_LMK_LE), // input wire [0:0]  probe0  
	.probe1(O_LMK_CLK), // input wire [0:0]  probe1 
	.probe2(O_LMK_DATA), // input wire [0:0]  probe2 
	.probe3(W_PXIE_Rstn_dac1), // input wire [0:0]  probe3 
	.probe4(O_LMK_Sync), // input wire [0:0]  probe4
	.probe5(W_PXIE_Rst_fifo), // input wire [0:0]  probe1 
    .probe6(W_Logic1_Rst_n), // input wire [0:0]  probe2 
    .probe7(I_LMK_Holdover), // input wire [0:0]  probe3 
    .probe8(I_LMK_LD), // input wire [0:0]  probe4
	.probe9(W_PXIE_STAR),
	.probe10(I_PXIE_GA)
);


ila_5 ila_pxie (
	.clk(W_pxie_user_clk), // input wire clk


	.probe0(h2c_tdata), // input wire [127:0]  probe0  
	.probe1(h2c_tlast), // input wire [0:0]  probe1 
	.probe2(h2c_tvalid), // input wire [0:0]  probe2 
	.probe3(h2c_tkeep), // input wire [14:0]  probe3 
	.probe4(c2h_tready) // input wire [0:0]  probe4
);


endmodule