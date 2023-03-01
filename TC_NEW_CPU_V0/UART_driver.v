//////////////////////////////////////////////////////////////////////////////////////////////////////
//																									//
// File Name: 			UART_driver.v 																//
// Company:				ECRIEE(CETC38),  Communication Research Division							//
// Engineer:			GuHefang(Email:aaa6394@sina.com;OfficePhone:(86)551-5391738)				//
// Description:																						//
// Revision				1.0																			//
//																									//
// Copyright 2011, ECRIEE(CETC38), Communication Research Division									//
// All rights reserved.			 																	//
//																									//
//////////////////////////////////////////////////////////////////////////////////////////////////////


`timescale 1ns/10ps

module UART_driver(
	rst_n,			//asynchronous reset/low active
	clk_10M,		//clock (10MHz)
//	clk_divsor,		//round(10e6/baudrate) 	(symbol duration)
	
	rxb,			//receive data
	txb,			//transmit data
	
	rx_reg,			//receive data reg
	rx_ready,		//rx_reg available
	FE,				//frame error
	
	tx_ready,		//(=1)tx_reg idle
	tx_ena,			//rising edge start a transmit process
	tx_data			//transmit data input
	//optional port
	);



//=================== Port Declaration =================//	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
	input rst_n;
	input clk_10M;
//	input [11:0] clk_divsor;	
	
	input rxb;
	output reg txb;
	
	output reg [7:0] rx_reg;
	output reg rx_ready;		
	output reg FE;				
	
	output tx_ready;	
	input tx_ena;			
	input [7:0] tx_data;		
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
//=========================��rz=========================//	



//===================Parameter Definition===============//
	parameter edge_detection_delay = 4;			
	parameter frame_length = 8;				
	parameter silence_length = 5;	
	parameter clk_divsor = 2083;
//=========================��rz=========================//	




//######################### RXB ########################//
//================= Variable Declaration ===============//
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//	
	reg [11:0] clk_divsor_reg;
	reg [11:0] rx_symbol_cnt;
	reg [2:0] rx_bit_cnt;
	reg [edge_detection_delay-1:0] rxb_buf;
	reg [1:0] edge_detection_buf;
	reg [7:0] rx_reg_buf;
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//	
//=========================��rz=========================//	



//=================== Edge Detection ===================//
	wire falling_edge_rxb;
	wire byte_start;
	
	//==== buffer rxb data ====//
	always @(posedge clk_10M, negedge rst_n)
	    begin
		if (!rst_n) 
			rxb_buf <= 0;
		else 
			rxb_buf <= {rxb_buf[edge_detection_delay-2:0],rxb};		//MSB first
	    end
	
	//==== falling edge detection ====//
	assign falling_edge_rxb = rxb_buf[edge_detection_delay-1] & (~rxb_buf[0]);	//falling edge
	
	//==== double check ====//
	always @(posedge clk_10M, negedge rst_n)
	    begin
		if (!rst_n) 
			edge_detection_buf <= 0;
		else 
			edge_detection_buf <= {edge_detection_buf[0],falling_edge_rxb};	
		end
	
	assign byte_start = &edge_detection_buf;
//=========================��rz=========================//	



//================= RX Symbol Counter ==================//
	reg rx_symbol_cnt_clr;
	wire rx_symbol_cnt_full;
	wire rx_symbol_cnt_half_full;
	wire [11:0] half_symbol_duration;

	assign rx_symbol_cnt_full = (rx_symbol_cnt == clk_divsor_reg-1);
	assign rx_symbol_cnt_half_full = (rx_symbol_cnt == half_symbol_duration);

	always @(posedge clk_10M, negedge rst_n)
		begin
		if (!rst_n)
			rx_symbol_cnt <= 0;
		else
		  begin
			if (rx_symbol_cnt_clr)
				rx_symbol_cnt <= 0;
			else
			  begin
				if (rx_symbol_cnt_full)
					rx_symbol_cnt <= 0;
				else
					rx_symbol_cnt <= rx_symbol_cnt + 1'b1;
			  end
		  end
		end
//=========================��rz=========================//	



//================== RX Bit Counter ====================//
	reg rx_bit_cnt_clr;
	wire rx_bit_cnt_full;

	assign rx_bit_cnt_full = (rx_bit_cnt == frame_length-1);
//	assign rx_bit_cnt_full = (rx_bit_cnt == frame_length-2);
	
	always @(posedge clk_10M, negedge rst_n)
		begin
		if (!rst_n)
			rx_bit_cnt <= 0;
		else
		  begin
			if (rx_bit_cnt_clr)
				rx_bit_cnt <= 0;
			else
			  begin
				if (rx_symbol_cnt_full)
					rx_bit_cnt <= rx_bit_cnt + 1'b1;
			  end
		  end
		end
//=========================��rz=========================//	



//============= State Machine of RXB Part1 =============//
	//================//
	reg [2:0] RXB_state;
	
	localparam 	Rx_Initialization 	= 3'b000,
				Wait_Half_Symbol	= 3'b001,
				Wait_for_ByteStart	= 3'b011,
				Byte_Receiving		= 3'b111,
				Stop_Bit			= 3'b110;
	//================//
	assign half_symbol_duration = clk_divsor_reg >> 1;			

	always @(posedge clk_10M, negedge rst_n)
		begin
			if (!rst_n)
					RXB_state	<= Rx_Initialization;
			else
				case(RXB_state)
					Rx_Initialization: 
						RXB_state <= Wait_for_ByteStart;
					Wait_for_ByteStart:
						if (byte_start)
							RXB_state <= Wait_Half_Symbol;
					Wait_Half_Symbol:		
						if(rx_symbol_cnt_half_full)
							RXB_state <= Byte_Receiving;
					Byte_Receiving:
						if (rx_symbol_cnt_full && rx_bit_cnt_full)
							RXB_state <= Stop_Bit;
					Stop_Bit:
						if (rx_symbol_cnt_full)
							RXB_state <= Wait_for_ByteStart;
					default:
						RXB_state <= Rx_Initialization;
				endcase
		end	
//=========================��rz=========================//	



//============= State Machine of RXB Part2 =============//
	always @(posedge clk_10M, negedge rst_n)
		begin
			if (!rst_n)
				begin
					clk_divsor_reg <= 0;
					rx_symbol_cnt_clr <= 1'b1;
					rx_bit_cnt_clr <= 1'b1;
					rx_reg_buf <= 0;
					rx_reg <= 0;
					rx_ready <= 1'b0;
					FE <= 1'b0;
				end
			else
				case(RXB_state)
					Rx_Initialization: 
						begin
							clk_divsor_reg <= clk_divsor;
							rx_symbol_cnt_clr <= 1'b1;
							rx_bit_cnt_clr <= 1'b1;
							rx_reg_buf <= 0;
							rx_reg <= 0;
							rx_ready <= 1'b0;
							FE <= 1'b0;
						end
					Wait_for_ByteStart:
						begin
							rx_symbol_cnt_clr <= 1'b1;	
							rx_bit_cnt_clr <= 1'b1;
							rx_reg_buf <= 0;
							rx_reg <= rx_reg;
							rx_ready <= 1'b0;
							FE <= 1'b0;
						end
					Wait_Half_Symbol:
						begin
							if(rx_symbol_cnt_half_full)
								rx_symbol_cnt_clr <= 1'b1;
							else
								rx_symbol_cnt_clr <= 1'b0;	
							rx_bit_cnt_clr <= 1'b1;
							rx_reg_buf <= 0;
							rx_reg <= rx_reg;	
							rx_ready <= 1'b0;
							FE <= 1'b0;
						end
					Byte_Receiving:
						begin
							rx_symbol_cnt_clr <= 1'b0;
							rx_bit_cnt_clr <= 1'b0;
							if (rx_symbol_cnt_full)
								rx_reg_buf <= {rxb,rx_reg_buf[frame_length-1:1]};
							rx_reg <= rx_reg;	
							rx_ready <= 1'b0;	
							FE <= 1'b0;
						end
					Stop_Bit:
						begin
							rx_symbol_cnt_clr <= 1'b0;
							rx_bit_cnt_clr <= 1'b1;
							if (rx_symbol_cnt_full)
								if (rxb)
								begin
									rx_reg <= rx_reg_buf;
									rx_ready <= 1'b1;
									FE <= 1'b0;
								end
								else
								begin
									rx_reg <= 0;
									rx_ready <= 1'b0;
									FE <= 1'b1;
								end
						end
					default:
						begin
							clk_divsor_reg <= 0;
							rx_symbol_cnt_clr <= 1'b1;
							rx_bit_cnt_clr <= 1'b1;
							rx_reg_buf <= 0;
							rx_reg <= 0;
							rx_ready <= 1'b0;
							FE <= 1'b0;
						end
				endcase
		end	
//=========================��rz=========================//	
//######################################################//




//######################### TXB ########################//
//================= Variable Declaration ===============//
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//	
	reg [9:0] tx_reg;
	reg [11:0] tx_symbol_cnt;
	reg [3:0] tx_bit_cnt;
	reg tx_busy;
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//	
//=========================��rz=========================//	



//=================== Edge Detection ===================//
	reg tx_ena_buf;
	wire tx_start;
	
	always @(posedge clk_10M, negedge rst_n)
		begin
			if (!rst_n) 
				tx_ena_buf <= 1'b0;
			else 
				tx_ena_buf <= tx_ena;
		end
	
		assign tx_start = tx_ena & (~tx_ena_buf);		//rising edge
		assign tx_ready = ~(tx_start | tx_busy);
//=========================��rz=========================//	



//================= TX Symbol Counter ==================//
	reg tx_symbol_cnt_clr;
	wire tx_symbol_cnt_full;

	assign tx_symbol_cnt_full = (tx_symbol_cnt == clk_divsor_reg-1);

	always @(posedge clk_10M, negedge rst_n)
		begin
		if (!rst_n)
			tx_symbol_cnt <= 0;
		else
		  begin
			if (tx_symbol_cnt_clr)
				tx_symbol_cnt <= 0;
			else
			  begin
				if (tx_symbol_cnt_full)
					tx_symbol_cnt <= 0;
				else
					tx_symbol_cnt <= tx_symbol_cnt + 1'b1;
			  end
		  end
		end
//=========================��rz=========================//	



//================== TX Bit Counter ====================//
	reg tx_bit_cnt_clr;
	wire tx_bit_cnt_full;

	assign tx_bit_cnt_full = (tx_bit_cnt == 4'd9);

	always @(posedge clk_10M, negedge rst_n)
		begin
		if (!rst_n)
			tx_bit_cnt <= 0;
		else
		  begin
			if (tx_bit_cnt_clr)
				tx_bit_cnt <= 0;
			else
			  begin
				if (tx_symbol_cnt_full)
					tx_bit_cnt <= tx_bit_cnt + 1'b1;
			  end
		  end
		end
//=========================��rz=========================//	



//============= State Machine of TXB Part1 =============//
	//================//
	reg [1:0] TXB_state;
	
	localparam 	Tx_Initialization 	= 2'b00,
				Wait_for_tx_start	= 2'b01,
				Byte_Sending		= 2'b11,
				Silence				= 2'b10;
	//================//		

	always @(posedge clk_10M, negedge rst_n)
		begin
			if (!rst_n)
					TXB_state	<= Tx_Initialization;
			else
				case(TXB_state)
					Tx_Initialization: 
						TXB_state <= Wait_for_tx_start;
					Wait_for_tx_start:
						if (tx_start)
							TXB_state <= Byte_Sending;
					Byte_Sending:		
						if(tx_symbol_cnt_full && tx_bit_cnt_full)
							TXB_state <= Silence;
					Silence:
						if (tx_symbol_cnt == silence_length)
							TXB_state <= Wait_for_tx_start;
					default:
						TXB_state <= Tx_Initialization;
				endcase
		end	
//=========================��rz=========================//	



//============= State Machine of TXB Part2 =============//
	always @(posedge clk_10M, negedge rst_n)
		begin
			if (!rst_n)
				begin
					tx_symbol_cnt_clr <= 1'b1;
					tx_bit_cnt_clr <= 1'b1;
					tx_busy <= 1'b0;
					tx_reg <= 10'b0;
					txb <= 1'b1;
				end
			else
				case(TXB_state)
					Tx_Initialization: 
						begin
							tx_symbol_cnt_clr <= 1'b1;
							tx_bit_cnt_clr <= 1'b1;
							tx_busy <= 1'b0;
							tx_reg <= 10'b0;
							txb <= 1'b1;
						end
					Wait_for_tx_start:
						begin
							if (tx_start)
							  begin
							  	tx_busy <= 1'b1;
								tx_symbol_cnt_clr <= 1'b0;
								tx_bit_cnt_clr <= 1'b0;
								tx_reg <= {1'b1,tx_data,1'b0};
							  end
							else
							  begin
								tx_busy <= 1'b0;
								tx_symbol_cnt_clr <= 1'b1;
								tx_bit_cnt_clr <= 1'b1;
								tx_reg <= 10'b0;
							  end
								
							txb <= 1'b1;
						end
					Byte_Sending:
						begin
							tx_symbol_cnt_clr <= 1'b0;
							if (tx_symbol_cnt_full && tx_bit_cnt_full)
								tx_bit_cnt_clr <= 1'b1;
							else
								tx_bit_cnt_clr <= 1'b0;
							
							tx_busy <= 1'b1;
							
							if (tx_symbol_cnt == 0)
							  begin
								tx_reg <= {1'b0,tx_reg[9:1]};
								txb <= tx_reg[0];	// LSB first
							  end
						end	
					Silence:
						begin
							tx_symbol_cnt_clr <= 1'b0;
							tx_bit_cnt_clr <= 1'b0;
							tx_busy <= 1'b1;
							tx_reg <= 10'b0;
							txb <= 1'b1;
						end
					default:
						begin
							tx_symbol_cnt_clr <= 1'b1;
							tx_bit_cnt_clr <= 1'b1;
							tx_busy <= 1'b0;
							tx_reg <= 10'b0;
							txb <= 1'b1;
						end
				endcase
		end	
//=========================��rz=========================//	
endmodule
