`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2020/07/23 10:38:47
// Design Name:
// Module Name: Trig_Gen_Mdl
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


module Trig_Gen_Mdl(


	input[31:0]	I_Trig_Num	,
	input[31:0]	I_Trig_Step	,
	input	I_clk_100mhz	,
	input	I_Rst_n	,
	input	I_Trig_in	,
	output  O_Trig

    );


parameter [3:0]	ST_IDLE		= 4'd0	;
parameter [3:0]	ST_WAIT		= 4'd1	;
parameter [3:0] ST_WAIT1 	= 4'd2 	;
parameter [3:0]	ST_TRIG		= 4'd3	;
parameter [3:0]	ST_CYCLE	= 4'd4	;
parameter [3:0]	ST_DONE		= 4'd5	;




reg[3:0]	R_State				;
reg[3:0]	R_NextState			;

reg[31:0]	R_Trig_Num			;
reg[31:0]	R_Trig_Step			;

reg[31:0]	Cnt_Num				;
reg[31:0]	Cnt_Step			;


reg 	R_Trig		;


always @ (posedge I_clk_100mhz or negedge I_Rst_n)
begin
	if(~I_Rst_n)
	begin
		R_State	<=	ST_IDLE	;
		R_Trig_Num	<=	32'd0	;
		R_Trig_Step	<=	32'd0	;
	end
	else
	begin
		R_State	<=	R_NextState	;
		R_Trig_Num	<=	I_Trig_Num	;
		R_Trig_Step	<=	I_Trig_Step	;
	end
end






always @(*)
begin
	case(R_State)
		ST_IDLE:
		begin
			R_NextState	=	ST_WAIT	;
		end

		ST_WAIT:
		begin
			if(I_Trig_in)
			begin
				R_NextState = ST_WAIT1	;
			end
			else
			begin
				R_NextState = ST_WAIT	;
			end
		end


		ST_WAIT1:
		begin
			if(Cnt_Step == 32'h0001_0000)
			begin
				R_NextState = ST_TRIG ;
			end
			else
			begin
				R_NextState = ST_WAIT1 ;
			end
		end

		ST_TRIG:
		begin
			if(Cnt_Step == (R_Trig_Step-2'd2))
			begin
				R_NextState	=	ST_CYCLE	;
			end
			else
			begin
				R_NextState	=	ST_TRIG	;
			end
		end


		ST_CYCLE:
		begin
			if(Cnt_Num >= R_Trig_Num)
			begin
				R_NextState	=	ST_DONE	;
			end
			else
			begin
				R_NextState = ST_TRIG;
			end
		end


		ST_DONE:
		begin
			R_NextState	=	ST_IDLE	;
		end

		default:	R_NextState	=	ST_IDLE	;
	endcase
end


always	@ (posedge I_clk_100mhz or negedge I_Rst_n)
begin
	if(~I_Rst_n)
	begin
		R_Trig	<=	1'b0		;
		Cnt_Step	<=	32'd0	;
		Cnt_Num	<=	32'd0		;

	end
	else
	begin
		case(R_State)
			ST_IDLE:
			begin
				R_Trig	<=	1'b0		;
				Cnt_Step	<=	32'd0	;
				Cnt_Num	<=	32'd0		;
			end
			ST_WAIT:
			begin
				R_Trig	<=	1'b0		;
				Cnt_Step	<=	32'd0	;
				Cnt_Num	<=	32'd0		;
			end
			ST_WAIT1:
			begin
				R_Trig	<=	1'b0		;
				if(Cnt_Step < 32'h0001_0000)
				begin
					Cnt_Step	<=	Cnt_Step + 1'b1	;
				end else begin
					Cnt_Step 	<=  32'h0;
				end
				Cnt_Num	<=	32'd0		;
			end
			ST_TRIG:
			begin
				if(Cnt_Step <= 32'd23)
				begin
					R_Trig	<=	1'b1	;
					Cnt_Step	<=	Cnt_Step + 1'b1	;
					Cnt_Num		<=	Cnt_Num	;
				end
				else if(Cnt_Step == 32'd24)
				begin
					Cnt_Num		<=	Cnt_Num	+ 1'b1;
					R_Trig	<=	1'b0	;
					Cnt_Step	<=	Cnt_Step + 1'b1	;
				end
				else
				begin
                	R_Trig	<=	1'b0	;
					Cnt_Step	<=	Cnt_Step + 1'b1	;
					Cnt_Num		<=	Cnt_Num	;
				end
			end

			ST_CYCLE:
			begin
				R_Trig	<=	1'b0	;
				Cnt_Step	<=	32'd0	;
				Cnt_Num		<=	Cnt_Num	;
			end


			ST_DONE:
			begin
				R_Trig	<=	1'b0		;
				Cnt_Step	<=	32'd0	;
				Cnt_Num	<=	32'd0		;

			end

			default:
			begin
				R_Trig	<=	1'b0		;
				Cnt_Step	<=	32'd0	;
				Cnt_Num	<=	32'd0		;

			end
		endcase
	end
end

assign O_Trig	=	R_Trig	;

ila_1 ila_trig (
	.clk(I_clk_100mhz), // input wire clk


	.probe0(I_Trig_Num), // input wire [31:0]  probe0  
	.probe1(I_Trig_Step), // input wire [31:0]  probe1 
	.probe2(I_Trig_in), // input wire [0:0]  probe2 
	.probe3(O_Trig), // input wire [0:0]  probe3 
	.probe4(R_State), // input wire [3:0]  probe4 
	.probe5(R_Trig_Num), // input wire [31:0]  probe5 
	.probe6(R_Trig_Step) // input wire [31:0]  probe6
);

endmodule
