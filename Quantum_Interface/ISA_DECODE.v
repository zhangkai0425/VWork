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
    AXI_pad_wdata,
    AXI_pad_waddr,
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
input [15:0] isa_ram_en;
input [127:0]AXI_pad_wdata;
input [39:0] AXI_pad_waddr;
output reg[63:0]	O_tx_data;
output reg O_tx_en;
output reg	        O_Trig;
output reg [31:0]	O_Trig_Num;
output reg [31:0]	O_Trig_Step;
output reg [31:0]   O_Wait;

wire [63:0]	W_AXI_Data;
wire 	    W_AXI_Mask;
wire        W_AXI_Data_Valid;
wire [31:0] W_AXI_data;
wire [31:0] W_AXI_addr;
wire [3:0]  W_AXI_mask;
// Judge:0x0000-0xffff

// wstrb
wire [127:0] AXI_pad_Wdata; 
wire [127:0] AXI_pad_Waddr;
assign AXI_pad_Wdata = { AXI_pad_wdata[127:0]}; // 128 bit
assign AXI_pad_Waddr = { AXI_pad_waddr[31:0]+32'hc,AXI_pad_waddr[31:0]+32'h8,
        				 AXI_pad_waddr[31:0]+32'h4,AXI_pad_waddr[31:0]+32'h0 }; // 128 bit

// fifo input :
// DATA:{ AXI_pad_Wdata[127:0]} // 128 bit
// ADDR:{ AXI_pad_Waddr[31:0]+1'hc,AXI_pad_Waddr[31:0]+1'h8,
//        AXI_pad_Waddr[31:0]+1'h4,AXI_pad_Waddr[31:0]+1'h0 } // 128 bit

isa_capturer isa_capturer_ints(
	.clk_wr 		(I_wr_clk),
	.rstn 			(I_rst_n),
	.isa_ram_en 	(isa_ram_en),
	.isa_data 		(AXI_pad_Wdata[127:0]), // 128 -> mask -> 32
	.isa_addr 		(AXI_pad_Waddr[127:0]), // 128 -> mask -> 32
	.isa_en 		(wr_en),
	.isa_tx_ready   (I_tx_ready),
	.clk_rd 		(I_rd_clk),
	.isa_addr_o 	(W_AXI_addr),
	.isa_data_o 	(W_AXI_data),
	.isa_mask_o     (W_AXI_mask),
	.isa_valid_o 	(W_AXI_Data_Valid)
	);
// We use the 32 bit data form before,so that we don't need to change
// too much code to adapt the new data form.
assign W_AXI_Data = {W_AXI_addr,W_AXI_data};
assign W_AXI_Mask = (&W_AXI_mask[3:0]);

parameter [31:0] ADDR_FMR = 32'h40003000;
reg [31:0]  ADDR_OFFSET_r;
wire [31:0] ADDR_ACQ_w;

ila_isa_decode x_isa_decode(
    .clk(I_rd_clk),
    .probe0(O_Trig),
    .probe1(O_Trig_Num),
    .probe2(O_Trig_Step)
);

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
	// We have to change the address to adapt the new hardware architecture
	begin
		if (W_AXI_Data_Valid && W_AXI_Mask) // add mask limitation
		begin
		case (W_AXI_Data[63:32])
			// TRIG:executing in AQTC
			32'h0200_1000: begin
					O_Trig		<= 1'b1;
					O_Trig_Num	<= W_AXI_Data[31:0];
					O_Wait 		<= 32'h0;
					O_tx_data   <= W_AXI_Data;
					O_tx_en     <= 1'b1	;
				end
			32'h0200_1004: begin
			     O_Trig_Step	<= W_AXI_Data[31:0];
			end
			// QWAIT
			32'h0200_1ffc: begin
                O_Wait	    <= 32'h0;
            end
            32'h0200_2000: begin
                O_Wait	    <= O_Wait + W_AXI_Data[31:0];
            end
  			// FMR:TODO:To be finished in the future
 			// W_AXI_Data[63:32]==32'h0200_2fff||W_AXI_Data[63:32]==32'h0200_3000||W_AXI_Data[63:32]==32'h0200_4000
			32'h0200_2fff: begin
			end
			32'h0200_3000: begin
			end
			32'h0200_4000: begin
			end
//			// Pulse transmission
//			// W_AXI_Data[63:32]>=32'h0200_23f8&&W_AXI_Data[63:32]<=32'h0200_2800
//			32'h0200_2???: begin
//                O_Wait	    <= 32'h0;
//            end
            
//			// Play
//			// W_AXI_Data[63:32]>=32'h0200_8000&&W_AXI_Data[63:32]<=32'h0205_2000
//			32'h0200?_???: begin
//				O_tx_data   <= W_AXI_Data;
//				O_tx_en     <= 1'b1	;
//			end

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
