`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2022/06/21 14:14:05
// Design Name:
// Module Name: qubit_state1_cnt
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


module qubit_state1_cnt(
    input 			clk,
    input 			rstn,
    input   		data_en,
(*mark_debug="true"*)    input	signed [31:0]  Idata,
(*mark_debug="true"*)    input   signed [31:0]  Qdata,
    input   signed [31:0] I0,
    input   signed [31:0] Q0,
    input   signed [31:0] I1,
    input   signed [31:0] Q1,

(*mark_debug="true"*)    output  reg valid,
(*mark_debug="true"*)    output  reg qstate
    );


(*mark_debug="true"*)reg signed [32:0]  d0_x;
(*mark_debug="true"*)reg signed [32:0]  d0_y;
(*mark_debug="true"*)reg signed [32:0]  d1_x;
(*mark_debug="true"*)reg signed [32:0]  d1_y;
wire [65:0]  d0_xx;
wire [65:0]  d0_yy;
wire [65:0]  d1_xx;
wire [65:0]  d1_yy;

(*mark_debug="true"*)reg signed [66:0]  d0;
(*mark_debug="true"*)reg signed [66:0]  d1;
(*mark_debug="true"*)wire signed [66:0]  d;
reg [3:0] 	cnt;
(*mark_debug="true"*) reg [2:0] 	state_disc;

parameter 	st_idle = 3'b000,
			st_wait  = 3'b001,
			st_disc = 3'b010,
			st_done = 3'b100;

always @(posedge clk or negedge rstn) begin
	if (!rstn) begin
		valid 	<= 1'b0;
		qstate 	<= 1'b0;
		d0 		<= 67'h0;
		d1 		<= 67'h0;
		cnt 	<= 3'b0;
		state_disc 	<= st_idle;
	end
	else begin
		case (state_disc)
		st_idle:begin
			d0 		<= 67'h0;
			d1 		<= 67'h0;
			valid 	<= 1'b0;
			qstate 	<= 1'b0;
			cnt 	<= 3'b0;
			if (data_en) begin
				state_disc 	<= st_wait;
			end else begin
				state_disc 	<= st_idle;
			end
		end
		st_wait:begin
			cnt <= cnt + 1'b1;
			if (cnt == 3'b111) begin
				d0 <= d0_xx + d0_yy;
				d1 <= d1_xx + d1_yy;
				state_disc 	<= st_disc;
				cnt <= 3'b0;
			end else begin
				state_disc 	<= st_wait;
			end
		end
		st_disc:begin
			state_disc 	<= st_done;
		end
		st_done:begin
			qstate <= d[66];
			valid <= 1'b1;
			state_disc 	<= st_idle;
		end
		default:begin
			d0 		<= 67'h0;
			d1 		<= 67'h0;
			valid 	<= 1'b0;
			qstate 	<= 1'b0;
			cnt 	<= 3'b0;
			state_disc 	<= st_idle;
		end
		endcase
		end
end


c_addsub_0 c_addsub_0_inst (
    .A (d1),//: IN STD_LOGIC_VECTOR(66 DOWNTO 0);
    .B (d0),// : IN STD_LOGIC_VECTOR(66 DOWNTO 0);
    .CLK (clk),// : IN STD_LOGIC;
    .CE (1'b1),// : IN STD_LOGIC;
    .S (d)// : OUT STD_LOGIC_VECTOR(66 DOWNTO 0)
  );

always @(posedge clk or negedge rstn) begin
	if (!rstn) begin
		d0_x 	<= 33'h0;
		d0_y 	<= 33'h0;
		d1_x 	<= 33'h0;
		d1_y 	<= 33'h0;
	end else begin
		if (data_en) begin
			d0_x <= Idata + I0;
			d0_y <= Qdata + Q0;
			d1_x <= Idata + I1;
			d1_y <= Qdata + Q1;
		end else begin
			d0_x <= d0_x;
			d0_y <= d0_y;
			d1_x <= d1_x;
			d1_y <= d1_y;
		end
	end
end

mult_gen_0 mult_gen_x_0(
    .CLK 	(clk),
    .A  	(d0_x),
    .B 		(d0_x),
    .P  	(d0_xx)
  );
mult_gen_0 mult_gen_y_0(
    .CLK 	(clk),
    .A  	(d0_y),
    .B 		(d0_y),
    .P  	(d0_yy)
  );
mult_gen_0 mult_gen_x_1(
    .CLK 	(clk),
    .A  	(d1_x),
    .B 		(d1_x),
    .P  	(d1_xx)
  );
mult_gen_0 mult_gen_y_1(
    .CLK 	(clk),
    .A  	(d1_y),
    .B 		(d1_y),
    .P  	(d1_yy)
  );
endmodule
