`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2020/05/19 16:42:29
// Design Name:
// Module Name: top
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


module AQTC_top(

//-----------------------pxie interface--------------

(* DIFF_TERM = "TRUE" *)    input 	I_PXIE_Clk_p,
(* DIFF_TERM = "TRUE" *)    input 	I_PXIE_Clk_n,

    input  [3 : 0]  I_PXIE_Rxp		,
    input  [3 : 0]  I_PXIE_Rxn		,

    input 			I_PXIE_Rst_n	,

	output [3 : 0] 	O_PXIE_Txp		,
    output [3 : 0] 	O_PXIE_Txn		,


//-----------------------trig out---------------------
	output [16:0]	 O_Dstarb_p		,
    output [16:0]	 O_Dstarb_n		,

	output [16:0]	 O_star			,

    input [16:0]	 I_Dstarc_p		,
    input [16:0]	 I_Dstarc_n		,

//	output			TXB_AWG1	,

//-----------------------clk--------------------------
    input       I_SYS_50mhz_p,       //clk from pll
    input       I_SYS_50mhz_n,

    //input       I_SYS1_50mhz_p,       //clk from fanout
    //input       I_SYS1_50mhz_n,

    input       I_LOC_100mhz,
    //control
//-----------------------PLL-------------------------
    output			O_lmk_resetn,
	output			O_lmk_sel,
	output			O_lmk_sclk,			//spi
	output			O_lmk_scs,			//spi
	output			O_lmk_sdio,			//spi
	output			O_lmk_sync,			//sync
	input			I_lmk_st0,			//debug
	input			I_lmk_st1			//debug

    //fanout

	);





wire		W_Clk_10mhz			;
wire		W1_Clk_10mhz		;
wire		W1_Clk_20mhz		;
wire		W_Clk_20mhz			;
wire		W_Clk_125mhz		;
wire		Clk_10mhz_locked	;
wire		W_Rst_n				;
wire		W_Glb_Rst_n			;
wire		W_PXIE_Rst			;
wire 		W_PXIE_Rst_125MHz 	;
wire		W_PXIE_Trig			;
wire[127:0]	h2c_tdata			;
wire		h2c_tlast			;
wire		h2c_tvalid			;
wire[15:0]	h2c_tkeep			;
wire		c2h_tready			;
wire		W_pxie_user_clk		;
wire		locked				;

wire        cpu_clock_100       ;
wire        cpu_clock_100_lock  ;
wire        cpu_rst_b;

wire		TXB_AWG1	;
wire        txb         ;

wire   [1:0]   pad_biu_hresp;
wire   [31:0]  pad_biu_hrdata;
wire           pad_biu_hready;
wire          biu_pad_hwrite;
wire  [31:0]  biu_pad_hwdata;
wire  [31:0]  biu_pad_haddr;
wire  [1:0]   biu_pad_htrans;

wire[31:0]		W_Trig_Num		;
wire[31:0]		W_Trig_Step		;
wire			W_Trig			;
wire     W_ISA_TRIG ;


Global_Reset_Module inst0_rst
(
	.I_clk(W_Clk_10mhz),
	.I_locked(Clk_10mhz_locked),
	.O_Rst_n(W_Glb_Rst_n),
	.O_pll_rst_n(O_lmk_resetn),
	.O_pll_trig(W_pll_trig)
);




  clk_10m_gen inst0_clk_10mhz
   (
    // Clock out ports
    .clk_out1(W_Clk_10mhz),     // output clk_out1
	.clk_out2(W_Clk_20mhz),     // output clk_out2
    // Status and control signals
    .locked(Clk_10mhz_locked),       // output locked
   // Clock in ports
    .clk_in1(I_LOC_100mhz));      // input clk_in1


  clk_sys_10m sys_clk_gen
   (
    // Clock out ports
    .clk_out1(W1_Clk_10mhz),     // output clk_out1
	.clk_out2(W1_Clk_20mhz),
	.clk_out3(W_Clk_125mhz),
    // Status and control signals
    .locked(locked),       // output locked
   // Clock in ports
    .clk_in1_p(I_SYS_50mhz_p),    // input clk_in1_p
    .clk_in1_n(I_SYS_50mhz_n));    // input clk_in1_n


genvar q;
    generate
        for(q=0;q<17;q=q+1)
        begin:OBUF_loop1
            OBUF  OBUF_inst (
				.O(O_star[q]), // Buffer output (connect directly to top-level port)
				.I(W_Trig) // Buffer input
				);
        end
    endgenerate


assign O_Trig_out =  W_PXIE_Trig;


 Trig_Gen_Mdl inst_sys_trig_gen(

	.I_Trig_Num(W_Trig_Num)	,
	.I_Trig_Step(W_Trig_Step)	,
	.I_clk_100mhz(W_Clk_125mhz)	,
	.I_Rst_n(W_Glb_Rst_n && ~W_PXIE_Rst_125MHz)	,
	.I_Trig_in(W_ISA_TRIG)	,
	.O_Trig(W_Trig)

    );

assign O_LMK_CLK_SEL = 1'b0;
assign O_LMK_SYNC = 1'b0;

LMK04610_CFG1  inst_pll_cfg
(
 .I_Clk(W_Clk_10mhz),
 .I_Rst_n(W_Glb_Rst_n),
 .I_Trig(W_pll_trig),
 .O_lmk_scsn(O_lmk_scs),
 .O_lmk_scl(O_lmk_sclk),
 .O_lmk_sdio(O_lmk_sdio)
);


// // For Test
// ila_0 ila1 (
// 	.clk(W_Clk_10mhz), // input wire clk


// 	.probe0(locked), // input wire [0:0]  probe0
// 	.probe1(Clk_10mhz_locked), // input wire [0:0]  probe1
// 	.probe2(O_lmk_sclk), // input wire [0:0]  probe2
// 	.probe3(O_lmk_scs), // input wire [0:0]  probe3
// 	.probe4(I_lmk_st0), // input wire [0:0]  probe4
// 	.probe5(I_lmk_st1) // input wire [0:0]  probe5
// );






xilinx_dma_pcie_ep inst0_pcie(
	.pci_exp_txp(O_PXIE_Txp),
	.pci_exp_txn(O_PXIE_Txn),
	.pci_exp_rxp(I_PXIE_Rxp),
	.pci_exp_rxn(I_PXIE_Rxn),
	.sys_clk_p(I_PXIE_Clk_p),
	.sys_clk_n(I_PXIE_Clk_n),
	.sys_rst_n(I_PXIE_Rst_n),
	.s_axis_c2h_tdata_0({c2h_tdata,c2h_tdata}),
	.s_axis_c2h_tlast_0(c2h_tlast),
	.s_axis_c2h_tvalid_0(c2h_tvalid),
	.s_axis_c2h_tready_0(c2h_tready),
	.s_axis_c2h_tkeep_0({c2h_tkeep,c2h_tkeep}),
	.m_axis_h2c_tdata_0(h2c_tdata),
	.m_axis_h2c_tlast_0(h2c_tlast),
	.m_axis_h2c_tvalid_0(h2c_tvalid),
	.m_axis_h2c_tready_0(1'b1),
	.m_axis_h2c_tkeep_0(h2c_tkeep),
	.user_clk(W_pxie_user_clk)
	);


/*ila_PXIe ila_pxie_data (
	.clk(W_pxie_user_clk), // input wire clk


	.probe0(h2c_tvalid), // input wire [0:0]  probe0
	.probe1(h2c_tdata) // input wire [127:0]  probe1
);*/
// 地址是32位是无关紧要的，因为我们可以通过取[23:4]位的方式限制在20位的地址位宽
wire [31:0] isa_addr_pxie;
wire [63:0] isa_data_pxie;
wire [15:0] isa_num_pxie;
wire isa_wren_pxie;
wire [15:0] isa_addr;
wire [31:0] isa_data;
wire isa_wren;
wire isa_run;

wire [31:0] sys_addr_pxie;
wire [63:0] sys_data_pxie;
wire [15:0] sys_num_pxie;
wire sys_wren_pxie;
wire [15:0] sys_addr;
wire [31:0] sys_data;
wire sys_wren;

wire [31:0] biu_pad_retire_pc;
wire biu_pad_retire;
wire [15:0] ram_wen;

PXIE_RX_DATA  inst_pxie_rx_data(
	.I_PXIE_CLK(W_pxie_user_clk),
	.I_PXIE_DATA(h2c_tdata[63:0]),
	.I_PXIE_DATA_VLD(h2c_tvalid),
	.I_Rst_n(W_Rst_n && W_Glb_Rst_n ),
	.I_CLK_10MHz(W1_Clk_10mhz),
	.I_CLK_125MHz(W_Clk_125mhz),
	.O_Trig(W_PXIE_Trig),
	.O_Rst(W_PXIE_Rst),
	.O_Rst_125MHz(W_PXIE_Rst_125MHz),
	.O_Trig_Num(),
	.O_Trig_Step(),

	.O_run (isa_run),
	.O_isa_Num (isa_num_pxie), //16
	.O_isa_addr(isa_addr_pxie), //32
	.O_isa_data(isa_data_pxie), //64
	.O_isa_wren(isa_wren_pxie),

	.O_sys_Num (sys_num_pxie), //16
	.O_sys_addr(sys_addr_pxie), //32
	.O_sys_data(sys_data_pxie), //64
	.O_sys_wren(sys_wren_pxie),

    .O_c2h_addr(c2h_addr),
    .O_c2h_len(c2h_len),
    .O_c2h_en(c2h_en)

	);

// vio_0 vio_0_inst(
//     .clk(cpu_clock_100),
//     .probe_out0(c2h_en),
//     .probe_out1(c2h_addr),
//     .probe_out2(c2h_len)
//     );

wire   [15:0]  c2h_addr;
wire   [15:0]  c2h_len;
wire           c2h_en;

wire  [63:0]  c2h_tdata;
wire  c2h_tvalid;
wire  c2h_tlast;
wire  c2h_tready;
wire  [7:0]   c2h_tkeep;

    //system ram
wire   [31:0]  sysRAM_data;
wire  sysRAM_vld;
wire  [15:0]  sysRAM_addr;
PXIE_TX_DATA PXIE_TX_DATA_inst(
    .rstn           (W_Rst_n),
    .c2h_addr       (c2h_addr),
    .c2h_len        (c2h_len),
    .c2h_en         (c2h_en),
    //c2h
    .c2h_clk        (W_pxie_user_clk),
    .c2h_tdata      (c2h_tdata),
    .c2h_tvalid     (c2h_tvalid),
    .c2h_tlast      (c2h_tlast),
    .c2h_tready     (c2h_tready),
    .c2h_tkeep      (c2h_tkeep),

    //system ram
    .sysRAM_clk     (cpu_clock_100),
    .sysRAM_data    (sysRAM_data),
    .sysRAM_vld     (sysRAM_vld),
    .sysRAM_addr    (sysRAM_addr)
    );

isa_buffer isa_buffer_inst(
	.clk_i 			(W_pxie_user_clk),
	.isa_data_i 	(isa_data_pxie),
	.isa_wren_i 	(isa_wren_pxie),
	.isa_addr_i 	(isa_addr_pxie),

	.clk_cpu 		(cpu_clock_100),
	.rstn 			(W_Rst_n),
	.isa_data_o 	(isa_data),
	.isa_wren_o 	(isa_wren),
	.isa_addr_o 	(isa_addr)
	);

isa_buffer sys_buffer_inst(
	.clk_i 			(W_pxie_user_clk),
	.isa_data_i 	(sys_data_pxie),
	.isa_wren_i 	(sys_wren_pxie),
	.isa_addr_i 	(sys_addr_pxie),

	.clk_cpu 		(cpu_clock_100),
	.rstn 			(W_Rst_n),
	.isa_data_o 	(sys_data),
	.isa_wren_o 	(sys_wren),
	.isa_addr_o 	(sys_addr)
	);

wire [31:0] uart2sys_data;
wire [15:0] uart2sys_addr;
wire        uart2sys_en;
uart2sys_buffer uart2sys_buffer_inst(
    .clk_i          (W1_Clk_10mhz),
    .data_i         (uart_rx_data),
    .data_vld_i     (uart_rx_valid),
    .addr_init      (16'h10),
    .addr_init_vld_i(addr_init_vld),  //1'b0

    .clk_cpu        (cpu_clock_100),
    .rstn           (W_Rst_n),
    .sys_data_o     (uart2sys_data),
    .sys_wren_o     (uart2sys_en),
    .sys_addr_o     (uart2sys_addr)
    );

cpu_clk cpu_clk_inst(
    .clk_100        (cpu_clock_100),
    // Status and control signals
    .locked         (cpu_clock_100_lock),
    // Clock in ports
    .clk_in1        (W1_Clk_20mhz)
    );

wire addr_init_vld;
vio_1 vio_1_inst(
    .clk(cpu_clock_100),
    .probe_out0(pg_rstn),
    .probe_out1(addr_init_vld)
    );
wire pg_rstn;

// here change to soc of C908 CPU

// system_c908 system_c908_inst(

//     );

wire sys_final_addr;
assign sys_final_addr = sysRAM_vld?sysRAM_addr:sys_addr;
soc system_c908_inst(
    // clk and rst
    .i_pad_clk           ( cpu_clock_100        ),
    .i_pad_rst_b         ( ~isa_run             ),
    // CPU monitor:ISA Decode
    .biu_pad_htrans      ( biu_pad_htrans       ),
    .biu_pad_hwrite      ( biu_pad_hwrite       ),
    .biu_pad_hwdata      ( biu_pad_hwdata       ),
    .biu_pad_haddr       ( biu_pad_haddr        ),
    // IRAM
    .prog_wen            ( isa_wren             ),
    .prog_waddr          ( isa_addr             ),
    .prog_wdata          ( isa_data             ),
    // SRAM input
    .uart2sys_en         ( uart2sys_en          ),
    .uart2sys_addr       ( uart2sys_addr        ),
    .uart2sys_data       ( uart2sys_data        ),
    .sys_wren            ( sys_wren             ),
    .sys_data            ( sys_data             ),
    .sys_final_addr      ( sys_final_addr       ), // sysRAM_vld?sysRAM_addr:sys_addr
    // SRAM output
    .sysRAM_data         ( sysRAM_data          ),
    .ram_wen             ( ram_wen              )
);

// CPU_SYSTEM CPU_SYSTEM_inst(
//     .cpu_clk            (cpu_clock_100),
//     .clk_en             (cpu_clock_100_lock),
//     .pg_reset_b         (pg_rstn), //1
//     .pad_cpu_rst_b      (~isa_run),
//     .pad_vic_int_vld    (32'h0),
//     .pad_biu_bigend_b   (1'b1),
//     .nmi_wake_lower     (2'h0),
//     .pad_yy_scan_mode   (1'b0),

//     .pad_had_jtg_tclk   (),
//     .pad_had_jtg_trst_b (1'b1),
//     .pad_had_jtg_tms_i  (),
//     .i_pad_jtg_tms      (),

//     .biu_pad_htrans     (biu_pad_htrans),

//     .pad_biu_hresp      (pad_biu_hresp),
//     .pad_biu_hrdata     (pad_biu_hrdata),
//     .pad_biu_hready     (pad_biu_hready),
//     .biu_pad_hwrite     (biu_pad_hwrite),
//     .biu_pad_hwdata     (biu_pad_hwdata),
//     .biu_pad_hsize      (biu_pad_hsize),
//     .biu_pad_haddr      (biu_pad_haddr),
//     .biu_pad_hburst     (),
//     .biu_pad_hprot      (),

//     .dram0_portb_clk    (),
//     .dram0_portb_rst    (),
//     .dram0_portb_wen    (),
//     .dram0_portb_ren    (),
//     .dram0_portb_din    (),
//     .dram0_portb_dout   (),
//     .dram0_portb_addr   (),
//     .dram1_portb_wen    (),
//     .dram1_portb_din    (),
//     .dram1_portb_dout   (),
//     .dram1_portb_addr   (),

//     .status_dram_par_err0(),
//     .status_dram_par_err1(),
//     .status_dram_par_err2(),

//     .prog_wen           (isa_wren),
//     .prog_waddr         (isa_addr),
//     .prog_wdata         (isa_data),
//     .status_iram_par_err(),
//     .cpu_pc             (),

//     .sysio_pad_lpmd_b   (),
//     .biu_pad_retire_pc(biu_pad_retire_pc),
//     .biu_pad_retire(biu_pad_retire)
//     );

// AQE_AHB AQE_AHB_inst(
//     .lite_mmc_hsel       (biu_pad_htrans[1]),
//     .lite_yy_haddr       (biu_pad_haddr-32'h4000_0000    ),
//     .lite_yy_hsize       (biu_pad_hsize    ),
//     .lite_yy_htrans      (biu_pad_htrans   ),
//     .lite_yy_hwdata      (biu_pad_hwdata   ),
//     .lite_yy_hwrite      (biu_pad_hwrite   ),
//     .mmc_lite_hrdata     (pad_biu_hrdata   ),
//     .mmc_lite_hready     (pad_biu_hready   ),
//     .mmc_lite_hresp      (pad_biu_hresp    ),
//     .pad_biu_bigend_b    (1'b1             ),
//     .pad_cpu_rst_b       (1'b1    ),
//     .pll_core_cpuclk     (cpu_clock_100            ),

//     .prog_wen            (uart2sys_en   ),
//     .prog_waddr          (uart2sys_addr ),
//     .prog_wdata          (uart2sys_data ),
//     .iram_par_err        (),
//     .dram1_portb_wen     ({4{sys_wren}}),
//     .dram1_portb_din     (sys_data),
//     .dram1_portb_dout    (sysRAM_data),
//     .dram1_portb_addr    (sysRAM_vld?sysRAM_addr:sys_addr),
//     .ram_wen 			 (ram_wen)
//     );

assign W_Rst_n = 1'b1;

wire    W_tx_ready;
wire[63:0]  W_UART_DATA ;
wire   W_UART_DATA_VLD ;

ISA_DECODE  inst_isa_decode(
    .I_wr_clk(cpu_clock_100),
    .I_rd_clk(W1_Clk_10mhz),
    .I_rst_n(W_Rst_n && W_Glb_Rst_n),
    .I_tx_ready(W_tx_ready),
    .wr_en(biu_pad_htrans[1] && biu_pad_hwrite),
    .isa_ram_en(ram_wen),
    .AHB_pad_hwdata(biu_pad_hwdata),
    .AHB_pad_hwaddr(biu_pad_haddr),
    .O_tx_data(W_UART_DATA),
    .O_tx_en(W_UART_DATA_VLD),
    .O_Trig(W_ISA_TRIG),
    .O_Trig_Num(W_Trig_Num),
    .O_Trig_Step(W_Trig_Step)
    );

UART_TX_DATA  inst_tx_data(
    .I_clk_10M      (W1_Clk_10mhz),
    .I_rst_n        (W_Rst_n && W_Glb_Rst_n),
    .txb            (txb),
    .I_data         (W_UART_DATA),
    .I_data_valid   (W_UART_DATA_VLD),
    .O_tx_ready     (W_tx_ready)
    );

genvar i;
    generate
        for(i=0;i<17;i=i+1)
        begin:OBUF_loop2
            OBUFDS #(
                .IOSTANDARD("DEFAULT")
                ) OBUF_dstarb_inst(
                .O(O_Dstarb_p[i]),
                .OB(O_Dstarb_n[i]),
                .I(txb)//TXB_AWG1
            );
        end
    endgenerate

wire [16:0] rxb;
genvar j;
    generate
        for(j=0;j<17;j=j+1)
        begin:IBUF_loop2
            IBUFDS #(
                .IOSTANDARD("DEFAULT")
                ) IBUF_dstarc_inst(
                .O(rxb[j]),
                .I(I_Dstarc_p[j]),
                .IB(I_Dstarc_n[j])//TXB_AWG1
            );
        end
    endgenerate

wire [63:0] uart_rx_data;
wire        uart_rx_valid;
UART_RX_DATA inst_uart_rx_data(
	.I_clk_10M      (W1_Clk_10mhz),
	.I_rst_n        (W_Rst_n && W_Glb_Rst_n),
	.rxb            (rxb[4]),
	.GA             (),
	.data_valid 	(uart_rx_valid),
	.data 			(uart_rx_data)
	);

//TO DO
// 1Q_map 1Q_map_inst(
//     .clk            (),
//     .rstn           (),
//     .qubit_index    (),
//     .xy_ctrl_i      (),
//     .xy_ctrl_q      (),
//     .z_ctrl         (),
//     .readout_i      (),
//     .readout_q      (),
//     .readout_i_dig  (),
//     .readout_q_dig  ()
//     );

endmodule