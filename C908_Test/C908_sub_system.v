`define PC_PA_WIDTH 40
`ifdef TDT_MP_PROCESSOR_3
     `define TDT_MP_DM_CORE_NUM                  4
     `define TDT_MP_DM_ALLCORE_NSCRATCH          {`TDT_MP_DM_CORE_NSCRATCH, `TDT_MP_DM_CORE_NSCRATCH, `TDT_MP_DM_CORE_NSCRATCH, `TDT_MP_DM_CORE_NSCRATCH}
     `define TDT_MP_DM_ALLCORE_ISA               {`TDT_MP_DM_CORE_ISA, `TDT_MP_DM_CORE_ISA, `TDT_MP_DM_CORE_ISA, `TDT_MP_DM_CORE_ISA}
     `define TDT_MP_CORE_1_EXISTS
     `define TDT_MP_CORE_2_EXISTS
     `define TDT_MP_CORE_3_EXISTS
`else
  `ifdef TDT_MP_PROCESSOR_2
     `define TDT_MP_DM_CORE_NUM                  3
     `define TDT_MP_DM_ALLCORE_NSCRATCH          {`TDT_MP_DM_CORE_NSCRATCH, `TDT_MP_DM_CORE_NSCRATCH, `TDT_MP_DM_CORE_NSCRATCH}
     `define TDT_MP_DM_ALLCORE_ISA               {`TDT_MP_DM_CORE_ISA, `TDT_MP_DM_CORE_ISA, `TDT_MP_DM_CORE_ISA}
     `define TDT_MP_CORE_1_EXISTS
     `define TDT_MP_CORE_2_EXISTS
  `else
    `ifdef TDT_MP_PROCESSOR_1
       `define TDT_MP_DM_CORE_NUM                  2
       `define TDT_MP_DM_ALLCORE_NSCRATCH          {`TDT_MP_DM_CORE_NSCRATCH, `TDT_MP_DM_CORE_NSCRATCH}
       `define TDT_MP_DM_ALLCORE_ISA               {`TDT_MP_DM_CORE_ISA, `TDT_MP_DM_CORE_ISA}
       `define TDT_MP_CORE_1_EXISTS
    `else
       `define TDT_MP_DM_CORE_NUM                  1
       `define TDT_MP_DM_SINGLE_CORE
       `define TDT_MP_DM_ALLCORE_NSCRATCH          `TDT_MP_DM_CORE_NSCRATCH
       `define TDT_MP_DM_ALLCORE_ISA               `TDT_MP_DM_CORE_ISA
    `endif
  `endif
`endif
module C908_sub_system
#(parameter SV48_CONFIG=0)
(
  axim_clk_en,
  biu_pad_araddr,
  biu_pad_arburst,
  biu_pad_arcache,
  biu_pad_arid,
  biu_pad_arlen,
  biu_pad_arlock,
  biu_pad_arprot,
  biu_pad_arsize,
  biu_pad_arvalid,
  biu_pad_awaddr,
  biu_pad_awburst,
  biu_pad_awcache,
  biu_pad_awid,
  biu_pad_awlen,
  biu_pad_awlock,
  biu_pad_awprot,
  biu_pad_awsize,
  biu_pad_awvalid,
  biu_pad_bready,
  biu_pad_lpmd_b,
  biu_pad_rready,
  biu_pad_wdata,
  biu_pad_wid,
  biu_pad_wlast,
  biu_pad_wstrb,
  biu_pad_wvalid,
  pad_biu_arready,
  pad_biu_awready,
  pad_biu_bid,
  pad_biu_bresp,
  pad_biu_bvalid,
  pad_biu_rdata,
  pad_biu_rid,
  pad_biu_rlast,
  pad_biu_rresp,
  pad_biu_rvalid,
  pad_biu_wready,
  pad_cpu_apb_base,
  pad_cpu_rst_b,
  pad_yy_dft_clk_rst_b,
  per_clk,
  pll_cpu_clk,
`ifdef PMU_LP_MODE_TEST
  pmu_cpu_iso_in,
  pmu_cpu_iso_out,
  pmu_cpu_pwr_on,
  pmu_cpu_restore,
  pmu_cpu_save,
`endif
  sys_tdt_clk,
  tdt_dmi_paddr,
  tdt_dmi_penable,
  tdt_dmi_prdata,
  tdt_dmi_pready,
  tdt_dmi_psel,
  tdt_dmi_pslverr,
  tdt_dmi_pwdata,
  tdt_dmi_pwrite,
  pad_cpu_sys_cnt,    
  cluster0_pic_paddr,        
  cluster0_pic_penable,      
  cluster0_pic_pprot,        
  cluster0_pic_psel,         
  cluster0_pic_pwdata,       
  cluster0_pic_pwrite,  
  pic_cluster0_prdata,       
  pic_cluster0_pready,       
  pic_cluster0_pslverr,  
  plic_hart0_me_int,         
  plic_hart0_se_int, 
  clint_hart0_ms_int,        
  clint_hart0_mt_int,        
  clint_hart0_ss_int,        
  clint_hart0_st_int,    
  ciu_pad_async_abort_int,

);

// &Ports; @7
input            axim_clk_en;               
input            pad_biu_arready;           
input            pad_biu_awready;           
input   [7  :0]  pad_biu_bid;               
input   [1  :0]  pad_biu_bresp;             
input            pad_biu_bvalid;            
input   [127:0]  pad_biu_rdata;             
input   [7  :0]  pad_biu_rid;               
input            pad_biu_rlast;             
input   [1  :0]  pad_biu_rresp;             
input            pad_biu_rvalid;            
input            pad_biu_wready;            
input   [39 :0]  pad_cpu_apb_base;          
input   [0  :0]  pad_cpu_rst_b;             
input            pad_yy_dft_clk_rst_b;      
input            per_clk;                   
input   [0  :0]  pll_cpu_clk;
`ifdef PMU_LP_MODE_TEST               
input            pmu_cpu_iso_in;            
input            pmu_cpu_iso_out;           
input            pmu_cpu_pwr_on;            
input            pmu_cpu_restore;           
input            pmu_cpu_save;
`endif              
input            sys_tdt_clk;               
input   [11 :0]  tdt_dmi_paddr;             
input            tdt_dmi_penable;           
input            tdt_dmi_psel;              
input   [31 :0]  tdt_dmi_pwdata;            
input            tdt_dmi_pwrite;            
output  [39 + SV48_CONFIG :0]  biu_pad_araddr;            
output  [1  :0]  biu_pad_arburst;           
output  [3  :0]  biu_pad_arcache;           
output  [7  :0]  biu_pad_arid;              
output  [7  :0]  biu_pad_arlen;             
output           biu_pad_arlock;            
output  [2  :0]  biu_pad_arprot;            
output  [2  :0]  biu_pad_arsize;            
output           biu_pad_arvalid;           
output  [39 + SV48_CONFIG :0]  biu_pad_awaddr;            
output  [1  :0]  biu_pad_awburst;           
output  [3  :0]  biu_pad_awcache;           
output  [7  :0]  biu_pad_awid;              
output  [7  :0]  biu_pad_awlen;             
output           biu_pad_awlock;            
output  [2  :0]  biu_pad_awprot;            
output  [2  :0]  biu_pad_awsize;            
output           biu_pad_awvalid;           
output           biu_pad_bready;            
output  [1  :0]  biu_pad_lpmd_b;            
output           biu_pad_rready;            
output  [127:0]  biu_pad_wdata;             
output  [7  :0]  biu_pad_wid;               
output           biu_pad_wlast;             
output  [15 :0]  biu_pad_wstrb;             
output           biu_pad_wvalid;            
output  [31 :0]  tdt_dmi_prdata;            
output           tdt_dmi_pready;            
output           tdt_dmi_pslverr;           
input   [63 :0]  pad_cpu_sys_cnt;           
input   [31 :0]  pic_cluster0_prdata;       
input   [0  :0]  pic_cluster0_pready;       
input   [0  :0]  pic_cluster0_pslverr;  
input            plic_hart0_me_int;         
input            plic_hart0_se_int; 
input            clint_hart0_ms_int;        
input            clint_hart0_mt_int;        
input            clint_hart0_ss_int;        
input            clint_hart0_st_int;   
output  [31 :0]  cluster0_pic_paddr;        
output  [0  :0]  cluster0_pic_penable;      
output  [1  :0]  cluster0_pic_pprot;        
output  [0  :0]  cluster0_pic_psel;         
output  [31 :0]  cluster0_pic_pwdata;       
output  [0  :0]  cluster0_pic_pwrite;  
output           ciu_pad_async_abort_int;   

// LLP signal

//从CPU System中引出LLP信号
//仿照AQE_AHB模块写AQE_AXI模块，并将AXI协议写入，同时信号对应LLP信号
//在AQE_AXI中例化对应的SRAM即可




// &Regs; @8
wire     [63 :0]  pad_cpu_sys_cnt;           

// &Wires; @9
wire             axim_clk_en;               
wire    [39 + SV48_CONFIG :0]  biu_pad_araddr;            
wire    [1  :0]  biu_pad_arburst;           
wire    [3  :0]  biu_pad_arcache;           
wire    [7  :0]  biu_pad_arid;              
wire    [7  :0]  biu_pad_arlen;             
wire             biu_pad_arlock;            
wire    [2  :0]  biu_pad_arprot;            
wire    [2  :0]  biu_pad_arsize;            
wire             biu_pad_arvalid;           
wire    [39 + SV48_CONFIG:0]  biu_pad_awaddr;            
wire    [1  :0]  biu_pad_awburst;           
wire    [3  :0]  biu_pad_awcache;           
wire    [7  :0]  biu_pad_awid;              
wire    [7  :0]  biu_pad_awlen;             
wire             biu_pad_awlock;            
wire    [2  :0]  biu_pad_awprot;            
wire    [2  :0]  biu_pad_awsize;            
wire             biu_pad_awvalid;           
wire             biu_pad_bready;            
wire             biu_pad_cactive;           
wire             biu_pad_csysack;           
wire    [1  :0]  biu_pad_lpmd_b;            
wire             biu_pad_rready;            
wire    [127:0]  biu_pad_wdata;             
wire    [7  :0]  biu_pad_wid;               
wire             biu_pad_wlast;             
wire    [15 :0]  biu_pad_wstrb;             
wire             biu_pad_wvalid;            
wire             ciu_pad_async_abort_int;   
wire             pad_yy_dft_clk_rst_b;      
wire             per_clk;                   
// PIC <-> CPU 
wire    [31:0]  cluster0_pic_paddr;        
wire    [0 :0]  cluster0_pic_penable;      
wire    [1 :0]  cluster0_pic_pprot;        
wire    [0 :0]  cluster0_pic_psel;         
wire    [31:0]  cluster0_pic_pwdata;       
wire    [0 :0]  cluster0_pic_pwrite;  
wire    [31:0]  pic_cluster0_prdata;       
wire    [0 :0]  pic_cluster0_pready;       
wire    [0 :0]  pic_cluster0_pslverr;  
wire            plic_hart0_me_int;         
wire            plic_hart0_se_int; 
wire            clint_hart0_ms_int;        
wire            clint_hart0_mt_int;        
wire            clint_hart0_ss_int;        
wire            clint_hart0_st_int;
             
wire             core0_pad_halted;          
wire             core0_pad_lpmd_b;          
wire    [63 :0]  core0_pad_mstatus;         
wire    [4  :0]  core0_pad_par_violation;   
wire             core0_pad_retire0;         
wire    [39 + 2*SV48_CONFIG :0]  core0_pad_retire0_pc;      
wire             core0_pad_retire1;         
wire    [39 + 2*SV48_CONFIG :0]  core0_pad_retire1_pc;      
wire             core0_pad_sleep_out;       
wire    [3  :0]  core0_pad_zoneid;          
wire             cpu_func_rst_b;            
wire             cpu_pad_l2cache_flush_done; 
wire             cpu_pad_no_op;             
wire             cpu_pad_sleep_out;         
wire             pad_biu_arready;           
wire             pad_biu_awready;           
wire    [7  :0]  pad_biu_bid;               
wire    [1  :0]  pad_biu_bresp;             
wire             pad_biu_bvalid;            
wire    [127:0]  pad_biu_rdata;             
wire    [7  :0]  pad_biu_rid;               
wire             pad_biu_rlast;             
wire    [1  :0]  pad_biu_rresp;             
wire             pad_biu_rvalid;            
wire             pad_biu_wready;            
wire    [39 :0]  pad_cpu_apb_base;          
wire    [0  :0]  pad_cpu_rst_b;             
           
wire    [0  :0]  pll_cpu_clk;               
wire             sys_tdt_clk;               
wire [`TDT_MP_DM_CORE_NUM-1:0] tdt_dm_pad_hartreset_n ;
wire             tdt_dm_pad_ndmreset_n  ;     
wire    [11 :0]  tdt_dmi_paddr;             
wire             tdt_dmi_penable;           
wire    [31 :0]  tdt_dmi_prdata;            
wire             tdt_dmi_pready;            
wire             tdt_dmi_psel;              
wire             tdt_dmi_pslverr;           
wire    [31 :0]  tdt_dmi_pwdata;            
wire             tdt_dmi_pwrite;            


//==========================================================+
//                  Instance C908 MP TOP 					| 
//==========================================================+
pc_mp_top  x_C908_TOP (
  .axim_clk_en                (axim_clk_en               ),
  .biu_pad_araddr             (biu_pad_araddr            ),
  .biu_pad_arburst            (biu_pad_arburst           ),
  .biu_pad_arcache            (biu_pad_arcache           ),
  .biu_pad_arid               (biu_pad_arid              ),
  .biu_pad_arlen              (biu_pad_arlen             ),
  .biu_pad_arlock             (biu_pad_arlock            ),
  .biu_pad_arprot             (biu_pad_arprot            ),
  .biu_pad_arsize             (biu_pad_arsize            ),
  .biu_pad_arvalid            (biu_pad_arvalid           ),
  .biu_pad_awaddr             (biu_pad_awaddr            ),
  .biu_pad_awburst            (biu_pad_awburst           ),
  .biu_pad_awcache            (biu_pad_awcache           ),
  .biu_pad_awid               (biu_pad_awid              ),
  .biu_pad_awlen              (biu_pad_awlen             ),
  .biu_pad_awlock             (biu_pad_awlock            ),
  .biu_pad_awprot             (biu_pad_awprot            ),
  .biu_pad_awsize             (biu_pad_awsize            ),
  .biu_pad_awvalid            (biu_pad_awvalid           ),
  .biu_pad_bready             (biu_pad_bready            ),
  .biu_pad_cactive            (biu_pad_cactive           ),
  .biu_pad_csysack            (biu_pad_csysack           ),
  .biu_pad_rready             (biu_pad_rready            ),
  .biu_pad_wdata              (biu_pad_wdata             ),
  .biu_pad_wlast              (biu_pad_wlast             ),
  .biu_pad_wstrb              (biu_pad_wstrb             ),
  .biu_pad_wvalid             (biu_pad_wvalid            ),
  .pad_biu_arready            (pad_biu_arready           ),
  .pad_biu_awready            (pad_biu_awready           ),
  .pad_biu_bid                (pad_biu_bid               ),
  .pad_biu_bresp              (pad_biu_bresp             ),
  .pad_biu_bvalid             (pad_biu_bvalid            ),
  .pad_biu_csysreq            (1'b0                      ),
  .pad_biu_rdata              (pad_biu_rdata             ),
  .pad_biu_rid                (pad_biu_rid               ),
  .pad_biu_rlast              (pad_biu_rlast             ),
  .pad_biu_rvalid             (pad_biu_rvalid            ),
  .pad_biu_wready             (pad_biu_wready            ),
  //------------------------------------------------------------------
  // ACE
  .pad_biu_rresp               (pad_biu_rresp            ), 
  //------------------------------------------------------------------
  
      .llp_clk_en                  (1'b1                     ), //I LLP接口与外部�?�线同步时钟使能信号
    .llp_pad_araddr              (                         ),   //O 读地�?通道地址
    .llp_pad_arburst             (                         ),   //O 读地�?通道突发指示信号
    .llp_pad_arcache             (                         ),   //O 读地�?通道读请求对应的cache属�??
    .llp_pad_arid                (                         ),   //O 读地�?通道读地�?ID 8'b0
    .llp_pad_arlen               (                         ),   //O 读地�?通道突发传输长度
    .llp_pad_arlock              (                         ),   //O 读地�?通道读请求对应的访问方式
    .llp_pad_arprot              (                         ),   //O 读地�?通道读请求的保护类型
    .llp_pad_arsize              (                         ),   //O 读地�?通道读请求每拍数据位�?
    .llp_pad_arvalid             (                         ),   //O 读地�?通道读地�?有效信号
    .llp_pad_awaddr              (                         ),   //O 写地�?通道地址
    .llp_pad_awburst             (                         ),   //O 写地�?通道突发指示信号
    .llp_pad_awcache             (                         ),   //O 写地�?通道写请求对应的cache属�??
    .llp_pad_awid                (                         ),   //O 写地�?通道写地�?ID 8'b0
    .llp_pad_awlen               (                         ),   //O 写地�?通道突发传输长度
    .llp_pad_awlock              (                         ),   //O 写地�?通道写请求的访问方式
    .llp_pad_awprot              (                         ),   //O 写地�?通道写请求的保护类型
    .llp_pad_awsize              (                         ),   //O 写地�?通道写请求每拍数据位�?
    .llp_pad_awvalid             (                         ),   //O 写地�?通道写地�?有效信号
    .llp_pad_bready              (                         ),   //O 写响应�?�道ready信号
    .llp_pad_rready              (                         ),   //O 读数据�?�道ready信号
    .llp_pad_wdata               (                         ),   //O 写数据�?�道数据
    .llp_pad_wlast               (                         ),   //O 写数据�?�道写最后一拍指示信�?
    .llp_pad_wstrb               (                         ),   //O 写数据�?�道写数据字节有效信�? 
    .llp_pad_wvalid              (                         ),   //O 写数据�?�道写数据有效信�?
    .pad_llp_arready             (1'b0                     ),   //I 读地�?通道有效信号
    .pad_llp_awready             (1'b0                     ),   //I 写数据�?�道有效信号
    .pad_llp_bid                 (8'h0                     ),   //I 写响应ID
    .pad_llp_bresp               (2'b0                     ),   //I 写响应信�?
    .pad_llp_bvalid              (1'b0                     ),   //I 写响应有效信�?
    .pad_llp_rdata               (128'h0                   ),   //I 读数据�?�线
    .pad_llp_rid                 (8'h0                     ),   //I 读数据ID
    .pad_llp_rlast               (1'b0                     ),   //I 读数据最后一拍指示信�?
    .pad_llp_rresp               (2'b0                     ),   //I 读响应信号AXI[1:0],ACE[3:0]
    .pad_llp_rvalid              (1'b0                     ),   //I 读数据有效信�?
    .pad_llp_wready              (1'b0                     ),   //I 写数据�?�道ready信号
    .pad_cpu_llp_base           (40'hffffffffff            ),   //I 指定LLP端口的基地址
    .pad_cpu_llp_mask           (40'hffffffffff            ),   //I 指定LLP端口的size

  //--------------------------------------------------------
  // Device slave if
     .slvif_clk_en                (1'b1                     ),
   .pad_slvif_araddr            ({`PC_PA_WIDTH{1'b0}}     ),
   .pad_slvif_arburst           (2'h0                     ),
   .pad_slvif_arcache           (4'h0                     ),
   .pad_slvif_arid              (5'h0                     ),
   .pad_slvif_arlen             (8'h0                     ),
   .pad_slvif_arlock            (1'b0                     ),
   .pad_slvif_arprot            (3'h0                     ),
   .pad_slvif_arsize            (3'h0                     ),
   .pad_slvif_arvalid           (1'b0                     ),
   .pad_slvif_awaddr            ({`PC_PA_WIDTH{1'b0}}     ),
   .pad_slvif_awburst           (2'h0                     ),
   .pad_slvif_awcache           (4'h0                     ),
   .pad_slvif_awid              (5'h0                     ),
   .pad_slvif_awlen             (8'h0                     ),
   .pad_slvif_awlock            (1'b0                     ),
   .pad_slvif_awprot            (3'h0                     ),
   .pad_slvif_awsize            (3'h0                     ),
   .pad_slvif_awvalid           (1'b0                     ),
   .pad_slvif_bready            (1'b0                     ),
   .pad_slvif_rready            (1'b0                     ),
   .pad_slvif_wdata             (128'h0                   ),
   .pad_slvif_wlast             (1'b0                     ),
   .pad_slvif_wstrb             (16'h0                    ),
   .pad_slvif_wvalid            (1'b0                     ),
   .slvif_pad_arready           (                         ),
   .slvif_pad_awready           (                         ),
   .slvif_pad_bid               (                         ),
   .slvif_pad_bresp             (                         ),
   .slvif_pad_bvalid            (                         ),
   .slvif_pad_rdata             (                         ),
   .slvif_pad_rid               (                         ),
   .slvif_pad_rlast             (                         ),
   .slvif_pad_rresp             (                         ),
   .slvif_pad_rvalid            (                         ),
   .slvif_pad_wready            (                         ),

  //--------------------------------------------------------
  .ciu_pad_async_abort_int    (ciu_pad_async_abort_int   ),
  .ciu_pic_paddr              (cluster0_pic_paddr        ),
  .ciu_pic_penable            (cluster0_pic_penable      ),
  .ciu_pic_pprot              (cluster0_pic_pprot        ),
  .ciu_pic_psel               (cluster0_pic_psel         ),
  .ciu_pic_pwdata             (cluster0_pic_pwdata       ),
  .ciu_pic_pwrite             (cluster0_pic_pwrite       ),
  .pic_ciu_prdata             (pic_cluster0_prdata 		 ),
  .pic_ciu_pready             (pic_cluster0_pready       ),
  .pic_ciu_pslverr            (pic_cluster0_pslverr		 ),
  .cpu_pad_l2cache_flush_done (cpu_pad_l2cache_flush_done),
  .cpu_pad_no_op              (cpu_pad_no_op             ),
  .cpu_pad_sleep_out          (cpu_pad_sleep_out         ),
  //------------------------------------------------------------------
  // Debug port for FPGA
  .cpu_debug_port              (                         ),

      .pad_cpu_mdbgen              (1'b1			           ),
    .pad_cpu_zdbgen              (16'b0			           ),
    .core0_pad_zoneid			 (core0_pad_zoneid		   ),
    .core0_pad_par_violation     (core0_pad_par_violation  ),
   
  //----------------------- Core 0 ---------------------------------
  .core0_pad_halted           (core0_pad_halted          ),
  .core0_pad_lpmd_b           (core0_pad_lpmd_b          ),
  .core0_pad_mstatus          (core0_pad_mstatus         ),
  .core0_pad_retire0          (core0_pad_retire0         ),
  .core0_pad_retire0_pc       (core0_pad_retire0_pc      ),
  .core0_pad_retire1          (core0_pad_retire1         ),
  .core0_pad_retire1_pc       (core0_pad_retire1_pc      ),
  .core0_pad_sleep_out        (core0_pad_sleep_out       ),
  .pad_core0_iso_en           (1'b0                      ),
  .pad_core0_ms_int           (clint_hart0_ms_int        ),
  .pad_core0_mt_int           (clint_hart0_mt_int        ),
  .pad_core0_ss_int           (clint_hart0_ss_int        ),
  .pad_core0_st_int           (clint_hart0_st_int        ),
  .pad_core0_me_int           (plic_hart0_me_int         ),
  .pad_core0_se_int           (plic_hart0_se_int         ),
  .pad_core0_rst_b            (cpu_func_rst_b            ),
  .pad_core0_rvba             (40'b0                     ),
  .pad_core0_sleep_in         (1'b0                      ),
  //--------------------------------------------------------
  
  
  
  //--------------------------------------------------------
  .pad_cpu_apb_base           	(pad_cpu_apb_base          ),
  .pad_cpu_clusterid          	(4'b0                      ),
  .pad_cpu_l2cache_flush_req  	(1'b0                      ),
  .pad_cpu_rst_b              	(pad_cpu_rst_b             ),
  .pad_cpu_sleep_in           	(1'b0                      ),
  .pad_cpu_sys_cnt            	(pad_cpu_sys_cnt           ),
  .pad_tdt_dm_core_unavail    	({`TDT_MP_DM_CORE_NUM{1'b0}}),
  .pad_tdt_dm_nextdm_base     	(32'b0                     ),
  .pad_yy_dft_clk_disable     	(1'b0                      ),
  .pad_yy_dft_clk_rst_b       	(pad_yy_dft_clk_rst_b      ),
  .pad_yy_dft_clk_sel         	(1'b0                      ),
  .pad_yy_dft_mcp_hold        	(1'b0                      ),
  .pad_yy_dft_ram_hold        	(1'b0                      ),
  .pad_yy_icg_scan_en         	(1'b0                      ),
  .pad_yy_mbist_mode          	(1'b0                      ),
  .pad_yy_scan_enable         	(1'b0                      ),
  .pad_yy_scan_mode           	(1'b0                      ),
  .pad_yy_scan_rst_b          	(1'b1                      ),
  .pll_cpu_clk                	(pll_cpu_clk               ),
  .sys_apb_clk                	(sys_tdt_clk               ),
  .sys_apb_rst_b              	(pad_cpu_rst_b             ),
  .tdt_dm_pad_hartreset_n     	(tdt_dm_pad_hartreset_n    ),
  .tdt_dm_pad_ndmreset_n      	(tdt_dm_pad_ndmreset_n     ),
  .tdt_dmi_paddr              	(tdt_dmi_paddr             ),
  .tdt_dmi_penable            	(tdt_dmi_penable           ),
  .tdt_dmi_prdata             	(tdt_dmi_prdata            ),
  .tdt_dmi_pready             	(tdt_dmi_pready            ),
  .tdt_dmi_psel               	(tdt_dmi_psel              ),
  .tdt_dmi_pslverr            	(tdt_dmi_pslverr           ),
  .tdt_dmi_pwdata             	(tdt_dmi_pwdata            ),
  .tdt_dmi_pwrite             	(tdt_dmi_pwrite            ),
  .pad_cpu_l2cache_init_disable	( 1'b0                     ), // I 
  .pad_tdt_in_iso_en           	( 1'b0                     ), // I >tdt_mp_top, no use
  .pad_tdt_out_iso_en          	( 1'b0                     ), // I >tdt_mp_top, no use
  .pad_tdt_sleep_in            	( 1'b0                     ), // I >tdt_mp_top, no use 
  .tdt_pad_sleep_out           	(                          )  // O >tdt_mp_top, no use 
);

assign cpu_func_rst_b = pad_cpu_rst_b &  tdt_dm_pad_ndmreset_n & tdt_dm_pad_hartreset_n[0];
assign biu_pad_lpmd_b[1:0] = {2{core0_pad_lpmd_b}};


//==========================================================+
//                  Instance WID_for_AXI4 					|
//==========================================================+
wid_for_axi4  x_wid_for_axi4 (
  .biu_pad_awid    (biu_pad_awid   ),
  .biu_pad_awvalid (biu_pad_awvalid),
  .biu_pad_wid     (biu_pad_wid    ),
  .biu_pad_wlast   (biu_pad_wlast  ),
  .biu_pad_wvalid  (biu_pad_wvalid ),
  .pad_biu_awready (pad_biu_awready),
  .pad_biu_wready  (pad_biu_wready ),
  .pad_cpu_rst_b   (pad_cpu_rst_b  ),
  .per_clk         (per_clk        )
);

// &ModuleEnd; @181
endmodule


