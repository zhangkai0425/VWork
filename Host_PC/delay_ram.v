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
    input           I_Rst_n     ,

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

reg wea_awg_delay_ram1;
reg [10:0] write_addr_to_awg_delay_ram1;
reg [23:0] write_data_to_awg_delay_ram1;
reg [10:0] read_addr_to_awg_delay_ram1;

blk_mem_gen_1 awg_delay_ram1 (
  .clka(I_UART_CLK),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(wea_awg_delay_ram1),      // input wire [0 : 0] wea
  .addra(write_addr_to_awg_delay_ram1),  // input wire [10 : 0] addra
  .dina(write_data_to_awg_delay_ram1),    // input wire [23 : 0] dina
  .clkb(I_DELY_CLK),    // input wire clkb
  .enb(1'b1),      // input wire enb
  .addrb(read_addr_to_awg_delay_ram1),  // input wire [10 : 0] addrb
  .doutb(O_DAC1_DELAY)  // output wire [23 : 0] doutb
);

reg wea_awg_delay_ram2;
reg [10:0] write_addr_to_awg_delay_ram2;
reg [23:0] write_data_to_awg_delay_ram2;
reg [10:0] read_addr_to_awg_delay_ram2;

blk_mem_gen_1 awg_delay_ram2 (
  .clka(I_UART_CLK),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(wea_awg_delay_ram2),      // input wire [0 : 0] wea
  .addra(write_addr_to_awg_delay_ram2),  // input wire [10 : 0] addra
  .dina(write_data_to_awg_delay_ram2),    // input wire [23 : 0] dina
  .clkb(I_DELY_CLK),    // input wire clkb
  .enb(1'b1),      // input wire enb
  .addrb(read_addr_to_awg_delay_ram2),  // input wire [10 : 0] addrb
  .doutb(O_DAC2_DELAY)  // output wire [23 : 0] doutb
);

reg wea_awg_delay_ram3;
reg [10:0] write_addr_to_awg_delay_ram3;
reg [23:0] write_data_to_awg_delay_ram3;
reg [10:0] read_addr_to_awg_delay_ram3;

blk_mem_gen_1 awg_delay_ram3 (
  .clka(I_UART_CLK),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(wea_awg_delay_ram3),      // input wire [0 : 0] wea
  .addra(write_addr_to_awg_delay_ram3),  // input wire [10 : 0] addra
  .dina(write_data_to_awg_delay_ram3),    // input wire [23 : 0] dina
  .clkb(I_DELY_CLK),    // input wire clkb
  .enb(1'b1),      // input wire enb
  .addrb(read_addr_to_awg_delay_ram3),  // input wire [10 : 0] addrb
  .doutb(O_DAC3_DELAY)  // output wire [23 : 0] doutb
);

reg wea_awg_delay_ram4;
reg [10:0] write_addr_to_awg_delay_ram4;
reg [23:0] write_data_to_awg_delay_ram4;
reg [10:0] read_addr_to_awg_delay_ram4;

blk_mem_gen_1 awg_delay_ram4 (
  .clka(I_UART_CLK),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(wea_awg_delay_ram4),      // input wire [0 : 0] wea
  .addra(write_addr_to_awg_delay_ram4),  // input wire [10 : 0] addra
  .dina(write_data_to_awg_delay_ram4),    // input wire [23 : 0] dina
  .clkb(I_DELY_CLK),    // input wire clkb
  .enb(1'b1),      // input wire enb
  .addrb(read_addr_to_awg_delay_ram4),  // input wire [10 : 0] addrb
  .doutb(O_DAC4_DELAY)  // output wire [23 : 0] doutb
);

// 读RAM的地址线设置
always @(posedge I_UART_CLK or negedge I_Rst_n) begin
    if (~I_Rst_n) begin
        read_addr_to_awg_delay_ram1 <= 11'b0;
        read_addr_to_awg_delay_ram2 <= 11'b0;
        read_addr_to_awg_delay_ram3 <= 11'b0;
        read_addr_to_awg_delay_ram4 <= 11'b0;
    end else begin
        read_addr_to_awg_addr_ram1 <= I_READ_ADDR_RAM1;
        read_addr_to_awg_addr_ram2 <= I_READ_ADDR_RAM2;
        read_addr_to_awg_addr_ram3 <= I_READ_ADDR_RAM3;
        read_addr_to_awg_addr_ram4 <= I_READ_ADDR_RAM4;
    end
end

// 写RAM的地址和数据线设置
always @(posedge I_UART_CLK or negedge I_Rst_n) begin
    if (~I_Rst_n) begin
        write_addr_to_awg_delay_ram1 <= 11'b0;
        write_addr_to_awg_delay_ram2 <= 11'b0;
        write_addr_to_awg_delay_ram3 <= 11'b0;
        write_addr_to_awg_delay_ram4 <= 11'b0;
        write_data_to_awg_delay_ram1 <= 11'b0;
        write_data_to_awg_delay_ram2 <= 11'b0;
        write_data_to_awg_delay_ram3 <= 11'b0;
        write_data_to_awg_delay_ram4 <= 11'b0;
    end else begin
        write_addr_to_awg_addr_ram1 <= I_WRITE_ADDR_RAM1;
        write_addr_to_awg_addr_ram2 <= I_WRITE_ADDR_RAM2;
        write_addr_to_awg_addr_ram3 <= I_WRITE_ADDR_RAM3;
        write_addr_to_awg_addr_ram4 <= I_WRITE_ADDR_RAM4;
        write_data_to_awg_delay_ram1 <= I_WRITE_DELAY_RAM1;
        write_data_to_awg_delay_ram2 <= I_WRITE_DELAY_RAM2;
        write_data_to_awg_delay_ram3 <= I_WRITE_DELAY_RAM3;
        write_data_to_awg_delay_ram4 <= I_WRITE_DELAY_RAM4;
    end
end

// 使能信号
always @(posedge I_UART_CLK or negedge I_Rst_n) begin
    if (~I_Rst_n) begin
        wea_awg_delay_ram1 <= 1'b0;
        wea_awg_delay_ram2 <= 1'b0;
        wea_awg_delay_ram3 <= 1'b0;
        wea_awg_delay_ram4 <= 1'b0;
    end else begin
        wea_awg_delay_ram1 <= I_WEA_RAM1;
        wea_awg_delay_ram2 <= I_WEA_RAM2;
        wea_awg_delay_ram3 <= I_WEA_RAM3;
        wea_awg_delay_ram4 <= I_WEA_RAM4;
    end
end

endmodule
