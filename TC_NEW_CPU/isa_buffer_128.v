`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2023/3/27 21:00:00
// Design Name:
// Module Name: isa_buffer_128
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

// Remember:For cross region clock processing only
module isa_buffer_128(
	input 			clk_i,
	input  [127:0] 	isa_data_i,
	input 			isa_wren_i,
	input  [31:0]	isa_addr_i,

	input 			clk_cpu,
	input 			rstn,
	output [127:0] 	isa_data_o,
	output 			isa_wren_o,
	output [15:0] 	isa_addr_o
    );

wire 		fifo_isa_full;
wire 		fifo_isa_empty;
wire [127:0]fifo_isa_data;
reg  		fifo_isa_rden;
wire 		fifo_addr_full;
wire 		fifo_addr_empty;
wire [15:0] fifo_addr_data;
reg  		fifo_addr_rden;

fifo_isa fifo_isa_inst  (
    .wr_clk (clk_i),					// IN STD_LOGIC
    .rd_clk (clk_cpu),					// IN STD_LOGIC
    .din 	(isa_data_i),				// IN STD_LOGIC_VECTOR(127 DOWNTO 0)
    .wr_en 	(isa_wren_i),				// IN STD_LOGIC
    .rd_en 	(fifo_isa_rden),			// IN STD_LOGIC
    .dout 	(fifo_isa_data),			// OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    .full 	(fifo_isa_full),			// OUT STD_LOGIC
    .empty 	(fifo_isa_empty)			// OUT STD_LOGIC
  );

fifo_addr fifo_addr_inst  (
    .wr_clk (clk_i),					// IN STD_LOGIC
    .rd_clk (clk_cpu),					// IN STD_LOGIC
    .din 	(isa_addr_i[15:0]),			    // IN STD_LOGIC_VECTOR(31 DOWNTO 0)
    .wr_en 	(isa_wren_i),				// IN STD_LOGIC
    .rd_en 	(fifo_addr_rden),			// IN STD_LOGIC
    .dout 	(fifo_addr_data),			// OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    .full 	(fifo_addr_full),			// OUT STD_LOGIC
    .empty 	(fifo_addr_empty)			// OUT STD_LOGIC
  );

reg [127:0] isa_data_r;
reg [15:0] 	isa_addr_r;
reg 		isa_wren_r;

reg [3:0] 	isa_buffer_state;
reg [3:0]   state_next;
parameter [3:0]	st_idle		= 4'b0000;
parameter [3:0]	st_wait		= 4'b0001;
parameter [3:0]	st_data 	= 4'b0011;


always @ (posedge clk_cpu or negedge rstn)
begin
	if (~rstn)
	begin
		isa_buffer_state <= st_idle;
	end else begin
		isa_buffer_state <= state_next;
	end
end

always @ (*)
begin
	case(isa_buffer_state)
		st_idle:
		begin
			state_next = st_wait;
		end
		st_wait:
		begin
			if (~rstn)
			begin
				state_next = st_idle;
			end else
			if (fifo_isa_empty || fifo_addr_empty)
			begin
				state_next = st_wait;
			end else begin
				state_next = st_data;
			end
		end
		st_data:
		begin
			state_next = st_wait;
		end
		default: state_next = st_idle;
	endcase
end

always @ (posedge clk_cpu or negedge rstn)
begin
	if (~rstn)
	begin
		isa_data_r <= 128'h0;
		isa_addr_r <= 16'h0;
		isa_wren_r <= 1'b0;
		fifo_addr_rden <= 1'b0;
		fifo_isa_rden <= 1'b0;
	end else begin
		fifo_addr_rden <= 1'b0;
		fifo_isa_rden <= 1'b0;
		case(isa_buffer_state)
			st_idle:
			begin
				isa_data_r <= 128'h0;
				isa_addr_r <= 16'h0;
				isa_wren_r <= 1'b0;
			end
			st_wait:
			begin
				isa_data_r <= 128'h0;
				isa_addr_r <= 16'h0;
				isa_wren_r <= 1'b0;
				if (state_next == st_data)
				begin
					fifo_isa_rden <= 1'b1;
				end else begin
					fifo_isa_rden <= 1'b0;
				end
			end
			st_data:
			begin
				fifo_isa_rden <= 1'b1;
				isa_data_r <= fifo_isa_data;
				isa_addr_r <= fifo_addr_data;
				isa_wren_r <= 1'b1;
			end
		endcase

	end
end
assign isa_data_o = isa_data_r;
assign isa_addr_o = isa_addr_r;
assign isa_wren_o = isa_wren_r;
endmodule
