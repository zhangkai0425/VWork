`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/12 19:06:35
// Design Name: 
// Module Name: LMK04610_CFG
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




module LMK04610_CFG1(
    input I_Clk	,
	input I_Rst_n	,
	input I_Trig	,
	
	output O_lmk_scsn,
	output O_lmk_scl,
	output O_lmk_sdio
	
);

reg O_lmk_scsn	;
reg O_lmk_scl		;
reg O_lmk_sdio		;


localparam [2:0] ST_IDLE = 3'd0;
localparam [2:0] ST_WAIT = 3'd1;
localparam [2:0] ST_TXDATA1 = 3'd2;
localparam [2:0] ST_TXDATA2 = 3'd3;
localparam [2:0] ST_TXBITDONE1 = 3'd4;
localparam [2:0] ST_TXBITDONE2 = 3'd5;
localparam [2:0] ST_DONE = 3'd6;

reg [2:0] R_State;
reg [2:0] R_NextState;
reg [7:0] R_Cnt_Reg;
reg [7:0] R_Cnt_Bit;
reg R_Trig;
reg R1_Trig;
reg[23:0] R_PLL_Data;

wire[7:0]	W_Cnt_Reg	;


wire W_trig;
wire W_Reg;

wire[23:0]	W_PLL_Data	;

assign W_Cnt_Reg = W_Reg?8'd242:1'b1	;
assign W_Reg = 1'b1;
assign W_PLL_Data = 24'h000000;

always @ (posedge I_Clk or negedge I_Rst_n) 
begin
    if(!I_Rst_n)
    begin
        R_State <= ST_IDLE;
		R_Trig	<= 1'b0;
		R1_Trig	<= 1'b0;
	end	
    else
    begin
        R_State <= R_NextState;
		R_Trig	<= I_Trig;
		R1_Trig <= R_Trig ;
	end	
end


assign W_trig = ~R1_Trig & R_Trig ;

always @ (*) 
begin
    case(R_State)
        ST_IDLE:
		begin
            R_NextState = ST_WAIT;
        end
        ST_WAIT:  
		begin
			if(W_trig)
			begin
				R_NextState = ST_TXDATA1;
			end
			else
			begin
				R_NextState = ST_WAIT;
			end
        end
        ST_TXDATA2:  
		begin
            if(R_Cnt_Bit == 8'd23)
		    begin
			    R_NextState = ST_TXBITDONE1;
			end
			else
			begin
				R_NextState = ST_TXDATA1;
			end
        end
		ST_TXDATA1:
		begin
            R_NextState = ST_TXDATA2;
        end
        ST_TXBITDONE1:
                begin
                    R_NextState = ST_TXBITDONE2;
                end
        ST_TXBITDONE2:      
        begin
             if(R_Cnt_Reg == W_Cnt_Reg)
             R_NextState = ST_DONE;
             else
             R_NextState = ST_TXDATA1;
        end
		ST_DONE:
		begin
            R_NextState = ST_IDLE;
        end
        default : R_NextState = ST_IDLE;
   endcase
end


always @ (posedge I_Clk or negedge I_Rst_n) 
begin
	if(!I_Rst_n)
	begin
		O_lmk_scl	<=	1'b0	;
		O_lmk_sdio<=	1'b0	;
		O_lmk_scsn	<=	1'b1	;
		R_Cnt_Bit	<=	8'd0	;
		R_Cnt_Reg	<=	8'd0	;
	end
	else
	begin
		case(R_State)
			ST_IDLE:
			begin
				O_lmk_scl	<=	1'b0	;
				O_lmk_sdio<=	1'b0	;
				O_lmk_scsn	<=	1'b1	;
				R_Cnt_Bit	<=	8'd0	;
				R_Cnt_Reg	<=	8'd0	;
			end
			ST_WAIT:
			begin
				O_lmk_scl	<=	1'b0	;
				O_lmk_sdio<=	1'b0	;
				O_lmk_scsn	<=	1'b1	;
				R_Cnt_Bit	<=	8'd0	;
				R_Cnt_Reg	<=	8'd0	;
			end
			ST_TXDATA2:
			begin
				if(R_Cnt_Bit < 8'd23)
				begin
					R_Cnt_Bit <= R_Cnt_Bit + 1'd1 ;
					R_Cnt_Reg <= R_Cnt_Reg ;
					O_lmk_scsn	<= 1'b0	;
					O_lmk_scl <= 1'b1 ;
					O_lmk_sdio <= R_PLL_Data[5'd23-R_Cnt_Bit];
				end
				else
				begin
					R_Cnt_Bit <= 1'd0;
					R_Cnt_Reg <= R_Cnt_Reg + 1'd1 ;
					O_lmk_scsn	<= 1'b0	;
					O_lmk_scl <= 1'b1 ;
					O_lmk_sdio <= R_PLL_Data[5'd23-R_Cnt_Bit];
				end	
			end
			ST_TXDATA1:
			begin
				O_lmk_scsn	<= 1'b0	;
				O_lmk_scl <= 1'b0 ;
				O_lmk_sdio <= R_PLL_Data[5'd23-R_Cnt_Bit];
			end
			ST_TXBITDONE1:
            begin
                O_lmk_scsn    <= 1'b0    ;
                O_lmk_scl <= 1'b0 ;
                O_lmk_sdio <= 1'b0;
                R_Cnt_Bit <= 1'd0;
            end
			ST_TXBITDONE2:
            begin
                 O_lmk_scsn    <= 1'b1    ;
                 O_lmk_scl <= 1'b0 ;
                 O_lmk_sdio <= 1'b0;
                 R_Cnt_Bit <= 1'd0;
            end
			ST_DONE:
			begin
				O_lmk_scsn	<= 1'b1	;
				O_lmk_scl <= 1'b0 ;
				O_lmk_sdio <= 1'b0;
				R_Cnt_Bit	<=	8'd0	;
				R_Cnt_Reg	<=	8'd0	;
			end
			default : 
			begin
				O_lmk_scsn	<= 1'b1	;
				O_lmk_scl <= 1'b0 ;
				O_lmk_sdio <= 1'b0;
				R_Cnt_Bit	<=	8'd0	;
				R_Cnt_Reg	<=	8'd0	;
			end	
		endcase
	end			
end			
			
always @ (posedge I_Clk)
begin  
	case (R_Cnt_Reg)
	8'd0:   R_PLL_Data <= W_PLL_Data;
	8'd1:	R_PLL_Data <= 24'h000000;
	8'd2:	R_PLL_Data <= 24'h000100;
	8'd3:	R_PLL_Data <= 24'h000200;
	8'd4:	R_PLL_Data <= 24'h000346;
	8'd5:	R_PLL_Data <= 24'h000438;
	8'd6:	R_PLL_Data <= 24'h000503;
	8'd7:	R_PLL_Data <= 24'h000611;
	8'd8:	R_PLL_Data <= 24'h000700;
	8'd9:	R_PLL_Data <= 24'h000800;
	8'd10:  R_PLL_Data <= 24'h000900;
	8'd11:  R_PLL_Data <= 24'h000A00;
	8'd12:  R_PLL_Data <= 24'h000B00;
	8'd13:  R_PLL_Data <= 24'h000C51;
	8'd14:  R_PLL_Data <= 24'h000D08;
	8'd15:  R_PLL_Data <= 24'h000E00;
	8'd16:  R_PLL_Data <= 24'h000F00;
	8'd17:  R_PLL_Data <= 24'h00101F;
	//8'd18:  R_PLL_Data <= 24'h001101;
	8'd19:  R_PLL_Data <= 24'h001204;
	8'd20:  R_PLL_Data <= 24'h001310;
	8'd21:  R_PLL_Data <= 24'h001480;
	8'd22:  R_PLL_Data <= 24'h001508;
	8'd23:  R_PLL_Data <= 24'h001650;
	8'd24:  R_PLL_Data <= 24'h001700;
	8'd25:  R_PLL_Data <= 24'h001800;
	//local
	8'd26:  R_PLL_Data <= 24'h001939;
	8'd27:  R_PLL_Data <= 24'h001A2A;
	//external
	//8'd26:  R_PLL_Data <= 24'h001929;
	//8'd27:  R_PLL_Data <= 24'h001A3A;

	8'd28:  R_PLL_Data <= 24'h001F00;
	8'd29:  R_PLL_Data <= 24'h002001;
	8'd30:  R_PLL_Data <= 24'h002100;
	8'd31:  R_PLL_Data <= 24'h002201;
	8'd32:  R_PLL_Data <= 24'h002714;
	8'd33:  R_PLL_Data <= 24'h002808;
	8'd34:  R_PLL_Data <= 24'h002914;
	8'd35:  R_PLL_Data <= 24'h002A08;
	8'd36:  R_PLL_Data <= 24'h002B00;
	//local
	8'd37:  R_PLL_Data <= 24'h002C40;
	//external
	//8'd37:  R_PLL_Data <= 24'h002C80;

	8'd38:  R_PLL_Data <= 24'h002D00;
	8'd39:  R_PLL_Data <= 24'h002E16;
	8'd40:  R_PLL_Data <= 24'h002F01;
	8'd41:  R_PLL_Data <= 24'h003001;
	8'd42:  R_PLL_Data <= 24'h00310C;
	8'd43:  R_PLL_Data <= 24'h003200;
	8'd44:  R_PLL_Data <= 24'h003300;
	8'd45:  R_PLL_Data <= 24'h003403;
	8'd46:  R_PLL_Data <= 24'h003500;
	8'd47:  R_PLL_Data <= 24'h003603;
	8'd48:  R_PLL_Data <= 24'h003700;
	8'd49:  R_PLL_Data <= 24'h003863;
	8'd50:  R_PLL_Data <= 24'h003900;
	8'd51:  R_PLL_Data <= 24'h003A03;
	8'd52:  R_PLL_Data <= 24'h003B00;
	8'd53:  R_PLL_Data <= 24'h003C03;
	8'd54:  R_PLL_Data <= 24'h003D18;
	8'd55:  R_PLL_Data <= 24'h003E03;
	8'd56:  R_PLL_Data <= 24'h003F00;
	8'd57:  R_PLL_Data <= 24'h004003;
	8'd58:  R_PLL_Data <= 24'h004118;
	8'd59:  R_PLL_Data <= 24'h004203;
	8'd60:  R_PLL_Data <= 24'h004300;
	8'd61:  R_PLL_Data <= 24'h004401;
	8'd62:  R_PLL_Data <= 24'h004500;
	8'd63:  R_PLL_Data <= 24'h004601;
	8'd64:  R_PLL_Data <= 24'h004700;
	8'd65:  R_PLL_Data <= 24'h00480A;
	8'd66:  R_PLL_Data <= 24'h004900;
	8'd67:  R_PLL_Data <= 24'h004A01;
	8'd68:  R_PLL_Data <= 24'h004B00;
	8'd69:  R_PLL_Data <= 24'h004C01;//
	8'd70:  R_PLL_Data <= 24'h004D00;
	8'd71:  R_PLL_Data <= 24'h004E14;
	8'd72:  R_PLL_Data <= 24'h004F00;
	8'd73:  R_PLL_Data <= 24'h005001;
	8'd74:  R_PLL_Data <= 24'h005100;
	8'd75:  R_PLL_Data <= 24'h005214;//50M
	8'd76:  R_PLL_Data <= 24'h005300;
	8'd77:  R_PLL_Data <= 24'h005410;
	8'd78:  R_PLL_Data <= 24'h005500;
	8'd79:  R_PLL_Data <= 24'h00560F;
	8'd80:  R_PLL_Data <= 24'h005710;//
	8'd81:  R_PLL_Data <= 24'h00583F;
	8'd82:  R_PLL_Data <= 24'h005961;
	8'd83:  R_PLL_Data <= 24'h005A0A;
	8'd84:  R_PLL_Data <= 24'h005B02;
	8'd85:  R_PLL_Data <= 24'h005CCA;
	8'd86:  R_PLL_Data <= 24'h005D00;
	8'd87:  R_PLL_Data <= 24'h005E00;
	8'd88:  R_PLL_Data <= 24'h005F61;
	8'd89:  R_PLL_Data <= 24'h0060A8;
	8'd90:  R_PLL_Data <= 24'h006100;
	8'd91:  R_PLL_Data <= 24'h00620C;
	8'd92:  R_PLL_Data <= 24'h006300;
	8'd93:  R_PLL_Data <= 24'h006440;
	8'd94:  R_PLL_Data <= 24'h006500;
	8'd95:  R_PLL_Data <= 24'h006600;
	8'd96:  R_PLL_Data <= 24'h006700;
	8'd97:  R_PLL_Data <= 24'h006800;
	8'd98:  R_PLL_Data <= 24'h006900;
	8'd99:  R_PLL_Data <= 24'h006A09;
	8'd100:  R_PLL_Data <= 24'h006B01;
	8'd101:  R_PLL_Data <= 24'h006C00;
	8'd102:  R_PLL_Data <= 24'h006D88;
	8'd103:  R_PLL_Data <= 24'h006E1B;
	8'd104:  R_PLL_Data <= 24'h006F00;
	8'd105:  R_PLL_Data <= 24'h007000;
	8'd106:  R_PLL_Data <= 24'h007100;
	8'd107:  R_PLL_Data <= 24'h00720C;
	8'd108:  R_PLL_Data <= 24'h007300;
	8'd109:  R_PLL_Data <= 24'h00740A;
	8'd110:  R_PLL_Data <= 24'h007500;
	8'd111:  R_PLL_Data <= 24'h007601;
	8'd112:  R_PLL_Data <= 24'h007701;
	8'd113:  R_PLL_Data <= 24'h0078FF;
	8'd114:  R_PLL_Data <= 24'h007900;
	8'd115:  R_PLL_Data <= 24'h007A86;
	8'd116:  R_PLL_Data <= 24'h007BA0;
	8'd117:  R_PLL_Data <= 24'h007C08;
	8'd118:  R_PLL_Data <= 24'h007D00;
	8'd119:  R_PLL_Data <= 24'h007E00;
	8'd120:  R_PLL_Data <= 24'h007F34;
	8'd121:  R_PLL_Data <= 24'h00800A;
	8'd122:  R_PLL_Data <= 24'h008100;
	8'd123:  R_PLL_Data <= 24'h008200;
	8'd124:  R_PLL_Data <= 24'h008300;
	8'd125:  R_PLL_Data <= 24'h00840F;
	8'd126:  R_PLL_Data <= 24'h008501;
	8'd127:  R_PLL_Data <= 24'h008601;
	8'd128:  R_PLL_Data <= 24'h008700;
	8'd129:  R_PLL_Data <= 24'h008840;
	8'd130:  R_PLL_Data <= 24'h008900;
	8'd131:  R_PLL_Data <= 24'h008A00;
	8'd132:  R_PLL_Data <= 24'h008B40;
	8'd133:  R_PLL_Data <= 24'h008C00;
	8'd134:  R_PLL_Data <= 24'h008D00;
	8'd135:  R_PLL_Data <= 24'h008E00;
	8'd136:  R_PLL_Data <= 24'h008F40;
	8'd137:  R_PLL_Data <= 24'h009000;
	8'd138:  R_PLL_Data <= 24'h009100;
	8'd139:  R_PLL_Data <= 24'h009280;
	8'd140:  R_PLL_Data <= 24'h009380;
	8'd141:  R_PLL_Data <= 24'h009402;
	8'd142:  R_PLL_Data <= 24'h009501;
	8'd143:  R_PLL_Data <= 24'h009610;
	8'd144:  R_PLL_Data <= 24'h009720;
	8'd145:  R_PLL_Data <= 24'h009820;
	8'd146:  R_PLL_Data <= 24'h009980;
	8'd147:  R_PLL_Data <= 24'h009B00;
	8'd148:  R_PLL_Data <= 24'h009C20;
	8'd149:  R_PLL_Data <= 24'h00AB00;
	8'd150:  R_PLL_Data <= 24'h00AC00;
	8'd151:  R_PLL_Data <= 24'h00AD00;
	8'd152:  R_PLL_Data <= 24'h00AF00;
	8'd153:  R_PLL_Data <= 24'h00B001;
	8'd154:  R_PLL_Data <= 24'h00BE03;
	8'd155:  R_PLL_Data <= 24'h00F600;
	8'd156:  R_PLL_Data <= 24'h00F700;
	8'd157:  R_PLL_Data <= 24'h00F907;
	8'd158:  R_PLL_Data <= 24'h00FAD7;
	8'd159:  R_PLL_Data <= 24'h00FC00;
	8'd160:  R_PLL_Data <= 24'h00FD00;
	8'd161:  R_PLL_Data <= 24'h00FE00;
	8'd162:  R_PLL_Data <= 24'h00FF00;
	8'd163:  R_PLL_Data <= 24'h010000;
	8'd164:  R_PLL_Data <= 24'h010100;
	8'd165:  R_PLL_Data <= 24'h010200;
	8'd166:  R_PLL_Data <= 24'h010300;
	8'd167:  R_PLL_Data <= 24'h010400;
	8'd168:  R_PLL_Data <= 24'h010500;
	8'd169:  R_PLL_Data <= 24'h010600;
	8'd170:  R_PLL_Data <= 24'h010700;
	8'd171:  R_PLL_Data <= 24'h010800;
	8'd172:  R_PLL_Data <= 24'h010900;
	8'd173:  R_PLL_Data <= 24'h010A00;
	8'd174:  R_PLL_Data <= 24'h010B00;
	8'd175:  R_PLL_Data <= 24'h010D00;
	8'd176:  R_PLL_Data <= 24'h010E00;
	8'd177:  R_PLL_Data <= 24'h011000;
	8'd178:  R_PLL_Data <= 24'h011100;
	8'd179:  R_PLL_Data <= 24'h011200;
	8'd180:  R_PLL_Data <= 24'h011500;
	8'd181:  R_PLL_Data <= 24'h011600;
	8'd182:  R_PLL_Data <= 24'h011700;
	8'd183:  R_PLL_Data <= 24'h011900;
	8'd184:  R_PLL_Data <= 24'h011A00;
	8'd185:  R_PLL_Data <= 24'h012408;
	8'd186:  R_PLL_Data <= 24'h012700;
	8'd187:  R_PLL_Data <= 24'h012800;
	8'd188:  R_PLL_Data <= 24'h012900;
	8'd189:  R_PLL_Data <= 24'h012A00;
	8'd190:  R_PLL_Data <= 24'h012B00;
	8'd191:  R_PLL_Data <= 24'h012C04;
	8'd192:  R_PLL_Data <= 24'h012D04;
	8'd193:  R_PLL_Data <= 24'h012E00;
	8'd194:  R_PLL_Data <= 24'h013005;
	8'd195:  R_PLL_Data <= 24'h013105;
	8'd196:  R_PLL_Data <= 24'h013305;
	8'd197:  R_PLL_Data <= 24'h013405;
	8'd198:  R_PLL_Data <= 24'h013505;
	8'd199:  R_PLL_Data <= 24'h013805;
	8'd200:  R_PLL_Data <= 24'h013905;
	8'd201:  R_PLL_Data <= 24'h013A05;
	8'd202:  R_PLL_Data <= 24'h013C05;
	8'd203:  R_PLL_Data <= 24'h013D05;
	8'd204:  R_PLL_Data <= 24'h01400A;
	8'd205:  R_PLL_Data <= 24'h014109;
	8'd206:  R_PLL_Data <= 24'h014240;
	8'd207:  R_PLL_Data <= 24'h014300;
	8'd208:  R_PLL_Data <= 24'h014500;
	8'd209:  R_PLL_Data <= 24'h01463C;
	8'd210:  R_PLL_Data <= 24'h014900;
	8'd211:  R_PLL_Data <= 24'h014A00;
	8'd212:  R_PLL_Data <= 24'h014B00;
	8'd213:  R_PLL_Data <= 24'h014C00;
	8'd214:  R_PLL_Data <= 24'h014E00;
	8'd215:  R_PLL_Data <= 24'h015000;
	8'd216:  R_PLL_Data <= 24'h015114;
	8'd217:  R_PLL_Data <= 24'h01520F;
	8'd218:  R_PLL_Data <= 24'h015300;
	8'd219:  R_PLL_Data <= 24'h001101;
	8'd220:  R_PLL_Data <= 24'h00_AD_30;
	8'd221:  R_PLL_Data <= 24'h00_00_00;
	8'd241:  R_PLL_Data <= 24'h00_AD_00;
	
	default : R_PLL_Data <= 24'h00_00_00;
//	
//	

	// 8'd32:  R_PLL_Data <= 24'h00_2c_80;
	// 8'd38:  R_PLL_Data <= 24'h00_76_01;
	// 8'd39:  R_PLL_Data <= 24'h00_77_01;
	// 8'd40:  R_PLL_Data <= 24'h00_80_0a;
	// 8'd41:  R_PLL_Data <= 24'h00_9c_20;
	// 8'd42:  R_PLL_Data <= 24'h00_be_03;
	// 8'd43:  R_PLL_Data <= 24'h01_24_08;
	// 8'd44:  R_PLL_Data <= 24'h01_27_40;
	// 8'd45:  R_PLL_Data <= 24'h01_28_01;
	// 8'd46:  R_PLL_Data <= 24'h01_29_05;
	// 8'd47:  R_PLL_Data <= 24'h01_2a_01;
	// 8'd48:  R_PLL_Data <= 24'h01_2b_04;
	// 8'd49:  R_PLL_Data <= 24'h01_2c_05;
	// 8'd50:  R_PLL_Data <= 24'h01_2d_04;	
	// 8'd51:  R_PLL_Data <= 24'h01_2e_01;
	// 8'd52:  R_PLL_Data <= 24'h01_51_14;		
	// 8'd53:  R_PLL_Data <= 24'h00_11_01;

//    8'd26:  R_PLL_Data <= 32'h11_11_11_11;
//    8'd27:  R_PLL_Data <= 32'h11_11_11_11;
//    8'd28:  R_PLL_Data <= 32'h11_11_11_11;
//    8'd29:  R_PLL_Data <= 32'h11_11_11_11;
//    8'd30:  R_PLL_Data <= 32'h11_11_11_11;
//    8'd31:  R_PLL_Data <= 32'h11_11_11_11;
//    8'd32:  R_PLL_Data <= 32'h11_11_11_11;
	endcase
end


/*vio_reg_state vio_pll (
  .clk(I_Clk),                // input wire clk
  .probe_out0(W_Reg),  // output wire [0 : 0] probe_out0
  .probe_out1(W_PLL_Data)
);*/



endmodule