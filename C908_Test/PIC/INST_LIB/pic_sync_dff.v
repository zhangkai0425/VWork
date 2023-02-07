// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : pic_sync_dff.v
// AUTHOR          : xiaty 
// ORIGINAL DATE   : 2021-8-13
// FUNCTION        : Sync signal in domain 1 to domain 2.
// ******************************************************************************

module pic_sync_dff (
  clk,
  rst_b,
  sync_in,
  sync_out
);
//RELEASE_INST_LIB

parameter FLOP_NUM     = 3;

input          clk;
input          rst_b;
input          sync_in;
output         sync_out;

reg   [FLOP_NUM-1:0]  sync_ff;

wire           clk;
wire           rst_b;
wire           sync_in;
wire           sync_out;

always @ (posedge clk or negedge rst_b)
begin
  if (~rst_b)
    sync_ff[FLOP_NUM-1:0] <= {FLOP_NUM{1'b0}};
  else
    sync_ff[FLOP_NUM-1:0] <= {sync_ff[FLOP_NUM-2:0],sync_in};
end

assign sync_out = sync_ff[FLOP_NUM-1];

endmodule

