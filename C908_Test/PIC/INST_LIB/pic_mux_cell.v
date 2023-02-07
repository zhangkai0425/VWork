// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : pic_mux_cell.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2022-7-4
// FUNCTION        : pic_mux_cell
// ******************************************************************************
module pic_mux_cell(
  I0,
  I1,
  S,
  Z
);
//RELEASE_INST_LIB

input   I0;
input   I1;
input   S;
output  Z;

wire Z;

assign Z = S ? I1 : I0; //Customs can replace this line with their own mux_cell

//`ifdef PIC_TSMC
//  `ifdef PIC_PROCESS12FFC
//    MUX2D8BWP6T16P96CPDLVT x_mux_cell(
//      .I0 (I0),
//      .I1 (I1),
//      .S  (S ),
//      .Z  (Z )
//    );
//  `else
//    `ifdef PIC_PROCESS28HPC
//      MUX2D4BWP30P140 x_mux_cell(
//        .I0 (I0),
//        .I1 (I1),
//        .S  (S ),
//        .Z  (Z )
//      );
//    `endif
//  `endif
//`endif

endmodule
