`define PIC_CLUSTER_NUM 1
`define PIC_HART_NUM 4
`define PIC_PLIC_INT_NUM 64
`define PIC_TEE_EXTENSION
`define APB_BASE_ADDR 40'h0010000000

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


// Fixed RTL configures: 
`define PIC_PLIC
`define PIC_PLIC_ID_NUM   10  
`define PIC_PLIC_PRIO_BIT 5   

module soc#(parameter SV48_CONFIG=0)(
  b_pad_gpio_porta,
  i_pad_clk,
  i_pad_jtg_tclk,
  i_pad_jtg_tdi,
  i_pad_jtg_tms,
  i_pad_jtg_trst_b,
  i_pad_rst_b,
  i_pad_uart0_sin,
  o_pad_jtg_tdo,
  o_pad_uart0_sout,
  prog_wen,
  prog_waddr,
  prog_wdata,
  // // System RAM Data
  // // Output
  // fifo_pad_araddr,
  // fifo_pad_arburst,
  // fifo_pad_arcache,
  // fifo_pad_arid,
  // fifo_pad_arlen,
  // fifo_pad_arprot,
  // fifo_pad_arsize,
  // arvalid_s1,
  // biu_pad_awaddr,
  // biu_pad_awburst,
  // biu_pad_awcache,
  // biu_pad_awid,
  // biu_pad_awlen,
  // biu_pad_awprot,
  // biu_pad_awsize,
  // awvalid_s1,
  // bready_s1,
  // per_clk,
  // rready_s1,
  // biu_pad_wdata,
  // biu_pad_wid,
  // biu_pad_wlast,
  // biu_pad_wstrb,
  // wvalid_s1,
  // // Input
  // arready_s1,
  // awready_s1,
  // bid_s1,
  // bresp_s1,
  // bvalid_s1,
  // rdata_s1,
  // rid_s1,
  // rlast_s1,
  // rresp_s1,
  // rvalid_s1,
  // wready_s1

);

input            i_pad_clk;            
input            i_pad_jtg_tclk;       
input            i_pad_jtg_tdi;        
inout            i_pad_jtg_tms;        
input            i_pad_jtg_trst_b;     
input            i_pad_rst_b;          
input            i_pad_uart0_sin;      
output           o_pad_jtg_tdo;        
output           o_pad_uart0_sout;     
inout   [7  :0]  b_pad_gpio_porta;

// program write data
input            prog_wen;
input   [19: 0]  prog_waddr;
input   [127:0]  prog_wdata;


wire             arready_s0;           
wire             arready_s1;           
wire             arready_s2;           
wire             arready_s3;           
wire             arvalid_s0;           
wire             arvalid_s1;           
wire             arvalid_s2;           
wire             arvalid_s3;           
wire             awready_s0;           
wire             awready_s1;           
wire             awready_s2;           
wire             awready_s3;           
wire             awvalid_s0;           
wire             awvalid_s1;           
wire             awvalid_s2;           
wire             awvalid_s3;           
wire    [7  :0]  b_pad_gpio_porta;     
wire    [7  :0]  bid_s0;               
wire    [7  :0]  bid_s1;               
wire    [7  :0]  bid_s2;               
wire    [7  :0]  bid_s3;               
wire    [39 + SV48_CONFIG :0]  biu_pad_araddr;       
wire    [1  :0]  biu_pad_arburst;      
wire    [3  :0]  biu_pad_arcache;      
wire    [7  :0]  biu_pad_arid;         
wire    [7  :0]  biu_pad_arlen;        
wire             biu_pad_arlock;       
wire    [2  :0]  biu_pad_arprot;       
wire    [2  :0]  biu_pad_arsize;       
wire             biu_pad_arvalid;      
wire    [39 + SV48_CONFIG :0]  biu_pad_awaddr;       
wire    [1  :0]  biu_pad_awburst;      
wire    [3  :0]  biu_pad_awcache;      
wire    [7  :0]  biu_pad_awid;         
wire    [7  :0]  biu_pad_awlen;        
wire             biu_pad_awlock;       
wire    [2  :0]  biu_pad_awprot;       
wire    [2  :0]  biu_pad_awsize;       
wire             biu_pad_awvalid;      
wire             biu_pad_bready;       
wire    [39 :0]  biu_pad_haddr;        
wire    [2  :0]  biu_pad_hburst;       
wire             biu_pad_hbusreq;      
wire             biu_pad_hlock;        
wire    [3  :0]  biu_pad_hprot;        
wire    [2  :0]  biu_pad_hsize;        
wire    [1  :0]  biu_pad_htrans;       
wire    [1  :0]  biu_pad_htrans_dly;   
wire    [127:0]  biu_pad_hwdata;       
wire             biu_pad_hwrite;       
wire             biu_pad_hwrite_dly;   
wire    [1  :0]  biu_pad_lpmd_b;       
wire             biu_pad_rready;       
wire    [127:0]  biu_pad_wdata;        
wire    [7  :0]  biu_pad_wid;          
wire             biu_pad_wlast;        
wire    [15 :0]  biu_pad_wstrb;        
wire             biu_pad_wvalid;       
wire             bready_s0;            
wire             bready_s1;            
wire             bready_s2;            
wire             bready_s3;            
wire    [1  :0]  bresp_s0;             
wire    [1  :0]  bresp_s1;             
wire    [1  :0]  bresp_s2;             
wire    [1  :0]  bresp_s3;             
wire             bvalid_s0;            
wire             bvalid_s1;            
wire             bvalid_s2;            
wire             bvalid_s3;            
wire             axim_clk_en;               
wire             fifo_biu_arready;     
wire    [39 :0]  fifo_pad_araddr;      
wire    [1  :0]  fifo_pad_arburst;     
wire    [3  :0]  fifo_pad_arcache;     
wire    [7  :0]  fifo_pad_arid;        
wire    [7  :0]  fifo_pad_arlen;       
wire             fifo_pad_arlock;      
wire    [2  :0]  fifo_pad_arprot;      
wire    [2  :0]  fifo_pad_arsize;      
wire             fifo_pad_artrust;     
wire             fifo_pad_arvalid;     
wire             had_pad_jtg_tdo;      
wire             had_pad_jtg_tdo_en;      
wire    [39 :0]  haddr_dly;            
wire    [39 :0]  haddr_s1;             
wire    [39 :0]  haddr_s2;             
wire    [39 :0]  haddr_s3;             
wire    [2  :0]  hburst_s1;            
wire    [2  :0]  hburst_s2;            
wire    [2  :0]  hburst_s3;            
wire             hmastlock;            
wire    [3  :0]  hprot_s1;             
wire    [3  :0]  hprot_s2;             
wire    [3  :0]  hprot_s3;             
wire    [127:0]  hrdata_s1;            
wire    [127:0]  hrdata_s2;            
wire    [127:0]  hrdata_s3;            
wire             hready_s1;            
wire             hready_s2;            
wire             hready_s3;            
wire    [1  :0]  hresp_s1;             
wire    [1  :0]  hresp_s2;             
wire    [1  :0]  hresp_s3;             
wire             hsel_s1;              
wire             hsel_s2;              
wire             hsel_s3;              
wire    [2  :0]  hsize_s1;             
wire    [2  :0]  hsize_s2;             
wire    [2  :0]  hsize_s3;             
wire    [1  :0]  htrans_s1;            
wire    [1  :0]  htrans_s2;            
wire    [1  :0]  htrans_s3;            
wire    [127:0]  hwdata_s1;            
wire    [127:0]  hwdata_s2;            
wire    [127:0]  hwdata_s3;            
wire             hwrite_s1;            
wire             hwrite_s2;            
wire             hwrite_s3;            
wire             i_pad_clk;            
wire             cpu_clk;            
wire             i_pad_jtg_tclk;       
wire             i_pad_jtg_tdi;        
wire             i_pad_jtg_tms;        
wire             i_pad_jtg_trst_b;     
wire             i_pad_rst_b;          
wire             i_pad_uart0_sin;      
wire             o_pad_jtg_tdo;        
wire             o_pad_uart0_sout;     
wire             pad_biu_arready;     
wire             pad_biu_awready;      
wire    [7  :0]  pad_biu_bid;          
wire    [1  :0]  pad_biu_bresp;        
wire             pad_biu_bvalid;       
wire             pad_biu_hgrant;       
wire    [127:0]  pad_biu_hrdata;       
wire             pad_biu_hready;       
wire    [1  :0]  pad_biu_hresp;        
wire    [127:0]  pad_biu_rdata;        
wire    [7  :0]  pad_biu_rid;          
wire             pad_biu_rlast;        
wire    [1  :0]  pad_biu_rresp;        
wire             pad_biu_rvalid;       
wire             pad_biu_wready;       
wire             pad_cpu_rst_b;        
wire             pad_had_jtg_tclk;     
wire             pad_had_jtg_tdi;      
wire             pad_had_jtg_trst_b;   
wire             per_clk;              
wire             pll_cpu_clk;      
wire    [127:0]  rdata_s0;             
wire    [127:0]  rdata_s1;             
wire    [127:0]  rdata_s2;             
wire    [127:0]  rdata_s3;             
wire    [7  :0]  rid_s0;               
wire    [7  :0]  rid_s1;               
wire    [7  :0]  rid_s2;               
wire    [7  :0]  rid_s3;               
wire             rlast_s0;             
wire             rlast_s1;             
wire             rlast_s2;             
wire             rlast_s3;             
wire             rready_s0;            
wire             rready_s1;            
wire             rready_s2;            
wire             rready_s3;            
wire    [1  :0]  rresp_s0;             
wire    [1  :0]  rresp_s1;             
wire    [1  :0]  rresp_s2;             
wire    [1  :0]  rresp_s3;             
wire             rvalid_s0;            
wire             rvalid_s1;            
wire             rvalid_s2;            
wire             rvalid_s3;            
wire             uart0_sin;            
wire             uart0_sout;           
wire             wready_s0;            
wire             wready_s1;            
wire             wready_s2;            
wire             wready_s3;            
wire             wvalid_s0;            
wire             wvalid_s1;            
wire             wvalid_s2;            
wire             wvalid_s3;            
wire    [39 :0]  xx_intc_vld;          

`ifdef PMU_LP_MODE_TEST
wire             pmu_cpu_pwr_on ; 
wire             pmu_cpu_iso_in ; 
wire             pmu_cpu_iso_out; 
wire             pmu_cpu_save   ; 
wire             pmu_cpu_restore; 
`endif

wire             sys_tdt_clk    ; 
reg 	[63:  0] pad_cpu_sys_cnt;


//------------------------------------------------------//
// PIC
// clk & rst_b
wire	[1 *`PIC_CLUSTER_NUM    -1 :0]  clusterx_clk	;
wire	[1 *`PIC_CLUSTER_NUM    -1 :0]  clusterx_rst_b	;

// connect with interrupt number
wire    [`PIC_PLIC_INT_NUM-1 	   :0]  plic_int_cfg;              
wire    [`PIC_PLIC_INT_NUM-1 	   :0]  plic_int_vld;   
wire    [`PIC_PLIC_INT_NUM-17	   :0]  pad_plic_int_cfg;          
wire    [`PIC_PLIC_INT_NUM-17	   :0]  pad_plic_int_vld;  

// connect with CPU 
wire    [32*`PIC_CLUSTER_NUM    -1 :0]  clusterx_pic_paddr;        
wire    [1 *`PIC_CLUSTER_NUM    -1 :0]  clusterx_pic_penable;      
wire    [2 *`PIC_CLUSTER_NUM    -1 :0]  clusterx_pic_pprot;        
wire    [1 *`PIC_CLUSTER_NUM    -1 :0]  clusterx_pic_psel;         
wire    [32*`PIC_CLUSTER_NUM    -1 :0]  clusterx_pic_pwdata;       
wire    [1 *`PIC_CLUSTER_NUM    -1 :0]  clusterx_pic_pwrite;  
wire    [32                     -1 :0]  cluster0_pic_paddr;        
wire    [1                      -1 :0]  cluster0_pic_penable;      
wire    [2                      -1 :0]  cluster0_pic_pprot;        
wire    [1                      -1 :0]  cluster0_pic_psel;         
wire    [32                     -1 :0]  cluster0_pic_pwdata;       
wire    [1                      -1 :0]  cluster0_pic_pwrite; 
wire    [32*`PIC_CLUSTER_NUM    -1 :0]  pic_clusterx_prdata;       
wire    [1 *`PIC_CLUSTER_NUM    -1 :0]  pic_clusterx_pready;       
wire    [1 *`PIC_CLUSTER_NUM    -1 :0]  pic_clusterx_pslverr;  
wire    [`PIC_HART_NUM			-1 :0]  plic_hartx_me_int;         
wire    [`PIC_HART_NUM			-1 :0]  plic_hartx_se_int; 
wire    [`PIC_HART_NUM			-1 :0]  clint_hartx_ms_int;        
wire    [`PIC_HART_NUM			-1 :0]  clint_hartx_mt_int;        
wire    [`PIC_HART_NUM			-1 :0]  clint_hartx_ss_int;        
wire    [`PIC_HART_NUM			-1 :0]  clint_hartx_st_int; 
wire             						ciu_pad_async_abort_int;

//------------------------------------------------------//
// TDT_DMI_TOP
// Connect with Clusterx 
wire    [11 :0]  					tdt_dmi_paddr;             
wire             					tdt_dmi_penable;           
wire    [31 :0]  					tdt_dmi_pwdata;            
wire             					tdt_dmi_pwrite;  
wire    [1 *`TDT_DMI_SLAVE_NUM-1:0] clusterx_tdt_dmi_psel;              
wire    [32*`TDT_DMI_SLAVE_NUM-1:0] clusterx_tdt_dmi_prdata;            
wire    [1 *`TDT_DMI_SLAVE_NUM-1:0] clusterx_tdt_dmi_pready;            
wire    [1 *`TDT_DMI_SLAVE_NUM-1:0] clusterx_tdt_dmi_pslverr;

// Connect with pad jtg
//wire             pad_had_jtg_tclk  ;
//wire             pad_had_jtg_tdi   ;
wire             pad_had_jtg_tms   ;
//wire             pad_had_jtg_trst_b;
wire	[63:0]		 pad_tdt_dmi_paddr;

assign	pad_tdt_dmi_paddr = 64'h0;
assign  pad_biu_arready = 1'b1;
//========================================================================+
//                  Instance TDT_DMI_TOP  							  	  |		                   用于芯片头部测试
//========================================================================+
tdt_dmi_top x_tdt_dmi_top(
`ifdef TDT_DMI_SYSAPB_EN 
	.pad_tdt_dmi_paddr				( pad_tdt_dmi_paddr[12 + `TDT_DMI_HIGH_ADDR_W -1 :0]					), 
	.pad_tdt_dmi_penable			(  1'b0								), 
	.pad_tdt_dmi_psel				(  1'b0								), 
	.pad_tdt_dmi_pwdata				( 32'h0								), 
	.pad_tdt_dmi_pwrite	 			(  1'b0								),
	.pad_tdt_sysapb_en				(  1'b0								),
    .tdt_dmi_pad_prdata				(									), 
	.tdt_dmi_pad_pready				(									), 
	.tdt_dmi_pad_pslverr			(									), 
`endif
    .pad_tdt_dtm_jtag2_sel         	(1'b0                               ), 
    .pad_tdt_dtm_tap_en            	(1'b1                               ), 
    .pad_tdt_dtm_tclk              	(pad_had_jtg_tclk                   ), 
    .pad_tdt_dtm_tdi               	(pad_had_jtg_tdi                    ), 
    .pad_tdt_dtm_tms_i             	(pad_had_jtg_tms                    ), 
    .pad_tdt_dtm_trst_b            	(pad_had_jtg_trst_b                 ), 
    .pad_tdt_icg_scan_en           	(1'b0                               ), 
    .pad_yy_mbist_mode             	(1'b0                               ), 
    .pad_yy_scan_mode              	(1'b0                               ), 
    .pad_yy_scan_rst_b             	(1'b1                               ), 
    .sys_apb_clk                   	(sys_tdt_clk                        ), 
    .sys_apb_rst_b                 	(pad_cpu_rst_b                      ),
    .tdt_dmi_paddr                 	(tdt_dmi_paddr                      ), 
    .tdt_dmi_penable               	(tdt_dmi_penable                    ),
    .tdt_dmi_pwdata                	(tdt_dmi_pwdata                     ),
    .tdt_dmi_pwrite                	(tdt_dmi_pwrite                     ),
    .tdt_dmi_psel                  	(clusterx_tdt_dmi_psel       		), 
    .tdt_dmi_prdata                	(clusterx_tdt_dmi_prdata     		), 
    .tdt_dmi_pready                	(clusterx_tdt_dmi_pready     		), 
    .tdt_dmi_pslverr               	(clusterx_tdt_dmi_pslverr    		),
    .tdt_dtm_pad_tdo               	(had_pad_jtg_tdo                    ), 
    .tdt_dtm_pad_tdo_en            	(had_pad_jtg_tdo_en                 ), 
    .tdt_dtm_pad_tms_o             	(tdt_dtm_pad_tms_o                  ), 
    .tdt_dtm_pad_tms_oe            	(tdt_dtm_pad_tms_oe                 )  
);

assign pad_had_jtg_tclk     = i_pad_jtg_tclk; 
assign pad_had_jtg_tdi      = i_pad_jtg_tdi ;
assign pad_had_jtg_tms      = i_pad_jtg_tms ;
assign i_pad_jtg_tms        = tdt_dtm_pad_tms_oe ? tdt_dtm_pad_tms_o : 1'bz;
assign pad_had_jtg_trst_b   = i_pad_jtg_trst_b;  

assign o_pad_jtg_tdo = had_pad_jtg_tdo;

assign uart0_sin 		= i_pad_uart0_sin;
assign o_pad_uart0_sout = uart0_sout;

assign pad_cpu_rst_b = i_pad_rst_b;
assign pll_cpu_clk 	 =  cpu_clk;

assign sys_tdt_clk = pll_cpu_clk;
//always@(posedge pll_cpu_clk or negedge pad_cpu_rst_b) begin
//  if(!pad_cpu_rst_b)
//    sys_tdt_clk <= 1'b0;
//  else
//    sys_tdt_clk <= ~sys_tdt_clk;
//end

//========================================================================+
//                  Instance PIC Top									  |		                接外设中�?
//========================================================================+
// System timer simple model
always@(posedge pll_cpu_clk or negedge pad_cpu_rst_b)
begin
  if (!pad_cpu_rst_b)
    pad_cpu_sys_cnt <= 64'b0;
  else
    pad_cpu_sys_cnt <= pad_cpu_sys_cnt + 1'b1;
end

// plic interrupt 
assign plic_int_vld[`PIC_PLIC_INT_NUM-1:0] 		 = {pad_plic_int_vld[`PIC_PLIC_INT_NUM-17:0],{14{1'b0}},ciu_pad_async_abort_int,1'b0};
assign plic_int_cfg[`PIC_PLIC_INT_NUM-1:0] 		 = {pad_plic_int_cfg[`PIC_PLIC_INT_NUM-17:0],{16{1'b0}}};

assign pad_plic_int_vld[      39 : 0]            = xx_intc_vld[ 39 : 0];
assign pad_plic_int_vld[`PIC_PLIC_INT_NUM-17:40] = {(`PIC_PLIC_INT_NUM-16-40){1'b0}};
assign pad_plic_int_cfg 						 = {(`PIC_PLIC_INT_NUM-16){1'b0}};

//pic clusters clk & rst_b 
assign clusterx_clk			= {{    (`PIC_CLUSTER_NUM-1){1'b0}},pll_cpu_clk 	};
assign clusterx_rst_b		= {{    (`PIC_CLUSTER_NUM-1){1'b1}},pad_cpu_rst_b 	};

//pic clusters apb slave 
assign clusterx_pic_paddr	= {{(32*(`PIC_CLUSTER_NUM-1)){1'b0}},cluster0_pic_paddr	 };   
assign clusterx_pic_penable	= {{(1 *(`PIC_CLUSTER_NUM-1)){1'b0}},cluster0_pic_penable}; 
assign clusterx_pic_pprot	= {{(2 *(`PIC_CLUSTER_NUM-1)){1'b0}},cluster0_pic_pprot	 };   
assign clusterx_pic_psel	= {{(1 *(`PIC_CLUSTER_NUM-1)){1'b0}},cluster0_pic_psel	 };    
assign clusterx_pic_pwdata	= {{(32*(`PIC_CLUSTER_NUM-1)){1'b0}},cluster0_pic_pwdata };  
assign clusterx_pic_pwrite	= {{(1 *(`PIC_CLUSTER_NUM-1)){1'b0}},cluster0_pic_pwrite };  

pic_top  x_pic_top (
  .clint_hartx_ms_int   	(clint_hartx_ms_int					),
  .clint_hartx_mt_int   	(clint_hartx_mt_int					),
  .clint_hartx_ss_int   	(clint_hartx_ss_int					),
  .clint_hartx_st_int   	(clint_hartx_st_int					),
  .plic_hartx_me_int    	(plic_hartx_me_int 					),
  .plic_hartx_se_int    	(plic_hartx_se_int 					),
  .cluster_clk          	(clusterx_clk	 			      	),
  .cluster_rst_b        	(clusterx_rst_b	 				  	),
  .clusterx_pic_paddr   	(clusterx_pic_paddr  				),
  .clusterx_pic_penable 	(clusterx_pic_penable				),
  .clusterx_pic_pprot   	(clusterx_pic_pprot  				),
  .clusterx_pic_psel    	(clusterx_pic_psel   				),
  .clusterx_pic_pwdata  	(clusterx_pic_pwdata 				),
  .clusterx_pic_pwrite  	(clusterx_pic_pwrite 				),
  .pic_clusterx_prdata  	(pic_clusterx_prdata 				),
  .pic_clusterx_pready  	(pic_clusterx_pready 				),
  .pic_clusterx_pslverr 	(pic_clusterx_pslverr				),
  .pad_pic_plic_int_cfg 	(plic_int_cfg        				),
  .pad_pic_plic_int_vld 	(plic_int_vld        				),
  .pad_pic_sys_cnt      	(pad_cpu_sys_cnt     				),
  .pad_yy_icg_scan_en   	(1'b0                				),
  .pad_yy_mbist_mode    	(1'b0                				),
  .pad_yy_scan_mode     	(1'b0                				),
  .pad_yy_scan_rst_b    	(1'b1                				),
  .pic_clk              	(pll_cpu_clk         				),
`ifdef PIC_TEE_EXTENSION
  .pic_pad_par_violation	(					 				),
`endif
  .pic_rst_b            	(pad_cpu_rst_b       				) 
);

//========================================================================+
//                  Instance C908 sub system							  |		
//========================================================================+
C908_sub_system  x_cpu_sub_system
 (
  //AXI master interface
  .axim_clk_en           	(axim_clk_en          			),
  .biu_pad_araddr        	(biu_pad_araddr       			),
  .biu_pad_arburst       	(biu_pad_arburst      			),
  .biu_pad_arcache       	(biu_pad_arcache      			),
  .biu_pad_arid          	(biu_pad_arid         			),
  .biu_pad_arlen         	(biu_pad_arlen        			),
  .biu_pad_arlock        	(biu_pad_arlock       			),
  .biu_pad_arprot        	(biu_pad_arprot       			),
  .biu_pad_arsize        	(biu_pad_arsize       			),
  .biu_pad_arvalid       	(biu_pad_arvalid      			),
  .biu_pad_awaddr        	(biu_pad_awaddr       			),
  .biu_pad_awburst       	(biu_pad_awburst      			),
  .biu_pad_awcache       	(biu_pad_awcache      			),
  .biu_pad_awid          	(biu_pad_awid         			),
  .biu_pad_awlen         	(biu_pad_awlen        			),
  .biu_pad_awlock        	(biu_pad_awlock       			),
  .biu_pad_awprot        	(biu_pad_awprot       			),
  .biu_pad_awsize        	(biu_pad_awsize       			),
  .biu_pad_awvalid       	(biu_pad_awvalid      			),
  .biu_pad_bready        	(biu_pad_bready       			),
  .biu_pad_lpmd_b        	(biu_pad_lpmd_b       			),
  .biu_pad_rready        	(biu_pad_rready       			),
  .biu_pad_wdata         	(biu_pad_wdata        			),
  .biu_pad_wid           	(biu_pad_wid          			),
  .biu_pad_wlast         	(biu_pad_wlast        			),
  .biu_pad_wstrb         	(biu_pad_wstrb        			),
  .biu_pad_wvalid        	(biu_pad_wvalid       			),
  .pad_biu_arready       	(fifo_biu_arready     			),
  .pad_biu_awready       	(pad_biu_awready      			),
  .pad_biu_bid           	(pad_biu_bid          			),
  .pad_biu_bresp         	(pad_biu_bresp        			),
  .pad_biu_bvalid        	(pad_biu_bvalid       			),
  .pad_biu_rdata         	(pad_biu_rdata        			),
  .pad_biu_rid           	(pad_biu_rid          			),
  .pad_biu_rlast         	(pad_biu_rlast        			),
  .pad_biu_rresp         	(pad_biu_rresp        			),
  .pad_biu_rvalid        	(pad_biu_rvalid       			),
  .pad_biu_wready        	(pad_biu_wready       			),
  .pad_cpu_rst_b         	(pad_cpu_rst_b        			),
  .pad_yy_dft_clk_rst_b  	(pad_cpu_rst_b        			),
  .pad_cpu_apb_base      	(`APB_BASE_ADDR       			),
  .pad_cpu_sys_cnt		 	(pad_cpu_sys_cnt				),
  //Connect with TDT_DMI_TOP
  .tdt_dmi_pwdata        	(tdt_dmi_pwdata                 ),
  .tdt_dmi_pwrite        	(tdt_dmi_pwrite                 ),
  .tdt_dmi_paddr         	(tdt_dmi_paddr                  ),
  .tdt_dmi_penable       	(tdt_dmi_penable                ),
  .tdt_dmi_psel          	(1'b1                           ),
  .tdt_dmi_pready        	(clusterx_tdt_dmi_pready[0]     ),
  .tdt_dmi_prdata        	(clusterx_tdt_dmi_prdata[31:0]  ),
  .tdt_dmi_pslverr       	(clusterx_tdt_dmi_pslverr[0]    ),
  //Connect with PIC
  .cluster0_pic_paddr	 	(cluster0_pic_paddr				),        
  .cluster0_pic_penable	 	(cluster0_pic_penable			),      
  .cluster0_pic_pprot	 	(cluster0_pic_pprot				),        
  .cluster0_pic_psel	 	(cluster0_pic_psel				), 
  .cluster0_pic_pwdata	 	(cluster0_pic_pwdata			),       
  .cluster0_pic_pwrite	 	(cluster0_pic_pwrite			),  
  .pic_cluster0_prdata	 	(pic_clusterx_prdata[31:0]		),       
  .pic_cluster0_pready	 	(pic_clusterx_pready[0]			),       
  .pic_cluster0_pslverr	 	(pic_clusterx_pslverr[0]		),  
  .plic_hart0_me_int	 	(plic_hartx_me_int[0]  			),         
  .plic_hart0_se_int	 	(plic_hartx_se_int[0]  			), 
  .clint_hart0_ms_int	 	(clint_hartx_ms_int[0] 			),        
  .clint_hart0_mt_int	 	(clint_hartx_mt_int[0] 			),        
  .clint_hart0_ss_int	 	(clint_hartx_ss_int[0] 			),        
  .clint_hart0_st_int	 	(clint_hartx_st_int[0] 			),
  .ciu_pad_async_abort_int	(ciu_pad_async_abort_int		),
`ifdef PMU_LP_MODE_TEST
  .pmu_cpu_pwr_on        	(pmu_cpu_pwr_on                 ), 
  .pmu_cpu_iso_in        	(pmu_cpu_iso_in                 ), 
  .pmu_cpu_iso_out       	(pmu_cpu_iso_out                ), 
  .pmu_cpu_save          	(pmu_cpu_save                   ), 
  .pmu_cpu_restore       	(pmu_cpu_restore                ), 
`endif
  .per_clk               	(per_clk                        ),
  .pll_cpu_clk           	(pll_cpu_clk                    ),
  .sys_tdt_clk           	(sys_tdt_clk                    ) 
);                                                            

//========================================================================+
//                  Instance SOC other IP or Devices					  |		
//========================================================================+
axi_interconnect128  x_axi_interconnect (
  .aclk             (per_clk         ),
  .araddr           (fifo_pad_araddr ),
  .aresetn          (pad_cpu_rst_b   ),
  .arready          (pad_biu_arready ),
  .arready_s0       (arready_s0      ),
  .arready_s1       (arready_s1      ),
  .arready_s2       (arready_s2      ),
  .arready_s3       (arready_s3      ),
  .arvalid          (fifo_pad_arvalid),
  .arvalid_s0       (arvalid_s0      ),
  .arvalid_s1       (arvalid_s1      ),
  .arvalid_s2       (arvalid_s2      ),
  .arvalid_s3       (arvalid_s3      ),
  .awaddr           (biu_pad_awaddr  ),
  .awid             (biu_pad_awid    ),
  .awready          (pad_biu_awready ),
  .awready_s0       (awready_s0      ),
  .awready_s1       (awready_s1      ),
  .awready_s2       (awready_s2      ),
  .awready_s3       (awready_s3      ),
  .awvalid          (biu_pad_awvalid ),
  .awvalid_s0       (awvalid_s0      ),
  .awvalid_s1       (awvalid_s1      ),
  .awvalid_s2       (awvalid_s2      ),
  .awvalid_s3       (awvalid_s3      ),
  .bid              (pad_biu_bid     ),
  .bid_s0           (bid_s0          ),
  .bid_s1           (bid_s1          ),
  .bid_s2           (bid_s2          ),
  .bid_s3           (bid_s3          ),
  .bready           (biu_pad_bready  ),
  .bready_s0        (bready_s0       ),
  .bready_s1        (bready_s1       ),
  .bready_s2        (bready_s2       ),
  .bready_s3        (bready_s3       ),
  .bresp            (pad_biu_bresp   ),
  .bresp_s0         (bresp_s0        ),
  .bresp_s1         (bresp_s1        ),
  .bresp_s2         (bresp_s2        ),
  .bresp_s3         (bresp_s3        ),
  .bvalid           (pad_biu_bvalid  ),
  .bvalid_s0        (bvalid_s0       ),
  .bvalid_s1        (bvalid_s1       ),
  .bvalid_s2        (bvalid_s2       ),
  .bvalid_s3        (bvalid_s3       ),
  .rdata            (pad_biu_rdata   ),
  .rdata_s0         (rdata_s0        ),
  .rdata_s1         (rdata_s1        ),
  .rdata_s2         (rdata_s2        ),
  .rdata_s3         (rdata_s3        ),
  .rid              (pad_biu_rid     ),
  .rid_s0           (rid_s0          ),
  .rid_s1           (rid_s1          ),
  .rid_s2           (rid_s2          ),
  .rid_s3           (rid_s3          ),
  .rlast            (pad_biu_rlast   ),
  .rlast_s0         (rlast_s0        ),
  .rlast_s1         (rlast_s1        ),
  .rlast_s2         (rlast_s2        ),
  .rlast_s3         (rlast_s3        ),
  .rready           (biu_pad_rready  ),
  .rready_s0        (rready_s0       ),
  .rready_s1        (rready_s1       ),
  .rready_s2        (rready_s2       ),
  .rready_s3        (rready_s3       ),
  .rresp            (pad_biu_rresp   ),
  .rresp_s0         (rresp_s0        ),
  .rresp_s1         (rresp_s1        ),
  .rresp_s2         (rresp_s2        ),
  .rresp_s3         (rresp_s3        ),
  .rvalid           (pad_biu_rvalid  ),
  .rvalid_s0        (rvalid_s0       ),
  .rvalid_s1        (rvalid_s1       ),
  .rvalid_s2        (rvalid_s2       ),
  .rvalid_s3        (rvalid_s3       ),
  .wid              (biu_pad_wid     ),
  .wlast            (biu_pad_wlast   ),
  .wready           (pad_biu_wready  ),
  .wready_s0        (wready_s0       ),
  .wready_s1        (wready_s1       ),
  .wready_s2        (wready_s2       ),
  .wready_s3        (wready_s3       ),
  .wvalid           (biu_pad_wvalid  ),
  .wvalid_s0        (wvalid_s0       ),
  .wvalid_s1        (wvalid_s1       ),
  .wvalid_s2        (wvalid_s2       ),
  .wvalid_s3        (wvalid_s3       )
);

axi_fifo  x_axi_fifo (
  .biu_pad_araddr   (biu_pad_araddr  ),
  .biu_pad_arburst  (biu_pad_arburst ),
  .biu_pad_arcache  (biu_pad_arcache ),
  .biu_pad_arid     (biu_pad_arid    ),
  .biu_pad_arlen    (biu_pad_arlen   ),
  .biu_pad_arlock   (biu_pad_arlock  ),
  .biu_pad_arprot   (biu_pad_arprot  ),
  .biu_pad_arsize   (biu_pad_arsize  ),
  .biu_pad_arvalid  (biu_pad_arvalid ),
  .counter_num0     (32'd0           ),
  .counter_num1     (32'd0           ),
  .counter_num2     (32'd0           ),
  .counter_num3     (32'd0           ),
  .counter_num4     (32'd0           ),
  .counter_num5     (32'd0           ),
  .counter_num6     (32'd0           ),
  .counter_num7     (32'd0           ),
  .cpu_clk          (per_clk         ),
  .cpu_rst_b        (pad_cpu_rst_b   ),
  .fifo_biu_arready (fifo_biu_arready),
  .fifo_pad_araddr  (fifo_pad_araddr ),
  .fifo_pad_arburst (fifo_pad_arburst),
  .fifo_pad_arcache (fifo_pad_arcache),
  .fifo_pad_arid    (fifo_pad_arid   ),
  .fifo_pad_arlen   (fifo_pad_arlen  ),
  .fifo_pad_arlock  (fifo_pad_arlock ),
  .fifo_pad_arprot  (fifo_pad_arprot ),
  .fifo_pad_arsize  (fifo_pad_arsize ),
  .fifo_pad_artrust (fifo_pad_artrust),
  .fifo_pad_arvalid (fifo_pad_arvalid),
  .pad_biu_arready  (pad_biu_arready )
);

axi_slave128  x_axi_slave128 (
  .araddr_s0        (fifo_pad_araddr ),
  .arburst_s0       (fifo_pad_arburst),
  .arcache_s0       (fifo_pad_arcache),
  .arid_s0          (fifo_pad_arid   ),
  .arlen_s0         (fifo_pad_arlen  ),
  .arprot_s0        (fifo_pad_arprot ),
  .arready_s0       (arready_s0      ),
  .arsize_s0        (fifo_pad_arsize ),
  .arvalid_s0       (arvalid_s0      ),
  .awaddr_s0        (biu_pad_awaddr  ),
  .awburst_s0       (biu_pad_awburst ),
  .awcache_s0       (biu_pad_awcache ),
  .awid_s0          (biu_pad_awid    ),
  .awlen_s0         (biu_pad_awlen   ),
  .awprot_s0        (biu_pad_awprot  ),
  .awready_s0       (awready_s0      ),
  .awsize_s0        (biu_pad_awsize  ),
  .awvalid_s0       (awvalid_s0      ),
  .bid_s0           (bid_s0          ),
  .bready_s0        (bready_s0       ),
  .bresp_s0         (bresp_s0        ),
  .bvalid_s0        (bvalid_s0       ),
  .pad_cpu_rst_b    (pad_cpu_rst_b   ),
  .pll_core_cpuclk  (per_clk         ),
  .rdata_s0         (rdata_s0        ),
  .rid_s0           (rid_s0          ),
  .rlast_s0         (rlast_s0        ),
  .rready_s0        (rready_s0       ),
  .rresp_s0         (rresp_s0        ),
  .rvalid_s0        (rvalid_s0       ),
  .wdata_s0         (biu_pad_wdata   ),
  .wid_s0           (biu_pad_wid     ),
  .wlast_s0         (biu_pad_wlast   ),
  .wready_s0        (wready_s0       ),
  .wstrb_s0         (biu_pad_wstrb   ),
  .wvalid_s0        (wvalid_s0       ),
  .prog_wen         (prog_wen        ),
  .prog_waddr       (prog_waddr      ),
  .prog_wdata       (prog_wdata      )
);

axi_err128  x_axi_err (
  .araddr_s1        (fifo_pad_araddr ), // I
  .arburst_s1       (fifo_pad_arburst), // I
  .arcache_s1       (fifo_pad_arcache), // I
  .arid_s1          (fifo_pad_arid   ), // I
  .arlen_s1         (fifo_pad_arlen  ), // I
  .arprot_s1        (fifo_pad_arprot ), // I
  .arready_s1       (arready_s1      ), // O
  .arsize_s1        (fifo_pad_arsize ), // I
  .arvalid_s1       (arvalid_s1      ), // I
  .awaddr_s1        (biu_pad_awaddr  ), // I
  .awburst_s1       (biu_pad_awburst ), // I
  .awcache_s1       (biu_pad_awcache ), // I
  .awid_s1          (biu_pad_awid    ), // I
  .awlen_s1         (biu_pad_awlen   ), // I
  .awprot_s1        (biu_pad_awprot  ), // I
  .awready_s1       (awready_s1      ), // O
  .awsize_s1        (biu_pad_awsize  ), // I
  .awvalid_s1       (awvalid_s1      ), // I
  .bid_s1           (bid_s1          ), // O
  .bready_s1        (bready_s1       ), // I
  .bresp_s1         (bresp_s1        ), // O
  .bvalid_s1        (bvalid_s1       ), // O
  .pad_cpu_rst_b    (pad_cpu_rst_b   ), // I
  .pll_core_cpuclk  (per_clk         ), // I
  .rdata_s1         (rdata_s1        ), // O
  .rid_s1           (rid_s1          ), // O
  .rlast_s1         (rlast_s1        ), // O
  .rready_s1        (rready_s1       ), // I
  .rresp_s1         (rresp_s1        ), // O
  .rvalid_s1        (rvalid_s1       ), // O
  .wdata_s1         (biu_pad_wdata   ), // I
  .wid_s1           (biu_pad_wid     ), // I
  .wlast_s1         (biu_pad_wlast   ), // I
  .wready_s1        (wready_s1       ), // O
  .wstrb_s1         (biu_pad_wstrb   ), // I
  .wvalid_s1        (wvalid_s1       )  // I
);


axi2ahb  x_axi2ahb (
  .biu_pad_araddr   (fifo_pad_araddr ),
  .biu_pad_arburst  (fifo_pad_arburst),
  .biu_pad_arcache  (fifo_pad_arcache),
  .biu_pad_arid     (fifo_pad_arid   ),
  .biu_pad_arlen    (fifo_pad_arlen  ),
  .biu_pad_arlock   (fifo_pad_arlock ),
  .biu_pad_arprot   (fifo_pad_arprot ),
  .biu_pad_arsize   (fifo_pad_arsize ),
  .biu_pad_artrust  (fifo_pad_artrust),
  .biu_pad_arvalid  (arvalid_s2      ),
  .biu_pad_awaddr   (biu_pad_awaddr[39:0]  ),
  .biu_pad_awburst  (biu_pad_awburst ),
  .biu_pad_awcache  (biu_pad_awcache ),
  .biu_pad_awid     (biu_pad_awid    ),
  .biu_pad_awlen    (biu_pad_awlen   ),
  .biu_pad_awlock   (biu_pad_awlock  ),
  .biu_pad_awprot   (biu_pad_awprot  ),
  .biu_pad_awsize   (biu_pad_awsize  ),
  .biu_pad_awvalid  (awvalid_s2      ),
  .biu_pad_bready   (bready_s2       ),
  .biu_pad_haddr    (biu_pad_haddr   ),
  .biu_pad_hburst   (biu_pad_hburst  ),
  .biu_pad_hbusreq  (biu_pad_hbusreq ),
  .biu_pad_hlock    (biu_pad_hlock   ),
  .biu_pad_hprot    (biu_pad_hprot   ),
  .biu_pad_hsize    (biu_pad_hsize   ),
  .biu_pad_htrans   (biu_pad_htrans  ),
  .biu_pad_hwdata   (biu_pad_hwdata  ),
  .biu_pad_hwrite   (biu_pad_hwrite  ),
  .biu_pad_rready   (rready_s2       ),
  .biu_pad_wdata    (biu_pad_wdata   ),
  .biu_pad_wid      (biu_pad_wid     ),
  .biu_pad_wlast    (biu_pad_wlast   ),
  .biu_pad_wstrb    (biu_pad_wstrb   ),
  .biu_pad_wvalid   (wvalid_s2       ),
  .pad_biu_arready  (arready_s2      ),
  .pad_biu_awready  (awready_s2      ),
  .pad_biu_bid      (bid_s2          ),
  .pad_biu_bresp    (bresp_s2        ),
  .pad_biu_bvalid   (bvalid_s2       ),
  .pad_biu_hgrant   (pad_biu_hgrant  ),
  .pad_biu_hrdata   (pad_biu_hrdata  ),
  .pad_biu_hready   (pad_biu_hready  ),
  .pad_biu_hresp    (pad_biu_hresp   ),
  .pad_biu_rdata    (rdata_s2        ),
  .pad_biu_rid      (rid_s2          ),
  .pad_biu_rlast    (rlast_s2        ),
  .pad_biu_rresp    (rresp_s2        ),
  .pad_biu_rvalid   (rvalid_s2       ),
  .pad_biu_wready   (wready_s2       ),
  .pad_cpu_rst_b    (pad_cpu_rst_b   ),
  .pll_core_cpuclk  (per_clk         )
);


// axi_err128  x_axi_err1 (
//   .araddr_s1        (fifo_pad_araddr ),
//   .arburst_s1       (fifo_pad_arburst),
//   .arcache_s1       (fifo_pad_arcache),
//   .arid_s1          (fifo_pad_arid   ),
//   .arlen_s1         (fifo_pad_arlen  ),
//   .arprot_s1        (fifo_pad_arprot ),
//   .arready_s1       (arready_s3      ),
//   .arsize_s1        (fifo_pad_arsize ),
//   .arvalid_s1       (arvalid_s3      ),
//   .awaddr_s1        (biu_pad_awaddr  ),
//   .awburst_s1       (biu_pad_awburst ),
//   .awcache_s1       (biu_pad_awcache ),
//   .awid_s1          (biu_pad_awid    ),
//   .awlen_s1         (biu_pad_awlen   ),
//   .awprot_s1        (biu_pad_awprot  ),
//   .awready_s1       (awready_s3      ),
//   .awsize_s1        (biu_pad_awsize  ),
//   .awvalid_s1       (awvalid_s3      ),
//   .bid_s1           (bid_s3          ),
//   .bready_s1        (bready_s3       ),
//   .bresp_s1         (bresp_s3        ),
//   .bvalid_s1        (bvalid_s3       ),
//   .pad_cpu_rst_b    (pad_cpu_rst_b   ),
//   .pll_core_cpuclk  (per_clk         ),
//   .rdata_s1         (rdata_s3        ),
//   .rid_s1           (rid_s3          ),
//   .rlast_s1         (rlast_s3        ),
//   .rready_s1        (rready_s3       ),
//   .rresp_s1         (rresp_s3        ),
//   .rvalid_s1        (rvalid_s3       ),
//   .wdata_s1         (biu_pad_wdata   ),
//   .wid_s1           (biu_pad_wid     ),
//   .wlast_s1         (biu_pad_wlast   ),
//   .wready_s1        (wready_s3       ),
//   .wstrb_s1         (biu_pad_wstrb   ),
//   .wvalid_s1        (wvalid_s3       )
// );


assign #1 biu_pad_htrans_dly[1:0] = biu_pad_htrans[1:0];
assign #1 haddr_dly[39:0] = biu_pad_haddr[39:0];
assign #1 biu_pad_hwrite_dly = biu_pad_hwrite;


ahb  x_ahb (
  .biu_pad_haddr      (haddr_dly         ),
  .biu_pad_hburst     (biu_pad_hburst    ),
  .biu_pad_hbusreq    (biu_pad_hbusreq   ),
  .biu_pad_hlock      (biu_pad_hlock     ),
  .biu_pad_hprot      (biu_pad_hprot     ),
  .biu_pad_hsize      (biu_pad_hsize     ),
  .biu_pad_htrans     (biu_pad_htrans_dly),
  .biu_pad_hwdata     (biu_pad_hwdata    ),
  .biu_pad_hwrite     (biu_pad_hwrite_dly),
  .haddr_s1           (haddr_s1          ),
  .haddr_s2           (haddr_s2          ),
  .haddr_s3           (haddr_s3          ),
  .hburst_s1          (hburst_s1         ),
  .hburst_s2          (hburst_s2         ),
  .hburst_s3          (hburst_s3         ),
  .hmastlock          (hmastlock         ),
  .hprot_s1           (hprot_s1          ),
  .hprot_s2           (hprot_s2          ),
  .hprot_s3           (hprot_s3          ),
  .hrdata_s1          (hrdata_s1         ),
  .hrdata_s2          (hrdata_s2         ),
  .hrdata_s3          (hrdata_s3         ),
  .hready_s1          (hready_s1         ),
  .hready_s2          (hready_s2         ),
  .hready_s3          (hready_s3         ),
  .hresp_s1           (hresp_s1          ),
  .hresp_s2           (hresp_s2          ),
  .hresp_s3           (hresp_s3          ),
  .hsel_s1            (hsel_s1           ),
  .hsel_s2            (hsel_s2           ),
  .hsel_s3            (hsel_s3           ),
  .hsize_s1           (hsize_s1          ),
  .hsize_s2           (hsize_s2          ),
  .hsize_s3           (hsize_s3          ),
  .htrans_s1          (htrans_s1         ),
  .htrans_s2          (htrans_s2         ),
  .htrans_s3          (htrans_s3         ),
  .hwdata_s1          (hwdata_s1         ),
  .hwdata_s2          (hwdata_s2         ),
  .hwdata_s3          (hwdata_s3         ),
  .hwrite_s1          (hwrite_s1         ),
  .hwrite_s2          (hwrite_s2         ),
  .hwrite_s3          (hwrite_s3         ),
  .pad_biu_hgrant     (pad_biu_hgrant    ),
  .pad_biu_hrdata     (pad_biu_hrdata    ),
  .pad_biu_hready     (pad_biu_hready    ),
  .pad_biu_hresp      (pad_biu_hresp     ),
  .pad_cpu_rst_b      (pad_cpu_rst_b     ),
  .pll_core_cpuclk    (per_clk           )
);


mem_ctrl  x_mem_ctrl (
  .haddr_s1        (haddr_s1       ),
  .hburst_s1       (hburst_s1      ),
  .hprot_s1        (hprot_s1       ),
  .hrdata_s1       (hrdata_s1      ),
  .hready_s1       (hready_s1      ),
  .hresp_s1        (hresp_s1       ),
  .hsel_s1         (hsel_s1        ),
  .hsize_s1        (hsize_s1       ),
  .htrans_s1       (htrans_s1      ),
  .hwdata_s1       (hwdata_s1      ),
  .hwrite_s1       (hwrite_s1      ),
  .pad_cpu_rst_b   (pad_cpu_rst_b  ),
  .pll_core_cpuclk (per_clk        )
);


apb  x_apb (
  .b_pad_gpio_porta (b_pad_gpio_porta),
  .biu_pad_haddr    (haddr_dly       ),
  .biu_pad_hprot    (biu_pad_hprot   ),
  .biu_pad_lpmd_b   (biu_pad_lpmd_b  ),
  .clk_en           (axim_clk_en     ),
  .haddr_s2         (haddr_s2        ),
  .hburst_s2        (hburst_s2       ),
  .hmastlock        (hmastlock       ),
  .hprot_s2         (hprot_s2        ),
  .hrdata_s2        (hrdata_s2       ),
  .hready_s2        (hready_s2       ),
  .hresp_s2         (hresp_s2        ),
  .hsel_s2          (hsel_s2         ),
  .hsize_s2         (hsize_s2        ),
  .htrans_s2        (htrans_s2       ),
  .hwdata_s2        (hwdata_s2       ),
  .hwrite_s2        (hwrite_s2       ),
  .i_pad_clk        (i_pad_clk       ),
  .pad_biu_clkratio (                ),
  .pad_cpu_rst_b    (pad_cpu_rst_b   ),
  .per_clk          (per_clk         ),
  .cpu_clk          (cpu_clk         ),
`ifdef PMU_LP_MODE_TEST
  .pmu_cpu_pwr_on   (pmu_cpu_pwr_on  ), 
  .pmu_cpu_iso_in   (pmu_cpu_iso_in  ), 
  .pmu_cpu_iso_out  (pmu_cpu_iso_out ), 
  .pmu_cpu_save     (pmu_cpu_save    ), 
  .pmu_cpu_restore  (pmu_cpu_restore ), 
`endif
  .uart0_sin        (uart0_sin       ),
  .uart0_sout       (uart0_sout      ),
  .xx_intc_vld      (xx_intc_vld     )
);

err_gen  x_err_gen (
  .hburst_s3       (hburst_s3      ),
  .hmastlock       (hmastlock      ),
  .hprot_s3        (hprot_s3       ),
  .hrdata_s3       (hrdata_s3      ),
  .hready_s3       (hready_s3      ),
  .hresp_s3        (hresp_s3       ),
  .hsel_s3         (hsel_s3        ),
  .hsize_s3        (hsize_s3       ),
  .htrans_s3       (htrans_s3      ),
  .hwdata_s3       (hwdata_s3      ),
  .hwrite_s3       (hwrite_s3      ),
  .pad_cpu_rst_b   (pad_cpu_rst_b  ),
  .pll_core_cpuclk (per_clk        )
);

endmodule


