//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2022/02/28 13:44:45
// Design Name:
// Module Name: UART_Rx
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

`timescale 1ns/1ns

module UART_Rx(
	input clk,
	input rst_n,
	input [7:0] frame_data_in,
	input frame_data_ena,
	input[4:0] GA,

	output  [63:0]  data,
	output  data_valid

);


//**********************Variable Definition begin**********************//


//**********************Variable Definition end**********************//



//************************************************************************//
//************************Programmer start here***************************//
//************************************************************************//
localparam  [7:0] FRH_DET_FB 		      = 8'd0; //Frame_Head_Detection_First_Byte
localparam  [7:0] FRH_DET_SB              = 8'd1; //Frame_Head_Detection_Second_Byte


localparam  [7:0] FRC01_DET            = 8'd2; //Frame Content Store
localparam  [7:0] FRC02_DET            = 8'd3; //Frame Content Store
localparam  [7:0] FRC03_DET            = 8'd4; //Frame Content Store
localparam  [7:0] FRC04_DET            = 8'd5; //Frame Content Store
localparam  [7:0] FRC05_DET            = 8'd6; //Frame Content Store
localparam  [7:0] FRC06_DET            = 8'd7; //Frame Content Store
localparam  [7:0] FRC07_DET            = 8'd8; //Frame Content Store
localparam  [7:0] FRC08_DET            = 8'd9; //Frame Content Store



localparam  [7:0] CRC_DET                 = 8'd10; //CRC Store
localparam  [7:0] CRC_CHK                 = 8'd11; //CRC_Check
localparam  [7:0] FR_END                  = 8'd12; //Frame Detection Successful
localparam  [7:0] FR_ERR                  = 8'd13; //Error Occu


reg [7:0] fd_st_cuur;					//FSM:pointer
reg [7:0] fd_st_next;					//FSM:pointer

reg[63:0] R_UART_DATA;
reg  data_updata;
reg[7:0] CRC_Value;

reg[3:0] MYSLOT ;

//////////////////////////////////////////////////////////////////////////
////////////////////////// FSM(Three Parts) //////////////////////////////
//////////////////////////////////////////////////////////////////////////

//reg [7:0] CRC_Value;         //CRC check from "FRL_DET",add all data equal tp 8'h00 is right
//***************************FSM Part1 begin****************************//
always @(posedge clk, negedge rst_n)
	begin
		if(~rst_n) fd_st_cuur <= FRH_DET_FB; //initialization
		else fd_st_cuur <= fd_st_next;
	end
//*************************FSM Part1 end****************************//

//*************************FSM Part2 begin****************************//
always @(*) //next state generation
begin
	if(~rst_n) fd_st_next = FRH_DET_FB;
	else
	begin
		case(fd_st_cuur)
		FRH_DET_FB: begin
			if(frame_data_ena) begin
				if(frame_data_in == 8'heb) fd_st_next = FRH_DET_SB; //to next state
				else fd_st_next = FR_ERR;     //to error report,for fifo clear
			end
			else fd_st_next = FRH_DET_FB;     //hold
		end
		FRH_DET_SB: begin
			if(frame_data_ena) begin
				if(frame_data_in ==8'h9c) fd_st_next = FRC01_DET; //to next state
				else fd_st_next = FR_ERR; //to error report,for fifo clear
			end
			else fd_st_next = FRH_DET_SB; //hold
		end
		FRC01_DET: begin
			if(frame_data_ena) fd_st_next = FRC02_DET;
			else fd_st_next = FRC01_DET;
		end
		FRC02_DET: begin
			if(frame_data_ena) fd_st_next = FRC03_DET;
			else fd_st_next = FRC02_DET;
		end
		FRC03_DET: begin
			if(frame_data_ena) fd_st_next = FRC04_DET;
			else fd_st_next = FRC03_DET;
		end
		FRC04_DET: begin
			if(frame_data_ena) fd_st_next = FRC05_DET;
			else fd_st_next = FRC04_DET;
		end
		FRC05_DET: begin
			if(frame_data_ena) fd_st_next = FRC06_DET;
			else fd_st_next = FRC05_DET;
		end
		FRC06_DET: begin
			if(frame_data_ena) fd_st_next = FRC07_DET;
			else fd_st_next = FRC06_DET;
		end
		FRC07_DET: begin
			if(frame_data_ena) fd_st_next = FRC08_DET;
			else fd_st_next = FRC07_DET;
		end
		FRC08_DET: begin
			if(frame_data_ena) fd_st_next = FR_END;
			else fd_st_next = FRC08_DET;
		end

		FR_END: fd_st_next = FRH_DET_FB; //round to init
		FR_ERR: fd_st_next = FRH_DET_FB; //round to init
		default: fd_st_next = FRH_DET_FB;
		endcase
	end
end

always @ (posedge clk)
begin
	case(GA)
	5'd0: MYSLOT <= 4'd0 ;
	5'd1: MYSLOT <= 4'd0 ;
	5'd2: MYSLOT <= 4'd1 ;
	5'd3: MYSLOT <= 4'd2 ;
	5'd4: MYSLOT <= 4'd3 ;
	5'd5: MYSLOT <= 4'd4 ;
	5'd6: MYSLOT <= 4'd5 ;
	5'd7: MYSLOT <= 4'd6 ;
	5'd8: MYSLOT <= 4'd7 ;
	5'd9: MYSLOT <= 4'd0 ;
	5'd10: MYSLOT <= 4'd8 ;
	5'd11: MYSLOT <= 4'd9 ;
	5'd12: MYSLOT <= 4'd10 ;
	5'd13: MYSLOT <= 4'd11 ;
	5'd14: MYSLOT <= 4'd12 ;
	5'd15: MYSLOT <= 4'd13 ;
	5'd16: MYSLOT <= 4'd14 ;
	5'd17: MYSLOT <= 4'd15 ;

	default :MYSLOT <= 4'd0 ;
	endcase

end


//*************************FSM Part2 end****************************//

//*************************FSM Part3 begin****************************//
always @(posedge clk, negedge rst_n)
begin
	if(~rst_n)
	begin
		CRC_Value <= 8'd0;
		R_UART_DATA	<=	64'd0	;
		data_updata <= 1'B0 ;

	end
	else
	begin
		case(fd_st_cuur)
		FRH_DET_FB: begin
			if(frame_data_ena) CRC_Value <= frame_data_in;
			else CRC_Value <= CRC_Value;
			data_updata<= 1'b0;
		end
		FRH_DET_SB: begin
			if(frame_data_ena) CRC_Value <= CRC_Value + frame_data_in;
			else CRC_Value <= CRC_Value;
		end
		FRC01_DET: begin
			if(frame_data_ena) begin
				CRC_Value <= CRC_Value + frame_data_in;
				R_UART_DATA	  <= {R_UART_DATA[63:8],frame_data_in};
			end
			else begin
				CRC_Value <= CRC_Value;
				R_UART_DATA	  <= R_UART_DATA;
			end
			data_updata<= 1'b0;		//receive correct frame head
		end
		FRC02_DET: begin
			if(frame_data_ena) begin
				CRC_Value <= CRC_Value + frame_data_in;
				R_UART_DATA	  <= {R_UART_DATA[63:16],frame_data_in,R_UART_DATA[7:0]};
			end
			else begin
				CRC_Value <= CRC_Value;
				R_UART_DATA	  <= R_UART_DATA;
			end
		end
		FRC03_DET: begin
			if(frame_data_ena) begin
				CRC_Value <= CRC_Value + frame_data_in;
				R_UART_DATA	  <= {R_UART_DATA[63:24],frame_data_in,R_UART_DATA[15:0]};
			end
			else begin
				CRC_Value <= CRC_Value;
				R_UART_DATA	  <= R_UART_DATA;
			end
		end
		FRC04_DET: begin
			if(frame_data_ena) begin
				CRC_Value <= CRC_Value + frame_data_in;
				R_UART_DATA	  <= {R_UART_DATA[63:32],frame_data_in,R_UART_DATA[23:0]};
			end
			else begin
				CRC_Value <= CRC_Value;
				R_UART_DATA	  <= R_UART_DATA;
			end
		end
		FRC05_DET: begin
			if(frame_data_ena) begin
				CRC_Value <= CRC_Value + frame_data_in;
				R_UART_DATA	  <= {R_UART_DATA[63:40],frame_data_in,R_UART_DATA[31:0]};
			end
			else begin
				CRC_Value <= CRC_Value;
				R_UART_DATA	  <= R_UART_DATA;
			end
		end
		FRC06_DET: begin
			if(frame_data_ena) begin
				CRC_Value <= CRC_Value + frame_data_in;
				R_UART_DATA	  <= {R_UART_DATA[63:48],frame_data_in,R_UART_DATA[39:0]};
			end
			else begin
				CRC_Value <= CRC_Value;
				R_UART_DATA	  <= R_UART_DATA;
			end
		end
		FRC07_DET: begin
			if(frame_data_ena) begin
				CRC_Value <= CRC_Value + frame_data_in;
				R_UART_DATA	  <= {R_UART_DATA[63:56],frame_data_in,R_UART_DATA[47:0]};
			end
			else begin
				CRC_Value <= CRC_Value;
				R_UART_DATA	  <= R_UART_DATA;
			end
		end
		FRC08_DET: begin
			if(frame_data_ena) begin
				CRC_Value <= CRC_Value + frame_data_in;
				R_UART_DATA	  <= {frame_data_in,R_UART_DATA[55:0]};
			end
			else begin
				CRC_Value <= CRC_Value;
				R_UART_DATA	  <= R_UART_DATA;
			end
		end



		CRC_DET: begin
			if(frame_data_ena) CRC_Value <= CRC_Value + frame_data_in;
//			if(frame_data_ena) CRC_Value <= 8'h0;
			else CRC_Value <= CRC_Value;
		end
		CRC_CHK: begin
			CRC_Value <= CRC_Value;
			data_updata<= 1'b0;
		end
		FR_END: begin
			CRC_Value <= FR_END;
			data_updata<= 1'b1;
		end
		FR_ERR: begin
			CRC_Value <= FR_ERR;
			data_updata<= 1'b0;
		end
	    default: begin
			CRC_Value <= 8'd0;
			data_updata<= 1'b0;
			R_UART_DATA	<=	R_UART_DATA	;

		end
		endcase
	end
end

/*
always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		// reset
	    cycle_num    <= 32'h0000_03e8;
	    wait_time    <= 32'h0000_0000;
	end
	else begin
		if (data_updata && (R_UART_DATA[39:36] == MYSLOT))
		begin
			casez(R_UART_DATA[63:32])
				40'h4000_4???: begin
					wait_time <= R_UART_DATA[23:0];
				end
				40'h4000_1000: begin
					cycle_num <= R_UART_DATA[31:0];
				end
				default: begin
					wait_time <= wait_time;
					cycle_num <= cycle_num;
				end
			endcase
		end else begin
				wait_time <= wait_time;
				cycle_num <= cycle_num;
		end
	end
end*/
assign data = R_UART_DATA;
assign data_valid = data_updata;
//************************************************************************//
//************************Programmer end *********************************//
//************************************************************************//

endmodule



