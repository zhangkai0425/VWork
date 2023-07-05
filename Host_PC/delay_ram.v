`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/05 10:43:47
// Design Name: 
// Module Name: delay_ram
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


module Delay_RAM
#(
	parameter MAXIMUM_WIDTH_OF_EACH_CH = 11			//每个通道可以存下的最大波形数目
)
(
    // CLK
	input			I_UART_CLK	,
    input           I_DELY_CLK  ,

    // Write : UART->RAM
    // Write Enable port 1-4
    input           I_WEA_RAM1  ,
    input           I_WEA_RAM2  ,
    input           I_WEA_RAM3  ,
    input           I_WEA_RAM4  ,

    // Write Wave ID port 1-4
    input    [10:0] I_WRITE_ADDR_RAM1 ,
    input    [10:0] I_WRITE_ADDR_RAM2 ,
    input    [10:0] I_WRITE_ADDR_RAM3 ,
    input    [10:0] I_WRITE_ADDR_RAM4 ,

    // Write Data:Delay
    input    [23:0] I_WRITE_DELAY_RAM1,
    input    [23:0] I_WRITE_DELAY_RAM2,
    input    [23:0] I_WRITE_DELAY_RAM3,
    input    [23:0] I_WRITE_DELAY_RAM4,

    // Read Wave ID port 1-4
    input    [10:0] I_READ_ADDR_RAM1 ,
    input    [10:0] I_READ_ADDR_RAM2 ,
    input    [10:0] I_READ_ADDR_RAM3 ,
    input    [10:0] I_READ_ADDR_RAM4 ,

    // Delay of Port 1-4
    output   [23:0] O_DAC1_DELAY,
    output   [23:0] O_DAC2_DELAY,
    output   [23:0] O_DAC3_DELAY,
    output   [23:0] O_DAC4_DELAY	
);





endmodule
