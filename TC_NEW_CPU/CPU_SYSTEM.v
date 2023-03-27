`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/06/01 16:02:26
// Design Name:
// Module Name: CPU_SYSTEM
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


module CPU_SYSTEM(
	input 			cpu_clk,
	input 			clk_en,
	input 			pg_reset_b,
	input 			pad_cpu_rst_b,
	input   [31:0] 	pad_vic_int_vld,
	input 			pad_biu_bigend_b,
	input   [1 :0]  nmi_wake_lower,
	input 			pad_yy_scan_mode,
	//Jtag
	input 			pad_had_jtg_tclk,
	input 			pad_had_jtg_trst_b,
	output 			pad_had_jtg_tms_i,
	inout 			i_pad_jtg_tms,
	//i bus
	output  [1:0] 	biu_pad_htrans,
	//sys bus
	input 	[1:0]	pad_biu_hresp,
	input 	[31:0] 	pad_biu_hrdata,
	input 			pad_biu_hready,
	output 			biu_pad_hwrite,
	output 	[31:0]  biu_pad_hwdata,
	output 	[2:0]	biu_pad_hsize,
	output 	[31:0]	biu_pad_haddr,
	output 	[2:0] 	biu_pad_hburst,
	output 	[3:0] 	biu_pad_hprot,
	//Dram
	input           dram0_portb_clk,
	input           dram0_portb_rst,
	input   [15:0]  dram0_portb_wen,
	input           dram0_portb_ren,
	input   [127:0] dram0_portb_din,
	output  [127:0] dram0_portb_dout,
	input   [15:0]  dram0_portb_addr,
	input   [15:0]  dram1_portb_wen,
	input   [127:0] dram1_portb_din,
	output  [127:0] dram1_portb_dout,
	input   [15:0]  dram1_portb_addr,
	//status
	output          status_dram_par_err0,
	output          status_dram_par_err1,
	output          status_dram_par_err2,
	//Iram
	input           prog_wen,
	input   [15:0]  prog_waddr,
	input   [31:0]  prog_wdata,
	output          status_iram_par_err,
	output 	[31:0] 	cpu_pc,
	//
	output  [1 :0]  sysio_pad_lpmd_b,
  output  [31:0]  biu_pad_retire_pc,
  output  biu_pad_retire

    );


//regs//////////////////////////////////////////////////////
reg     [1 :0]  biu_addr;
reg     [1 :0]  biu_size;
reg     [1 :0]  dahbl_addr;
reg 	[1 :0]  dahbl_size;
reg 	[1 :0]  iahbl_addr;
reg 	[1 :0]  iahbl_size;
reg     [31:0]  pad_biu_hrdata_mux;
reg     [31:0]  pad_dahbl_hrdata_mux;
reg 	[31:0]  pad_iahbl_hrdata_mux;
reg 	[63:0]  pad_cpu_sys_cnt;
////////////////////////////////////////////////////////////
//wires/////////////////////////////////////////////////////
wire 				cpu_clk;
wire 				clk_en;
wire 				pad_biu_bigend_b;
wire 	[1 :0] 		sysio_pad_lpmd_b;
wire 	[1 :0] 		nmi_wake_lower;
wire 				pad_yy_scan_mode;
//Adj Freq
wire 				pad_cpu_dfs_req;
//Reset
wire 				cpu_rst;
wire 				had_rst;
wire 				pg_reset_b;
wire 				pad_cpu_rst_b;
wire    [1 :0]  	cpu_pad_soft_rst;
wire 				pad_had_jtg_trst_b;
//CPU monitor
//(*mark_debug = "true"*)wire 	[31:0]		biu_pad_retire_pc;
//(*mark_debug = "true"*)wire            	biu_pad_retire;
wire 				cpu_pad_lockup;
//Debug
wire 				pad_sysio_dbgrq_b;
//Interruption
wire 				pad_cpu_ext_int_b;
wire 	[47:0]pad_clic_int_vld;
wire  [31:0]pad_vic_int_vld;
//Jtag
wire 				had_pad_jtg_tms_oe;
wire 				had_pad_jtg_tms_o;
wire 				pad_had_jtg_tms_i;
wire 				pad_had_jtg_tclk;
wire 				i_pad_jtg_tms;
//SYS bus
wire    [1 :0]		pad_biu_hresp;
wire 				pad_biu_hresp_0;
wire    [2 :0]  	biu_pad_hsize;
wire    [31:0]  	biu_pad_haddr;
wire 				biu_pad_hwrite;
wire 				pad_biu_hready;
wire 	[31:0] 		biu_pad_hwdata;
wire 	[31:0] 		pad_biu_hrdata;
wire 	[1 :0] 		biu_pad_htrans;
wire 	[2:0] 		biu_pad_hburst;
wire 	[3:0] 		biu_pad_hprot;
//Data bus
wire 	[1 :0] 		dahbl_pad_htrans;
wire 	[31:0]		dahbl_pad_haddr;
wire    [2 :0]  	dahbl_pad_hsize;
wire 	[31:0] 		dahbl_pad_hwdata;
wire 				dahbl_pad_hwrite;
wire    [31:0]  	pad_dahbl_hrdata;
wire 				pad_dahbl_hready;
wire 	[1 :0]		pad_dahbl_hresp;
wire 				pad_dahbl_hresp_0;
//Instruction bus
wire 	[1 :0] 		pad_iahbl_hresp;
wire 				pad_iahbl_hresp_0;
wire 				pad_iahbl_hready;
wire 				iahbl_pad_hwrite;
(*mark_debug="true"*)wire 	[1 :0] 		iahbl_pad_htrans;
wire 	[2 :0] 		iahbl_pad_hsize;
(*mark_debug="true"*)wire 	[31:0] 		iahbl_pad_haddr;
(*mark_debug="true"*)wire 	[31:0] 		pad_iahbl_hrdata;
wire  	[31:0] 		iahbl_pad_hwdata;
////////////////////////////////////////////////////////////
//E906//////////////////////////////////////////////////////
assign pad_cpu_ext_int_b = 1'b1;
assign pad_cpu_dfs_req = 0;
assign pad_sysio_dbgrq_b = 1;
assign cpu_pc = biu_pad_retire_pc;
assign pad_clic_int_vld[47:0] = {16'h0,pad_vic_int_vld[31:0]};
assign pad_biu_hresp_0 = pad_biu_hresp[0];
E906_TOP RV_E906_inst(
    // DFT system integration interface
    .pad_yy_icg_scan_en     (1'b0),                     //I
    .pad_yy_scan_mode       (pad_yy_scan_mode),         //I
    .pad_yy_scan_rst_b      (1'b1),                     //I

    // Reset
    .cpu_pad_soft_rst       (cpu_pad_soft_rst),         //O
    .pad_cpu_rst_addr       (32'h0),                    //I
    .pad_cpu_rst_b          (cpu_rst),                  //I
    .pad_had_jtg_trst_b     (pad_had_jtg_trst_b),       //I
    .pad_had_rst_b          (had_rst),                  //I

    // Instruction Lite bus
    .pad_iahbl_hrdata       (pad_iahbl_hrdata_mux),     //I
    .pad_iahbl_hready       (pad_iahbl_hready),         //I
    .pad_iahbl_hresp        (pad_iahbl_hresp_0),        //I
    .pad_bmu_iahbl_base     (12'h000),                  //I
    .pad_bmu_iahbl_mask     (12'he00),                  //I
    .iahbl_pad_haddr        (iahbl_pad_haddr),          //O
    .iahbl_pad_hburst       (),         //O
    .iahbl_pad_hlock        (),         //O
    .iahbl_pad_hprot        (),         //O
    .iahbl_pad_hsize        (iahbl_pad_hsize),          //O
    .iahbl_pad_htrans       (iahbl_pad_htrans),         //O
    .iahbl_pad_hwdata       (iahbl_pad_hwdata),         //O
    .iahbl_pad_hwrite       (iahbl_pad_hwrite),         //O

    // Data Lite bus
    .pad_dahbl_hrdata       (pad_dahbl_hrdata_mux),     //I
    .pad_dahbl_hready       (pad_dahbl_hready),         //I
    .pad_dahbl_hresp        (pad_dahbl_hresp_0),        //I
    .pad_bmu_dahbl_base     (12'h200 ),                 //I
    .pad_bmu_dahbl_mask     (12'he00 ),                 //I
    .dahbl_pad_haddr        (dahbl_pad_haddr),          //O
    .dahbl_pad_hburst       (),         //O
    .dahbl_pad_hlock        (),         //O
    .dahbl_pad_hprot        (),         //O
    .dahbl_pad_hsize        (dahbl_pad_hsize),          //O
    .dahbl_pad_htrans       (dahbl_pad_htrans),         //O
    .dahbl_pad_hwdata       (dahbl_pad_hwdata),         //O
    .dahbl_pad_hwrite       (dahbl_pad_hwrite),         //O

    // Debug
    .pad_sysio_dbgrq_b      (pad_sysio_dbgrq_b),        //I
    .had_pad_jdb_pm         (),         //O

    // Clock
    .pll_core_cpuclk        (cpu_clk),                  //I
    .clk_en                 (1'b1),                     //I

    // System Lite bus
    .biu_pad_haddr          (biu_pad_haddr),            //O
    .biu_pad_hburst         (biu_pad_hburst),           //O
    .biu_pad_hlock          (),         //O
    .biu_pad_hprot          (biu_pad_hprot),            //O
    .biu_pad_hsize          (biu_pad_hsize),            //O
    .biu_pad_htrans         (biu_pad_htrans),           //O
    .biu_pad_hwdata         (biu_pad_hwdata),           //O
    .biu_pad_hwrite         (biu_pad_hwrite),           //O
    .pad_biu_hrdata         (pad_biu_hrdata_mux),       //I
    .pad_biu_hready         (pad_biu_hready),           //I
    .pad_biu_hresp          (pad_biu_hresp_0),          //I

    // Adj Freq
    .pad_cpu_dfs_req        (pad_cpu_dfs_req),          //I
    .cpu_pad_dfs_ack        (),         //O

    // Jtag
    .had_pad_jtg_tms_o      (had_pad_jtg_tms_o),        //O
    .had_pad_jtg_tms_oe     (had_pad_jtg_tms_oe),       //O
    .pad_had_jtg_tclk       (pad_had_jtg_tclk),         //I
    .pad_had_jtg_tms_i      (pad_had_jtg_tms_i),        //I

    // Low Power
    .sysio_pad_lpmd_b       (sysio_pad_lpmd_b),         //O
    .pad_cpu_wakeup_event   (nmi_wake_lower[1]),        //I

    // Interruption
    .pad_cpu_nmi            (nmi_wake_lower[0]),        //I
    .pad_clic_int_vld       (pad_vic_int_vld),         //I
    .pad_cpu_ext_int_b      (pad_cpu_ext_int_b),        //I
    .pad_cpu_sys_cnt        (pad_cpu_sys_cnt),          //I

    // CPU monitor
    .rtu_pad_inst_retire    (biu_pad_retire),           //O
    .rtu_pad_inst_split     (),         //O
    .rtu_pad_retire_pc      (biu_pad_retire_pc),        //O
    // .rtu_pad_wb0_data       (),         //O
    // .rtu_pad_wb0_preg       (),         //O
    // .rtu_pad_wb0_vld        (),         //O
    // .rtu_pad_wb1_data       (),         //O
    // .rtu_pad_wb1_preg       (),         //O
    // .rtu_pad_wb1_vld        (),         //O
    // .rtu_pad_wb_freg        (),         //O
    // .rtu_pad_wb_freg_data   (),         //O
    // .rtu_pad_wb_freg_vld    (),         //O
    .cp0_pad_mcause         (),         //O
    .cp0_pad_mintstatus     (),         //O
    .cp0_pad_mstatus        (),         //O
    .cpu_pad_lockup         (cpu_pad_lockup),           //O
    .lsu_pad_sc_pass        ()          //O

    );
////////////////////////////////////////////////////////////

//reset/////////////////////////////////////////////////////
//E906 demo used pg_reset_b instead of pad_cpu_rst_b.
//Splitted the reset tree of pad_cpu_rst_b and others.
assign cpu_rst = pg_reset_b & (~cpu_pad_lockup) &  (~|cpu_pad_soft_rst);
assign had_rst = pg_reset_b & (~cpu_pad_soft_rst[1]);
////////////////////////////////////////////////////////////

//sys cnt///////////////////////////////////////////////////
always @(posedge cpu_clk or negedge pad_cpu_rst_b)
begin
	if (!pad_cpu_rst_b)
		pad_cpu_sys_cnt[63:0] <= 64'h0;
	else begin
		pad_cpu_sys_cnt[63:0] <= pad_cpu_sys_cnt[63:0] + 1'b1;
	end
end
////////////////////////////////////////////////////////////

// &Force("inout","i_pad_jtg_tms");/////////////////////////
assign i_pad_jtg_tms = had_pad_jtg_tms_oe ? had_pad_jtg_tms_o : 1'bz;
assign pad_had_jtg_tms_i = i_pad_jtg_tms;
////////////////////////////////////////////////////////////

//sys bus///////////////////////////////////////////////////
always@(posedge cpu_clk or negedge pg_reset_b)
begin
    if(!pg_reset_b) begin
      biu_size[1:0] <= 2'h2;
      biu_addr[1:0] <= 2'b0;
    end
    else if((biu_pad_htrans == 2) && (!biu_pad_hwrite) && pad_biu_hready) begin
      biu_size[1:0] <= biu_pad_hsize[1:0];
      biu_addr[1:0] <= biu_pad_haddr[1:0];
    end
end
always@(*)
begin
    case({biu_size[1:0],biu_addr[1:0]})
        4'b0000:pad_biu_hrdata_mux[31:0] = {24'h0,pad_biu_hrdata[7:0]};
        4'b0001:pad_biu_hrdata_mux[31:0] = {16'h0,pad_biu_hrdata[15:8],8'h0};
        4'b0010:pad_biu_hrdata_mux[31:0] = {8'h0,pad_biu_hrdata[23:16],16'h0};
        4'b0011:pad_biu_hrdata_mux[31:0] = {pad_biu_hrdata[31:24],24'h0};
        4'b0100: pad_biu_hrdata_mux[31:0] = {16'h0,pad_biu_hrdata[15:0]};
        4'b0110: pad_biu_hrdata_mux[31:0] = {pad_biu_hrdata[31:16],16'h0};
        4'b1000: pad_biu_hrdata_mux[31:0] = pad_biu_hrdata[31:0];
        default: pad_biu_hrdata_mux[31:0] = 32'h0;
    endcase
end
////////////////////////////////////////////////////////////

//imem bus//////////////////////////////////////////////////
assign pad_iahbl_hresp_0 = pad_iahbl_hresp[0];
always@(posedge cpu_clk or negedge pg_reset_b)
begin
    if(!pg_reset_b) begin
      iahbl_size[1:0] <= 2'h2;
      iahbl_addr[1:0] <= 2'b0;
    end
    else if((iahbl_pad_htrans == 2) && (!iahbl_pad_hwrite) && pad_iahbl_hready) begin
      iahbl_size[1:0] <= iahbl_pad_hsize[1:0];
      iahbl_addr[1:0] <= iahbl_pad_haddr[1:0];
    end
end
always@(*)
begin
    case({iahbl_size[1:0],iahbl_addr[1:0]})
        4'b0000:pad_iahbl_hrdata_mux[31:0] = {24'h0,pad_iahbl_hrdata[7:0]};
        4'b0001:pad_iahbl_hrdata_mux[31:0] = {16'h0,pad_iahbl_hrdata[15:8],8'h0};
        4'b0010:pad_iahbl_hrdata_mux[31:0] = {8'h0,pad_iahbl_hrdata[23:16],16'h0};
        4'b0011:pad_iahbl_hrdata_mux[31:0] = {pad_iahbl_hrdata[31:24],24'h0};
        4'b0100: pad_iahbl_hrdata_mux[31:0] = {16'h0,pad_iahbl_hrdata[15:0]};
        4'b0110: pad_iahbl_hrdata_mux[31:0] = {pad_iahbl_hrdata[31:16],16'h0};
        4'b1000: pad_iahbl_hrdata_mux[31:0] = pad_iahbl_hrdata[31:0];
        default: pad_iahbl_hrdata_mux[31:0] = 32'h0;
    endcase
end
////////////////////////////////////////////////////////////

//imem ctrl/////////////////////////////////////////////////

iahb_mem_ctrl x_iahb_mem_ctrl(
  .lite_mmc_hsel       (iahbl_pad_htrans[1]),
  .lite_yy_haddr       (iahbl_pad_haddr    ),
  .lite_yy_hsize       (iahbl_pad_hsize    ),
  .lite_yy_htrans      (iahbl_pad_htrans   ),
  .lite_yy_hwdata      (iahbl_pad_hwdata   ),
  .lite_yy_hwrite      (iahbl_pad_hwrite   ),
  .mmc_lite_hrdata     (pad_iahbl_hrdata   ),
  .mmc_lite_hready     (pad_iahbl_hready   ),
  .mmc_lite_hresp      (pad_iahbl_hresp    ),
  .pad_biu_bigend_b    (pad_biu_bigend_b   ),
  .pad_cpu_rst_b       (pad_cpu_rst_b      ),
  .pll_core_cpuclk     (cpu_clk            ),
  //.iram_portb_clk      (iram_portb_clk     ),
  //.iram_portb_wen      (iram_portb_wen     ),
  //.iram_portb_din      (iram_portb_din     ),
  //.iram_portb_dout     (iram_portb_dout    ),
  //.iram_portb_addr     (iram_portb_addr    )
  .prog_wen             (prog_wen       ),
  .prog_waddr           (prog_waddr     ),
  .prog_wdata           (prog_wdata     ),
  .iram_par_err         (status_iram_par_err)
	);
////////////////////////////////////////////////////////////

//dmem bus//////////////////////////////////////////////////
assign pad_dahbl_hresp_0 = pad_dahbl_hresp[0];
always@(posedge cpu_clk or negedge pg_reset_b)
begin
    if(!pg_reset_b) begin
      dahbl_size[1:0] <= 2'h2;
      dahbl_addr[1:0] <= 2'b0;
    end
    else if((dahbl_pad_htrans == 2) && (!dahbl_pad_hwrite) && pad_dahbl_hready) begin
      dahbl_size[1:0] <= dahbl_pad_hsize[1:0];
      dahbl_addr[1:0] <= dahbl_pad_haddr[1:0];
    end
end
always@(*)
begin
    case({dahbl_size[1:0],dahbl_addr[1:0]})
        4'b0000:pad_dahbl_hrdata_mux[31:0] = {24'h0,pad_dahbl_hrdata[7:0]};
        4'b0001:pad_dahbl_hrdata_mux[31:0] = {16'h0,pad_dahbl_hrdata[15:8],8'h0};
        4'b0010:pad_dahbl_hrdata_mux[31:0] = {8'h0,pad_dahbl_hrdata[23:16],16'h0};
        4'b0011:pad_dahbl_hrdata_mux[31:0] = {pad_dahbl_hrdata[31:24],24'h0};
        4'b0100: pad_dahbl_hrdata_mux[31:0] = {16'h0,pad_dahbl_hrdata[15:0]};
        4'b0110: pad_dahbl_hrdata_mux[31:0] = {pad_dahbl_hrdata[31:16],16'h0};
        4'b1000: pad_dahbl_hrdata_mux[31:0] = pad_dahbl_hrdata[31:0];
        default: pad_dahbl_hrdata_mux[31:0] = 32'h0;
    endcase
end
////////////////////////////////////////////////////////////

//dmem ctrl/////////////////////////////////////////////////

dahb_mem_ctrl  x_dahb_mem_ctrl (
  .lite_mmc_hsel       (dahbl_pad_htrans[1]),
  .lite_yy_haddr       (dahbl_pad_haddr    ),
  .lite_yy_hsize       (dahbl_pad_hsize    ),
  .lite_yy_htrans      (dahbl_pad_htrans   ),
  .lite_yy_hwdata      (dahbl_pad_hwdata   ),
  .lite_yy_hwrite      (dahbl_pad_hwrite   ),
  .mmc_lite_hrdata     (pad_dahbl_hrdata   ),
  .mmc_lite_hready     (pad_dahbl_hready   ),
  .mmc_lite_hresp      (pad_dahbl_hresp    ),
  .pad_biu_bigend_b    (pad_biu_bigend_b   ),
  .pad_cpu_rst_b       (pad_cpu_rst_b      ),
  .pll_core_cpuclk     (cpu_clk            ),
  .dram0_portb_clk     (dram0_portb_clk    ),
  .dram0_portb_rst     (dram0_portb_rst    ),
  .dram0_portb_wen     (dram0_portb_wen    ),
  .dram0_portb_ren     (dram0_portb_ren    ),
  .dram0_portb_din     (dram0_portb_din    ),
  .dram0_portb_dout    (dram0_portb_dout   ),
  .dram0_portb_addr    (dram0_portb_addr   ),
//  .dram1_portb_clk     (dram1_portb_clk    ),
  .dram1_portb_wen     (dram1_portb_wen    ),
  .dram1_portb_din     (dram1_portb_din    ),
  .dram1_portb_dout    (dram1_portb_dout   ),
  .dram1_portb_addr    (dram1_portb_addr   ),
  .status_dram_par_err0(status_dram_par_err0)   ,
  .status_dram_par_err1(status_dram_par_err1)   ,
  .status_dram_par_err2(status_dram_par_err2)
);
////////////////////////////////////////////////////////////
endmodule
