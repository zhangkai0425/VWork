`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Zhangkai
//
// Create Date: 2023/1/17 14:00
// Design Name:
// Module Name: AQE_AXI
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

//From CPU Master interface to System RAM

module AQE_AXI(
  // AXI Slave Ports:Master interface
  araddr_s1,    //I
  arburst_s1,   //I
  arcache_s1,   //I
  arid_s1,      //I
  arlen_s1,     //I
  arprot_s1,    //I
  arready_s1,   //O
  arsize_s1,    //I
  arvalid_s1,   //I
  awaddr_s1,    //I
  awburst_s1,   //I
  awcache_s1,   //I
  awid_s1,      //I
  awlen_s1,     //I
  awprot_s1,    //I
  awready_s1,   //O
  awsize_s1,    //I
  awvalid_s1,   //I
  bid_s1,       //O
  bready_s1,    //O
  bresp_s1,     //O    
  bvalid_s1,    //O
  pad_cpu_rst_b, // 与AQE_AHB同
  pll_core_cpuclk, // 与AQE_AHB同
  rdata_s1,     //O
  rid_s1,       //O
  rlast_s1,     //O
  rready_s1,    //I
  rresp_s1,     //O
  rvalid_s1,    //O
  wdata_s1,     //I
  wid_s1,       //I
  wlast_s1,     //I
  wready_s1,    //O
  wstrb_s1,     //I
  wvalid_s1,    //I

/*
  // AQE_AHB  原有的信号
  // lite_mmc_hsel,
  // lite_yy_haddr,
  // lite_yy_hsize,
  // lite_yy_htrans,
  // lite_yy_hwdata,
  // lite_yy_hwrite,
  // mmc_lite_hrdata,
  // mmc_lite_hready,
  // mmc_lite_hresp,
  // CPU相关的信号,之后再考虑
  // pad_biu_bigend_b, 不知道对应哪个信号
*/

  // AQE_AXI LLP Ports
  // Input 
  llp_pad_araddr, //I 读地址通道地址
  llp_pad_arburst,//I 读地址通道突发指示信号
  llp_pad_arcache,//I 读地址通道读请求对应的cache属性
  llp_pad_arid,//I 读地址通道读地址ID 8'b0
  llp_pad_arlen ,//I 读地址通道突发传输长度
  llp_pad_arlock,//I 读地址通道读请求对应的访问方式
  llp_pad_arprot,//I 读地址通道读请求的保护类型
  llp_pad_arsize,//I 读地址通道读请求每拍数据位宽
  llp_pad_arvalid,//I 读地址通道读地址有效信号
  llp_pad_awaddr,//I 写地址通道地址
  llp_pad_awburst,//I 写地址通道突发指示信号
  llp_pad_awcache,//I 写地址通道写请求对应的cache属性
  llp_pad_awid,//I 写地址通道写地址ID 8'b0
  llp_pad_awlen,//I 写地址通道突发传输长度
  llp_pad_awlock,//I 写地址通道写请求的访问方式
  llp_pad_awprot,//I 写地址通道写请求的保护类型
  llp_pad_awsize,//I 写地址通道写请求每拍数据位宽
  llp_pad_awvalid,//I 写地址通道写地址有效信号
  llp_pad_bready,//I 写响应通道ready信号
  llp_pad_rready,//I 读数据通道ready信号
  llp_pad_wdata,//I 写数据通道数据:TODO::我们写Mem的主要数据来源1
  llp_pad_wlast,//I 写数据通道写最后一拍指示信号
  llp_pad_wstrb,//I 写数据通道写数据字节有效信号 
  llp_pad_wvalid,//I 写数据通道写数据有效信号
  
  //Output
  llp_clk_en, //O LLP接口与外部总线同步时钟使能信号
  pad_llp_arready,//O 读地址通道有效信号
  pad_llp_awready,//O 写数据通道有效信号
  pad_llp_bid,//O 写响应ID
  pad_llp_bresp,//O 写响应信号
  pad_llp_bvalid,//O 写响应有效信号
  pad_llp_rdata,//O 读数据总线
  pad_llp_rid,//O 读数据ID
  pad_llp_rlast,//O 读数据最后一拍指示信号
  pad_llp_rresp,//O 读响应信号AXI[1:0],ACE[3:0]
  pad_llp_rvalid,//O 读数据有效信号
  pad_llp_wready,//O 写数据通道ready信号

  pad_cpu_llp_base,//O 指定LLP端口的基地址
  pad_cpu_llp_mask,//O 指定LLP端口的size

  //Program read/write
  //自定义写变量
  prog_wen,//I 
  prog_waddr,//I
  prog_wdata,//I

  dram1_portb_wen,//I
  dram1_portb_din,//I
  dram1_portb_dout,//O
  dram1_portb_addr//I

  ram_wen
);

// AXI slave Ports
input   [39 :0]  araddr_s1;      
input   [1  :0]  arburst_s1;     
input   [3  :0]  arcache_s1;     
input   [7  :0]  arid_s1;        
input   [7  :0]  arlen_s1;       
input   [2  :0]  arprot_s1;      
input   [2  :0]  arsize_s1;      
input            arvalid_s1;     
input   [39 + SV48_CONFIG:0]  awaddr_s1;      
input   [1  :0]  awburst_s1;     
input   [3  :0]  awcache_s1;     
input   [7  :0]  awid_s1;        
input   [7  :0]  awlen_s1;       
input   [2  :0]  awprot_s1;      
input   [2  :0]  awsize_s1;      
input            awvalid_s1;     
input            bready_s1;      
input            pad_cpu_rst_b;  
input            pll_core_cpuclk; 
input            rready_s1;      
input   [127:0]  wdata_s1;       
input   [7  :0]  wid_s1;         
input            wlast_s1;       
input   [15 :0]  wstrb_s1;       
input            wvalid_s1;      
output           arready_s1;     
output           awready_s1;     
output  [7  :0]  bid_s1;         
output  [1  :0]  bresp_s1;       
output           bvalid_s1;      
output  [127:0]  rdata_s1;       
output  [7  :0]  rid_s1;         
output           rlast_s1;       
output  [1  :0]  rresp_s1;       
output           rvalid_s1;      
output           wready_s1; 
/*
// LLP ports
input   [39:0]  llp_pad_araddr;
input   [1:0]   llp_pad_arburst;
input   [3:0]   llp_pad_arcache;
input   [7:0]   llp_pad_arid;
input   [7:0]   llp_pad_arlen;
input           llp_pad_arlock;
input   [2:0]   llp_pad_arprot;
input   [2:0]   llp_pad_arsize;
input           llp_pad_arvalid;
input   [39:0]  llp_pad_awaddr;
input   [1:0]   llp_pad_awburst;
input   [3:0]   llp_pad_awcache;
input   [7:0]   llp_pad_awid;
input   [7:0]   llp_pad_awlen;
input           llp_pad_awlock;
input   [2:0]   llp_pad_awprot;
input   [2:0]   llp_pad_awsize;
input           llp_pad_awvalid;
input           llp_pad_bready;
input           llp_pad_rready;
input   [127:0] llp_pad_wdata;
input           llp_pad_wlast;
input   [15:0]  llp_pad_wstrb;
input           llp_pad_wvalid;

output          llp_clk_en;
output          pad_llp_arready;
output          pad_llp_awready;
output  [7:0]   pad_llp_bid;
output  [1:0]   pad_llp_bresp;
output          pad_llp_bvalid;
output  [127:0] pad_llp_rdata;
output  [7:0]   pad_llp_rid;
output          pad_llp_rlast;
output  [3:0]   pad_llp_rresp;
output          pad_llp_rvalid;
output          pad_llp_wready;

output  [39:0]  pad_cpu_llp_base;
output  [39:0]  pad_cpu_llp_mask;

*/

// Self defined ports
input           prog_wen;
input   [15:0]  prog_waddr;
input   [31:0]  prog_wdata;
output          iram_par_err;

// 数据位宽有待讨论
input   [3:0]   dram1_portb_wen;
input   [31:0]  dram1_portb_din;
output  [31:0]  dram1_portb_dout;
input   [15:0]  dram1_portb_addr;

output[3:0] ram_wen  ;


/*
// // &Ports; @22
// input           lite_mmc_hsel;
// input   [31:0]  lite_yy_haddr;
// input   [2 :0]  lite_yy_hsize;
// input   [1 :0]  lite_yy_htrans;
// input   [31:0]  lite_yy_hwdata;
// input           lite_yy_hwrite;
// input           pad_biu_bigend_b;
// input           pad_cpu_rst_b;
// input           pll_core_cpuclk;
// output  [31:0]  mmc_lite_hrdata;
// output          mmc_lite_hready;
// output  [1 :0]  mmc_lite_hresp;
*/

reg     [7  :0]  arid;           
reg     [7  :0]  arlen;          
reg              arready;        
reg     [7  :0]  awid;           
reg     [7  :0]  awlen;          
reg              awready;        
reg     [7  :0]  bid;            
reg     [1  :0]  cur_state;      
reg     [39 :0]  mem_addr;       
reg              mem_cen;        
reg     [127:0]  mem_din;        
reg     [15 :0]  mem_wen;        
reg     [1  :0]  next_state;     
reg              read_dly;       
reg     [7  :0]  read_step;      
reg              rvalid;         
reg     [7  :0]  write_step;     


wire    [39 :0]  araddr_s1;      
wire    [7  :0]  arid_s1;        
wire    [7  :0]  arlen_s1;       
wire             arready_s1;     
wire             arvalid_s1;     
//wire    [39 :0]  awaddr_s1;
wire	[39 + SV48_CONFIG:0]  awaddr_s1;      
wire    [7  :0]  awid_s1;        
wire    [7  :0]  awlen_s1;       
wire             awready_s1;     
wire             awvalid_s1;     
wire    [7  :0]  bid_s1;         
wire             bready_s1;      
wire    [1  :0]  bresp_s1;       
wire             bvalid;         
wire             bvalid_s1;      
wire    [127:0]  mem_dout;       
wire             pad_cpu_rst_b;  
wire             pll_core_cpuclk; 
wire    [127:0]  rdata_s1;       
wire             read_over;      
wire    [7  :0]  rid_s1;         
wire             rlast;          
wire             rlast_s1;       
wire             rready_s1;      
wire    [1  :0]  rresp_s1;       
wire             rvalid_s1;      
wire    [127:0]  wdata_s1;       
wire             wrap2_1;        
wire             wrap2_read_en;  
wire             wrap2_write_en; 
wire             wrap4_1;        
wire             wrap4_2;        
wire             wrap4_3;        
wire             wrap4_read_en;  
wire             wrap4_write_en; 
wire             wready;         
wire             wready_s1;      
wire             write_over;     
wire    [15 :0]  wstrb_s1;       
wire             wvalid_s1;      


parameter IDLE  = 2'b00;
parameter WRITE = 2'b01;
parameter WRITE_RESP = 2'b10;
parameter READ  = 2'b11;

assign  rdata_s1[127:0] = 128'h0;
assign  rid_s1[7:0] = arid[7:0];
assign  rlast_s1 = rlast;
assign  rresp_s1[1:0] = 2'b10;
assign  rvalid_s1 = rvalid;
assign  arready_s1 = arready;
assign  wready_s1 = wready;
assign  awready_s1 = awready;
assign  bid_s1[7:0] = bid[7:0];
assign  bresp_s1[1:0] = 2'b10;
assign  bvalid_s1 = bvalid;
assign  bvalid = (cur_state[1:0] == WRITE_RESP);

assign  read_over = (read_step[7:0] == arlen[7:0]) ? 1'b1 : 1'b0;
assign  write_over = (write_step[7:0] == awlen[7:0]) ? 1'b1 : 1'b0;

always@(posedge pll_core_cpuclk or negedge pad_cpu_rst_b)
begin
  if(!pad_cpu_rst_b)
    cur_state[1:0] <= IDLE;
  else
    cur_state[1:0] <= next_state[1:0];
end


always @( arvalid_s1
       or write_over
       or rready_s1
       or wready
       or cur_state[1:0]
       or bready_s1
       or awvalid_s1
       or rvalid
       or wvalid_s1
       or read_over
       or bvalid)
begin
    next_state[1:0] = IDLE;
    case(cur_state[1:0])
    IDLE:
      begin
        if(arvalid_s1)
            next_state[1:0] = READ;
        else if(awvalid_s1)
            next_state[1:0] = WRITE;
        else
            next_state[1:0] = IDLE;
      end
    READ:
      begin
        if(read_over && rvalid && rready_s1)
            next_state[1:0] = IDLE;
        else
            next_state[1:0] = READ;
      end
    WRITE:
      begin
        if(write_over && wvalid_s1 && wready)
            next_state[1:0] = WRITE_RESP;
        else
            next_state[1:0] = WRITE;
      end
    WRITE_RESP:
      begin
        if(bvalid && bready_s1)
            next_state[1:0] = IDLE;
        else
            next_state[1:0] = WRITE_RESP;
      end
    default:
      begin
            next_state[1:0] = 2'bxx;
      end
    endcase

end


always@ (posedge pll_core_cpuclk or negedge pad_cpu_rst_b)
begin
  if(!pad_cpu_rst_b) begin

      arid[7:0] <= 8'b0;
      arlen[7:0] <= 8'b0;

      awid[7:0] <= 8'b0;
      awlen[7:0] <= 8'b0;
  end
  else if(cur_state==IDLE) begin

      arid[7:0] <= arid_s1[7:0];
      arlen[7:0] <= arlen_s1[7:0];

      awid[7:0] <= awid_s1[7:0];
      awlen[7:0] <= awlen_s1[7:0];
  end
end


always @ (posedge pll_core_cpuclk or negedge pad_cpu_rst_b)
begin
  if(!pad_cpu_rst_b)
      read_step[7:0] <= 8'b0;
  else if(next_state[1:0] == IDLE)
      read_step[7:0] <= 8'b0;
  else if((cur_state[1:0] == READ) && rready_s1 && rvalid)
      read_step[7:0] <= read_step[7:0] + 1'b1;
  else 
      read_step[7:0] <= read_step[7:0];
end


always @ (posedge pll_core_cpuclk or negedge pad_cpu_rst_b)
begin
  if(!pad_cpu_rst_b)
      write_step[7:0] <= 8'b0;
  else if(next_state[1:0] == IDLE)
      write_step[7:0] <= 8'b0;
  else if((cur_state[1:0] == WRITE) && wvalid_s1 && wready)
      write_step[7:0] <= write_step[7:0] + 1'b1;
  else 
      write_step[7:0] <= write_step[7:0];
end


assign wrap2_read_en = (cur_state[1:0]==READ)&&(arlen[7:0]==8'b0001);
assign wrap2_write_en = (cur_state[1:0]==WRITE)&&(awlen[7:0]==8'b0001);
assign wrap4_read_en = (cur_state[1:0]==READ)&&(arlen[7:0]==8'b0011);
assign wrap4_write_en = (cur_state[1:0]==WRITE)&&(awlen[7:0]==8'b0011);


assign wrap2_1 = (mem_addr[4]==1'b1)&&(((read_step[7:0]==8'h0)&&wrap2_read_en)||
                 ((write_step[7:0]==8'h0)&&wrap2_write_en));


assign wrap4_1 = (mem_addr[5:4]==2'b11)&&(((read_step[7:0]==8'h0)&&wrap4_read_en)||
                 ((write_step[7:0]==8'h0)&&wrap4_write_en));


assign wrap4_2 = (mem_addr[5:4]==2'b11)&&(((read_step[7:0]==8'h01)&&wrap4_read_en)||
                 ((write_step[7:0]==8'h01)&&wrap4_write_en));


assign wrap4_3 = (mem_addr[5:4]==2'b11)&&(((read_step[7:0]==8'h02)&&wrap4_read_en)||
                 ((write_step[7:0]==8'h02)&&wrap4_write_en));

always @ (posedge pll_core_cpuclk or negedge pad_cpu_rst_b)
begin
  if(!pad_cpu_rst_b)
    begin
      mem_addr[39:0] <= 40'b0;
    end
  else if((cur_state[1:0] == IDLE) && arvalid_s1)
    begin
      mem_addr[39:0] <= araddr_s1[39:0];
    end
  else if((cur_state[1:0] == IDLE) && awvalid_s1)
    begin
      mem_addr[39:0] <= awaddr_s1[39:0];
    end
  else if((wrap4_1 || wrap4_2 || wrap4_3) && 
          ((wvalid_s1 && wready) || (rready_s1 && rvalid)))
    begin
      mem_addr[39:0] <= mem_addr[39:0] - 6'h30;
    end
  else if((wrap2_1) &&
          ((wvalid_s1 && wready) || (rready_s1 && rvalid)))
    begin
      mem_addr[39:0] <= mem_addr[39:0] - 5'h10;
    end
  else if((wvalid_s1 && wready) || (rready_s1 && rvalid))
    begin
      mem_addr[39:0] <= mem_addr[39:0] + 5'h10;
    end
end


assign wready = (cur_state[1:0]==WRITE);


always @ (posedge pll_core_cpuclk or negedge pad_cpu_rst_b)
begin
  if(!pad_cpu_rst_b)
      read_dly <= 1'b0;
  else if((arvalid_s1 && arready) || (rvalid && rready_s1))
      read_dly <= 1'b1;
  else
      read_dly <= 1'b0;
end

always @ (posedge pll_core_cpuclk or negedge pad_cpu_rst_b)
begin
  if(!pad_cpu_rst_b)
      rvalid <= 1'b0;
  else if((cur_state[1:0] == READ) && read_dly)
      rvalid <= 1'b1;
  else if(rvalid && rready_s1)
      rvalid <= 1'b0;
end



assign rlast = ((read_step[7:0]==arlen[7:0]) && rvalid);



always @( arvalid_s1
       or cur_state[1:0])
begin
      arready = 1'b0;
      awready = 1'b0;
  case(cur_state[1:0])
  IDLE:
    begin
      if(arvalid_s1)
        arready = 1'b1;
      else
        awready = 1'b1;
    end
  READ:
    begin
      arready = 1'b0;
      awready = 1'b0;
    end
  WRITE:
    begin
      arready = 1'b0;
      awready = 1'b0;
    end
  WRITE_RESP:
    begin
      arready = 1'b0;
      awready = 1'b0;
    end
  default:
    begin
      arready = 1'bx;
      awready = 1'bx;
    end
  endcase

end



always @( awid
       or cur_state[1:0])
begin
  case(cur_state[1:0])
  IDLE:
    begin
      bid[7:0] = 8'b0;
    end
  READ:
    begin
      bid[7:0] = 8'b0;
    end
  WRITE:
    begin
      bid[7:0] = 8'b0;
    end
  WRITE_RESP:
    begin
      bid[7:0] = awid;
    end
  default:
    begin
      bid[7:0] = 8'bxxxx;
    end
  endcase

end


always @( cur_state
       or wdata_s1[127:0]
       or wready
       or wvalid_s1
       or wstrb_s1[15:0])
begin
  if(cur_state == READ)
    begin
      mem_cen = 1'b0;
      mem_wen[15:0] = 16'hffff;
      mem_din[127:0] = 128'b0;
    end
  else if(wvalid_s1 && wready)
    begin
      mem_cen = 1'b0;
      mem_wen[15:0] = ~wstrb_s1[15:0];
      mem_din[127:0] = wdata_s1[127:0];
    end
  else
    begin
      mem_cen = 1'b1;
      mem_wen[15:0] = 16'hffff;
      mem_din[127:0] = 128'b0;
    end

end


f_spsram_32768x128  x_f_spsram_32768x128_L (
  .A               (mem_addr[18:4] ),
  .CEN             (1'b1           ),
  .CLK             (pll_core_cpuclk),
  .D               (mem_din[127:0] ),
  .Q               (mem_dout[127:0]),
  .WEN             (mem_wen[15:0]  )
);

//TODO:
//1.Decide whether to use TDRAM or f_spsram
//2.mem_cen的具体功能
//3.Program写入信号的加入

// System ram used before in E906
unified_TDPRAM #(
     .MEMORY_PRIMITIVE("block"),   //"auto","block","distributed","ultra"
     .CLOCKING_MODE("common_clock"),
     .MEMORY_INIT_FILE("sRAM_init.mem"),      // String
     .BYTE_WRITE_EN(1),      // DECIMAL
     .READ_LATENCY_A(1),
     .READ_LATENCY_B(2),
     .ADDR_WIDTH_A(13), //10
     .ADDR_WIDTH_B(13), //10
     .WRITE_DATA_WIDTH_A(32),        // DECIMAL
     .WRITE_DATA_WIDTH_B(32),        // DECIMAL
     .READ_DATA_WIDTH_A(32),
     .READ_DATA_WIDTH_B(32)
	) x1_inst_sharemem (
.rsta(!pad_cpu_rst_b),
.rstb(!pad_cpu_rst_b),
.clka(ram_clk),
.wea(ram_wen[3:0]),
.ena(1'b1),
.addra(ram_addr[12:0]),
.dina({ram3_din, ram2_din, ram1_din, ram0_din}),
.douta({ram3_dout[7:0], ram2_dout[7:0], ram1_dout[7:0], ram0_dout[7:0]}),
.clkb(ram_clk),
.addrb(dram1_portb_addr[12:0]),
.dinb(dram1_portb_din),
.web(dram1_portb_wen),
.enb(1'b1),
.doutb(dram1_portb_dout),
.parity_err()
);

endmodule