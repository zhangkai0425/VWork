// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : tdt_dmi_gated_clk_cell.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-6
// FUNCTION        : ttd_gated_clk_cell.v
// ******************************************************************************
module tdt_dmi_gated_clk_cell(
  clk_in,
  module_en,
  local_en,
  external_en,
  pad_yy_icg_scan_en,
  clk_out
);
//RELEASE_INST_LIB

input  clk_in;
input  module_en;
input  local_en;
input  external_en;
input  pad_yy_icg_scan_en;
output clk_out;

wire   clk_en_bf_latch;
wire   SE;

assign clk_en_bf_latch = module_en | local_en | external_en ;

// SE driven from primary input, held constant
assign SE       = pad_yy_icg_scan_en;

`ifdef TDT_DMI_GATED_CELL  
tdt_dmi_gated_cell x_tdt_dmi_gated_cell( //Customs can replace tdt_dmi_gated_cell with their own icg_cell
  .clk_in        (clk_in),
  .external_en   (clk_en_bf_latch),
  .SE            (SE),
  .clk_out       (clk_out)
  );
//`ifdef TDT_DMI_SMIC
//  `ifdef TDT_DMI_PROCESS55LL
//HVT_CLKLANQHDV8 x_gated_clk_cell(
//.CK(clk_in),
//  `endif
//.TE(SE),
//.E(clk_en_bf_latch),
//.Q(clk_out));
//`endif
//`ifdef TDT_DMI_TSMC
//  `ifdef TDT_DMI_PROCESS40LP
//CKLNQD1BWP x_gated_clk_cell(
//.CP(clk_in),
//.TE(SE),
//.E(clk_en_bf_latch),
//.Q(clk_out));
//  `endif
//  `ifdef TDT_DMI_PROCESS28HPC
//    CKLNQD8BWP35P140  x_gated_clk_cell (
//                .CP     (clk_in),
//                .TE     (SE),
//                .E      (clk_en_bf_latch),
//                .Q      (clk_out)
//                );
//  `endif
//  `ifdef TDT_DMI_PROCESS12FFC
//    CKLNQD8BWP6T16P96CPDLVT x_gated_clk_cell (
//      .CP           (clk_in),
//      .TE           (SE),
//      .E            (clk_en_bf_latch),
//      .Q            (clk_out)
//    );
//  `endif
//`endif
//`ifdef TDT_DMI_GSMC
//  `ifdef TDT_DMI_PROCESS130
//CLKGTPHD8X x_gated_clk_cell(
//.CK(clk_in),
//  `endif
//.TE(SE),
//.E(clk_en_bf_latch),
//.Z(clk_out));
//`endif
//
//`ifdef TDT_DMI_UMC
//  `ifdef TDT_DMI_PROCESS28HDE
//    PREICG_X4B_A9PP140ZTR_C30 x_gated_clk_cell (
//    .CK(clk_in),
//    .SE(SE),
//    .E(clk_en_bf_latch),
//    .ECK(clk_out)
//  );
//    `endif 
//   `ifdef TDT_DMI_PROCESS22HDE
//    PREICG_X4B_A9PP140ZTS_C30 x_gated_clk_cell (
//    .CK(clk_in),
//    .SE(SE),
//    .E(clk_en_bf_latch),
//    .ECK(clk_out)
//  );
//  
//  `endif
//`endif
`else
//STN_CKGTPLT_V5_1  x_gated_clk_cell (
//  .CK           (clk_in),
//  .SE               (SE),
//  .EN      (clk_en_bf_latch),
//  .Q          (clk_out)
//);
assign clk_out = clk_in;
`endif


endmodule   
