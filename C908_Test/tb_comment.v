
`timescale 1ns/100ps

`define CLK_PERIOD          10
`define TCLK_PERIOD         40
`define MAX_RUN_TIME        32'h3000000

`define SOC_TOP             tb.x_soc
// 目前来看指令内存文件、数据内存文件均保存在S0的RAM里即可，且
`define RTL_MEM             tb.x_soc.x_axi_slave128.x_f_spsram_large
//`define CPU_TOP             tb.x_soc.x_cpu_sub_system_axi.x_c908_inst
`define CPU_TOP             tb.x_soc.x_cpu_sub_system
`define tb_retire0          `CPU_TOP.core0_pad_retire0
`define retire0_pc          `CPU_TOP.core0_pad_retire0_pc[39:0]
`define tb_retire1          `CPU_TOP.core0_pad_retire1
`define retire1_pc          `CPU_TOP.core0_pad_retire1_pc[39:0]
`define CPU_CLK             `CPU_TOP.pll_cpu_clk
`define CPU_RST             `CPU_TOP.pad_cpu_rst_b
`define clk_en              `CPU_TOP.axim_clk_en
// `define CP0_RSLT_VLD        `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_cp0_top.x_ct_cp0_iui.cp0_iu_ex3_rslt_vld
// `define CP0_RSLT            `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_cp0_top.x_ct_cp0_iui.cp0_iu_ex3_rslt_data[63:0]

// `define APB_BASE_ADDR       40'h4000000000
`define APB_BASE_ADDR       40'hb0000000

module tb();
  reg clk;
  reg rst_b;
  // 用来打开内存文件的标识符
  integer FILE;
  // CPU时钟
  initial
  begin
    clk =0;
    forever begin
      #(`CLK_PERIOD/2) clk = ~clk;
    end
  end
  // 复位信号
  initial
  begin
    rst_b = 1;
    #100;
    rst_b = 0;
    #100;
    rst_b = 1;
  end
  
  integer i;
  reg [31:0] mem_inst_temp [16777216:0];
  reg [31:0] mem_data_temp [16777216:0];
  integer j;
  // 初始化指令内存和数据内存
  // 1.对原来的内存清零处理
  // 2.初始化0x0000-0x3FFF成为指令文件
  // 3.初始化0x4000-0x7FFF成为数据文件
  // 目前来看数据文件应该不是我们的程序所生成的，怀疑是CPU启动程序所生成的
  initial
  begin
    $display("\t********* Init Program *********");
    $display("\t********* Wipe memory to 0 *********");
    for(i=0; i < 32'h1000000; i=i+1)
    begin
      `RTL_MEM.ram0.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram1.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram2.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram3.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram4.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram5.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram6.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram7.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram8.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram9.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram10.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram11.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram12.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram13.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram14.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram15.mem[i][7:0] = 8'h0;
    end
  
    $display("\t********* Read program *********");
    $readmemh("inst.mem", mem_inst_temp);
    $readmemh("data.mem", mem_data_temp);
  
    $display("\t********* Load program to memory *********");
    i=0;
    for(j=0;i<32'h4000;i=j/4)
    begin
      `RTL_MEM.ram0.mem[i][7:0] = mem_inst_temp[j][31:24];
      `RTL_MEM.ram1.mem[i][7:0] = mem_inst_temp[j][23:16];
      `RTL_MEM.ram2.mem[i][7:0] = mem_inst_temp[j][15: 8];
      `RTL_MEM.ram3.mem[i][7:0] = mem_inst_temp[j][ 7: 0];
      j = j+1;
      `RTL_MEM.ram4.mem[i][7:0] = mem_inst_temp[j][31:24];
      `RTL_MEM.ram5.mem[i][7:0] = mem_inst_temp[j][23:16];
      `RTL_MEM.ram6.mem[i][7:0] = mem_inst_temp[j][15: 8];
      `RTL_MEM.ram7.mem[i][7:0] = mem_inst_temp[j][ 7: 0];
      j = j+1;
      `RTL_MEM.ram8.mem[i][7:0] = mem_inst_temp[j][31:24];
      `RTL_MEM.ram9.mem[i][7:0] = mem_inst_temp[j][23:16];
      `RTL_MEM.ram10.mem[i][7:0] = mem_inst_temp[j][15: 8];
      `RTL_MEM.ram11.mem[i][7:0] = mem_inst_temp[j][ 7: 0];
      j = j+1;
      `RTL_MEM.ram12.mem[i][7:0] = mem_inst_temp[j][31:24];
      `RTL_MEM.ram13.mem[i][7:0] = mem_inst_temp[j][23:16];
      `RTL_MEM.ram14.mem[i][7:0] = mem_inst_temp[j][15: 8];
      `RTL_MEM.ram15.mem[i][7:0] = mem_inst_temp[j][ 7: 0];
      j = j+1;
    end
    // 目前看来，甚至data.mem内容是无用的，因为不进行初始化也能成功仿真
  end

  initial
  begin
  #(`MAX_RUN_TIME * `CLK_PERIOD);
    $display("**********************************************");
    $display("*   meeting max simulation time, stop!       *");
    $display("**********************************************");
    FILE = $fopen("run_case.report","w");
    $fwrite(FILE,"TEST FAIL");   
  $finish;
  end
  
  reg [31:0] retire_inst_in_period;
  reg [31:0] cycle_count;
  
  `define LAST_CYCLE 50000

// 下面的部分目前来看也是没有用的
//   always @(posedge clk or negedge rst_b)
//   begin
//     if(!rst_b)
//       cycle_count[31:0] <= 32'b1;
//     else 
//       cycle_count[31:0] <= cycle_count[31:0] + 1'b1;
//   end
  
  
//   always @(posedge clk or negedge rst_b)
//   begin
//     if(!rst_b) //reset to zero
//       retire_inst_in_period[31:0] <= 32'b0;
//     else if( (cycle_count[31:0] % `LAST_CYCLE) == 0)//check and reset retire_inst_in_period every 50000 cycles
//     begin
//       if(retire_inst_in_period[31:0] == 0)begin
//         $display("*************************************************************");
//         $display("* Error: There is no instructions retired in the last %d cycles! *", `LAST_CYCLE);
//         $display("*              Simulation Fail and Finished!                *");
//         $display("*************************************************************");
//         #10;
//         FILE = $fopen("run_case.report","w");
//         $fwrite(FILE,"TEST FAIL");   
  
//         $finish;
//       end
//       retire_inst_in_period[31:0] <= 32'b0;
//     end
//     else if(`tb_retire0 || `tb_retire1)
//       retire_inst_in_period[31:0] <= retire_inst_in_period[31:0] + 1'b1;
//   end
  
  
  
  reg [31:0] cpu_awaddr;
  reg [3:0]  cpu_awlen;
  reg [15:0] cpu_wstrb;
  reg        cpu_wvalid;
  reg [63:0] value0;
  reg [63:0] value1;
  reg [63:0] value2;
  
  always @(posedge `CPU_CLK)
  begin
    cpu_awlen[3:0]   <= `SOC_TOP.x_axi_slave128.awlen[3:0];
    cpu_awaddr[31:0] <= `SOC_TOP.x_axi_slave128.mem_addr[31:0];
    cpu_wvalid       <= `SOC_TOP.biu_pad_wvalid;
    cpu_wstrb        <= `SOC_TOP.biu_pad_wstrb;
    // value0           <= `CPU_TOP.core0_pad_wb0_data[63:0];
    // value1           <= `CPU_TOP.core0_pad_wb1_data[63:0];
    // value2           <= `CPU_TOP.core0_pad_wb2_data[63:0];
 
    value0              <= `CPU_TOP.x_C908_TOP.x_pc_top_0.x_pc_core.x_pc_iu_top.x_pc_iu_dp.dp_pipe0_ex4_wb_data[63:0];
    value1              <= `CPU_TOP.x_C908_TOP.x_pc_top_0.x_pc_core.x_pc_iu_top.x_pc_iu_dp.dp_pipe1_ex4_wb_data[63:0];
  end
  
  always @(posedge `CPU_CLK)
  begin
      if(value0 == 64'h444333222 || value1 == 64'h444333222 || value2 == 64'h444333222)
    begin
      $display("**********************************************");
      $display("*    simulation finished successfully        *");
      $display("**********************************************");
     #10;
     FILE = $fopen("run_case.report","w");
     $fwrite(FILE,"TEST PASS");   
  
     $finish;
    end
      else if (value0 == 64'h2382348720 || value1 == 64'h2382348720 || value2 == 64'h444333222)
    begin
     $display("**********************************************");
     $display("*    simulation finished with error          *");
     $display("**********************************************");
     #10;
     FILE = $fopen("run_case.report","w");
     $fwrite(FILE,"TEST FAIL");   
  
     $finish;
    end
  
    else if((cpu_awlen[3:0] == 4'b0) &&
       (cpu_awaddr[31:0] == 32'h01ff_fff0) &&
        cpu_wvalid &&
       `clk_en)
    // 这里的意思其实是以tb.v模块为AXI总线，直接接收CPU传来的数据，并进行字符显示
    // 作用其实就是将C程序里Print的数据打印出来，如何判断是打印应该是按照RISC-V汇编的规则来确定的
    begin
     if(cpu_wstrb[15:0] == 16'hf)
     begin
        $write("%c", `SOC_TOP.biu_pad_wdata[7:0]);
     end
     else if(cpu_wstrb[15:0] == 16'hf0)
     begin
        $write("%c", `SOC_TOP.biu_pad_wdata[39:32]);
     end
     else if(cpu_wstrb[15:0] == 16'hf00)
     begin
        $write("%c", `SOC_TOP.biu_pad_wdata[71:64]);
     end
     else if(cpu_wstrb[15:0] == 16'hf000)
     begin
        $write("%c", `SOC_TOP.biu_pad_wdata[103:96]);
     end
    end
  
  end
 
  parameter cpu_cycle = 110;
  
  soc x_soc(
    .i_pad_clk           ( clk                  ),
    // .b_pad_gpio_porta    (                      ),
    // .i_pad_jtg_trst_b    (                      ),
    // .i_pad_jtg_tclk      (                      ),
    // .i_pad_jtg_tdi       (                      ),
    // .i_pad_jtg_tms       (                      ),
    // .i_pad_uart0_sin     (                      ),
    // .o_pad_jtg_tdo       (                      ),
    // .o_pad_uart0_sout    (                      ),
    .i_pad_rst_b         ( rst_b                )
  );
  
  int_mnt x_int_mnt(
  );
  
// Latest Power control
//`ifdef UPF_INCLUDED
//  import UPF::*;

//  initial
//  begin
//        supply_on ("VDD", 1.00);
//     	supply_on ("VDDG", 1.00);
//  end

//  initial 
//  begin
//    $deposit(tb.x_soc.pmu_cpu_pwr_on,  1'b1);
//    $deposit(tb.x_soc.pmu_cpu_iso_in,  1'b0);
//    $deposit(tb.x_soc.pmu_cpu_iso_out, 1'b0);
//    $deposit(tb.x_soc.pmu_cpu_save,    1'b0);
//    $deposit(tb.x_soc.pmu_cpu_restore, 1'b0);
//  end
//`endif
  
//  reg [31:0] virtual_counter;
  
//  always @(posedge `CPU_CLK or negedge `CPU_RST)
//  begin
//    if(!`CPU_RST)
//      virtual_counter[31:0] <= 32'b0;
//    else if(virtual_counter[31:0]==32'hffffffff)
//      virtual_counter[31:0] <= virtual_counter[31:0];
//    else
//      virtual_counter[31:0] <= virtual_counter[31:0] +1'b1;
//  end 
  
  //always @(*)
  //begin
  //if(virtual_counter[31:0]> 32'h3000000) $finish;
  //end
  
endmodule
