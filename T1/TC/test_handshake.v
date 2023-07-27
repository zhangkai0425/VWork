
`timescale 1ns/100ps
/*
    check FIFO addr
*/

module tb();
    // reg clk;
    reg rst_b;
    
    // 这是时钟区域：可以生成多个时钟
    reg clk_10mhz;
    reg clk_50mhz;

    initial begin
      clk_10mhz = 0;
      // 10 MHz clock
      forever #50 clk_10mhz = ~clk_10mhz;
    end
    
    initial begin
      clk_50mhz = 0;
      // 250 MHz clock
      forever #10 clk_50mhz = ~clk_50mhz;
    end
    
    initial
    begin
        rst_b = 1;
        #100;
        rst_b = 0;
        #100;
        rst_b = 1;
    end
wire [127: 0] isa_addr;
wire R_wr_en;
wire rd_en;
wire [31:0] isa_addr_o;
wire isa_fifo_addr_empty;
wire isa_fifo_addr_full;
wire isa_valid_addr_o;
wire isa_tx_ready;
reg uart_busy;
reg uart_busy1;
reg uart_busy2;

assign uart_busy = isa_valid_addr_o && (isa_addr_o[31:12]==20'h02001||isa_addr_o[31:12]==20'h02002);

assign rd_en = ~isa_fifo_addr_empty && isa_tx_ready && ~uart_busy && ~uart_busy1 && ~uart_busy2 ;
    

always @ (posedge clk_10mhz or negedge rst_b)
begin
  if(~rst_b)
  begin
    uart_busy1 <= 1'b0;
    uart_busy2 <= 1'b0;
  end
  else begin
    uart_busy1 <= uart_busy2;
    uart_busy2 <= uart_busy;
  end
end

isa_capturer_fifo_128 isa_capturer_fifo_addr(
  .rst 		(~rst_b),        			  // input wire rst
  .wr_clk (clk_50mhz),  					    // input wire wr_clk
  .rd_clk (clk_10mhz),  					    // input wire rd_clk
  .din 		(isa_addr),             // input wire  [127 : 0] din
  .wr_en 	(R_wr_en),    				  // input wire wr_en
  .rd_en 	(rd_en),    				    // input wire rd_en
  .dout 	(isa_addr_o),      	    // output wire [31 : 0]  dout
  .full 	(isa_fifo_addr_full),      	// output wire full
  .empty 	(isa_fifo_addr_empty),    		// output wire empty
  .valid 	(isa_valid_addr_o)     			// output wire valid
);
  
    initial
    begin
        R_wr_en = 0;
        isa_tx_ready = 0;
        #1000
        isa_addr = 128'h02001_000_02002_000_02003_000_02001_000;
        R_wr_en = 1;
        #20
        R_wr_en = 0;
        #200
        isa_tx_ready = 1;
        forever #100 isa_tx_ready = ~isa_tx_ready;
    end

endmodule