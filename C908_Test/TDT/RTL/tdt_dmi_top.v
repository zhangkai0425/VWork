`define TDT_DMI_SLAVE_0


`define FPGA



// Fixed RTL configures: 
`define TDT_DMI_TSMC

`define TDT_DMI_PROCESS12FFC

`ifdef TDT_DMI_SLAVE_31
  `define TDT_DMI_SLAVE_NUM                                                                 32
`else
  `ifdef TDT_DMI_SLAVE_30
    `define TDT_DMI_SLAVE_NUM                                                               31
  `else
    `ifdef TDT_DMI_SLAVE_29
      `define TDT_DMI_SLAVE_NUM                                                             30
    `else
      `ifdef TDT_DMI_SLAVE_28
        `define TDT_DMI_SLAVE_NUM                                                           29
      `else
        `ifdef TDT_DMI_SLAVE_27
          `define TDT_DMI_SLAVE_NUM                                                         28
        `else
          `ifdef TDT_DMI_SLAVE_26
            `define TDT_DMI_SLAVE_NUM                                                       27
          `else
            `ifdef TDT_DMI_SLAVE_25
              `define TDT_DMI_SLAVE_NUM                                                     26
            `else
              `ifdef TDT_DMI_SLAVE_24
                `define TDT_DMI_SLAVE_NUM                                                   25
              `else
                `ifdef TDT_DMI_SLAVE_23
                  `define TDT_DMI_SLAVE_NUM                                                 24
                `else
                  `ifdef TDT_DMI_SLAVE_22
                    `define TDT_DMI_SLAVE_NUM                                               23
                  `else 
                    `ifdef TDT_DMI_SLAVE_21
                      `define TDT_DMI_SLAVE_NUM                                             22
                    `else
                      `ifdef TDT_DMI_SLAVE_20
                        `define TDT_DMI_SLAVE_NUM                                           21
                      `else
                        `ifdef TDT_DMI_SLAVE_19 
                          `define TDT_DMI_SLAVE_NUM                                         20
                        `else
                          `ifdef TDT_DMI_SLAVE_18
                            `define TDT_DMI_SLAVE_NUM                                       19
                          `else
                            `ifdef TDT_DMI_SLAVE_17
                              `define TDT_DMI_SLAVE_NUM                                     18
                            `else
                              `ifdef TDT_DMI_SLAVE_16
                                `define TDT_DMI_SLAVE_NUM                                   17
                              `else
                                `ifdef TDT_DMI_SLAVE_15
                                  `define TDT_DMI_SLAVE_NUM                                 16
                                `else
                                  `ifdef TDT_DMI_SLAVE_14
                                    `define TDT_DMI_SLAVE_NUM                               15
                                  `else
                                    `ifdef TDT_DMI_SLAVE_13
                                      `define TDT_DMI_SLAVE_NUM                             14
                                    `else
                                      `ifdef TDT_DMI_SLAVE_12
                                        `define TDT_DMI_SLAVE_NUM                           13
                                      `else
                                        `ifdef TDT_DMI_SLAVE_11
                                          `define TDT_DMI_SLAVE_NUM                         12
                                        `else
                                          `ifdef TDT_DMI_SLAVE_10
                                            `define TDT_DMI_SLAVE_NUM                       11
                                          `else
                                            `ifdef TDT_DMI_SLAVE_9
                                              `define TDT_DMI_SLAVE_NUM                     10
                                            `else
                                              `ifdef TDT_DMI_SLAVE_8
                                                `define TDT_DMI_SLAVE_NUM                   9
                                              `else
                                                `ifdef TDT_DMI_SLAVE_7
                                                  `define TDT_DMI_SLAVE_NUM                 8
                                                `else
                                                  `ifdef TDT_DMI_SLAVE_6
                                                    `define TDT_DMI_SLAVE_NUM               7
                                                  `else
                                                    `ifdef TDT_DMI_SLAVE_5
                                                      `define TDT_DMI_SLAVE_NUM             6
                                                    `else
                                                      `ifdef TDT_DMI_SLAVE_4
                                                        `define TDT_DMI_SLAVE_NUM           5
                                                      `else
                                                        `ifdef TDT_DMI_SLAVE_3
                                                          `define TDT_DMI_SLAVE_NUM         4
                                                        `else
                                                          `ifdef TDT_DMI_SLAVE_2
                                                            `define TDT_DMI_SLAVE_NUM       3
                                                          `else
                                                            `ifdef TDT_DMI_SLAVE_1
                                                              `define TDT_DMI_SLAVE_NUM     2
                                                            `else
                                                              `ifdef TDT_DMI_SLAVE_0
                                                               `define TDT_DMI_SLAVE_NUM    1
                                                               `define TDT_DMI_SINGLE_SLAVE
                                                              `endif
                                                            `endif
                                                          `endif
                                                        `endif
                                                      `endif
                                                    `endif
                                                  `endif
                                                `endif
                                              `endif
                                            `endif
                                          `endif
                                        `endif
                                      `endif
                                    `endif
                                  `endif
                                `endif
                              `endif
                            `endif
                          `endif
                        `endif
                      `endif
                    `endif
                  `endif
                `endif
              `endif
            `endif
          `endif
        `endif
      `endif
    `endif
  `endif
`endif

`ifdef TDT_DMI_SINGLE_SLAVE
  `define TDT_DMI_HIGH_ADDR_W                  0
`else
  `define TDT_DMI_HIGH_ADDR_W                  6
`endif 

`ifdef TDT_DMI_SLAVE_31
    `define TDT_DMI_SLAVE_31_BASEADDR            'd31
`endif
`ifdef TDT_DMI_SLAVE_30
    `define TDT_DMI_SLAVE_30_BASEADDR            'd30
`endif
`ifdef TDT_DMI_SLAVE_29
    `define TDT_DMI_SLAVE_29_BASEADDR            'd29
`endif
`ifdef TDT_DMI_SLAVE_28
    `define TDT_DMI_SLAVE_28_BASEADDR            'd28
`endif
`ifdef TDT_DMI_SLAVE_27
    `define TDT_DMI_SLAVE_27_BASEADDR            'd27
`endif
`ifdef TDT_DMI_SLAVE_26
    `define TDT_DMI_SLAVE_26_BASEADDR            'd26
`endif
`ifdef TDT_DMI_SLAVE_25
    `define TDT_DMI_SLAVE_25_BASEADDR            'd25
`endif
`ifdef TDT_DMI_SLAVE_24
    `define TDT_DMI_SLAVE_24_BASEADDR            'd24
`endif
`ifdef TDT_DMI_SLAVE_23
    `define TDT_DMI_SLAVE_23_BASEADDR            'd23
`endif
`ifdef TDT_DMI_SLAVE_22
    `define TDT_DMI_SLAVE_22_BASEADDR            'd22
`endif
`ifdef TDT_DMI_SLAVE_21
    `define TDT_DMI_SLAVE_21_BASEADDR            'd21
`endif
`ifdef TDT_DMI_SLAVE_20
    `define TDT_DMI_SLAVE_20_BASEADDR            'd20
`endif
`ifdef TDT_DMI_SLAVE_19
    `define TDT_DMI_SLAVE_19_BASEADDR            'd19
`endif
`ifdef TDT_DMI_SLAVE_18
    `define TDT_DMI_SLAVE_18_BASEADDR            'd18
`endif
`ifdef TDT_DMI_SLAVE_17
    `define TDT_DMI_SLAVE_17_BASEADDR            'd17
`endif
`ifdef TDT_DMI_SLAVE_16
    `define TDT_DMI_SLAVE_16_BASEADDR            'd16
`endif
`ifdef TDT_DMI_SLAVE_15
    `define TDT_DMI_SLAVE_15_BASEADDR            'd15
`endif
`ifdef TDT_DMI_SLAVE_14
    `define TDT_DMI_SLAVE_14_BASEADDR            'd14
`endif
`ifdef TDT_DMI_SLAVE_13
    `define TDT_DMI_SLAVE_13_BASEADDR            'd13
`endif
`ifdef TDT_DMI_SLAVE_12
    `define TDT_DMI_SLAVE_12_BASEADDR            'd12
`endif
`ifdef TDT_DMI_SLAVE_11
    `define TDT_DMI_SLAVE_11_BASEADDR            'd11
`endif
`ifdef TDT_DMI_SLAVE_10
    `define TDT_DMI_SLAVE_10_BASEADDR            'd10
`endif
`ifdef TDT_DMI_SLAVE_9
    `define TDT_DMI_SLAVE_9_BASEADDR             'd9
`endif
`ifdef TDT_DMI_SLAVE_8
    `define TDT_DMI_SLAVE_8_BASEADDR             'd8
`endif
`ifdef TDT_DMI_SLAVE_7
    `define TDT_DMI_SLAVE_7_BASEADDR             'd7
`endif
`ifdef TDT_DMI_SLAVE_6
    `define TDT_DMI_SLAVE_6_BASEADDR             'd6
`endif
`ifdef TDT_DMI_SLAVE_5
    `define TDT_DMI_SLAVE_5_BASEADDR             'd5
`endif
`ifdef TDT_DMI_SLAVE_4
    `define TDT_DMI_SLAVE_4_BASEADDR             'd4
`endif
`ifdef TDT_DMI_SLAVE_3
    `define TDT_DMI_SLAVE_3_BASEADDR             'd3
`endif
`ifdef TDT_DMI_SLAVE_2
    `define TDT_DMI_SLAVE_2_BASEADDR             'd2
`endif
`ifdef TDT_DMI_SLAVE_1
    `define TDT_DMI_SLAVE_1_BASEADDR             'd1
`endif

`define TDT_DMI_IDLE_CYCLE                       3'h7


// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : tdt_dmi.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-6
// FUNCTION        : tdt_dmi.v
// ******************************************************************************

module tdt_dmi (
    sys_apb_clk,
    sys_apb_rst_b,
    pad_tdt_dtm_tclk,
    pad_tdt_dtm_trst_b,
    pad_tdt_dtm_jtag2_sel,         
    pad_tdt_dtm_tap_en,        
    pad_tdt_dtm_tdi,           
    pad_tdt_dtm_tms_i,  
    tdt_dtm_pad_tdo,           
    tdt_dtm_pad_tdo_en,        
    tdt_dtm_pad_tms_o,         
    tdt_dtm_pad_tms_oe,

    pad_icg_scan_en,

`ifdef TDT_DMI_SYSAPB_EN
    pad_tdt_sysapb_en,
    pad_tdt_dmi_paddr,
    pad_tdt_dmi_pwrite,
    pad_tdt_dmi_psel,
    pad_tdt_dmi_penable,
    pad_tdt_dmi_pwdata,
    tdt_dmi_pad_prdata,
    tdt_dmi_pad_pready,
    tdt_dmi_pad_pslverr,

`endif

    tdt_dmi_paddr,
    tdt_dmi_pwrite,
    tdt_dmi_penable,
    tdt_dmi_pwdata,
    tdt_dmi_psel,
    tdt_dmi_prdata,
    tdt_dmi_pslverr,    
    tdt_dmi_pready
);


    input                                     sys_apb_clk;
    input                                     sys_apb_rst_b;
    input                                     pad_tdt_dtm_tclk;
    input                                     pad_tdt_dtm_trst_b;
    input                                     pad_tdt_dtm_jtag2_sel;         
    input                                     pad_tdt_dtm_tap_en;        
    input                                     pad_tdt_dtm_tdi;           
    input                                     pad_tdt_dtm_tms_i;  
    output                                    tdt_dtm_pad_tdo;           
    output                                    tdt_dtm_pad_tdo_en;        
    output                                    tdt_dtm_pad_tms_o;         
    output                                    tdt_dtm_pad_tms_oe;

    input                                     pad_icg_scan_en;

`ifdef TDT_DMI_SYSAPB_EN
    input                                     pad_tdt_sysapb_en;
    input  [12+`TDT_DMI_HIGH_ADDR_W-1:0]      pad_tdt_dmi_paddr;
    input                                     pad_tdt_dmi_pwrite;
    input                                     pad_tdt_dmi_psel;
    input                                     pad_tdt_dmi_penable;
    input  [31:0]                             pad_tdt_dmi_pwdata;
    output [31:0]                             tdt_dmi_pad_prdata;
    output                                    tdt_dmi_pad_pready;
    output                                    tdt_dmi_pad_pslverr;    
`endif

    output [11:0]                             tdt_dmi_paddr;
    output                                    tdt_dmi_pwrite;
    output                                    tdt_dmi_penable;
    output [31:0]                             tdt_dmi_pwdata;
`ifdef TDT_DMI_SINGLE_SLAVE
    output                                    tdt_dmi_psel;
`else
    output [`TDT_DMI_SLAVE_NUM-1:0]           tdt_dmi_psel;
`endif
    input  [32*`TDT_DMI_SLAVE_NUM-1:0]        tdt_dmi_prdata;
`ifdef TDT_DMI_SINGLE_SLAVE
    input                                     tdt_dmi_pready;
    input                                     tdt_dmi_pslverr;
`else
    input  [`TDT_DMI_SLAVE_NUM-1:0]           tdt_dmi_pready;
    input  [`TDT_DMI_SLAVE_NUM-1:0]           tdt_dmi_pslverr;
`endif

    wire                                      apbm_apbmux_psel;
    wire                                      apbm_apbmux_penable;
    wire                                      apbm_apbmux_pwrite;
    wire [12+`TDT_DMI_HIGH_ADDR_W-1:0]        apbm_apbmux_paddr;
    wire [31:0]                               apbm_apbmux_pwdata;
    wire                                      apbmux_apbm_pready;
    wire                                      apbmux_apbm_pslverr;    
    wire [31:0]                               apbmux_apbm_prdata;
`ifdef TDT_DMI_SYSAPB_EN
    wire                                      pre_apbmux_apbdec_psel;
    wire                                      pre_apbmux_apbdec_penable;
    wire                                      pre_apbmux_apbdec_pwrite;
    wire [12+`TDT_DMI_HIGH_ADDR_W-1:0]        pre_apbmux_apbdec_paddr;
    wire [31:0]                               pre_apbmux_apbdec_pwdata;
    wire                                      pre_apbdec_apbmux_pready;
    wire                                      pre_apbdec_apbmux_pslverr;    
    wire [31:0]                               pre_apbdec_apbmux_prdata;

`endif
    wire                                      apbmux_apbdec_psel;
    wire                                      apbmux_apbdec_penable;
    wire                                      apbmux_apbdec_pwrite;
    wire [12+`TDT_DMI_HIGH_ADDR_W-1:0]        apbmux_apbdec_paddr;
    wire [31:0]                               apbmux_apbdec_pwdata;
    wire                                      apbdec_apbmux_pready;
    wire                                      apbdec_apbmux_pslverr;    
    wire [31:0]                               apbdec_apbmux_prdata;

    wire                                      dtm_apbm_wr_vld;
    wire    [`TDT_DMI_HIGH_ADDR_W+10-1:0]     dtm_apbm_wr_addr;
    wire    [1:0]                             dtm_apbm_wr_flg;
    wire    [31:0]                            dtm_apbm_wdata;
    wire                                      dtm_apbm_dmihardreset;
    wire    [31:0]                            apbm_dtm_rdata;
    wire                                      apbm_dtm_wr_ready;

    wire                                      apb_icg_en;
    assign apb_icg_en = 1'b0;

tdt_dmi_dtm_top #(
    .DTM_ABITS                               (`TDT_DMI_HIGH_ADDR_W+10)
) x_tdt_dmi_dtm_top (
    .pad_dtm_tclk                            (pad_tdt_dtm_tclk),
    .pad_dtm_trst_b                          (pad_tdt_dtm_trst_b),
    .pad_dtm_jtag2_sel                       (pad_tdt_dtm_jtag2_sel),         
    .pad_dtm_tap_en                          (pad_tdt_dtm_tap_en),        
    .pad_dtm_tdi                             (pad_tdt_dtm_tdi),           
    .pad_dtm_tms_i                           (pad_tdt_dtm_tms_i),  
    .dtm_pad_tdo                             (tdt_dtm_pad_tdo),           
    .dtm_pad_tdo_en                          (tdt_dtm_pad_tdo_en),        
    .dtm_pad_tms_o                           (tdt_dtm_pad_tms_o),         
    .dtm_pad_tms_oe                          (tdt_dtm_pad_tms_oe),

    .dtm_apbm_wr_vld                         (dtm_apbm_wr_vld),
    .dtm_apbm_wr_addr                        (dtm_apbm_wr_addr),
    .dtm_apbm_wr_flg                         (dtm_apbm_wr_flg),
    .dtm_apbm_wdata                          (dtm_apbm_wdata),
    .dmihardreset                            (dtm_apbm_dmihardreset),
    .apbm_dtm_rdata                          (apbm_dtm_rdata),
    .apbm_dtm_wr_ready                       (apbm_dtm_wr_ready)
);

//==========================================================
//    apb master
//==========================================================

tdt_dmi_apb_master #(
    .PADDR_HIGH_WIDTH                 (`TDT_DMI_HIGH_ADDR_W),
    .PADDR_LOW_WIDTH                  (10),
    .SLAVE_NUM                        (`TDT_DMI_SLAVE_NUM)
) x_tdt_dmi_apb_master ( 
    .tck                              (pad_tdt_dtm_tclk),
    .trst_b                           (pad_tdt_dtm_trst_b),
    .cmd_vld                          (dtm_apbm_wr_vld),
    .addr                             (dtm_apbm_wr_addr),
    .wr_flg                           (dtm_apbm_wr_flg),
    .wdata                            (dtm_apbm_wdata),
    .dmihardreset                     (dtm_apbm_dmihardreset),
    .rdata                            (apbm_dtm_rdata),
    .apb_wr_ready                     (apbm_dtm_wr_ready),

    .pclk                             (sys_apb_clk),
    .preset_b                         (sys_apb_rst_b),
    .psel                             (apbm_apbmux_psel),
    .penable                          (apbm_apbmux_penable),
    .pwrite                           (apbm_apbmux_pwrite),
    .paddr                            (apbm_apbmux_paddr),
    .pwdata                           (apbm_apbmux_pwdata),
    .pready                           (apbmux_apbm_pready),
    .pslverr                          (apbmux_apbm_pslverr),    
    .prdata                           (apbmux_apbm_prdata),

    .dm_apb_clk_en                    (apb_icg_en),
    .pad_icg_scan_en                  (pad_icg_scan_en)
);

//==========================================================
//    apb mux
//==========================================================
`ifdef TDT_DMI_SYSAPB_EN

tdt_dmi_apb_mux #(
    .PADDR_HIGH_WIDTH                 (`TDT_DMI_HIGH_ADDR_W),
    .PADDR_LOW_WIDTH                  (10)
) x_tdt_dmi_apb_mux (
    .pclk                             (sys_apb_clk),
    .preset_b                          (sys_apb_rst_b),

    .psel_dtm                         (apbm_apbmux_psel),
    .penable_dtm                      (apbm_apbmux_penable),
    .pwrite_dtm                       (apbm_apbmux_pwrite),
    .paddr_dtm                        (apbm_apbmux_paddr),
    .pwdata_dtm                       (apbm_apbmux_pwdata),
    .pready_dtm                       (apbmux_apbm_pready),
    .pslverr_dtm                      (apbmux_apbm_pslverr),

    .prdata_dtm                       (apbmux_apbm_prdata),

    .sysapb_en                        (pad_tdt_sysapb_en),
    .psel_sys                         (pad_tdt_dmi_psel),
    .penable_sys                      (pad_tdt_dmi_penable),
    .pwrite_sys                       (pad_tdt_dmi_pwrite),
    .paddr_sys                        (pad_tdt_dmi_paddr),
    .pwdata_sys                       (pad_tdt_dmi_pwdata),
    .pready_sys                       (tdt_dmi_pad_pready),
    .prdata_sys                       (tdt_dmi_pad_prdata), 
    .pslverr_sys                      (tdt_dmi_pad_pslverr), 

    .psel                             (pre_apbmux_apbdec_psel),
    .penable                          (pre_apbmux_apbdec_penable),
    .pwrite                           (pre_apbmux_apbdec_pwrite),
    .paddr                            (pre_apbmux_apbdec_paddr),
    .pwdata                           (pre_apbmux_apbdec_pwdata),
    .pready                           (pre_apbdec_apbmux_pready),
    .pslverr                          (pre_apbdec_apbmux_pslverr),    
    .prdata                           (pre_apbdec_apbmux_prdata),

    .dm_apb_clk_en                    (apb_icg_en),
    .pad_icg_scan_en                  (pad_icg_scan_en)
);

tdt_dmi_apb_regslice #(
    .PADDR_HIGH_WIDTH                 (`TDT_DMI_HIGH_ADDR_W),
    .PADDR_LOW_WIDTH                  (10)
) x_tdt_dmi_apb_regslice (
    .pclk                           (sys_apb_clk),
    .preset_b                        (sys_apb_rst_b),

    .psel                           (pre_apbmux_apbdec_psel),
    .penable                        (pre_apbmux_apbdec_penable),
    .pwrite                         (pre_apbmux_apbdec_pwrite),
    .paddr                          (pre_apbmux_apbdec_paddr),
    .pwdata                         (pre_apbmux_apbdec_pwdata),
    .pready                         (apbdec_apbmux_pready),
    .pslverr                        (apbdec_apbmux_pslverr),    
    .prdata                         (apbdec_apbmux_prdata),

    .psel_r                         (apbmux_apbdec_psel),
    .penable_r                      (apbmux_apbdec_penable),
    .pwrite_r                       (apbmux_apbdec_pwrite),
    .paddr_r                        (apbmux_apbdec_paddr),
    .pwdata_r                       (apbmux_apbdec_pwdata),
    .pready_r                       (pre_apbdec_apbmux_pready),
    .pslverr_r                      (pre_apbdec_apbmux_pslverr),    
    .prdata_r                       (pre_apbdec_apbmux_prdata),

    .dm_apb_clk_en                  (apb_icg_en),
    .pad_icg_scan_en                (pad_icg_scan_en)
);

`else 
    assign apbmux_apbdec_psel                                  = apbm_apbmux_psel;
    assign apbmux_apbdec_penable                               = apbm_apbmux_penable;
    assign apbmux_apbdec_pwrite                                = apbm_apbmux_pwrite;
    assign apbmux_apbdec_paddr[12+`TDT_DMI_HIGH_ADDR_W-1:0]    = apbm_apbmux_paddr[12+`TDT_DMI_HIGH_ADDR_W-1:0];
    assign apbmux_apbdec_pwdata[31:0]                          = apbm_apbmux_pwdata[31:0];
    assign apbmux_apbm_pready                                  = apbdec_apbmux_pready;
    assign apbmux_apbm_pslverr                                 = apbdec_apbmux_pslverr;    
    assign apbmux_apbm_prdata[31:0]                            = apbdec_apbmux_prdata[31:0];
`endif

//==========================================================
//    apb decoder
//==========================================================
`ifdef TDT_DMI_SINGLE_SLAVE
    assign tdt_dmi_psel                                 = apbmux_apbdec_psel;
    assign tdt_dmi_penable                              = apbmux_apbdec_penable;
    assign tdt_dmi_pwrite                               = apbmux_apbdec_pwrite;
    assign tdt_dmi_paddr[11:0]                          = apbmux_apbdec_paddr[12+`TDT_DMI_HIGH_ADDR_W-1:0];
    assign tdt_dmi_pwdata[31:0]                         = apbmux_apbdec_pwdata[31:0];
    assign apbdec_apbmux_pready                         = tdt_dmi_pready;
    assign apbdec_apbmux_pslverr                        = tdt_dmi_pslverr;    
    assign apbdec_apbmux_prdata[31:0]                   = tdt_dmi_prdata[32*`TDT_DMI_SLAVE_NUM-1:0];
`else
tdt_dmi_apb_decoder #(
`ifdef TDT_DMI_SLAVE_31
    .PSEL_31_ADDR                     ($unsigned(`TDT_DMI_SLAVE_31_BASEADDR) & {`TDT_DMI_HIGH_ADDR_W{1'b1}}),
`endif
`ifdef TDT_DMI_SLAVE_30               
    .PSEL_30_ADDR                     ($unsigned(`TDT_DMI_SLAVE_30_BASEADDR) & {`TDT_DMI_HIGH_ADDR_W{1'b1}}),
`endif
`ifdef TDT_DMI_SLAVE_29               
    .PSEL_29_ADDR                     ($unsigned(`TDT_DMI_SLAVE_29_BASEADDR) & {`TDT_DMI_HIGH_ADDR_W{1'b1}}),
`endif
`ifdef TDT_DMI_SLAVE_28               
    .PSEL_28_ADDR                     ($unsigned(`TDT_DMI_SLAVE_28_BASEADDR) & {`TDT_DMI_HIGH_ADDR_W{1'b1}}),
`endif
`ifdef TDT_DMI_SLAVE_27               
    .PSEL_27_ADDR                     ($unsigned(`TDT_DMI_SLAVE_27_BASEADDR) & {`TDT_DMI_HIGH_ADDR_W{1'b1}}),
`endif
`ifdef TDT_DMI_SLAVE_26               
    .PSEL_26_ADDR                     ($unsigned(`TDT_DMI_SLAVE_26_BASEADDR) & {`TDT_DMI_HIGH_ADDR_W{1'b1}}),
`endif
`ifdef TDT_DMI_SLAVE_25               
    .PSEL_25_ADDR                     ($unsigned(`TDT_DMI_SLAVE_25_BASEADDR) & {`TDT_DMI_HIGH_ADDR_W{1'b1}}),
`endif
`ifdef TDT_DMI_SLAVE_24               
    .PSEL_24_ADDR                     ($unsigned(`TDT_DMI_SLAVE_24_BASEADDR) & {`TDT_DMI_HIGH_ADDR_W{1'b1}}),
`endif
`ifdef TDT_DMI_SLAVE_23               
    .PSEL_23_ADDR                     ($unsigned(`TDT_DMI_SLAVE_23_BASEADDR) & {`TDT_DMI_HIGH_ADDR_W{1'b1}}),
`endif
`ifdef TDT_DMI_SLAVE_22               
    .PSEL_22_ADDR                     ($unsigned(`TDT_DMI_SLAVE_22_BASEADDR) & {`TDT_DMI_HIGH_ADDR_W{1'b1}}),
`endif
`ifdef TDT_DMI_SLAVE_21               
    .PSEL_21_ADDR                     ($unsigned(`TDT_DMI_SLAVE_21_BASEADDR) & {`TDT_DMI_HIGH_ADDR_W{1'b1}}),
`endif
`ifdef TDT_DMI_SLAVE_20               
    .PSEL_20_ADDR                     ($unsigned(`TDT_DMI_SLAVE_20_BASEADDR) & {`TDT_DMI_HIGH_ADDR_W{1'b1}}),
`endif
`ifdef TDT_DMI_SLAVE_19               
    .PSEL_19_ADDR                     ($unsigned(`TDT_DMI_SLAVE_19_BASEADDR) & {`TDT_DMI_HIGH_ADDR_W{1'b1}}),
`endif
`ifdef TDT_DMI_SLAVE_18               
    .PSEL_18_ADDR                     ($unsigned(`TDT_DMI_SLAVE_18_BASEADDR) & {`TDT_DMI_HIGH_ADDR_W{1'b1}}),
`endif
`ifdef TDT_DMI_SLAVE_17               
    .PSEL_17_ADDR                     ($unsigned(`TDT_DMI_SLAVE_17_BASEADDR) & {`TDT_DMI_HIGH_ADDR_W{1'b1}}),
`endif
`ifdef TDT_DMI_SLAVE_16               
    .PSEL_16_ADDR                     ($unsigned(`TDT_DMI_SLAVE_16_BASEADDR) & {`TDT_DMI_HIGH_ADDR_W{1'b1}}),
`endif
`ifdef TDT_DMI_SLAVE_15               
    .PSEL_15_ADDR                     ($unsigned(`TDT_DMI_SLAVE_15_BASEADDR) & {`TDT_DMI_HIGH_ADDR_W{1'b1}}),
`endif
`ifdef TDT_DMI_SLAVE_14               
    .PSEL_14_ADDR                     ($unsigned(`TDT_DMI_SLAVE_14_BASEADDR) & {`TDT_DMI_HIGH_ADDR_W{1'b1}}),
`endif
`ifdef TDT_DMI_SLAVE_13               
    .PSEL_13_ADDR                     ($unsigned(`TDT_DMI_SLAVE_13_BASEADDR) & {`TDT_DMI_HIGH_ADDR_W{1'b1}}),
`endif
`ifdef TDT_DMI_SLAVE_12               
    .PSEL_12_ADDR                     ($unsigned(`TDT_DMI_SLAVE_12_BASEADDR) & {`TDT_DMI_HIGH_ADDR_W{1'b1}}),
`endif
`ifdef TDT_DMI_SLAVE_11               
    .PSEL_11_ADDR                     ($unsigned(`TDT_DMI_SLAVE_11_BASEADDR) & {`TDT_DMI_HIGH_ADDR_W{1'b1}}),
`endif
`ifdef TDT_DMI_SLAVE_10               
    .PSEL_10_ADDR                     ($unsigned(`TDT_DMI_SLAVE_10_BASEADDR) & {`TDT_DMI_HIGH_ADDR_W{1'b1}}),
`endif
`ifdef TDT_DMI_SLAVE_9               
    .PSEL_9_ADDR                      ($unsigned(`TDT_DMI_SLAVE_9_BASEADDR) & {`TDT_DMI_HIGH_ADDR_W{1'b1}}),
`endif
`ifdef TDT_DMI_SLAVE_8                
    .PSEL_8_ADDR                      ($unsigned(`TDT_DMI_SLAVE_8_BASEADDR) & {`TDT_DMI_HIGH_ADDR_W{1'b1}}),
`endif
`ifdef TDT_DMI_SLAVE_7                
    .PSEL_7_ADDR                      ($unsigned(`TDT_DMI_SLAVE_7_BASEADDR) & {`TDT_DMI_HIGH_ADDR_W{1'b1}}),
`endif
`ifdef TDT_DMI_SLAVE_6                
    .PSEL_6_ADDR                      ($unsigned(`TDT_DMI_SLAVE_6_BASEADDR) & {`TDT_DMI_HIGH_ADDR_W{1'b1}}),
`endif
`ifdef TDT_DMI_SLAVE_5                
    .PSEL_5_ADDR                      ($unsigned(`TDT_DMI_SLAVE_5_BASEADDR) & {`TDT_DMI_HIGH_ADDR_W{1'b1}}),
`endif
`ifdef TDT_DMI_SLAVE_4                
    .PSEL_4_ADDR                      ($unsigned(`TDT_DMI_SLAVE_4_BASEADDR) & {`TDT_DMI_HIGH_ADDR_W{1'b1}}),
`endif
`ifdef TDT_DMI_SLAVE_3                
    .PSEL_3_ADDR                      ($unsigned(`TDT_DMI_SLAVE_3_BASEADDR) & {`TDT_DMI_HIGH_ADDR_W{1'b1}}),
`endif
`ifdef TDT_DMI_SLAVE_2                
    .PSEL_2_ADDR                      ($unsigned(`TDT_DMI_SLAVE_2_BASEADDR) & {`TDT_DMI_HIGH_ADDR_W{1'b1}}),
`endif
`ifdef TDT_DMI_SLAVE_1                
    .PSEL_1_ADDR                      ($unsigned(`TDT_DMI_SLAVE_1_BASEADDR) & {`TDT_DMI_HIGH_ADDR_W{1'b1}}),
`endif
    .PSEL_0_ADDR                      ({`TDT_DMI_HIGH_ADDR_W{1'b0}}),
    .NUM_APB_SLAVES                   (`TDT_DMI_SLAVE_NUM),
    .PADDR_HIGH_WIDTH                 (`TDT_DMI_HIGH_ADDR_W),
    .PADDR_LOW_WIDTH                  (10)
) x_tdt_dmi_apb_decoder (
    .pclk                             (sys_apb_clk),
    .preset_b                          (sys_apb_rst_b),

    .psel_m                           (apbmux_apbdec_psel),
    .penable_m                        (apbmux_apbdec_penable),
    .pwrite_m                         (apbmux_apbdec_pwrite),
    .paddr_m                          (apbmux_apbdec_paddr),
    .pwdata_m                         (apbmux_apbdec_pwdata),
    .pready_m                         (apbdec_apbmux_pready),
    .pslverr_m                        (apbdec_apbmux_pslverr),
    .prdata_m                         (apbdec_apbmux_prdata),

    .penable                          (tdt_dmi_penable),
    .pwrite                           (tdt_dmi_pwrite),
    .paddr                            (tdt_dmi_paddr),
    .pwdata                           (tdt_dmi_pwdata),
    .psel                             (tdt_dmi_psel),
    .pslverr                          (tdt_dmi_pslverr),
    .pready                           (tdt_dmi_pready),    
    .prdata                           (tdt_dmi_prdata)
);
`endif

endmodule
// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : tdt_dmi_apb_master.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-6
// FUNCTION        : tdt_dmi_apb_master.v
// ******************************************************************************

module tdt_dmi_apb_master
#(
    parameter   PADDR_HIGH_WIDTH = 6,
    parameter   PADDR_LOW_WIDTH  = 12,
    parameter   DTM_ADDR_WIDTH   = PADDR_HIGH_WIDTH+PADDR_LOW_WIDTH,
    parameter   PADDR_WIDTH      = PADDR_HIGH_WIDTH+PADDR_LOW_WIDTH+2,
    parameter   SLAVE_NUM        = 1
)
( 
    input                           tck,
    input                           trst_b,
    input                           cmd_vld,
    input   [DTM_ADDR_WIDTH-1:0]    addr,
    input   [1:0]                   wr_flg,
    input   [31:0]                  wdata,
    input                           dmihardreset,
    output  [31:0]                  rdata,
    output                          apb_wr_ready,

    input                           pclk,
    input                           preset_b,
    output reg                      psel,
    output reg                      penable,
    output reg                      pwrite,
    output reg [PADDR_WIDTH-1:0]    paddr,
    output reg [31:0]               pwdata,
    input                           pready,
    input  [31:0]                   prdata,
    input                           pslverr,

    input                           dm_apb_clk_en,
    input                           pad_icg_scan_en
);
    //gated clock out
    wire    apb_pclk;

    //input sync
    wire    cmd_vld_sync; 
    wire    dmihardreset_sync;

    tdt_dmi_pulse_sync x_tdt_dmi_pulse_cmd_vld (
        .src_clk          (tck),
        .dst_clk          (pclk),
        .src_rst_b        (trst_b),
        .dst_rst_b        (preset_b),
        .src_pulse        (cmd_vld),
        .dst_pulse        (cmd_vld_sync)
    );

   tdt_dmi_pulse_sync x_tdt_dmi_pulse_dmihardreset (
        .src_clk          (tck),
        .dst_clk          (pclk),
        .src_rst_b        (trst_b),
        .dst_rst_b        (preset_b),
        .src_pulse        (dmihardreset),
        .dst_pulse        (dmihardreset_sync)
    );
    reg                     apb_wr_ready_pclk_d1;
    reg     [31:0]          prdata_smp;

    //input sample
    reg     [1:0]           wr_flg_smp;
    reg     [DTM_ADDR_WIDTH-1:0]     addr_smp;
    reg     [31:0]          wdata_smp;

    always @ (posedge apb_pclk or negedge preset_b)
    begin
        if(~preset_b)
        begin 
            wr_flg_smp[1:0] <= 2'b00;
            addr_smp[DTM_ADDR_WIDTH-1:0]   <= {DTM_ADDR_WIDTH{1'b0}};
            wdata_smp[31:0]  <= {32{1'b0}};
        end
        else if(dmihardreset_sync)
        begin 
            wr_flg_smp[1:0] <= 2'b00;
            addr_smp[DTM_ADDR_WIDTH-1:0]   <= {DTM_ADDR_WIDTH{1'b0}};
            wdata_smp[31:0]  <= {32{1'b0}};
        end
        else if(cmd_vld_sync)
        begin
            wr_flg_smp[1:0] <= wr_flg[1:0];
            addr_smp[DTM_ADDR_WIDTH-1:0]   <= addr[DTM_ADDR_WIDTH-1:0];
            wdata_smp[31:0]  <= wdata[31:0];
        end
    end

    //APB MASTER FSM
    localparam      IDLE    = 2'b00;
    localparam      APB_SETUP   = 2'b01;
    localparam      APB_ACCESS  = 2'b10;
    reg     [1:0]   p_state;
    reg     [1:0]   n_state;
    wire            addr_is_legal; 
    wire            trans_req;
    reg             cmd_vld_sync_dly;

    always @ (posedge apb_pclk or negedge preset_b)
    begin
        if(~preset_b)
            cmd_vld_sync_dly <= 1'b0;
        else if(dmihardreset_sync)
            cmd_vld_sync_dly <= 1'b0;
        else
            cmd_vld_sync_dly <= cmd_vld_sync;  
    end

    `ifdef TDT_DMI_SINGLE_SLAVE
        assign addr_is_legal = 1'b1;
    `else
        assign addr_is_legal = addr[DTM_ADDR_WIDTH-1:DTM_ADDR_WIDTH-PADDR_HIGH_WIDTH] < ($unsigned(SLAVE_NUM) & {PADDR_HIGH_WIDTH+1{1'b1}});
    `endif

    assign trans_req = cmd_vld_sync_dly & (wr_flg_smp[0] ^ wr_flg_smp[1]) & addr_is_legal;

    always @ (posedge apb_pclk or negedge preset_b)
    begin
        if(~preset_b)
            p_state[1:0] <= 2'b00;
        else if(dmihardreset_sync)
            p_state[1:0] <= 2'b00;
        else
            p_state[1:0] <= n_state[1:0];
    end

    always @ (p_state[1:0] or
              pready or
              trans_req)
    begin
        case(p_state[1:0])
            IDLE    : 
                if(trans_req)
                    n_state[1:0] = APB_SETUP;
                else
                    n_state[1:0] = IDLE;
            APB_SETUP   :   
                n_state[1:0] = APB_ACCESS;
            APB_ACCESS  : 
                if(pready & trans_req)
                    n_state[1:0] = APB_SETUP;
                else if(pready & ~trans_req)
                    n_state[1:0] = IDLE;
                else 
                    n_state[1:0] = APB_ACCESS;
            default :   
                n_state[1:0] = IDLE;
        endcase
    end
    
    //psel reg out
    always @ (posedge apb_pclk or negedge preset_b)
    begin
        if(~preset_b)
            psel <= 1'b0;
        else if(dmihardreset_sync)
            psel <= 1'b0;
        else if(p_state[1:0] == IDLE & trans_req)
            psel <= 1'b1;
        else if(p_state[1:0] == APB_ACCESS & pready & ~trans_req) //miss pready  at first
            psel <= 1'b0;
    end

    //penable reg out
    always @ (posedge apb_pclk or negedge preset_b)
    begin
        if(~preset_b)
            penable <= 1'b0;
        else if(dmihardreset_sync)
            penable <= 1'b0;
        else if(p_state[1:0] == APB_SETUP)
            penable <= 1'b1;
        else if(p_state[1:0] == APB_ACCESS & pready)
            penable <= 1'b0;
    end

    //pwrite, paddr, pwdata reg out
    always @ (posedge apb_pclk or negedge preset_b)
    begin
        if(~preset_b)
        begin
            pwrite <= 1'b0;
            paddr[PADDR_WIDTH-1:0]  <= {PADDR_WIDTH{1'b0}};
            pwdata[31:0] <= {32{1'b0}};
        end
        else if(dmihardreset_sync)
        begin
            pwrite <= 1'b0;
            paddr[PADDR_WIDTH-1:0]  <= {PADDR_WIDTH{1'b0}};
            pwdata[31:0] <= {32{1'b0}};
        end
        else if(trans_req)
        begin
            pwrite <= wr_flg_smp[1];
            paddr[PADDR_WIDTH-1:0]  <= {addr_smp[DTM_ADDR_WIDTH-1:0], 2'b00};
            pwdata[31:0] <= wdata_smp[31:0];
        end
    end

    //response modify
    wire    apb_wr_ready_pclk;

    assign apb_wr_ready_pclk = pready & penable;

    always @ (posedge apb_pclk or negedge preset_b) begin
        if(~preset_b)
            apb_wr_ready_pclk_d1 <= 1'b0;
        else if(dmihardreset_sync)
            apb_wr_ready_pclk_d1 <= 1'b0;
        else if (apb_wr_ready_pclk_d1)
            apb_wr_ready_pclk_d1 <= 1'b0;    
        else if (apb_wr_ready_pclk) 
            apb_wr_ready_pclk_d1 <= 1'b1;

    end

    always @ (posedge apb_pclk or negedge preset_b) begin
        if(~preset_b)
            prdata_smp[31:0] <= {32{1'b0}};
        else if(dmihardreset_sync)
            prdata_smp[31:0] <= {32{1'b0}};
        else if (apb_wr_ready_pclk)
            prdata_smp[31:0] <= prdata[31:0];

    end

    //output sync
    tdt_dmi_pulse_sync x_tdt_dmi_pulse_sync_1(
        .src_clk        (pclk),
        .dst_clk        (tck),
        .src_rst_b      (preset_b),
        .dst_rst_b      (trst_b),
        .src_pulse      (apb_wr_ready_pclk_d1),
        .dst_pulse      (apb_wr_ready)
    );
    
    //output rdata
    assign rdata[31:0] = prdata_smp[31:0];

    //clock gating enable
    wire    apb_master_clk_en;
    assign apb_master_clk_en = cmd_vld_sync | cmd_vld_sync_dly | psel | apb_wr_ready_pclk_d1 | dmihardreset_sync;
    
    tdt_dmi_gated_clk_cell x_tdt_dmi_gated_clk_cell(
        .clk_in             (pclk),
        .module_en          (dm_apb_clk_en),
        .local_en           (apb_master_clk_en),
        .external_en        (1'b0),
        .pad_yy_icg_scan_en (pad_icg_scan_en),
        .clk_out            (apb_pclk)
    );

endmodule
// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : tdt_dmi_dtm_chain.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-6
// FUNCTION        : tdt_dmi_dtm_chain.v
// ******************************************************************************

module tdt_dmi_dtm_chain #(
    parameter                        CHAIN_DW          = 64,
    parameter                        DTM_IRREG_WIDTH   = 5,
    parameter                        DTM_ABITS         = 16,    
    parameter                        DTM_NDMIREG_WIDTH = 32

)(
    input                            tclk,                 
    input                            trst_b,   
    input                            dmihardreset,
    input                            io_chain_tdi,
    output                           chain_io_tdo,

    input   [CHAIN_DW-1:0]           idr_chain_dr, 
    input   [DTM_IRREG_WIDTH-1:0]    idr_chain_ir, 
    output  [CHAIN_DW-1:0]           chain_idr_data,      
     
    input                            idr_dmi_mode,
    input                            ctrl_chain_capture_dr,  
    input                            ctrl_chain_capture_ir,    
    input                            ctrl_chain_shift_dr,      
    input                            ctrl_chain_shift_ir,      
    input                            ctrl_chain_shift_par,     
    input                            ctrl_chain_shift_sync
);

        
    localparam  [DTM_IRREG_WIDTH-1:0] IDCODE               = 5'h01;
    localparam  [DTM_IRREG_WIDTH-1:0] DMI_ACC              = 5'h02;
    localparam  [DTM_IRREG_WIDTH-1:0] DTMCS                = 5'h10;
    localparam  [DTM_IRREG_WIDTH-1:0] DMI                  = 5'h11;
    
    localparam                        DTM_DMIREG_WIDTH     = DTM_ABITS + 2 + 32;   
    localparam                        DTM_DMIACCREG_WIDTH  = 1;
    
    reg  [CHAIN_DW-1:0] chain_shifter_pre;
    reg  [CHAIN_DW-1:0] chain_shifter;
    reg                 parity;
    reg                 tdo;
    wire                tdi;
    
    always @ (ctrl_chain_shift_ir                or
              tdi                                or
              chain_shifter                      or
              ctrl_chain_capture_dr              or
              idr_chain_dr[CHAIN_DW-1:0]         or
              ctrl_chain_capture_ir              or
              idr_chain_ir[DTM_IRREG_WIDTH-1:0]  or
              ctrl_chain_shift_dr                or
              idr_dmi_mode
              ) begin
        chain_shifter_pre[CHAIN_DW-1:0] = {CHAIN_DW{1'b0}};
        if (ctrl_chain_shift_ir)
            chain_shifter_pre[DTM_IRREG_WIDTH-1:0] = {tdi, chain_shifter[DTM_IRREG_WIDTH-1:1]};
        else if (ctrl_chain_capture_dr)
            chain_shifter_pre[CHAIN_DW-1:0] = idr_chain_dr[CHAIN_DW-1:0];
        else if (ctrl_chain_capture_ir)
            chain_shifter_pre[CHAIN_DW-1:0] = {{CHAIN_DW-DTM_IRREG_WIDTH{1'b0}}, idr_chain_ir[DTM_IRREG_WIDTH-1:0]};
        else if (ctrl_chain_shift_dr) 
            case (idr_chain_ir[DTM_IRREG_WIDTH-1:0]) 
                DMI_ACC   : chain_shifter_pre[DTM_DMIACCREG_WIDTH-1:0] = tdi; //1bit
                DMI       : if (idr_dmi_mode) 
                                chain_shifter_pre[DTM_DMIREG_WIDTH-DTM_ABITS-1:0] = {tdi, chain_shifter[DTM_DMIREG_WIDTH-DTM_ABITS-1:1]}; //44bit
                            else 
                                chain_shifter_pre[DTM_DMIREG_WIDTH-1:0] = {tdi, chain_shifter[DTM_DMIREG_WIDTH-1:1]}; //34bit
                DTMCS     : chain_shifter_pre[DTM_NDMIREG_WIDTH-1:0] = {tdi, chain_shifter[DTM_NDMIREG_WIDTH-1:1]}; //32bit
                IDCODE    : chain_shifter_pre[DTM_NDMIREG_WIDTH-1:0] = {tdi, chain_shifter[DTM_NDMIREG_WIDTH-1:1]}; //32bit
                default   : chain_shifter_pre[DTM_DMIACCREG_WIDTH-1:0] = tdi; //1bit,use DTM_DMIACCREG_WIDTH
            endcase
        else
            chain_shifter_pre[CHAIN_DW-1:0] = chain_shifter[CHAIN_DW-1:0];
    end
    
    // data shift from the lowest bit
    // sample tdi on the posedge of JTAG clock
    always @ (posedge tclk) begin
        chain_shifter[CHAIN_DW-1:0] <= chain_shifter_pre[CHAIN_DW-1:0];
    end
    
    assign chain_idr_data[CHAIN_DW-1:0] = chain_shifter[CHAIN_DW-1:0];
    //==============================================
    // calculate the parity bit when read DR
    //==============================================
    always @ (posedge tclk) begin
        if (ctrl_chain_capture_dr)
            parity <= 1'b1;
        else if (ctrl_chain_shift_dr)
            parity <= parity ^ chain_shifter[0];
    end
    
    //==============================================
    // set tdo on the negedge of tclk
    // set tdo to logic 1 when IDLE
    //==============================================
    always @ (negedge tclk or negedge trst_b) begin
        if (~trst_b)
            tdo <= 1'b1;
        else if (ctrl_chain_shift_sync)
            tdo <= 1'b0;
        else if (ctrl_chain_shift_dr | ctrl_chain_shift_ir)
            tdo <= chain_shifter[0];
        else if (ctrl_chain_shift_par)
            tdo <= parity;
        else
            tdo <= 1'b1;
    end
    
    //==========================================================
    //               jtag input and output
    //==========================================================
    
    assign tdi = io_chain_tdi;
    
    assign chain_io_tdo = tdo;

endmodule



// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : tdt_dmi_dtm_ctrl.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-6
// FUNCTION        : tdt_dmi_dtm_ctrl.v
// ******************************************************************************

module tdt_dmi_dtm_ctrl #(
    parameter       DTM_ABITS            = 16,    
    parameter       DTM_NDMIREG_WIDTH    = 32, 
    parameter       DTM_IRREG_WIDTH      = 5, 
    parameter [6:0] DTM_FSM2_RSTCNT      = 7'd80 
)(
    input           tclk,                    
    input           trst_b,
    input           dmihardreset,
    input           io_ctrl_tap_en,            
    input           pad_dtm_jtag2_sel,       
    input           pad_dtm_tms_i,   
    input           idr_dmi_mode,
    input [DTM_IRREG_WIDTH-1:0] idr_chain_ir,
    output          ctrl_io_tdo_en,            
    output          ctrl_io_tms_oe,            
    output          ctrl_chain_capture_dr,   
    output          ctrl_chain_capture_ir,   
    output          ctrl_idr_update_ir,       
    output          ctrl_idr_update_dr,
    output          ctrl_idr_capture_dr,
    output          ctrl_idr_tap_reset,
    output          ctrl_chain_shift_dr,      
    output          ctrl_chain_shift_ir,      
    output          ctrl_chain_shift_par,     
    output          ctrl_chain_shift_sync
);

    localparam   DTM_DMIREG_WIDTH      = DTM_ABITS + 2 + 32;
    localparam   DTM_DMIREG_ACC_WIDTH  = DTM_DMIREG_WIDTH - DTM_ABITS;
    localparam   DTM_DMIACCREG_WIDTH   = 1;  

    localparam  [DTM_IRREG_WIDTH-1:0]   IDCODE               = 5'h01;
    localparam  [DTM_IRREG_WIDTH-1:0]   DMI_ACC              = 5'h02;
    localparam  [DTM_IRREG_WIDTH-1:0]   DTMCS                = 5'h10;
    localparam  [DTM_IRREG_WIDTH-1:0]   DMI                  = 5'h11;
    
    reg        [7:0]  fsm2_data_counter;        
    reg               fsm2_parity;              
    reg               fsm2_read_vld;            
    reg        [1:0]  fsm2_rs;                  
    reg        [1:0]  fsm2_rs_counter;          
    reg        [3:0]  tap2_cur_st;             
    reg        [3:0]  tap2_nxt_st;             
    reg        [6:0]  tap2_rst_cnt;            
    reg        [3:0]  tap5_cur_st;             
    reg        [3:0]  tap5_nxt_st;             
    reg               tdo_en;                  
    reg               tms_oe;                  
   
    
    wire              jtag2_sel;               
    wire              fsm2_capture_dr;   
    wire              fsm2_capture_ir;                 
    wire              fsm2_load_rs;             
    wire              fsm2_load_rw;             
    wire              fsm2_parity_vld;          
    wire              fsm2_rs_had_dr_dmi_sel; 
    wire              fsm2_rs_had_dr_sel;       
    wire              fsm2_rs_had_dr_ndmi_sel;          
    wire              fsm2_rs_had_ir_sel;       
    wire              fsm2_shift_dr;            
    wire              fsm2_shift_ir;            
    wire              fsm2_shift_vld;           
    wire              fsm2_start_vld;           
    wire              fsm2_sync_vld;            
    wire              fsm2_trn1;                
    wire              fsm2_trn2;                
    wire              fsm2_update_dr;           
    wire              fsm2_update_ir;           
    wire              fsm2_update_vld;          
    wire              fsm5_capture_dr;    
    wire              fsm5_capture_ir;                
    wire              fsm5_shift_dr;            
    wire              fsm5_shift_ir;            
    wire              fsm5_update_dr;           
    wire              fsm5_update_ir; 
    wire              fsm5_tap_reset;
    wire              fsm2_rs_had_dr_dmiacc_sel;
    wire              tap2_rst_vld;
    wire              tms_i;
    wire [7:0]        counter_value_dmiacc;
    wire [7:0]        counter_value_dmi;
    wire [7:0]        counter_value_ndmi;
    wire [7:0]        counter_value_ir;
    assign tms_i = pad_dtm_tms_i;
    assign jtag2_sel = pad_dtm_jtag2_sel;
    
    //==============================================================================
    //                    TAP5 controller state machine
    //==============================================================================
    localparam TAP5_RESET          = 4'b0000;
    localparam TAP5_IDLE           = 4'b0001;
    localparam TAP5_SELECT_DR_SCAN = 4'b0011;
    localparam TAP5_SELECT_IR_SCAN = 4'b0010;
    localparam TAP5_CAPTURE_IR     = 4'b0110;
    localparam TAP5_SHIFT_IR       = 4'b0100;
    localparam TAP5_EXIT1_IR       = 4'b0101;
    localparam TAP5_UPDATE_IR      = 4'b0111;
    localparam TAP5_CAPTURE_DR     = 4'b1011;
    localparam TAP5_SHIFT_DR       = 4'b1010;
    localparam TAP5_EXIT1_DR       = 4'b1000;
    localparam TAP5_UPDATE_DR      = 4'b1001;
    localparam TAP5_PAUSE_IR       = 4'b1101;
    localparam TAP5_EXIT2_IR       = 4'b1111;
    localparam TAP5_PAUSE_DR       = 4'b1100;
    localparam TAP5_EXIT2_DR       = 4'b1110;
    
    always @ (posedge tclk or negedge trst_b) begin
        if (~trst_b)
            tap5_cur_st[3:0] <= TAP5_RESET;
        else if (jtag2_sel)
            tap5_cur_st[3:0] <= TAP5_RESET;
        else 
            tap5_cur_st[3:0] <= tap5_nxt_st[3:0];
    end
    
    always @ (tap5_cur_st[3:0] or
              io_ctrl_tap_en or
              tms_i) begin
        case(tap5_cur_st[3:0])
            TAP5_RESET:
                if (io_ctrl_tap_en & ~tms_i)
                    tap5_nxt_st[3:0] = TAP5_IDLE;
                else
                    tap5_nxt_st[3:0] = TAP5_RESET;
            TAP5_IDLE:
                if (tms_i)      
                    tap5_nxt_st[3:0] = TAP5_SELECT_DR_SCAN;
                else
                    tap5_nxt_st[3:0] = TAP5_IDLE;
            TAP5_SELECT_DR_SCAN:
                if (tms_i)
                    tap5_nxt_st[3:0] = TAP5_SELECT_IR_SCAN;
                else
                    tap5_nxt_st[3:0] = TAP5_CAPTURE_DR;
            TAP5_SELECT_IR_SCAN:
                if (~tms_i)
                    tap5_nxt_st[3:0] = TAP5_CAPTURE_IR;
                else
                    tap5_nxt_st[3:0] = TAP5_RESET;
            TAP5_CAPTURE_IR:
                if (~tms_i)
                    tap5_nxt_st[3:0] = TAP5_SHIFT_IR;
                else
                    tap5_nxt_st[3:0] = TAP5_EXIT1_IR;
            TAP5_SHIFT_IR: 
                if (tms_i)
                    tap5_nxt_st[3:0] = TAP5_EXIT1_IR;
                else
                    tap5_nxt_st[3:0] = TAP5_SHIFT_IR;
            TAP5_EXIT1_IR:
                if (tms_i)
                    tap5_nxt_st[3:0] = TAP5_UPDATE_IR;
                else
                    tap5_nxt_st[3:0] = TAP5_PAUSE_IR;
            TAP5_PAUSE_IR:
                if (tms_i)
                    tap5_nxt_st[3:0] = TAP5_EXIT2_IR;
                else
                    tap5_nxt_st[3:0] = TAP5_PAUSE_IR;
            TAP5_EXIT2_IR:
                if (tms_i)
                    tap5_nxt_st[3:0] = TAP5_UPDATE_IR;
                else
                    tap5_nxt_st[3:0] = TAP5_SHIFT_IR;
            TAP5_UPDATE_IR:
                if (tms_i)
                    tap5_nxt_st[3:0] = TAP5_SELECT_DR_SCAN;
                else
                    tap5_nxt_st[3:0] = TAP5_IDLE;
            TAP5_CAPTURE_DR: 
                if (~tms_i)
                    tap5_nxt_st[3:0] = TAP5_SHIFT_DR;
                else
                    tap5_nxt_st[3:0] = TAP5_EXIT1_DR;
            TAP5_SHIFT_DR:
                if (tms_i)
                    tap5_nxt_st[3:0] = TAP5_EXIT1_DR;
                else
                    tap5_nxt_st[3:0] = TAP5_SHIFT_DR;
            TAP5_EXIT1_DR:
                if (~tms_i)
                    tap5_nxt_st[3:0] = TAP5_PAUSE_DR;
                else
                    tap5_nxt_st[3:0] = TAP5_UPDATE_DR;
            TAP5_PAUSE_DR:
                if (tms_i)
                    tap5_nxt_st[3:0] = TAP5_EXIT2_DR;
                else
                    tap5_nxt_st[3:0] = TAP5_PAUSE_DR;
            TAP5_EXIT2_DR:
                if (tms_i)
                    tap5_nxt_st[3:0] = TAP5_UPDATE_DR;
                else
                    tap5_nxt_st[3:0] = TAP5_SHIFT_DR;
            TAP5_UPDATE_DR:
                if (tms_i)
                    tap5_nxt_st[3:0] = TAP5_SELECT_DR_SCAN;
                else
                    tap5_nxt_st[3:0] = TAP5_IDLE;
            default:
                tap5_nxt_st[3:0] = TAP5_RESET;
        endcase
    end
    
    //=============================================
    // TAP5 status
    //=============================================
    assign fsm5_shift_ir   = (tap5_cur_st[3:0] == TAP5_SHIFT_IR);
    assign fsm5_update_ir  = (tap5_cur_st[3:0] == TAP5_UPDATE_IR);
    assign fsm5_shift_dr   = (tap5_cur_st[3:0] == TAP5_SHIFT_DR);
    assign fsm5_update_dr  = (tap5_cur_st[3:0] == TAP5_UPDATE_DR);
    assign fsm5_capture_dr = (tap5_cur_st[3:0] == TAP5_CAPTURE_DR);
    assign fsm5_capture_ir = (tap5_cur_st[3:0] == TAP5_CAPTURE_IR);
    assign fsm5_tap_reset  = (tap5_cur_st[3:0] == TAP5_RESET) & ~jtag2_sel;

    //=============================================
    // TDO output enable in JTAG_5 interafce
    //=============================================
    always @ (negedge tclk or negedge trst_b) begin
        if (~trst_b)
            tdo_en <= 1'b0;
        else if (fsm5_shift_dr | fsm5_shift_ir)
            tdo_en <= 1'b1;
        else
            tdo_en <= 1'b0;
    end
    
    assign ctrl_io_tdo_en = tdo_en;
    
    //==============================================================================
    //                    TAP2 controller state machine
    //==============================================================================
    parameter TAP2_RESET  = 4'b0000;
    parameter TAP2_START  = 4'b0001;
    parameter TAP2_RW     = 4'b0010;
    parameter TAP2_RS     = 4'b0011;
    parameter TAP2_TRN1   = 4'b0100;
    parameter TAP2_DATA   = 4'b0101;
    parameter TAP2_SYNC   = 4'b0110; 
    parameter TAP2_PARITY = 4'b0111;
    parameter TAP2_TRN2   = 4'b1000;
    
    always @ (posedge tclk or negedge trst_b) begin
        if (~trst_b)
            tap2_cur_st[3:0] <= TAP2_RESET;
        else if ((tap2_rst_vld & tms_i) | (~jtag2_sel))
            tap2_cur_st[3:0] <= TAP2_RESET;
        else
            tap2_cur_st[3:0] <= tap2_nxt_st[3:0];
    end
    
    //========================================
    // counter is counting dowwn when
    // TMS id high and TCLK is valid
    //========================================
    always @ (posedge tclk or negedge trst_b) begin
        if (~trst_b)
            tap2_rst_cnt[6:0] <= DTM_FSM2_RSTCNT;
        else if (~jtag2_sel)
            tap2_rst_cnt[6:0] <= DTM_FSM2_RSTCNT;
        else if (~tms_i)
            tap2_rst_cnt[6:0] <= DTM_FSM2_RSTCNT;
        else if (tap2_rst_cnt[6:0] > 7'd0)
            tap2_rst_cnt[6:0] <= tap2_rst_cnt[6:0] - 7'd1;
        else
            tap2_rst_cnt[6:0] <= DTM_FSM2_RSTCNT;
    end
    
    assign tap2_rst_vld = (tap2_rst_cnt[6:0] == 7'd00);
    
    always @ (tap2_cur_st[3:0] or
              io_ctrl_tap_en or
              tms_i or
              fsm2_rs_counter[1:0] or
              fsm2_read_vld or
              fsm2_data_counter[7:0]
              ) begin
        case (tap2_cur_st[3:0])
            TAP2_RESET : begin
                if (io_ctrl_tap_en & tms_i) 
                    tap2_nxt_st[3:0] = TAP2_START;
                else 
                    tap2_nxt_st[3:0] = TAP2_RESET;
            end
    
            TAP2_START : begin // wait for START bit (tms = 0)
                if (~tms_i) // sample START bit, logic 0
                    tap2_nxt_st[3:0] = TAP2_RW;
                else
                    tap2_nxt_st[3:0] = TAP2_START;
            end
    
            TAP2_RW : begin  // RnW bit, 1=Read Op, 0=Write Op
                tap2_nxt_st[3:0] = TAP2_RS;
            end
    
            TAP2_RS : begin // RS[1:0] - Register Group Select
                if (fsm2_rs_counter[1:0] == 2'd0)
                    tap2_nxt_st[3:0] = TAP2_TRN1;
                else
                    tap2_nxt_st[3:0] = TAP2_RS;
            end
    
            TAP2_TRN1 : begin // Turn Around 1
                if (fsm2_read_vld)  // Read operation need a sync cycle
                    tap2_nxt_st[3:0] = TAP2_SYNC;
                else               // write operation
                    tap2_nxt_st[3:0] = TAP2_DATA;
            end
    
            TAP2_SYNC : begin
                tap2_nxt_st[3:0] = TAP2_DATA;
            end
    
            TAP2_DATA : begin // IR or DR, Sample or Set
                if (fsm2_data_counter[7:0] == 8'd0)
                    tap2_nxt_st[3:0] = TAP2_PARITY;
                else
                    tap2_nxt_st[3:0] = TAP2_DATA;
            end
    
            TAP2_PARITY : begin
                tap2_nxt_st[3:0] = TAP2_TRN2;
            end
    
            TAP2_TRN2 : begin
                tap2_nxt_st[3:0] = TAP2_START;
            end
            default : begin
                tap2_nxt_st[3:0] = TAP2_RESET;
            end
        endcase
    end
    
    assign fsm2_start_vld  = (tap2_cur_st[3:0] == TAP2_RW);
    assign fsm2_load_rw    = (tap2_cur_st[3:0] == TAP2_RW);
    assign fsm2_load_rs    = (tap2_cur_st[3:0] == TAP2_RS);
    assign fsm2_trn1       = (tap2_cur_st[3:0] == TAP2_TRN1);
    assign fsm2_trn2       = (tap2_cur_st[3:0] == TAP2_TRN2);
    assign fsm2_shift_vld  = (tap2_cur_st[3:0] == TAP2_DATA);
    assign fsm2_update_vld = (tap2_cur_st[3:0] == TAP2_TRN2);
    assign fsm2_parity_vld = (tap2_cur_st[3:0] == TAP2_PARITY);
    assign fsm2_sync_vld   = (tap2_cur_st[3:0] == TAP2_SYNC);
    
    //=========================================
    // load the RW
    //=========================================
    always @ (posedge tclk) begin
        if (fsm2_load_rw)
            fsm2_read_vld <= tms_i;
    end
    
    //===========================================
    // load the RS[1:0]
    //===========================================
    always @ (posedge tclk) begin
        if (fsm2_start_vld)
            fsm2_rs_counter[1:0] <= 2'd1;
        else if (fsm2_load_rs) 
            fsm2_rs_counter[1:0] <= fsm2_rs_counter[1:0] - 2'd1;
        else
            fsm2_rs_counter[1:0] <= fsm2_rs_counter[1:0];
    end
    
    always @ (posedge tclk) begin
        if (fsm2_load_rs)
            fsm2_rs[1:0] <= {tms_i, fsm2_rs[1]};
        else
            fsm2_rs[1:0] <= fsm2_rs[1:0];
    end
    
    assign fsm2_rs_had_ir_sel        = fsm2_rs[1:0] == 2'b10;   //IR
    assign fsm2_rs_had_dr_sel        = fsm2_rs[1:0] == 2'b11;   //DR
    assign fsm2_rs_had_dr_dmiacc_sel = fsm2_rs_had_dr_sel & (idr_chain_ir[DTM_IRREG_WIDTH-1:0] == DMI_ACC);
    assign fsm2_rs_had_dr_dmi_sel    = fsm2_rs_had_dr_sel & (idr_chain_ir[DTM_IRREG_WIDTH-1:0] == DMI);
    assign fsm2_rs_had_dr_ndmi_sel   = fsm2_rs_had_dr_sel & (idr_chain_ir[DTM_IRREG_WIDTH-1:0] == IDCODE | idr_chain_ir[DTM_IRREG_WIDTH-1:0] == DTMCS);

    //===========================================
    // intialize DATA shift length
    //===========================================
    always @ (posedge tclk) begin
        if (fsm2_trn1) begin
            if (fsm2_rs_had_dr_dmiacc_sel)
                fsm2_data_counter[7:0] <= {8{1'b0}}; //DTM_DMIACCREG_WIDTH - 1'b1
            else if (fsm2_rs_had_dr_dmi_sel) begin
                if (idr_dmi_mode)
                    fsm2_data_counter[7:0] <= counter_value_dmiacc[7:0]; //34 - 1, to fix lint
                else 
                    fsm2_data_counter[7:0] <= counter_value_dmi[7:0]; //50 - 1, to fix lint
            end else if (fsm2_rs_had_dr_ndmi_sel)
                fsm2_data_counter[7:0] <= counter_value_ndmi[7:0]; //32 - 1, to fix lint
            else if (fsm2_rs_had_ir_sel) 
                fsm2_data_counter[7:0] <= counter_value_ir[7:0]; //5 - 1, to fix lint
            else
                fsm2_data_counter[7:0] <= {8{1'b0}};
        end
        else if (fsm2_shift_vld)
            fsm2_data_counter[7:0] <= fsm2_data_counter[7:0] - {{7{1'b0}},1'b1};
    end
   
    assign counter_value_dmiacc[7:0] = $unsigned(DTM_DMIREG_ACC_WIDTH-1) & {8{1'b1}}; //34 -1
    assign counter_value_dmi[7:0]    = $unsigned(DTM_DMIREG_WIDTH-1) & {8{1'b1}}; //44 -1
    assign counter_value_ndmi[7:0]   = $unsigned(DTM_NDMIREG_WIDTH-1) & {8{1'b1}}; //32-1
    assign counter_value_ir[7:0]     = $unsigned(DTM_IRREG_WIDTH-1) & {8{1'b1}}; //5-1

    //================================================
    // TMS output Enable
    //================================================
    always @ (posedge tclk or negedge trst_b) begin
        if (~trst_b)
            tms_oe <= 1'b0; // default is input
        else if (fsm2_trn1 & fsm2_read_vld)
            tms_oe <= 1'b1;
        else if (fsm2_trn2)
            tms_oe <= 1'b0;
        else
            tms_oe <= tms_oe;
    end
    
    assign ctrl_io_tms_oe = tms_oe;
    
    //================================================
    // Parity Check
    //================================================
    always @ (posedge tclk) begin
        if (fsm2_start_vld)
            fsm2_parity <= 1'b1;
        else if ((fsm2_rs_had_dr_sel | fsm2_rs_had_ir_sel) & fsm2_shift_vld)
            fsm2_parity <= fsm2_parity ^ tms_i; // calculate the parity bit
        else if (fsm2_parity_vld)
            fsm2_parity <= fsm2_parity ^ tms_i; // check received parity bit
        else
            fsm2_parity <= fsm2_parity;
    end
    
    assign fsm2_shift_ir   = fsm2_rs_had_ir_sel & fsm2_shift_vld;
    assign fsm2_shift_dr   = fsm2_rs_had_dr_sel & fsm2_shift_vld;
    assign fsm2_capture_dr = fsm2_rs_had_dr_sel & fsm2_read_vld & fsm2_trn1;
    assign fsm2_capture_ir = fsm2_rs_had_ir_sel & fsm2_read_vld & fsm2_trn1;
    assign fsm2_update_ir  = fsm2_update_vld & (~fsm2_read_vld) & fsm2_rs_had_ir_sel & (~fsm2_parity);
    assign fsm2_update_dr  = fsm2_update_vld & (~fsm2_read_vld) & fsm2_rs_had_dr_sel & (~fsm2_parity);
    
    assign ctrl_chain_shift_ir   = fsm5_shift_ir | fsm2_shift_ir;
    assign ctrl_chain_shift_dr   = fsm5_shift_dr | fsm2_shift_dr;
    assign ctrl_chain_capture_dr = fsm5_capture_dr | fsm2_capture_dr;
    assign ctrl_chain_capture_ir = fsm5_capture_ir | fsm2_capture_ir;
    assign ctrl_chain_shift_par  = fsm2_parity_vld;
    assign ctrl_chain_shift_sync = fsm2_sync_vld;
    assign ctrl_idr_update_ir    = fsm5_update_ir | fsm2_update_ir;
    assign ctrl_idr_update_dr    = fsm5_update_dr | fsm2_update_dr;
    assign ctrl_idr_capture_dr   = fsm5_capture_dr | fsm2_capture_dr;
    assign ctrl_idr_tap_reset    = fsm5_tap_reset;

    `ifdef TDT_ASSERTION
     property jtag2_read_not_update_idr;
      @(posedge tclk) (jtag2_sel & fsm2_read_vld) |-> ~(fsm2_update_ir | fsm2_update_dr);
    endproperty
    assert property(jtag2_read_not_update_idr);   

    property jtag2_write_not_capture_idr;
      @(posedge tclk) (jtag2_sel & ~fsm2_read_vld) |-> ~(fsm2_capture_ir | fsm2_capture_dr);
    endproperty
    assert property(jtag2_write_not_capture_idr);

    property dmihardreset_cannot_reset_tap_fsm;
      @(posedge tclk) (~jtag2_sel & dmihardreset) |=> ~(tap5_cur_st[3:0] == TAP5_RESET);
    endproperty
    assert property(dmihardreset_cannot_reset_tap_fsm);

    `endif
endmodule






// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : tdt_dmi_dtm_idr.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-6
// FUNCTION        : tdt_dmi_dtm_idr.v
// ******************************************************************************

module tdt_dmi_dtm_idr #(
    parameter                           DTM_IRREG_WIDTH   = 5,
    parameter                           DTM_ABITS         = 16,    
    parameter                           DTM_NDMIREG_WIDTH = 32,
    parameter                           CHAIN_DW          = DTM_ABITS + 32 + 2

)(
    input                               tclk,                 
    input                               trst_b, 
    output     [CHAIN_DW-1:0]           idr_chain_dr, 
    output     [DTM_IRREG_WIDTH-1:0]    idr_chain_ir, 
    input      [CHAIN_DW-1:0]           chain_idr_data,
    output                              idr_dmi_mode,     
    input                               ctrl_idr_update_ir,       
    input                               ctrl_idr_update_dr,
    input                               ctrl_idr_capture_dr,
    input                               ctrl_idr_tap_reset,
    output reg                          dmihardreset,

    output                              dtm_apbm_wr_vld,
    output     [DTM_ABITS-1:0]          dtm_apbm_wr_addr,
    output     [1:0]                    dtm_apbm_wr_flg,
    output     [31:0]                   dtm_apbm_wdata,
    input      [31:0]                   apbm_dtm_rdata,
    input                               apbm_dtm_wr_ready
);

    localparam  [DTM_IRREG_WIDTH-1:0]   IDCODE               = 5'h01;
    localparam  [DTM_IRREG_WIDTH-1:0]   DMI_ACC              = 5'h02;
    localparam  [DTM_IRREG_WIDTH-1:0]   DTMCS                = 5'h10;
    localparam  [DTM_IRREG_WIDTH-1:0]   DMI                  = 5'h11;
    localparam  [DTM_NDMIREG_WIDTH-1:0] IDCODE_REG_DEFINE    = {4'h1, {16{1'b0}}, 12'b1011_011_0111_1};
    localparam  [3:0]                   DTM_VERSION          = 4'h1;
    localparam  [2:0]                   IDLE_CYCLE           = `TDT_DMI_IDLE_CYCLE;
    
    reg  [DTM_IRREG_WIDTH-1:0]   dtm_ir;
    wire [DTM_NDMIREG_WIDTH-1:0] dtm_idcode;
    //reg                          dmihardreset;
    reg                          dmireset;
    wire [2:0]                   idle;
    wire [1:0]                   dmistat;
    wire [5:0]                   abits;
    wire [3:0]                   version;
    reg  [DTM_ABITS-1:0]         address;
    reg  [31:0]                  data;
    reg  [1:0]                   op;
    reg                          mode;
    reg  [1:0]                   op_stat;
    reg                          wr_vld;
    reg                          dmi_req_running;
    reg  [CHAIN_DW-1:0]          data_out;
   
    wire                         capture_dmi_in_running;
    wire [CHAIN_DW-1:0]          dmi_total;

    always @ (posedge tclk or negedge trst_b) begin
        if (~trst_b) 
            dtm_ir[DTM_IRREG_WIDTH-1:0] <= IDCODE;
        else if(ctrl_idr_tap_reset)
            dtm_ir[DTM_IRREG_WIDTH-1:0] <= IDCODE;
        else if (ctrl_idr_update_ir) 
            dtm_ir[DTM_IRREG_WIDTH-1:0] <= chain_idr_data[DTM_IRREG_WIDTH-1:0];
     
    end
    
    assign dtm_idcode[DTM_NDMIREG_WIDTH-1:0] = IDCODE_REG_DEFINE;
    
    assign idle[2:0]         = IDLE_CYCLE;
    assign dmistat[1:0]      = op_stat[1:0];
    assign abits[5:0]        = DTM_ABITS;
    assign version[3:0]      = DTM_VERSION;
   
    always @ (posedge tclk or negedge trst_b) begin
        if (~trst_b) 
            dmihardreset <= 1'b0;
        else if (dmihardreset)
            dmihardreset <= 1'b0;
        else if (ctrl_idr_update_dr & dtm_ir[DTM_IRREG_WIDTH-1:0] ==  DTMCS) 
            dmihardreset <= chain_idr_data[17];
    end

    always @ (posedge tclk or negedge trst_b) begin
        if (~trst_b) 
            dmireset <= 1'b0;
        else if (dmihardreset)
            dmireset <= 1'b0;
        else if (dmireset)
            dmireset <= 1'b0;
        else if (ctrl_idr_update_dr & dtm_ir[DTM_IRREG_WIDTH-1:0] ==  DTMCS) 
            dmireset <= chain_idr_data[16];
    end
 
    always @ (posedge tclk or negedge trst_b) begin
        if (~trst_b) 
            mode <= 1'b0;
        else if (dmihardreset)
            mode <= 1'b0;
        else if (ctrl_idr_update_dr & dtm_ir[DTM_IRREG_WIDTH-1:0] ==  DMI_ACC) 
            mode <= chain_idr_data[0];
    end
    
    always @ (posedge tclk or negedge trst_b) begin
        if (~trst_b) 
            address[DTM_ABITS-1:0] <= {DTM_ABITS{1'b0}};
        else if (dmihardreset)
            address[DTM_ABITS-1:0] <= {DTM_ABITS{1'b0}};
        else if (ctrl_idr_update_dr & ~mode & dtm_ir[DTM_IRREG_WIDTH-1:0] ==  DMI & ~dmi_req_running)
            address[DTM_ABITS-1:0] <= chain_idr_data[34 +: DTM_ABITS];
    end
    
    always @ (posedge tclk or negedge trst_b) begin
        if (~trst_b) 
            data[31:0] <= {32{1'b0}};
        else if (dmihardreset)
            data[31:0] <= {32{1'b0}};
        else if (ctrl_idr_update_dr & dtm_ir[DTM_IRREG_WIDTH-1:0] ==  DMI & ~dmi_req_running) 
            data[31:0] <= chain_idr_data[33:2];
        else if (apbm_dtm_wr_ready & op[1:0] == 2'b01)
        //else if (apbm_dtm_wr_ready)
            data[31:0] <= apbm_dtm_rdata[31:0];
    end
    
    always @ (posedge tclk or negedge trst_b) begin
        if (~trst_b) 
            op[1:0] <= 2'b00;
        else if (dmihardreset)
            op[1:0] <= 2'b00;
        else if (ctrl_idr_update_dr & dtm_ir[DTM_IRREG_WIDTH-1:0] ==  DMI & ~dmi_req_running) 
            op[1:0] <= chain_idr_data[1:0];
    end
    
    always @ (posedge tclk or negedge trst_b) begin
        if (~trst_b) 
            wr_vld <= 1'b0;
        else if (dmihardreset)
            wr_vld <= 1'b0;
        else if (wr_vld)
            wr_vld <= 1'b0;
        else if (ctrl_idr_update_dr & dtm_ir[DTM_IRREG_WIDTH-1:0] ==  DMI & (^chain_idr_data[1:0])
                 & op_stat[1:0] == 2'b00 & ~dmi_req_running) 
            wr_vld <= 1'b1;
    end
   
    always @ (posedge tclk or negedge trst_b) begin
        if (~trst_b) 
            dmi_req_running <= 1'b0;
        else if (dmihardreset)
            dmi_req_running <= 1'b0;
        else if (apbm_dtm_wr_ready)
            dmi_req_running <= 1'b0;
        else if (wr_vld) 
            dmi_req_running <= 1'b1;
    end

    assign capture_dmi_in_running = dmi_req_running & ctrl_idr_capture_dr & dtm_ir[DTM_IRREG_WIDTH-1:0] ==  DMI;

    always @ (posedge tclk or negedge trst_b) begin
        if (~trst_b) 
            op_stat[1:0] <= 2'b00;
        else if (dmihardreset)
            op_stat[1:0] <= 2'b00;
        else if (dmireset)
            op_stat[1:0] <= 2'b00;
        else if (dmi_req_running & ctrl_idr_update_dr & dtm_ir[DTM_IRREG_WIDTH-1:0] ==  DMI & (^chain_idr_data[1:0]) |
                 capture_dmi_in_running) 
            op_stat[1:0] <= 2'b11;
    end

    assign dmi_total[CHAIN_DW-1:0] = capture_dmi_in_running ? {address[DTM_ABITS-1:0], data[31:0], 2'b11} : {address[DTM_ABITS-1:0], data[31:0], op_stat[1:0]};
    
    //generate 
    //    if ((CHAIN_DW-DTM_ABITS-34) == 0) begin : gen_full_dmi
    //        assign dmi_total = {address, data, op_stat};
    //    end else begin : gen_pad_dmi
    //        assign dmi_total = {{CHAIN_DW-DTM_ABITS-34{1'b0}}, address, data, op_stat};
    //    end
    //endgenerate

    always @ (dtm_ir[DTM_IRREG_WIDTH-1:0] or
              dtm_idcode[DTM_NDMIREG_WIDTH-1:0] or
              mode or
              idle[2:0] or
              dmistat[1:0] or
              abits[5:0] or
              version[3:0] or
              dmi_total[CHAIN_DW-1:0]
              ) begin
        case (dtm_ir[DTM_IRREG_WIDTH-1:0])
            IDCODE  : data_out[CHAIN_DW-1:0] = {{CHAIN_DW-DTM_NDMIREG_WIDTH{1'b0}}, dtm_idcode[DTM_NDMIREG_WIDTH-1:0]};
            DMI_ACC : data_out[CHAIN_DW-1:0] = {{CHAIN_DW-1{1'b0}}, mode};
            DTMCS   : data_out[CHAIN_DW-1:0] = {{CHAIN_DW-15{1'b0}}, idle[2:0], dmistat[1:0], abits[5:0], version[3:0]};
            DMI     : data_out[CHAIN_DW-1:0] = dmi_total[CHAIN_DW-1:0];
            default : data_out[CHAIN_DW-1:0] = {CHAIN_DW{1'b0}};
        endcase
    end
   
    assign idr_dmi_mode                      = mode; 
    assign idr_chain_dr[CHAIN_DW-1:0]        = data_out[CHAIN_DW-1:0];
    assign idr_chain_ir[DTM_IRREG_WIDTH-1:0] = dtm_ir[DTM_IRREG_WIDTH-1:0];
    assign dtm_apbm_wr_vld                   = wr_vld;
    assign dtm_apbm_wr_flg[1:0]              = op[1:0];
    assign dtm_apbm_wr_addr[DTM_ABITS-1:0]   = address[DTM_ABITS-1:0];
    assign dtm_apbm_wdata[31:0]              = data[31:0];

    `ifdef TDT_ASSERTION
     property update_dr_in_dmi_running_cannot_change_dmi_address;
      @(posedge tclk) (dmi_req_running & ~dmihardreset) |-> $stable(address[DTM_ABITS-1:0]);
    endproperty
    assert property(update_dr_in_dmi_running_cannot_change_dmi_address);   

    property update_dr_in_dmi_running_cannot_change_dmi_op;
      @(posedge tclk) (dmi_req_running & ~dmihardreset) |-> $stable(op[1:0]);
    endproperty
    assert property(update_dr_in_dmi_running_cannot_change_dmi_op);

    property update_dr_in_dmi_running_cannot_change_dmi_data;
      @(posedge tclk) (dmi_req_running & ~dmihardreset & ~apbm_dtm_wr_ready) |-> $stable(data[31:0]);
    endproperty
    assert property(update_dr_in_dmi_running_cannot_change_dmi_data);

    property update_dr_in_dmi_running_cannot_start_a_new_operation;
      @(posedge tclk) (dmi_req_running & ~dmihardreset) |=> $stable(wr_vld);
    endproperty
    assert property(update_dr_in_dmi_running_cannot_start_a_new_operation);

    property set_op_when_capture_dr_in_dmi_running;
      @(posedge tclk) (dmi_req_running & ctrl_idr_capture_dr & dtm_ir ==  DMI) |-> (dmi_total[1:0] == 2'b11);
    endproperty
    assert property(set_op_when_capture_dr_in_dmi_running);

    property dmihardreset_cannot_reset_ir;
      @(posedge tclk) dmihardreset |=> $stable(dtm_ir[DTM_IRREG_WIDTH-1:0]);
    endproperty
    assert property(dmihardreset_cannot_reset_ir);
    `endif

endmodule
// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : tdt_dmi_dtm_io.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-6
// FUNCTION        : tdt_dmi_dtm_io.v
// ******************************************************************************

module tdt_dmi_dtm_io(      
    input          pad_dtm_jtag2_sel,         
    input          pad_dtm_tap_en,        
    input          pad_dtm_tdi,           
    input          pad_dtm_tms_i,  
    output         dtm_pad_tdo,           
    output         dtm_pad_tdo_en,        
    output         dtm_pad_tms_o,         
    output         dtm_pad_tms_oe,        
    input          chain_io_tdo,             
    input          ctrl_io_tdo_en,              
    input          ctrl_io_tms_oe,                          
    output         io_chain_tdi,             
    output         io_ctrl_tap_en
);

    assign io_ctrl_tap_en = pad_dtm_tap_en;
    assign io_chain_tdi   = pad_dtm_jtag2_sel ? pad_dtm_tms_i : pad_dtm_tdi;
    assign dtm_pad_tdo    = chain_io_tdo;
    assign dtm_pad_tms_o  = chain_io_tdo;
    assign dtm_pad_tdo_en = ctrl_io_tdo_en;
    assign dtm_pad_tms_oe = ctrl_io_tms_oe;

endmodule



// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : tdt_dmi_dtm_top.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-6
// FUNCTION        : tdt_dmi_dtm_top.v
// ******************************************************************************

module tdt_dmi_dtm_top #(
    parameter                        DTM_ABITS = 16
)(
    input                            pad_dtm_tclk,
    input                            pad_dtm_trst_b,
    input                            pad_dtm_jtag2_sel,         
    input                            pad_dtm_tap_en,        
    input                            pad_dtm_tdi,           
    input                            pad_dtm_tms_i,  
    output                           dtm_pad_tdo,           
    output                           dtm_pad_tdo_en,        
    output                           dtm_pad_tms_o,         
    output                           dtm_pad_tms_oe,

    output                           dtm_apbm_wr_vld,
    output  [DTM_ABITS-1:0]          dtm_apbm_wr_addr,
    output  [1:0]                    dtm_apbm_wr_flg,
    output  [31:0]                   dtm_apbm_wdata,
    output                           dmihardreset,
    input   [31:0]                   apbm_dtm_rdata,
    input                            apbm_dtm_wr_ready
);

    localparam                           DTM_NDMIREG_WIDTH    = 32;
    localparam                           DTM_IRREG_WIDTH      = 5; 
    localparam                           DTM_FSM2_RSTCNT      = 80; 
    localparam                           CHAIN_DW             = DTM_ABITS + 32 + 2;
    
    wire                                 chain_io_tdo;             
    wire                                 ctrl_io_tdo_en;              
    wire                                 ctrl_io_tms_oe;                          
    wire                                 io_chain_tdi;             
    wire                                 io_ctrl_tap_en;
    wire                                 idr_dmi_mode;
    wire                                 ctrl_chain_capture_dr;  
    wire                                 ctrl_chain_capture_ir;   
    wire                                 ctrl_idr_update_ir;       
    wire                                 ctrl_idr_update_dr;
    wire                                 ctrl_idr_capture_dr;
    wire                                 ctrl_idr_tap_reset;
    wire                                 ctrl_chain_shift_dr;      
    wire                                 ctrl_chain_shift_ir;      
    wire                                 ctrl_chain_shift_par;     
    wire                                 ctrl_chain_shift_sync;
    wire  [CHAIN_DW-1:0]                 idr_chain_dr; 
    wire  [DTM_IRREG_WIDTH-1:0]          idr_chain_ir; 
    wire  [CHAIN_DW-1:0]                 chain_idr_data;      

    tdt_dmi_dtm_io x_tdt_dmi_dtm_io (      
        .pad_dtm_jtag2_sel               (pad_dtm_jtag2_sel),         
        .pad_dtm_tap_en                  (pad_dtm_tap_en),        
        .pad_dtm_tdi                     (pad_dtm_tdi),           
        .pad_dtm_tms_i                   (pad_dtm_tms_i),  
        .dtm_pad_tdo                     (dtm_pad_tdo),           
        .dtm_pad_tdo_en                  (dtm_pad_tdo_en),        
        .dtm_pad_tms_o                   (dtm_pad_tms_o),         
        .dtm_pad_tms_oe                  (dtm_pad_tms_oe),        
        .chain_io_tdo                    (chain_io_tdo),             
        .ctrl_io_tdo_en                  (ctrl_io_tdo_en),              
        .ctrl_io_tms_oe                  (ctrl_io_tms_oe),                          
        .io_chain_tdi                    (io_chain_tdi),             
        .io_ctrl_tap_en                  (io_ctrl_tap_en)
    );
    
    tdt_dmi_dtm_ctrl #(
        .DTM_ABITS                       (DTM_ABITS),   
        .DTM_NDMIREG_WIDTH               (DTM_NDMIREG_WIDTH),
        .DTM_IRREG_WIDTH                 (DTM_IRREG_WIDTH),
        .DTM_FSM2_RSTCNT                 (DTM_FSM2_RSTCNT[6:0])
    ) x_tdt_dmi_dtm_ctrl (
        .tclk                            (pad_dtm_tclk),                    
        .trst_b                          (pad_dtm_trst_b),
        .dmihardreset                    (dmihardreset), 
        .io_ctrl_tap_en                  (io_ctrl_tap_en),            
        .pad_dtm_jtag2_sel               (pad_dtm_jtag2_sel),       
        .pad_dtm_tms_i                   (pad_dtm_tms_i),   
        .idr_dmi_mode                    (idr_dmi_mode),
        .idr_chain_ir                    (idr_chain_ir[DTM_IRREG_WIDTH-1:0]),
        .ctrl_io_tdo_en                  (ctrl_io_tdo_en),            
        .ctrl_io_tms_oe                  (ctrl_io_tms_oe),            
        .ctrl_chain_capture_dr           (ctrl_chain_capture_dr), 
        .ctrl_chain_capture_ir           (ctrl_chain_capture_ir),     
        .ctrl_idr_update_ir              (ctrl_idr_update_ir),       
        .ctrl_idr_update_dr              (ctrl_idr_update_dr),
        .ctrl_idr_capture_dr             (ctrl_idr_capture_dr),
        .ctrl_idr_tap_reset              (ctrl_idr_tap_reset),
        .ctrl_chain_shift_dr             (ctrl_chain_shift_dr),      
        .ctrl_chain_shift_ir             (ctrl_chain_shift_ir),      
        .ctrl_chain_shift_par            (ctrl_chain_shift_par),     
        .ctrl_chain_shift_sync           (ctrl_chain_shift_sync)
    );
    
    tdt_dmi_dtm_chain #(
        .CHAIN_DW                        (CHAIN_DW),          
        .DTM_IRREG_WIDTH                 (DTM_IRREG_WIDTH),   
        .DTM_ABITS                       (DTM_ABITS),             
        .DTM_NDMIREG_WIDTH               (DTM_NDMIREG_WIDTH) 
    ) x_tdt_dmi_dtm_chain (
        .tclk                            (pad_dtm_tclk),                 
        .trst_b                          (pad_dtm_trst_b),   
        .dmihardreset                    (dmihardreset), 
        .io_chain_tdi                    (io_chain_tdi),
        .chain_io_tdo                    (chain_io_tdo),
        .idr_chain_dr                    (idr_chain_dr), 
        .idr_chain_ir                    (idr_chain_ir), 
        .chain_idr_data                  (chain_idr_data),      
        .idr_dmi_mode                    (idr_dmi_mode),
        .ctrl_chain_capture_dr           (ctrl_chain_capture_dr),  
        .ctrl_chain_capture_ir           (ctrl_chain_capture_ir),    
        .ctrl_chain_shift_dr             (ctrl_chain_shift_dr),      
        .ctrl_chain_shift_ir             (ctrl_chain_shift_ir),      
        .ctrl_chain_shift_par            (ctrl_chain_shift_par),     
        .ctrl_chain_shift_sync           (ctrl_chain_shift_sync)
    );
    
    tdt_dmi_dtm_idr #(
        .CHAIN_DW                        (CHAIN_DW),          
        .DTM_IRREG_WIDTH                 (DTM_IRREG_WIDTH),   
        .DTM_ABITS                       (DTM_ABITS[5:0]),             
        .DTM_NDMIREG_WIDTH               (DTM_NDMIREG_WIDTH) 
    ) x_tdt_dmi_dtm_idr (
        .tclk                            (pad_dtm_tclk),                 
        .trst_b                          (pad_dtm_trst_b),
        .dmihardreset                    (dmihardreset), 
        .idr_chain_dr                    (idr_chain_dr), 
        .idr_chain_ir                    (idr_chain_ir), 
        .idr_dmi_mode                    (idr_dmi_mode),                    
        .chain_idr_data                  (chain_idr_data), 
        .ctrl_idr_update_ir              (ctrl_idr_update_ir),       
        .ctrl_idr_update_dr              (ctrl_idr_update_dr),
        .ctrl_idr_capture_dr             (ctrl_idr_capture_dr),
        .ctrl_idr_tap_reset              (ctrl_idr_tap_reset),
        .dtm_apbm_wr_vld                 (dtm_apbm_wr_vld),
        .dtm_apbm_wr_addr                (dtm_apbm_wr_addr),
        .dtm_apbm_wr_flg                 (dtm_apbm_wr_flg),
        .dtm_apbm_wdata                  (dtm_apbm_wdata),
        .apbm_dtm_rdata                  (apbm_dtm_rdata),
        .apbm_dtm_wr_ready               (apbm_dtm_wr_ready)
    );

    `ifdef TDT_ASSERTION
     property test_logic_reset_set_ir_to_idcode;
       @(posedge pad_dtm_tclk) 
         ((x_tdt_dmi_dtm_ctrl.tap5_cur_st[3:0] == 4'b0000) & (pad_dtm_jtag2_sel == 1'b0)) |=> (x_tdt_dmi_dtm_idr.dtm_ir[4:0] == 5'h01);
     endproperty
    assert property(test_logic_reset_set_ir_to_idcode);   
    `endif

endmodule
// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : tdt_dmi_gated_cell.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-6
// FUNCTION        : ttd_gated_cell.v
// ******************************************************************************
// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : tdt_dmi_gated_clk_cell.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-6
// FUNCTION        : ttd_gated_clk_cell.v
// ******************************************************************************
// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : tdt_dmi_mux_cell.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2022-7-4
// FUNCTION        : pic_mux_cell
// ******************************************************************************
// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : tdt_dmi_pulse_sync.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-6
// FUNCTION        : tdt_dmi_pulse_sync.v
// ******************************************************************************

module tdt_dmi_pulse_sync (
    input       src_clk,
    input       dst_clk,
    input       src_rst_b,
    input       dst_rst_b,
    input       src_pulse,
    output      dst_pulse
);
    reg         src_pulse_2_lvl;
    wire        dst_lvl; 
    reg         dst_lvl_d;
    wire        dst_lvl_src;
    reg         dst_lvl_src_d;
    wire        dst_pulse_2_src;

    always @ (posedge src_clk or negedge src_rst_b) begin
        if(~src_rst_b)
            dst_lvl_src_d <= 1'b0;
        else 
            dst_lvl_src_d <= dst_lvl_src;        
    end

    assign dst_pulse_2_src = dst_lvl_src & ~dst_lvl_src_d;


    always @ (posedge src_clk or negedge src_rst_b) begin
        if(~src_rst_b)
            src_pulse_2_lvl <= 1'b0;
        else if (dst_pulse_2_src)
            src_pulse_2_lvl <= 1'b0;    
        else if (src_pulse)
            src_pulse_2_lvl <= 1'b1;

            //src_pulse_2_lvl <= ~src_pulse_2_lvl;
    end

    tdt_dmi_sync_dff  x_tdt_dmi_sync_dff (
        .dst_clk     (dst_clk),
        .dst_rst_b   (dst_rst_b),
        .src_in      (src_pulse_2_lvl),
        .dst_out     (dst_lvl)
    );

    tdt_dmi_sync_dff  x_tdt_dmi_sync_dff_back (
        .dst_clk     (src_clk),
        .dst_rst_b   (src_rst_b),
        .src_in      (dst_lvl),
        .dst_out     (dst_lvl_src)
    );

    always @ (posedge dst_clk or negedge dst_rst_b) begin
        if(~dst_rst_b)
            dst_lvl_d <= 1'b0;
        else
            dst_lvl_d <= dst_lvl;
    end

    assign dst_pulse = dst_lvl & ~dst_lvl_d;

endmodule

// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : tdt_dmi_rst_top.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-6
// FUNCTION        : tdt_dmi_rst_top.v
// ******************************************************************************

module tdt_dmi_rst_top(
  sys_apb_clk,
  sys_apb_rst_b,
  pad_tdt_dtm_tclk,
  pad_tdt_dtm_trst_b,
  pad_yy_scan_mode,
  pad_yy_scan_rst_b,
  pad_yy_mbist_mode,
  sync_sys_apb_rst_b,
  sync_trst_b
                    );

  input sys_apb_clk;
  input sys_apb_rst_b;
  input pad_tdt_dtm_tclk;
  input pad_tdt_dtm_trst_b;
  input pad_yy_scan_mode;
  input pad_yy_scan_rst_b;
  input pad_yy_mbist_mode;
  output sync_sys_apb_rst_b;
  output sync_trst_b;

  wire sync_sys_apb_rst_b;
  wire async_apb_rst_b;
  wire sync_trst_b;
  wire async_trst_b;
  reg sys_apb_rst_ff_1st;
  reg trst_ff_1st;
  reg trst_ff_2nd;
  reg trst_ff_3rd;

//=========================================================
//                      APB reset
//=========================================================
//only flop sys_apb_rst_b for timing
assign async_apb_rst_b = sys_apb_rst_b & ~pad_yy_mbist_mode;

always @(posedge sys_apb_clk or negedge async_apb_rst_b)
begin
  if (~async_apb_rst_b)
    sys_apb_rst_ff_1st <= 1'b0;
  else
    sys_apb_rst_ff_1st <= 1'b1;
end

tdt_dmi_mux_cell  x_sync_sys_apb_rst_mux (
  .I0                 (sys_apb_rst_ff_1st),
  .I1                 (pad_yy_scan_rst_b ),
  .S                  (pad_yy_scan_mode  ),
  .Z                  (sync_sys_apb_rst_b    )
);

//=========================================================
//                    jtag reset
//=========================================================
assign async_trst_b = pad_tdt_dtm_trst_b & ~pad_yy_mbist_mode;

always @(posedge pad_tdt_dtm_tclk or negedge async_trst_b)
begin
  if (~async_trst_b)
  begin
    trst_ff_1st <= 1'b0;
    trst_ff_2nd <= 1'b0;
    trst_ff_3rd <= 1'b0;
  end
  else
  begin
    trst_ff_1st <= 1'b1;
    trst_ff_2nd <= trst_ff_1st;
    trst_ff_3rd <= trst_ff_2nd;
  end
end

tdt_dmi_mux_cell  x_sync_jtag_rst_mux (
  .I0                 (trst_ff_3rd),
  .I1                 (pad_yy_scan_rst_b ),
  .S                  (pad_yy_scan_mode  ),
  .Z                  (sync_trst_b    )
);

endmodule
// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : tdt_dmi_sync_dff.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-6
// FUNCTION        : tdt_dmi_sync_dff.v
// ******************************************************************************

// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : tdt_dmi_top.vp
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-6
// FUNCTION        : tdt_dmi_top.vp
// ******************************************************************************

// &Depend("tdt_dmi_cfig.vh"); @16
// &Depend("tdt_dmi.v"); @17
// &Depend("tdt_dmi_rst_top.v"); @18
// &Depend("tdt_dmi_dtm_chain.v"); @19
// &Depend("tdt_dmi_dtm_ctrl.v"); @20
// &Depend("tdt_dmi_dtm_idr.v"); @21
// &Depend("tdt_dmi_dtm_io.v"); @22
// &Depend("tdt_dmi_dtm_top.v"); @23
// &Depend("tdt_dmi_apb_master.v"); @24
// &Depend("tdt_dmi_apb_mux.v"); @26
// &Depend("tdt_dmi_apb_regslice.v"); @27
// &Depend("tdt_dmi_apb_decoder.v"); @31
// &Depend("tdt_dmi_pulse_sync.v"); @33
// &Depend("tdt_dmi_sync_dff.v"); @34
// &Depend("tdt_dmi_gated_clk_cell.v"); @35
// &Depend("tdt_dmi_gated_cell.v"); @36
// &Depend("tdt_dmi_mux_cell.v"); @37

// &Depend("tdt_dmi_top_golden_port.vp"); @39

// &ModuleBeg; @41
module tdt_dmi_top(
  pad_tdt_dtm_jtag2_sel,
  pad_tdt_dtm_tap_en,
  pad_tdt_dtm_tclk,
  pad_tdt_dtm_tdi,
  pad_tdt_dtm_tms_i,
  pad_tdt_dtm_trst_b,
  pad_tdt_icg_scan_en,
  pad_yy_mbist_mode,
  pad_yy_scan_mode,
  pad_yy_scan_rst_b,
  sys_apb_clk,
  sys_apb_rst_b,
  tdt_dmi_paddr,
  tdt_dmi_penable,
  tdt_dmi_prdata,
  tdt_dmi_pready,
  tdt_dmi_psel,
  tdt_dmi_pslverr,
  tdt_dmi_pwdata,
  tdt_dmi_pwrite,
  tdt_dtm_pad_tdo,
  tdt_dtm_pad_tdo_en,
  tdt_dtm_pad_tms_o,
  tdt_dtm_pad_tms_oe
);

// &Ports("compare", "tdt_dmi_top_golden_port.v"); @42
input           pad_tdt_dtm_jtag2_sel; 
input           pad_tdt_dtm_tap_en; 
input           pad_tdt_dtm_tclk; 
input           pad_tdt_dtm_tdi; 
input           pad_tdt_dtm_tms_i; 
input           pad_tdt_dtm_trst_b; 
input           pad_tdt_icg_scan_en; 
input           pad_yy_mbist_mode; 
input           pad_yy_scan_mode; 
input           pad_yy_scan_rst_b; 
input           sys_apb_clk; 
input           sys_apb_rst_b; 
input   [31:0]  tdt_dmi_prdata; 
input           tdt_dmi_pready; 
input           tdt_dmi_pslverr; 
output  [11:0]  tdt_dmi_paddr; 
output          tdt_dmi_penable; 
output          tdt_dmi_psel; 
output  [31:0]  tdt_dmi_pwdata; 
output          tdt_dmi_pwrite; 
output          tdt_dtm_pad_tdo; 
output          tdt_dtm_pad_tdo_en; 
output          tdt_dtm_pad_tms_o; 
output          tdt_dtm_pad_tms_oe; 

// &Regs; @43

// &Wires; @44


//csky vperl off
wire sync_sys_apb_rst_b;
wire sync_trst_b;
//csky vperl on

tdt_dmi_rst_top x_tdt_dmi_rst_top (
    .sys_apb_clk(sys_apb_clk),
    .sys_apb_rst_b(sys_apb_rst_b),
    .pad_tdt_dtm_tclk(pad_tdt_dtm_tclk),
    .pad_tdt_dtm_trst_b(pad_tdt_dtm_trst_b),
    .pad_yy_scan_mode(pad_yy_scan_mode),
    .pad_yy_scan_rst_b(pad_yy_scan_rst_b),
    .pad_yy_mbist_mode(pad_yy_mbist_mode),
    .sync_sys_apb_rst_b(sync_sys_apb_rst_b),
    .sync_trst_b(sync_trst_b)
);

tdt_dmi x_tdt_dmi (
    .sys_apb_clk(sys_apb_clk),
    .sys_apb_rst_b(sync_sys_apb_rst_b),
    .pad_tdt_dtm_tclk(pad_tdt_dtm_tclk),
    .pad_tdt_dtm_trst_b(sync_trst_b),
    .pad_tdt_dtm_jtag2_sel(pad_tdt_dtm_jtag2_sel),         
    .pad_tdt_dtm_tap_en(pad_tdt_dtm_tap_en),        
    .pad_tdt_dtm_tdi(pad_tdt_dtm_tdi),           
    .pad_tdt_dtm_tms_i(pad_tdt_dtm_tms_i),  
    .tdt_dtm_pad_tdo(tdt_dtm_pad_tdo),           
    .tdt_dtm_pad_tdo_en(tdt_dtm_pad_tdo_en),        
    .tdt_dtm_pad_tms_o(tdt_dtm_pad_tms_o),         
    .tdt_dtm_pad_tms_oe(tdt_dtm_pad_tms_oe),

    .pad_icg_scan_en(pad_tdt_icg_scan_en),


    .tdt_dmi_paddr(tdt_dmi_paddr),
    .tdt_dmi_pwrite(tdt_dmi_pwrite),
    .tdt_dmi_penable(tdt_dmi_penable),
    .tdt_dmi_pwdata(tdt_dmi_pwdata),
    .tdt_dmi_psel(tdt_dmi_psel),
    .tdt_dmi_prdata(tdt_dmi_prdata),
    .tdt_dmi_pslverr(tdt_dmi_pslverr),
    .tdt_dmi_pready(tdt_dmi_pready)

);


// &Force("input", "sys_apb_clk"); @103
// &Force("input", "sys_apb_rst_b"); @104
// &Force("input", "pad_tdt_dtm_tclk"); @105
// &Force("input", "pad_tdt_dtm_trst_b"); @106
// &Force("input", "pad_tdt_dtm_jtag2_sel");          @107
// &Force("input", "pad_tdt_dtm_tap_en");         @108
// &Force("input", "pad_tdt_dtm_tdi");            @109
// &Force("input", "pad_tdt_dtm_tms_i");   @110
// &Force("output", "tdt_dtm_pad_tdo");            @111
// &Force("output", "tdt_dtm_pad_tdo_en");         @112
// &Force("output", "tdt_dtm_pad_tms_o");          @113
// &Force("output", "tdt_dtm_pad_tms_oe"); @114
// &Force("input", "pad_tdt_icg_scan_en"); @115
// &Force("input", "pad_yy_scan_mode"); @116
// &Force("input", "pad_yy_scan_rst_b"); @117
// &Force("input", "pad_yy_mbist_mode") @118

// &Force("input", "pad_tdt_sysapb_en"); @121
// &Force("input", "pad_tdt_dmi_paddr"); @122
// &Force("bus","pad_tdt_dmi_paddr",12+`TDT_DMI_HIGH_ADDR_W-1,0); @123
// &Force("input", "pad_tdt_dmi_pwrite"); @124
// &Force("input", "pad_tdt_dmi_psel"); @125
// &Force("input", "pad_tdt_dmi_penable"); @126
// &Force("input", "pad_tdt_dmi_pwdata"); @127
// &Force("bus","pad_tdt_dmi_pwdata",31,0); @128
// &Force("output", "tdt_dmi_pad_prdata"); @129
// &Force("bus","tdt_dmi_pad_prdata",31,0); @130
// &Force("output", "tdt_dmi_pad_pready"); @131
// &Force("output", "tdt_dmi_pad_pslverr"); @132

// &Force("output", "tdt_dmi_paddr"); @135
// &Force("bus","tdt_dmi_paddr",11,0); @136
// &Force("output", "tdt_dmi_pwrite"); @137
// &Force("output", "tdt_dmi_penable"); @138
// &Force("output", "tdt_dmi_pwdata"); @139
// &Force("bus","tdt_dmi_pwdata",31,0); @140
// &Force("output", "tdt_dmi_psel"); @142
// &Force("output", "tdt_dmi_psel");&Force("bus","tdt_dmi_psel",`TDT_DMI_SLAVE_NUM-1,0); @144
// &Force("input", "tdt_dmi_prdata"); @146
// &Force("bus","tdt_dmi_prdata",32*`TDT_DMI_SLAVE_NUM-1,0); @147
// &Force("input", "tdt_dmi_pready"); @149
// &Force("input", "tdt_dmi_pslverr"); @150
// &Force("input", "tdt_dmi_pready");&Force("bus","tdt_dmi_pready",`TDT_DMI_SLAVE_NUM-1,0); @152
// &Force("input", "tdt_dmi_pslverr");&Force("bus","tdt_dmi_pslverr",`TDT_DMI_SLAVE_NUM-1,0); @153

// &ModuleEnd; @156
endmodule


// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : tdt_dmi_top_golden_port.vp
// AUTHOR          : Xia Tianyi
// ORIGINAL DATE   : 2021-4-1
// DESCRIPTION     : Golden port module for tdt_dmi_top
// ******************************************************************************

// &ModuleBeg; @16








