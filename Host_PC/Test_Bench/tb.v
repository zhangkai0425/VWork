
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
    // reg clk;
    reg rst_b;
    
    // 这是时钟区域：可以生成多个时钟
    reg clk_10mhz;
    reg clk_250mhz;

    initial begin
      clk_10mhz = 0;
      clk_250mhz = 0;

      // 10 MHz clock
      forever #50 clk_10mhz = ~clk_10mhz;

      // 250 MHz clock
      forever #4 clk_250mhz = ~clk_250mhz;
    end
    
    initial
    begin
        rst_b = 1;
        #100;
        rst_b = 0;
        #100;
        rst_b = 1;
    end
    

    // 发送模块
    wire        txb   ;
    wire        W_tx_ready;
    reg[63:0]   W_UART_DATA ;
    reg         W_UART_DATA_VLD ;

    UART_TX_DATA  inst_tx_data(
    .I_clk_10M      (clk_10mhz),
    .I_rst_n        (rst_b),
    .txb            (txb),
    .I_data         (W_UART_DATA),
    .I_data_valid   (W_UART_DATA_VLD),
    .O_tx_ready     (W_tx_ready)
    );
    // BUFFER
    // 发送的BUFFER:复制来自TC_TOP
    wire [16:0]	 Dstarb_p		;
    wire [16:0]	 Dstarb_n		;
    genvar i;
    generate
        for(i=0;i<17;i=i+1)
        begin:OBUF_loop2
            OBUFDS #(
                .IOSTANDARD("DEFAULT")
                ) OBUF_dstarb_inst(
                .O(Dstarb_p[i]),
                .OB(Dstarb_n[i]),
                .I(txb)//TXB_AWG1
            );
        end
    endgenerate
    // 接收的BUFFER:复制来自AWG_TOP
    wire	W_UART_RXB	;
    IBUFDS IBUFDS_DATA (
    .O(W_UART_RXB), // 1-bit output: Buffer output
    .I(Dstarb_p[0]), // 1-bit input: Diff_p buffer input (connect directly to top-level port)
    .IB(Dstarb_n[0]) // 1-bit input: Diff_n buffer input (connect directly to top-level port)
    );

    wire WEA_RAM1;
    wire WEA_RAM2;
    wire WEA_RAM3;
    wire WEA_RAM4;

    wire [10:0] WRITE_ADDR_RAM1;
    wire [10:0] WRITE_ADDR_RAM2;
    wire [10:0] WRITE_ADDR_RAM3;
    wire [10:0] WRITE_ADDR_RAM4;

    wire [23:0] WRITE_DELAY_RAM1;
    wire [23:0] WRITE_DELAY_RAM2;
    wire [23:0] WRITE_DELAY_RAM3;
    wire [23:0] WRITE_DELAY_RAM4;

    // 接收模块
    reg [4:0] GA ;
    UART_RX_DATA inst_uart_rx_data(
	.I_clk_10M(clk_10mhz)	,
	.I_rst_n(rst_b)	,
	.rxb(W_UART_RXB)	,
	.GA(GA),
	.O_WEA_RAM1(WEA_RAM1),
	.O_WEA_RAM2(WEA_RAM2),
	.O_WEA_RAM3(WEA_RAM3),
	.O_WEA_RAM4(WEA_RAM4),
	.O_WRITE_ADDR_RAM1(WRITE_ADDR_RAM1),
	.O_WRITE_ADDR_RAM2(WRITE_ADDR_RAM2),
	.O_WRITE_ADDR_RAM3(WRITE_ADDR_RAM3),
	.O_WRITE_ADDR_RAM4(WRITE_ADDR_RAM4),
	.O_WRITE_DELAY_RAM1(WRITE_DELAY_RAM1),
	.O_WRITE_DELAY_RAM2(WRITE_DELAY_RAM2),
	.O_WRITE_DELAY_RAM3(WRITE_DELAY_RAM3),
	.O_WRITE_DELAY_RAM4(WRITE_DELAY_RAM4)
    );

    // Delay RAM
    reg [10:0]	W_dac1_tx_id    ;
    reg [10:0]	W_dac2_tx_id    ;
    reg [10:0]	W_dac3_tx_id    ;
    reg [10:0]	W_dac4_tx_id    ;
    reg [23:0]  W_dac1_tx_delay ;
    reg [23:0]  W_dac2_tx_delay ;
    reg [23:0]  W_dac3_tx_delay ;
    reg [23:0]  W_dac4_tx_delay ;

    Delay_RAM inst_delay_ram(   
	.I_UART_CLK(clk_10mhz)			,
	.I_DELY_CLK(clk_250mhz)  			,
	.I_Rst_n(rst_b),

	.I_WEA_RAM1(WEA_RAM1)  				,
	.I_WEA_RAM2(WEA_RAM2)  				,
	.I_WEA_RAM3(WEA_RAM3)  				,
	.I_WEA_RAM4(WEA_RAM4)  				,
	.I_WRITE_ADDR_RAM1(WRITE_ADDR_RAM1) ,
	.I_WRITE_ADDR_RAM2(WRITE_ADDR_RAM2) ,
	.I_WRITE_ADDR_RAM3(WRITE_ADDR_RAM3) ,
	.I_WRITE_ADDR_RAM4(WRITE_ADDR_RAM4) ,
	.I_WRITE_DELAY_RAM1(WRITE_DELAY_RAM1),
	.I_WRITE_DELAY_RAM2(WRITE_DELAY_RAM2),
	.I_WRITE_DELAY_RAM3(WRITE_DELAY_RAM3),
	.I_WRITE_DELAY_RAM4(WRITE_DELAY_RAM4),

	.I_READ_ADDR_RAM1(W_dac1_tx_id) 	,
	.I_READ_ADDR_RAM2(W_dac2_tx_id) 	,
	.I_READ_ADDR_RAM3(W_dac3_tx_id) 	,
	.I_READ_ADDR_RAM4(W_dac4_tx_id) 	,
	.O_DAC1_DELAY(W_dac1_tx_delay)		,
	.O_DAC2_DELAY(W_dac2_tx_delay)		,
	.O_DAC3_DELAY(W_dac3_tx_delay)		,
	.O_DAC4_DELAY(W_dac4_tx_delay)	
    );

        // TODO: 输入相应的W_UART_DATA和W_UART_DATA_VLD信号变化
    initial
    begin
        // 在这里面加具体的信号变化
        GA = 4'd16;
        W_UART_DATA_VLD = 0;
        W_UART_DATA = 64'b0;
        #300
        W_UART_DATA_VLD = 1;
        W_UART_DATA = 64'h02002000_e_1_00000a;
        #200
        W_UART_DATA_VLD = 0;
        
        #300
        W_UART_DATA_VLD = 1;
        W_UART_DATA = 64'h02002000_e_2_000014;
        #200
        W_UART_DATA_VLD = 0;
        
        #300
        W_UART_DATA_VLD = 1;
        W_UART_DATA = 64'h02002000_e_3_00001e;
        #200
        W_UART_DATA_VLD = 0;
        
        #300
        W_UART_DATA_VLD = 1;
        W_UART_DATA = 64'h02002000_e_4_000028;
        #200
        W_UART_DATA_VLD = 0;
    end

  
endmodule