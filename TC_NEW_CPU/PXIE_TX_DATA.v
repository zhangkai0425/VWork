`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2022/07/13 14:35:23
// Design Name:
// Module Name: PXIE_TX_DATA
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


module PXIE_TX_DATA(
	input 	rstn,
	input 	[15:0] 	c2h_addr,
	input 	[15:0] 	c2h_len,
	input 			c2h_en,

    input 	c2h_clk,
    output 	[63:0] 	c2h_tdata,
    output 	c2h_tvalid,
    output 	c2h_tlast,
    input 	c2h_tready,
    output 	[7:0] 	c2h_tkeep,

    //system ram
    input 	sysRAM_clk,
    input 	[31:0] 	sysRAM_data,
    output 	reg sysRAM_vld,
    output  reg	[15:0] 	sysRAM_addr

    );

wire c2h_en_sig;
pulse_syn_fast2s pulse_syn_fast2s_inst(
    .rstn           (rstn),
    .clk_fast       (c2h_clk),
    .pulse_fast     (c2h_en),
    .clk_slow       (sysRAM_clk),
    .pulse_slow     (c2h_en_sig)
	);

reg [15:0]  sys_cnt;
reg 		fifo_wren;
reg 		fifo_wren_r;
reg 		fifo_done;
reg 		fifo_done_r;
reg 		fifo_done_rr;
reg [2:0] state_sys;
parameter st_sys_idle 		= 3'b000;
parameter st_sys_read		= 3'b001;
parameter st_sys_write 		= 3'b010;
parameter st_sys_done 		= 3'b100;
always @(posedge sysRAM_clk or negedge rstn) begin
	if (~rstn) begin
		// reset
		fifo_wren 	<= 1'b0;
		fifo_wren_r <= 1'b0;
		sys_cnt 	<= 10'h0;
		sysRAM_vld  <= 1'b0;
		sysRAM_addr <= 16'h0;
		fifo_done 	<= 1'b0;
		state_sys 	<= st_sys_idle;
	end
	else begin
		fifo_wren_r <= fifo_wren;
		case (state_sys)
		st_sys_idle:begin
			fifo_done 	<= 1'b0;
			fifo_wren 	<= 1'b0;
			sys_cnt 	<= 10'h0;
			sysRAM_vld  <= 1'b0;
			sysRAM_addr <= 16'h0;
			if (c2h_en_sig) begin
				sysRAM_vld	<= 1'b1;
				sysRAM_addr <= c2h_addr;
				state_sys <= st_sys_read;
			end else begin
				state_sys <= st_sys_idle;
			end

		end
		st_sys_read:begin
			fifo_wren 	<= 1'b0;
			sys_cnt 	<= sys_cnt + 1'b1;
			sysRAM_vld  <= 1'b1;
			sysRAM_addr <= sysRAM_addr;
			state_sys	<= st_sys_write;
		end
		//2 clock delay fifo wren 打一拍
		st_sys_write:begin
			//sys_cnt 	<= sys_cnt + 1'b1;
			fifo_wren 	<= 1'b1;
			sysRAM_addr <= sysRAM_addr + 1'b1;
			if (sys_cnt == c2h_len) begin
				state_sys	<= st_sys_done;
			end else begin
				state_sys 	<= st_sys_read; //st_sys_read
			end
		end
		st_sys_done:begin
			fifo_wren 	<= 1'b0;
			sysRAM_vld  <= 1'b0;
			sysRAM_addr <= 16'h0;
			fifo_done 	<= 1'b1;
			state_sys 	<= st_sys_idle;
		end
		default:begin
			fifo_wren 	<= 1'b0;
			sysRAM_vld  <= 1'b0;
			sysRAM_addr <= 16'h0;
			state_sys 	<= st_sys_idle;
		end
		endcase
	end
end

always@(posedge c2h_clk or negedge rstn) begin
	if (~rstn) begin
		fifo_done_rr <= 1'b0;
		fifo_done_r  <= 1'b0;
	end else begin
		fifo_done_r  <= fifo_done_rr;
		fifo_done_rr <= fifo_done;
	end
end

reg [63:0] 		c2h_tdata_r;
reg 			c2h_tvalid_r;
reg 			c2h_tlast_r;
reg [7:0] 		c2h_tkeep_r;

wire 			fifo_rden;
reg 			fifo_rden_r;
reg [23:0]		fifo_cnt;

wire [63:0]		fifo_dout_sig;
wire 			fifo_empty_sig;
wire			fifo_full_sig;

fifo_generator_0 fifo_generator_0_inst(
    .wr_clk 	(sysRAM_clk),
    .rd_clk 	(c2h_clk),
    .rst 		(!rstn),
    .din 		(sysRAM_data),
    .wr_en 		(fifo_wren_r),
    .rd_en 		(fifo_rden),
    .dout 		(fifo_dout_sig),
    .full 		(fifo_full_sig),
    .empty 		(fifo_empty_sig)
	);

reg [8:0] state;
parameter st_idle 		= 9'b0_0000_0000;
parameter st_ready		= 9'b0_0000_0001;
parameter st_rdfifo 	= 9'b0_0000_0010;
parameter st_rdwait 	= 9'b0_0000_0100;
parameter st_rdwait1 	= 9'b0_0000_1000;
parameter st_rdlast 	= 9'b0_0001_0000;
parameter st_done 		= 9'b0_0010_0000;

always @(posedge c2h_clk or negedge rstn) begin
	if (~rstn) begin
		// reset
		c2h_tdata_r 	<= 64'h0;
		c2h_tvalid_r	<= 1'b0;
		c2h_tlast_r 	<= 1'b0;
		c2h_tkeep_r 	<= 8'hff;
		fifo_rden_r 	<= 1'b0;
		fifo_cnt 		<= 24'h0;
		state 			<= st_idle;
	end
	else begin
		case (state)
		st_idle:begin
			fifo_cnt 		<= 24'h0;
			fifo_rden_r 	<= 1'b0;
			c2h_tdata_r 	<= 64'h0;
			c2h_tvalid_r	<= 1'b0;
			c2h_tlast_r 	<= 1'b0;
			c2h_tkeep_r 	<= 8'hff;
			if (fifo_done_r) //c2h_en
			state 			<= st_ready;
			else
			state 			<= st_idle;
		end
		st_ready:begin
				c2h_tlast_r <= 1'b0;
				// fifo_cnt 		<= 24'h0;
				if (c2h_tready && (!fifo_empty_sig)) begin
					fifo_rden_r 	<= 1'b1;
					c2h_tdata_r		<= fifo_dout_sig;
					c2h_tvalid_r	<= 1'b0;
					state 			<= st_rdfifo;
				end else begin
					fifo_rden_r 	<= 1'b0;
					c2h_tvalid_r	<= 1'b0;
					state 			<= st_ready;
				end

		end
		st_rdfifo:begin
			if (fifo_empty_sig) begin
				c2h_tdata_r		<= fifo_dout_sig;
				fifo_rden_r 	<= 1'b0;
				c2h_tvalid_r	<= 1'b0;
				state 			<= st_ready;
			end else begin
				if (fifo_cnt == c2h_len[15:1]-2'h1) begin
					fifo_cnt 		<= 24'd0;
					fifo_rden_r 	<= 1'b0;
					c2h_tdata_r		<= fifo_dout_sig;
					c2h_tvalid_r	<= 1'b1;
					c2h_tlast_r 	<= 1'b1;
					state 	 		<= st_rdlast;
				end else begin
					if (c2h_tready) begin
					c2h_tdata_r		<= fifo_dout_sig;
					c2h_tvalid_r	<= 1'b1;
					fifo_rden_r	 	<= 1'b1;
					fifo_cnt 		<= fifo_cnt + 1'b1;
					state 	 		<= st_rdfifo;
					end
					else begin
					fifo_rden_r 	<= 1'b0;
					c2h_tvalid_r 	<= 1'b1;
					state 	 		<= st_rdwait;
					end
				end
			end
		end
		st_rdwait:begin
			if (c2h_tready)
			begin
				state 			<= st_rdfifo;
				c2h_tdata_r		<= fifo_dout_sig;
				c2h_tvalid_r 	<= 1'b0;
				fifo_rden_r 	<= 1'b1;
			end
			else begin
				c2h_tvalid_r 	<= 1'b0;
				state 		 	<= st_rdwait1;
			end
		end
		st_rdwait1:begin
			if (c2h_tready)
			begin
				state 			<= st_rdfifo;
				c2h_tvalid_r 	<= 1'b1;
				fifo_rden_r 	<= 1'b1;
			end
			else begin
				c2h_tvalid_r 	<= 1'b0;
				state 		 	<= st_rdwait1;
			end
		end
		st_rdlast:begin
			c2h_tvalid_r	<= 1'b0;
			if (c2h_tready)
			begin
				state 			<= st_done;
				c2h_tdata_r 	<= fifo_dout_sig;
				fifo_rden_r 	<= 1'b0;
				fifo_cnt 		<= 24'd0;
				c2h_tvalid_r	<= 1'b0;
				c2h_tlast_r 	<= 1'b0;
				c2h_tkeep_r 	<= 8'hff;
			end
			else
				state 			<= st_rdlast;
		end
		st_done:begin
			c2h_tdata_r <= 64'h0;
			c2h_tvalid_r<= 1'b0;
			c2h_tlast_r <= 1'b0;
			c2h_tkeep_r <= 8'h00; //ffff
			fifo_rden_r <= 1'b0;
			state 		<= st_idle;
		end
		default: state <= st_idle;
		endcase
	end
end



assign c2h_tdata  = c2h_tdata_r;
assign c2h_tvalid = c2h_tvalid_r && c2h_tready;
assign c2h_tlast  = c2h_tlast_r;
assign c2h_tkeep  = c2h_tkeep_r;
assign fifo_rden  = fifo_rden_r && c2h_tready;



endmodule
