
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
    
    // 这是时钟区域：可以生成多个时钟
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
        // 在这里面加具体的信号变化
    end



    // 发送模块
    UART_TX_DATA  inst_tx_data(
    .I_clk_10M      (W1_Clk_10mhz),
    .I_rst_n        (rst_b),
    .txb            (txb),
    .I_data         (W_UART_DATA),
    .I_data_valid   (W_UART_DATA_VLD),
    .O_tx_ready     (W_tx_ready)
    );
    // BUFFER
    // 发送的BUFFER:复制来自TC_TOP
    genvar i;
    generate
        for(i=0;i<17;i=i+1)
        begin:OBUF_loop2
            OBUFDS #(
                .IOSTANDARD("DEFAULT")
                ) OBUF_dstarb_inst(
                .O(O_Dstarb_p[i]),
                .OB(O_Dstarb_n[i]),
                .I(txb)//TXB_AWG1
            );
        end
    endgenerate
    // 接收的BUFFER:复制来自AWG_TOP
    IBUFDS IBUFDS_DATA (
    .O(W_UART_RXB), // 1-bit output: Buffer output
    .I(I_PXIE_Dstarb_p), // 1-bit input: Diff_p buffer input (connect directly to top-level port)
    .IB(I_PXIE_Dstarb_n) // 1-bit input: Diff_n buffer input (connect directly to top-level port)
    );


    // 接收模块
    UART_RX_DATA inst_uart_rx_data(
	.I_clk_10M(W_clk_10mhz)	,
	.I_rst_n(W_rst2_n && W_Logic2_Rst_n)	,
	.rxb(W_UART_RXB)	,
	.GA(I_PXIE_GA),
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
    Delay_RAM inst_delay_ram(
	.I_UART_CLK(W_clk_10mhz)			,
	.I_DELY_CLK(W_clk_250mhz)  			,
	.I_Rst_n(W_rst2_n && W_Logic2_Rst_n),

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

  
endmodule