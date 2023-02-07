// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : tdt_dmi_sync_dff.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-6
// FUNCTION        : tdt_dmi_sync_dff.v
// ******************************************************************************

module tdt_dmi_sync_dff #(
    parameter    SYNC_NUM = 3
)(
    input        dst_clk,
    input        dst_rst_b,
    input        src_in,
    output       dst_out
);
//RELEASE_INST_LIB

reg  [SYNC_NUM-1:0] sync_ff;

always @ (posedge dst_clk or negedge dst_rst_b) begin
    if (~dst_rst_b)
        sync_ff[SYNC_NUM-1:0] <= {SYNC_NUM{1'b0}};
    else 
        sync_ff[SYNC_NUM-1:0] <= {sync_ff[SYNC_NUM-2:0], src_in};
end

assign dst_out = sync_ff[SYNC_NUM-1];

endmodule
