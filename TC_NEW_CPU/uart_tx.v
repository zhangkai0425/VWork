//////////////////////////////////////////////////////////////////////////////////
//
// File Name: 			state_report.v
// Company:				ECRIEE(CETC38), Microwave Research Division, Signal Group
// Engineer:			Wujian.Lee
// Description:		    send bit and temper message to monitor by UART
//
// Copyright 2015, ECRIEE(CETC38), Microwave Research Division, Signal Group
// All rights reserved.
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module UART_Tx(
	input rst_n,
	input clk,
	input I_tx_ready,

	input	I_data_valid	,
	input[63:0]	I_data      ,

//	input	tx_dac2_trig	,
//	input	tx_dac3_trig	,
//	input	tx_dac4_trig	,



//	input [31:0] O_DAC1_DELAY,
//	input [31:0] O_DAC2_DELAY,
//	input [31:0] O_DAC3_DELAY,
//	input [31:0] O_DAC4_DELAY,

//	input [31:0] O_DAC1_LENGTH,
//	input [31:0] O_DAC2_LENGTH,
//	input [31:0] O_DAC3_LENGTH,
//	input [31:0] O_DAC4_LENGTH,

//	input [31:0] O_DAC1_ADDR,
//	input [31:0] O_DAC2_ADDR,
//	input [31:0] O_DAC3_ADDR,
//	input [31:0] O_DAC4_ADDR,


	output reg tx_en,
	output reg [7:0] tx_data,
	output reg O_tx_ready
);


//*************Parameter Definition begin************//
localparam  [7:0] WAIT_TARNS    = 8'd0; 		//Wait 500ms





localparam  [7:0] FH1_SEND 		= 8'd1; 		//Frame head1: EB
localparam  [7:0] FH2_SEND      	= 8'd2; 		//Frame head2: 9C

localparam  [7:0] FRC1_SEND     	= 8'd3; 		//Frame content1
localparam  [7:0] FRC2_SEND     	= 8'd4; 		//Frame content2
localparam  [7:0] FRC3_SEND     	= 8'd5; 		//Frame content3
localparam  [7:0] FRC4_SEND     	= 8'd6; 		//Frame content4
localparam  [7:0] FRC5_SEND     	= 8'd7; 		//Frame content5
localparam  [7:0] FRC6_SEND     	= 8'd8; 		//Frame content6
localparam  [7:0] FRC7_SEND     	= 8'd9; 		//Frame content7
localparam  [7:0] FRC8_SEND     	= 8'd10; 		//Frame content8
localparam  [7:0] FRC_END     	    = 8'd11;

/*
localparam  [7:0] DAC2_FH1_SEND 		= 8'd18; 		//Frame head1: FF
localparam  [7:0] DAC2_FH2_SEND      	= 8'd19; 		//Frame head2: FF
localparam  [7:0] DAC2_FH3_SEND 		= 8'd20; 		//Frame head3: AA
localparam  [7:0] DAC2_FH4_SEND      	= 8'd21; 		//Frame head4: BB
localparam  [7:0] DAC2_FH5_SEND      	= 8'd22; 		//Frame head5: 02
localparam  [7:0] DAC2_FRC1_SEND     	= 8'd23; 		//Frame content1
localparam  [7:0] DAC2_FRC2_SEND     	= 8'd24; 		//Frame content2
localparam  [7:0] DAC2_FRC3_SEND     	= 8'd25; 		//Frame content3
localparam  [7:0] DAC2_FRC4_SEND     	= 8'd26; 		//Frame content4
localparam  [7:0] DAC2_FRC5_SEND     	= 8'd27; 		//Frame content5
localparam  [7:0] DAC2_FRC6_SEND     	= 8'd28; 		//Frame content6
localparam  [7:0] DAC2_FRC7_SEND     	= 8'd29; 		//Frame content7
localparam  [7:0] DAC2_FRC8_SEND     	= 8'd30; 		//Frame content8
localparam  [7:0] DAC2_FRC9_SEND     	= 8'd31; 		//Frame content9
localparam  [7:0] DAC2_FRC10_SEND     	= 8'd32; 		//Frame content10
localparam  [7:0] DAC2_FRC11_SEND     	= 8'd33; 		//Frame content11
localparam  [7:0] DAC2_FRC12_SEND     	= 8'd34; 		//Frame content12



localparam  [7:0] DAC3_FH1_SEND 		= 8'd35; 		//Frame head1: FF
localparam  [7:0] DAC3_FH2_SEND      	= 8'd36; 		//Frame head2: FF
localparam  [7:0] DAC3_FH3_SEND 		= 8'd37; 		//Frame head3: AA
localparam  [7:0] DAC3_FH4_SEND      	= 8'd38; 		//Frame head4: BB
localparam  [7:0] DAC3_FH5_SEND      	= 8'd39; 		//Frame head5: 03
localparam  [7:0] DAC3_FRC1_SEND     	= 8'd40; 		//Frame content1
localparam  [7:0] DAC3_FRC2_SEND     	= 8'd41; 		//Frame content2
localparam  [7:0] DAC3_FRC3_SEND     	= 8'd42; 		//Frame content3
localparam  [7:0] DAC3_FRC4_SEND     	= 8'd43; 		//Frame content4
localparam  [7:0] DAC3_FRC5_SEND     	= 8'd44; 		//Frame content5
localparam  [7:0] DAC3_FRC6_SEND     	= 8'd45; 		//Frame content6
localparam  [7:0] DAC3_FRC7_SEND     	= 8'd46; 		//Frame content7
localparam  [7:0] DAC3_FRC8_SEND     	= 8'd47; 		//Frame content8
localparam  [7:0] DAC3_FRC9_SEND     	= 8'd48; 		//Frame content9
localparam  [7:0] DAC3_FRC10_SEND     	= 8'd49; 		//Frame content10
localparam  [7:0] DAC3_FRC11_SEND     	= 8'd50; 		//Frame content11
localparam  [7:0] DAC3_FRC12_SEND     	= 8'd51; 		//Frame content12


localparam  [7:0] DAC4_FH1_SEND 		= 8'd52; 		//Frame head1: FF
localparam  [7:0] DAC4_FH2_SEND      	= 8'd53; 		//Frame head2: FF
localparam  [7:0] DAC4_FH3_SEND 		= 8'd54; 		//Frame head3: AA
localparam  [7:0] DAC4_FH4_SEND      	= 8'd55; 		//Frame head4: BB
localparam  [7:0] DAC4_FH5_SEND      	= 8'd56; 		//Frame head5: 04
localparam  [7:0] DAC4_FRC1_SEND     	= 8'd57; 		//Frame content1
localparam  [7:0] DAC4_FRC2_SEND     	= 8'd58; 		//Frame content2
localparam  [7:0] DAC4_FRC3_SEND     	= 8'd59; 		//Frame content3
localparam  [7:0] DAC4_FRC4_SEND     	= 8'd60; 		//Frame content4
localparam  [7:0] DAC4_FRC5_SEND     	= 8'd61; 		//Frame content5
localparam  [7:0] DAC4_FRC6_SEND     	= 8'd62; 		//Frame content6
localparam  [7:0] DAC4_FRC7_SEND     	= 8'd63; 		//Frame content7
localparam  [7:0] DAC4_FRC8_SEND     	= 8'd64; 		//Frame content8
localparam  [7:0] DAC4_FRC9_SEND     	= 8'd65; 		//Frame content9
localparam  [7:0] DAC4_FRC10_SEND     	= 8'd66; 		//Frame content10
localparam  [7:0] DAC4_FRC11_SEND     	= 8'd67; 		//Frame content11
localparam  [7:0] DAC4_FRC12_SEND     	= 8'd68; 		//Frame content12

*/

//*************Parameter Definition end************//


//**********various definition begin************//
reg [23:0] cnt_500ms;
reg [7:0] fd_st_cuur;					//FSM:pointer
reg [7:0] fd_st_next;					//FSM:pointer
reg [7:0] CRC_value;
//**********various definition end************//



//**********************************************************************************//
//*******************************main processes start here**************************//
//**********************************************************************************//
//counter for 500ms
always @(posedge clk, negedge rst_n)
begin
	if(~rst_n)
		cnt_500ms <= 24'd0;
	else if(cnt_500ms == 24'h989680)
		cnt_500ms <= 24'd0;
	else
		cnt_500ms <= cnt_500ms + 1'd1;
end



//////////////////////////////////////////////////////////////////////////
////////////////////////// FSM(Three Parts) //////////////////////////////
//////////////////////////////////////////////////////////////////////////
//***************************FSM Part1 begin****************************//
always @(posedge clk, negedge rst_n)
begin
	if(~rst_n)
		fd_st_cuur <= WAIT_TARNS; //initialization
	else
		fd_st_cuur <= fd_st_next;
end
//***************************FSM Part1 end****************************//

//*************************FSM Part2 begin****************************//
always @(*)
begin
	if(~rst_n)
		fd_st_next = WAIT_TARNS;
	else
	begin
		case(fd_st_cuur)
		WAIT_TARNS:
		begin
			if(I_tx_ready)
			begin
				if(I_data_valid)
					fd_st_next = FH1_SEND;
				else
					fd_st_next = WAIT_TARNS;
			end
			else
				fd_st_next = WAIT_TARNS;
		end
		FH1_SEND:
		begin
			if(I_tx_ready)
				fd_st_next = FH2_SEND;
			else
				fd_st_next = FH1_SEND;
		end
		FH2_SEND:
		begin
			if(I_tx_ready)
				fd_st_next = FRC1_SEND;
			else
				fd_st_next = FH2_SEND;
		end
		FRC1_SEND:
		begin
			if(I_tx_ready)
				fd_st_next = FRC2_SEND;
			else
				fd_st_next = FRC1_SEND;
		end
		FRC2_SEND:
		begin
			if(I_tx_ready)
				fd_st_next = FRC3_SEND;
			else
				fd_st_next = FRC2_SEND;
		end
		FRC3_SEND:
		begin
			if(I_tx_ready)
				fd_st_next = FRC4_SEND;
			else
				fd_st_next = FRC3_SEND;
		end
		FRC4_SEND:
		begin
			if(I_tx_ready)
				fd_st_next = FRC5_SEND;
			else
				fd_st_next = FRC4_SEND;
		end
		FRC5_SEND:
		begin
			if(I_tx_ready)
				fd_st_next = FRC6_SEND;
			else
				fd_st_next = FRC5_SEND;
		end
		FRC6_SEND:
		begin
			if(I_tx_ready)
				fd_st_next = FRC7_SEND;
			else
				fd_st_next = FRC6_SEND;
		end
		FRC7_SEND:
		begin
			if(I_tx_ready)
				fd_st_next = FRC8_SEND;
			else
				fd_st_next = FRC7_SEND;
		end
		FRC8_SEND:
		begin
			if(I_tx_ready)
				fd_st_next = FRC_END;
			else
				fd_st_next = FRC8_SEND;
		end
		FRC_END:
		begin
			if(I_tx_ready)
				fd_st_next = WAIT_TARNS;
			else
				fd_st_next = FRC_END;
		end


		default:
		begin
			fd_st_next = WAIT_TARNS;
		end
		endcase
	end
end
//*************************FSM Part2 end****************************//

//*************************FSM Part3 begin****************************//
always @(posedge clk, negedge rst_n)
begin
	if(~rst_n)
	begin
		tx_en <= 1'd0;
		tx_data <= 8'd0;
		CRC_value <= 8'd0;
		O_tx_ready	<=	1'b0;
	end
	else
	begin
		case(fd_st_cuur)
		WAIT_TARNS:
		begin
			tx_en <= 1'd0;
			tx_data <= 8'h0;
			CRC_value <= 8'd0;
			O_tx_ready	<=	1'b1;
		end
		FH1_SEND:
		begin
			if(I_tx_ready)
			begin
				tx_en <= 1'd1;
				tx_data <= 8'heb;
				CRC_value <= 8'heb;
				O_tx_ready	<=	1'b0;
			end
			else
			begin
				tx_en <= 1'd0;
				tx_data <= 8'h0;
				CRC_value <= CRC_value;
				O_tx_ready	<=	1'b0;
			end
		end
		FH2_SEND:
		begin
			if(I_tx_ready)
			begin
				tx_en <= 1'd1;
				tx_data <= 8'h9c;
				CRC_value <= CRC_value + 8'h9c;
				O_tx_ready	<=	1'b0;
			end
			else
			begin
				tx_en <= 1'd0;
				tx_data <= 8'h0;
				CRC_value <= CRC_value;
				O_tx_ready	<=	1'b0;
			end
		end
		FRC1_SEND:
		begin
			if(I_tx_ready)
			begin
				tx_en <= 1'd1;
				tx_data <= I_data[7:0];
				CRC_value <= CRC_value + I_data[7:0];
				O_tx_ready	<=	1'b0;
			end
			else
			begin
				tx_en <= 1'd0;
				tx_data <= 8'h0;
				CRC_value <= CRC_value;
				O_tx_ready	<=	1'b0;
			end
		end
		FRC2_SEND:
		begin
			if(I_tx_ready)
			begin
				tx_en <= 1'd1;
				tx_data <= I_data[15:8];
				CRC_value <= CRC_value + I_data[15:8];
				O_tx_ready	<=	1'b0;
			end
			else
			begin
				tx_en <= 1'd0;
				tx_data <= 8'h0;
				CRC_value <= CRC_value;
				O_tx_ready	<=	1'b0;
			end
		end
		FRC3_SEND:
		begin
			if(I_tx_ready)
			begin
				tx_en <= 1'd1;
				tx_data <= I_data[23:16];
				CRC_value <= CRC_value + I_data[23:16];
				O_tx_ready	<=	1'b0;
			end
			else
			begin
				tx_en <= 1'd0;
				tx_data <= 8'h0;
				CRC_value <= CRC_value;
				O_tx_ready	<=	1'b0;
			end
		end
		FRC4_SEND:
		begin
			if(I_tx_ready)
			begin
				tx_en <= 1'd1;
				tx_data <= I_data[31:24];
				CRC_value <= CRC_value + I_data[31:24];
				O_tx_ready	<=	1'b0;
			end
			else
			begin
				tx_en <= 1'd0;
				tx_data <= 8'h0;
				CRC_value <= CRC_value;
				O_tx_ready	<=	1'b0;
			end
		end
		FRC5_SEND:
		begin
			if(I_tx_ready)
			begin
				tx_en <= 1'd1;
				tx_data <= I_data[39:32];
				CRC_value <= CRC_value + I_data[39:32];
				O_tx_ready	<=	1'b0;
			end
			else
			begin
				tx_en <= 1'd0;
				tx_data <= 8'h0;
				CRC_value <= CRC_value;
				O_tx_ready	<=	1'b0;
			end
		end
		FRC6_SEND:
		begin
			if(I_tx_ready)
			begin
				tx_en <= 1'd1;
				tx_data <= I_data[47:40];
				CRC_value <= CRC_value + I_data[47:40];
				O_tx_ready	<=	1'b0;
			end
			else
			begin
				tx_en <= 1'd0;
				tx_data <= 8'h0;
				CRC_value <= CRC_value;
				O_tx_ready	<=	1'b0;
			end
		end
		FRC7_SEND:
		begin
			if(I_tx_ready)
			begin
				tx_en <= 1'd1;
				tx_data <= I_data[55:48];
				CRC_value <= CRC_value + I_data[55:48];
				O_tx_ready	<=	1'b0;
			end
			else
			begin
				tx_en <= 1'd0;
				tx_data <= 8'h0;
				CRC_value <= CRC_value;
				O_tx_ready	<=	1'b0;
			end
		end
		FRC8_SEND:
		begin
			if(I_tx_ready)
			begin
				tx_en <= 1'd1;
				tx_data <= I_data[63:56];
				CRC_value <= CRC_value + I_data[63:56];
				O_tx_ready	<=	1'b0;
			end
			else
			begin
				tx_en <= 1'd0;
				tx_data <= 8'h0;
				CRC_value <= CRC_value;
				O_tx_ready	<=	1'b0;
			end
		end
		FRC_END:
		begin
			tx_en <= 1'b0;
			tx_data <= 8'h0;
			CRC_value <= CRC_value;
			O_tx_ready <= 1'b0;
		end

		default:
		begin
			tx_en <= 1'd0;
			tx_data <= 8'h0;
			CRC_value <= 8'd0;
		end
		endcase
	end
end
//*************************FSM Part3 end****************************//

/*
ila_tx ila_tx1 (
	.clk(clk), // input wire clk
	.probe0(fd_st_next), // input wire [7:0]  probe0
	.probe1(tx_en), // input wire [0:0]  probe1
	.probe2(tx_dac1_trig), // input wire [0:0]  probe2
	.probe3(tx_ready) // input wire [0:0]  probe3
);
*/



endmodule

