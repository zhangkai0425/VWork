`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2022/02/07 09:59:48
// Design Name:
// Module Name: pulse_syn_fast2s
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

//同步模块工作时钟大约为 25MHz 的模块
//异步数据对来自工作时钟为 100MHz 的模块
module pulse_syn_fast2s
  #( parameter          PULSE_INIT = 1'b0
   )
  (
   input                rstn,
   input                clk_fast,
   input                pulse_fast,
   input                clk_slow,
   output               pulse_slow);

   wire                 clear_n ;
   reg                  pulse_fast_r ;
   /**************** fast clk ***************/
   //(1) 快时钟域检测到脉冲信号时，不急于将脉冲信号拉低
   always@(posedge clk_fast or negedge rstn) begin
        if (!rstn)
           pulse_fast_r  <= PULSE_INIT ;
        else if (!clear_n)
           pulse_fast_r  <= 1'b0 ;
        else if (pulse_fast)
           pulse_fast_r  <= 1'b1 ;
   end

   reg  [1:0]           pulse_fast2s_r ;
   /************ slow clk *************/
   //(2) 慢时钟域对信号进行延迟打拍采样
   always@(posedge clk_slow or negedge rstn) begin
      if (!rstn)
        pulse_fast2s_r     <= 3'b0 ;
      else
        pulse_fast2s_r     <= {pulse_fast2s_r[0], pulse_fast_r} ;
   end
   assign pulse_slow = pulse_fast2s_r[1] ;

   reg [1:0]            pulse_slow2f_r ;
   /********* feedback for slow clk to fast clk *******/
   //(3) 对反馈信号进行延迟打拍采样
   always@(posedge clk_fast or negedge rstn) begin
      if (!rstn)
        pulse_slow2f_r  <= 1'b0 ;
      else
        pulse_slow2f_r  <= {pulse_slow2f_r[0], pulse_slow} ;
   end
   //控制快时钟域脉冲信号拉低
   assign clear_n = ~(!pulse_fast && pulse_slow2f_r[1]) ;


endmodule
