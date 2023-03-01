`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/08/09 11:19:08
// Design Name:
// Module Name: ISA_DECODE
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

module ISA_DECODE(
    I_wr_clk,
    I_rd_clk,
    I_rst_n,
    I_tx_ready,
    wr_en,
    isa_ram_en,
    AHB_pad_hwdata,
    AHB_pad_hwaddr,
    O_tx_data,
    O_tx_en,
    O_Trig,
    O_Trig_Num,
    O_Trig_Step,
    O_Wait
    );
input	    I_wr_clk;
input       I_rd_clk;
input 	    I_rst_n;
input       I_tx_ready;
input       wr_en;
input [3:0] isa_ram_en;
input [31:0]AHB_pad_hwdata;
input [31:0]AHB_pad_hwaddr;
output reg[63:0]	O_tx_data;
output reg O_tx_en;
output reg	        O_Trig;
output reg [31:0]	O_Trig_Num;
output reg [31:0]	O_Trig_Step;
output reg [31:0]   O_Wait;

wire [63:0]	W_AHB_Data;
wire        W_AHB_Data_Valid;
wire [31:0] W_AHB_data;
wire [31:0] W_AHB_addr;

isa_capturer isa_capturer_ints(
	.clk_wr 		(I_wr_clk),
	.rstn 			(I_rst_n),
	.isa_ram_en 	(isa_ram_en),
	.isa_data 		(AHB_pad_hwdata),
	.isa_addr 		(AHB_pad_hwaddr),
	.isa_en 		(wr_en),
	.isa_tx_ready   (I_tx_ready),
	.clk_rd 		(I_rd_clk),
	.isa_addr_o 	(W_AHB_addr),
	.isa_data_o 	(W_AHB_data),
	.isa_valid_o 	(W_AHB_Data_Valid)
	);
assign W_AHB_Data = {W_AHB_addr,W_AHB_data};

parameter [31:0] ADDR_FMR = 32'h40003000;
reg [31:0]  ADDR_OFFSET_r;
wire [31:0] ADDR_ACQ_w;
always @ (posedge I_rd_clk or negedge I_rst_n)
begin
	if(~I_rst_n)
	begin
		O_Trig	    <= 1'b0;
		O_Trig_Num	<= 32'd0;
		O_Trig_Step	<= 32'd0;
		O_tx_data   <= 64'd0;
		O_tx_en	    <= 1'b0;
		O_Wait      <= 32'h0;
		ADDR_OFFSET_r <= 32'h0;
	end
	else
	begin
		if (W_AHB_Data_Valid)
		begin
		casez (W_AHB_Data[63:32])
			// TRIG
		    // executing in AQTC
			32'h4000_1000: begin //cycle & trigger
			    O_Trig		<= 1'b1;
		        O_Trig_Num	<= W_AHB_Data[31:0];
		        O_Wait 		<= 32'h0;
		        O_tx_data   <= W_AHB_Data;
			    O_tx_en     <= 1'b1	;
			end
			32'h4000_1004: begin //interval
			    O_Trig_Step	<= W_AHB_Data[31:0];
			end
			32'h4000_1008: begin //bitmask
			    O_Trig_Num	<= W_AHB_Data[31:0];
			end
			// QWAIT
			32'h4000_1ffc: begin
			    O_Wait	    <= 32'h0;
			end
			32'h4000_2000: begin
			    O_Wait	    <= O_Wait + W_AHB_Data[31:0];
			end
			// FMR & offser
			// ADDR_FMR + [ADDR_OFFSET] + qubit_index * sizeof(int)
			32'h4000_2004: begin
		        ADDR_OFFSET_r <= W_AHB_Data[31:0];
			end
			32'h4000_4???: begin
			    O_tx_data   <= {W_AHB_Data[63:24],O_Wait[23:0]};
			    O_tx_en     <= 1'b1	;
			end
			default: begin
			    O_tx_en   	<= 1'b0;
			    O_tx_data 	<= O_tx_data;
			    O_Trig 		<= 1'b0;
			    O_Wait      <= O_Wait;
			    O_Trig_Num	<= O_Trig_Num;
			    O_Trig_Step	<= O_Trig_Step;
			    ADDR_OFFSET_r <= ADDR_OFFSET_r;
			end
		endcase
		end else begin
			O_tx_en   	<= 1'b0;
			O_tx_data 	<= O_tx_data;
			O_Trig 		<= 1'b0;
			O_Wait      <= O_Wait;
			O_Trig_Num	<= O_Trig_Num;
			O_Trig_Step	<= O_Trig_Step;
			ADDR_OFFSET_r <= ADDR_OFFSET_r;
		end
	end
end
assign ADDR_ACQ_w = ADDR_FMR + ADDR_OFFSET_r[31:0];

endmodule
