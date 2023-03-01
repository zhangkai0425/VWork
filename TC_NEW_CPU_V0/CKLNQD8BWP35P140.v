`timescale 1ns/1ps
module CKLNQD8BWP35P140 (Q, E, TE, CP);
output Q;
input  E, TE, CP;
//synopsys translate_off

//simulation model for smic11
//it will be discarded during synthsis
reg clk_en_af_latch;
always @(CP or E)
begin
  if(!CP)
    clk_en_af_latch <= E;
end

reg clk_en ;
always @ (TE or clk_en_af_latch )
begin
    clk_en <= clk_en_af_latch || TE ;
end
assign Q = CP && clk_en ;


//synopsys translate_on

endmodule //TLATNTSCAX8MTR
