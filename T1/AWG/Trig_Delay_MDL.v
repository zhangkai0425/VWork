`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/09/08 19:39:41
// Design Name: 
// Module Name: Trig_Delay_MDL
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


module Trig_Delay_MDL
#(
	parameter MAXIMUM_WIDTH_OF_EACH_CH = 11			//每个通道可以存下的最大波形数目
)
(
	input I_clk_250mhz,
	input I_rst_n,

	input [MAXIMUM_WIDTH_OF_EACH_CH-1:0] AWG_CH1_WAVENUM,
	input [MAXIMUM_WIDTH_OF_EACH_CH-1:0] AWG_CH2_WAVENUM,
	input [MAXIMUM_WIDTH_OF_EACH_CH-1:0] AWG_CH3_WAVENUM,
	input [MAXIMUM_WIDTH_OF_EACH_CH-1:0] AWG_CH4_WAVENUM,

	input 	I_trig	,

	output 	reg [MAXIMUM_WIDTH_OF_EACH_CH-1:0]	O_dac1_tx_id	,
	output 	reg									O_dac1_tx_ena	,
	input	[23:0]								I_dac1_tx_delay	,

	output 	reg [MAXIMUM_WIDTH_OF_EACH_CH-1:0]	O_dac2_tx_id	,
	output 	reg									O_dac2_tx_ena	,
	input	[23:0]								I_dac2_tx_delay	,

	output 	reg [MAXIMUM_WIDTH_OF_EACH_CH-1:0]	O_dac3_tx_id	,
	output	reg									O_dac3_tx_ena	,
	input	[23:0]								I_dac3_tx_delay	,

	output	reg [MAXIMUM_WIDTH_OF_EACH_CH-1:0]	O_dac4_tx_id	,
	output	reg									O_dac4_tx_ena	,
	input	[23:0]								I_dac4_tx_delay	,

	output	[3:0]	R_State1	,
	output	[3:0]	R_State2	,
	output	[3:0]	R_State3	,
	output	[3:0]	R_State4	
	
	);

//记录各个通道已经进行的延迟数
reg[23:0]	R_cnt_delay1	;
reg[23:0]	R_cnt_delay2	;
reg[23:0]	R_cnt_delay3	;
reg[23:0]	R_cnt_delay4	;

//同步各个通道的相位
reg[6:0]	R_cnt_sync1		;
reg[6:0]	R_cnt_sync2		;
reg[6:0]	R_cnt_sync3		;
reg[6:0]	R_cnt_sync4		;

//记录各个通道已经产生的波形个数
reg[MAXIMUM_WIDTH_OF_EACH_CH-1:0]	R_COUNT_AWG_CH1	;
reg[MAXIMUM_WIDTH_OF_EACH_CH-1:0]	R_COUNT_AWG_CH2	;
reg[MAXIMUM_WIDTH_OF_EACH_CH-1:0]	R_COUNT_AWG_CH3	;
reg[MAXIMUM_WIDTH_OF_EACH_CH-1:0]	R_COUNT_AWG_CH4	;

//控制CH1通道的状态机延迟
reg[3:0]	R_State1	;
reg[3:0]	R_NextState1	;

parameter [3:0]	ST1_IDLE		= 4'd0	;
parameter [3:0]	ST1_WAIT		= 4'd1	;
parameter [3:0]	ST1_DELAY	    = 4'd2	;
parameter [3:0]	ST1_DONE		= 4'd3	;
parameter [3:0]	ST1_SYNC		= 4'd4	;

//控制CH2通道的状态机延迟
reg[3:0]	R_State2	;
reg[3:0]	R_NextState2	;

parameter [3:0]	ST2_IDLE		= 4'd0	;
parameter [3:0]	ST2_WAIT		= 4'd1	;
parameter [3:0]	ST2_DELAY	    = 4'd2	;
parameter [3:0]	ST2_DONE		= 4'd3	;
parameter [3:0]	ST2_SYNC		= 4'd4	;

//控制CH3通道的状态机延迟
reg[3:0]	R_State3	;
reg[3:0]	R_NextState3	;

parameter [3:0]	ST3_IDLE		= 4'd0	;
parameter [3:0]	ST3_WAIT		= 4'd1	;
parameter [3:0]	ST3_DELAY	    = 4'd2	;
parameter [3:0]	ST3_DONE		= 4'd3	;
parameter [3:0]	ST3_SYNC		= 4'd4	;

//控制CH4通道的状态机延迟
reg[3:0]	R_State4	;
reg[3:0]	R_NextState4	;

parameter [3:0]	ST4_IDLE		= 4'd0	;
parameter [3:0]	ST4_WAIT		= 4'd1	;
parameter [3:0]	ST4_DELAY	    = 4'd2	;
parameter [3:0]	ST4_DONE		= 4'd3	;
parameter [3:0]	ST4_SYNC		= 4'd4	;


wire	W_trig	;	
reg 	R1_trig	;
reg 	R2_trig	;

//将I_trig转化成4ns的单脉冲的信号
always @ (posedge I_clk_250mhz)
begin
	if(~I_rst_n)
	begin
		R1_trig	<=	1'b0	;
		R2_trig <=	1'b0	;
	end	
	else
	begin
		R1_trig	<=	I_trig	;
		R2_trig <=	R1_trig	;	
	end
end

assign W_trig = R1_trig & ~ R2_trig	;


//*****************************************DAC1 DELAY MODULE*************************************************
always @ (posedge I_clk_250mhz )
begin
	if(~I_rst_n)
	begin
		R_State1		<=	ST1_IDLE	;
	end
	else
	begin
		R_State1		<=	R_NextState1;
	end
end	
			
always @(*)
begin
	case(R_State1)
		ST1_IDLE:
		begin
			R_NextState1	=	ST1_WAIT	;
		end
	
		ST1_WAIT:
		begin
			if(W_trig && AWG_CH1_WAVENUM != 11'd0)
			begin
				R_NextState1	=	ST1_DELAY	;
			end
			else
			begin
				R_NextState1	=	ST1_WAIT	;
			end	
			
		end

		ST1_SYNC:
		begin
			if(R_cnt_sync1 >= 6'd40)
			begin
				R_NextState1	=	ST1_DELAY	;
			end
			else
			begin
				R_NextState1	=	ST1_SYNC	;
			end
		end

		ST1_DELAY:
		begin
			if(AWG_CH1_WAVENUM == R_COUNT_AWG_CH1)
				R_NextState1	=	ST1_DONE	;
			else
			begin	
				R_NextState1	=	ST1_DELAY	;
			end
		end
		
		ST1_DONE:
		begin
			R_NextState1	=	ST1_IDLE	;
		end
		
		
		
		default:	R_NextState1	=	ST1_IDLE	;
	endcase
end	


always @ (posedge I_clk_250mhz)
begin
	if(~I_rst_n)
	begin
		O_dac1_tx_id	<=	11'd0	;
		O_dac1_tx_ena	<=	1'd0	;

		R_cnt_delay1	<=	24'd0	;
		R_COUNT_AWG_CH1	<=	11'd0	;

		R_cnt_sync1		<=	5'd0	;		
	end

	else
	begin
		case(R_State1)
			ST1_IDLE:
			begin
				O_dac1_tx_id	<=	11'd0	;
				O_dac1_tx_ena	<=	1'd0	;

				R_cnt_delay1	<=	24'd0	;
				R_COUNT_AWG_CH1	<=	11'd0	;

				R_cnt_sync1		<=	5'd0	;
			end		
			
			ST1_WAIT:
			begin
				O_dac1_tx_id	<=	11'd0	;
				O_dac1_tx_ena	<=	1'd0	;

				R_cnt_delay1	<=	24'd0	;
				R_COUNT_AWG_CH1	<=	11'd0	;

				R_cnt_sync1		<=	5'd0	;
			end

			ST1_SYNC:
			begin
				O_dac1_tx_id	<=	11'd0	;
				O_dac1_tx_ena	<=	1'd0	;

				R_cnt_delay1	<=	24'd0	;
				R_COUNT_AWG_CH1	<=	11'd0	;

				R_cnt_sync1		<=	R_cnt_sync1	+	5'd1	;
			end

			ST1_DELAY:
			begin
				R_cnt_delay1	<=	R_cnt_delay1 +	24'd1	;
				if(R_cnt_delay1 == I_dac1_tx_delay)
				begin
					O_dac1_tx_id	<=	O_dac1_tx_id	+ 11'd1	;
					O_dac1_tx_ena	<= 	1'b1					;
					R_COUNT_AWG_CH1 <=	R_COUNT_AWG_CH1 + 11'd1	;
				end
				else
				begin
					O_dac1_tx_id	<=	O_dac1_tx_id	;
					O_dac1_tx_ena	<=	1'b0			;
					R_COUNT_AWG_CH1	<=	R_COUNT_AWG_CH1	;
				end
				
				R_cnt_sync1		<=	5'd0	;
			end	
			
			
			ST1_DONE:
			begin
				O_dac1_tx_id	<=	11'd0	;
				O_dac1_tx_ena	<=	1'd0	;

				R_cnt_delay1	<=	24'd0	;
				R_COUNT_AWG_CH1	<=	11'd0	;

				R_cnt_sync1		<=	5'd0	;
			end	
						
			default:
			begin
				O_dac1_tx_id	<=	11'd0	;
				O_dac1_tx_ena	<=	1'd0	;

				R_cnt_delay1	<=	24'd0	;
				R_COUNT_AWG_CH1	<=	11'd0	;

				R_cnt_sync1		<=	5'd0	;

			end
		endcase
	end
end

//*****************************************DAC2 DELAY MODULE*************************************************
always @ (posedge I_clk_250mhz )
begin
	if(~I_rst_n)
	begin
		R_State2		<=	ST2_IDLE	;
	end
	else
	begin
		R_State2		<=	R_NextState2;
	end
end	
			
always @(*)
begin
	case(R_State2)
		ST2_IDLE:
		begin
			R_NextState2	=	ST2_WAIT	;
		end
	
		ST2_WAIT:
		begin
			if(W_trig && AWG_CH2_WAVENUM != 11'd0)
			begin
				R_NextState2	=	ST2_DELAY	;
			end
			else
			begin
				R_NextState2	=	ST2_WAIT	;
			end	
			
		end

		ST2_SYNC:
		begin
			if(R_cnt_sync2 >= 6'd40)
			begin
				R_NextState2	=	ST2_DELAY	;
			end
			else
			begin
				R_NextState2	=	ST2_SYNC	;
			end
		end

		ST2_DELAY:
		begin
			if(AWG_CH2_WAVENUM == R_COUNT_AWG_CH2)
				R_NextState2	=	ST2_DONE	;
			else
			begin	
				R_NextState2	=	ST2_DELAY	;
			end
		end
		
		ST2_DONE:
		begin
			R_NextState2	=	ST2_IDLE	;
		end
		
		
		
		default:	R_NextState2	=	ST2_IDLE	;
	endcase
end	


always @ (posedge I_clk_250mhz)
begin
	if(~I_rst_n)
	begin
		O_dac2_tx_id	<=	11'd0	;
		O_dac2_tx_ena	<=	1'd0	;

		R_cnt_delay2	<=	24'd0	;
		R_COUNT_AWG_CH2	<=	11'd0	;

		R_cnt_sync2		<=	5'd0	;		
	end

	else
	begin
		case(R_State2)
			ST2_IDLE:
			begin
				O_dac2_tx_id	<=	11'd0	;
				O_dac2_tx_ena	<=	1'd0	;

				R_cnt_delay2	<=	24'd0	;
				R_COUNT_AWG_CH2	<=	11'd0	;

				R_cnt_sync2		<=	5'd0	;
			end		
			
			ST2_WAIT:
			begin
				O_dac2_tx_id	<=	11'd0	;
				O_dac2_tx_ena	<=	1'd0	;

				R_cnt_delay2	<=	24'd0	;
				R_COUNT_AWG_CH2	<=	11'd0	;

				R_cnt_sync2		<=	5'd0	;
			end	
			
			ST2_SYNC:
			begin
				O_dac2_tx_id	<=	11'd0	;
				O_dac2_tx_ena	<=	1'd0	;

				R_cnt_delay2	<=	24'd0	;
				R_COUNT_AWG_CH2	<=	11'd0	;

				R_cnt_sync2		<=	R_cnt_sync2	+	5'd1	;				
			end

			ST2_DELAY:
			begin
				R_cnt_delay2	<=	R_cnt_delay2 +	24'd1	;
				if(R_cnt_delay2 == I_dac2_tx_delay)
				begin
					O_dac2_tx_id	<=	O_dac2_tx_id	+ 11'd1	;
					O_dac2_tx_ena	<= 	1'b1					;
					R_COUNT_AWG_CH2 <=	R_COUNT_AWG_CH2 + 11'd1	;
				end
				else
				begin
					O_dac2_tx_id	<=	O_dac2_tx_id	;
					O_dac2_tx_ena	<=	1'b0			;
					R_COUNT_AWG_CH2	<=	R_COUNT_AWG_CH2	;
				end

				R_cnt_sync2		<=	5'd0	;
				
			end	
			
			
			ST2_DONE:
			begin
				O_dac2_tx_id	<=	11'd0	;
				O_dac2_tx_ena	<=	1'd0	;

				R_cnt_delay2	<=	24'd0	;
				R_COUNT_AWG_CH2	<=	11'd0	;

				R_cnt_sync2		<=	5'd0	;
			end	
						
			default:
			begin
				O_dac2_tx_id	<=	11'd0	;
				O_dac2_tx_ena	<=	1'd0	;

				R_cnt_delay2	<=	24'd0	;
				R_COUNT_AWG_CH2	<=	11'd0	;

				R_cnt_sync2		<=	5'd0	;

			end
		endcase
	end
end

//*****************************************DAC3 DELAY MODULE*************************************************
always @ (posedge I_clk_250mhz )
begin
	if(~I_rst_n)
	begin
		R_State3		<=	ST3_IDLE	;
	end
	else
	begin
		R_State3		<=	R_NextState3;
	end
end	
			
always @(*)
begin
	case(R_State3)
		ST3_IDLE:
		begin
			R_NextState3	=	ST3_WAIT	;
		end
	
		ST3_WAIT:
		begin
			if(W_trig && AWG_CH3_WAVENUM != 11'd0)
			begin
				R_NextState3	=	ST3_DELAY	;
			end
			else
			begin
				R_NextState3	=	ST3_WAIT	;
			end	
			
		end
		
		ST3_SYNC:
		begin
			if(R_cnt_sync3 >= 6'd40)
			begin
				R_NextState3	=	ST3_DELAY	;
			end
			else
			begin
				R_NextState3	=	ST3_SYNC	;
			end
		end

		ST3_DELAY:
		begin
			if(AWG_CH3_WAVENUM == R_COUNT_AWG_CH3)
				R_NextState3	=	ST3_DONE	;
			else
			begin	
				R_NextState3	=	ST3_DELAY	;
			end
		end
		
		ST3_DONE:
		begin
			R_NextState3	=	ST3_IDLE	;
		end
		
		
		
		default:	R_NextState3	=	ST3_IDLE	;
	endcase
end	


always @ (posedge I_clk_250mhz)
begin
	if(~I_rst_n)
	begin
		O_dac3_tx_id	<=	11'd0	;
		O_dac3_tx_ena	<=	1'd0	;

		R_cnt_delay3	<=	24'd0	;
		R_COUNT_AWG_CH3	<=	11'd0	;	

		R_cnt_sync3		<=	5'd0	;	
	end

	else
	begin
		case(R_State3)
			ST3_IDLE:
			begin
				O_dac3_tx_id	<=	11'd0	;
				O_dac3_tx_ena	<=	1'd0	;

				R_cnt_delay3	<=	24'd0	;
				R_COUNT_AWG_CH3	<=	11'd0	;

				R_cnt_sync3		<=	5'd0	;
			end		
			
			ST3_WAIT:
			begin
				O_dac3_tx_id	<=	11'd0	;
				O_dac3_tx_ena	<=	1'd0	;

				R_cnt_delay3	<=	24'd0	;
				R_COUNT_AWG_CH3	<=	11'd0	;
				
				R_cnt_sync3		<=	5'd0	;
			end	
			
			ST3_SYNC:
			begin
				O_dac3_tx_id	<=	11'd0	;
				O_dac3_tx_ena	<=	1'd0	;

				R_cnt_delay3	<=	24'd0	;
				R_COUNT_AWG_CH3	<=	11'd0	;
				
				R_cnt_sync3		<=	R_cnt_sync3	+	5'd1	;
			end

			ST3_DELAY:
			begin
				R_cnt_delay3	<=	R_cnt_delay3 +	24'd1	;
				if(R_cnt_delay3 == I_dac3_tx_delay)
				begin
					O_dac3_tx_id	<=	O_dac3_tx_id	+ 11'd1	;
					O_dac3_tx_ena	<= 	1'b1					;
					R_COUNT_AWG_CH3 <=	R_COUNT_AWG_CH3 + 11'd1	;
				end
				else
				begin
					O_dac3_tx_id	<=	O_dac3_tx_id	;
					O_dac3_tx_ena	<=	1'b0			;
					R_COUNT_AWG_CH3	<=	R_COUNT_AWG_CH3	;
				end

				R_cnt_sync3		<=	5'd0	;
				
			end	
			
			
			ST3_DONE:
			begin
				O_dac3_tx_id	<=	11'd0	;
				O_dac3_tx_ena	<=	1'd0	;

				R_cnt_delay3	<=	24'd0	;
				R_COUNT_AWG_CH3	<=	11'd0	;

				R_cnt_sync3		<=	5'd0	;
			end	
						
			default:
			begin
				O_dac3_tx_id	<=	11'd0	;
				O_dac3_tx_ena	<=	1'd0	;

				R_cnt_delay3	<=	24'd0	;
				R_COUNT_AWG_CH3	<=	11'd0	;

				R_cnt_sync3		<=	5'd0	;

			end
		endcase
	end
end

//*****************************************DAC4 DELAY MODULE*************************************************
always @ (posedge I_clk_250mhz )
begin
	if(~I_rst_n)
	begin
		R_State4		<=	ST4_IDLE	;
	end
	else
	begin
		R_State4		<=	R_NextState4;
	end
end	
			
always @(*)
begin
	case(R_State4)
		ST4_IDLE:
		begin
			R_NextState4	=	ST4_WAIT	;
		end
	
		ST4_WAIT:
		begin
			if(W_trig && AWG_CH4_WAVENUM != 11'd0)
			begin
				R_NextState4	=	ST4_DELAY	;
			end
			else
			begin
				R_NextState4	=	ST4_WAIT	;
			end	
			
		end
		
		ST4_SYNC:
		begin
			if(R_cnt_sync4 >= 6'd40)
			begin
				R_NextState4	=	ST4_DELAY	;
			end
			else
			begin
				R_NextState4	=	ST4_SYNC	;
			end
		end

		ST4_DELAY:
		begin
			if(AWG_CH4_WAVENUM == R_COUNT_AWG_CH4)
				R_NextState4	=	ST4_DONE	;
			else
			begin	
				R_NextState4	=	ST4_DELAY	;
			end
		end
		
		ST4_DONE:
		begin
			R_NextState4	=	ST4_IDLE	;
		end
		
		
		
		default:	R_NextState4	=	ST4_IDLE	;
	endcase
end	


always @ (posedge I_clk_250mhz)
begin
	if(~I_rst_n)
	begin
		O_dac4_tx_id	<=	11'd0	;
		O_dac4_tx_ena	<=	1'd0	;

		R_cnt_delay4	<=	24'd0	;
		R_COUNT_AWG_CH4	<=	11'd0	;

		R_cnt_sync4		<=	5'd0	;		
	end

	else
	begin
		case(R_State4)
			ST4_IDLE:
			begin
				O_dac4_tx_id	<=	11'd0	;
				O_dac4_tx_ena	<=	1'd0	;

				R_cnt_delay4	<=	24'd0	;
				R_COUNT_AWG_CH4	<=	11'd0	;

				R_cnt_sync4		<=	5'd0	;
			end		
			
			ST4_WAIT:
			begin
				O_dac4_tx_id	<=	11'd0	;
				O_dac4_tx_ena	<=	1'd0	;

				R_cnt_delay4	<=	24'd0	;
				R_COUNT_AWG_CH4	<=	11'd0	;

				R_cnt_sync4		<=	5'd0	;
			end	
			
			ST4_SYNC:
			begin
				O_dac4_tx_id	<=	11'd0	;
				O_dac4_tx_ena	<=	1'd0	;

				R_cnt_delay4	<=	24'd0	;
				R_COUNT_AWG_CH4	<=	11'd0	;

				R_cnt_sync4		<=	R_cnt_sync4	+	5'd1	;
			end

			ST4_DELAY:
			begin
				R_cnt_delay4	<=	R_cnt_delay4 +	24'd1	;
				if(R_cnt_delay4 == I_dac4_tx_delay)
				begin
					O_dac4_tx_id	<=	O_dac4_tx_id	+ 11'd1	;
					O_dac4_tx_ena	<= 	1'b1					;
					R_COUNT_AWG_CH4 <=	R_COUNT_AWG_CH4 + 11'd1	;
				end
				else
				begin
					O_dac4_tx_id	<=	O_dac4_tx_id	;
					O_dac4_tx_ena	<=	1'b0			;
					R_COUNT_AWG_CH4	<=	R_COUNT_AWG_CH4	;
				end

				R_cnt_sync4		<=	5'd0	;
				
			end	
			
			
			ST4_DONE:
			begin
				O_dac4_tx_id	<=	11'd0	;
				O_dac4_tx_ena	<=	1'd0	;

				R_cnt_delay4	<=	24'd0	;
				R_COUNT_AWG_CH4	<=	11'd0	;

				R_cnt_sync4		<=	5'd0	;
			end	
						
			default:
			begin
				O_dac4_tx_id	<=	11'd0	;
				O_dac4_tx_ena	<=	1'd0	;

				R_cnt_delay4	<=	24'd0	;
				R_COUNT_AWG_CH4	<=	11'd0	;

				R_cnt_sync4		<=	5'd0	;

			end
		endcase
	end
end

	
	
endmodule
