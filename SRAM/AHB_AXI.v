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


module AQE_AXI(
  lite_mmc_hsel,
  lite_yy_haddr,
  lite_yy_hsize,
  lite_yy_htrans,
  lite_yy_hwdata,
  lite_yy_hwrite,
  mmc_lite_hrdata,
  mmc_lite_hready,
  mmc_lite_hresp,
  pad_biu_bigend_b,
  pad_cpu_rst_b,
  pll_core_cpuclk,
  prog_wen,
  prog_wdata,
  prog_waddr,
  iram_par_err,
  dram1_portb_wen,
  dram1_portb_din,
  dram1_portb_dout,
  dram1_portb_addr,
  ram_wen
);

// &Ports; @22
input           lite_mmc_hsel;
input   [31:0]  lite_yy_haddr;
input   [2 :0]  lite_yy_hsize;
input   [1 :0]  lite_yy_htrans;
input   [31:0]  lite_yy_hwdata;
input           lite_yy_hwrite;
input           pad_biu_bigend_b;
input           pad_cpu_rst_b;
input           pll_core_cpuclk;
output  [31:0]  mmc_lite_hrdata;
output          mmc_lite_hready;
output  [1 :0]  mmc_lite_hresp;

//input           iram_portb_clk;
//input   [3:0]   iram_portb_wen;
//input   [31:0]  iram_portb_din;
//output  [31:0]  iram_portb_dout;
//input   [15:0]  iram_portb_addr;
input           prog_wen;
input   [15:0]  prog_waddr;
input   [31:0]  prog_wdata;
output          iram_par_err;

input   [3:0]  dram1_portb_wen;
input   [31:0] dram1_portb_din;
output  [31:0] dram1_portb_dout;
input   [15:0]  dram1_portb_addr;

output[3:0] ram_wen  ;


// &Regs; @23
reg     [15:0]  addr_holding;
reg     [3 :0]  lite_mem_wen;
reg             lite_read_bypass;
reg             lite_read_bypass_vld;
reg             lite_read_stall;
reg             lite_read_stall_vld;
reg     [31:0]  lite_wbuf_addr;
reg     [31:0]  lite_wbuf_data;
reg     [2 :0]  lite_wbuf_size;
reg             lite_write_req;
reg             lite_write_stall;

// &Wires; @24
wire            lite_addr_hit;
wire            lite_addr_no_hit;
wire    [31:0]  lite_bypass_data;
wire    [31:0]  lite_mem_addr;
wire            lite_mem_cen;
wire    [31:0]  lite_mem_din;
wire    [31:0]  lite_mem_dout;
wire            lite_mmc_hsel;
wire            lite_read_addr_hit_with_bypass;
wire            lite_read_addr_hit_with_stall;
wire            lite_read_req;
wire            lite_wbuf_update;
wire            lite_write_cplt;
wire            lite_write_en;
wire            lite_write_req_en;
wire            lite_write_stall_en;
wire    [31:0]  lite_yy_haddr;
wire    [2 :0]  lite_yy_hsize;
wire    [31:0]  lite_yy_hwdata;
wire            lite_yy_hwrite;
wire    [31:0]  mmc_lite_hrdata;
wire            mmc_lite_hready;
wire    [1 :0]  mmc_lite_hresp;
wire            pad_biu_bigend_b;
wire            pad_cpu_rst_b;
wire            pll_core_cpuclk;
wire    [7 :0]  ram0_din;
wire    [7 :0]  ram0_dout;
wire    [7 :0]  ram1_din;
wire    [7 :0]  ram1_dout;
wire    [7 :0]  ram2_din;
wire    [7 :0]  ram2_dout;
wire    [7 :0]  ram3_din;
wire    [7 :0]  ram3_dout;
wire    [15:0]  ram_addr;
wire            ram_clk;
wire    [3 :0]  ram_wen;

parameter IMEM_WIDTH = 17;
// IRAM size = 128KB

// &Force("nonport","lite_mem_addr"); @27
// &Force("nonport","lite_mem_cen"); @28
// &Force("nonport","lite_mem_din"); @29
// &Force("nonport","lite_mem_dout"); @30
// &Force("nonport","lite_mem_wen"); @31
// &Force("input","lite_yy_htrans"); @32
// &Force("bus", "lite_yy_htrans", 1, 0); @33
// //&Force("nonport",""); @34
// //&Force("nonport",""); @35
// //&Force("nonport",""); @36
// //&Force("nonport",""); @37
// //&Force("nonport",""); @38
// //&Force("nonport",""); @39
// //&Force("nonport",""); @40


//write buffer
assign lite_wbuf_update = lite_yy_hwrite && lite_mmc_hsel;
always @ (posedge pll_core_cpuclk or negedge pad_cpu_rst_b)
begin
  if(!pad_cpu_rst_b)
  begin
    lite_wbuf_addr[31:0] <= 32'b0;
    lite_wbuf_size[2:0]  <= 3'b0;
  end
  else if (lite_wbuf_update)
  begin
    lite_wbuf_addr[31:0] <= lite_yy_haddr;
    lite_wbuf_size[2:0]  <= lite_yy_hsize;
  end
  //else if (lite_write_cplt)
  //begin
  //  lite_wbuf_addr[31:0] <= 32'b0;
  //  lite_wbuf_size[2:0]  <= 3'b0;
  //end
end
//write data
always @ (posedge pll_core_cpuclk or negedge pad_cpu_rst_b)
begin
  if(!pad_cpu_rst_b)
  begin
    lite_wbuf_data[31:0] <= 32'b0;
  end
  else if (lite_write_req)
  begin
    lite_wbuf_data[31:0] <= lite_yy_hwdata[31:0];
  end
end
//read first and wirte will stall when address don't hit
assign lite_write_stall_en = lite_write_req && lite_addr_no_hit && lite_read_req;
always @ (posedge pll_core_cpuclk or negedge pad_cpu_rst_b)
begin
  if(!pad_cpu_rst_b)
  begin
    lite_write_stall <= 1'b0;
  end
  else if (lite_write_stall_en)
  begin
    lite_write_stall <= 1'b1;
  end
  else if (lite_write_cplt)
  begin
     lite_write_stall <=1'b0;
  end
end
//write request from bus interface
assign lite_write_req_en = lite_yy_hwrite && lite_mmc_hsel;
always @ (posedge pll_core_cpuclk or negedge pad_cpu_rst_b)
begin
  if(!pad_cpu_rst_b)
  begin
    lite_write_req <= 1'b0;
  end
  else if (lite_write_req_en)
  begin
    lite_write_req <= 1'b1;
  end
  else
  begin
    lite_write_req <= 1'b0;
  end
end
//read bypass and read stall
always @(posedge pll_core_cpuclk or negedge pad_cpu_rst_b)
begin
  if(!pad_cpu_rst_b)
  begin
    lite_read_bypass <= 1'b0;
    lite_read_stall  <= 1'b0;
  end
  else
  begin
    lite_read_bypass <= lite_read_addr_hit_with_bypass;
    lite_read_stall  <= lite_read_addr_hit_with_stall;
  end
end

//no read first and write request or write stall
assign lite_write_en    = ((lite_write_req | lite_write_stall) && (lite_addr_hit | (lite_yy_hwrite && lite_mmc_hsel) | ~lite_mmc_hsel));
assign lite_bypass_data[31:0] = lite_wbuf_data[31:0];
//write complete
assign lite_write_cplt  = (lite_write_req | lite_write_stall) && (lite_addr_hit | ~lite_mmc_hsel | (lite_yy_hwrite && lite_mmc_hsel));
//read request
assign lite_read_req    = ~lite_yy_hwrite && lite_mmc_hsel;
//address hit
assign lite_addr_no_hit = (lite_yy_haddr[31:2] != lite_wbuf_addr[31:2]);
assign lite_addr_hit    = ~lite_addr_no_hit;
//address hit and read will bypass
assign lite_read_addr_hit_with_bypass = lite_read_req && (lite_write_req | lite_write_stall) && lite_addr_hit && lite_read_bypass_vld;
//address hit but read will stall
assign lite_read_addr_hit_with_stall  = lite_read_req && (lite_write_req | lite_write_stall) && lite_addr_hit && lite_read_stall_vld;

//read bypass or stall
// &CombBeg; @140
always @( lite_yy_haddr[1:0]
       or lite_wbuf_addr[1:0]
       or lite_wbuf_size[2:0]
       or lite_yy_hsize[2:0])
begin
casez({lite_wbuf_size[2:0],lite_yy_hsize[2:0],lite_wbuf_addr[1:0],lite_yy_haddr[1:0]})
//st.b/ld.b
10'b000_000_00_00,
10'b000_000_01_01,
10'b000_000_10_10,
10'b000_000_11_11:
  begin
    lite_read_bypass_vld = 1'b1;
    lite_read_stall_vld = 1'b0;
  end
//st.b/ld.h
10'b000_001_??_??:
  begin
    lite_read_stall_vld = 1'b1;
    lite_read_bypass_vld = 1'b0;
  end
//st.b/ld.w
10'b000_010_??_??:
  begin
    lite_read_stall_vld = 1'b1;
    lite_read_bypass_vld = 1'b0;
  end
//st.h/ld.b
10'b001_000_0?_0?,
10'b001_000_1?_1?:
  begin
    lite_read_bypass_vld = 1'b1;
    lite_read_stall_vld = 1'b0;
  end
//st.h/ld.h
10'b001_001_0?_0?,
10'b001_001_1?_1?:
  begin
    lite_read_bypass_vld = 1'b1;
    lite_read_stall_vld = 1'b0;
  end
//st.h/ld.w
10'b001_010_??_??:
  begin
    lite_read_stall_vld = 1'b1;
    lite_read_bypass_vld = 1'b0;
  end
//st.w/all lds
10'b010_???_??_??:
  begin
    lite_read_bypass_vld = 1'b1;
    lite_read_stall_vld = 1'b0;
  end
default:
  begin
    lite_read_bypass_vld = 1'b0;
    lite_read_stall_vld = 1'b0;
  end
endcase
// &CombEnd; @195
end



//memory select
assign lite_mem_cen = ~(lite_read_req | lite_write_req | lite_write_stall);
//memory write enable
// &CombBeg; @202
always @( lite_wbuf_addr[1:0]
       or lite_wbuf_size[2:0]
       or pad_biu_bigend_b
       or lite_write_en)
begin
  case({pad_biu_bigend_b, lite_write_en, lite_wbuf_size[2:0], lite_wbuf_addr[1:0]})
  7'b0100000:
    begin
      lite_mem_wen[3:0] = 4'b0111;
    end
  7'b0100001:
    begin
      lite_mem_wen[3:0] = 4'b1011;
    end
  7'b0100010:
    begin
      lite_mem_wen[3:0] = 4'b1101;
    end
  7'b0100011:
    begin
      lite_mem_wen[3:0] = 4'b1110;
    end
  7'b0100100:
    begin
      lite_mem_wen[3:0] = 4'b0011;
    end
  7'b0100110:
    begin
      lite_mem_wen[3:0] = 4'b1100;
    end
  7'b0101000:
    begin
      lite_mem_wen[3:0] = 4'b0000;
    end
  7'b1100000:
    begin
      lite_mem_wen[3:0] = 4'b1110;
    end
  7'b1100001:
    begin
      lite_mem_wen[3:0] = 4'b1101;
    end
  7'b1100010:
    begin
      lite_mem_wen[3:0] = 4'b1011;
    end
  7'b1100011:
    begin
      lite_mem_wen[3:0] = 4'b0111;
    end
  7'b1100100:
    begin
      lite_mem_wen[3:0] = 4'b1100;
    end
  7'b1100110:
    begin
      lite_mem_wen[3:0] = 4'b0011;
    end
  7'b1101000:
     begin
       lite_mem_wen[3:0] = 4'b0000;
     end
  default:
    begin
      lite_mem_wen[3:0] = 4'b1111;
    end
  endcase
// &CombEnd; @265
end

assign lite_mem_addr[31:0] = (lite_write_en | lite_read_stall) ? lite_wbuf_addr[31:0] : lite_yy_haddr[31:0];
assign lite_mem_din[31:0] = (lite_write_stall) ? lite_wbuf_data[31:0] : lite_yy_hwdata[31:0];
assign mmc_lite_hrdata[31:0] = lite_read_bypass ? lite_bypass_data[31:0] : lite_mem_dout[31:0];
assign mmc_lite_hready       = !lite_read_stall;
assign mmc_lite_hresp[1:0]   = 2'b0;



//memory
always @(posedge pll_core_cpuclk)
begin
  if(!lite_mem_cen)
    addr_holding[IMEM_WIDTH-3:0] <= lite_mem_addr[IMEM_WIDTH-1:2];
end

assign ram_clk = pll_core_cpuclk;
assign ram_addr[IMEM_WIDTH-3:0] = prog_wen ? prog_waddr[IMEM_WIDTH-3:0] :
                                lite_mem_cen ? addr_holding[IMEM_WIDTH-3:0] : lite_mem_addr[IMEM_WIDTH-1:2];
assign ram_wen[0] = prog_wen | (!lite_mem_cen && !lite_mem_wen[0]);
assign ram_wen[1] = prog_wen | (!lite_mem_cen && !lite_mem_wen[1]);
assign ram_wen[2] = prog_wen | (!lite_mem_cen && !lite_mem_wen[2]);
assign ram_wen[3] = prog_wen | (!lite_mem_cen && !lite_mem_wen[3]);

assign ram0_din[7:0] = prog_wen ? prog_wdata[7:0] : lite_mem_din[7:0];
assign ram1_din[7:0] = prog_wen ? prog_wdata[15:8] : lite_mem_din[15:8];
assign ram2_din[7:0] = prog_wen ? prog_wdata[23:16] : lite_mem_din[23:16];
assign ram3_din[7:0] = prog_wen ? prog_wdata[31:24] : lite_mem_din[31:24];
assign lite_mem_dout[31:0] = {ram3_dout[7:0], ram2_dout[7:0], ram1_dout[7:0], ram0_dout[7:0]};

/*************
 * IRAM 128KB
 * **********/
// unified_SPRAM #(
//         .MEMORY_PRIMITIVE("block"),   //"auto","block","distributed","ultra"
//         .MEMORY_INIT_FILE("iRAM_init.mem"),      // String
//         .ADDR_WIDTH_A(15),
//         .READ_LATENCY_A(1),
//         .WRITE_DATA_WIDTH_A(32),        // DECIMAL
//         .READ_DATA_WIDTH_A(32)
// 	) inst_iram(
//     .rsta       (!pad_cpu_rst_b),
//     .clka       (ram_clk),
//     .wea        (|ram_wen[3:0]),
//     .ena        (1'b1),
//     .addra      (ram_addr[14:0]),
//     .dina       ({ram3_din, ram2_din, ram1_din, ram0_din}),
//     .douta      ({ram3_dout[7:0], ram2_dout[7:0], ram1_dout[7:0], ram0_dout[7:0]}),
//     .parity_err (iram_par_err) //at rd_clk
// );
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