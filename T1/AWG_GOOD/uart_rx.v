`timescale 1ns/1ns

module UART_Rx(
	input clk,
	input rst_n,
	input [7:0] frame_data_in,
	input frame_data_ena,
	input[4:0] GA,
	

	output reg [23:0] R_AWG_CH1_DELAY1   ,
	output reg [23:0] R_AWG_CH2_DELAY1   ,
	output reg [23:0] R_AWG_CH3_DELAY1   ,
	output reg [23:0] R_AWG_CH4_DELAY1   ,
	output reg [23:0] R_AWG_CH1_DELAY2   ,
	output reg [23:0] R_AWG_CH2_DELAY2   ,
	output reg [23:0] R_AWG_CH3_DELAY2   ,
	output reg [23:0] R_AWG_CH4_DELAY2   ,
	output reg [23:0] R_AWG_CH1_DELAY3   ,
	output reg [23:0] R_AWG_CH2_DELAY3   ,
	output reg [23:0] R_AWG_CH3_DELAY3   ,
	output reg [23:0] R_AWG_CH4_DELAY3   ,
	output reg [23:0]  R_AWG_CH1_LEN1	 ,
	output reg [23:0]  R_AWG_CH2_LEN1	 ,
	output reg [23:0]  R_AWG_CH3_LEN1	 ,
	output reg [23:0]  R_AWG_CH4_LEN1	 ,
	output reg [23:0]  R_AWG_CH1_LEN2	 ,
	output reg [23:0]  R_AWG_CH2_LEN2	 ,
	output reg [23:0]  R_AWG_CH3_LEN2	 ,
	output reg [23:0]  R_AWG_CH4_LEN2	 ,
	output reg [23:0]  R_AWG_CH1_LEN3	 ,
	output reg [23:0]  R_AWG_CH2_LEN3	 ,
	output reg [23:0]  R_AWG_CH3_LEN3	 ,
	output reg [23:0]  R_AWG_CH4_LEN3	 ,
	output reg [23:0]  R_AWG_CH1_ADDR1	 ,
	output reg [23:0]  R_AWG_CH2_ADDR1	 ,
	output reg [23:0]  R_AWG_CH3_ADDR1	 ,
	output reg [23:0]  R_AWG_CH4_ADDR1	 ,
	output reg [23:0]  R_AWG_CH1_ADDR2	 ,
	output reg [23:0]  R_AWG_CH2_ADDR2	 ,
	output reg [23:0]  R_AWG_CH3_ADDR2	 ,
	output reg [23:0]  R_AWG_CH4_ADDR2	 ,
	output reg [23:0]  R_AWG_CH1_ADDR3	 ,
	output reg [23:0]  R_AWG_CH2_ADDR3	 ,
	output reg [23:0]  R_AWG_CH3_ADDR3	 ,
    output reg [23:0]  R_AWG_CH4_ADDR3	
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

/*

localparam  [7:0] FRC_DAC1_ch01_DET            = 8'd5; //Frame Content Store
localparam  [7:0] FRC_DAC1_ch02_DET            = 8'd6; //Frame Content Store
localparam  [7:0] FRC_DAC1_ch03_DET            = 8'd7; //Frame Content Store
localparam  [7:0] FRC_DAC1_ch04_DET            = 8'd8; //Frame Content Store
localparam  [7:0] FRC_DAC1_ch05_DET            = 8'd9; //Frame Content Store
localparam  [7:0] FRC_DAC1_ch06_DET            = 8'd10; //Frame Content Store
localparam  [7:0] FRC_DAC1_ch07_DET            = 8'd11; //Frame Content Store
localparam  [7:0] FRC_DAC1_ch08_DET            = 8'd12; //Frame Content Store
localparam  [7:0] FRC_DAC1_ch09_DET            = 8'd13; //Frame Content Store
localparam  [7:0] FRC_DAC1_ch10_DET            = 8'd14; //Frame Content Store
localparam  [7:0] FRC_DAC1_ch11_DET            = 8'd15; //Frame Content Store
localparam  [7:0] FRC_DAC1_ch12_DET            = 8'd16; //Frame Content Store


localparam  [7:0] FRC_DAC2_ch01_DET            = 8'd17; //Frame Content Store
localparam  [7:0] FRC_DAC2_ch02_DET            = 8'd18; //Frame Content Store
localparam  [7:0] FRC_DAC2_ch03_DET            = 8'd19; //Frame Content Store
localparam  [7:0] FRC_DAC2_ch04_DET            = 8'd20; //Frame Content Store
localparam  [7:0] FRC_DAC2_ch05_DET            = 8'd21; //Frame Content Store
localparam  [7:0] FRC_DAC2_ch06_DET            = 8'd22; //Frame Content Store
localparam  [7:0] FRC_DAC2_ch07_DET            = 8'd23; //Frame Content Store
localparam  [7:0] FRC_DAC2_ch08_DET            = 8'd24; //Frame Content Store
localparam  [7:0] FRC_DAC2_ch09_DET            = 8'd25; //Frame Content Store
localparam  [7:0] FRC_DAC2_ch10_DET            = 8'd26; //Frame Content Store
localparam  [7:0] FRC_DAC2_ch11_DET            = 8'd27; //Frame Content Store
localparam  [7:0] FRC_DAC2_ch12_DET            = 8'd28; //Frame Content Store



localparam  [7:0] FRC_DAC3_ch01_DET            = 8'd29; //Frame Content Store
localparam  [7:0] FRC_DAC3_ch02_DET            = 8'd30; //Frame Content Store
localparam  [7:0] FRC_DAC3_ch03_DET            = 8'd31; //Frame Content Store
localparam  [7:0] FRC_DAC3_ch04_DET            = 8'd32; //Frame Content Store
localparam  [7:0] FRC_DAC3_ch05_DET            = 8'd33; //Frame Content Store
localparam  [7:0] FRC_DAC3_ch06_DET            = 8'd34; //Frame Content Store
localparam  [7:0] FRC_DAC3_ch07_DET            = 8'd35; //Frame Content Store
localparam  [7:0] FRC_DAC3_ch08_DET            = 8'd36; //Frame Content Store
localparam  [7:0] FRC_DAC3_ch09_DET            = 8'd37; //Frame Content Store
localparam  [7:0] FRC_DAC3_ch10_DET            = 8'd38; //Frame Content Store
localparam  [7:0] FRC_DAC3_ch11_DET            = 8'd39; //Frame Content Store
localparam  [7:0] FRC_DAC3_ch12_DET            = 8'd40; //Frame Content Store



localparam  [7:0] FRC_DAC4_ch01_DET            = 8'd41; //Frame Content Store
localparam  [7:0] FRC_DAC4_ch02_DET            = 8'd42; //Frame Content Store
localparam  [7:0] FRC_DAC4_ch03_DET            = 8'd43; //Frame Content Store
localparam  [7:0] FRC_DAC4_ch04_DET            = 8'd44; //Frame Content Store
localparam  [7:0] FRC_DAC4_ch05_DET            = 8'd45; //Frame Content Store
localparam  [7:0] FRC_DAC4_ch06_DET            = 8'd46; //Frame Content Store
localparam  [7:0] FRC_DAC4_ch07_DET            = 8'd47; //Frame Content Store
localparam  [7:0] FRC_DAC4_ch08_DET            = 8'd48; //Frame Content Store
localparam  [7:0] FRC_DAC4_ch09_DET            = 8'd49; //Frame Content Store
localparam  [7:0] FRC_DAC4_ch10_DET            = 8'd50; //Frame Content Store
localparam  [7:0] FRC_DAC4_ch11_DET            = 8'd51; //Frame Content Store
localparam  [7:0] FRC_DAC4_ch12_DET            = 8'd52; //Frame Content Store

*/

//localparam  [7:0] FRC_ch113_DET            = 8'd117; //Frame Content Store
//localparam  [7:0] FRC_ch114_DET            = 8'd118; //Frame Content Store
//localparam  [7:0] FRC_ch115_DET            = 8'd119; //Frame Content Store
//localparam  [7:0] FRC_ch116_DET            = 8'd120; //Frame Content Store
//localparam  [7:0] FRC_ch117_DET            = 8'd121; //Frame Content Store
//localparam  [7:0] FRC_ch118_DET            = 8'd122; //Frame Content Store
//localparam  [7:0] FRC_ch119_DET            = 8'd123; //Frame Content Store
//localparam  [7:0] FRC_ch120_DET            = 8'd124; //Frame Content Store

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

		
		
		
/*		
		FRC_ch17_DET: begin
			if(frame_data_ena) fd_st_next = FRC_ch18_DET;
			else fd_st_next = FRC_ch17_DET;
		end
		FRC_ch18_DET: begin
			if(frame_data_ena) fd_st_next = CRC_DET;
			else fd_st_next = FRC_ch18_DET;
		end
		CRC_DET: begin
			if(frame_data_ena) fd_st_next = CRC_CHK;
			else fd_st_next = CRC_DET;
		end
		CRC_CHK: begin
//			if(frame_data_ena) begin	
				if(CRC_Value == 8'd0) fd_st_next = FR_END; //to next state
				else fd_st_next = FR_ERR; //to error report,for fifo clear
//			end
//			else fd_st_next = CRC_CHK;
		end
*/		
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


always @(posedge clk, negedge rst_n)
begin
	if(~rst_n)
	begin
		R_AWG_CH1_DELAY1	<= 24'd0;
		R_AWG_CH2_DELAY1	<= 24'd0;
		R_AWG_CH3_DELAY1	<= 24'd0;
		R_AWG_CH4_DELAY1	<= 24'd0;
		R_AWG_CH1_DELAY2	<= 24'd0;
		R_AWG_CH2_DELAY2	<= 24'd0;
		R_AWG_CH3_DELAY2	<= 24'd0;
		R_AWG_CH4_DELAY2	<= 24'd0;
		R_AWG_CH1_DELAY3	<= 24'd0;
		R_AWG_CH2_DELAY3	<= 24'd0;
		R_AWG_CH3_DELAY3	<= 24'd0;
		R_AWG_CH4_DELAY3	<= 24'd0;
		R_AWG_CH1_LEN1	<= 24'd250;
		R_AWG_CH2_LEN1	<= 24'd250;
		R_AWG_CH3_LEN1	<= 24'd250;
		R_AWG_CH4_LEN1	<= 24'd250;
		R_AWG_CH1_LEN2	<= 24'd250;
		R_AWG_CH2_LEN2	<= 24'd250;
		R_AWG_CH3_LEN2	<= 24'd250;
		R_AWG_CH4_LEN2	<= 24'd250;
		R_AWG_CH1_LEN3	<= 24'd250;
		R_AWG_CH2_LEN3	<= 24'd250;
		R_AWG_CH3_LEN3	<= 24'd250;
		R_AWG_CH4_LEN3	<= 24'd250;
		R_AWG_CH1_ADDR1	<= 24'd0;
		R_AWG_CH2_ADDR1	<= 24'd0;
		R_AWG_CH3_ADDR1	<= 24'd0;
		R_AWG_CH4_ADDR1	<= 24'd0;
		R_AWG_CH1_ADDR2	<= 24'd250;
		R_AWG_CH2_ADDR2	<= 24'd250;
		R_AWG_CH3_ADDR2	<= 24'd250;
		R_AWG_CH4_ADDR2	<= 24'd250;
		R_AWG_CH1_ADDR3	<= 24'd500;
		R_AWG_CH2_ADDR3	<= 24'd500;
		R_AWG_CH3_ADDR3	<= 24'd500;
		R_AWG_CH4_ADDR3	<= 24'd500;
		
	end
	else
	begin
		if(data_updata && (R_UART_DATA[39:36] == MYSLOT) && (R_UART_DATA[35:34] == 2'd0) && (R_UART_DATA[31:28] == 4'd0) && (R_UART_DATA[27:24] == 4'd0))
		begin
			R_AWG_CH1_DELAY1	<=	R_UART_DATA[23:0] ;
		end
		else if	(data_updata && (R_UART_DATA[39:36] == MYSLOT) && (R_UART_DATA[35:34] == 2'd1) &&(R_UART_DATA[31:28] == 4'd0) && (R_UART_DATA[27:24] == 4'd0))
		begin
			R_AWG_CH2_DELAY1	<=	R_UART_DATA[23:0] ;
		end
		else if	(data_updata && (R_UART_DATA[39:36] == MYSLOT) && (R_UART_DATA[35:34] == 2'd2) &&(R_UART_DATA[31:28] == 4'd0) && (R_UART_DATA[27:24] == 4'd0))
		begin
			R_AWG_CH3_DELAY1	<=	R_UART_DATA[23:0] ;
		end
		else if	(data_updata && (R_UART_DATA[39:36] == MYSLOT) && (R_UART_DATA[35:34] == 2'd3) &&(R_UART_DATA[31:28] == 4'd0) && (R_UART_DATA[27:24] == 4'd0))
		begin
			R_AWG_CH4_DELAY1	<=	R_UART_DATA[23:0] ;
		end
		else if	(data_updata && (R_UART_DATA[39:36] == MYSLOT) && (R_UART_DATA[35:34] == 2'd0) &&(R_UART_DATA[31:28] == 4'd1) && (R_UART_DATA[27:24] == 4'd0))
		begin
			R_AWG_CH1_LEN1	<=	R_UART_DATA[23:0] ;
		end
		else if	(data_updata && (R_UART_DATA[39:36] == MYSLOT) && (R_UART_DATA[35:34] == 2'd1) &&(R_UART_DATA[31:28] == 4'd1) && (R_UART_DATA[27:24] == 4'd0))
		begin
			R_AWG_CH2_LEN1	<=	R_UART_DATA[23:0] ;
		end
		else if	(data_updata && (R_UART_DATA[39:36] == MYSLOT) && (R_UART_DATA[35:34] == 2'd2) &&(R_UART_DATA[31:28] == 4'd1) && (R_UART_DATA[27:24] == 4'd0))
		begin
			R_AWG_CH3_LEN1	<=	R_UART_DATA[23:0] ;
		end
		else if	(data_updata && (R_UART_DATA[39:36] == MYSLOT) && (R_UART_DATA[35:34] == 2'd3) &&(R_UART_DATA[31:28] == 4'd1) && (R_UART_DATA[27:24] == 4'd0))
		begin
			R_AWG_CH4_LEN1	<=	R_UART_DATA[23:0] ;
		end
		else if	(data_updata && (R_UART_DATA[39:36] == MYSLOT) && (R_UART_DATA[35:34] == 2'd0) &&(R_UART_DATA[31:28] == 4'd2) && (R_UART_DATA[27:24] == 4'd0))
		begin
			R_AWG_CH1_ADDR1	<=	R_UART_DATA[23:0] ;
		end
		else if	(data_updata && (R_UART_DATA[39:36] == MYSLOT) && (R_UART_DATA[35:34] == 2'd1) &&(R_UART_DATA[31:28] == 4'd2) && (R_UART_DATA[27:24] == 4'd0))
		begin
			R_AWG_CH2_ADDR1	<=	R_UART_DATA[23:0] ;
		end
		else if	(data_updata && (R_UART_DATA[39:36] == MYSLOT) && (R_UART_DATA[35:34] == 2'd2) &&(R_UART_DATA[31:28] == 4'd2) && (R_UART_DATA[27:24] == 4'd0))
		begin
			R_AWG_CH3_ADDR1	<=	R_UART_DATA[23:0] ;
		end
		else if	(data_updata && (R_UART_DATA[39:36] == MYSLOT) && (R_UART_DATA[35:34] == 2'd3) &&(R_UART_DATA[31:28] == 4'd2) && (R_UART_DATA[27:24] == 4'd0))
		begin
			R_AWG_CH4_ADDR1	<=	R_UART_DATA[23:0] ;
		end
		else if(data_updata && (R_UART_DATA[39:36] == MYSLOT) && (R_UART_DATA[35:34] == 2'd0) &&(R_UART_DATA[31:28] == 4'd0) && (R_UART_DATA[27:24] == 4'd1))
		begin
			R_AWG_CH1_DELAY2	<=	R_UART_DATA[23:0] ;
		end
		else if	(data_updata && (R_UART_DATA[39:36] == MYSLOT) && (R_UART_DATA[35:34] == 2'd1) &&(R_UART_DATA[31:28] == 4'd0) && (R_UART_DATA[27:24] == 4'd1))
		begin
			R_AWG_CH2_DELAY2	<=	R_UART_DATA[23:0] ;
		end
		else if	(data_updata && (R_UART_DATA[39:36] == MYSLOT) && (R_UART_DATA[35:34] == 2'd2) &&(R_UART_DATA[31:28] == 4'd0) && (R_UART_DATA[27:24] == 4'd1))
		begin
			R_AWG_CH3_DELAY2	<=	R_UART_DATA[23:0] ;
		end
		else if	(data_updata && (R_UART_DATA[39:36] == MYSLOT) && (R_UART_DATA[35:34] == 2'd3) &&(R_UART_DATA[31:28] == 4'd0) && (R_UART_DATA[27:24] == 4'd1))
		begin
			R_AWG_CH4_DELAY2	<=	R_UART_DATA[23:0] ;
		end
		else if	(data_updata && (R_UART_DATA[39:36] == MYSLOT) && (R_UART_DATA[35:34] == 2'd0) &&(R_UART_DATA[31:28] == 4'd1) && (R_UART_DATA[27:24] == 4'd1))
		begin
			R_AWG_CH1_LEN2	<=	R_UART_DATA[23:0] ;
		end
		else if	(data_updata && (R_UART_DATA[39:36] == MYSLOT) && (R_UART_DATA[35:34] == 2'd1) &&(R_UART_DATA[31:28] == 4'd1) && (R_UART_DATA[27:24] == 4'd1))
		begin
			R_AWG_CH2_LEN2	<=	R_UART_DATA[23:0] ;
		end
		else if	(data_updata && (R_UART_DATA[39:36] == MYSLOT) && (R_UART_DATA[35:34] == 2'd2) &&(R_UART_DATA[31:28] == 4'd1) && (R_UART_DATA[27:24] == 4'd1))
		begin
			R_AWG_CH3_LEN2	<=	R_UART_DATA[23:0] ;
		end
		else if	(data_updata && (R_UART_DATA[39:36] == MYSLOT) && (R_UART_DATA[35:34] == 2'd3) &&(R_UART_DATA[31:28] == 4'd1) && (R_UART_DATA[27:24] == 4'd1))
		begin
			R_AWG_CH4_LEN2	<=	R_UART_DATA[23:0] ;
		end
		else if	(data_updata && (R_UART_DATA[39:36] == MYSLOT) && (R_UART_DATA[35:34] == 2'd0) &&(R_UART_DATA[31:28] == 4'd2) && (R_UART_DATA[27:24] == 4'd1))
		begin
			R_AWG_CH1_ADDR2	<=	R_UART_DATA[23:0] ;
		end
		else if	(data_updata && (R_UART_DATA[39:36] == MYSLOT) && (R_UART_DATA[35:34] == 2'd1) &&(R_UART_DATA[31:28] == 4'd2) && (R_UART_DATA[27:24] == 4'd1))
		begin
			R_AWG_CH2_ADDR2	<=	R_UART_DATA[23:0] ;
		end
		else if	(data_updata && (R_UART_DATA[39:36] == MYSLOT) && (R_UART_DATA[35:34] == 2'd2) &&(R_UART_DATA[31:28] == 4'd2) && (R_UART_DATA[27:24] == 4'd1))
		begin
			R_AWG_CH3_ADDR2	<=	R_UART_DATA[23:0] ;
		end
		else if	(data_updata && (R_UART_DATA[39:36] == MYSLOT) && (R_UART_DATA[35:34] == 2'd3) &&(R_UART_DATA[31:28] == 4'd2) && (R_UART_DATA[27:24] == 4'd1))
		begin
			R_AWG_CH4_ADDR2	<=	R_UART_DATA[23:0] ;
		end
		else if(data_updata && (R_UART_DATA[39:36] == MYSLOT) && (R_UART_DATA[35:34] == 2'd0) &&(R_UART_DATA[31:28] == 4'd0) && (R_UART_DATA[27:24] == 4'd2))
		begin
			R_AWG_CH1_DELAY3	<=	R_UART_DATA[23:0] ;
		end
		else if	(data_updata && (R_UART_DATA[39:36] == MYSLOT) && (R_UART_DATA[35:34] == 2'd1) &&(R_UART_DATA[31:28] == 4'd0) && (R_UART_DATA[27:24] == 4'd2))
		begin
			R_AWG_CH2_DELAY3	<=	R_UART_DATA[23:0] ;
		end
		else if	(data_updata && (R_UART_DATA[39:36] == MYSLOT) && (R_UART_DATA[35:34] == 2'd2) &&(R_UART_DATA[31:28] == 4'd0) && (R_UART_DATA[27:24] == 4'd2))
		begin
			R_AWG_CH3_DELAY3	<=	R_UART_DATA[23:0] ;
		end
		else if	(data_updata && (R_UART_DATA[39:36] == MYSLOT) && (R_UART_DATA[35:34] == 2'd3) &&(R_UART_DATA[31:28] == 4'd0) && (R_UART_DATA[27:24] == 4'd2))
		begin
			R_AWG_CH4_DELAY3	<=	R_UART_DATA[23:0] ;
		end
		else if	(data_updata && (R_UART_DATA[39:36] == MYSLOT) && (R_UART_DATA[35:34] == 2'd0) &&(R_UART_DATA[31:28] == 4'd1) && (R_UART_DATA[27:24] == 4'd2))
		begin
			R_AWG_CH1_LEN3	<=	R_UART_DATA[23:0] ;
		end
		else if	(data_updata && (R_UART_DATA[39:36] == MYSLOT) && (R_UART_DATA[35:34] == 2'd1) &&(R_UART_DATA[31:28] == 4'd1) && (R_UART_DATA[27:24] == 4'd2))
		begin
			R_AWG_CH2_LEN3	<=	R_UART_DATA[23:0] ;
		end
		else if	(data_updata && (R_UART_DATA[39:36] == MYSLOT) && (R_UART_DATA[35:34] == 2'd2) &&(R_UART_DATA[31:28] == 4'd1) && (R_UART_DATA[27:24] == 4'd2))
		begin
			R_AWG_CH3_LEN3	<=	R_UART_DATA[23:0] ;
		end
		else if	(data_updata && (R_UART_DATA[39:36] == MYSLOT) && (R_UART_DATA[35:34] == 2'd3) &&(R_UART_DATA[31:28] == 4'd1) && (R_UART_DATA[27:24] == 4'd2))
		begin
			R_AWG_CH4_LEN3	<=	R_UART_DATA[23:0] ;
		end
		else if	(data_updata && (R_UART_DATA[39:36] == MYSLOT) && (R_UART_DATA[35:34] == 2'd0) &&(R_UART_DATA[31:28] == 4'd2) && (R_UART_DATA[27:24] == 4'd2))
		begin
			R_AWG_CH1_ADDR3	<=	R_UART_DATA[23:0] ;
		end
		else if	(data_updata && (R_UART_DATA[39:36] == MYSLOT) && (R_UART_DATA[35:34] == 2'd1) &&(R_UART_DATA[31:28] == 4'd2) && (R_UART_DATA[27:24] == 4'd2))
		begin
			R_AWG_CH2_ADDR3	<=	R_UART_DATA[23:0] ;
		end
		else if	(data_updata && (R_UART_DATA[39:36] == MYSLOT) && (R_UART_DATA[35:34] == 2'd2) &&(R_UART_DATA[31:28] == 4'd2) && (R_UART_DATA[27:24] == 4'd2))
		begin
			R_AWG_CH3_ADDR3	<=	R_UART_DATA[23:0] ;
		end
		else if	(data_updata && (R_UART_DATA[39:36] == MYSLOT) && (R_UART_DATA[35:34] == 2'd3) &&(R_UART_DATA[31:28] == 4'd2) && (R_UART_DATA[27:24] == 4'd2))
		begin
			R_AWG_CH4_ADDR3	<=	R_UART_DATA[23:0] ;
		end
		else
		begin
			R_AWG_CH1_DELAY1	<= 		R_AWG_CH1_DELAY1   ;
			R_AWG_CH2_DELAY1	<= 		R_AWG_CH2_DELAY1   ;
			R_AWG_CH3_DELAY1	<= 		R_AWG_CH3_DELAY1   ;
			R_AWG_CH4_DELAY1	<= 		R_AWG_CH4_DELAY1   ;
			R_AWG_CH1_DELAY2	<= 		R_AWG_CH1_DELAY2   ;
			R_AWG_CH2_DELAY2	<= 		R_AWG_CH2_DELAY2   ;
			R_AWG_CH3_DELAY2	<= 		R_AWG_CH3_DELAY2   ;
			R_AWG_CH4_DELAY2	<= 		R_AWG_CH4_DELAY2   ;
			R_AWG_CH1_DELAY3	<= 		R_AWG_CH1_DELAY3   ;
			R_AWG_CH2_DELAY3	<= 		R_AWG_CH2_DELAY3   ;
			R_AWG_CH3_DELAY3	<= 		R_AWG_CH3_DELAY3   ;
			R_AWG_CH4_DELAY3	<= 		R_AWG_CH4_DELAY3   ;
			R_AWG_CH1_LEN1		<= 		R_AWG_CH1_LEN1	   ;
			R_AWG_CH2_LEN1		<= 		R_AWG_CH2_LEN1	   ;
			R_AWG_CH3_LEN1		<= 		R_AWG_CH3_LEN1	   ;
			R_AWG_CH4_LEN1		<= 		R_AWG_CH4_LEN1	   ;
			R_AWG_CH1_LEN2		<= 		R_AWG_CH1_LEN2	   ;
			R_AWG_CH2_LEN2		<= 		R_AWG_CH2_LEN2	   ;
			R_AWG_CH3_LEN2		<= 		R_AWG_CH3_LEN2	   ;
			R_AWG_CH4_LEN2		<= 		R_AWG_CH4_LEN2	   ;
			R_AWG_CH1_LEN3		<= 		R_AWG_CH1_LEN3	   ;
			R_AWG_CH2_LEN3		<= 		R_AWG_CH2_LEN3	   ;
			R_AWG_CH3_LEN3		<= 		R_AWG_CH3_LEN3	   ;
			R_AWG_CH4_LEN3		<= 		R_AWG_CH4_LEN3	   ;
            R_AWG_CH1_ADDR1		<= 		R_AWG_CH1_ADDR1	   ;
		    R_AWG_CH2_ADDR1		<= 		R_AWG_CH2_ADDR1	   ;
		    R_AWG_CH3_ADDR1		<= 		R_AWG_CH3_ADDR1	   ;
		    R_AWG_CH4_ADDR1		<= 		R_AWG_CH4_ADDR1	   ;
		    R_AWG_CH1_ADDR2		<= 		R_AWG_CH1_ADDR2	   ;
		    R_AWG_CH2_ADDR2		<= 		R_AWG_CH2_ADDR2	   ;
		    R_AWG_CH3_ADDR2		<= 		R_AWG_CH3_ADDR2	   ;
		    R_AWG_CH4_ADDR2		<= 		R_AWG_CH4_ADDR2	   ;
		    R_AWG_CH1_ADDR3		<= 		R_AWG_CH1_ADDR3	   ;
		    R_AWG_CH2_ADDR3		<= 		R_AWG_CH2_ADDR3	   ;
		    R_AWG_CH3_ADDR3		<= 		R_AWG_CH3_ADDR3	   ;
		    R_AWG_CH4_ADDR3		<= 		R_AWG_CH4_ADDR3	   ;
		end
	end
end	
		

//************************************************************************//
//************************Programmer end *********************************//
//************************************************************************//
	
endmodule


