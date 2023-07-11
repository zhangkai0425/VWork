`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2022/01/22 15:19:35
// Design Name:
// Module Name: isa_capturer
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

// data:128->32
// addr:128->32
// mask:16 ->4
// if mask_o == 4'hf -> data/addr is valid

module isa_capturer(
input 			     clk_wr,
input 			     rstn,
input [15:0]     isa_ram_en,
input [127:0]	   isa_data,
input [127:0] 	 isa_addr,
input 			     isa_en,
input 			     isa_tx_ready,
input 			     clk_rd,
output [31:0] 	 isa_addr_o,
output [31:0] 	 isa_data_o,
output [3:0 ]    isa_mask_o,
output 			     isa_valid_o
);


wire isa_fifo_full;
wire isa_fifo_addr_full;
wire isa_fifo_data_full;
wire isa_fifo_mask_full;
wire isa_fifo_empty;
wire isa_fifo_addr_empty;
wire isa_fifo_data_empty;
wire isa_fifo_mask_empty;

wire isa_valid_addr_o;
wire isa_valid_data_o;
wire isa_valid_mask_o;

assign isa_valid_o = isa_valid_addr_o && isa_valid_data_o && isa_valid_mask_o;

wire [63:0] isa_fifo_dout;
wire isa_valid;
(*mark_debug="TRUE"*)wire rd_en;
wire uart_busy;

assign uart_busy = isa_valid_o && (isa_addr_o==32'h40001000||isa_addr_o[31:12]==20'h40004);

reg uart_busy1;
reg uart_busy2;

always @ (posedge clk_rd or negedge rstn)
begin
  if(~rstn)
  begin
    uart_busy1 <= 1'b0;
    uart_busy2 <= 1'b0;
  end
  else begin
    uart_busy1 <= uart_busy2;
    uart_busy2 <= uart_busy;
  end
end

//assign rd_en = ~isa_fifo_empty && isa_tx_ready && ~uart_busy && ~uart_busy1 && ~uart_busy2;
// debug
assign rd_en = ~isa_fifo_data_empty && ~isa_fifo_addr_empty &&~isa_fifo_mask_empty ;

// isa_capturer_fifo(
//   .rst 		(~rstn),        			  // input wire rst
//   .wr_clk (clk_wr),  					    // input wire wr_clk
//   .rd_clk (clk_rd),  					    // input wire rd_clk
//   .din 		({isa_addr,isa_data}),  // input wire [63 : 0] din
//   .wr_en 	(R_wr_en && (isa_ram_en==16'hf000 || isa_ram_en==16'h0f00 || isa_ram_en==16'h00f0 || isa_ram_en==16'h000f)),    				  // input wire wr_en
//   .rd_en 	(rd_en),    				    // input wire rd_en
//   .dout 	({isa_addr_o,isa_data_o}),      	// output wire [63 : 0] dout
//   .full 	(isa_fifo_full),      	// output wire full
//   .empty 	(isa_fifo_empty),    		// output wire empty
//   .valid 	(isa_valid_o)     			  // output wire valid
// 	);

isa_capturer_fifo_128 isa_capturer_fifo_addr(
  .rst 		(~rstn),        			  // input wire rst
  .wr_clk (clk_wr),  					    // input wire wr_clk
  .rd_clk (clk_rd),  					    // input wire rd_clk
  .din 		(isa_addr),             // input wire  [127 : 0] din
  .wr_en 	(R_wr_en),    				  // input wire wr_en
  .rd_en 	(rd_en),    				    // input wire rd_en
  .dout 	(isa_addr_o),      	    // output wire [31 : 0]  dout
  .full 	(isa_fifo_addr_full),      	// output wire full
  .empty 	(isa_fifo_addr_empty),    		// output wire empty
  .valid 	(isa_valid_addr_o)     			// output wire valid
	);

isa_capturer_fifo_128 isa_capturer_fifo_data(
  .rst 		(~rstn),        			  // input wire rst
  .wr_clk (clk_wr),  					    // input wire wr_clk
  .rd_clk (clk_rd),  					    // input wire rd_clk
  .din 		(isa_data),             // input wire  [127 : 0] din
  .wr_en 	(R_wr_en),    				  // input wire wr_en
  .rd_en 	(rd_en),    				    // input wire rd_en
  .dout 	(isa_data_o),      	    // output wire [31 : 0]  dout
  .full 	(isa_fifo_data_full),      	// output wire full
  .empty 	(isa_fifo_data_empty),    		// output wire empty
  .valid 	(isa_valid_data_o)     			// output wire valid
);

isa_capturer_fifo_16 isa_capturer_fifo_mask(
  .rst 		(~rstn),        			  // input wire rst
  .wr_clk (clk_wr),  					    // input wire wr_clk
  .rd_clk (clk_rd),  					    // input wire rd_clk
  .din 		(isa_ram_en),           // input wire  [15 : 0] din
  .wr_en 	(R_wr_en),    				  // input wire wr_en
  .rd_en 	(rd_en),    				         // input wire rd_en
  .dout 	(isa_mask_o),           // output wire [3 : 0]  dout
  .full 	(isa_fifo_mask_full),      	// output wire full
  .empty 	(isa_fifo_mask_empty),    		// output wire empty
  .valid 	(isa_valid_mask_o)     			// output wire valid
);
wire R_wr_en;
assign R_wr_en = isa_en;
// fix the bug here:do not use reg signal!!!
//always @ (posedge clk_wr or negedge rstn )
//begin
//	if(~rstn)
//	begin
//		R_wr_en	<=	1'b0;
//	end
//	else
//	begin
//    R_wr_en <= isa_en;
//	end
//end

endmodule