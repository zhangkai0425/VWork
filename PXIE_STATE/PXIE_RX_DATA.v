`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2020/05/28 10:43:47
// Design Name:
// Module Name: PXIE_RX_DATA
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


module PXIE_RX_DATA(
	input			I_PXIE_CLK	,
	input[127:0]	I_PXIE_DATA	,
	input			I_PXIE_DATA_VLD	,
	input			I_Rst_n	,
	input			I_CLK_10MHz,
	input			I_CLK_125MHz,
	output			O_Rst	,
	output 			O_Rst_125MHz,
	output			O_Trig	,
	output[31:0]	O_Trig_Num	,
	output[31:0]	O_Trig_Step ,
	//
	output 			O_run,
	output[15:0] 	O_isa_Num ,
	output[31:0] 	O_isa_addr,
	output[127:0] 	O_isa_data,
	output 			O_isa_wren,

	output[15:0] 	O_sys_Num ,
	output[31:0] 	O_sys_addr,
	output[127:0] 	O_sys_data,
	output 			O_sys_wren,

	output[15:0] 	O_c2h_addr,
	output[15:0] 	O_c2h_len,
	output		 	O_c2h_en
    );

// 有限状态机,通读可以知道哪一部分是对应的什么数据

parameter [8:0]	ST_IDLE		= 9'b0_0000_0000;
parameter [8:0]	ST_HEAD		= 9'b0_0000_0001;
parameter [8:0]	ST_RST	    = 9'b0_0000_0010;
parameter [8:0]	ST_TRIG	    = 9'b0_0000_0100;
parameter [8:0] ST_ISA 		= 9'b0_0000_1000;
parameter [8:0] ST_ISA_run  = 9'b0_0001_0000;
parameter [8:0] ST_SRAM 	= 9'b0_0010_0000;
parameter [8:0]	ST_READCFG 	= 9'b0_0100_0000;
parameter [8:0]	ST_DONE	    = 9'b0_1000_0000;








reg[8:0]	R_State				;
reg[8:0]	R_NextState			;
reg[127:0]	R1_PXIE_DATA		;
reg[127:0]	R_PXIE_DATA			;
reg			R1_PXIE_DATA_VLD	;
reg			R_PXIE_DATA_VLD		;


reg			R_Rst				;
reg			R1_Rst				;
reg			R2_Rst				;
reg			R1_Rst_125MHz		;
reg			R2_Rst_125MHz		;

reg			R_Trig				;
reg			R1_Trig				;
reg			R2_Trig				;
reg 		R1_run 				;
reg 		R2_run 				;
reg[5:0]	R_Rst_Cnt			;
reg[5:0]	R_Trig_Cnt			;
reg[5:0] 	isa_run_cnt 		;

reg 		R_run 				;
reg[31:0]	O_Trig_Num			;
reg[31:0]	O_Trig_Step			;

reg[31:0] 	R_ISA_Num 			;
reg[31:0] 	R_ISA_Cnt 			;
reg[31:0]   isa_ram_addr 		;
reg  		isa_ram_wren 		;
reg[63:0] 	isa_ram_data 		;

reg[31:0] 	R_SRAM_Num 			;
reg[31:0] 	R_SRAM_Cnt 			;
reg[31:0] 	sys_ram_addr 		;
reg  		sys_ram_wren 		;
reg[63:0] 	sys_ram_data 		;

reg[15:0] 	c2h_addr;
reg[15:0] 	c2h_len;
reg 		c2h_en;

//*****************************************PXIE data to fifo****************125M TO 250M***********************


always @ (posedge I_PXIE_CLK or negedge I_Rst_n)
begin
	if(~I_Rst_n)
	begin
		R_State	<=	ST_IDLE	;
		R_PXIE_DATA	<=	128'd0	;
		R1_PXIE_DATA	<=	128'd0	;
		R_PXIE_DATA_VLD	<=	1'b0	;
		R1_PXIE_DATA_VLD	<=	1'b0	;
	end
	else
	begin
		R_State	<=	R_NextState	;
		R_PXIE_DATA	<=	I_PXIE_DATA	;
		R1_PXIE_DATA	<=	R_PXIE_DATA	;
		R_PXIE_DATA_VLD	<=	I_PXIE_DATA_VLD	;
		R1_PXIE_DATA_VLD	<=	R_PXIE_DATA_VLD	;
	end
end


always @(*)
begin
	case(R_State)
		ST_IDLE:
		begin
			R_NextState	=	ST_HEAD	;
		end


		ST_HEAD:
		begin
			if((I_PXIE_DATA[63:48] == 16'heb9c)&&(I_PXIE_DATA[15:0] == 16'h0001)&&(I_PXIE_DATA_VLD))
			begin
				R_NextState	=	ST_RST	;
			end
			else if((I_PXIE_DATA[63:48] == 16'heb9c)&&(I_PXIE_DATA[15:0] == 16'h0002)&&(I_PXIE_DATA_VLD))
			begin
				R_NextState	=	ST_TRIG	;
			end
			else if((I_PXIE_DATA[63:48] == 16'heb9c)&&(I_PXIE_DATA[15:0] == 16'h1000)&&(I_PXIE_DATA_VLD))
			begin
				R_NextState	=	ST_ISA	;
			end
			else if((I_PXIE_DATA[63:48] == 16'heb9c)&&(I_PXIE_DATA[15:0] == 16'h1001)&&(I_PXIE_DATA_VLD))
			begin
				R_NextState	=	ST_SRAM	;
			end
			else if((I_PXIE_DATA[63:48] == 16'heb9c)&&(I_PXIE_DATA[15:0] == 16'h1100)&&(I_PXIE_DATA_VLD))
			begin
				R_NextState	=	ST_ISA_run	;
			end
			else if((I_PXIE_DATA[63:48] == 16'heb9c)&&(I_PXIE_DATA[15:0] == 16'h1010)&&(I_PXIE_DATA_VLD))
			begin
				R_NextState = 	ST_READCFG ;
			end
			else
			begin
				R_NextState	=	ST_HEAD		;
			end
		end

		ST_RST:
		begin
			if(R_Rst_Cnt == 6'd50)
			begin
				R_NextState	=	ST_DONE	;
			end
			else
				R_NextState	= ST_RST	;
		end

		ST_TRIG:
		begin
			if(R_Trig_Cnt == 6'd50)
			begin
				R_NextState	=	ST_DONE	;
			end
			else
				R_NextState	= ST_TRIG	;
		end

		ST_ISA:
		begin
			if(R_ISA_Cnt == R_ISA_Num)
			begin
				R_NextState = ST_DONE;
			end else
				R_NextState = ST_ISA;
		end

		ST_SRAM:
		begin
			if(R_SRAM_Cnt == R_SRAM_Num)
			begin
				R_NextState = ST_DONE;
			end else
				R_NextState = ST_SRAM;
		end

		ST_ISA_run:
		begin
			R_NextState	=	ST_DONE	;
		end

		ST_READCFG:
		begin
			R_NextState	=	ST_DONE	;
		end

		ST_DONE:
		begin
			R_NextState	=	ST_IDLE	;
		end

		default:	R_NextState	=	ST_IDLE	;
	endcase
end


always	@ (posedge I_PXIE_CLK or negedge I_Rst_n)
begin
	if(~I_Rst_n)
	begin
		R_Rst		<=	1'b0	;
		R_Trig		<=	1'b0	;
		R_Rst_Cnt	<=	6'd0	;
		R_Trig_Cnt	<=	6'd0	;
		isa_run_cnt <=  6'b0 	;
		O_Trig_Num	<=	32'd0	;
		O_Trig_Step	<=	32'd0	;
		R_ISA_Num 	<=  16'd0 	;
		R_SRAM_Num 	<=  16'd0 	;
		isa_ram_addr<=  32'd0 	;
		sys_ram_addr<=  32'd0 	;
		R_run 		<=  1'b0 	;
		c2h_addr 	<= 	16'h0;
		c2h_len 	<= 	16'h0;
		c2h_en 		<= 	1'b0;
	end
	else
	begin
		case(R_State)
			ST_IDLE:
			begin
				R_Rst		<=	1'b0	;
				R_Trig		<=	1'b0	;
				R_Rst_Cnt	<=	6'd0	;
				R_Trig_Cnt	<=	6'd0	;
				isa_run_cnt <=  6'b0 	;
				R_run 		<=  1'b0 	;
				c2h_addr 	<= 	c2h_addr;
				c2h_len 	<= 	c2h_len;
				c2h_en 		<= 	1'b0;
				O_Trig_Num	<=	O_Trig_Num	;
				O_Trig_Step	<=	O_Trig_Step	;
				isa_ram_addr<=  isa_ram_addr;
				sys_ram_addr<=  sys_ram_addr;
				R_ISA_Num   <=  R_ISA_Num;
				R_SRAM_Num 	<=  R_SRAM_Num;
			end

			ST_HEAD:
			begin
				if((I_PXIE_DATA[63:48] == 16'heb9c)&&(I_PXIE_DATA[47:32] == 16'h0003)&&(I_PXIE_DATA_VLD))
				begin
					O_Trig_Num  <= I_PXIE_DATA[31:0]	;
				end
				else if((I_PXIE_DATA[63:48] == 16'heb9c)&&(I_PXIE_DATA[47:32] == 16'h0004)&&(I_PXIE_DATA_VLD))
				begin
					O_Trig_Step <= I_PXIE_DATA[31:0]	;
				end
				else if((I_PXIE_DATA[63:48] == 16'heb00)&&(I_PXIE_DATA_VLD))
				begin
					isa_ram_addr <= I_PXIE_DATA[31:0]	;
					R_ISA_Num    <= I_PXIE_DATA[47:32]	;
				end
				else if((I_PXIE_DATA[63:48] == 16'heb01)&&(I_PXIE_DATA_VLD))
				begin
					sys_ram_addr <= I_PXIE_DATA[31:0]	;
					R_SRAM_Num    <= I_PXIE_DATA[47:32]	;
				end
				else if((I_PXIE_DATA[63:48] == 16'heb02)&&(I_PXIE_DATA_VLD))
				begin
					c2h_addr 	<= 	I_PXIE_DATA[15:0];
					c2h_len 	<= 	I_PXIE_DATA[31:16];
				end
				else
				begin
					c2h_addr 	<= 	c2h_addr;
					c2h_len 	<= 	c2h_len;
					O_Trig_Num	<=	O_Trig_Num	;
					O_Trig_Step	<=	O_Trig_Step	;
				end
			end


			ST_RST:
			begin
				R_Rst	<=	1'b1	;
				if(R_Rst_Cnt < 6'd50)
				begin
					R_Rst_Cnt	<=	R_Rst_Cnt	+ 	1'b1	;
				end
				else
				begin
					R_Rst_Cnt	<=	R_Rst_Cnt	;
				end
			end

			ST_TRIG:
			begin
				R_Trig	<=	1'b1	;
				O_Trig_Num	<=	O_Trig_Num	;
				O_Trig_Step	<=	O_Trig_Step	;
				if(R_Trig_Cnt < 6'd50)
				begin
					R_Trig_Cnt	<=	R_Trig_Cnt	+ 	1'b1	;
				end
				else
				begin
					R_Trig_Cnt	<=	R_Trig_Cnt	;
				end
			end

			ST_ISA:
			begin
				if (I_PXIE_DATA_VLD)
				begin
					isa_ram_wren <= 1'b1;
					isa_ram_data <= I_PXIE_DATA;
					R_ISA_Cnt 	 <= R_ISA_Cnt + 1'b1;
					isa_ram_addr <= isa_ram_addr + 2'b10;
				end else begin
					isa_ram_wren <= 1'b0;
					isa_ram_data <= 64'h0;
					R_ISA_Cnt 	 <= R_ISA_Cnt;
					isa_ram_addr <= isa_ram_addr;
				end
			end

			ST_SRAM:
			begin
				if (I_PXIE_DATA_VLD)
				begin
					sys_ram_wren <= 1'b1;
					sys_ram_data <= I_PXIE_DATA;
					R_SRAM_Cnt 	 <= R_SRAM_Cnt + 1'b1;
					sys_ram_addr <= sys_ram_addr + 2'b10;
				end else begin
					sys_ram_wren <= 1'b0;
					sys_ram_data <= 64'h0;
					R_SRAM_Cnt 	 <= R_SRAM_Cnt;
					sys_ram_addr <= sys_ram_addr;
				end
			end

			ST_ISA_run:
			begin
				R_run 		<=  1'b1 	;
				if(isa_run_cnt < 6'd50)
				begin
					isa_run_cnt	<=	isa_run_cnt	+ 	1'b1	;
				end
				else
				begin
					isa_run_cnt	<=	isa_run_cnt	;
				end
			end

			ST_READCFG:
			begin
				c2h_en 		<= 	1'b1;
			end
			ST_DONE:
			begin
				R_Rst		<=	1'b0	;
				R_Trig		<=	1'b0	;
				R_run 		<=  1'b0 	;
				R_Rst_Cnt	<=	6'd0	;
                R_Trig_Cnt	<=	6'd0	;
                isa_run_cnt <=  6'b0 	;
                R_ISA_Cnt   <=  32'd0 	;
                R_SRAM_Cnt 	<=  32'd0 	;
				O_Trig_Num	<=	O_Trig_Num	;
				O_Trig_Step	<=	O_Trig_Step	;
				c2h_addr 	<= 	c2h_addr;
				c2h_len 	<= 	c2h_len;
				c2h_en 		<= 	1'b0;
			end

			default:
			begin
				R_Rst		<=	1'b0	;
				R_Trig		<=	1'b0	;
				R_run 		<=  1'b0 	;
				R_Rst_Cnt	<=	6'd0	;
				isa_run_cnt <=  6'b0 	;
                R_Trig_Cnt	<=	6'd0	;
                R_SRAM_Cnt 	<=  32'd0 	;
				O_Trig_Num	<=	O_Trig_Num	;
				O_Trig_Step	<=	O_Trig_Step	;
				c2h_addr 	<= 	c2h_addr;
				c2h_len 	<= 	c2h_len;
				c2h_en 		<= 	1'b0;
			end
		endcase
	end
end



always @ (posedge I_CLK_10MHz or negedge I_Rst_n)
begin
	if(~I_Rst_n)
	begin
		R1_Rst	<=	1'b0	;
		R2_Rst	<=	1'b0	;
	end
	else
	begin
		R1_Rst	<=	R_Rst	;
		R2_Rst	<=	R1_Rst	;
	end
end

// pulse_syn_fast2s pulse_syn_fast2s_inst(
//     .rstn           (I_Rst_n),
//     .clk_fast       (I_PXIE_CLK),
//     .pulse_fast     (R_Rst),
//     .clk_slow       (I_CLK_10mhz),
//     .pulse_slow     (O_Rst)
// 	);

always @ (posedge I_CLK_125MHz or negedge I_Rst_n)
begin
	if(~I_Rst_n)
	begin
		R1_Trig	<=	1'b0	;
		R2_Trig	<=	1'b0	;
		R1_run  <=  1'b0 	;
		R2_run  <=  1'b0 	;
		R1_Rst_125MHz	<=	1'b0	;
		R2_Rst_125MHz	<=	1'b0	;
	end
	else
	begin
		R1_Trig	<=	R_Trig	;
		R2_Trig	<=	R1_Trig	;
		R1_run  <=  R_run 	;
		R2_run 	<= 	R1_run 	;
		R1_Rst_125MHz	<=	R_Rst	;
		R2_Rst_125MHz	<=	R1_Rst_125MHz	;
	end
end


assign O_run 		=   1'b0 	; //R1_run
// assign O_run 		=   R1_run && ~R2_run 	;
assign O_Rst		=	R1_Rst && ~R2_Rst	;
assign O_Rst_125MHz	=	R1_Rst_125MHz && ~R2_Rst_125MHz	;
// assign O_Rst        =   R2_Rst;
assign O_Trig		=   R1_Trig && ~R2_Trig	;
assign O_isa_Num 	= 	R_ISA_Num;
assign O_isa_addr	= 	isa_ram_addr - 2'b10;
assign O_isa_data 	= 	isa_ram_data;
assign O_isa_wren 	= 	isa_ram_wren;

assign O_sys_Num 	= 	R_SRAM_Num;
assign O_sys_addr	= 	sys_ram_addr - 2'b10;
assign O_sys_data 	= 	sys_ram_data;
assign O_sys_wren 	= 	sys_ram_wren;

assign O_c2h_addr 	= 	c2h_addr;
assign O_c2h_len 	= 	c2h_len;
assign O_c2h_en 	= 	c2h_en;


endmodule
