
`timescale 1ns/100ps
/*
测试要求：
1.汇编代码得到的64位地址+数据作为UART_TX的发送模块
还是四个port
固定AWG_ID = 14
Port |  Delay
1    |   10
2    |   20
3    |   30
4    |   40
2.UART_TX发送后，经过一个Buffer作为UART_RX的输入，可以参考top.v
3.测试UART_RX是否能够正常解码，以及解码后得到的64位数据是什么东西
是否能对的上原来的64位数据
4.测试是否能够从UART_RX正确写入我们的delay_RAM中，查看写数据波形是否正确
5.模拟从delay_RAM读取，看能否读到正确的delay
*/


module tb();
  reg clk;
  reg rst_b;
  integer FILE;
  
  initial
  begin
    clk =0;
    forever begin
      #(`CLK_PERIOD/2) clk = ~clk;
    end
  end
  
  initial
  begin
    rst_b = 1;
    #100;
    rst_b = 0;
    #100;
    rst_b = 1;
  end
  
  // test dual port:
  reg prog_wen;
  reg [39:0] prog_waddr;
  reg [127:0] prog_wdata;
  reg uart2sys_en;
  reg [39:0] uart2sys_addr;
  reg [127:0] uart2sys_data;
  reg sys_wren;
  reg [39:0] sys_final_addr;
  reg [127:0] sys_data;
  initial
  begin
    uart2sys_en = 0;
    sys_wren = 0;
    prog_wen = 0;
    uart2sys_addr = 40'h0002000020;
    sys_final_addr = 40'h0002000020; 
    prog_waddr = 40'h0001ffffe0;
    uart2sys_data = 128'h7;
    sys_data = 128'h8;
    prog_wdata = 128'h4;
    #(`CLK_PERIOD*10);
    prog_wen = 1;
    #(`CLK_PERIOD*100);
    prog_wen = 0;
    #(`CLK_PERIOD*2000);
    uart2sys_en = 1;
    #(`CLK_PERIOD*10);
    uart2sys_en = 0;
    #(`CLK_PERIOD*10);
    sys_wren = 1;
    #(`CLK_PERIOD*100);
    sys_wren = 0;
  end

  
endmodule