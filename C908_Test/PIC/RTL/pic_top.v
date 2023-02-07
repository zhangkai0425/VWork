`define PIC_CLUSTER_NUM 1
`define PIC_HART_NUM 4
`define PIC_PLIC_INT_NUM 64
`define PIC_TEE_EXTENSION




// Fixed RTL configures: 
`define PIC_PLIC
`define PIC_PLIC_ID_NUM   10  
`define PIC_PLIC_PRIO_BIT 5   
   
// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : pic_abp_matrix_n_to_n.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-1
// FUNCTION        : Use SLV_NUM base address to select MST_NUM apb inputs, genarate 
//                   SLV_NUM apb requests for SLV_NUM slaves
// ******************************************************************************

module pic_apb_matrix_n_to_n (
  //input
  apb_matrix_clk,
  apb_matrix_rst_b,
  pad_yy_icg_scan_en,
  apb_matrix_icg_en,
  slvx_base_addr,
  slvx_base_addr_mask,
  trans_cmplt,
  psel_slv,
  penable_slv,
  pwrite_slv,
  paddr_slv,
  pwdata_slv,
  pprot_slv,
  pready_mst,
  prdata_mst,
  pslverr_mst,
  //output
  pready_slv,
  prdata_slv,
  pslverr_slv,
  psel_mst,
  penable_mst,
  pwrite_mst,
  paddr_mst,
  pwdata_mst,
  pprot_mst
);

parameter MST_NUM        = 4;
parameter SLV_NUM        = 2;
parameter ADDR_WIDTH     = 32; // the width of apb address
parameter DATA_WIDTH     = 32; // the width of apb data
parameter PROT_WIDTH     = 2;
parameter CLOG_BIT       = $clog2(MST_NUM);
parameter MST_BIT        = (CLOG_BIT==0) ? 1 : CLOG_BIT;

localparam IDLE        = 2'b00;
localparam APB_SETUP   = 2'b01;
localparam APB_ACCESS  = 2'b10;

input                                     apb_matrix_clk;
input                                     apb_matrix_rst_b;
input                                     pad_yy_icg_scan_en;
input                                     apb_matrix_icg_en;
input  [ADDR_WIDTH*SLV_NUM-1:0]           slvx_base_addr;
input  [ADDR_WIDTH*SLV_NUM-1:0]           slvx_base_addr_mask;
input  [MST_NUM:0]                        trans_cmplt; //matser have recived the pready/prdata/pslverr from slave, 
                                                       //this can be wired with pready_slv.
input  [MST_NUM:0]                        psel_slv;
input  [MST_NUM:0]                        penable_slv;
input  [MST_NUM:0]                        pwrite_slv;
input  [ADDR_WIDTH*MST_NUM:0]             paddr_slv;
input  [DATA_WIDTH*MST_NUM:0]             pwdata_slv;
input  [PROT_WIDTH*MST_NUM:0]             pprot_slv;
input  [SLV_NUM-1:0]                      pready_mst;
input  [DATA_WIDTH*SLV_NUM-1:0]           prdata_mst;
input  [SLV_NUM-1:0]                      pslverr_mst;
output [MST_NUM:0]                        pready_slv;
output [DATA_WIDTH*MST_NUM:0]             prdata_slv;
output [MST_NUM:0]                        pslverr_slv;
output [SLV_NUM-1:0]                      psel_mst;
output [SLV_NUM-1:0]                      penable_mst;
output [SLV_NUM-1:0]                      pwrite_mst;
output [ADDR_WIDTH*SLV_NUM-1:0]           paddr_mst;
output [DATA_WIDTH*SLV_NUM-1:0]           pwdata_mst;
output [PROT_WIDTH*SLV_NUM-1:0]           pprot_mst;

wire                                      apb_matrix_clk;
wire                                      apb_matrix_rst_b;
wire                                      matrix_psel_gated_clk;
wire                                      matrix_pready_gated_clk;
wire [SLV_NUM-1:0]                        psel_gated_clk_en_slv;
wire                                      psel_gated_clk_en;
wire [MST_NUM:0]                          pready_clear_tmp;
wire                                      pready_gated_clk_en;
wire                                      pad_yy_icg_scan_en;
wire                                      apb_matrix_icg_en;
wire [MST_NUM:0]                          psel_slv;
wire [MST_NUM:0]                          penable_slv;
wire [MST_NUM:0]                          pwrite_slv;
wire [ADDR_WIDTH*MST_NUM:0]               paddr_slv;
wire [DATA_WIDTH*MST_NUM:0]               pwdata_slv;
wire [PROT_WIDTH*MST_NUM:0]               pprot_slv;
wire [MST_NUM:0]                          trans_cmplt;
wire [ADDR_WIDTH*SLV_NUM-1:0]             slvx_base_addr;
wire [ADDR_WIDTH*SLV_NUM-1:0]             slvx_base_addr_mask;
wire [MST_NUM*SLV_NUM-1:0]                psel_before_arb;
wire [MST_NUM*SLV_NUM-1:0]                penable_before_arb;
wire [MST_NUM*SLV_NUM-1:0]                pwrite_before_arb;
wire [ADDR_WIDTH*MST_NUM*SLV_NUM-1:0]     paddr_before_arb;
wire [DATA_WIDTH*MST_NUM*SLV_NUM-1:0]     pwdata_before_arb;
wire [PROT_WIDTH*MST_NUM*SLV_NUM-1:0]     pprot_before_arb;
wire [(MST_NUM+1)*SLV_NUM-1:0]            psel_or_tmp;
wire [(MST_NUM+1)*SLV_NUM-1:0]            cmplt_aft_sel_tmp;
wire [(MST_NUM+1)*SLV_NUM-1:0]            pacc_aft_arb_tmp;
wire [(MST_NUM+1)*SLV_NUM-1:0]            sel_reg_tmp;
wire [MST_NUM*SLV_NUM-1:0]                paccess_after_arb;
wire [SLV_NUM-1:0]                        trans_cmplt_after_sel;
wire [SLV_NUM-1:0]                        have_paccess_after_arb;
wire [SLV_NUM-1:0]                        sel_reg_have_value;
wire [MST_NUM*SLV_NUM-1:0]                psel_after_arb;
wire [MST_NUM*SLV_NUM-1:0]                pwrite_after_arb;
wire [ADDR_WIDTH*MST_NUM*SLV_NUM-1:0]     paddr_after_arb;
wire [DATA_WIDTH*MST_NUM*SLV_NUM-1:0]     pwdata_after_arb;
wire [PROT_WIDTH*MST_NUM*SLV_NUM-1:0]     pprot_after_arb;
wire [(MST_NUM+1)*SLV_NUM-1:0]            tmp_pwrite;
wire [ADDR_WIDTH*(MST_NUM+1)*SLV_NUM-1:0] tmp_paddr;
wire [DATA_WIDTH*(MST_NUM+1)*SLV_NUM-1:0] tmp_pwdata;
wire [PROT_WIDTH*(MST_NUM+1)*SLV_NUM-1:0] tmp_pprot;
wire [SLV_NUM-1:0]                        pwrite_selected;
wire [ADDR_WIDTH*SLV_NUM-1:0]             paddr_selected;
wire [DATA_WIDTH*SLV_NUM-1:0]             pwdata_selected;
wire [PROT_WIDTH*SLV_NUM-1:0]             pprot_selected;
wire [SLV_NUM-1:0]                        trans_req;
wire [SLV_NUM-1:0]                        pready_mst;
wire [DATA_WIDTH*SLV_NUM-1:0]             prdata_mst;
wire [SLV_NUM-1:0]                        pslverr_mst;
wire [MST_NUM*SLV_NUM-1:0]                pready_after_sel;
wire [DATA_WIDTH*MST_NUM*SLV_NUM-1:0]     prdata_after_sel;
wire [MST_NUM*SLV_NUM-1:0]                pslverr_after_sel;
wire [MST_NUM*(SLV_NUM+1)-1:0]            pready_or_tmp;
wire [DATA_WIDTH*MST_NUM*(SLV_NUM+1)-1:0] prdata_or_tmp;
wire [MST_NUM*(SLV_NUM+1)-1:0]            pslverr_or_temp;
wire [MST_NUM*SLV_NUM-1:0]                psel_shift_before_arb;
wire [MST_NUM*SLV_NUM-1:0]                psel_shift_after_arb;
wire [MST_BIT:0]                          counter_max_value;
wire [MST_BIT:0]                          master_num;
wire [MST_BIT*SLV_NUM-1:0]                shift_counter_add_1;
wire [MST_BIT*SLV_NUM-1:0]                right_shift;
wire [MST_BIT*SLV_NUM-1:0]                left_shift;
wire [SLV_NUM-1:0]                        pready_after_sel_self_or;
wire [(MST_NUM+1)*SLV_NUM-1:0]            pready_after_sel_or_tmp;
wire                                      value_zero;
wire [MST_NUM*(SLV_NUM+1)-1:0]            psel_before_arb_or;
wire [MST_NUM:0]                          psel_but_addr_illegal;
wire [MST_NUM:0]                          psel_but_addr_illegal_tmp;

reg [MST_BIT*SLV_NUM-1:0]                 shift_counter;
reg [MST_NUM*SLV_NUM-1:0]                 sel_reg;
reg [2*SLV_NUM-1:0]                       p_state;
reg [2*SLV_NUM-1:0]                       n_state;
reg [SLV_NUM-1:0]                         psel_mst;
reg [SLV_NUM-1:0]                         penable_mst;
reg [SLV_NUM-1:0]                         pwrite_mst;
reg [ADDR_WIDTH*SLV_NUM-1:0]              paddr_mst;
reg [DATA_WIDTH*SLV_NUM-1:0]              pwdata_mst;
reg [PROT_WIDTH*SLV_NUM-1:0]              pprot_mst;
reg [MST_NUM:0]                           pready_slv;
reg [DATA_WIDTH*MST_NUM:0]                prdata_slv;
reg [MST_NUM:0]                           pslverr_slv;
reg [MST_NUM:0]                           psel_but_addr_illegal_flop;
//=========================================================
//                    apb matrix
//=========================================================

//generate SLV_NUM-way apb before arbitration for every slave
//****************psel paddr from mst**********************
genvar slv_idx0,mst_idx0;
generate
for(slv_idx0=0;slv_idx0<SLV_NUM;slv_idx0=slv_idx0+1)
  begin:APB_VEC_BEFORE_ARB
    for(mst_idx0=0;mst_idx0<MST_NUM;mst_idx0=mst_idx0+1)
      begin:APB_ELEMENT_BEFOR_ARB
        assign psel_before_arb[MST_NUM*slv_idx0+mst_idx0] = 
                                      ((paddr_slv[ADDR_WIDTH*mst_idx0+:ADDR_WIDTH] & slvx_base_addr_mask[ADDR_WIDTH*slv_idx0+:ADDR_WIDTH]) == 
                                      slvx_base_addr[ADDR_WIDTH*slv_idx0+:ADDR_WIDTH]) & psel_slv[mst_idx0];
        assign penable_before_arb[MST_NUM*slv_idx0+mst_idx0]                                    = penable_slv[mst_idx0];
        assign pwrite_before_arb[MST_NUM*slv_idx0+mst_idx0]                                     = pwrite_slv[mst_idx0];
        assign paddr_before_arb[(ADDR_WIDTH*MST_NUM*slv_idx0+ADDR_WIDTH*mst_idx0)+:ADDR_WIDTH]  = paddr_slv[ADDR_WIDTH*mst_idx0+:ADDR_WIDTH];
        assign pwdata_before_arb[(DATA_WIDTH*MST_NUM*slv_idx0+DATA_WIDTH*mst_idx0)+:DATA_WIDTH] = pwdata_slv[DATA_WIDTH*mst_idx0+:DATA_WIDTH];
        assign pprot_before_arb[(PROT_WIDTH*MST_NUM*slv_idx0+PROT_WIDTH*mst_idx0)+:PROT_WIDTH]  = pprot_slv[PROT_WIDTH*mst_idx0+:PROT_WIDTH];
      end //APB_ELEMENT_BEFOR_ARB
  end //APB_VEC_BEFORE_ARB
endgenerate

//if have psel but addr is illeagal,pic must give back a apb error
genvar mst_idx6,slv_idx6;
generate
for(mst_idx6=0;mst_idx6<MST_NUM;mst_idx6=mst_idx6+1)
  begin:PSEL_SFT_ADDR_CHECK_OR_VEC
    assign psel_before_arb_or[mst_idx6] = 1'b0;
    for(slv_idx6=0;slv_idx6<SLV_NUM;slv_idx6=slv_idx6+1)
      begin:PSEL_SFT_ADDR_CHECK_OR
        assign psel_before_arb_or[MST_NUM*(slv_idx6+1)+mst_idx6] = psel_before_arb[MST_NUM*slv_idx6+mst_idx6] | psel_before_arb_or[MST_NUM*slv_idx6+mst_idx6];
      end
    assign psel_but_addr_illegal[mst_idx6] = ~psel_before_arb_or[MST_NUM*SLV_NUM+mst_idx6] & psel_slv[mst_idx6] & ~psel_but_addr_illegal_flop[mst_idx6];
    always @ (posedge matrix_pready_gated_clk or negedge apb_matrix_rst_b)
    begin
      if(~apb_matrix_rst_b)
        psel_but_addr_illegal_flop[mst_idx6] <= 1'b0;
      else if(~psel_before_arb_or[MST_NUM*SLV_NUM+mst_idx6] & psel_slv[mst_idx6]) //psel is low after pic apbaddr check,but orginal psel from cluster is high
        psel_but_addr_illegal_flop[mst_idx6] <= 1'b1;
      else if(~psel_slv[mst_idx6])
        psel_but_addr_illegal_flop[mst_idx6] <= 1'b0;
    end
  end
endgenerate
assign psel_but_addr_illegal[MST_NUM] = 1'b0;
always @ (*) //to fix lint
  begin
    psel_but_addr_illegal_flop[MST_NUM] = value_zero;
  end

//chose only one psel for each slave, lower bit of psel_before_arb has higher priority
genvar slv_idx1,mst_idx1;
generate
for(slv_idx1=0;slv_idx1<SLV_NUM;slv_idx1=slv_idx1+1)
  begin:PSEL_ARBITER
    assign psel_shift_before_arb[MST_NUM*slv_idx1+:MST_NUM] = (psel_before_arb[MST_NUM*slv_idx1+:MST_NUM] >> right_shift[MST_BIT*slv_idx1+:MST_BIT]) |
                                                              (psel_before_arb[MST_NUM*slv_idx1+:MST_NUM] << left_shift[MST_BIT*slv_idx1+:MST_BIT]);

    assign psel_or_tmp[(MST_NUM+1)*slv_idx1] = 1'b0;

    for(mst_idx1=0;mst_idx1<MST_NUM;mst_idx1=mst_idx1+1)
      begin:PSEL_OR_TEMP
        assign psel_or_tmp[(MST_NUM+1)*slv_idx1+mst_idx1+1]  = psel_shift_before_arb[MST_NUM*slv_idx1+mst_idx1] | psel_or_tmp[(MST_NUM+1)*slv_idx1+mst_idx1];
      end

    assign psel_shift_after_arb[MST_NUM*slv_idx1+:MST_NUM] = ~psel_or_tmp[(MST_NUM+1)*slv_idx1+:MST_NUM] & psel_shift_before_arb[MST_NUM*slv_idx1+:MST_NUM];
    assign psel_after_arb[MST_NUM*slv_idx1+:MST_NUM]       = (psel_shift_after_arb[MST_NUM*slv_idx1+:MST_NUM] << right_shift[MST_BIT*slv_idx1+:MST_BIT]) |
                                                             (psel_shift_after_arb[MST_NUM*slv_idx1+:MST_NUM] >> left_shift[MST_BIT*slv_idx1+:MST_BIT]);
    assign paccess_after_arb[MST_NUM*slv_idx1+:MST_NUM]    = psel_after_arb[MST_NUM*slv_idx1+:MST_NUM] & penable_before_arb[MST_NUM*slv_idx1+:MST_NUM];
    
    //generate info for sel_reg update
    assign cmplt_aft_sel_tmp[(MST_NUM+1)*slv_idx1] = 1'b0;
    assign pacc_aft_arb_tmp[(MST_NUM+1)*slv_idx1]  = 1'b0;
    assign sel_reg_tmp[(MST_NUM+1)*slv_idx1]       = 1'b0;
    for(mst_idx1=0;mst_idx1<MST_NUM;mst_idx1=mst_idx1+1)
      begin:UPDATE_SEL_REG_TEMP
        assign cmplt_aft_sel_tmp[(MST_NUM+1)*slv_idx1+mst_idx1+1]  = sel_reg[MST_NUM*slv_idx1+mst_idx1] & trans_cmplt[mst_idx1] |
                                                                     cmplt_aft_sel_tmp[(MST_NUM+1)*slv_idx1+mst_idx1];
        assign pacc_aft_arb_tmp[(MST_NUM+1)*slv_idx1+mst_idx1+1]   = paccess_after_arb[MST_NUM*slv_idx1+mst_idx1] |
                                                                     pacc_aft_arb_tmp[(MST_NUM+1)*slv_idx1+mst_idx1];
        assign sel_reg_tmp[(MST_NUM+1)*slv_idx1+mst_idx1+1]        = sel_reg[MST_NUM*slv_idx1+mst_idx1] | sel_reg_tmp[(MST_NUM+1)*slv_idx1+mst_idx1];
      end

    //sel_reg sample new paccess_after_arb when a transcation has completed.
    assign trans_cmplt_after_sel[slv_idx1]  = cmplt_aft_sel_tmp[(MST_NUM+1)*slv_idx1+MST_NUM];
    assign have_paccess_after_arb[slv_idx1] = pacc_aft_arb_tmp[(MST_NUM+1)*slv_idx1+MST_NUM];
    assign sel_reg_have_value[slv_idx1]     = sel_reg_tmp[(MST_NUM+1)*slv_idx1+MST_NUM];
    always @(posedge matrix_psel_gated_clk or negedge apb_matrix_rst_b)
      begin
        if(~apb_matrix_rst_b)
          sel_reg[MST_NUM*slv_idx1+:MST_NUM] <= {MST_NUM{1'b0}};
        else if(trans_cmplt_after_sel[slv_idx1] & have_paccess_after_arb[slv_idx1])
          sel_reg[MST_NUM*slv_idx1+:MST_NUM] <= paccess_after_arb[MST_NUM*slv_idx1+:MST_NUM];
        else if(trans_cmplt_after_sel[slv_idx1])
          sel_reg[MST_NUM*slv_idx1+:MST_NUM] <= {MST_NUM{1'b0}};
        else if(~sel_reg_have_value[slv_idx1] & have_paccess_after_arb[slv_idx1])
          sel_reg[MST_NUM*slv_idx1+:MST_NUM] <= paccess_after_arb[MST_NUM*slv_idx1+:MST_NUM];
      end 

  always @(posedge matrix_psel_gated_clk or negedge apb_matrix_rst_b)
    begin
      if(~apb_matrix_rst_b)
        shift_counter[MST_BIT*slv_idx1+:MST_BIT] <= {MST_BIT{1'b0}};
      else if(pready_mst[slv_idx1] & (p_state[2*slv_idx1+:2] == APB_ACCESS) &
              shift_counter[MST_BIT*slv_idx1+:MST_BIT] == counter_max_value[MST_BIT-1:0])
        shift_counter[MST_BIT*slv_idx1+:MST_BIT] <= {MST_BIT{1'b0}};
      else if(pready_mst[slv_idx1] & (p_state[2*slv_idx1+:2] == APB_ACCESS))
        shift_counter[MST_BIT*slv_idx1+:MST_BIT] <= shift_counter_add_1[MST_BIT*slv_idx1+:MST_BIT];
    end
  assign shift_counter_add_1[MST_BIT*slv_idx1+:MST_BIT] = shift_counter[MST_BIT*slv_idx1+:MST_BIT] + 1'b1;
  assign right_shift[MST_BIT*slv_idx1+:MST_BIT]         = shift_counter[MST_BIT*slv_idx1+:MST_BIT];
  assign left_shift[MST_BIT*slv_idx1+:MST_BIT]          = master_num[MST_BIT-1:0] - shift_counter[MST_BIT*slv_idx1+:MST_BIT]; 
end
endgenerate

assign master_num[MST_BIT:0]          = $unsigned(MST_NUM) & {MST_BIT+1{1'b1}};
assign counter_max_value[MST_BIT:0]   = $unsigned(MST_NUM-1) & {MST_BIT+1{1'b1}};

//generate SLV_NUM-way apb after arbitration for every slave
genvar slv_idx2,mst_idx2;
generate
for(slv_idx2=0;slv_idx2<SLV_NUM;slv_idx2=slv_idx2+1)
  begin:APB_VEC_AFTER_ARB
    for(mst_idx2=0;mst_idx2<MST_NUM;mst_idx2=mst_idx2+1)
      begin:APB_ELEMENT_AFTER_ARB
        assign pwrite_after_arb[MST_NUM*slv_idx2+mst_idx2] = 
                                                   psel_after_arb[MST_NUM*slv_idx2+mst_idx2] & pwrite_before_arb[MST_NUM*slv_idx2+mst_idx2];
        assign paddr_after_arb[(ADDR_WIDTH*MST_NUM*slv_idx2+ADDR_WIDTH*mst_idx2)+:ADDR_WIDTH]  = 
                                                   {ADDR_WIDTH{psel_after_arb[MST_NUM*slv_idx2+mst_idx2]}} & 
                                                   paddr_before_arb[(ADDR_WIDTH*MST_NUM*slv_idx2+ADDR_WIDTH*mst_idx2)+:ADDR_WIDTH];
        assign pwdata_after_arb[(DATA_WIDTH*MST_NUM*slv_idx2+DATA_WIDTH*mst_idx2)+:DATA_WIDTH] = 
                                                   {DATA_WIDTH{psel_after_arb[MST_NUM*slv_idx2+mst_idx2]}} & 
                                                   pwdata_before_arb[(DATA_WIDTH*MST_NUM*slv_idx2+DATA_WIDTH*mst_idx2)+:DATA_WIDTH];
        assign pprot_after_arb[(PROT_WIDTH*MST_NUM*slv_idx2+PROT_WIDTH*mst_idx2)+:PROT_WIDTH]  = 
                                                   {PROT_WIDTH{psel_after_arb[MST_NUM*slv_idx2+mst_idx2]}} & 
                                                   pprot_before_arb[(PROT_WIDTH*MST_NUM*slv_idx2+PROT_WIDTH*mst_idx2)+:PROT_WIDTH];
      end //APB_ELEMENT_AFTER_ARB
  end //APB_VEC_AFTER_ARB
endgenerate

//combine MST_NUM-way apb to 1-way apb for every slave
genvar slv_idx3,mst_idx3;
generate
for(slv_idx3=0;slv_idx3<SLV_NUM;slv_idx3=slv_idx3+1)
  begin:SELECT_TO_SLV_FSM
    assign tmp_pwrite[(MST_NUM+1)*slv_idx3]                        = 1'b0;
    assign tmp_paddr[ADDR_WIDTH*(MST_NUM+1)*slv_idx3+:ADDR_WIDTH]  = {ADDR_WIDTH{1'b0}};
    assign tmp_pwdata[DATA_WIDTH*(MST_NUM+1)*slv_idx3+:DATA_WIDTH] = {DATA_WIDTH{1'b0}};
    assign tmp_pprot[PROT_WIDTH*(MST_NUM+1)*slv_idx3+:PROT_WIDTH]  = {PROT_WIDTH{1'b0}};

    for(mst_idx3=0;mst_idx3<MST_NUM;mst_idx3=mst_idx3+1)
      begin:PADDR_OR_TMP
        assign tmp_pwrite[(MST_NUM+1)*slv_idx3+(mst_idx3+1)] = pwrite_after_arb[MST_NUM*slv_idx3+mst_idx3] | 
                                                               tmp_pwrite[(MST_NUM+1)*slv_idx3+mst_idx3];
        assign tmp_paddr[(ADDR_WIDTH*(MST_NUM+1)*slv_idx3+ADDR_WIDTH*(mst_idx3+1))+:ADDR_WIDTH]  =
                                        paddr_after_arb[(ADDR_WIDTH*MST_NUM*slv_idx3+ADDR_WIDTH*mst_idx3)+:ADDR_WIDTH] |
                                        tmp_paddr[(ADDR_WIDTH*(MST_NUM+1)*slv_idx3+ADDR_WIDTH*mst_idx3)+:ADDR_WIDTH];
        assign tmp_pwdata[(DATA_WIDTH*(MST_NUM+1)*slv_idx3+DATA_WIDTH*(mst_idx3+1))+:DATA_WIDTH] =
                                        pwdata_after_arb[(DATA_WIDTH*MST_NUM*slv_idx3+DATA_WIDTH*mst_idx3)+:DATA_WIDTH] |
                                        tmp_pwdata[(DATA_WIDTH*(MST_NUM+1)*slv_idx3+DATA_WIDTH*mst_idx3)+:DATA_WIDTH];
        assign tmp_pprot[(PROT_WIDTH*(MST_NUM+1)*slv_idx3+PROT_WIDTH*(mst_idx3+1))+:PROT_WIDTH]  = 
                                        pprot_after_arb[(PROT_WIDTH*MST_NUM*slv_idx3+PROT_WIDTH*mst_idx3)+:PROT_WIDTH] |
                                        tmp_pprot[(PROT_WIDTH*(MST_NUM+1)*slv_idx3+PROT_WIDTH*mst_idx3)+:PROT_WIDTH];
      end //PADDR_OR_TMP

    assign pwrite_selected[slv_idx3]                        = tmp_pwrite[(MST_NUM+1)*slv_idx3+MST_NUM];
    assign paddr_selected[ADDR_WIDTH*slv_idx3+:ADDR_WIDTH]  = tmp_paddr[(ADDR_WIDTH*(MST_NUM+1)*slv_idx3+ADDR_WIDTH*MST_NUM)+:ADDR_WIDTH];
    assign pwdata_selected[DATA_WIDTH*slv_idx3+:DATA_WIDTH] = tmp_pwdata[(DATA_WIDTH*(MST_NUM+1)*slv_idx3+DATA_WIDTH*MST_NUM)+:DATA_WIDTH];
    assign pprot_selected[PROT_WIDTH*slv_idx3+:PROT_WIDTH]  = tmp_pprot[(PROT_WIDTH*(MST_NUM+1)*slv_idx3+PROT_WIDTH*MST_NUM)+:PROT_WIDTH];
  end //SELECT_TO_SLV_FSM
endgenerate

//=========================================================
//                     apb fsm
//=========================================================
assign pready_or_tmp[MST_NUM-1:0]            = {MST_NUM{1'b0}};
assign prdata_or_tmp[DATA_WIDTH*MST_NUM-1:0] = {DATA_WIDTH*MST_NUM{1'b0}};
assign pslverr_or_temp[MST_NUM-1:0]          = {MST_NUM{1'b0}};

genvar slv_idx4,mst_idx4;
generate
for(slv_idx4=0;slv_idx4<SLV_NUM;slv_idx4=slv_idx4+1)
  begin:APB_FSM
    assign trans_req[slv_idx4]     = ~sel_reg_have_value[slv_idx4] & have_paccess_after_arb[slv_idx4] |
                                    trans_cmplt_after_sel[slv_idx4] & have_paccess_after_arb[slv_idx4];

    always @ (posedge matrix_psel_gated_clk or negedge apb_matrix_rst_b)
      begin
        if(~apb_matrix_rst_b)
          p_state[2*slv_idx4+:2] <= 2'b00;
        else if(psel_gated_clk_en)
          p_state[2*slv_idx4+:2] <= n_state[2*slv_idx4+:2];
      end

    always @ (p_state[2*slv_idx4+:2] or
              pready_mst[slv_idx4] or
              trans_req[slv_idx4])
      begin
        case(p_state[2*slv_idx4+:2])
          IDLE: 
            if(trans_req[slv_idx4])
              n_state[2*slv_idx4+:2] = APB_SETUP;
            else
              n_state[2*slv_idx4+:2] = IDLE;
          APB_SETUP:   
            n_state[2*slv_idx4+:2] = APB_ACCESS;
          APB_ACCESS: 
            if(pready_mst[slv_idx4] & trans_req[slv_idx4])
              n_state[2*slv_idx4+:2] = APB_SETUP;
            else if(pready_mst[slv_idx4])
              n_state[2*slv_idx4+:2] = IDLE;
            else 
              n_state[2*slv_idx4+:2] = APB_ACCESS;
          default:   
            n_state[2*slv_idx4+:2] = IDLE;
        endcase
      end
//****************psel paddr to slv**********************
    //psel reg out to slave
    always @ (posedge matrix_psel_gated_clk or negedge apb_matrix_rst_b)
    begin
      if(~apb_matrix_rst_b)
        psel_mst[slv_idx4] <= 1'b0;
      else if(p_state[2*slv_idx4+:2] == IDLE & trans_req[slv_idx4])
        psel_mst[slv_idx4] <= 1'b1;
      else if(p_state[2*slv_idx4+:2] == APB_ACCESS & pready_mst[slv_idx4] & ~trans_req[slv_idx4] & psel_mst[slv_idx4])
        psel_mst[slv_idx4] <= 1'b0;
    end

    //penable reg out to slave
    always @ (posedge matrix_psel_gated_clk or negedge apb_matrix_rst_b)
    begin
      if(~apb_matrix_rst_b)
        penable_mst[slv_idx4] <= 1'b0;
      else if(p_state[2*slv_idx4+:2] == APB_SETUP & psel_mst[slv_idx4])
        penable_mst[slv_idx4] <= 1'b1;
      else if(p_state[2*slv_idx4+:2] == APB_ACCESS & pready_mst[slv_idx4] & psel_mst[slv_idx4])
        penable_mst[slv_idx4] <= 1'b0;
    end
   
    //pwrite, paddr, pwdata reg out to slave
    always @ (posedge matrix_psel_gated_clk or negedge apb_matrix_rst_b)
    begin
      if(~apb_matrix_rst_b)
        begin
          pwrite_mst[slv_idx4]                        <= 1'b0;
          paddr_mst[ADDR_WIDTH*slv_idx4+:ADDR_WIDTH]  <= {ADDR_WIDTH{1'b0}};
          pwdata_mst[DATA_WIDTH*slv_idx4+:DATA_WIDTH] <= {DATA_WIDTH{1'b0}};
          pprot_mst[PROT_WIDTH*slv_idx4+:PROT_WIDTH]  <= {PROT_WIDTH{1'b0}};
        end
      else if(trans_req[slv_idx4])
        begin
          pwrite_mst[slv_idx4]                        <= pwrite_selected[slv_idx4];
          paddr_mst[ADDR_WIDTH*slv_idx4+:ADDR_WIDTH]  <= paddr_selected[ADDR_WIDTH*slv_idx4+:ADDR_WIDTH];
          pwdata_mst[DATA_WIDTH*slv_idx4+:DATA_WIDTH] <= pwdata_selected[DATA_WIDTH*slv_idx4+:DATA_WIDTH];
          pprot_mst[PROT_WIDTH*slv_idx4+:PROT_WIDTH]  <= pprot_selected[PROT_WIDTH*slv_idx4+:PROT_WIDTH];
        end
    end

//****************pready prdata from slv********************** 
    //SLV_NUM pready to MST_NUM pready
    assign pready_after_sel[MST_NUM*slv_idx4+:MST_NUM] = {MST_NUM{pready_mst[slv_idx4] & penable_mst[slv_idx4]}} & sel_reg[MST_NUM*slv_idx4+:MST_NUM];
    //combine every pready_after_sel of each slave to one pready vec for all masters
    assign pready_or_tmp[MST_NUM*(slv_idx4+1)+:MST_NUM] = pready_after_sel[MST_NUM*slv_idx4+:MST_NUM] | pready_or_tmp[MST_NUM*slv_idx4+:MST_NUM];

    //pready_after_sel self-or logic, pready_after_sel(each salve) have 1 or not
    assign pready_after_sel_or_tmp[(MST_NUM+1)*slv_idx4] = 1'b0;
    for(mst_idx4=0;mst_idx4<MST_NUM;mst_idx4=mst_idx4+1)
      begin:PREADY_AFTER_SEL_HAVE_1
        assign pready_after_sel_or_tmp[(MST_NUM+1)*slv_idx4+mst_idx4+1] = pready_after_sel[MST_NUM*slv_idx4+mst_idx4] |
                                                                     pready_after_sel_or_tmp[(MST_NUM+1)*slv_idx4+mst_idx4];
      end
    assign pready_after_sel_self_or[slv_idx4] = pready_after_sel_or_tmp[(MST_NUM+1)*slv_idx4+MST_NUM];

    //SLV_NUM prdata pprot to MST_NUM pready
    for(mst_idx4=0;mst_idx4<MST_NUM;mst_idx4=mst_idx4+1)
      begin:RDATA_PROT_MST
        assign prdata_after_sel[(DATA_WIDTH*MST_NUM*slv_idx4+DATA_WIDTH*mst_idx4)+:DATA_WIDTH] = {DATA_WIDTH{pready_after_sel[MST_NUM*slv_idx4+mst_idx4]}} & 
                                                                               prdata_mst[DATA_WIDTH*slv_idx4+:DATA_WIDTH];
        assign pslverr_after_sel[MST_NUM*slv_idx4+mst_idx4]                       = pready_after_sel[MST_NUM*slv_idx4+mst_idx4] & pslverr_mst[slv_idx4];
      end //RDATA_PROT_MST
    assign prdata_or_tmp[DATA_WIDTH*MST_NUM*(slv_idx4+1)+:DATA_WIDTH*MST_NUM] = prdata_after_sel[DATA_WIDTH*MST_NUM*slv_idx4+:DATA_WIDTH*MST_NUM] |
                                                                                prdata_or_tmp[DATA_WIDTH*MST_NUM*slv_idx4+:DATA_WIDTH*MST_NUM];
    assign pslverr_or_temp[MST_NUM*(slv_idx4+1)+:MST_NUM]                     = pslverr_after_sel[MST_NUM*slv_idx4+:MST_NUM] |
                                                                                pslverr_or_temp[MST_NUM*slv_idx4+:MST_NUM];

  end //APB_FSM
endgenerate

//****************pready prdata to mst**********************
genvar mst_idx5;
generate
for(mst_idx5=0;mst_idx5<MST_NUM;mst_idx5=mst_idx5+1)
begin:PREADY_REG_OUTPUT
  //pready, pulse
  always @ (posedge matrix_pready_gated_clk or negedge apb_matrix_rst_b)
  begin
    if(~apb_matrix_rst_b)
      pready_slv[mst_idx5] <= 1'b0;
    else if(pready_slv[mst_idx5])
      pready_slv[mst_idx5] <= 1'b0;
    else if(|pready_after_sel_self_or[SLV_NUM-1:0])
      pready_slv[mst_idx5] <= pready_or_tmp[MST_NUM*SLV_NUM+mst_idx5];
    else if(psel_but_addr_illegal[mst_idx5])
      pready_slv[mst_idx5] <= 1'b1;
  end
  //prdata, pslverr
  always @ (posedge matrix_pready_gated_clk or negedge apb_matrix_rst_b)
  begin
    if(~apb_matrix_rst_b)
      begin
        prdata_slv[DATA_WIDTH*mst_idx5+:DATA_WIDTH] <= {DATA_WIDTH{1'b0}};
        pslverr_slv[mst_idx5]                       <= 1'b0;
      end  
    else if(|pready_after_sel_self_or[SLV_NUM-1:0] & pready_or_tmp[MST_NUM*SLV_NUM+mst_idx5])
      begin
        prdata_slv[DATA_WIDTH*mst_idx5+:DATA_WIDTH] <= prdata_or_tmp[(DATA_WIDTH*MST_NUM*SLV_NUM+DATA_WIDTH*mst_idx5)+:DATA_WIDTH] 
                                                       & {DATA_WIDTH{~pslverr_or_temp[MST_NUM*SLV_NUM+mst_idx5]}};
        pslverr_slv[mst_idx5]                       <= pslverr_or_temp[MST_NUM*SLV_NUM+mst_idx5];
      end
    else if(psel_but_addr_illegal[mst_idx5])
      begin
        prdata_slv[DATA_WIDTH*mst_idx5+:DATA_WIDTH] <= {DATA_WIDTH{1'b0}};
        pslverr_slv[mst_idx5]                       <= 1'b1;
      end
  end
end
endgenerate

assign value_zero = 1'b0;
always @ (*) //to fix lint
  begin
    pready_slv[MST_NUM]            = value_zero;
    prdata_slv[DATA_WIDTH*MST_NUM] = value_zero;
    pslverr_slv[MST_NUM]           = value_zero;
  end

//=========================================================
//                     gated clk
//=========================================================
//****************psel gated clk cell**********************
genvar gated_idx0;
generate
for(gated_idx0=0;gated_idx0<SLV_NUM;gated_idx0=gated_idx0+1)
begin:PSEL_GATE_CLK_EN
  assign  psel_gated_clk_en_slv[gated_idx0]   = trans_req[gated_idx0] | psel_mst[gated_idx0] | 
                                                 trans_cmplt_after_sel[gated_idx0] | have_paccess_after_arb[gated_idx0]; 
end
endgenerate
assign psel_gated_clk_en = |psel_gated_clk_en_slv[SLV_NUM-1:0];

pic_gated_clk_cell  apb_matrix_psel_gateclk (
    .clk_in               (apb_matrix_clk      ),
    .clk_out              (matrix_psel_gated_clk    ),
    .external_en          (1'b0                ),
    .local_en             (psel_gated_clk_en ),
    .module_en            (apb_matrix_icg_en   ),
    .pad_yy_icg_scan_en   (pad_yy_icg_scan_en  )
  );

//****************pready gated clk cell**********************
assign pready_clear_tmp[0]          = 1'b0;
assign psel_but_addr_illegal_tmp[0] = 1'b0;
genvar gated_idx1;
generate
for(gated_idx1=0;gated_idx1<MST_NUM;gated_idx1=gated_idx1+1)
begin:PREADY_CLEAR 
  assign pready_clear_tmp[gated_idx1+1]          = pready_slv[gated_idx1] | pready_clear_tmp[gated_idx1];
  assign psel_but_addr_illegal_tmp[gated_idx1+1] = (psel_but_addr_illegal[gated_idx1] | psel_but_addr_illegal_flop[gated_idx1]) | 
                                                   psel_but_addr_illegal_tmp[gated_idx1];
end
endgenerate

assign pready_gated_clk_en = (|pready_after_sel_self_or[SLV_NUM-1:0]) | pready_clear_tmp[MST_NUM] | psel_but_addr_illegal_tmp[MST_NUM];

pic_gated_clk_cell  apb_matrix_pready_gateclk (
    .clk_in               (apb_matrix_clk      ),
    .clk_out              (matrix_pready_gated_clk    ),
    .external_en          (1'b0                ),
    .local_en             (pready_gated_clk_en ),
    .module_en            (apb_matrix_icg_en   ),
    .pad_yy_icg_scan_en   (pad_yy_icg_scan_en  )
  );

`ifdef PIC_ASSERTION
//============================================================
// assertion of psel/pready between plic/clint and apb matrix
//============================================================
property psel_to_slave_caused_by_psel_from_cluster;
  @ (posedge matrix_psel_gated_clk)
    |psel_mst[SLV_NUM-1:0] |-> |psel_slv[MST_NUM:0];
endproperty
assert property(psel_to_slave_caused_by_psel_from_cluster);

genvar i;
generate
for(i=0;i<SLV_NUM;i=i+1)
begin:PSEL_TO_SLV_MUST_HAVE_SEL_REG_ASSER
  property pesl_to_slv_must_have_sel_reg;
    @ (posedge matrix_psel_gated_clk)
      psel_mst[i] |-> |sel_reg[MST_NUM*i+:MST_NUM];
  endproperty
  assert property(pesl_to_slv_must_have_sel_reg);
end
endgenerate

generate
for(i=0;i<SLV_NUM;i=i+1)
begin:PREADY_FROM_SLV_HAVE_PSEL_TO_SLV_ASSER
  property pready_from_slv_have_psel_to_slv;
  @ (posedge matrix_psel_gated_clk)
    $rose(pready_mst[i]) |-> psel_mst[i];
  endproperty
  assert property(pready_from_slv_have_psel_to_slv);
end
endgenerate

generate
for(i=0;i<SLV_NUM;i=i+1)
begin:PREADY_FROM_SLV_CLEAR_PSEL_TO_SLV_ASSER
  property pready_from_slv_clear_psel_to_slv;
  @ (posedge matrix_psel_gated_clk)
    $rose(pready_mst[i]) |=> !psel_mst[i];
  endproperty
  assert property(pready_from_slv_clear_psel_to_slv);
end
endgenerate

//============================================================
// assertion of psel/pready between apb matrix between cluster
//============================================================
generate
for(i=0;i<SLV_NUM;i=i+1)
begin:PREADY_FROM_MATRIX_HAVE_PSEL_TO_MATRIX_ASSER
  property pready_from_matrix_have_psel_to_matrix;
  @ (posedge matrix_pready_gated_clk)
    pready_slv[i] |-> psel_slv[i];
  endproperty
  assert property(pready_from_matrix_have_psel_to_matrix);
end
endgenerate
`endif

endmodule
// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : pic_apb_sync.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-1
// FUNCTION        : pic cdc
//                   each cluster has a apb cdc logic 
// ******************************************************************************

module pic_apb_sync (
  //input
  pic_clk,
  pic_rst_b,
  cluster_clk,
  cluster_rst_b,
  psel_cluster,
  penable_cluster,
  pwrite_cluster,
  paddr_cluster,
  pwdata_cluster,
  pprot_cluster,
  pready_pic,
  prdata_pic,
  pslverr_pic,
  //output
  psel_pic,
  pwrite_pic, 
  paddr_pic,
  pwdata_pic,
  pprot_pic,
  pready_cluster,
  prdata_cluster,
  pslverr_cluster,
  trans_cmplt
);
parameter CLUSTER_NUM = 4;

input                          pic_clk;
input                          pic_rst_b;
input  [CLUSTER_NUM:0]         cluster_clk;
input  [CLUSTER_NUM:0]         cluster_rst_b;
input  [CLUSTER_NUM:0]         psel_cluster;
input  [CLUSTER_NUM:0]         penable_cluster;
input  [CLUSTER_NUM:0]         pwrite_cluster; 
input  [32*CLUSTER_NUM:0]      paddr_cluster;
input  [32*CLUSTER_NUM:0]      pwdata_cluster;
input  [2*CLUSTER_NUM:0]       pprot_cluster;
input  [CLUSTER_NUM:0]         pready_pic;
input  [32*CLUSTER_NUM:0]      prdata_pic;
input  [CLUSTER_NUM:0]         pslverr_pic;
output [CLUSTER_NUM:0]         psel_pic;
output [CLUSTER_NUM:0]         pwrite_pic; 
output [32*CLUSTER_NUM:0]      paddr_pic;
output [32*CLUSTER_NUM:0]      pwdata_pic;
output [2*CLUSTER_NUM:0]       pprot_pic;
output [CLUSTER_NUM:0]         pready_cluster;
output [32*CLUSTER_NUM:0]      prdata_cluster;
output [CLUSTER_NUM:0]         pslverr_cluster;
output [CLUSTER_NUM:0]         trans_cmplt;

wire                      pic_clk;
wire                      pic_rst_b;
wire [CLUSTER_NUM:0]      cluster_clk;
wire [CLUSTER_NUM:0]      cluster_rst_b;
wire [CLUSTER_NUM:0]      psel_cluster;
wire [CLUSTER_NUM:0]      penable_cluster;
wire [CLUSTER_NUM:0]      pwrite_cluster; 
wire [32*CLUSTER_NUM:0]   paddr_cluster;
wire [32*CLUSTER_NUM:0]   pwdata_cluster;
wire [2*CLUSTER_NUM:0]    pprot_cluster;
wire [CLUSTER_NUM:0]      psel_pic_pulse;
wire [CLUSTER_NUM:0]      psel_pic;
wire [CLUSTER_NUM:0]      pready_pic;
wire [32*CLUSTER_NUM:0]   prdata_pic;
wire [CLUSTER_NUM:0]      pslverr_pic;
wire [CLUSTER_NUM:0]      psel_cluster_pulse; 
wire [CLUSTER_NUM:0]      pready_cluster_pulse;
wire [CLUSTER_NUM:0]      trans_cmplt;
wire                      value_zero; 
 
reg [CLUSTER_NUM:0]    psel_pic_reg;
reg [CLUSTER_NUM:0]    pwrite_pic; 
reg [32*CLUSTER_NUM:0] paddr_pic;
reg [32*CLUSTER_NUM:0] pwdata_pic;
reg [2*CLUSTER_NUM:0]  pprot_pic;
reg [CLUSTER_NUM:0]    pready_cluster;
reg [32*CLUSTER_NUM:0] prdata_cluster;
reg [CLUSTER_NUM:0]    pslverr_cluster;

//apb cdc from cluster_clk domain to pic_clk domain
genvar i;
generate
for(i=0;i<CLUSTER_NUM;i=i+1)
begin:CLUSTER_TO_PIC
  assign psel_cluster_pulse[i] = psel_cluster[i] & ~penable_cluster[i];
  
  pic_psel_cdc  x_pic_psel_pulse_cdc (
    .src_clk    (cluster_clk[i]),
    .src_rst_b  (cluster_rst_b[i]),
    .src_pulse  (psel_cluster_pulse[i]), //apb req signal in cluster_clk domain
    .dst_clk    (pic_clk),
    .dst_rst_b  (pic_rst_b),
    .clr_src_lvl(pready_cluster_pulse[i]), //use cluster_clk domain pready to clear the pusle-to-lvl register in cluster_clk domain
    .dst_pulse  (psel_pic_pulse[i]) //apb req signal in pic_clk domain      
  );
  always @ (posedge pic_clk or negedge pic_rst_b)
  begin
    if(~pic_rst_b)
      psel_pic_reg[i] <= 1'b0;
    else if(psel_pic_pulse[i]) //here record apb req in pic-clk domain
      psel_pic_reg[i] <= 1'b1;
    else if(trans_cmplt[i]) //trans_cmplt means clusters have received pready from pic 
      psel_pic_reg[i] <= 1'b0;
  end
  assign psel_pic[i] = ~trans_cmplt[i] & psel_pic_reg[i]; //if trans_cmplt is 1, means last apb req has completed, so this cycle psel_pic need to be 0
  always @ (posedge pic_clk or negedge pic_rst_b)
  begin
    if(~pic_rst_b)
      begin
        pwrite_pic[i]         <= 1'b0;
        paddr_pic[32*i+:32]   <= {32{1'b0}};
        pwdata_pic[32*i+:32]  <= {32{1'b0}};
        pprot_pic[2*i+:2]     <= {2{1'b0}};
      end    
    else if(psel_pic_pulse[i])
      begin
        pwrite_pic[i]         <= pwrite_cluster[i];
        paddr_pic[32*i+:32]   <= paddr_cluster[32*i+:32];
        pwdata_pic[32*i+:32]  <= pwdata_cluster[32*i+:32];
        pprot_pic[2*i+:2]     <= pprot_cluster[2*i+:2];
      end
  end
end
endgenerate
assign psel_pic_pulse[CLUSTER_NUM]       = 1'b0; //to fix lint
assign psel_cluster_pulse[CLUSTER_NUM]   = 1'b0;
assign pready_cluster_pulse[CLUSTER_NUM] = 1'b0;
assign psel_pic[CLUSTER_NUM]             = 1'b0;

assign value_zero = 1'b0;
always @ (*) //to fix lint
  begin
    psel_pic_reg[CLUSTER_NUM]       = value_zero;
    pwrite_pic[CLUSTER_NUM]         = value_zero;
    paddr_pic[32*CLUSTER_NUM]       = value_zero;
    pwdata_pic[32*CLUSTER_NUM]      = value_zero;
    pprot_pic[2*CLUSTER_NUM]        = value_zero;
    pready_cluster[CLUSTER_NUM]     = value_zero;
    prdata_cluster[32*CLUSTER_NUM]  = value_zero;
    pslverr_cluster[CLUSTER_NUM]    = value_zero;
  end

//apb cdc from pic_clk domain to cluster_clk domain
genvar j;
generate
for(j=0;j<CLUSTER_NUM;j=j+1)
begin:PIC_TO_CLUSTER
  pic_pready_pulse_cdc  x_pic_pready_pulse_cdc (
    .src_clk         (pic_clk),
    .src_rst_b       (pic_rst_b),
    .src_pulse       (pready_pic[j]),
    .dst_clk         (cluster_clk[j]),
    .dst_rst_b       (cluster_rst_b[j]),
    .dst_pulse       (pready_cluster_pulse[j]),
    .handshake_pulse (trans_cmplt[j]) 
  );
  always @ (posedge cluster_clk[j] or negedge cluster_rst_b[j])
  begin
    if(~cluster_rst_b[j])
      pready_cluster[j] <= 1'b0;
    else if(pready_cluster[j])
      pready_cluster[j] <= 1'b0;   
    else if(pready_cluster_pulse[j])
      pready_cluster[j] <= 1'b1;
  end

  always @ (posedge cluster_clk[j] or negedge cluster_rst_b[j])
  begin
    if(~cluster_rst_b[j])
      pslverr_cluster[j] <= 1'b0;
    else if(pready_cluster_pulse[j])
      pslverr_cluster[j] <= pslverr_pic[j];
  end

  always @ (posedge cluster_clk[j] or negedge cluster_rst_b[j])
  begin
    if(~cluster_rst_b[j])
      prdata_cluster[32*j+:32] <= {32{1'b0}};   
    else if(pready_cluster_pulse[j] & ~pwrite_cluster[j])
      prdata_cluster[32*j+:32] <= prdata_pic[32*j+:32];
  end
end
endgenerate
assign trans_cmplt[CLUSTER_NUM] = 1'b0; //to fix lint

endmodule
// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : pic_clint_func.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-1
// FUNCTION        : Clint implementation
// ******************************************************************************

module pic_clint_func(
  //input
  forever_apbclk,
  cpurst_b,
  pad_yy_icg_scan_en,
  paddr,
  penable,
  pprot,
  psel_clint,
  pwdata,
  pwrite,
  sysio_clint_mtime,

  //output
  pready_clint,
  perr_clint,
  prdata_clint,
  clint_core_ms_int,
  clint_core_ss_int,
  clint_core_mt_int,
  clint_core_st_int,
  plic_icg_en,
  apb_icg_en
`ifdef PIC_TEE_EXTENSION
  ,
  reg_parity_disable
`endif
  );

parameter HART_NUM   = 16;
parameter HART_EXIST = 256'hffff;

input             forever_apbclk;
input             cpurst_b;
input             pad_yy_icg_scan_en;
input   [31:0]    paddr;             
input             penable;           
input   [1 :0]    pprot;             
input             psel_clint;        
input   [31:0]    pwdata;            
input             pwrite;
input   [63:0]    sysio_clint_mtime;
output            perr_clint;        
output  [31:0]    prdata_clint;      
output            pready_clint;
output [HART_NUM-1:0] clint_core_ms_int;
output [HART_NUM-1:0] clint_core_ss_int;
output [HART_NUM-1:0] clint_core_mt_int;
output [HART_NUM-1:0] clint_core_st_int;
output                plic_icg_en;
output                apb_icg_en;
`ifdef PIC_TEE_EXTENSION
output                reg_parity_disable;
`endif


reg                      perr_clint;        
reg                      pready_clint;
reg [HART_NUM-1:0]       msip_reg;
reg [31:0]               mtimecmp_reg[HART_NUM-1:0];
reg [31:0]               mtimecmph_reg[HART_NUM-1:0];
reg [HART_NUM-1:0]       ssip_reg;
reg [31:0]               stimecmp_reg[HART_NUM-1:0];
reg [31:0]               stimecmph_reg[HART_NUM-1:0];
reg [63:0]               clint_mtime_reg;
`ifdef PIC_TEE_EXTENSION
reg                      reg_parity_disable;
`endif
reg [2:0]                icg_module_en_reg;
reg [HART_NUM-1:0]       clint_core_mt_int;
reg [HART_NUM-1:0]       clint_core_st_int;
wire [HART_NUM-1:0]      clint_core_ms_int;
wire [HART_NUM-1:0]      clint_core_ss_int;
wire [HART_NUM-1:0]      gen_mt_int;
wire [HART_NUM-1:0]      gen_st_int;

wire                     forever_apbclk;
wire                     cpurst_b;
wire                     pad_yy_icg_scan_en;
wire                     clint_icg_en;
wire                     plic_icg_en;
wire                     apb_icg_en;
wire                     clint_clk;
wire                     clint_clk_en;
wire                     mtime_clk;
wire [31:0]              paddr;             
wire                     penable;           
wire [1 :0]              pprot;                           
wire                     psel_clint;        
wire [31:0]              pwdata;            
wire                     pwrite; 
wire [31:0]              prdata_clint;
wire                     acc_err;
wire                     priv_err;
wire                     write_time_err;
wire                     clint_wen;
wire                     user_mode;
wire                     supv_mode;
wire                     mach_mode;
wire                     mreg_wen;
wire                     sreg_wen;
wire [63:0]              sysio_clint_mtime;
wire [31:0]              data_out;
wire [(HART_NUM+1)*16-1:0]   offset_4_vec;
wire [(HART_NUM+1)*16-1:0]   offset_8_vec;
wire [HART_NUM*16-1:0]   msip_addr_vec;
wire [HART_NUM*16-1:0]   mtimecmp_addr_vec;
wire [HART_NUM*16-1:0]   mtimecmph_addr_vec;
wire [15:0]              mtime_addr;
wire [15:0]              mtimeh_addr;
wire [HART_NUM*16-1:0]   ssip_addr_vec;
wire [HART_NUM*16-1:0]   stimecmp_addr_vec;
wire [HART_NUM*16-1:0]   stimecmph_addr_vec;
wire [15:0]              stime_addr;
wire [15:0]              stimeh_addr;
//wire [HART_NUM*16*6-1:0] clint_reg_addr_vec;
wire [HART_NUM-1:0]      msip_acc_vld;
wire [HART_NUM-1:0]      mtimecmp_acc_vld;
wire [HART_NUM-1:0]      mtimecmph_acc_vld;
wire                     mtime_acc_vld;
wire                     mtimeh_acc_vld;
wire [HART_NUM-1:0]      ssip_acc_vld;
wire [HART_NUM-1:0]      stimecmp_acc_vld;
wire [HART_NUM-1:0]      stimecmph_acc_vld;
wire                     stime_acc_vld;
wire                     stimeh_acc_vld;
wire [HART_NUM*6+3:0]    clint_reg_access_vld;
wire [HART_NUM-1:0]      msip_wen_vec;
wire [HART_NUM-1:0]      mtimecmp_wen_vec;
wire [HART_NUM-1:0]      mtimecmph_wen_vec;
wire [HART_NUM-1:0]      ssip_wen_vec;
wire [HART_NUM-1:0]      stimecmp_wen_vec;
wire [HART_NUM-1:0]      stimecmph_wen_vec;
wire [31:0]              msip_value[HART_NUM-1:0];
wire [31:0]              mtimecmp_value[HART_NUM-1:0];
wire [31:0]              mtimecmph_value[HART_NUM-1:0];
wire [31:0]              ssip_value[HART_NUM-1:0];
wire [31:0]              stimecmp_value[HART_NUM-1:0];
wire [31:0]              stimecmph_value[HART_NUM-1:0];
wire [(HART_NUM+1)*32-1:0] tmp_msip_out;
wire [(HART_NUM+1)*32-1:0] tmp_mtimecmp_out;
wire [(HART_NUM+1)*32-1:0] tmp_mtimecmph_out;
wire [(HART_NUM+1)*32-1:0] tmp_ssip_out;
wire [(HART_NUM+1)*32-1:0] tmp_stimecmp_out;
wire [(HART_NUM+1)*32-1:0] tmp_stimecmph_out;
wire [31:0]                msip_out;
wire [31:0]                mtimecmp_out;
wire [31:0]                mtimecmph_out;
wire [31:0]                mtime_out;
wire [31:0]                mtimeh_out;
wire [31:0]                ssip_out;
wire [31:0]                stimecmp_out;
wire [31:0]                stimecmph_out;
wire [31:0]                stime_out;
wire [31:0]                stimeh_out;
wire [15:0]                icg_en_addr;
wire                       icg_en_acc_vld;
wire                       icg_en_wen;
wire [31:0]                icg_module_en_value;
wire [31:0]                icg_module_en_out;
wire                       value_zero;

assign clint_clk_en = psel_clint | perr_clint | pready_clint | 
                      (|{1'b0,gen_mt_int[HART_NUM-1:0]}) | (|{1'b0,gen_st_int[HART_NUM-1:0]}) |
                      (|{1'b0,clint_core_mt_int[HART_NUM-1:0]}) | (|{1'b0,clint_core_st_int[HART_NUM-1:0]});
                      //add 1'b0 to fix lint
pic_gated_clk_cell  x_clint_gateclk (
  .clk_in             (forever_apbclk    ),
  .clk_out            (clint_clk         ),
  .external_en        (1'b0              ),
  .local_en           (clint_clk_en      ),
  .module_en          (clint_icg_en      ),
  .pad_yy_icg_scan_en (pad_yy_icg_scan_en)
);

//===================================================
// Clint Function Module
// 1. APB interface
// 2. Software and Time Register
// 3. CP0 interface
//===================================================

//===================================================
// 0. clint register address preparation
//===================================================
assign offset_4_vec[15:0] = 16'h0000;
assign offset_8_vec[15:0] = 16'h0000;
genvar offset_idx;
generate
for(offset_idx=1;offset_idx<HART_NUM+1;offset_idx=offset_idx+1) //adding idx=HART_NUM to fix lint
begin:ADDR_OFFSET
  assign offset_4_vec[offset_idx*16+:16] = offset_4_vec[(offset_idx-1)*16+:16] + 16'h0004; //[HART_NUM*16+16-1:HART_NUM*16] does not used
  assign offset_8_vec[offset_idx*16+:16] = offset_8_vec[(offset_idx-1)*16+:16] + 16'h0008;
end
endgenerate

genvar hart_idx;
generate
for(hart_idx=0;hart_idx<HART_NUM;hart_idx=hart_idx+1)
begin:CLINT_REG_BASE_ADDR
  assign msip_addr_vec[hart_idx*16+:16]      = 16'h0000 + offset_4_vec[hart_idx*16+:16]; //the address of MSIP0 is 16'h0000
  assign mtimecmp_addr_vec[hart_idx*16+:16]  = 16'h4000 + offset_8_vec[hart_idx*16+:16]; //the address of MTIMECMP0 is 16'h4000
  assign mtimecmph_addr_vec[hart_idx*16+:16] = 16'h4004 + offset_8_vec[hart_idx*16+:16]; //the address of MTIMECMPH0 is 16'h4000
  assign ssip_addr_vec[hart_idx*16+:16]      = 16'hc000 + offset_4_vec[hart_idx*16+:16]; //the address of MSIP0 is 16'hc000
  assign stimecmp_addr_vec[hart_idx*16+:16]  = 16'hd000 + offset_8_vec[hart_idx*16+:16]; //the address of MTIMECMP0 is 16'hd000
  assign stimecmph_addr_vec[hart_idx*16+:16] = 16'hd004 + offset_8_vec[hart_idx*16+:16]; //the address of MTIMECMPH0 is 16'hd000
end
endgenerate
assign mtime_addr[15:0]  = 16'hbff8;
assign mtimeh_addr[15:0] = 16'hbffc;
assign stime_addr[15:0]  = 16'hfff8;
assign stimeh_addr[15:0] = 16'hfffc;
assign icg_en_addr[15:0] = 16'hbff4;
//assign clint_reg_addr_vec[HART_NUM*16*6-1:0] ={stimecmph_addr_vec[HART_NUM*16-1:0],stimecmp_addr_vec[HART_NUM*16-1:0],ssip_addr_vec[HART_NUM*16-1:0],
//                                               mtimecmph_addr_vec[HART_NUM*16-1:0],mtimecmp_addr_vec[HART_NUM*16-1:0],msip_addr_vec[HART_NUM*16-1:0]};

genvar reg_access_idx;
generate //which register is access by paddr
for(reg_access_idx=0;reg_access_idx<HART_NUM;reg_access_idx=reg_access_idx+1)
begin:REG_ACCESS
  if(HART_EXIST[reg_access_idx])
    begin:REG_ACCESS_VLD
      assign msip_acc_vld[reg_access_idx]      = paddr[15:0] == msip_addr_vec[reg_access_idx*16+:16];
      assign mtimecmp_acc_vld[reg_access_idx]  = paddr[15:0] == mtimecmp_addr_vec[reg_access_idx*16+:16];
      assign mtimecmph_acc_vld[reg_access_idx] = paddr[15:0] == mtimecmph_addr_vec[reg_access_idx*16+:16];
      assign ssip_acc_vld[reg_access_idx]      = paddr[15:0] == ssip_addr_vec[reg_access_idx*16+:16];
      assign stimecmp_acc_vld[reg_access_idx]  = paddr[15:0] == stimecmp_addr_vec[reg_access_idx*16+:16];
      assign stimecmph_acc_vld[reg_access_idx] = paddr[15:0] == stimecmph_addr_vec[reg_access_idx*16+:16];
    end
  else
    begin:REG_ACCESS_VLD_DUMMY
      assign msip_acc_vld[reg_access_idx]      = 1'b0;
      assign mtimecmp_acc_vld[reg_access_idx]  = 1'b0;
      assign mtimecmph_acc_vld[reg_access_idx] = 1'b0;
      assign ssip_acc_vld[reg_access_idx]      = 1'b0;
      assign stimecmp_acc_vld[reg_access_idx]  = 1'b0;
      assign stimecmph_acc_vld[reg_access_idx] = 1'b0;
    end
end
endgenerate
assign mtime_acc_vld = paddr[15:0]  == mtime_addr[15:0];
assign mtimeh_acc_vld = paddr[15:0] == mtimeh_addr[15:0];
assign stime_acc_vld = paddr[15:0]  == stime_addr[15:0];
assign stimeh_acc_vld = paddr[15:0] == stimeh_addr[15:0];
assign icg_en_acc_vld = paddr[15:0] == icg_en_addr[15:0];

assign clint_reg_access_vld[HART_NUM*6+3:0] = {stimecmph_acc_vld[HART_NUM-1:0],stimecmp_acc_vld[HART_NUM-1:0],ssip_acc_vld[HART_NUM-1:0],
                                                stimeh_acc_vld,stime_acc_vld,
                                                mtimecmph_acc_vld[HART_NUM-1:0],mtimecmp_acc_vld[HART_NUM-1:0],msip_acc_vld[HART_NUM-1:0],
                                                mtimeh_acc_vld,mtime_acc_vld};

//===================================================
// 1. APB interface
//===================================================
assign clint_wen = psel_clint & pwrite & penable;

assign user_mode = pprot[1:0] == 2'b00;
assign supv_mode = pprot[1:0] == 2'b01;
assign mach_mode = pprot[1:0] == 2'b11;

assign mreg_wen  = mach_mode & clint_wen;
assign sreg_wen  = (mach_mode | supv_mode) & clint_wen;

// pready
always @ (posedge clint_clk or negedge cpurst_b)
begin
  if(~cpurst_b)
    pready_clint <= 1'b0;
  else if(psel_clint & ~penable)
    pready_clint <= 1'b1;
  else
    pready_clint <= 1'b0;
end

// perr
always @ (posedge clint_clk or negedge cpurst_b)
begin
  if(~cpurst_b)
    perr_clint <= 1'b0;
  else if(psel_clint & ~penable & (acc_err | priv_err | write_time_err))
    perr_clint <= 1'b1;
  else
    perr_clint <= 1'b0;
end

assign acc_err = ~(|clint_reg_access_vld[HART_NUM*6+3:0] | icg_en_acc_vld) ;

assign priv_err = (paddr[15:12] == 4'h0 | paddr[15:12] == 4'h4 | paddr[15:12] == 4'hB) & ~mach_mode 
               | (paddr[15:12] == 4'hC | paddr[15:12] == 4'hD | paddr[15:12] == 4'hF) &  user_mode;

assign write_time_err = (psel_clint & pwrite) & (mtime_acc_vld | mtimeh_acc_vld | stime_acc_vld | stimeh_acc_vld);

// prdata
assign prdata_clint[31:0] = {32{~perr_clint}} & data_out[31:0];

//===================================================
// 2. Software and Time Register
//===================================================
genvar wen_idx;
generate
for(wen_idx=0;wen_idx<HART_NUM;wen_idx=wen_idx+1)
begin:REG_WEN
  assign msip_wen_vec[wen_idx]      = mreg_wen & msip_acc_vld[wen_idx];
  assign mtimecmp_wen_vec[wen_idx]  = mreg_wen & mtimecmp_acc_vld[wen_idx];
  assign mtimecmph_wen_vec[wen_idx] = mreg_wen & mtimecmph_acc_vld[wen_idx];
  assign ssip_wen_vec[wen_idx]      = sreg_wen & ssip_acc_vld[wen_idx];
  assign stimecmp_wen_vec[wen_idx]  = sreg_wen & stimecmp_acc_vld[wen_idx];
  assign stimecmph_wen_vec[wen_idx] = sreg_wen & stimecmph_acc_vld[wen_idx];
end
endgenerate

genvar reg_idx;
generate
for(reg_idx=0;reg_idx<HART_NUM;reg_idx=reg_idx+1)
begin:CLINT_REGISTER
  if(HART_EXIST[reg_idx])
    begin:CLINT_REG
      // Machine Software Interrupt Pending Register
      always @ (posedge clint_clk or negedge cpurst_b)
      begin
        if(~cpurst_b)
          msip_reg[reg_idx] <= 1'b0;
        else if(msip_wen_vec[reg_idx])
          msip_reg[reg_idx] <= pwdata[0];
      end
      assign msip_value[reg_idx][31:0] = {{31{1'b0}}, msip_reg[reg_idx]};
    
      // Machine Time Compare Register Low
      always @ (posedge clint_clk or negedge cpurst_b)
      begin
      if(~cpurst_b)
        mtimecmp_reg[reg_idx][31:0] <= 32'hffffffff;
      else if(mtimecmp_wen_vec[reg_idx])
        mtimecmp_reg[reg_idx][31:0] <= pwdata[31:0];
      end
      assign mtimecmp_value[reg_idx][31:0] = mtimecmp_reg[reg_idx][31:0];
    
      // Machine Time Compare Register High
      always @ (posedge clint_clk or negedge cpurst_b)
      begin
      if(~cpurst_b)
        mtimecmph_reg[reg_idx][31:0] <= 32'hffffffff;
      else if(mtimecmph_wen_vec[reg_idx])
        mtimecmph_reg[reg_idx][31:0] <= pwdata[31:0];
      end
      assign mtimecmph_value[reg_idx][31:0] = mtimecmph_reg[reg_idx][31:0];
    
      // Supervisor Software Interrupt Pending Register
      always @ (posedge clint_clk or negedge cpurst_b)
      begin
        if(~cpurst_b)
          ssip_reg[reg_idx] <= 1'b0;
        else if(ssip_wen_vec[reg_idx])
          ssip_reg[reg_idx] <= pwdata[0];
      end
      assign ssip_value[reg_idx][31:0] = {{31{1'b0}}, ssip_reg[reg_idx]};
    
      // Supervisor Time Compare Register Low
      always @ (posedge clint_clk or negedge cpurst_b)
      begin
      if(~cpurst_b)
        stimecmp_reg[reg_idx][31:0] <= 32'hffffffff;
      else if(stimecmp_wen_vec[reg_idx])
        stimecmp_reg[reg_idx][31:0] <= pwdata[31:0];
      end
      assign stimecmp_value[reg_idx][31:0] = stimecmp_reg[reg_idx][31:0];
    
      // Supervisor Time Compare Register High
      always @ (posedge clint_clk or negedge cpurst_b)
      begin
      if(~cpurst_b)
        stimecmph_reg[reg_idx][31:0] <= 32'hffffffff;
      else if(stimecmph_wen_vec[reg_idx])
        stimecmph_reg[reg_idx][31:0] <= pwdata[31:0];
      end
      assign stimecmph_value[reg_idx][31:0] = stimecmph_reg[reg_idx][31:0];
    end //end:CLINT_REG
  else // this hart does not exist
    begin:CLINT_REG_DUMMY
        always @ (*)
        begin
          msip_reg[reg_idx]              = value_zero;
          mtimecmp_reg[reg_idx][31:0]    = {32{value_zero}};
          mtimecmph_reg[reg_idx][31:0]   = {32{value_zero}};
          ssip_reg[reg_idx]              = value_zero;
          stimecmp_reg[reg_idx][31:0]    = {32{value_zero}};
          stimecmph_reg[reg_idx][31:0]   = {32{value_zero}};
        end
        assign msip_value[reg_idx][31:0]      = {32{1'b0}};       
        assign mtimecmp_value[reg_idx][31:0]  = {32{1'b0}}; 
        assign mtimecmph_value[reg_idx][31:0] = {32{1'b0}}; 
        assign ssip_value[reg_idx][31:0]      = {32{1'b0}}; 
        assign stimecmp_value[reg_idx][31:0]  = {32{1'b0}}; 
        assign stimecmph_value[reg_idx][31:0] = {32{1'b0}};
    end
end
endgenerate

assign value_zero = 1'b0;
//read data
assign tmp_msip_out[31:0]      = {32{1'b0}};
assign tmp_mtimecmp_out[31:0]  = {32{1'b0}};
assign tmp_mtimecmph_out[31:0] = {32{1'b0}};
assign tmp_ssip_out[31:0]      = {32{1'b0}};
assign tmp_stimecmp_out[31:0]  = {32{1'b0}};
assign tmp_stimecmph_out[31:0] = {32{1'b0}};

genvar read_out_idx;
generate
for(read_out_idx=0;read_out_idx<HART_NUM;read_out_idx=read_out_idx+1)
begin:MSIP_READ_OUT
  assign tmp_msip_out[32*(read_out_idx+1)+:32]      = ({32{msip_acc_vld[read_out_idx]}} & msip_value[read_out_idx][31:0]) |
                                                      tmp_msip_out[32*read_out_idx+:32];
  assign tmp_mtimecmp_out[32*(read_out_idx+1)+:32]  = ({32{mtimecmp_acc_vld[read_out_idx]}} & mtimecmp_value[read_out_idx][31:0]) |
                                                      tmp_mtimecmp_out[32*read_out_idx+:32];
  assign tmp_mtimecmph_out[32*(read_out_idx+1)+:32] = ({32{mtimecmph_acc_vld[read_out_idx]}} & mtimecmph_value[read_out_idx][31:0]) |
                                                      tmp_mtimecmph_out[32*read_out_idx+:32];
  assign tmp_ssip_out[32*(read_out_idx+1)+:32]      = ({32{ssip_acc_vld[read_out_idx]}} & ssip_value[read_out_idx][31:0]) |
                                                      tmp_ssip_out[32*read_out_idx+:32];
  assign tmp_stimecmp_out[32*(read_out_idx+1)+:32]  = ({32{stimecmp_acc_vld[read_out_idx]}} & stimecmp_value[read_out_idx][31:0]) |
                                                      tmp_stimecmp_out[32*read_out_idx+:32];
  assign tmp_stimecmph_out[32*(read_out_idx+1)+:32] = ({32{stimecmph_acc_vld[read_out_idx]}} & stimecmph_value[read_out_idx][31:0]) |
                                                      tmp_stimecmph_out[32*read_out_idx+:32];
end
endgenerate
//only one of these six xxx_out have value, the other five xxx_out are zero
assign msip_out[31:0]          = tmp_msip_out[32*HART_NUM+:32];
assign mtimecmp_out[31:0]      = tmp_mtimecmp_out[32*HART_NUM+:32];
assign mtimecmph_out[31:0]     = tmp_mtimecmph_out[32*HART_NUM+:32]; 
assign mtime_out[31:0]         = {32{mtime_acc_vld}} & clint_mtime_reg[31:0];
assign mtimeh_out[31:0]        = {32{mtimeh_acc_vld}} & clint_mtime_reg[63:32];
assign ssip_out[31:0]          = tmp_ssip_out[32*HART_NUM+:32];
assign stimecmp_out[31:0]      = tmp_stimecmp_out[32*HART_NUM+:32];
assign stimecmph_out[31:0]     = tmp_stimecmph_out[32*HART_NUM+:32];
assign stime_out[31:0]         = {32{stime_acc_vld}} & clint_mtime_reg[31:0];
assign stimeh_out[31:0]        = {32{stimeh_acc_vld}} & clint_mtime_reg[63:32];
assign icg_module_en_out[31:0] = {32{icg_en_acc_vld}} & icg_module_en_value[31:0];

assign data_out[31:0]      = msip_out[31:0] | mtimecmp_out[31:0] | mtimecmph_out[31:0] | mtimeh_out[31:0] | mtime_out[31:0] |
                             ssip_out[31:0] | stimecmp_out[31:0] | stimecmph_out[31:0] | stimeh_out[31:0] | stime_out[31:0] |
                             icg_module_en_out[31:0];

//===================================================
// 3. CP0 interface
//===================================================
// sample mtime in apb
pic_gated_clk_cell  x_mtime_gated_clk (
  .clk_in             (forever_apbclk    ),
  .clk_out            (mtime_clk         ),
  .external_en        (1'b0              ),
  .local_en           (1'b1              ),
  .module_en          (clint_icg_en      ),
  .pad_yy_icg_scan_en (pad_yy_icg_scan_en)
); 

always@(posedge mtime_clk or negedge cpurst_b)
begin
  if(~cpurst_b)
    clint_mtime_reg[63:0] <= {64{1'b0}};
  else
    clint_mtime_reg[63:0] <= sysio_clint_mtime[63:0];
end

genvar to_core_idx;
generate
for(to_core_idx=0;to_core_idx<HART_NUM;to_core_idx=to_core_idx+1)
begin:CLINT_TO_CORE_PORT
  if(HART_EXIST[to_core_idx])
    begin:CLINT_TO_CORE
      assign clint_core_ms_int[to_core_idx] = msip_reg[to_core_idx];
      assign clint_core_ss_int[to_core_idx] = ssip_reg[to_core_idx];

      assign gen_mt_int[to_core_idx] = ~({mtimecmph_reg[to_core_idx][31:0], mtimecmp_reg[to_core_idx][31:0]} > clint_mtime_reg[63:0]);
      assign gen_st_int[to_core_idx] = ~({stimecmph_reg[to_core_idx][31:0], stimecmp_reg[to_core_idx][31:0]} > clint_mtime_reg[63:0]);
      always @ (posedge clint_clk or negedge cpurst_b)
        begin
        if(~cpurst_b)
           clint_core_mt_int[to_core_idx] <= 1'b0;
        else if(gen_mt_int[to_core_idx])
           clint_core_mt_int[to_core_idx] <= 1'b1;
        else if(~gen_mt_int[to_core_idx])
           clint_core_mt_int[to_core_idx] <= 1'b0;
        end
      always @ (posedge clint_clk or negedge cpurst_b)
        begin
        if(~cpurst_b)
           clint_core_st_int[to_core_idx] <= 1'b0;
        else if(gen_st_int[to_core_idx])
           clint_core_st_int[to_core_idx] <= 1'b1;
        else if(~gen_st_int[to_core_idx])
           clint_core_st_int[to_core_idx] <= 1'b0;
        end
    end
  else
    begin:CLINT_TO_CORE_DUMMY
        assign clint_core_ms_int[to_core_idx] = 1'b0;
        assign clint_core_ss_int[to_core_idx] = 1'b0;

        assign gen_mt_int[to_core_idx] = 1'b0;
        assign gen_st_int[to_core_idx] = 1'b0;
        always @ (*)
        begin
           clint_core_mt_int[to_core_idx] = value_zero;
           clint_core_st_int[to_core_idx] = value_zero;
        end
    end
end
endgenerate

//===================================================
// 4. clint icg module en
//===================================================
assign icg_en_wen = mreg_wen & icg_en_acc_vld;
always @ (posedge clint_clk or negedge cpurst_b)
  begin
  if(~cpurst_b)
    icg_module_en_reg[2:0] <= 3'h0;
  else if(icg_en_wen)
    icg_module_en_reg[2:0] <= pwdata[2:0];
  end
assign clint_icg_en              = icg_module_en_reg[0];
assign plic_icg_en               = icg_module_en_reg[1];
assign apb_icg_en                = icg_module_en_reg[2];

`ifdef PIC_TEE_EXTENSION
always @ (posedge clint_clk or negedge cpurst_b)
  begin
  if(~cpurst_b)
    reg_parity_disable <= 1'b0;
  else if(icg_en_wen)
    reg_parity_disable <= pwdata[3];
  end
assign icg_module_en_value[31:0] = {{28{1'b0}},reg_parity_disable,icg_module_en_reg[2:0]};
`else
assign icg_module_en_value[31:0] = {{29{1'b0}},icg_module_en_reg[2:0]};
`endif

`ifdef PIC_ASSERTION
genvar n;
generate
for(n=0;n<HART_NUM;n=n+1)
begin:SIP_ASSERTION
  if(HART_EXIST[n])
    begin:SIP_ASSERTION_TRUE
      property msip_write;
        @ (posedge clint_clk)
          msip_wen_vec[n] & pwdata[0] |=> clint_core_ms_int[n];
      endproperty
      assert property(msip_write);

      property ssip_write;
        @ (posedge clint_clk)
          ssip_wen_vec[n] & pwdata[0] |=> clint_core_ss_int[n];
      endproperty
      assert property(ssip_write);
    end
  else
    begin:SIP_ASSERTION_DUMMY

    end
end
endgenerate

genvar i;
generate
for(i=0;i<HART_NUM;i=i+1)
begin:TIP_ASSERTION
  if(HART_EXIST[i])
    begin:TIP_ASSERTION_TRUE
      property mtint_when_mtimecmp_have_0;
        @ (posedge forever_apbclk)
          ~(|{mtimecmph_reg[i][31:0], mtimecmp_reg[i][31:0]}) |=> clint_core_mt_int[i];
      endproperty
      assert property(mtint_when_mtimecmp_have_0);

      property stint_when_stimecmp_have_0;
        @ (posedge forever_apbclk)
          ~(|{stimecmph_reg[i][31:0], stimecmp_reg[i][31:0]}) |=> clint_core_st_int[i];
      endproperty
      assert property(stint_when_stimecmp_have_0);
    end
  else
    begin:TIP_ASSERTION_DUMMY

    end
end
endgenerate

property perr_must_happen_at_pready;
  @ (posedge clint_clk)
    perr_clint |-> pready_clint;
endproperty
assert property(perr_must_happen_at_pready);

`endif

endmodule
// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : pic_clint_top.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-1
// FUNCTION        : Clint implementation
// ******************************************************************************

module pic_clint_top(
  //input
  forever_apbclk,
  cpurst_b,
  pad_yy_icg_scan_en,
  paddr,
  penable,
  pprot,
  psel_clint,
  pwdata,
  pwrite,
  sysio_clint_mtime,

  //output
  pready_clint,
  perr_clint,
  prdata_clint,
  clint_core_ms_int,
  clint_core_ss_int,
  clint_core_mt_int,
  clint_core_st_int,
  plic_icg_en,
  apb_icg_en
`ifdef PIC_TEE_EXTENSION
  ,
  clint_plic_reg_par_disable
`endif
);

parameter CLUSTER_NUM          = 16;
parameter HART_NUM_PER_CLUSTER = 16;
parameter HART_EXIST           = 256'hffff;
parameter HART_NUM             = CLUSTER_NUM*HART_NUM_PER_CLUSTER;

input                 forever_apbclk;
input                 cpurst_b;
input                 pad_yy_icg_scan_en;
input   [31:0]        paddr;             
input                 penable;           
input   [1 :0]        pprot;             
input                 psel_clint;        
input   [31:0]        pwdata;            
input                 pwrite;
input   [63:0]        sysio_clint_mtime;
output                perr_clint;        
output  [31:0]        prdata_clint;      
output                pready_clint;
output [HART_NUM-1:0] clint_core_ms_int;
output [HART_NUM-1:0] clint_core_ss_int;
output [HART_NUM-1:0] clint_core_mt_int;
output [HART_NUM-1:0] clint_core_st_int;
output                plic_icg_en;
output                apb_icg_en;
`ifdef PIC_TEE_EXTENSION
output                clint_plic_reg_par_disable;
`endif
wire                forever_apbclk;
wire                cpurst_b;
wire                pad_yy_icg_scan_en;
wire  [31:0]        paddr;             
wire                penable;           
wire  [1 :0]        pprot;             
wire                psel_clint;        
wire  [31:0]        pwdata;            
wire                pwrite;
wire  [63:0]        sysio_clint_mtime;
wire                perr_clint;        
wire  [31:0]        prdata_clint;      
wire                pready_clint;
wire [HART_NUM-1:0] clint_core_ms_int;
wire [HART_NUM-1:0] clint_core_ss_int;
wire [HART_NUM-1:0] clint_core_mt_int;
wire [HART_NUM-1:0] clint_core_st_int;
wire                plic_icg_en;
wire                apb_icg_en;
`ifdef PIC_TEE_EXTENSION
wire                clint_plic_reg_par_disable;
`endif
//==========================================================
// Instance clint func
//==========================================================

pic_clint_func #(.HART_NUM   (HART_NUM),
             .HART_EXIST (HART_EXIST))
  x_pic_clint_func (
  //input
  .forever_apbclk     (forever_apbclk),
  .cpurst_b           (cpurst_b),
  .pad_yy_icg_scan_en (pad_yy_icg_scan_en),
  .paddr              (paddr),
  .penable            (penable),
  .pprot              (pprot),
  .psel_clint         (psel_clint),
  .pwdata             (pwdata),
  .pwrite             (pwrite),
  .sysio_clint_mtime  (sysio_clint_mtime),

  //output
  .pready_clint       (pready_clint),
  .perr_clint         (perr_clint),
  .prdata_clint       (prdata_clint),
  .clint_core_ms_int  (clint_core_ms_int),
  .clint_core_ss_int  (clint_core_ss_int),
  .clint_core_mt_int  (clint_core_mt_int),
  .clint_core_st_int  (clint_core_st_int),
  .plic_icg_en        (plic_icg_en),
  .apb_icg_en         (apb_icg_en)
`ifdef PIC_TEE_EXTENSION
  ,
  .reg_parity_disable (clint_plic_reg_par_disable)
`endif
  );
endmodule
// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : pic_gated_cell.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-6
// FUNCTION        : pic_gated_cell.v
// ******************************************************************************
// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : pic_gated_clk_cell.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-6
// FUNCTION        : pic_gated_clk_cell.v
// ******************************************************************************
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
// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : pic_plic_32to1_arb.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-1
// FUNCTION        : PLIC 32/2-stage granularity arbitor
//                   1. the total number of input source is 1024
//                   2. the input round define which round will be selected
//                   3. total round is 32
// ******************************************************************************

module pic_plic_32to1_arb(
  //input
  plic_clk,
  arb_ctrl_clk_en,
  plicrst_b,
  int_in_prio,
  int_in_req,
  int_select_round,
  ctrl_arb_new_arb_start,
  ciu_plic_icg_en,
  pad_yy_icg_scan_en,
  
  //output
  int_out_req,
  int_out_id,
  int_out_prio
);
parameter PRIO_BIT   = 5;
parameter ID_NUM     = 10;
parameter INT_NUM    = 1024;
parameter SEL_NUM    = 4;
parameter ECH_RD     = 32;

localparam ROUND_WIDTH= 5;
localparam ROUND      = INT_NUM/ECH_RD;
//localparam PRIO_BIG   = SEL_NUM*PRIO_BIT;
//localparam ID_BIG     = SEL_NUM*ID_NUM;
input                           plic_clk;
input                           arb_ctrl_clk_en;
input                           plicrst_b;
input   [INT_NUM-1:0]           int_in_req;
input   [INT_NUM*PRIO_BIT-1:0]  int_in_prio;
input   [ROUND_WIDTH-1:0]       int_select_round;  
input                           ctrl_arb_new_arb_start;
input                           ciu_plic_icg_en;
input                           pad_yy_icg_scan_en;

output  [ID_NUM-1:0]            int_out_id;
output                          int_out_req;
output  [PRIO_BIT-1:0]          int_out_prio;

wire                          arb_clk;
wire  [ECH_RD/4-1:0]          int_req_fst_stg;
wire  [ECH_RD/4*ID_NUM-1:0]   int_id_fst_stg;
wire  [ECH_RD/4*PRIO_BIT-1:0] int_prio_fst_stg;


pic_gated_clk_cell  x_arb_ctrl_ready_gateclk (
  .clk_in               (plic_clk            ),
  .clk_out              (arb_clk        ),
  .external_en          (1'b0                ),
  .local_en             (arb_ctrl_clk_en     ),
  .module_en            (ciu_plic_icg_en     ),
  .pad_yy_icg_scan_en (pad_yy_icg_scan_en)
);

//*************************************
//  instance first stage arbiter
//
//*************************************
pic_plic_32to1_stage1 #(.PRIO_BIT (PRIO_BIT),
                    .ID_NUM   (ID_NUM),
                    .INT_NUM  (INT_NUM),
                    .SEL_NUM  (SEL_NUM),
                    .ECH_RD   (ECH_RD) )
x_pic_plic_32to1_stage1 (
  //input
  .arb_clk          (arb_clk),
  .arb_ctrl_clk_en  (arb_ctrl_clk_en),
  .plicrst_b        (plicrst_b),
  .int_in_prio      (int_in_prio),
  .int_in_req       (int_in_req),
  .int_select_round (int_select_round),

  //output
  .int_req_fst_stg  (int_req_fst_stg),
  .int_id_fst_stg   (int_id_fst_stg),
  .int_prio_fst_stg (int_prio_fst_stg)
);

//*************************************
//  instance second stage arbiter
//
//*************************************
pic_plic_32to1_stage2 #(.PRIO_BIT (PRIO_BIT),
                    .ID_NUM   (ID_NUM),
                    .INT_NUM  (INT_NUM),
                    .ECH_RD   (ECH_RD) )
x_pic_plic_32to1_stage2 (
  //input
  .arb_clk          (arb_clk),
  .arb_ctrl_clk_en  (arb_ctrl_clk_en),
  .plicrst_b        (plicrst_b),  
  .int_req_fst_stg        (int_req_fst_stg),
  .int_id_fst_stg         (int_id_fst_stg),
  .int_prio_fst_stg       (int_prio_fst_stg),
  .ctrl_arb_new_arb_start (ctrl_arb_new_arb_start),
  
  //output
  .int_out_req            (int_out_req),
  .int_out_id             (int_out_id),
  .int_out_prio           (int_out_prio)
);

endmodule
// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : pic_plic_32to1_stage1.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-1
// FUNCTION        : The first stage of 32/2-stage granularity arbitor
//                    
// ******************************************************************************

module pic_plic_32to1_stage1(
  //input
  arb_clk,
  arb_ctrl_clk_en,
  plicrst_b,
  int_in_prio,
  int_in_req,
  int_select_round,

  //output
  int_req_fst_stg,
  int_id_fst_stg,
  int_prio_fst_stg
);

parameter PRIO_BIT   = 5;
parameter ID_NUM     = 10;
parameter INT_NUM    = 1024;
parameter SEL_NUM    = 4;
parameter ECH_RD     = 32;

localparam ROUND_WIDTH= 5;
localparam ROUND      = INT_NUM/ECH_RD;

input                           arb_clk;
input                           arb_ctrl_clk_en;
input                           plicrst_b;
input   [INT_NUM-1:0]           int_in_req;
input   [INT_NUM*PRIO_BIT-1:0]  int_in_prio;
input   [ROUND_WIDTH-1:0]       int_select_round;

output  [ECH_RD/4-1:0]          int_req_fst_stg;
output  [ECH_RD/4*ID_NUM-1:0]   int_id_fst_stg;
output  [ECH_RD/4*PRIO_BIT-1:0] int_prio_fst_stg;

wire    [INT_NUM*ID_NUM-1:0]    int_in_id;

wire    [ECH_RD-1:0]            int_req_aft_round;
wire    [ECH_RD*2-1:0]          int_req_high_bit_on_use;
wire    [ECH_RD*ID_NUM-1:0]     int_id_aft_round;
wire    [ECH_RD*PRIO_BIT-1:0]   int_prio_aft_round;

wire    [ECH_RD/4-1:0]          int_req_aft_frt_sel;
wire    [ECH_RD/4*ID_NUM-1:0]   int_id_aft_frt_sel;
wire    [ECH_RD/4*PRIO_BIT-1:0] int_prio_aft_frt_sel;

wire    [ECH_RD/4-1:0]          round_int_req_fst_en;

wire    [ROUND*2-1:0]            int_req_round_prepare[ECH_RD-1:0]; 
wire    [ROUND*ID_NUM-1:0]       int_id_round_prepare[ECH_RD-1:0];
wire    [ROUND*PRIO_BIT-1:0]     int_prio_round_prepare[ECH_RD-1:0];

reg    [ECH_RD/4-1:0]           int_req_fst_stg;
reg    [ECH_RD/4*ID_NUM-1:0]    int_id_fst_stg;
reg    [ECH_RD/4*PRIO_BIT-1:0]  int_prio_fst_stg;
//**********************************************************************
//  form the interrupt id
//
//**********************************************************************
genvar i;
generate
for(i=0;i<INT_NUM;i=i+1)
begin:ID_FORM
  assign int_in_id[i*ID_NUM+:ID_NUM] = $unsigned(i) & {ID_NUM{1'b1}};
end
endgenerate

//**********************************************************************
//  first.round preperation,and prio selection,  
//  32to1 selection and 4 prio selection
//
//**********************************************************************
genvar j,k;
generate
for(j=0;j<ROUND;j=j+1)
  begin: INT_INFO
    for(k=0;k<ECH_RD;k=k+1)
    begin: INT_INFO_IN
    assign int_req_round_prepare[k][j*2+:2]          =  {1'b0,int_in_req[ECH_RD*j+k]}; //add 1'b0 on high bit to fix lint
    assign int_id_round_prepare[k][j*ID_NUM+:ID_NUM] =  
                                            int_in_id[(ECH_RD*j+k)*ID_NUM+:ID_NUM];
    assign int_prio_round_prepare[k][j*PRIO_BIT+:PRIO_BIT] =
                                      int_in_prio[(ECH_RD*j+k)*PRIO_BIT+:PRIO_BIT]; 
    end 
  end
endgenerate

genvar m;
generate
for(m=0;m<INT_NUM/ROUND;m=m+1)
begin: ROUND_SEL
   pic_plic_nor_sel #(.SEL_BIT(5),
            .SEL_NUM(ROUND),
            .DATA(ID_NUM)  )  x_round_sel_id(
          .data_in(int_id_round_prepare[m]),
          .sel_in(int_select_round),
          .data_out(int_id_aft_round[m*ID_NUM+:ID_NUM])
          );
    pic_plic_nor_sel #(.SEL_BIT(5),
            .SEL_NUM(ROUND),
            .DATA(PRIO_BIT)  )  x_round_sel_prio(
          .data_in(int_prio_round_prepare[m]),
          .sel_in(int_select_round),
          .data_out(int_prio_aft_round[m*PRIO_BIT+:PRIO_BIT])
          );
     pic_plic_nor_sel #(.SEL_BIT(5),
            .SEL_NUM(ROUND),
            .DATA(2)  )  x_round_sel_req(
          .data_in(int_req_round_prepare[m]),
          .sel_in(int_select_round),
          .data_out(int_req_high_bit_on_use[m*2+:2])
          );
    assign int_req_aft_round[m] = int_req_high_bit_on_use[m*2];
end
endgenerate

//*************************************
//  first stage prio selection
//
//*************************************

genvar n;
generate
for(n=0;n<ECH_RD/SEL_NUM;n=n+1)
begin:FIRST_SEL
  //pic_plic_granu_arb #(.SEL_NUM(SEL_NUM),
  //                    .ID_NUM(ID_NUM),
  //                    .PRIO_BIT(PRIO_BIT))first_prio_selection(
  pic_plic_granu2_arb #( .ID_NUM(ID_NUM),
                        .PRIO_BIT(PRIO_BIT))x_first_prio_selection(
    .int_in_prio(int_prio_aft_round[n*SEL_NUM*PRIO_BIT+:SEL_NUM*PRIO_BIT]),
    .int_in_id(int_id_aft_round[n*SEL_NUM*ID_NUM+:SEL_NUM*ID_NUM]),
    .int_in_req(int_req_aft_round[n*SEL_NUM+:SEL_NUM]),
    
    .int_out_req(int_req_aft_frt_sel[n]),
    .int_out_id(int_id_aft_frt_sel[n*ID_NUM+:ID_NUM]),
    .int_out_prio(int_prio_aft_frt_sel[n*PRIO_BIT+:PRIO_BIT])
  );
end
endgenerate
//************************************
//  first stage int flop
//
//************************************

genvar fst_idx;
generate
for(fst_idx=0;fst_idx<ECH_RD/SEL_NUM;fst_idx=fst_idx+1)
begin:FIRST_SEL_FLOP
  always @(posedge arb_clk or negedge plicrst_b)
  begin
    if(~plicrst_b)
    begin
      int_id_fst_stg[fst_idx*ID_NUM+:ID_NUM]          <= {ID_NUM{1'b0}};
      int_prio_fst_stg[fst_idx*PRIO_BIT+:PRIO_BIT]    <= {PRIO_BIT{1'b0}};
    end
    else if(int_req_aft_frt_sel[fst_idx] & arb_ctrl_clk_en) //add arb_ctrl_clk_en for formal sec
    begin
      int_id_fst_stg[fst_idx*ID_NUM+:ID_NUM]  <= int_id_aft_frt_sel[fst_idx*ID_NUM+:ID_NUM];
      int_prio_fst_stg[fst_idx*PRIO_BIT+:PRIO_BIT] <= 
                                int_prio_aft_frt_sel[fst_idx*PRIO_BIT+:PRIO_BIT];
    end
  end
  always @(posedge arb_clk or negedge plicrst_b)
  begin
    if(~plicrst_b)
      int_req_fst_stg[fst_idx]   <=1'b0;
    else if(round_int_req_fst_en[fst_idx] & arb_ctrl_clk_en) //add arb_ctrl_clk_en for formal sec
      int_req_fst_stg[fst_idx]   <= int_req_aft_frt_sel[fst_idx];
  end
  assign round_int_req_fst_en[fst_idx] = int_req_fst_stg[fst_idx] 
                                     ^ int_req_aft_frt_sel[fst_idx];
end

endgenerate

endmodule
// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : pic_plic_32to1_stage2.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-1
// FUNCTION        : The second stage of 32/2-stage granularity arbitor
//                    
// ******************************************************************************

module pic_plic_32to1_stage2 (
  //input
  arb_clk,
  arb_ctrl_clk_en,
  plicrst_b,
  int_req_fst_stg,
  int_id_fst_stg,
  int_prio_fst_stg,
  ctrl_arb_new_arb_start,
  
  //output
  int_out_req,
  int_out_id,
  int_out_prio
);

parameter PRIO_BIT   = 5;
parameter ID_NUM     = 10;
parameter INT_NUM    = 1024;
parameter ECH_RD     = 32;

input                          arb_clk;
input                          arb_ctrl_clk_en;
input                          plicrst_b;
input  [ECH_RD/4-1:0]          int_req_fst_stg;
input  [ECH_RD/4*ID_NUM-1:0]   int_id_fst_stg;
input  [ECH_RD/4*PRIO_BIT-1:0] int_prio_fst_stg;
input                         ctrl_arb_new_arb_start; 

output  [ID_NUM-1:0]            int_out_id;
output                          int_out_req;
output  [PRIO_BIT-1:0]          int_out_prio;

wire    [9-1:0]           int_req_secd_tmp_sel;
wire    [9*ID_NUM-1:0]    int_id_secd_tmp_sel;
wire    [9*PRIO_BIT-1:0]  int_prio_secd_tmp_sel;

wire                            round_int_req_secd_en;

wire                            int_req_aft_secd_sel;
wire    [ID_NUM-1:0]            int_id_aft_secd_sel;
wire    [PRIO_BIT-1:0]          int_prio_aft_secd_sel;

reg                            int_req_secd_stg;
reg    [ID_NUM-1:0]            int_id_secd_stg;
reg    [PRIO_BIT-1:0]          int_prio_secd_stg;

//**********************************************************************
//  secod stage: 9 to 1 prio selction.  
//  
//**********************************************************************
pic_plic_granu_arb #(.SEL_NUM(9),
                    .SEL_BIT(4),
                      .ID_NUM(ID_NUM),
                      .PRIO_BIT(PRIO_BIT))
                      x_secd_prio_selection10(
    .int_in_prio(int_prio_secd_tmp_sel[9*PRIO_BIT-1:0]),
    .int_in_id(int_id_secd_tmp_sel[9*ID_NUM-1:0]),
    .int_in_req(int_req_secd_tmp_sel[9-1:0]),
    
    .int_out_req(int_req_aft_secd_sel),
    .int_out_id(int_id_aft_secd_sel[ID_NUM-1:0]),
    .int_out_prio(int_prio_aft_secd_sel[PRIO_BIT-1:0])
  );
assign int_req_secd_tmp_sel[8:0] = {int_req_fst_stg[7:0],int_req_secd_stg};
assign int_prio_secd_tmp_sel[9*PRIO_BIT-1:0]  = {int_prio_fst_stg[8*PRIO_BIT-1:0],
                                                 int_prio_secd_stg[PRIO_BIT-1:0]};
assign int_id_secd_tmp_sel[9*ID_NUM-1:0]      = {int_id_fst_stg[8*ID_NUM-1:0],
                                                 int_id_secd_stg[ID_NUM-1:0]};  


always @(posedge arb_clk or negedge plicrst_b)
  begin
    if(~plicrst_b)
    begin
      int_id_secd_stg[ID_NUM-1:0]        <= {ID_NUM{1'b0}};
      int_prio_secd_stg[PRIO_BIT-1:0]    <= {PRIO_BIT{1'b0}};
    end
    else if(int_req_aft_secd_sel & arb_ctrl_clk_en) //add arb_ctrl_clk_en for formal sec 
    begin
      int_id_secd_stg[ID_NUM-1:0]    <= int_id_aft_secd_sel[ID_NUM-1:0];
      int_prio_secd_stg[PRIO_BIT-1:0]  <= 
                                int_prio_aft_secd_sel[PRIO_BIT-1:0];
    end
end
always @(posedge arb_clk or negedge plicrst_b)
begin
  if(~plicrst_b)
    int_req_secd_stg   <=1'b0;
  else if(ctrl_arb_new_arb_start & arb_ctrl_clk_en) //add arb_ctrl_clk_en for formal sec
    int_req_secd_stg   <= 1'b0;
  else if(round_int_req_secd_en & arb_ctrl_clk_en)
    int_req_secd_stg   <= int_req_aft_secd_sel;
end
assign round_int_req_secd_en = int_req_secd_stg 
                                   ^ int_req_aft_secd_sel;

assign int_out_req                 = int_req_secd_stg;
assign int_out_id[ID_NUM-1:0]      = int_id_secd_stg[ID_NUM-1:0];
assign int_out_prio[PRIO_BIT-1:0]  = int_prio_secd_stg[PRIO_BIT-1:0];

endmodule
// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : pic_plic_apb_1tox_matrix.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-1
// FUNCTION        : APB bus matrix interface
//                   1. parameterize  matrix with flop out
//                   2. need to config the region address
// ******************************************************************************

module pic_plic_apb_1tox_matrix(
  //input
  pclk,
  prst_b,
  slv_paddr,
  slv_psel,
  slv_pprot,
  slv_penable,
  slv_pwrite,
  slv_pwdata,
  slv_psec,
  mst_pready,
  mst_prdata,
  mst_pslverr,
  mst_base_addr,
  mst_base_addr_msk,
  other_slv_sel,
  ciu_plic_icg_en,
  pad_yy_icg_scan_en,
  //output
  mst_psel,
  mst_penable,
  mst_pprot,
  mst_paddr,
  mst_pwrite,
  mst_pwdata,
  mst_psec,
  slv_pready,
  slv_prdata,
  slv_pslverr
);
parameter ADDR   = 27;  // the address width
parameter SLAVE  = 4;   // the number of the slave
parameter FLOP   = 1;   // whether it will be floped out

localparam SLV_DIV_TMP = SLAVE/4;
localparam SLV_LEFT    = SLAVE - SLV_DIV_TMP*4;
localparam SLV_DIV     = SLV_LEFT>0 ? SLV_DIV_TMP+1 : SLV_DIV_TMP;
input                     pclk;
input                     prst_b;
input  [ADDR-1:0]         slv_paddr;
input                     slv_psel;
input  [1:0]              slv_pprot;
input                     slv_penable;
input                     slv_pwrite;
input  [31:0]             slv_pwdata;
input  [SLAVE-1:0]        mst_pready;
input  [32*SLAVE-1:0]     mst_prdata;
input  [SLAVE-1:0]        mst_pslverr;
input  [ADDR*SLAVE-1:0]   mst_base_addr;
input  [ADDR*SLAVE-1:0]   mst_base_addr_msk;
input  [SLAVE-1:0]        other_slv_sel;
input                     ciu_plic_icg_en;
input                     pad_yy_icg_scan_en;
input                     slv_psec;

  //output
output [SLAVE-1:0]        mst_psel;
output [SLAVE*2-1:0]      mst_pprot;
output [SLAVE-1:0]        mst_penable;
output [ADDR*SLAVE-1:0]   mst_paddr;
output [SLAVE-1:0]        mst_pwrite;
output [32*SLAVE-1:0]     mst_pwdata;
output [SLAVE-1:0]        mst_psec;
output                    slv_pready;
output [31:0]             slv_prdata;
output                    slv_pslverr;

// wire definition
wire   [SLAVE-1:0]        slave_addr_sel;
wire                      apb_vlalid_select;
wire   [SLAVE-1:0]        apb_mst_psel_pre;
wire   [SLAVE-1:0]        apb_mst_penable_pre;
wire   [SLAVE:0]          slv_pready_vld;
wire                      slv_pready_pre;
wire   [32*(SLAVE+1)-1:0] slv_pready_data_pre;
wire   [31:0]             slv_prdata_pre;
wire   [SLAVE:0]          slv_pready_pslverr_pre;
wire                      slv_pslverr_pre;
wire   [SLAVE-1:0]        tmp_mst_sel_clk;
wire   [SLAVE-1:0]        mst_sel_clk;
wire   [SLAVE-1:0]          mst_sel_clk_en;
wire   [SLAVE-1:0]        ori_tmp_mst_sel_clk_en;
wire   [SLAVE-1:0]        conv_tmp_mst_sel_clk_en;
wire                      slv_ready_clk;
wire                      slv_ready_clk_en;
wire   [SLAVE:0]          mst_psel_exp;
wire                      flop_inout;
//reg definition
reg    [31:0]             slv_prdata_flop;
reg                       slv_pready_flop;
reg                       slv_pslverr_flop;
reg    [SLAVE-1:0]        mst_psel_flop;
reg    [SLAVE-1:0]        mst_psec_flop;
reg    [SLAVE*2-1:0]      mst_pprot_flop;
reg    [SLAVE-1:0]        mst_penable_flop;
reg    [SLAVE-1:0]        mst_pwrite_flop;
reg    [SLAVE*ADDR-1:0]   mst_paddr_flop;
reg    [SLAVE*32-1:0]     mst_pwdata_flop;
//**********************************************************************
// code start
//
//**********************************************************************
// the base address should not be overlaped, if does, both slave will be
// selected
genvar i;
generate
  for(i=0;i<SLAVE;i=i+1)
  begin:MASTER_ADDR_SEL
    assign slave_addr_sel[i] = ((slv_paddr[ADDR-1:0] & mst_base_addr_msk[i*ADDR+:ADDR])
                                == mst_base_addr[i*ADDR+:ADDR]) | other_slv_sel[i];
  end
endgenerate
  
assign apb_vlalid_select                   = slv_psel & ~slv_penable;
assign apb_mst_psel_pre[SLAVE-1:0]         = {SLAVE{apb_vlalid_select}} 
                                             & slave_addr_sel[SLAVE-1:0];
assign apb_mst_penable_pre[SLAVE-1:0]      = {SLAVE{slv_penable}};
assign slv_pready_vld[SLAVE:0]           =    ({1'b0,mst_psel[SLAVE-1:0]
                                                     & mst_penable[SLAVE-1:0]
                                                     & mst_pready[SLAVE-1:0]});
assign slv_pready_pre                      = |slv_pready_vld[SLAVE:0] |
                                             ((~(|mst_psel_exp[SLAVE:0])) & slv_psel & slv_penable);
assign mst_psel_exp[SLAVE:0]               = {1'b0,mst_psel[SLAVE-1:0]};
assign slv_pready_data_pre[31:0]           = {32{1'b0}};
assign slv_pready_pslverr_pre[0]           = 1'b0;
genvar k;
generate
for(k=0;k<SLAVE;k=k+1)
begin:MASTER_PENABLE_REG
  assign slv_pready_data_pre[(k+2)*32-1:(k+1)*32]  = ({32{slv_pready_vld[k]}} 
                                                  & mst_prdata[(k+1)*32-1:k*32])
                                                | slv_pready_data_pre[(k+1)*32-1:k*32];
  assign slv_pready_pslverr_pre[k+1]     =  slv_pready_vld[k] & mst_pslverr[k] 
                                            | slv_pready_pslverr_pre[k];                                            
end
endgenerate
assign slv_prdata_pre[31:0]            = slv_pready_data_pre[(SLAVE+1)*32-1:SLAVE*32];
assign slv_pslverr_pre                 = slv_pready_pslverr_pre[SLAVE] |
                                         ((~(|mst_psel_exp[SLAVE:0])) & slv_psel & slv_penable);
pic_gated_clk_cell  x_slv_ready_gateclk (
  .clk_in               (pclk            ),
  .clk_out              (slv_ready_clk       ),
  .external_en          (1'b0                ),
  .local_en             (slv_ready_clk_en    ),
  .module_en            (ciu_plic_icg_en     ),
  .pad_yy_icg_scan_en (pad_yy_icg_scan_en)
);
assign   slv_ready_clk_en = slv_psel | slv_pready_pre;

always @ (posedge slv_ready_clk or negedge prst_b)
begin
  if(~prst_b)
    slv_prdata_flop[31:0] <= {32{1'b0}};
  else if(slv_pready_pre & ~slv_pwrite)
    slv_prdata_flop[31:0] <= slv_prdata_pre[31:0];
end

always @ (posedge slv_ready_clk or negedge prst_b)
begin
  if(~prst_b)
    slv_pslverr_flop <= 1'b0;
  else if(slv_pready_pre )
    slv_pslverr_flop  <= slv_pslverr_pre;
end


always @ (posedge slv_ready_clk or negedge prst_b)
begin
  if(~prst_b)
    slv_pready_flop <= 1'b0;
  else if(apb_vlalid_select)
    slv_pready_flop <= 1'b0;
  else if(slv_pready_pre)
    slv_pready_flop <= 1'b1;
end

 
genvar idx;
generate
for(idx=0;idx<SLAVE;idx=idx+1)
begin:GATE_CLK
  pic_gated_clk_cell  x_mst_sel_gateclk (
    .clk_in               (pclk                ),
    .clk_out              (tmp_mst_sel_clk[idx]     ),
    .external_en          (1'b0                ),
    .local_en             (mst_sel_clk_en[idx]   ),
    .module_en            (ciu_plic_icg_en       ),
    .pad_yy_icg_scan_en (pad_yy_icg_scan_en)
  );
  assign  mst_sel_clk_en[idx]   = conv_tmp_mst_sel_clk_en[idx];
  assign  mst_sel_clk[idx]      = tmp_mst_sel_clk[idx];
end
endgenerate
assign ori_tmp_mst_sel_clk_en[SLAVE-1:0]      = apb_mst_psel_pre[SLAVE-1:0] |
                                                mst_psel_flop[SLAVE-1:0];
assign conv_tmp_mst_sel_clk_en[SLAVE-1:0]     = ori_tmp_mst_sel_clk_en[SLAVE-1:0];

genvar j;
generate
for(j=0;j<SLAVE;j=j+1)
begin: MST_FLOP
  always @(posedge mst_sel_clk[j] or negedge prst_b)
  begin
    if(~prst_b)
      mst_psel_flop[j] <= 1'b0;
    else if(apb_mst_psel_pre[j])
      mst_psel_flop[j] <= 1'b1;
    else if(mst_penable_flop[j] & mst_pready[j])
      mst_psel_flop[j] <= 1'b0;
  end
  always @(posedge mst_sel_clk[j] or negedge prst_b)
  begin
    if(~prst_b)
      mst_penable_flop[j]          <= {1'b0};
    else if(apb_mst_psel_pre[j])
      mst_penable_flop[j]          <= 1'b0;
    else if(mst_psel[j])
      mst_penable_flop[j]          <= ~(mst_penable[j] & mst_pready[j]);
  end
  always @(posedge mst_sel_clk[j] or negedge prst_b)
  begin
    if(~prst_b)
    begin
      mst_pprot_flop[j*2+:2]        <= {2{1'b0}};
      mst_pwrite_flop[j]            <= {1'b0};
      mst_paddr_flop[j*ADDR+:ADDR]  <= {ADDR{1'b0}};
      mst_pwdata_flop[j*32+:32]     <= {32{1'b0}};
    end
    else if(mst_sel_clk_en[j]) 
    begin
      mst_pprot_flop[j*2+:2]         <= {{slv_pprot[1:0]}};
      mst_pwrite_flop[j]             <= {{slv_pwrite}};
      mst_paddr_flop[j*ADDR+:ADDR]   <= {{slv_paddr[ADDR-1:0]}};
      mst_pwdata_flop[j*32+:32]      <= {{slv_pwdata[31:0]}};
    end
  end
  always @(posedge mst_sel_clk[j] or negedge prst_b)
  begin
    if(~prst_b)
      mst_psec_flop[j]          <= {1'b0};
    else if(mst_sel_clk_en[j])
      mst_psec_flop[j]          <= slv_psec;
  end
end
endgenerate
assign flop_inout                = $unsigned(FLOP) & 1'b1;
assign mst_psel[SLAVE-1:0]       = flop_inout ? mst_psel_flop[SLAVE-1:0] 
                                        : apb_mst_psel_pre[SLAVE-1:0];
assign mst_pprot[SLAVE*2-1:0]    = flop_inout ? mst_pprot_flop[SLAVE*2-1:0] 
                                        : {SLAVE{slv_pprot[1:0]}};
assign mst_paddr[SLAVE*ADDR-1:0] = flop_inout ? mst_paddr_flop[SLAVE*ADDR-1:0] 
                                        : {SLAVE{slv_paddr[ADDR-1:0]}};
assign mst_penable[SLAVE-1:0]    = flop_inout ? mst_penable_flop[SLAVE-1:0]
                                        : {SLAVE{slv_penable}};
assign mst_pwrite[SLAVE-1:0]     = flop_inout ? mst_pwrite_flop[SLAVE-1:0]
                                        : {SLAVE{slv_pwrite}};
assign mst_pwdata[SLAVE*32-1:0]  = flop_inout ? mst_pwdata_flop[SLAVE*32-1:0]
                                        : {SLAVE{slv_pwdata[31:0]}};
assign slv_pready                = flop_inout ? slv_pready_flop
                                        : slv_pready_pre;
assign slv_pslverr               = flop_inout ? slv_pslverr_flop
                                         : slv_pslverr_pre;                               
assign slv_prdata[31:0]          = flop_inout  ? slv_prdata_flop[31:0] 
                                        : slv_prdata_pre[31:0];         
assign mst_psec[SLAVE-1:0]        = mst_psec_flop[SLAVE-1:0];

endmodule                                        

  
  

// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : pic_plic_apb_1tox_matrix_for_ie.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-1
// FUNCTION        : APB bus matrix interface
//                   1. parameterize  matrix with flop out
//                   2. need to config the region address
// ******************************************************************************

module pic_plic_apb_1tox_matrix_for_ie(
  //input
  pclk,
  prst_b,
  slv_paddr,
  slv_psel,
  slv_pprot,
  slv_penable,
  slv_pwrite,
  slv_pwdata,
  slv_psec,
  mst_pready,
  mst_prdata,
  mst_pslverr,
  mst_base_addr,
  mst_base_addr_msk,
  other_slv_sel,
  ciu_plic_icg_en,
  pad_yy_icg_scan_en,
  //output
  mst_psel,
  mst_penable,
  mst_pprot,
  mst_paddr,
  mst_pwrite,
  mst_pwdata,
  mst_psec,
  slv_pready,
  slv_prdata,
  slv_pslverr
);
parameter ADDR        = 27;  // the address width
parameter SLAVE       = 4;   // the number of the slave
parameter SLAVE_EXIST = 256'hffff;
parameter FLOP        = 1;   // whether it will be floped out

localparam SLV_DIV_TMP = SLAVE/4;
localparam SLV_LEFT    = SLAVE - SLV_DIV_TMP*4;
localparam SLV_DIV     = SLV_LEFT>0 ? SLV_DIV_TMP+1 : SLV_DIV_TMP;
input                     pclk;
input                     prst_b;
input  [ADDR-1:0]         slv_paddr;
input                     slv_psel;
input  [1:0]              slv_pprot;
input                     slv_penable;
input                     slv_pwrite;
input  [31:0]             slv_pwdata;
input  [SLAVE-1:0]        mst_pready;
input  [32*SLAVE-1:0]     mst_prdata;
input  [SLAVE-1:0]        mst_pslverr;
input  [ADDR*SLAVE-1:0]   mst_base_addr;
input  [ADDR*SLAVE-1:0]   mst_base_addr_msk;
input  [SLAVE-1:0]        other_slv_sel;
input                     ciu_plic_icg_en;
input                     pad_yy_icg_scan_en;
input                     slv_psec;

  //output
output [SLAVE-1:0]        mst_psel;
output [SLAVE*2-1:0]      mst_pprot;
output [SLAVE-1:0]        mst_penable;
output [ADDR*SLAVE-1:0]   mst_paddr;
output [SLAVE-1:0]        mst_pwrite;
output [32*SLAVE-1:0]     mst_pwdata;
output [SLAVE-1:0]        mst_psec;
output                    slv_pready;
output [31:0]             slv_prdata;
output                    slv_pslverr;

// wire definition
wire   [SLAVE-1:0]        slave_addr_sel;
wire                      apb_vlalid_select;
wire   [SLAVE-1:0]        apb_mst_psel_pre;
wire   [SLAVE-1:0]        apb_mst_penable_pre;
wire   [SLAVE:0]          slv_pready_vld;
wire                      slv_pready_pre;
wire   [32*(SLAVE+1)-1:0] slv_pready_data_pre;
wire   [31:0]             slv_prdata_pre;
wire   [SLAVE-1:0]        sel_nonexistent_slave;
wire   [SLAVE-1:0]        apb_sel_nonexistent_slave;
wire   [SLAVE:0]          slv_pready_pslverr_pre;
wire                      slv_pslverr_pre;
wire   [SLAVE-1:0]        tmp_mst_sel_clk;
wire   [SLAVE-1:0]        mst_sel_clk;
wire   [SLAVE-1:0]          mst_sel_clk_en;
wire   [SLAVE-1:0]        ori_tmp_mst_sel_clk_en;
wire   [SLAVE-1:0]        conv_tmp_mst_sel_clk_en;
wire                      slv_ready_clk;
wire                      slv_ready_clk_en;
wire   [SLAVE:0]          mst_psel_exp;
wire                      flop_inout;
wire                      value_zero;
//reg definition
reg    [31:0]             slv_prdata_flop;
reg                       slv_pready_flop;
reg                       slv_pslverr_flop;
reg    [SLAVE-1:0]        mst_psel_flop;
reg    [SLAVE-1:0]        mst_psec_flop;
reg    [SLAVE*2-1:0]      mst_pprot_flop;
reg    [SLAVE-1:0]        mst_penable_flop;
reg    [SLAVE-1:0]        mst_pwrite_flop;
reg    [SLAVE*ADDR-1:0]   mst_paddr_flop;
reg    [SLAVE*32-1:0]     mst_pwdata_flop;
//**********************************************************************
// code start
//
//**********************************************************************
// the base address should not be overlaped, if does, both slave will be
// selected
genvar i;
generate
  for(i=0;i<SLAVE;i=i+1)
  begin:MASTER_ADDR_SEL_
  if(SLAVE_EXIST[i])
    begin:MASTER_ADDR_SEL_TRUE
      assign slave_addr_sel[i]        = ((slv_paddr[ADDR-1:0] & mst_base_addr_msk[i*ADDR+:ADDR])
                                        == mst_base_addr[i*ADDR+:ADDR]) | other_slv_sel[i];
      assign sel_nonexistent_slave[i] = 1'b0;
    end
  else
    begin:MASTER_ADDR_SEL_NON
      assign slave_addr_sel[i]        = ((slv_paddr[ADDR-1:0] & mst_base_addr_msk[i*ADDR+:ADDR])
                                        == mst_base_addr[i*ADDR+:ADDR]) | other_slv_sel[i];
      assign sel_nonexistent_slave[i] = slave_addr_sel[i];
    end
  end
endgenerate
  
assign apb_vlalid_select                    = slv_psel & ~slv_penable;
assign apb_mst_psel_pre[SLAVE-1:0]          = {SLAVE{apb_vlalid_select}} 
                                              & slave_addr_sel[SLAVE-1:0];
assign apb_sel_nonexistent_slave[SLAVE-1:0] = {SLAVE{apb_vlalid_select}} 
                                              & sel_nonexistent_slave[SLAVE-1:0];
assign apb_mst_penable_pre[SLAVE-1:0]       = {SLAVE{slv_penable}};
assign slv_pready_vld[SLAVE:0]              =    ({1'b0,mst_psel[SLAVE-1:0]
                                                     & mst_penable[SLAVE-1:0]
                                                     & mst_pready[SLAVE-1:0]});
assign slv_pready_pre                       = (|slv_pready_vld[SLAVE:0]) |
                                              ((~(|mst_psel_exp[SLAVE:0])) & slv_psel & slv_penable) |
                                              (|{1'b0,apb_sel_nonexistent_slave[SLAVE-1:0]}); //add 1'b0 to fix lint
assign mst_psel_exp[SLAVE:0]               = {1'b0,mst_psel[SLAVE-1:0]};
assign slv_pready_data_pre[31:0]           = {32{1'b0}};
assign slv_pready_pslverr_pre[0]           = 1'b0;
genvar k;
generate
for(k=0;k<SLAVE;k=k+1)
begin:MASTER_PENABLE_REG
if(SLAVE_EXIST[k])
  begin:MASTER_PENABLE_REG_TRUE
    assign slv_pready_data_pre[(k+2)*32-1:(k+1)*32]  = ({32{slv_pready_vld[k]}} 
                                                    & mst_prdata[(k+1)*32-1:k*32])
                                                  | slv_pready_data_pre[(k+1)*32-1:k*32];
    assign slv_pready_pslverr_pre[k+1]     =  slv_pready_vld[k] & mst_pslverr[k] 
                                              | slv_pready_pslverr_pre[k];                                            
  end
else //if this hart is not exist
  begin:MASTER_PENABLE_REG_NONE
    assign slv_pready_data_pre[(k+2)*32-1:(k+1)*32]  = slv_pready_data_pre[(k+1)*32-1:k*32];
    assign slv_pready_pslverr_pre[k+1]     =  apb_sel_nonexistent_slave[k]
                                              | slv_pready_pslverr_pre[k]; 
  end
end
endgenerate
assign slv_prdata_pre[31:0]            = slv_pready_data_pre[(SLAVE+1)*32-1:SLAVE*32];
assign slv_pslverr_pre                 = slv_pready_pslverr_pre[SLAVE] |
                                         ((~(|mst_psel_exp[SLAVE:0])) & slv_psel & slv_penable);
pic_gated_clk_cell  x_slv_ready_gateclk (
  .clk_in               (pclk            ),
  .clk_out              (slv_ready_clk       ),
  .external_en          (1'b0                ),
  .local_en             (slv_ready_clk_en    ),
  .module_en            (ciu_plic_icg_en     ),
  .pad_yy_icg_scan_en (pad_yy_icg_scan_en)
);
assign   slv_ready_clk_en = slv_psel | slv_pready_pre;

always @ (posedge slv_ready_clk or negedge prst_b)
begin
  if(~prst_b)
    slv_prdata_flop[31:0] <= {32{1'b0}};
  else if(slv_pready_pre & ~slv_pwrite)
    slv_prdata_flop[31:0] <= slv_prdata_pre[31:0];
end

always @ (posedge slv_ready_clk or negedge prst_b)
begin
  if(~prst_b)
    slv_pslverr_flop <= 1'b0;
  else if(slv_pready_pre )
    slv_pslverr_flop  <= slv_pslverr_pre;
end


always @ (posedge slv_ready_clk or negedge prst_b)
begin
  if(~prst_b)
    slv_pready_flop <= 1'b0;
  else if(apb_vlalid_select)
    slv_pready_flop <= 1'b0;
  else if(slv_pready_pre)
    slv_pready_flop <= 1'b1;
end

genvar idx;
generate 
for(idx=0;idx<SLAVE;idx=idx+1)
begin:GATE_CLK
if(SLAVE_EXIST[idx])
  begin:GATE_CLK_TRUE
    pic_gated_clk_cell  x_mst_sel_gateclk (
      .clk_in               (pclk                ),
      .clk_out              (tmp_mst_sel_clk[idx]     ),
      .external_en          (1'b0                ),
      .local_en             (mst_sel_clk_en[idx]   ),
      .module_en            (ciu_plic_icg_en       ),
      .pad_yy_icg_scan_en (pad_yy_icg_scan_en)
    );
    assign  mst_sel_clk_en[idx]   = conv_tmp_mst_sel_clk_en[idx];
    assign  mst_sel_clk[idx]      = tmp_mst_sel_clk[idx];
  end
else //if this slave is not exist
  begin:GATE_CLK_DUMMY
      assign mst_sel_clk_en[idx]   = 1'b0;
      assign tmp_mst_sel_clk[idx]  = 1'b0;
      assign mst_sel_clk[idx]      = tmp_mst_sel_clk[idx];
  end
end
endgenerate
assign ori_tmp_mst_sel_clk_en[SLAVE-1:0]      = apb_mst_psel_pre[SLAVE-1:0] |
                                                mst_psel_flop[SLAVE-1:0];
assign conv_tmp_mst_sel_clk_en[SLAVE-1:0]     = ori_tmp_mst_sel_clk_en[SLAVE-1:0];

genvar j;
generate
for(j=0;j<SLAVE;j=j+1)
begin:MST_FLOP
if(SLAVE_EXIST[j])
  begin: MST_FLOP_TRUE
    always @(posedge mst_sel_clk[j] or negedge prst_b)
    begin
      if(~prst_b)
        mst_psel_flop[j] <= 1'b0;
      else if(apb_mst_psel_pre[j])
        mst_psel_flop[j] <= 1'b1;
      else if(mst_penable_flop[j] & mst_pready[j])
        mst_psel_flop[j] <= 1'b0;
    end
    always @(posedge mst_sel_clk[j] or negedge prst_b)
    begin
      if(~prst_b)
        mst_penable_flop[j]          <= {1'b0};
      else if(apb_mst_psel_pre[j])
        mst_penable_flop[j]          <= 1'b0;
      else if(mst_psel[j])
        mst_penable_flop[j]          <= ~(mst_penable[j] & mst_pready[j]);
    end
    always @(posedge mst_sel_clk[j] or negedge prst_b)
    begin
      if(~prst_b)
      begin
        mst_pprot_flop[j*2+:2]        <= {2{1'b0}};
        mst_pwrite_flop[j]            <= {1'b0};
        mst_paddr_flop[j*ADDR+:ADDR]  <= {ADDR{1'b0}};
        mst_pwdata_flop[j*32+:32]     <= {32{1'b0}};
      end
      else if(mst_sel_clk_en[j])
      begin
        mst_pprot_flop[j*2+:2]         <= {{slv_pprot[1:0]}};
        mst_pwrite_flop[j]             <= {{slv_pwrite}};
        mst_paddr_flop[j*ADDR+:ADDR]   <= {{slv_paddr[ADDR-1:0]}};
        mst_pwdata_flop[j*32+:32]      <= {{slv_pwdata[31:0]}};
      end
    end
    always @(posedge mst_sel_clk[j] or negedge prst_b)
    begin
      if(~prst_b)
        mst_psec_flop[j]          <= {1'b0};
      else if(mst_sel_clk_en[j])
        mst_psec_flop[j]          <= slv_psec;
    end
  end
else //if this slave is not exist
  begin: MST_FLOP_DUMMY
    always @ (*)
      begin
        mst_psel_flop[j]              = value_zero;
        mst_penable_flop[j]           = value_zero;
        mst_pprot_flop[j*2+:2]        = {2{value_zero}};
        mst_pwrite_flop[j]            = value_zero;
        mst_paddr_flop[j*ADDR+:ADDR]  = {ADDR{value_zero}};
        mst_pwdata_flop[j*32+:32]     = {32{value_zero}};
        mst_psec_flop[j]              = value_zero;
      end
  end
end
endgenerate
assign value_zero = 1'b0;

assign flop_inout                = $unsigned(FLOP) & 1'b1;
assign mst_psel[SLAVE-1:0]       = flop_inout ? mst_psel_flop[SLAVE-1:0] 
                                        : apb_mst_psel_pre[SLAVE-1:0];
assign mst_pprot[SLAVE*2-1:0]    = flop_inout ? mst_pprot_flop[SLAVE*2-1:0] 
                                        : {SLAVE{slv_pprot[1:0]}};
assign mst_paddr[SLAVE*ADDR-1:0] = flop_inout ? mst_paddr_flop[SLAVE*ADDR-1:0] 
                                        : {SLAVE{slv_paddr[ADDR-1:0]}};
assign mst_penable[SLAVE-1:0]    = flop_inout ? mst_penable_flop[SLAVE-1:0]
                                        : {SLAVE{slv_penable}};
assign mst_pwrite[SLAVE-1:0]     = flop_inout ? mst_pwrite_flop[SLAVE-1:0]
                                        : {SLAVE{slv_pwrite}};
assign mst_pwdata[SLAVE*32-1:0]  = flop_inout ? mst_pwdata_flop[SLAVE*32-1:0]
                                        : {SLAVE{slv_pwdata[31:0]}};
assign slv_pready                = flop_inout ? slv_pready_flop
                                        : slv_pready_pre;
assign slv_pslverr               = flop_inout ? slv_pslverr_flop
                                         : slv_pslverr_pre;                               
assign slv_prdata[31:0]          = flop_inout  ? slv_prdata_flop[31:0] 
                                        : slv_prdata_pre[31:0];         
assign mst_psec[SLAVE-1:0]        = mst_psec_flop[SLAVE-1:0];

endmodule                                        

  
  

// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : pic_plic_arb_ctrl.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-1
// FUNCTION        : PLIC arbitor controler
//                   1. depend on the interrupt source number, there will
//                   be 1-32 rounds selection
//                   2. this module gen
//                   3. 
// ******************************************************************************

module pic_plic_arb_ctrl(
  plic_clk,
  arb_ctrl_int_prio,
  arb_ctrl_int_req,
  arbx_hartx_mint_req,
  arbx_hartx_sint_req,
  arbx_hreg_claim_reg_ready,
  arbx_hreg_arb_start_ack,
  ctrl_arb_int_prio,
  ctrl_arb_int_req,
  ctrl_arb_select_round,
  ctrl_arb_new_arb_start,
  hreg_arbx_arb_start,
  hreg_arbx_arb_flush,
  hreg_arbx_mint_claim,
  hreg_arbx_sint_claim,
  hreg_arbx_int_en,
  hreg_arbx_int_mmode,
  hreg_arbx_prio_sth,
  hreg_arbx_prio_mth,
  kid_yy_int_prio,
  kid_yy_int_req,
  int_sec_infor,
  ctrl_xx_core_sec,
  ctrl_xx_amp_mode,
  ciu_plic_icg_en,
  pad_yy_icg_scan_en,
  arb_ctrl_clk_en,
  plicrst_b
);

parameter         INT_NUM       = 1024;
parameter         ECH_RD        = 32;
parameter         PRIO_BIT      = 5;

parameter        RD_NUM        = INT_NUM/ECH_RD;
parameter        CLOG_BIT      = $clog2(RD_NUM);
parameter        RD_BIT        = (CLOG_BIT==0) ? 1 : CLOG_BIT;
parameter        IDLE          = 2'b00;
parameter        ARBTRATE      = 2'b01;
parameter        ARB_DELAY     = 2'b10;
parameter        WRITE_CLAIM   = 2'b11;
parameter        ADD_NUM       = 1024-INT_NUM;
parameter        ADD_RD_WITH   = 5 - RD_BIT;

// &Ports; @26
input                           plic_clk;              
input   [PRIO_BIT  :0]          arb_ctrl_int_prio;        
input                           arb_ctrl_int_req;         
input                           hreg_arbx_arb_start;   
input                           hreg_arbx_arb_flush;
input                           hreg_arbx_mint_claim;      
input                           hreg_arbx_sint_claim;      
input   [INT_NUM-1:0]           hreg_arbx_int_en;         
input   [INT_NUM-1:0]           hreg_arbx_int_mmode; 
input   [PRIO_BIT-1   :0]       hreg_arbx_prio_sth;        
input   [PRIO_BIT-1   :0]       hreg_arbx_prio_mth;        
input   [INT_NUM*PRIO_BIT-1:0]  kid_yy_int_prio;          
input   [INT_NUM-1:0]           kid_yy_int_req;  
input   [INT_NUM-1:0]           int_sec_infor;
input                           ctrl_xx_core_sec;
input                           ctrl_xx_amp_mode;
input                           plicrst_b;      
input                           ciu_plic_icg_en;
input                           pad_yy_icg_scan_en;

output                          arbx_hartx_sint_req;       
output                          arbx_hartx_mint_req;       
output                          arbx_hreg_claim_reg_ready; 
output  [1024*(PRIO_BIT+1)-1:0] ctrl_arb_int_prio;        
output  [1023:0]                ctrl_arb_int_req;         
output  [4   :0]                ctrl_arb_select_round;    
output                          arbx_hreg_arb_start_ack;
output                          arb_ctrl_clk_en;
output                          ctrl_arb_new_arb_start;

// &Regs; @27
reg     [RD_BIT-1:0]            arb_round;                
reg     [1   :0]                arb_state;                
reg     [1   :0]                arb_state_next;           
reg                             sint_out_req;              
reg                             mint_out_req;              
reg     [PRIO_BIT-1:0]          sint_out_prio;
reg     [PRIO_BIT-1:0]          mint_out_prio;

// &Wires; @28
//wire                            arb_clk;              
wire    [PRIO_BIT    :0]        arb_ctrl_int_prio;        
wire                            arb_ctrl_int_req;         
wire                            arb_end;                  
wire                            arb_on;                   
wire                            arbx_core_sint_req_en;     
wire                            arbx_core_mint_req_en;     
wire                            arbx_hartx_sint_req;       
wire                            arbx_hartx_mint_req;       
wire                            arbx_hreg_claim_reg_ready; 
wire    [1024*(PRIO_BIT+1)-1:0]     ctrl_arb_int_prio;
wire    [1025*(PRIO_BIT+1)-1:0]     ctrl_arb_int_prio_fix_lint;
wire    [1023:0]                ctrl_arb_int_req;         
wire    [4   :0]                ctrl_arb_select_round;
wire    [5   :0]                ctrl_arb_select_round_fix_lint;
wire                            hreg_arbx_arb_start;      
wire                            hreg_arbx_mint_claim;      
wire                            hreg_arbx_sint_claim;      
wire    [INT_NUM-1:0]           hreg_arbx_int_en;         
wire    [PRIO_BIT-1   :0]       hreg_arbx_prio_sth;        
wire    [PRIO_BIT-1   :0]       hreg_arbx_prio_mth;        
wire    [INT_NUM-1:0]           int_in_req;               
wire    [1023:0]                int_req_1024;
wire    [1024:0]                int_req_1024_fix_lint;
wire    [INT_NUM*PRIO_BIT-1:0]  kid_yy_int_prio;    
wire    [INT_NUM*(PRIO_BIT+1)-1:0]  form_kid_yy_int_prio;    
wire                            int_out_update;
wire    [INT_NUM-1:0]           kid_yy_int_req;
wire    [INT_NUM-1:0]           hreg_arbx_vld_int_mmode;
wire                            plicrst_b;       
wire                            arb_ctrl_clk;
wire                            arb_ctrl_clk_en;
wire                            sint_on_clear;
wire                            mint_on_clear;
wire                            arb_ctrl_mint_req;
wire                            arb_ctrl_sint_req;
wire    [INT_NUM-2:0]           int_sec_ctrl;
pic_gated_clk_cell  x_arb_ctrl_ready_gateclk (
  .clk_in               (plic_clk            ),
  .clk_out              (arb_ctrl_clk        ),
  .external_en          (1'b0                ),
  .local_en             (arb_ctrl_clk_en     ),
  .module_en            (ciu_plic_icg_en     ),
  .pad_yy_icg_scan_en (pad_yy_icg_scan_en)
);
assign   arb_ctrl_clk_en =  hreg_arbx_arb_start |
                            arb_state[1:0] != IDLE |
                            hreg_arbx_arb_flush |
                            mint_out_req |
                            sint_out_req;
//assign arb_clk = arb_ctrl_clk;
//*************************************
// form to the bigest number 
// INT source
//*************************************

assign int_sec_ctrl[INT_NUM-2:0]            = (int_sec_infor[INT_NUM-1:1] 
                                              ~^ {(INT_NUM-1){ctrl_xx_core_sec}}) | 
                                              {(INT_NUM-1){~ctrl_xx_amp_mode}};
assign int_in_req[INT_NUM-1:0]              = kid_yy_int_req[INT_NUM-1:0] 
                                              & {hreg_arbx_int_en[INT_NUM-1:1],1'b1}
                                              & {int_sec_ctrl[INT_NUM-2:0],1'b1};
assign int_req_1024_fix_lint[1024:0]        = {{ADD_NUM+1{1'b0}},int_in_req[INT_NUM-1:0]};
assign int_req_1024[1023:0]                 = int_req_1024_fix_lint[1023:0];
assign ctrl_arb_int_req[1023:0]             = int_req_1024[1023:0];
 
genvar i;
generate
for(i=0;i<INT_NUM;i=i+1)
begin:FM_PRIO
  assign hreg_arbx_vld_int_mmode[i]                         = hreg_arbx_int_mmode[i] & (|kid_yy_int_prio[i*PRIO_BIT+:PRIO_BIT]); 
  //set 0 at top bit of priority if mint priority is 0
  assign form_kid_yy_int_prio[(PRIO_BIT+1)*i+:(PRIO_BIT+1)] = {hreg_arbx_vld_int_mmode[i],kid_yy_int_prio[i*PRIO_BIT+:PRIO_BIT]};
end
endgenerate
assign ctrl_arb_int_prio_fix_lint[1025*(PRIO_BIT+1)-1:0]    = {{(ADD_NUM+1)*(PRIO_BIT+1){1'b0}},
                                                              form_kid_yy_int_prio[INT_NUM*(PRIO_BIT+1)-1:0]};

assign ctrl_arb_int_prio[1024*(PRIO_BIT+1)-1:0]             = ctrl_arb_int_prio_fix_lint[1024*(PRIO_BIT+1)-1:0];
//*************************************
// the arbtration round, which 
// is parameterized
//*************************************
always @(posedge arb_ctrl_clk or negedge plicrst_b)
begin
  if(~plicrst_b)
    arb_round[RD_BIT-1:0] <= {RD_BIT{1'b0}};
  else if(hreg_arbx_arb_flush)
    arb_round[RD_BIT-1:0] <= {RD_BIT{1'b0}};
  else if(arb_end)
    arb_round[RD_BIT-1:0] <= {RD_BIT{1'b0}};
  else if(arb_on)
    arb_round[RD_BIT-1:0] <= arb_round[RD_BIT-1:0] + 1'b1;

end
assign arb_end   = arb_round[RD_BIT-1:0] == (RD_NUM-1);
assign arb_on    = arb_state[1:0] == ARBTRATE;
assign ctrl_arb_select_round_fix_lint[5:0] = {{ADD_RD_WITH+1{1'b0}},arb_round[RD_BIT-1:0]}; // +1 to fix {0{1'b0}} lint warning
assign ctrl_arb_select_round[4:0] = ctrl_arb_select_round_fix_lint[4:0];
//*************************************
// the arbitration state machine
//*************************************
always @(posedge arb_ctrl_clk or negedge plicrst_b)
begin
  if(~plicrst_b)
    arb_state[1:0] <= IDLE;
  else if(hreg_arbx_arb_flush)
    arb_state[1:0] <= IDLE;
  else if(arb_ctrl_clk_en)
    arb_state[1:0] <= arb_state_next[1:0];
end
// &CombBeg; @79
always @( arb_end
       or arb_state[1:0]
       or hreg_arbx_arb_start)
begin
  case(arb_state[1:0])
    IDLE:       begin 
                if(hreg_arbx_arb_start)
                  arb_state_next[1:0] = ARBTRATE;
                else
                  arb_state_next[1:0] = IDLE;
                end
    ARBTRATE:   begin 
                if(arb_end)
                  arb_state_next[1:0] = ARB_DELAY;
                else
                  arb_state_next[1:0] = ARBTRATE;
                end
    ARB_DELAY:  arb_state_next[1:0]   = WRITE_CLAIM;
    WRITE_CLAIM:arb_state_next[1:0]   = IDLE;
    default: arb_state_next[1:0] = IDLE;
  endcase
// &CombEnd @97
end
assign arbx_hreg_arb_start_ack        = (arb_state[1:0] == IDLE) &
                                        (arb_state_next[1:0] == ARBTRATE);
//it should happen in the first cycle of arbitration
assign ctrl_arb_new_arb_start         = (arb_state[1:0] == ARBTRATE) & 
                                        (arb_round[RD_BIT-1:0] == {RD_BIT{1'b0}});
assign arbx_hreg_claim_reg_ready      = arb_ctrl_int_req 
                                        & (arb_state[1:0]  == WRITE_CLAIM);
//*************************************
// the int request will be floped
//*************************************
// the second arbitration: threshold
assign arb_ctrl_sint_req               = arb_ctrl_int_req 
                                        & (arb_state[1:0]  == WRITE_CLAIM)
                                        // the s threashold
                                        & ~arb_ctrl_int_prio[PRIO_BIT];
assign arb_ctrl_mint_req               = arb_ctrl_int_req 
                                        & (arb_state[1:0]  == WRITE_CLAIM)
                                        // the m threashold
                                        & arb_ctrl_int_prio[PRIO_BIT];

assign arbx_core_sint_req_en           = arb_ctrl_int_req 
                                        & (arb_state[1:0]  == WRITE_CLAIM)
                                        // the s threashold
                                        & ~arb_ctrl_int_prio[PRIO_BIT]
                                        & (arb_ctrl_int_prio[PRIO_BIT-1:0] 
                                             > hreg_arbx_prio_sth[PRIO_BIT-1:0]);
assign arbx_core_mint_req_en           = arb_ctrl_int_req 
                                        & (arb_state[1:0]  == WRITE_CLAIM)
                                        // the m threashold
                                        &  arb_ctrl_int_prio[PRIO_BIT]
                                        & (arb_ctrl_int_prio[PRIO_BIT-1:0] 
                                             > hreg_arbx_prio_mth[PRIO_BIT-1:0]);
//this is used fo threashold update to clear out
assign mint_on_clear                   = mint_out_req 
                                         & ((mint_out_prio[PRIO_BIT-1:0] 
                                             <= hreg_arbx_prio_mth[PRIO_BIT-1:0]));    
assign sint_on_clear                   = sint_out_req 
                                         & ((sint_out_prio[PRIO_BIT-1:0] 
                                             <= hreg_arbx_prio_sth[PRIO_BIT-1:0]));
assign int_out_update                 = (arb_state[1:0]  == WRITE_CLAIM);
always @ (posedge arb_ctrl_clk or negedge plicrst_b)
begin
  if(~plicrst_b)
    sint_out_req    <= 1'b0;
  else if(hreg_arbx_sint_claim | sint_on_clear)
    sint_out_req    <= 1'b0;
  else if(int_out_update)
    sint_out_req    <= arbx_core_sint_req_en;
end 
always @ (posedge arb_ctrl_clk or negedge plicrst_b)
begin
  if(~plicrst_b)
    sint_out_prio[PRIO_BIT-1:0]  <= {PRIO_BIT{1'b0}};
  else if(arb_ctrl_sint_req)
    sint_out_prio[PRIO_BIT-1:0]  <= arb_ctrl_int_prio[PRIO_BIT-1:0];
end
always @ (posedge arb_ctrl_clk or negedge plicrst_b)
begin
  if(~plicrst_b)
    mint_out_req    <= 1'b0;
  else if(hreg_arbx_mint_claim | mint_on_clear)
    mint_out_req    <= 1'b0;
  else if(int_out_update)
    mint_out_req    <= arbx_core_mint_req_en;
end 
always @ (posedge arb_ctrl_clk or negedge plicrst_b)
begin
  if(~plicrst_b)
    mint_out_prio[PRIO_BIT-1:0]  <= {PRIO_BIT{1'b0}};
  else if(arb_ctrl_mint_req)
    mint_out_prio[PRIO_BIT-1:0]  <= arb_ctrl_int_prio[PRIO_BIT-1:0];
end

assign arbx_hartx_mint_req    = mint_out_req;    
assign arbx_hartx_sint_req    = sint_out_req;    
// &ModuleEnd; @120
endmodule



// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : pic_plic_ctrl.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-1
// FUNCTION        : pic_plic_ctrl.v
// ******************************************************************************

module pic_plic_ctrl(
  plicrst_b,
  plic_clk,
  bus_mtx_plic_ctrl_psel,
  bus_mtx_plic_ctrl_penable,
  bus_mtx_plic_ctrl_paddr,
  bus_mtx_plic_ctrl_pprot,
  bus_mtx_plic_ctrl_pwdata,
  bus_mtx_plic_ctrl_pwrite,
  bus_mtx_plic_ctrl_psec,
  ciu_plic_icg_en,
  pad_yy_icg_scan_en,
  plic_ctrl_prdata,
  plic_ctrl_pslverr,
  plic_ctrl_pready,
  ctrl_xx_s_permission_t,
  ctrl_xx_s_permission_nt,
  ctrl_xx_amp_mode,
  ctrl_xx_amp_lock
`ifdef PIC_TEE_EXTENSION
  ,
  reg_parity_disable,
  plic_pad_reg_parity_error
`endif
);
input               plic_clk;
input               plicrst_b;
input               bus_mtx_plic_ctrl_psel;
input               bus_mtx_plic_ctrl_penable;
input      [1:0]    bus_mtx_plic_ctrl_pprot;
input     [11:0]    bus_mtx_plic_ctrl_paddr;
input     [31:0]    bus_mtx_plic_ctrl_pwdata;
input               bus_mtx_plic_ctrl_pwrite;
input               bus_mtx_plic_ctrl_psec;
input               ciu_plic_icg_en;
input               pad_yy_icg_scan_en;
`ifdef PIC_TEE_EXTENSION
input               reg_parity_disable;
output              plic_pad_reg_parity_error;
`endif

output    [31:0]    plic_ctrl_prdata;
output              plic_ctrl_pslverr;
output              plic_ctrl_pready;
output              ctrl_xx_s_permission_t;
output              ctrl_xx_s_permission_nt;
output              ctrl_xx_amp_mode;
output              ctrl_xx_amp_lock;
  
wire                plic_ctrl_apb_acc_en;
wire                plic_ctrl_apb_write_en;
wire                plic_ctrl_apb_read_en;
wire                plic_ctrl_reg_wr_en;
wire                plic_ctrl_pslverr_pre;
wire                plic_ctrl_clk_en;
wire                plic_ctrl_clk;
wire                plic_ctrl_reg_rd_en;
wire                plic_ctrl_reg_sel_en;

reg                 plic_ctrl_pready;
wire                plic_t_amp_write_en;

reg                 plic_s_permission_t;
wire                plic_s_permision_t_wen;
wire                plic_s_permission_t_clean;
wire                plic_s_permission_t_pre;
wire                plic_ctrl_reg_t_write_en;
`ifdef PIC_TEE_EXTENSION
wire                plic_pad_reg_parity_error;
reg                 plic_per_parity;
`endif

`ifdef PIC_PLIC_SEC
reg                 plic_amp;
reg                 plic_sec_lock;
reg                 plic_s_permission;
wire                plic_s_permission_norm_wen;
wire                plic_s_permission_norm_clean;
wire                plic_s_permission_norm_pre;
wire                plic_ctrl_reg_norm_write_en;
wire                sec_ctrl_reg_sel_en;

wire                plic_ctrl_nt_vio;
wire                plic_sec_ctrl_reg_wr_en;
wire                plic_sec_ctrl_reg_rd_en;
wire    [31:0]      plic_sec_ctrl_reg_prdata;
wire    [31:0]      plic_ctrl_reg_prdata;

`else
wire                plic_amp;
`endif
assign plic_ctrl_apb_acc_en     = bus_mtx_plic_ctrl_psel 
                                  & ~bus_mtx_plic_ctrl_penable;

assign plic_ctrl_apb_write_en   = plic_ctrl_apb_acc_en 
                                  & bus_mtx_plic_ctrl_pwrite 
                                  & ~plic_ctrl_pslverr_pre;

assign plic_ctrl_apb_read_en    = plic_ctrl_apb_acc_en 
                                  & ~bus_mtx_plic_ctrl_pwrite 
                                  & ~plic_ctrl_pslverr_pre;

assign plic_ctrl_reg_sel_en     = (bus_mtx_plic_ctrl_paddr[11:0] == 12'hffc);
assign plic_ctrl_reg_wr_en      = plic_ctrl_apb_write_en 
                                  & plic_ctrl_reg_sel_en;
assign plic_ctrl_reg_rd_en      = plic_ctrl_apb_read_en & plic_ctrl_reg_sel_en;




`ifdef PIC_PLIC_SEC

// the slave err pre will different when 
assign plic_ctrl_pslverr_pre    = (((bus_mtx_plic_ctrl_paddr[11:0] ~= 12'hffc) 
                                     & (bus_mtx_plic_ctrl_paddr[11:0] ~= 12'hff8)) | 
                                   (bus_mtx_plic_ctrl_pprot[1:0]  ~= 2'b11)) 
                                 | plic_ctrl_nt_vio;
assign plic_ctrl_nt_vio         = plic_amp 
                                  & (bus_mtx_plic_ctrl_paddr[11:0] == 12'hff8) 
                                  & ~bus_mtx_plic_ctrl_psec;
                                     
assign sec_ctrl_reg_sel_en      = (bus_mtx_plic_ctrl_paddr[11:0] == 12'hff8);

assign plic_sec_ctrl_reg_wr_en  = plic_ctrl_apb_write_en
                                  & sec_ctrl_reg_sel_en
                                  & bus_mtx_plic_ctrl_psec;
assign plic_sec_ctrl_reg_rd_en  = plic_ctrl_apb_read_en
                                  & sec_ctrl_reg_sel_en
                                  & bus_mtx_plic_ctrl_psec;
// 

assign plic_t_amp_write_en      =  plic_sec_ctrl_reg_wr_en & ~plic_sec_lock;
always @(posedge plic_ctrl_clk or negedge plicrst_b)
begin
  if(~plicrst_b)
    plic_amp  <=  1'b0;
  else if(plic_t_amp_write_en)
    plic_amp  <= bus_mtx_plic_ctrl_pwdata[30];
end
always @(posedge plic_ctrl_clk or negedge plicrst_b)
begin
  if(~plicrst_b)
    plic_sec_lock  <=  1'b0;
  else if(plic_t_amp_write_en)
    plic_sec_lock  <= bus_mtx_plic_ctrl_pwdata[31];
end

assign plic_ctrl_reg_norm_write_en  = plic_ctrl_reg_wr_en & ~bus_mtx_plic_ctrl_psec & plic_amp;
assign plic_s_permission_norm_wen   = plic_ctrl_reg_norm_write_en | plic_s_permission_norm_clean;

assign plic_s_permission_norm_clean = plic_amp & ~bus_mtx_plic_ctrl_pwdata[30] & plic_t_amp_write_en;
assign plic_s_permission_norm_pre   = plic_s_permission_norm_clean ? 1'b0 : bus_mtx_plic_ctrl_pwdata[0];

always @(posedge plic_ctrl_clk or negedge plicrst_b)
begin
  if(~plicrst_b)
    plic_s_permission  <=  1'b0;
  else if(plic_s_permission_norm_wen)
    plic_s_permission  <= plic_s_permission_norm_pre;
end


assign ctrl_xx_amp_mode               = plic_amp;

assign plic_ctrl_reg_prdata[31:0]     = bus_mtx_plic_ctrl_psec ? {{31{1'b0}},plic_s_permission_t}
                                                               : {{31{1'b0}},plic_s_permission};
assign plic_sec_ctrl_reg_prdata[31:0] = {32{bus_mtx_plic_ctrl_psec}} & {plic_sec_lock,plic_amp,{30{1'b0}}};

assign plic_ctrl_prdata[31:0]         = {32{~plic_ctrl_pslverr_pre}} & ({32{sec_ctrl_reg_sel_en}}  & plic_sec_ctrl_reg_prdata[31:0] |
                                                                        {32{plic_ctrl_reg_sel_en}} & plic_ctrl_reg_prdata[31:0]);

assign ctrl_xx_amp_lock          = plic_sec_lock;
assign ctrl_xx_s_permission_t = plic_s_permission_t;
assign ctrl_xx_s_permission_nt = plic_s_permission;
`else
assign ctrl_xx_amp_mode = 1'b0;
assign plic_t_amp_write_en = 1'b0;
assign plic_amp            = 1'b0;
assign plic_ctrl_prdata[31:0] = {32{~plic_ctrl_pslverr_pre}} & {{31{1'b0}},plic_s_permission_t};
assign plic_ctrl_pslverr_pre    = (((bus_mtx_plic_ctrl_paddr[11:0] != 12'hffc)) | 
                                   (bus_mtx_plic_ctrl_pprot[1:0]  != 2'b11));
assign ctrl_xx_amp_lock       = 1'b0;
assign ctrl_xx_s_permission_t = plic_s_permission_t;
assign ctrl_xx_s_permission_nt = 1'b0;
`endif
always @(posedge plic_ctrl_clk or negedge plicrst_b)
begin
  if(~plicrst_b)
    plic_s_permission_t  <=  1'b0;
  else if(plic_s_permision_t_wen)
    plic_s_permission_t  <= plic_s_permission_t_pre;
end
assign plic_ctrl_reg_t_write_en  = plic_ctrl_reg_wr_en & (bus_mtx_plic_ctrl_psec | ~plic_amp); 
assign plic_s_permision_t_wen    = plic_ctrl_reg_t_write_en | plic_s_permission_t_clean;
assign plic_s_permission_t_clean = ~plic_amp & bus_mtx_plic_ctrl_pwdata[30] & plic_t_amp_write_en;
assign plic_s_permission_t_pre   = plic_s_permission_t_clean ? 1'b0 : bus_mtx_plic_ctrl_pwdata[0];

`ifdef PIC_TEE_EXTENSION
always @(posedge plic_ctrl_clk or negedge plicrst_b)
begin
  if(~plicrst_b)
    plic_per_parity <=  1'b0;
  else if(plic_s_permision_t_wen)
    plic_per_parity <= plic_s_permission_t_pre;
end
assign plic_pad_reg_parity_error = (plic_s_permission_t ^ plic_per_parity) & ~reg_parity_disable;

`endif

always @(posedge plic_ctrl_clk or negedge plicrst_b)
begin
  if(~plicrst_b)
    plic_ctrl_pready <= 1'b0;
  else if(bus_mtx_plic_ctrl_psel)
    plic_ctrl_pready <= plic_ctrl_apb_acc_en;
end 
assign plic_ctrl_pslverr    = plic_ctrl_pslverr_pre;                                           
pic_gated_clk_cell  x_ict_ready_gateclk (
  .clk_in               (plic_clk            ),
  .clk_out              (plic_ctrl_clk       ),
  .external_en          (1'b0                ),
  .local_en             (plic_ctrl_clk_en    ),
  .module_en            (ciu_plic_icg_en     ),
  .pad_yy_icg_scan_en (pad_yy_icg_scan_en)                
);
assign plic_ctrl_clk_en  = bus_mtx_plic_ctrl_psel;
endmodule
// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : pic_plic_granu2_arb.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-1
// FUNCTION        : PLIC granularity arbitor
//                   different with the other one, this one using compare
//                   to select. not using the decode to select
//                   1. parameterize the source number, the priority number
//                   2. big number means high priority 
//                   3. small id means high priority 
//                   
// ******************************************************************************

module pic_plic_granu2_arb(
  int_in_id,
  int_in_prio,
  int_in_req,
  int_out_id,
  int_out_prio,
  int_out_req
);
parameter ID_NUM    = 7;
parameter PRIO_BIT  = 6;
// &Ports; @28
input   [ID_NUM*4-1  :0]  int_in_id;      
input   [PRIO_BIT*4-1:0]  int_in_prio;    
input   [3 :0]            int_in_req;     
output  [ID_NUM-1 :0]       int_out_id;     
output  [PRIO_BIT-1 :0]     int_out_prio;   
output                    int_out_req;    

// &Regs; @29

// &Wires; @30
wire    [ID_NUM-1 :0]  int_01_id;      
wire            int_01_out;     
wire    [PRIO_BIT-1 :0]  int_01_prio;    
wire            int_01_sel_0;   
wire    [PRIO_BIT-1 :0]  int_0_req_prio; 
wire    [PRIO_BIT-1 :0]  int_1_req_prio; 
wire    [ID_NUM-1 :0]  int_23_id;      
wire            int_23_out;     
wire    [PRIO_BIT-1 :0]  int_23_prio;    
wire            int_23_sel_2;   
wire    [PRIO_BIT-1 :0]  int_2_req_prio; 
wire    [PRIO_BIT-1 :0]  int_3_req_prio; 
wire    [3 :0]  int_in_req;     
wire            int_lst_sel_01; 
wire    [ID_NUM-1 :0]  int_out_id;     
wire    [PRIO_BIT-1 :0]  int_out_prio;   
wire            int_out_req;    
wire    [PRIO_BIT-1 :0]  int_sel_01_prio; 
wire    [PRIO_BIT-1 :0]  int_sel_23_prio; 
wire    [ID_NUM-1:0]   int_0_id;
wire    [ID_NUM-1:0]   int_1_id;
wire    [ID_NUM-1:0]   int_2_id;
wire    [ID_NUM-1:0]   int_3_id;

assign int_0_req_prio[PRIO_BIT-1:0]  =  int_in_prio[PRIO_BIT-1:0];
assign int_1_req_prio[PRIO_BIT-1:0]  =  int_in_prio[2*PRIO_BIT-1:PRIO_BIT];
assign int_2_req_prio[PRIO_BIT-1:0]  =  int_in_prio[3*PRIO_BIT-1:2*PRIO_BIT];
assign int_3_req_prio[PRIO_BIT-1:0]  =  int_in_prio[4*PRIO_BIT-1:3*PRIO_BIT];
assign int_0_id[ID_NUM-1:0]          =  int_in_id[ID_NUM-1:0];
assign int_1_id[ID_NUM-1:0]          =  int_in_id[2*ID_NUM-1:ID_NUM];
assign int_2_id[ID_NUM-1:0]          =  int_in_id[3*ID_NUM-1:2*ID_NUM];
assign int_3_id[ID_NUM-1:0]          =  int_in_id[4*ID_NUM-1:3*ID_NUM];
assign int_01_sel_0         = ((int_in_req[0] & int_in_req[1]) 
                              & (int_0_req_prio[PRIO_BIT-1:0] >= int_1_req_prio[PRIO_BIT-1:0])) 
                            | (int_in_req[0] & ~int_in_req[1]);
assign int_23_sel_2         = ((int_in_req[2] & int_in_req[3]) 
                              & (int_2_req_prio[PRIO_BIT-1:0] >= int_3_req_prio[PRIO_BIT-1:0]))
                            | (int_in_req[2] & ~int_in_req[3]);

assign int_01_out           = int_in_req[0] | int_in_req[1];
assign int_01_prio[PRIO_BIT-1:0]     =  int_01_sel_0 ? int_0_req_prio[PRIO_BIT-1:0]
                                                     : int_1_req_prio[PRIO_BIT-1:0];
assign int_01_id[ID_NUM-1:0]       = int_01_sel_0 ? int_0_id[ID_NUM-1:0]
                                                   : int_1_id[ID_NUM-1:0];                   
assign int_23_out           = int_in_req[2] | int_in_req[3];
assign int_23_prio[PRIO_BIT-1:0]     = int_23_sel_2 ? int_2_req_prio[PRIO_BIT-1:0]
                                                    : int_3_req_prio[PRIO_BIT-1:0];
assign int_23_id[ID_NUM-1:0]       = int_23_sel_2 ? int_2_id[ID_NUM-1:0]
                                                  : int_3_id[ID_NUM-1:0]; 

assign int_sel_01_prio[PRIO_BIT-1:0]        = int_01_prio[PRIO_BIT-1:0]; 
assign int_sel_23_prio[PRIO_BIT-1:0]        = int_23_prio[PRIO_BIT-1:0];
assign int_lst_sel_01              = ((int_01_out & int_23_out) 
                                    & (int_sel_01_prio[PRIO_BIT-1:0] >= int_sel_23_prio[PRIO_BIT-1:0]))
                                   |(int_01_out & ~int_23_out);

assign int_out_req             = int_01_out | int_23_out;
assign int_out_prio[PRIO_BIT-1:0]       = int_lst_sel_01 ? int_01_prio[PRIO_BIT-1:0]
                                                : int_23_prio[PRIO_BIT-1:0];
assign int_out_id[ID_NUM-1:0]         = int_lst_sel_01 ? int_01_id[ID_NUM-1:0]
                                                       : int_23_id[ID_NUM-1:0];                                               
// &ModuleEnd; @60
endmodule


// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : pic_plic_granu_arb.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-1
// FUNCTION        : PLIC granularity arbitor
//                   1. parameterize the source number, the priority number
//                   2. big number means high priority 
//                   3. small id means high priority 
// ******************************************************************************

module pic_plic_granu_arb(
  //input
  int_in_prio,
  int_in_req, 
  int_in_id,

  //output
  int_out_req,
  int_out_id,
  int_out_prio

);
parameter    SEL_NUM        = 4;
parameter    SEL_BIT        = 2;
parameter    ID_NUM         = 10;
parameter    PRIO_BIT       = 5;
localparam   PRIO_NUM       = 1<<<PRIO_BIT;
localparam   INT_INFO       = ID_NUM + PRIO_BIT;

input   [SEL_NUM*PRIO_BIT-1:0]  int_in_prio;
input   [SEL_NUM-1:0]           int_in_req;
input   [SEL_NUM*ID_NUM-1:0]    int_in_id;

  //output
output                          int_out_req;
output  [ID_NUM-1:0]            int_out_id;
output  [PRIO_BIT-1:0]          int_out_prio;

// wire definition
wire    [PRIO_NUM-1:0]          int_valid_prio;
wire    [SEL_NUM-1:0]           high_prio_pos;
wire    [ID_NUM*SEL_NUM-1:0]    int_id_1d_bus;
wire    [PRIO_BIT-1:0]          high_prio;
wire    [SEL_NUM-1:0]           sel_pos_rever;
wire    [ID_NUM-1:0]            sel_out_id;

// reg definition
wire    [PRIO_NUM-1:0]          int_in_exp_prio[SEL_NUM-1:0];
wire    [SEL_NUM-1:0]           int_prio_pos_array[PRIO_NUM-1:0];
wire    [PRIO_NUM*SEL_NUM-1:0]  int_prio_pos_1d_bus;

wire    [SEL_BIT-1:0]           tmp_pos;
//**********************************************************************
//  first, get all the expand priority using 2-d array
//
//**********************************************************************
//integer i;
//integer j;
//always @(*)
//begin
//  for(i=0;i<SEL_NUM;i=i+1)
//  begin
//    for(j=0;j<PRIO_NUM;j=j+1)
//    begin
//        int_in_exp_prio[i][j] = int_in_req[i] & (int_in_prio[i*PRIO_BIT+:PRIO_BIT] == ($unsigned(j) & {PRIO_BIT{1'b1}}) );
//    end
//  end
//end

genvar fst_i,fst_j;
generate
for(fst_i=0;fst_i<SEL_NUM;fst_i=fst_i+1)
  begin:FIRST
    for(fst_j=0;fst_j<PRIO_NUM;fst_j=fst_j+1)
    begin:FIRST_IN
      assign int_in_exp_prio[fst_i][fst_j] = int_in_req[fst_i] & (int_in_prio[fst_i*PRIO_BIT+:PRIO_BIT] == ($unsigned(fst_j) & {PRIO_BIT{1'b1}}) );
    end
  end
endgenerate
//**********************************************************************
//  secod, reverse the expand priority array, ognized with priority
//
//**********************************************************************
//always @(*)
//begin
//  for(i=0;i<SEL_NUM;i=i+1)
//  begin
//    for(j=0;j<PRIO_NUM;j=j+1)
//    begin
//        int_prio_pos_array[j][i] = int_in_exp_prio[i][j];
//    end
//  end
//end
//always @(*)
//begin
//  for(j=0;j<PRIO_NUM;j=j+1)
//  begin
//      int_prio_pos_1d_bus[j*SEL_NUM+:SEL_NUM] = int_prio_pos_array[j];
//  end
//end

genvar scd_i,scd_j;
generate
for(scd_i=0;scd_i<SEL_NUM;scd_i=scd_i+1)
  begin:SECOND
    for(scd_j=0;scd_j<PRIO_NUM;scd_j=scd_j+1)
    begin:SECOND_IN
      assign int_prio_pos_array[scd_j][scd_i] = int_in_exp_prio[scd_i][scd_j];
    end
  end
endgenerate

genvar scd_k;
generate
for(scd_k=0;scd_k<PRIO_NUM;scd_k=scd_k+1)
  begin:SECOND_IN
    assign int_prio_pos_1d_bus[scd_k*SEL_NUM+:SEL_NUM] = int_prio_pos_array[scd_k][SEL_NUM-1:0];  
  end
endgenerate
//**********************************************************************
//  third, get the valid priority 
//  and select the highest priority position
//**********************************************************************
genvar k;
generate 
  for(k=0;k<PRIO_NUM;k=k+1)
  begin:VALID_PRIO
  assign int_valid_prio[k] = |int_prio_pos_array[k];
  end
endgenerate

pic_plic_prio_sel #(SEL_NUM,PRIO_NUM,PRIO_BIT) x_priority_select(
  .data_in(int_prio_pos_1d_bus),
  .sel_in(int_valid_prio),
  .data_out(high_prio_pos),
  .pos_out(high_prio)
);


//**********************************************************************
//  fourth, get the selected int information 
//  and select the highest priority position
//**********************************************************************
genvar m;
generate
  for(m=0;m<SEL_NUM;m=m+1)
    begin:FLAT_INT_INFO
    assign int_id_1d_bus[(SEL_NUM-1-m)*ID_NUM+:ID_NUM] = int_in_id[m*ID_NUM+:ID_NUM];
    assign sel_pos_rever[SEL_NUM-1-m]                  = high_prio_pos[m];
    end
endgenerate

pic_plic_prio_sel #(ID_NUM,SEL_NUM,SEL_BIT) x_id_select(
  .data_in(int_id_1d_bus),
  .sel_in(sel_pos_rever),
  .data_out(sel_out_id),
  .pos_out(tmp_pos)
);

assign int_out_req                 = |int_in_req[SEL_NUM-1:0];
assign int_out_prio[PRIO_BIT-1:0]  = high_prio[PRIO_BIT-1:0];
assign int_out_id[ID_NUM-1:0]      = sel_out_id[ID_NUM-1:0];


endmodule
// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : pic_plic_hart_arb.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-1
// FUNCTION        : PLIC hart arbitor controler,arbtor top module
//                   1. arb_ctrl, control the arbitration round
//                   2. arbitor, arbitration 32to1
// ******************************************************************************

module pic_plic_hart_arb(
  arbx_hartx_sint_req,
  arbx_hartx_mint_req,
  arbx_hreg_claim_id,
  arbx_hreg_claim_mmode,
  arbx_hreg_claim_reg_ready,
  arbx_hreg_arb_start_ack,
  ciu_plic_icg_en,
  pad_yy_icg_scan_en,
  hreg_arbx_arb_start,
  hreg_arbx_arb_flush,
  hreg_arbx_mint_claim,
  hreg_arbx_sint_claim,
  hreg_arbx_int_en,
  hreg_arbx_int_mmode,
  hreg_arbx_prio_sth,
  hreg_arbx_prio_mth,
  ctrl_xx_amp_mode,
  ctrl_xx_core_sec,
  kid_yy_int_prio,
  kid_yy_int_req,
  int_sec_infor,
  plic_clk,
  plicrst_b
);

parameter         INT_NUM       = 1024;
parameter         ECH_RD        = 32;
parameter         PRIO_BIT      = 5;
parameter         ID_NUM        = 10;
// &Ports; @24
input                           hreg_arbx_arb_start;    
input                           hreg_arbx_arb_flush;
input                           hreg_arbx_mint_claim;      
input                           hreg_arbx_sint_claim;      
input   [INT_NUM-1:0]           hreg_arbx_int_en;         
input   [INT_NUM-1:0]           hreg_arbx_int_mmode;         
input   [PRIO_BIT-1:0]          hreg_arbx_prio_sth;        
input   [PRIO_BIT-1:0]          hreg_arbx_prio_mth;        
input   [INT_NUM*PRIO_BIT-1:0]  kid_yy_int_prio;          
input   [INT_NUM-1:0]           kid_yy_int_req;     
input   [INT_NUM-1:0]           int_sec_infor;
input                           plic_clk;                 
input                           plicrst_b;       
input                           ciu_plic_icg_en;
input                           pad_yy_icg_scan_en;
input                           ctrl_xx_amp_mode;
input                           ctrl_xx_core_sec;
output                          arbx_hartx_sint_req;       
output                          arbx_hartx_mint_req;       
output  [ID_NUM-1   :0]         arbx_hreg_claim_id;       
output                          arbx_hreg_claim_mmode;       
output                          arbx_hreg_claim_reg_ready; 
output                          arbx_hreg_arb_start_ack;

// &Regs; @25

// &Wires; @26
wire    [PRIO_BIT:0]              arb_ctrl_int_prio;        
wire                              arb_ctrl_int_req;         
wire                              arbx_hartx_sint_req;       
wire                              arbx_hartx_mint_req;       
wire    [ID_NUM-1   :0]           arbx_hreg_claim_id;       
wire                              arbx_hreg_claim_reg_ready; 
wire    [1024*(PRIO_BIT+1)-1:0]       ctrl_arb_int_prio;        
wire    [1023:0]                  ctrl_arb_int_req;         
wire    [4   :0]                  ctrl_arb_select_round;    
wire                              hreg_arbx_arb_start;      
wire                              hreg_arbx_mint_claim;      
wire                              hreg_arbx_sint_claim;      
wire    [INT_NUM-1:0]             hreg_arbx_int_en;         
wire    [INT_NUM-1:0]             hreg_arbx_int_mmode;         
wire    [PRIO_BIT-1   :0]         hreg_arbx_prio_sth;        
wire    [PRIO_BIT-1   :0]         hreg_arbx_prio_mth;        
wire    [INT_NUM*PRIO_BIT-1:0]    kid_yy_int_prio;          
wire    [INT_NUM-1:0]             kid_yy_int_req;           
wire                              plic_clk;          
wire                              arb_ctrl_clk_en;
wire                              plicrst_b;                
wire                              ctrl_arb_new_arb_start;


// &Instance("pic_plic_arb_ctrl","x_pic_plic_arb_ctrl"); @31
pic_plic_arb_ctrl #(.INT_NUM(INT_NUM),
                   .PRIO_BIT(PRIO_BIT),
                   .ECH_RD(32)
                                    ) x_pic_plic_arb_ctrl (
  .plic_clk               (plic_clk                 ),
  .arb_ctrl_int_prio         (arb_ctrl_int_prio        ),
  .arb_ctrl_int_req          (arb_ctrl_int_req         ),
  .arbx_hartx_sint_req        (arbx_hartx_sint_req       ),
  .arbx_hartx_mint_req        (arbx_hartx_mint_req       ),
  .arbx_hreg_claim_reg_ready (arbx_hreg_claim_reg_ready),
  .arbx_hreg_arb_start_ack   (arbx_hreg_arb_start_ack  ),
  .ciu_plic_icg_en        (ciu_plic_icg_en),
  .pad_yy_icg_scan_en(pad_yy_icg_scan_en),
  .ctrl_arb_int_prio         (ctrl_arb_int_prio        ),
  .ctrl_arb_int_req          (ctrl_arb_int_req         ),
  .ctrl_arb_select_round     (ctrl_arb_select_round    ),
  .ctrl_arb_new_arb_start    (ctrl_arb_new_arb_start   ),
  .hreg_arbx_arb_start       (hreg_arbx_arb_start      ),
  .hreg_arbx_mint_claim      (hreg_arbx_mint_claim     ),
  .hreg_arbx_sint_claim      (hreg_arbx_sint_claim     ),
  .hreg_arbx_arb_flush       (hreg_arbx_arb_flush      ),
  .hreg_arbx_int_en          (hreg_arbx_int_en         ),
  .hreg_arbx_int_mmode       (hreg_arbx_int_mmode      ),
  .hreg_arbx_prio_sth        (hreg_arbx_prio_sth       ),
  .hreg_arbx_prio_mth        (hreg_arbx_prio_mth       ),
  .ctrl_xx_amp_mode          (ctrl_xx_amp_mode         ),
  .ctrl_xx_core_sec          (ctrl_xx_core_sec         ),
  .kid_yy_int_prio           (kid_yy_int_prio          ),
  .kid_yy_int_req            (kid_yy_int_req           ),
  .int_sec_infor             (int_sec_infor             ),
  .arb_ctrl_clk_en                (arb_ctrl_clk_en               ),
  .plicrst_b                 (plicrst_b                )
);

// &Connect( @32
//   .arb_ctl_clk(plic_clk), @33
// ); @34
// &Instance("pic_plic_32to1_arb","x_pic_plic_32to1_arb"); @35
pic_plic_32to1_arb  #(.PRIO_BIT(PRIO_BIT+1),
                     .ID_NUM(ID_NUM),
                     .INT_NUM(1024),
                     .ECH_RD(32),
                     .SEL_NUM(4)    //means 4to1 granu
                            )x_pic_plic_32to1_arb (
   .plic_clk             (plic_clk             ),   
   .arb_ctrl_clk_en      (arb_ctrl_clk_en      ),
  .int_in_prio           (ctrl_arb_int_prio    ),
  .int_in_req            (ctrl_arb_int_req     ),
  .ctrl_arb_new_arb_start    (ctrl_arb_new_arb_start   ),
  .ciu_plic_icg_en       (ciu_plic_icg_en      ),
  .pad_yy_icg_scan_en    (pad_yy_icg_scan_en   ),
  .int_out_id            (arbx_hreg_claim_id   ),
  .int_out_prio          (arb_ctrl_int_prio    ),
  .int_out_req           (arb_ctrl_int_req     ),
  .int_select_round      (ctrl_arb_select_round),
  .plicrst_b             (plicrst_b            )
);
assign arbx_hreg_claim_mmode = arb_ctrl_int_prio[PRIO_BIT];
// &Connect( @36
//   .arb_clk(plic_clk), @37
//   .int_in_prio(ctrl_arb_int_prio), @38
//   .int_in_req(ctrl_arb_int_req), @39
//   .int_select_round(ctrl_arb_select_round), @40
//   .int_out_req(arb_ctrl_int_req), @41
//   .int_out_prio(arb_ctrl_int_prio), @42
//   .int_out_id(arbx_hreg_claim_id) @43
// ); @44

endmodule
// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : pic_plic_hreg_busif.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-1
// FUNCTION        : PLIC hart reg bus interface
//                   1. including int enable, int th and claim register read and write
//                   
//                   2. parameterize the int source number, priority, hart
//                   number
//                   3. two apb bus,  for int enable and int th/claim priority
// ******************************************************************************

module pic_plic_hreg_busif(
  //input
  plic_clk,
  plicrst_b,
  bus_mtx_ict_psel,
  bus_mtx_ict_pprot,
  bus_mtx_ict_penable,
  bus_mtx_ict_paddr,
  bus_mtx_ict_pwrite,
  bus_mtx_ict_pwdata,
  bus_mtx_ict_psec,
  bus_mtx_ie_psel,
  bus_mtx_ie_pprot,
  bus_mtx_ie_penable,
  bus_mtx_ie_paddr,
  bus_mtx_ie_pwrite,
  bus_mtx_ie_pwdata,
  bus_mtx_ie_psec,
  arbx_hreg_claim_reg_ready,
  arbx_hreg_claim_mmode,
  arbx_hreg_claim_id,
  arbx_hreg_arb_start_ack,
  kid_hreg_new_int_pulse,
  ciu_plic_icg_en,
  pad_yy_icg_scan_en,
  kid_hreg_ip_prio_reg_we,
  ctrl_xx_amp_mode,
  ctrl_xx_core_sec,
  int_sec_infor,

  //output
  ie_bus_mtx_pready,
  ie_bus_mtx_prdata,
  ie_bus_mtx_pslverr,
  ict_bus_mtx_pready,
  ict_bus_mtx_prdata,
  ict_bus_mtx_pslverr,
  hreg_kid_claim_vld,
  //hreg_kid_claim_id,
  hreg_kid_cmplt_vld,
  hreg_arbx_arb_start,
  hreg_arbx_int_en,
  hreg_arbx_mint_claim,
  hreg_arbx_sint_claim,
  hreg_arbx_int_mmode,
  hreg_arbx_prio_sth,
  hreg_arbx_prio_mth,
  hreg_arbx_arb_flush
);
parameter          INT_NUM     = 1024;
parameter          HART_NUM    = 5'h4;
parameter          HART_EXIST  = 256'hffff;
parameter          ID_NUM      = 10;
parameter          PRIO_BIT    = 5;
parameter          IE_ADDR     = 21; // each hart will have 8 bit space. ie use 27'h0002??? ~ 27'01fc???
parameter          ICT_ADDR    = 26; // each hart will have 12 bit space, ict use 27'h02?????~27'h3f?????
localparam         HART_CT_DIV_TMP = HART_NUM/4;
localparam         CT_LEFT_NUM = HART_NUM - HART_CT_DIV_TMP * 4;
localparam         HART_CT_DIV = CT_LEFT_NUM > 0 ? HART_CT_DIV_TMP + 1 
                                                 : HART_CT_DIV_TMP;
localparam         ELEMENT_NUM = 32; //fix lint
localparam         IE_ADDR_SHIFT = 8;
  //input
input                             plic_clk;
input                             plicrst_b;
input                             bus_mtx_ict_psel;
input  [1:0]                      bus_mtx_ict_pprot;
input                             bus_mtx_ict_penable;
input  [ICT_ADDR-1:0]             bus_mtx_ict_paddr;
input                             bus_mtx_ict_pwrite;
input  [31:0]                     bus_mtx_ict_pwdata;
input                             bus_mtx_ict_psec;
input                             bus_mtx_ie_psel;
input  [1:0]                      bus_mtx_ie_pprot;
input                             bus_mtx_ie_penable;
input  [IE_ADDR-1:0]              bus_mtx_ie_paddr;
input                             bus_mtx_ie_pwrite;
input  [31:0]                     bus_mtx_ie_pwdata;
input                             bus_mtx_ie_psec;
input  [HART_NUM-1:0]             arbx_hreg_claim_reg_ready;
input  [HART_NUM-1:0]             arbx_hreg_claim_mmode;
input  [ID_NUM*HART_NUM-1:0]      arbx_hreg_claim_id;
input  [HART_NUM-1:0]             arbx_hreg_arb_start_ack;
input                             kid_hreg_new_int_pulse;
input                             pad_yy_icg_scan_en;
input                             kid_hreg_ip_prio_reg_we;
input                             ciu_plic_icg_en;
input                             ctrl_xx_amp_mode;
input  [HART_NUM-1:0]             ctrl_xx_core_sec;
input  [INT_NUM-1:0]              int_sec_infor;



  //output
output                            ie_bus_mtx_pready;
output [31:0]                     ie_bus_mtx_prdata;
output                            ie_bus_mtx_pslverr;
output                            ict_bus_mtx_pready;
output [31:0]                     ict_bus_mtx_prdata;
output                            ict_bus_mtx_pslverr;
output [INT_NUM-1:0]              hreg_kid_claim_vld;
//output [ID_NUM-1:0]               hreg_kid_claim_id;
output [INT_NUM-1:0]              hreg_kid_cmplt_vld;
output [HART_NUM-1:0]             hreg_arbx_arb_start;
output [HART_NUM*INT_NUM-1:0]     hreg_arbx_int_en;
output [HART_NUM-1:0]             hreg_arbx_mint_claim;
output [HART_NUM-1:0]             hreg_arbx_sint_claim;
output [HART_NUM*INT_NUM-1:0]     hreg_arbx_int_mmode;
output [HART_NUM*PRIO_BIT-1:0]    hreg_arbx_prio_sth;
output [HART_NUM*PRIO_BIT-1:0]    hreg_arbx_prio_mth;
output [HART_NUM-1:0]             hreg_arbx_arb_flush;

// wire definition
wire  [HART_NUM*32-1:0]           hart_ie_prdata;
wire  [HART_NUM*32-1:0]           hart_ie_pwdata;
wire  [HART_NUM-1:0]              hart_ie_psel;
wire  [HART_NUM-1:0]              hart_ie_psec;
wire  [HART_NUM*2-1:0]            hart_ie_pprot;
wire  [HART_NUM-1:0]              hart_ie_penable;
wire  [HART_NUM-1:0]              hart_ie_pwrite;
wire  [HART_NUM*IE_ADDR-1:0]      hart_ie_paddr;
wire  [HART_NUM-1:0]              ie_apb_acc_en;
wire  [HART_NUM-1:0]              ie_apb_write_en;
wire  [HART_NUM-1:0]              ie_apb_read_en;
wire  [HART_NUM-1:0]              ie_apb_read_acc_en;

wire  [31:0]                      hart_ie_prdata_pre[HART_NUM-1:0];
wire  [31:0]                      hart_ie_prdata_flop[HART_NUM-1:0];
wire  [HART_NUM-1:0]              hart_ie_ready_clk;
wire  [HART_NUM-1:0]              hart_ie_ready_clk_en;
wire  [HART_NUM-1:0]              ie_apb_slverr_pre;
wire  [INT_NUM/32-1:0]            ie_wr_clk[HART_NUM-1:0];
wire  [INT_NUM/32-1:0]            ie_wr_clk_en[HART_NUM-1:0];
wire  [INT_NUM-1:0]               hart_sie_flop[HART_NUM-1:0];
wire  [INT_NUM-1:0]               hart_mie_flop[HART_NUM-1:0];
wire  [INT_NUM-1:0]               hart_sie_flop_msk_zero[HART_NUM-1:0];
wire  [INT_NUM-1:0]               hart_mie_flop_msk_zero[HART_NUM-1:0];
wire  [HART_NUM*INT_NUM-1:0]      hart_sie_1d_bus;
wire  [HART_NUM*INT_NUM-1:0]      hart_mie_1d_bus;
wire                              ict_apb_acc_en;
wire                              ict_apb_write_en;
wire                              ict_apb_read_en;
wire  [HART_NUM-1:0]              busif_hart_mth_wr_en;
wire  [HART_NUM-1:0]              busif_hart_mth_rd_en;
wire  [HART_NUM-1:0]              busif_hart_mclaim_wr_en;
wire  [HART_NUM-1:0]              busif_hart_mclaim_rd_en;
wire  [HART_NUM-1:0]              busif_hart_sth_wr_en;
wire  [HART_NUM-1:0]              busif_hart_sth_rd_en;
wire  [HART_NUM-1:0]              busif_hart_sclaim_wr_en;
wire  [HART_NUM-1:0]              busif_hart_sclaim_rd_en;
wire  [HART_NUM-1:0]              hart_ict_read_en;
wire  [31:0]                      hart_ict_read_data[HART_NUM-1:0];    
wire  [(HART_NUM+1)*32-1:0]       hart_ict_read_data_tmp;
wire  [HART_NUM-1:0]              hart_claim_read_en;
wire  [31:0]                      hart_claim_read_data[HART_NUM-1:0];    
wire  [(HART_NUM+1)*32-1:0]       hart_claim_read_data_tmp;
wire  [HART_NUM-1:0]              hart_ict_exist_slverr;
wire                              ict_ready_clk;
wire                              ict_ready_clk_en;
wire  [31:0]                      hart_ict_prdata_pre;       
wire                              ict_apb_slverr_pre;
wire  [PRIO_BIT-1:0]              hart_mth_flop[HART_NUM-1:0];
wire  [PRIO_BIT-1:0]              hart_sth_flop[HART_NUM-1:0];
wire  [PRIO_BIT*HART_NUM-1:0]     hart_sth_1d_bus;
wire  [PRIO_BIT*HART_NUM-1:0]     hart_mth_1d_bus;
wire  [HART_NUM*ID_NUM-1:0]       hart_mclaim_set_id;
wire  [HART_NUM-1:0]              hart_mclaim_clr;
wire  [HART_NUM*ID_NUM-1:0]       hart_sclaim_set_id;
wire  [HART_NUM-1:0]              hart_sclaim_clr;
wire  [2*HART_NUM-1:0]            mclaim_eq_vec[HART_NUM-1:0];
wire  [2*HART_NUM-1:0]            sclaim_eq_vec[HART_NUM-1:0];
wire                              arbx_start_ack;
wire                              arb_start_en;
wire  [HART_NUM-1:0]              claim_clk;
wire  [HART_NUM-1:0]              tmp_claim_clk;
wire  [HART_NUM-1:0]              tmp_claim_clk_en;
wire  [HART_NUM-1:0]              th_wr_clk;
wire  [HART_NUM-1:0]              tmp_th_wr_clk;
wire  [HART_NUM-1:0]              tmp_th_wr_clk_en;
wire  [HART_NUM-1:0]              conv_tmp_claim_clk_en;
wire  [HART_NUM-1:0]              ori_tmp_claim_clk_en;
wire  [HART_NUM-1:0]              conv_tmp_th_wr_clk_en;
wire  [HART_NUM-1:0]              ori_tmp_th_wr_clk_en;
wire  [HART_NUM*IE_ADDR-1:0]      hart_ie_base_addr;
wire  [HART_NUM*IE_ADDR-1:0]      hart_ie_base_addr_msk;
wire  [(HART_NUM+1)*INT_NUM-1:0]  hart_int_cmplt_vld_tmp;
wire  [INT_NUM-1:0]               busif_hart_cmplt_int_vld[HART_NUM-1:0];
wire  [INT_NUM-1:0]               hart_cmplt_id_expnd;
wire  [(HART_NUM+1)*INT_NUM-1:0]  hart_int_claim_vld_tmp;
wire  [INT_NUM-1:0]               busif_hart_claim_int_vld[HART_NUM-1:0];
wire  [INT_NUM-1:0]               hart_claim_id_expnd;
wire  [ID_NUM-1:0]                hreg_kid_claim_id;
wire  [ID_NUM-1:0]                hreg_kid_cmplt_id;
wire                              hreg_cmplt_vld;
wire                              hreg_claim_vld;
wire                              ciu_plic_icg_en;
wire  [HART_NUM-1:0]              ict_psec_ctrl_en;
wire  [HART_NUM-1:0]              icg_psec_nonsec_err_en;
wire  [HART_NUM:0]                icg_psec_nonsec_err_en_rep;
wire  [INT_NUM-1:0]               hart_ie_sec_ctrl[HART_NUM-1:0];

wire  [INT_NUM+31:0]              mie_lst_read_tmp[HART_NUM-1:0];
wire  [INT_NUM+31:0]              sie_lst_read_tmp[HART_NUM-1:0];
wire  [INT_NUM/32-1:0]            busif_we_kid_mie[HART_NUM-1:0];
wire  [INT_NUM/32-1:0]            busif_rd_kid_mie[HART_NUM-1:0];
wire  [INT_NUM/32-1:0]            busif_we_kid_sie[HART_NUM-1:0];
wire  [INT_NUM/32-1:0]            busif_rd_kid_sie[HART_NUM-1:0];
wire  [INT_NUM-1:0]               busif_we_kid_mie_data[HART_NUM-1:0];
wire  [INT_NUM-1:0]               busif_we_kid_sie_data[HART_NUM-1:0];
wire                              value_zero;

//reg definition
reg   [HART_NUM-1:0]              hart_ie_pready;
reg   [HART_NUM-1:0]              hart_ie_pslverr;
reg   [ID_NUM-1:0]                hart_mclaim_flop[HART_NUM-1:0];
reg   [ID_NUM-1:0]                hart_sclaim_flop[HART_NUM-1:0];
reg                               arbx_arb_start_flop;
reg                               ict_bus_mtx_pready;
reg                               ict_bus_mtx_pslverr;

//**********************************************************************
//    the IE bus interface
//
//**********************************************************************
//**************************************
//    apb bus interface
//
//**************************************
genvar j;
generate
for(j=0;j<HART_NUM;j=j+1)
begin:HART_BASE_ADDR
  assign hart_ie_base_addr[j*IE_ADDR+:IE_ADDR]     = {{IE_ADDR-16{1'b0}},16'h2000} + $unsigned(j<<<IE_ADDR_SHIFT) & {IE_ADDR{1'b1}};
  //ie address space start at 0x0002000, each hart has 0x100 space
  assign hart_ie_base_addr_msk[j*IE_ADDR+:IE_ADDR] = {{(IE_ADDR-8){1'b1}},{8{1'b0}}};
end
endgenerate
pic_plic_apb_1tox_matrix_for_ie #(.ADDR(IE_ADDR),
                              .SLAVE(HART_NUM),
                              .SLAVE_EXIST(HART_EXIST)
                              )x_ie_1tox_matrix(
  //input
  .pclk         (plic_clk),
  .prst_b       (plicrst_b),
  .slv_paddr    (bus_mtx_ie_paddr),
  .slv_psel     (bus_mtx_ie_psel),
  .slv_pprot    (bus_mtx_ie_pprot),
  .slv_penable  (bus_mtx_ie_penable),
  .slv_pwrite   (bus_mtx_ie_pwrite),
  .slv_pwdata   (bus_mtx_ie_pwdata),
  .slv_psec     (bus_mtx_ie_psec),
  .mst_pready   (hart_ie_pready[HART_NUM-1:0]),
  .mst_prdata   (hart_ie_prdata[HART_NUM*32-1:0]),
  .mst_pslverr  (hart_ie_pslverr[HART_NUM-1:0]),
  .mst_base_addr(hart_ie_base_addr[HART_NUM*IE_ADDR-1:0]),
  .mst_base_addr_msk(hart_ie_base_addr_msk[HART_NUM*IE_ADDR-1:0]),
  .other_slv_sel({HART_NUM{1'b0}}),
  .ciu_plic_icg_en(ciu_plic_icg_en),
  .pad_yy_icg_scan_en(pad_yy_icg_scan_en),
  //.output
  .mst_psel     (hart_ie_psel[HART_NUM-1:0]),
  .mst_pprot    (hart_ie_pprot[HART_NUM*2-1:0]),
  .mst_penable  (hart_ie_penable[HART_NUM-1:0]),
  .mst_paddr    (hart_ie_paddr[HART_NUM*IE_ADDR-1:0]),
  .mst_pwrite   (hart_ie_pwrite[HART_NUM-1:0]),
  .mst_pwdata   (hart_ie_pwdata[HART_NUM*32-1:0]),
  .mst_psec     (hart_ie_psec[HART_NUM-1:0]),
  .slv_pready   (ie_bus_mtx_pready),
  .slv_prdata   (ie_bus_mtx_prdata),
  .slv_pslverr  (ie_bus_mtx_pslverr)
);

//****************************************************
//   generate the write/read signal
//   for each ie register
//   using the 2-d array
//****************************************************
genvar n,m;
generate
for(n=0;n<HART_NUM;n=n+1)
begin:BUSIF_WR_IE
if(HART_EXIST[n])
  begin:BUSIF_WR_IE_TRUE
  assign mie_lst_read_tmp[n][31:0] = {32{1'b0}};
  assign sie_lst_read_tmp[n][31:0] = {32{1'b0}};
    for(m=0;m<INT_NUM/32;m=m+1)
    begin:BUSIF_WR_IE_IN
    //***************************
    // mie write/read en, 2-d array,
    // each for 32bit ie
    //***************************
     assign busif_we_kid_mie[n][m] = ie_apb_write_en[n] 
                                     & ~(hart_ie_paddr[7+IE_ADDR*n])  //addr[7] = 0, access mie
                                     & (hart_ie_paddr[(2+IE_ADDR*n)+:5] == ($unsigned(m) & {5{1'b1}})); // access 32 bit at least
     assign busif_rd_kid_mie[n][m] = ie_apb_read_en[n] 
                                     & ~(hart_ie_paddr[7+IE_ADDR*n])
                                     & (hart_ie_paddr[(2+IE_ADDR*n)+:5] == ($unsigned(m) & {5{1'b1}})); 
    //***************************
    // mie write/read en, 2-d array,
    // each for 32bit ie
    //***************************

     assign busif_we_kid_sie[n][m] = ie_apb_write_en[n] 
                                     & (hart_ie_paddr[7+IE_ADDR*n]) //addr[7] = 1, access sie
                                     & (hart_ie_paddr[(2+IE_ADDR*n)+:5] == ($unsigned(m) & {5{1'b1}})); // access 32 bit at least
     assign busif_rd_kid_sie[n][m] = ie_apb_read_en[n] 
                                     & (hart_ie_paddr[7+IE_ADDR*n])
                                     & (hart_ie_paddr[(2+IE_ADDR*n)+:5] == ($unsigned(m) & {5{1'b1}}));
    //***************************
    // write data 2-d array,
    // hart-ie
    //***************************

     assign busif_we_kid_mie_data[n][32*m+:32] 
                                   = hart_ie_pwdata[32*n+:32] & hart_ie_sec_ctrl[n][32*m+:32];
     assign busif_we_kid_sie_data[n][32*m+:32] 
                                   = hart_ie_pwdata[32*n+:32] & hart_ie_sec_ctrl[n][32*m+:32];
    //***************************
    // read data 2-d array,
    // hart-ie
    //***************************

     assign mie_lst_read_tmp[n][32*(m+1)+:32]
                                = mie_lst_read_tmp[n][32*m+:32]
                                  |({32{busif_rd_kid_mie[n][m]}} 
                                    & hart_mie_flop_msk_zero[n][32*m+:32]);
     assign sie_lst_read_tmp[n][32*(m+1)+:32]
                                      = sie_lst_read_tmp[n][32*m+:32]
                                        |({32{busif_rd_kid_sie[n][m]}} 
                                          & hart_sie_flop_msk_zero[n][32*m+:32]);

    end   
  end 
else //if this hart is not exist
  begin:BUSIF_WR_IE_DUMMY
  assign mie_lst_read_tmp[n][31:0] = {32{1'b0}};
  assign sie_lst_read_tmp[n][31:0] = {32{1'b0}};
    for(m=0;m<INT_NUM/32;m=m+1)
    begin:BUSIF_WR_IE_IN_TRUE
     assign busif_we_kid_mie[n][m]      = 1'b0; 
     assign busif_rd_kid_mie[n][m]      = 1'b0; 
     assign busif_we_kid_sie[n][m]      = 1'b0;
     assign busif_rd_kid_sie[n][m]      = 1'b0;
     assign busif_we_kid_mie_data[n][32*m+:32] = {32{1'b0}};
     assign busif_we_kid_sie_data[n][32*m+:32] = {32{1'b0}};
     assign mie_lst_read_tmp[n][32*(m+1)+:32]  = {32{1'b0}};
     assign sie_lst_read_tmp[n][32*(m+1)+:32]  = {32{1'b0}};
    end
  end
end
endgenerate

genvar k;
generate
for(k=0;k<HART_NUM;k=k+1)
begin:HART_IE_RW
if(HART_EXIST[k])
  begin:HART_IE_RW_TRUE
    assign ie_apb_acc_en[k]              = hart_ie_psel[k]  & ~hart_ie_penable[k];
    assign ie_apb_write_en[k]            = ie_apb_acc_en[k] 
                                           & hart_ie_pwrite[k] 
                                           & ~ie_apb_slverr_pre[k]
                                           & (hart_ie_psec[k] | ~ctrl_xx_core_sec[k] | ~ctrl_xx_amp_mode);
    assign ie_apb_read_en[k]             = ie_apb_acc_en[k] & ~hart_ie_pwrite[k] & (hart_ie_psec[k] | ~ctrl_xx_core_sec[k] | ~ctrl_xx_amp_mode);
    assign ie_apb_read_acc_en[k]         = ie_apb_acc_en[k] & ~hart_ie_pwrite[k];
    assign hart_ie_sec_ctrl[k]           = (int_sec_infor[INT_NUM-1:0] ~^ {INT_NUM{ctrl_xx_core_sec[k]}}) | {INT_NUM{~ctrl_xx_amp_mode}};
  
  //merge the rdata
    assign hart_ie_prdata_pre[k]        = ie_apb_slverr_pre[k] ? {32{1'b0}}: (mie_lst_read_tmp[k][INT_NUM+:32] 
                                          & {32{~(hart_ie_paddr[7+IE_ADDR*k])}})
                                        | (sie_lst_read_tmp[k][INT_NUM+:32] 
                                          & {32{(hart_ie_paddr[7+IE_ADDR*k])}});
  
  //*************************************
  //  the ie ready signal
  //*************************************
  always @(posedge hart_ie_ready_clk[k] or negedge plicrst_b)
    begin
      if(~plicrst_b)
        hart_ie_pready[k] <= 1'b0;
      else if(hart_ie_psel[k])
        hart_ie_pready[k] <= ie_apb_acc_en[k];
    end
  //*************************************
  //  the ie rdata signal
  //*************************************
    pic_plic_instance_reg_flog #(.DATA(32)) x_hart_ie_rdata_ff(
      .clk      (hart_ie_ready_clk[k]),
      .en       (ie_apb_read_acc_en[k]),
      .rst_b    (plicrst_b),
      .data_in  (hart_ie_prdata_pre[k]),
      .data_out (hart_ie_prdata_flop[k])
    ); 
    assign hart_ie_prdata[k*32+:32]    = hart_ie_prdata_flop[k];
  //*************************************
  //  the ie slverr signal
  //*************************************
  always @(posedge hart_ie_ready_clk[k] or negedge plicrst_b)
    begin
      if(~plicrst_b)
        hart_ie_pslverr[k] <= 1'b0;
      else if(ie_apb_acc_en[k])
        hart_ie_pslverr[k] <= ie_apb_slverr_pre[k];
    end

    assign ie_apb_slverr_pre[k] =  (hart_ie_paddr[2+IE_ADDR*k+:5] >= $unsigned(INT_NUM/ELEMENT_NUM)) 
                                   | (hart_ie_pprot[2*k+1] == 1'b0)
                                   | (~hart_ie_psec[k] & ctrl_xx_core_sec[k]);
                                   
    pic_gated_clk_cell  x_hart_ie_ready_gateclk (
      .clk_in               (plic_clk            ),
      .clk_out              (hart_ie_ready_clk[k]),
      .external_en          (1'b0                ),
      .local_en             (hart_ie_ready_clk_en[k]),
      .module_en            (ciu_plic_icg_en     ),
      .pad_yy_icg_scan_en (pad_yy_icg_scan_en)
    );
    assign hart_ie_ready_clk_en[k] = ie_apb_acc_en[k] | hart_ie_pready[k];
  end
else //if this hart is not exist
  begin:HART_IE_RW_DUMMY
    assign ie_apb_acc_en[k]              = 1'b0;
    assign ie_apb_write_en[k]            = 1'b0;
    assign ie_apb_read_en[k]             = 1'b0;
    assign ie_apb_read_acc_en[k]         = 1'b0;
    assign hart_ie_sec_ctrl[k]           = {INT_NUM{1'b0}}; 
    assign hart_ie_prdata_pre[k]         = {32{1'b0}};
  //*************************************
  //  the ie ready signal
  //*************************************
   always @ (*)
   begin
    hart_ie_pready[k]    = value_zero;
    hart_ie_pslverr[k]   = value_zero;
   end
  //*************************************
  //  the ie rdata signal
  //*************************************
    assign hart_ie_prdata_flop[k]      = {32{1'b0}};
    assign hart_ie_prdata[k*32+:32]    = hart_ie_prdata_flop[k];
  //*************************************
  //  the ie slverr signal
  //*************************************
    assign ie_apb_slverr_pre[k] = 1'b0; // the slverr of hart nonexistence are handled by ie apb_1tox_matix
    assign hart_ie_ready_clk_en[k] = 1'b0;
    assign hart_ie_ready_clk[k]    = 1'b0;
  end
end
endgenerate
assign value_zero = 1'b0;
//****************************************************
//  MIE/SIE flop instance  
//****************************************************
genvar i,rd_idx;
generate
for(i=0;i<HART_NUM;i=i+1)
begin:HART_IE_TRUE
if(HART_EXIST[i])
  begin:HART_IE
    for(rd_idx=0;rd_idx<INT_NUM/32;rd_idx=rd_idx+1)
    begin:HART_IE_32
    pic_plic_instance_reg_flog #(.DATA(32)) x_hart_mie_ff(
      .clk      (ie_wr_clk[i][rd_idx]),
      .en       (busif_we_kid_mie[i][rd_idx]),
      .rst_b    (plicrst_b),
      .data_in  (busif_we_kid_mie_data[i][32*rd_idx+:32]),
      .data_out (hart_mie_flop[i][32*rd_idx+:32])
    ); 
    pic_plic_instance_reg_flog #(.DATA(32)) x_hart_sie_ff(
      .clk      (ie_wr_clk[i][rd_idx]),
      .en       (busif_we_kid_sie[i][rd_idx]),
      .rst_b    (plicrst_b),
      .data_in  (busif_we_kid_sie_data[i][32*rd_idx+:32]),
      .data_out (hart_sie_flop[i][32*rd_idx+:32])
    );
      // gate clk instance
    pic_gated_clk_cell  x_hart_ie_wr_gateclk (
      .clk_in               (plic_clk            ),
      .clk_out              (ie_wr_clk[i][rd_idx]),
      .external_en          (1'b0                ),
      .local_en             (ie_wr_clk_en[i][rd_idx]),
      .module_en            (ciu_plic_icg_en     ),
      .pad_yy_icg_scan_en (pad_yy_icg_scan_en)
    );
    assign ie_wr_clk_en[i][rd_idx]   =  busif_we_kid_mie[i][rd_idx] |
                                        busif_we_kid_sie[i][rd_idx];
    end
  //here we don't need the ie of int index 0 
    assign hart_sie_flop_msk_zero[i]           =  hart_sie_flop[i] & {{(INT_NUM-1){1'b1}},1'b0};
    assign hart_mie_flop_msk_zero[i]           =  hart_mie_flop[i] & {{(INT_NUM-1){1'b1}},1'b0};
    assign hart_sie_1d_bus[i*INT_NUM+:INT_NUM] = hart_sie_flop_msk_zero[i];
    assign hart_mie_1d_bus[i*INT_NUM+:INT_NUM] = hart_mie_flop_msk_zero[i]; 
  end
else //if this hart is not exist
  begin:HART_IE_DUMMY
    for(rd_idx=0;rd_idx<INT_NUM/32;rd_idx=rd_idx+1)
    begin:HART_IE_32_DUMMY
      assign hart_mie_flop[i][32*rd_idx+:32]     = {32{1'b0}};
      assign hart_sie_flop[i][32*rd_idx+:32]     = {32{1'b0}};
      assign ie_wr_clk[i][rd_idx]                = 1'b0;
      assign ie_wr_clk_en[i][rd_idx]             = 1'b0;
    end
    assign hart_sie_flop_msk_zero[i]           = {INT_NUM{1'b0}};
    assign hart_mie_flop_msk_zero[i]           = {INT_NUM{1'b0}};
    assign hart_sie_1d_bus[i*INT_NUM+:INT_NUM] = hart_sie_flop_msk_zero[i];
    assign hart_mie_1d_bus[i*INT_NUM+:INT_NUM] = hart_mie_flop_msk_zero[i];
  end
end
endgenerate
//**********************************************************************
//    the interrupt TH/CLAIM bus interface
//
//**********************************************************************
assign ict_apb_acc_en       = bus_mtx_ict_psel & ~bus_mtx_ict_penable;
assign ict_apb_write_en     = ict_apb_acc_en & bus_mtx_ict_pwrite & ~ict_apb_slverr_pre;
assign ict_apb_read_en      = ict_apb_acc_en & ~bus_mtx_ict_pwrite;
assign hart_ict_read_data_tmp[31:0] = {32{1'b0}};
assign hart_claim_read_data_tmp[31:0] = {32{1'b0}};

genvar ht_idx;
generate
for(ht_idx=0;ht_idx<HART_NUM;ht_idx=ht_idx+1)
begin:ICT_RW
if(HART_EXIST[ht_idx])
  begin:ICT_RW_TRUE
  //*************************************
  //  the ie mth write read enable
  //*************************************
    assign ict_psec_ctrl_en[ht_idx]      = (bus_mtx_ict_psec | ~ctrl_xx_core_sec[ht_idx] | ~ctrl_xx_amp_mode);
    assign icg_psec_nonsec_err_en[ht_idx]= ~bus_mtx_ict_psec & ctrl_xx_core_sec[ht_idx] & 
                                           (bus_mtx_ict_paddr[ICT_ADDR-1:13] == 12'h100 + ($unsigned(ht_idx) & {13{1'b1}}));
    assign busif_hart_mth_wr_en[ht_idx]  = ict_apb_write_en 
                                        & (bus_mtx_ict_pprot[1:0] == 2'b11)
                                        & (bus_mtx_ict_paddr[ICT_ADDR-1:13] == 12'h100 + ($unsigned(ht_idx) & {13{1'b1}}))
                                        & ~(bus_mtx_ict_paddr[12]) //addr[12] = 0 is m register
                                        & (bus_mtx_ict_paddr[11:0] == {12{1'b0}}) & ict_psec_ctrl_en[ht_idx]; //addr[11:0] = 0 is threshold
    assign busif_hart_mth_rd_en[ht_idx]  = ict_apb_read_en 
                                        & (bus_mtx_ict_pprot[1:0] == 2'b11)
                                        & (bus_mtx_ict_paddr[ICT_ADDR-1:13] == 12'h100 + ($unsigned(ht_idx) & {13{1'b1}}))
                                        & ~(bus_mtx_ict_paddr[12])
                                        & (bus_mtx_ict_paddr[11:0] == {12{1'b0}}) & ict_psec_ctrl_en[ht_idx];
  //************************************* 
  //  the ie mclaim write read enable
  //*************************************
  
    assign busif_hart_mclaim_wr_en[ht_idx]  = ict_apb_write_en 
                                        & (bus_mtx_ict_pprot[1:0] == 2'b11)
                                        & (bus_mtx_ict_paddr[ICT_ADDR-1:13] == 12'h100 + ($unsigned(ht_idx) & {13{1'b1}}))
                                        & ~(bus_mtx_ict_paddr[12])
                                        & (bus_mtx_ict_paddr[11:0] == {{8{1'b0}},4'h4}) & ict_psec_ctrl_en[ht_idx]; //addr[11:0] = 4 is claim
    assign busif_hart_mclaim_rd_en[ht_idx]  = ict_apb_read_en 
                                        & (bus_mtx_ict_pprot[1:0] == 2'b11)
                                        & (bus_mtx_ict_paddr[ICT_ADDR-1:13] == 12'h100 + ($unsigned(ht_idx) & {13{1'b1}}))
                                        & ~(bus_mtx_ict_paddr[12])
                                        & (bus_mtx_ict_paddr[11:0] == {{8{1'b0}},4'h4}) & ict_psec_ctrl_en[ht_idx];
  //*************************************
  //  the ie sth write read enable
  //*************************************
  
    assign busif_hart_sth_wr_en[ht_idx]  = ict_apb_write_en 
                                        & (bus_mtx_ict_pprot[0] == 1'b1)
                                        & (bus_mtx_ict_paddr[ICT_ADDR-1:13] == 12'h100 + ($unsigned(ht_idx) & {13{1'b1}}))
                                        & (bus_mtx_ict_paddr[12])
                                        & (bus_mtx_ict_paddr[11:0] == {12{1'b0}})& ict_psec_ctrl_en[ht_idx];
    assign busif_hart_sth_rd_en[ht_idx]  = ict_apb_read_en 
                                        & (bus_mtx_ict_pprot[0] == 1'b1)
                                        & (bus_mtx_ict_paddr[ICT_ADDR-1:13] == 12'h100 + ($unsigned(ht_idx) & {13{1'b1}}))
                                        & (bus_mtx_ict_paddr[12])
                                        & (bus_mtx_ict_paddr[11:0] == {12{1'b0}})& ict_psec_ctrl_en[ht_idx];
  //*************************************
  //  the ie sclaim write read enable
  //*************************************
    assign busif_hart_sclaim_wr_en[ht_idx]  = ict_apb_write_en 
                                        & (bus_mtx_ict_pprot[0] == 1'b1)
                                        & (bus_mtx_ict_paddr[ICT_ADDR-1:13] == 12'h100 + ($unsigned(ht_idx) & {13{1'b1}}))
                                        & (bus_mtx_ict_paddr[12])
                                        & (bus_mtx_ict_paddr[11:0] == {{8{1'b0}},4'h4})& ict_psec_ctrl_en[ht_idx];
    assign busif_hart_sclaim_rd_en[ht_idx]  = ict_apb_read_en 
                                        & (bus_mtx_ict_pprot[0] == 1'b1)
                                        & (bus_mtx_ict_paddr[ICT_ADDR-1:13] == 12'h100 + ($unsigned(ht_idx) & {13{1'b1}}))
                                        & (bus_mtx_ict_paddr[12])
                                        & (bus_mtx_ict_paddr[11:0] == {{8{1'b0}},4'h4})& ict_psec_ctrl_en[ht_idx];
  
    assign hart_ict_read_en[ht_idx]    =    busif_hart_mth_rd_en[ht_idx]
                                         | busif_hart_sth_rd_en[ht_idx]
                                         | hart_claim_read_en[ht_idx];
    assign hart_ict_read_data[ht_idx] =     ({32{busif_hart_mth_rd_en[ht_idx]}} 
                                            & {{32-PRIO_BIT{1'b0}},hart_mth_flop[ht_idx]})
                                         | ({32{busif_hart_sth_rd_en[ht_idx]}} 
                                            & {{32-PRIO_BIT{1'b0}},hart_sth_flop[ht_idx]})
                                         | hart_claim_read_data[ht_idx];
    assign hart_ict_read_data_tmp[(ht_idx+1)*32+:32]  =  hart_ict_read_data_tmp[ht_idx*32+:32]
                                                       | ({32{hart_ict_read_en[ht_idx]}}
                                                          & hart_ict_read_data[ht_idx]);
    assign hart_claim_read_en[ht_idx]   = busif_hart_mclaim_rd_en[ht_idx]
                                         | busif_hart_sclaim_rd_en[ht_idx];                                                      
    assign hart_claim_read_data[ht_idx] = ({32{busif_hart_mclaim_rd_en[ht_idx]}}
                                            & {{32-ID_NUM{1'b0}},hart_mclaim_flop[ht_idx]})
                                         | ({32{busif_hart_sclaim_rd_en[ht_idx]}}
                                            & {{32-ID_NUM{1'b0}},hart_sclaim_flop[ht_idx]});
    assign hart_claim_read_data_tmp[(ht_idx+1)*32+:32] = hart_claim_read_data_tmp[ht_idx*32+:32]
                                                       | ({32{hart_claim_read_en[ht_idx]}}
                                                          & hart_claim_read_data[ht_idx]);
  //*************************************
  //      hart exist ict slverr
  //*************************************
    assign hart_ict_exist_slverr[ht_idx] = 1'b0;
  end
else //if this hart is not exist
  begin:ICT_RW_DUMMY
  //*************************************
  //  the ie mth write read enable
  //*************************************
    assign ict_psec_ctrl_en[ht_idx]      = 1'b0;
    assign icg_psec_nonsec_err_en[ht_idx]= 1'b0;
    assign busif_hart_mth_wr_en[ht_idx]  = 1'b0;
    assign busif_hart_mth_rd_en[ht_idx]  = 1'b0;
  //************************************* 
  //  the ie mclaim write read enable
  //************************************* 
    assign busif_hart_mclaim_wr_en[ht_idx]  = 1'b0;
    assign busif_hart_mclaim_rd_en[ht_idx]  = 1'b0;
  //*************************************
  //  the ie sth write read enable
  //*************************************
    assign busif_hart_sth_wr_en[ht_idx]  = 1'b0;
    assign busif_hart_sth_rd_en[ht_idx]  = 1'b0;
  //*************************************
  //  the ie sclaim write read enable
  //*************************************
    assign busif_hart_sclaim_wr_en[ht_idx]  = 1'b0;
    assign busif_hart_sclaim_rd_en[ht_idx]  = 1'b0;
  
    assign hart_ict_read_en[ht_idx]    = 1'b0;
    assign hart_ict_read_data[ht_idx]  = {32{1'b0}};
    assign hart_ict_read_data_tmp[(ht_idx+1)*32+:32]  =  hart_ict_read_data_tmp[ht_idx*32+:32];
    assign hart_claim_read_en[ht_idx]   = 1'b0;                                                      
    assign hart_claim_read_data[ht_idx] = {32{1'b0}};
    assign hart_claim_read_data_tmp[(ht_idx+1)*32+:32] = hart_claim_read_data_tmp[ht_idx*32+:32];    
  //*************************************
  //      hart exist ict slverr
  //*************************************
    assign hart_ict_exist_slverr[ht_idx] = bus_mtx_ict_paddr[ICT_ADDR-1:13] == 12'h100 + ($unsigned(ht_idx) & {13{1'b1}});
  end
end
endgenerate
//*************************************
//  the ict ready signal
//*************************************
  //pic_plic_instance_reg_flog #(.DATA(1)) x_hart_ict_ready_ff(
  //  .clk      (ict_ready_clk),
  //  .en       (bus_mtx_ict_psel),
  //  .rst_b    (plicrst_b),
  //  .data_in  (ict_apb_acc_en),
  //  .data_out (ict_bus_mtx_pready)
  //);
  always @(posedge ict_ready_clk or negedge plicrst_b)
    begin
      if(~plicrst_b)
        ict_bus_mtx_pready <= 1'b0;
      else if(bus_mtx_ict_psel)
        ict_bus_mtx_pready <= ict_apb_acc_en;
    end
//*************************************
//  the ict rdata signal
//*************************************
  pic_plic_instance_reg_flog #(.DATA(32)) x_hart_ict_rdata_ff(
    .clk      (ict_ready_clk),
    .en       (ict_apb_read_en),
    .rst_b    (plicrst_b),
    .data_in  (hart_ict_prdata_pre),
    .data_out (ict_bus_mtx_prdata)
  ); 
  assign hart_ict_prdata_pre[31:0]    = ict_apb_slverr_pre ? {32{1'b0}} 
                                                    : hart_ict_read_data_tmp[HART_NUM*32+:32];
//*************************************
//  the ict slverr signal
//*************************************
  //pic_plic_instance_reg_flog #(.DATA(1)) x_hart_ict_slverr_ff(
  //  .clk      (ict_ready_clk),
  //  .en       (ict_apb_acc_en),
  //  .rst_b    (plicrst_b),
  //  .data_in  (ict_apb_slverr_pre),
  //  .data_out (ict_bus_mtx_pslverr)
  //);
  always @(posedge ict_ready_clk or negedge plicrst_b)
    begin
      if(~plicrst_b)
        ict_bus_mtx_pslverr <= 1'b0;
      else if(ict_apb_acc_en)
        ict_bus_mtx_pslverr <= ict_apb_slverr_pre;
    end

  assign ict_apb_slverr_pre = (bus_mtx_ict_paddr[ICT_ADDR-1:13]>= 12'h100 + $unsigned(HART_NUM))
                              //base address is 0x200000,each core has 0x2000 space. only compare [ICT_ADDR-1:13],core0:0x100,core1:0x101,core2:0x102
                            | (|hart_ict_exist_slverr[HART_NUM-1:0])
                            | ((bus_mtx_ict_paddr[11:2] > {{9{1'b0}},1'b1} )
                               |((bus_mtx_ict_pprot[1] == 1'b0)
                                   & (bus_mtx_ict_paddr[12] == 1'b0) | //[12] means m or s
                                  (bus_mtx_ict_pprot[0] == 1'b0)
                                   & (bus_mtx_ict_paddr[12] == 1'b1))) 
                            | (|icg_psec_nonsec_err_en_rep[HART_NUM:0]);
assign icg_psec_nonsec_err_en_rep[HART_NUM:0] = {1'b0,icg_psec_nonsec_err_en[HART_NUM-1:0]};
pic_gated_clk_cell  x_ict_ready_gateclk (
  .clk_in               (plic_clk            ),
  .clk_out              (ict_ready_clk        ),
  .external_en          (1'b0                ),
  .local_en             (ict_ready_clk_en     ),
  .module_en            (ciu_plic_icg_en      ),
  .pad_yy_icg_scan_en (pad_yy_icg_scan_en)
);
assign   ict_ready_clk_en = ict_apb_acc_en | ict_bus_mtx_pready;

genvar ht_reg_idx;
generate
for(ht_reg_idx=0;ht_reg_idx<HART_NUM;ht_reg_idx=ht_reg_idx+1)
begin:HART_ICT_REG
if(HART_EXIST[ht_reg_idx])
  begin:HART_ICT_REG_TRUE
  //*************************************
  //  the threshold register 
  //*************************************
  
    pic_plic_instance_reg_flog #(.DATA(PRIO_BIT)) x_hart_mth_ff(
      .clk      (th_wr_clk[ht_reg_idx]),
      .en       (busif_hart_mth_wr_en[ht_reg_idx]),
      .rst_b    (plicrst_b),
      .data_in  (bus_mtx_ict_pwdata[PRIO_BIT-1:0]),
      .data_out (hart_mth_flop[ht_reg_idx])
    );
    pic_plic_instance_reg_flog #(.DATA(PRIO_BIT)) x_hart_sth_ff(
      .clk      (th_wr_clk[ht_reg_idx]),
      .en       (busif_hart_sth_wr_en[ht_reg_idx]),
      .rst_b    (plicrst_b),
      .data_in  (bus_mtx_ict_pwdata[PRIO_BIT-1:0]),
      .data_out (hart_sth_flop[ht_reg_idx])
    );
    assign hart_sth_1d_bus[ht_reg_idx*PRIO_BIT+:PRIO_BIT] = hart_sth_flop[ht_reg_idx];
    assign hart_mth_1d_bus[ht_reg_idx*PRIO_BIT+:PRIO_BIT] = hart_mth_flop[ht_reg_idx];
  
    assign hart_mclaim_set_id[ht_reg_idx*ID_NUM+:ID_NUM] = 
                                           {ID_NUM{arbx_hreg_claim_mmode[ht_reg_idx]}} 
                                         & arbx_hreg_claim_id[ID_NUM*ht_reg_idx+:ID_NUM];
    assign hart_sclaim_set_id[ht_reg_idx*ID_NUM+:ID_NUM] = 
                                            {ID_NUM{~arbx_hreg_claim_mmode[ht_reg_idx]}}  
                                          & arbx_hreg_claim_id[ID_NUM*ht_reg_idx+:ID_NUM];
    assign hart_mclaim_clr[ht_reg_idx] = busif_hart_mclaim_rd_en[ht_reg_idx] 
                                         | (|({1'b0,mclaim_eq_vec[ht_reg_idx][0+:HART_NUM]} & {1'b0,busif_hart_mclaim_rd_en[0+:HART_NUM]}))
                                         | (|({1'b0,mclaim_eq_vec[ht_reg_idx][HART_NUM+:HART_NUM]} & {1'b0,busif_hart_sclaim_rd_en[0+:HART_NUM]}));
    assign hart_sclaim_clr[ht_reg_idx] = busif_hart_sclaim_rd_en[ht_reg_idx] 
                                         | (|({1'b0,sclaim_eq_vec[ht_reg_idx][0+:HART_NUM]} & {1'b0,busif_hart_mclaim_rd_en[0+:HART_NUM]}))
                                         | (|({1'b0,sclaim_eq_vec[ht_reg_idx][HART_NUM+:HART_NUM]} & {1'b0,busif_hart_sclaim_rd_en[0+:HART_NUM]}));
  
  //*************************************
  //  the claim register 
  //*************************************
  
    always @(posedge claim_clk[ht_reg_idx] or negedge plicrst_b)
    begin
      if(~plicrst_b)
        hart_mclaim_flop[ht_reg_idx] <= {ID_NUM{1'b0}};
      else if(hart_mclaim_clr[ht_reg_idx])
        hart_mclaim_flop[ht_reg_idx] <= {ID_NUM{1'b0}};
      else if(arbx_hreg_claim_reg_ready[ht_reg_idx])
        hart_mclaim_flop[ht_reg_idx] <= hart_mclaim_set_id[ID_NUM*ht_reg_idx+:ID_NUM];
    end
    always @(posedge claim_clk[ht_reg_idx] or negedge plicrst_b)
    begin
      if(~plicrst_b)
        hart_sclaim_flop[ht_reg_idx] <= {ID_NUM{1'b0}};
      else if(hart_sclaim_clr[ht_reg_idx])
        hart_sclaim_flop[ht_reg_idx] <= {ID_NUM{1'b0}};
      else if(arbx_hreg_claim_reg_ready[ht_reg_idx])
        hart_sclaim_flop[ht_reg_idx] <= hart_sclaim_set_id[ID_NUM*ht_reg_idx+:ID_NUM];
    end
  end
else //this hart is not exist
  begin:HART_ICT_REG_DUMMY
  //*************************************
  //  the threshold register 
  //*************************************
    assign hart_mth_flop[ht_reg_idx] = {PRIO_BIT{1'b0}};
    assign hart_sth_flop[ht_reg_idx] = {PRIO_BIT{1'b0}};
    assign hart_sth_1d_bus[ht_reg_idx*PRIO_BIT+:PRIO_BIT] = hart_sth_flop[ht_reg_idx];
    assign hart_mth_1d_bus[ht_reg_idx*PRIO_BIT+:PRIO_BIT] = hart_mth_flop[ht_reg_idx];
    assign hart_mclaim_set_id[ht_reg_idx*ID_NUM+:ID_NUM] = {ID_NUM{1'b0}};
    assign hart_sclaim_set_id[ht_reg_idx*ID_NUM+:ID_NUM] = {ID_NUM{1'b0}};
    assign hart_mclaim_clr[ht_reg_idx] = 1'b0;
    assign hart_sclaim_clr[ht_reg_idx] = 1'b0;  
  //*************************************
  //  the claim register 
  //************************************* 
    always@(*)
    begin
      hart_mclaim_flop[ht_reg_idx] = {ID_NUM{value_zero}};
      hart_sclaim_flop[ht_reg_idx] = {ID_NUM{value_zero}};
    end
  end
end
endgenerate
// gate clk instance
genvar gk;
generate
for(gk=0;gk<HART_NUM;gk=gk+1)
begin:HART_ICT_GATE_CLK
if(HART_EXIST[gk])
  begin:HART_ICT_GATE_CLK_TRUE
    pic_gated_clk_cell  x_hart_claim_gateclk (
      .clk_in               (plic_clk            ),
      .clk_out              (tmp_claim_clk[gk]   ),
      .external_en          (1'b0                ),
      .local_en             (tmp_claim_clk_en[gk]),
      .module_en            (ciu_plic_icg_en     ),
      .pad_yy_icg_scan_en (pad_yy_icg_scan_en)
    );
    assign tmp_claim_clk_en[gk]         = conv_tmp_claim_clk_en[gk];
    assign claim_clk[gk]                = tmp_claim_clk[gk];
    pic_gated_clk_cell  x_hart_th_wr_gateclk (
      .clk_in               (plic_clk            ),
      .clk_out              (tmp_th_wr_clk[gk]),
      .external_en          (1'b0                ),
      .local_en             (tmp_th_wr_clk_en[gk]),
      .module_en            (ciu_plic_icg_en     ),
      .pad_yy_icg_scan_en (pad_yy_icg_scan_en)
    );
  
    assign tmp_th_wr_clk_en[gk]    = conv_tmp_th_wr_clk_en[gk];
    assign th_wr_clk[gk]           = tmp_th_wr_clk[gk];
  end
else //this hart is not exist
  begin:HART_ICT_GATE_CLK_DUMMY
    assign tmp_claim_clk_en[gk] = 1'b0;
    assign tmp_claim_clk[gk]    = 1'b0;
    assign claim_clk[gk]        = 1'b0;
    assign tmp_th_wr_clk_en[gk] = 1'b0;
    assign tmp_th_wr_clk[gk]    = 1'b0;
    assign th_wr_clk[gk]        = 1'b0;
  end
end
endgenerate
assign conv_tmp_claim_clk_en[HART_NUM-1:0]   = ori_tmp_claim_clk_en[HART_NUM-1:0];
assign ori_tmp_claim_clk_en[HART_NUM-1:0]    = arbx_hreg_claim_reg_ready[HART_NUM-1:0] 
                                              |hart_mclaim_clr[HART_NUM-1:0]
                                              |hart_sclaim_clr[HART_NUM-1:0];
assign conv_tmp_th_wr_clk_en[HART_NUM-1:0]   = ori_tmp_th_wr_clk_en[HART_NUM-1:0];
assign ori_tmp_th_wr_clk_en[HART_NUM-1:0]    = busif_hart_sth_wr_en[HART_NUM-1:0] 
                                              |busif_hart_mth_wr_en[HART_NUM-1:0];
//*************************************
//  the claim register clear vector,
//  which record the equality of each 
//  claim register
//  here, there is another more efficient
//  code
//*************************************
genvar clm_idx,hrt_clm_idx;
generate
for(clm_idx=0;clm_idx<HART_NUM;clm_idx=clm_idx+1)
begin:CLAIM_CMPAR
if(HART_EXIST[clm_idx])
  begin: CLAIM_CMPAR_TRUE
    for(hrt_clm_idx=0;hrt_clm_idx<HART_NUM;hrt_clm_idx=hrt_clm_idx+1)
    begin:CLAIM_CMPARE_IN
      assign mclaim_eq_vec[clm_idx][hrt_clm_idx]         = hart_mclaim_flop[clm_idx] 
                                                            == hart_mclaim_flop[hrt_clm_idx];
      assign mclaim_eq_vec[clm_idx][HART_NUM+hrt_clm_idx]= hart_mclaim_flop[clm_idx] 
                                                            == hart_sclaim_flop[hrt_clm_idx];
      assign sclaim_eq_vec[clm_idx][hrt_clm_idx]         = hart_sclaim_flop[clm_idx] 
                                                            == hart_mclaim_flop[hrt_clm_idx];
      assign sclaim_eq_vec[clm_idx][HART_NUM+hrt_clm_idx]= hart_sclaim_flop[clm_idx] 
                                                            == hart_sclaim_flop[hrt_clm_idx];
    end                                                        
  end
else //if this hart is not exist
  begin: CLAIM_CMPAR_DUMMY
    for(hrt_clm_idx=0;hrt_clm_idx<HART_NUM;hrt_clm_idx=hrt_clm_idx+1)
    begin:CLAIM_CMPARE_IN_DUMMY
      assign mclaim_eq_vec[clm_idx][hrt_clm_idx]          = 1'b0;
      assign mclaim_eq_vec[clm_idx][HART_NUM+hrt_clm_idx] = 1'b0;
      assign sclaim_eq_vec[clm_idx][hrt_clm_idx]          = 1'b0;
      assign sclaim_eq_vec[clm_idx][HART_NUM+hrt_clm_idx] = 1'b0;
    end
  end
end
endgenerate

//**********************************************************************
//    to arbitor  interface
//
//**********************************************************************
assign hreg_arbx_mint_claim[HART_NUM-1:0]          = hart_mclaim_clr[HART_NUM-1:0]; 
assign hreg_arbx_sint_claim[HART_NUM-1:0]          = hart_sclaim_clr[HART_NUM-1:0];
assign hreg_arbx_arb_flush[HART_NUM-1:0]          = {HART_NUM{hreg_claim_vld
                                                      | hreg_cmplt_vld}};
assign hreg_arbx_arb_start[HART_NUM-1:0]          = {HART_NUM{arbx_arb_start_flop}};
assign hreg_arbx_prio_sth[HART_NUM*PRIO_BIT-1:0]  = hart_sth_1d_bus[HART_NUM*PRIO_BIT-1:0];
assign hreg_arbx_prio_mth[HART_NUM*PRIO_BIT-1:0]  = hart_mth_1d_bus[HART_NUM*PRIO_BIT-1:0];
assign hreg_arbx_int_en[INT_NUM*HART_NUM-1:0]     = hart_mie_1d_bus[INT_NUM*HART_NUM-1:0]
                                                    | hart_sie_1d_bus[INT_NUM*HART_NUM-1:0];
assign hreg_arbx_int_mmode[INT_NUM*HART_NUM-1:0]  = {hart_mie_1d_bus[INT_NUM*HART_NUM-1:1],1'b0};

assign arbx_start_ack                             = |{1'b0,arbx_hreg_arb_start_ack[HART_NUM-1:0]};
assign arb_start_en                               = hreg_claim_vld 
                                                    | hreg_cmplt_vld 
                                                    | kid_hreg_new_int_pulse
                                                    | kid_hreg_ip_prio_reg_we
                                                    | (|{1'b0,ie_apb_write_en[HART_NUM-1:0]})
                                                    | ict_apb_write_en;

// record the new event and start the arbitor
always @(posedge plic_clk or negedge plicrst_b)
begin
  if(~plicrst_b)
    arbx_arb_start_flop       <= 1'b0;
  else if(arb_start_en)
    arbx_arb_start_flop       <= 1'b1;
  else if(arbx_start_ack)   
    arbx_arb_start_flop       <= 1'b0;
end
//**********************************************************************
//    to kid interface
//
//**********************************************************************
assign hreg_claim_vld               =   |{1'b0,busif_hart_mclaim_rd_en[HART_NUM-1:0]} |
                                        (|{1'b0,busif_hart_sclaim_rd_en[HART_NUM-1:0]});
assign hreg_kid_claim_id[ID_NUM-1:0]    =   hart_claim_read_data_tmp[HART_NUM*32+:ID_NUM]; 
                                                       
assign hreg_cmplt_vld                   =   |{1'b0,busif_hart_mclaim_wr_en[HART_NUM-1:0]} |
                                            (|{1'b0,busif_hart_sclaim_wr_en[HART_NUM-1:0]});
assign hreg_kid_cmplt_id[ID_NUM-1:0]    =   bus_mtx_ict_pwdata[ID_NUM-1:0];

assign  hart_int_cmplt_vld_tmp[0+:INT_NUM] = {INT_NUM{1'b0}};
assign  hart_int_claim_vld_tmp[0+:INT_NUM] = {INT_NUM{1'b0}};
genvar hart_cmplt_idx;
generate
for(hart_cmplt_idx=0;hart_cmplt_idx<HART_NUM;hart_cmplt_idx=hart_cmplt_idx+1)
begin:HART_CMPLT
if(HART_EXIST[hart_cmplt_idx])
  begin:HART_CMPLT_TRUE
    assign busif_hart_cmplt_int_vld[hart_cmplt_idx][INT_NUM-1:0] = 
                                          ({INT_NUM{busif_hart_mclaim_wr_en[hart_cmplt_idx]}} & 
                                          hart_mie_flop_msk_zero[hart_cmplt_idx]) |
                                          ({INT_NUM{busif_hart_sclaim_wr_en[hart_cmplt_idx]}} & 
                                          hart_sie_flop_msk_zero[hart_cmplt_idx]);
    assign hart_int_cmplt_vld_tmp[INT_NUM*(hart_cmplt_idx+1)+:INT_NUM] = 
                                   hart_int_cmplt_vld_tmp[INT_NUM*(hart_cmplt_idx)+:INT_NUM] | 
                                   busif_hart_cmplt_int_vld[hart_cmplt_idx][INT_NUM-1:0];
    assign busif_hart_claim_int_vld[hart_cmplt_idx][INT_NUM-1:0] = 
                                          ({INT_NUM{busif_hart_mclaim_rd_en[hart_cmplt_idx]}} & 
                                          hart_mie_flop_msk_zero[hart_cmplt_idx]) |
                                          ({INT_NUM{busif_hart_sclaim_rd_en[hart_cmplt_idx]}} & 
                                          hart_sie_flop_msk_zero[hart_cmplt_idx]);
    assign hart_int_claim_vld_tmp[INT_NUM*(hart_cmplt_idx+1)+:INT_NUM] =  
                                   hart_int_claim_vld_tmp[INT_NUM*(hart_cmplt_idx)+:INT_NUM] | 
                                   busif_hart_claim_int_vld[hart_cmplt_idx];
  end
else //if this hart is not exist
  begin:HART_CMPLT_DUMMY
    assign busif_hart_cmplt_int_vld[hart_cmplt_idx][INT_NUM-1:0]       =  
                                          ({INT_NUM{busif_hart_mclaim_wr_en[hart_cmplt_idx]}} & 
                                          hart_mie_flop_msk_zero[hart_cmplt_idx]) |
                                          ({INT_NUM{busif_hart_sclaim_wr_en[hart_cmplt_idx]}} & 
                                          hart_sie_flop_msk_zero[hart_cmplt_idx]);
    assign hart_int_cmplt_vld_tmp[INT_NUM*(hart_cmplt_idx+1)+:INT_NUM] = //{INT_NUM{1'b1}};
                                                                         hart_int_cmplt_vld_tmp[INT_NUM*(hart_cmplt_idx)+:INT_NUM] |
                                                                         busif_hart_cmplt_int_vld[hart_cmplt_idx][INT_NUM-1:0];
    assign busif_hart_claim_int_vld[hart_cmplt_idx][INT_NUM-1:0]       = {INT_NUM{1'b0}};
    assign hart_int_claim_vld_tmp[INT_NUM*(hart_cmplt_idx+1)+:INT_NUM] = hart_int_claim_vld_tmp[INT_NUM*(hart_cmplt_idx)+:INT_NUM];
  end
end
endgenerate

 
genvar cmplt_idx;
generate
  for(cmplt_idx=0;cmplt_idx<INT_NUM;cmplt_idx=cmplt_idx+1)
  begin:CMPLT
    assign hart_cmplt_id_expnd[cmplt_idx] = (hreg_kid_cmplt_id[ID_NUM-1:0] == ($unsigned(cmplt_idx) & {ID_NUM{1'b1}}));
    assign hart_claim_id_expnd[cmplt_idx] = (hreg_kid_claim_id[ID_NUM-1:0] == ($unsigned(cmplt_idx) & {ID_NUM{1'b1}}));
  end 
endgenerate
assign hreg_kid_cmplt_vld[INT_NUM-1:0] = hart_cmplt_id_expnd[INT_NUM-1:0] & 
                                         hart_int_cmplt_vld_tmp[INT_NUM*HART_NUM +: INT_NUM];
assign hreg_kid_claim_vld[INT_NUM-1:0] = hart_claim_id_expnd[INT_NUM-1:0] & 
                                         hart_int_claim_vld_tmp[INT_NUM*HART_NUM +: INT_NUM];                                         
endmodule
// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : pic_plic_instance_reg_flog.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-1
// FUNCTION        : flop 
// ******************************************************************************
module pic_plic_instance_reg_flog(
  //input
  clk,
  rst_b,
  en,
  data_in,
  //output
  data_out
);
parameter DATA = 32;

input             clk;
input             rst_b;
input             en;
input  [DATA-1:0] data_in;

output [DATA-1:0] data_out;

reg    [DATA-1:0] data_flop;

always @(posedge clk or negedge rst_b)
begin
  if(~rst_b)
    data_flop[DATA-1:0] <= {DATA{1'b0}};
  else if(en)
    data_flop[DATA-1:0] <= data_in[DATA-1:0];
end
assign data_out[DATA-1:0] = data_flop[DATA-1:0];
endmodule
// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : pic_plic_int_kid.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-1
// FUNCTION        : PLIC interrupt kid
//                   1. including int ip, int priority
//                   
//                   2. 
//                   3. 
// ******************************************************************************

module pic_plic_int_kid(
  busif_clr_kid_ip_x,
  busif_set_kid_ip_x,
  busif_we_kid_prio_data,
  busif_we_kid_prio_x,
  hreg_int_claim_kid_x,
  hreg_int_complete_kid_x,
  int_vld_aft_sync_x,
  pad_plic_int_cfg_x,
  kid_arb_int_prio_x,
  kid_arb_int_pulse_x,
  kid_arb_int_req_x,
  kid_busif_int_prio_x,
  kid_busif_pending_x,
  kid_clk,
  kid_hreg_int_pulse_x,
  kid_sample_en,
  kid_int_active_x,
  plicrst_b
);

parameter       PRIO_BIT = 5;
// &Ports; @26
input                   busif_clr_kid_ip_x;     
input                   busif_set_kid_ip_x;     
input   [PRIO_BIT-1:0]  busif_we_kid_prio_data; 
input                   busif_we_kid_prio_x;    
input                   hreg_int_claim_kid_x;   
input                   hreg_int_complete_kid_x; 
input                   int_vld_aft_sync_x;     
input                   pad_plic_int_cfg_x;
input                   kid_clk;                
input                   plicrst_b;              
output  [PRIO_BIT-1:0]  kid_arb_int_prio_x;     
output                  kid_arb_int_pulse_x;    
output                  kid_arb_int_req_x;      
output  [PRIO_BIT-1:0]  kid_busif_int_prio_x;   
output                  kid_busif_pending_x;    
output                  kid_hreg_int_pulse_x;   
output                  kid_sample_en;          
output                  kid_int_active_x;          

// &Regs; @27
reg                     int_active;             
reg                     int_pending;            
reg     [PRIO_BIT-1:0]  int_priority;           
reg                     int_vld_ff;             

// &Wires; @28
wire                    busif_clr_kid_ip_x;     
wire                    busif_set_kid_ip_x;     
wire    [PRIO_BIT-1:0]  busif_we_kid_prio_data; 
wire                    busif_we_kid_prio_x;    
wire                    hreg_int_claim_kid_x;   
wire                    hreg_int_complete_kid_x; 
wire                    int_pulse;              
wire                    int_vld;                
wire                    int_vld_aft_sync_x;     
wire    [PRIO_BIT-1:0]  kid_arb_int_prio_x;     
wire                    kid_arb_int_pulse_x;    
wire                    kid_arb_int_req_x;      
wire    [PRIO_BIT-1:0]  kid_busif_int_prio_x;   
wire                    kid_busif_pending_x;    
wire                    kid_clk;                
wire                    kid_hreg_int_pulse_x;   
wire                    kid_sample_en;          
wire                    plicrst_b;              
wire                    int_new_pending;
wire                    int_new_set_pending;
wire                    level_int_pending;


assign int_vld = int_vld_aft_sync_x;

//------------------------------------------------
//   sample the interrupt
//------------------------------------------------

assign kid_sample_en = int_vld ^ int_vld_ff;

always@(posedge kid_clk or negedge plicrst_b)
begin
  if(~plicrst_b)
    int_vld_ff <= 1'b0;
  else 
    int_vld_ff <= int_vld;
end

assign int_pulse           = int_vld & ~int_vld_ff;
assign int_new_pending     = pad_plic_int_cfg_x ? int_pulse 
                                                : level_int_pending;
assign level_int_pending   = hreg_int_complete_kid_x ? int_vld : int_pulse;
assign int_new_set_pending = (~int_active | hreg_int_complete_kid_x)
                             & int_new_pending;
//------------------------------------------------
// PENDING register
//------------------------------------------------

always @(posedge kid_clk or negedge plicrst_b)
begin
  if(~plicrst_b)
    int_pending <= 1'b0;
  else if(busif_clr_kid_ip_x | hreg_int_claim_kid_x)
    int_pending <= 1'b0;
  else if(busif_set_kid_ip_x | int_new_set_pending)
    int_pending <= 1'b1;
end


//------------------------------------------------
// PRIORITY register
//------------------------------------------------
always@(posedge kid_clk or negedge plicrst_b)
begin
  if(~plicrst_b)
    int_priority[PRIO_BIT-1:0] <= {PRIO_BIT{1'b0}};
  else if(busif_we_kid_prio_x)
    int_priority[PRIO_BIT-1:0] <= busif_we_kid_prio_data[PRIO_BIT-1:0];
end

//===========================================================
//     interrupt active register
//     using this to mask-off the pending
//===========================================================
always @(posedge kid_clk or negedge plicrst_b)
begin
  if(~plicrst_b)
    int_active  <= 1'b0;
  else if(hreg_int_claim_kid_x) 
    int_active  <= 1'b1;
  else if(hreg_int_complete_kid_x)
    int_active  <= 1'b0;
end

assign kid_arb_int_pulse_x                = int_pulse;
assign kid_arb_int_req_x                  = int_pending 
                                            & ~int_active 
                                            & (int_priority[PRIO_BIT-1:0] != {PRIO_BIT{1'b0}});
assign kid_arb_int_prio_x[PRIO_BIT-1:0]   = int_priority[PRIO_BIT-1:0];
assign kid_hreg_int_pulse_x               = int_pulse;
assign kid_busif_int_prio_x[PRIO_BIT-1:0] = int_priority[PRIO_BIT-1:0];
assign kid_busif_pending_x                = int_pending;

//for func coverage
assign kid_int_active_x = int_active;
// &ModuleEnd; @96
endmodule




// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : pic_plic_kid_busif.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-1
// FUNCTION        : PLIC interrupt kid bus interface
//                   1. including int ip, int priority read and write
//                   
//                   2. parameterize the int source number, priority
//                   3. two apb bus,  for int pending and int priority
// ******************************************************************************

module pic_plic_kid_busif(
  //input
  plic_clk,
  plicrst_b,
  bus_mtx_prio_psel,
  bus_mtx_prio_pprot,
  bus_mtx_prio_penable,
  bus_mtx_prio_paddr,
  bus_mtx_prio_pwrite,
  bus_mtx_prio_pwdata,
  bus_mtx_prio_psec,
  bus_mtx_ip_psel,
  bus_mtx_ip_pprot,
  bus_mtx_ip_penable,
  bus_mtx_ip_paddr,
  bus_mtx_ip_pwrite,
  bus_mtx_ip_pwdata,
  bus_mtx_ip_psec,
  pad_plic_int_vld,
  pad_plic_int_cfg,
  hreg_kid_claim_vld,
  //hreg_kid_claim_id,
  hreg_kid_cmplt_vld,
  ciu_plic_icg_en,
  pad_yy_icg_scan_en,
  ctrl_xx_amp_mode,
  int_sec_infor,


  //output
  ip_bus_mtx_pready,
  ip_bus_mtx_prdata,
  ip_bus_mtx_pslverr,
  prio_bus_mtx_pready,
  prio_bus_mtx_prdata,
  prio_bus_mtx_pslverr,
  kid_hreg_new_int_pulse,
  kid_hreg_ip_prio_reg_we,
  kid_yy_int_req,
  kid_yy_int_prio

);
parameter       INT_NUM     = 1024;
parameter       PRIO_BIT    = 5;
parameter       ID_NUM      = 10;
parameter       ADDR        = 12;

localparam      PRIO_SPLIT1  = INT_NUM/128;   // each 128 will have one slave port.
localparam      RE_INT_NUM   = PRIO_SPLIT1 * 128;
localparam      LEFT_INT     = INT_NUM - RE_INT_NUM;
localparam      PRIO_SLV_NUM = LEFT_INT > 0 ?  PRIO_SPLIT1 + 1 :  PRIO_SPLIT1;
localparam      PRIO_SPLIT1_FOR_CMP = (PRIO_SPLIT1 == 0) ? 1 : PRIO_SPLIT1;
localparam      VALLUE_128    = 128;
localparam      FILL_LEFT_INT = ($unsigned(VALLUE_128-LEFT_INT) & 7'h7f) + {{6{1'b0}},1'b1};
localparam      VALUE_4       = 4; //for lint
localparam      VALUE_9       = 9; //for lint
localparam      VALUE_32      = 32; //for lint
input                       plic_clk;
input                       plicrst_b;
input                       bus_mtx_ip_psel;
input   [1:0]               bus_mtx_ip_pprot;
input                       bus_mtx_ip_penable;
input   [ADDR-1:0]          bus_mtx_ip_paddr;
input                       bus_mtx_ip_pwrite;
input   [31:0]              bus_mtx_ip_pwdata;
input                       bus_mtx_ip_psec;
input   [INT_NUM-1:0]       int_sec_infor;

input                       bus_mtx_prio_psel;
input   [1:0]               bus_mtx_prio_pprot;
input                       bus_mtx_prio_penable;
input   [ADDR-1:0]          bus_mtx_prio_paddr;
input                       bus_mtx_prio_pwrite;
input   [31:0]              bus_mtx_prio_pwdata;
input                       bus_mtx_prio_psec;
input   [INT_NUM-1:0]       pad_plic_int_vld;
input   [INT_NUM-1:0]       pad_plic_int_cfg;
input   [INT_NUM-1:0]       hreg_kid_claim_vld;
//input   [ID_NUM-1:0]        hreg_kid_claim_id;
input   [INT_NUM-1:0]       hreg_kid_cmplt_vld;
input                       ciu_plic_icg_en;
input                       pad_yy_icg_scan_en;
input                       ctrl_xx_amp_mode;

output                      ip_bus_mtx_pready;
output  [31:0]              ip_bus_mtx_prdata;
output                      ip_bus_mtx_pslverr;
output                      prio_bus_mtx_pready;
output  [31:0]              prio_bus_mtx_prdata;
output                      prio_bus_mtx_pslverr;
output                      kid_hreg_new_int_pulse;
output [INT_NUM-1:0]        kid_yy_int_req;
output [INT_NUM*PRIO_BIT-1:0]kid_yy_int_prio;
output                      kid_hreg_ip_prio_reg_we;

//wire definition
wire  [INT_NUM-1:0]         busif_clr_kid_ip;
wire  [INT_NUM-1:0]         busif_set_kid_ip;
wire  [INT_NUM-1:0]         hreg_int_claim_kid;
wire  [INT_NUM*PRIO_BIT-1:0]kid_arb_int_prio;
wire  [INT_NUM-1:0]         kid_arb_int_pulse; 
wire  [INT_NUM-1:0]         kid_arb_int_req;
wire  [INT_NUM-1:0]         kid_int_active;
wire  [PRIO_BIT-1:0]        kid_busif_int_prio[PRIO_SLV_NUM*128:0];
wire  [INT_NUM-1:0]         kid_busif_pending;
wire  [INT_NUM-1:0]         kid_hreg_int_pulse;
wire  [INT_NUM-1:0]         kid_sample_en;
wire  [PRIO_SLV_NUM-1:0]    prio_split_pslverr;
wire  [PRIO_SLV_NUM-1:0]    prio_split_pslverr_pre;
wire  [PRIO_SLV_NUM-1:0]    prio_split_psel;
wire  [PRIO_SLV_NUM-1:0]    prio_split_psec;
wire  [PRIO_SLV_NUM*2-1:0]  prio_split_pprot;
wire  [PRIO_SLV_NUM-1:0]    prio_split_penable;
wire  [PRIO_SLV_NUM-1:0]    prio_split_pwrite;
wire  [PRIO_SLV_NUM*12-1:0] prio_split_paddr;
wire  [PRIO_SLV_NUM*32-1:0] prio_split_pwdata;   
wire  [PRIO_SLV_NUM*32-1:0] prio_split_prdata;
wire  [PRIO_SLV_NUM:0]      prio_apb_write_en;
wire  [PRIO_SLV_NUM-1:0]    prio_apb_read_en;
wire  [PRIO_SLV_NUM*PRIO_BIT-1:0]prio_split_prdata_pre;
wire                        prio_lst_apb_acc_en;
wire                        prio_lst_apb_addr_non;
wire                        ip_apb_acc_en;
wire                        ip_apb_write_en;
wire                        ip_apb_read_en;
wire [INT_NUM+31:0]         ip_read_data_tmp;
wire [INT_NUM/32-1:0]       ip_wrd_write_en;
wire [INT_NUM/32-1:0]       ip_wrd_read_en;
wire [PRIO_SLV_NUM-1:0]     prio_ready_clk;
wire [PRIO_SLV_NUM-1:0]     prio_ready_clk_en;
wire                        ip_ready_clk;
wire                        ip_ready_clk_en;
wire [INT_NUM/32  :0]       kids_regs_clk;
wire [INT_NUM/32-1:0]       kids_regs_clk_en;
wire [INT_NUM+31:0]          kid_clk;
wire [PRIO_SLV_NUM-1:0]     prio_apb_acc_en;
wire  [PRIO_SLV_NUM*PRIO_BIT-1:0] prio_split_prdata_flop;
wire  [PRIO_SLV_NUM-1:0]    prio_split_prv_vio;
wire  [PRIO_SLV_NUM*12-1:0]  prio_split_base_addr;
wire  [PRIO_SLV_NUM*12-1:0]  prio_split_base_addr_msk;
wire [9:0]                   tmp_prio_split_pslverr_pre;
wire [9:0]                   tmp_prio_split_pslverr;
wire [INT_NUM-1:0]           ip_kid_sec_mask;
wire [PRIO_SLV_NUM*128:0]  int_sec_infor_pack;
wire [INT_NUM-1:0]         plic_int_sync;
//reg definition

reg                         lst_apb_slverr;
reg  [31:0]                 ip_bus_mtx_prdata_flop;
reg                         ip_bus_mtx_pready_flop;
reg                         ip_bus_mtx_pslverr_flop;
reg  [PRIO_SLV_NUM-1:0]     prio_split_pready;
wire                         ip_bus_mtx_pslverr_pre;
wire  [PRIO_BIT-1:0]         busif_we_kid_prio_data[PRIO_SLV_NUM*128-1:0];
wire  [PRIO_SLV_NUM*128-1:0] busif_we_kid_prio;
wire   [PRIO_SLV_NUM*128-1:0]busif_rd_kid_prio;
wire  [129*PRIO_BIT-1:0]     prio_lst_read_tmp[PRIO_SLV_NUM-1:0];
wire [128*PRIO_SLV_NUM-1:0]  prio_kid_sec_mask;

//**********************************************************************
//  using 2-stage flop to sync the input interrupt
//
//**********************************************************************
genvar kid_idx;
generate
for(kid_idx=0;kid_idx<INT_NUM;kid_idx=kid_idx+1)
begin:INT_SYNC
  pic_sync_dff  x_pic_sync_dff (
        .clk          (plic_clk),
        .rst_b        (plicrst_b),
        .sync_in      (pad_plic_int_vld[kid_idx]),
        .sync_out     (plic_int_sync[kid_idx])
    );
end
endgenerate

//**********************************************************************
//   instance the int kid
//
//**********************************************************************
genvar i;
generate
for(i=1;i<INT_NUM;i=i+1)
begin:INT_KID
  pic_plic_int_kid #(.PRIO_BIT(PRIO_BIT)) x_pic_plic_int_kid(
    .busif_clr_kid_ip_x         (busif_clr_kid_ip[i]),
    .busif_set_kid_ip_x         (busif_set_kid_ip[i]),
    .busif_we_kid_prio_data     (busif_we_kid_prio_data[i]), 
    .busif_we_kid_prio_x        (busif_we_kid_prio[i]),
    .hreg_int_claim_kid_x       (hreg_int_claim_kid[i]),
    .hreg_int_complete_kid_x    (hreg_kid_cmplt_vld[i]),
    .int_vld_aft_sync_x         (plic_int_sync[i]),
    .pad_plic_int_cfg_x         (pad_plic_int_cfg[i]),
    .kid_arb_int_prio_x         (kid_arb_int_prio[PRIO_BIT*i+:PRIO_BIT]),
    .kid_arb_int_pulse_x        (kid_arb_int_pulse[i]),
    .kid_arb_int_req_x          (kid_arb_int_req[i]),
    .kid_busif_int_prio_x       (kid_busif_int_prio[i]),
    .kid_busif_pending_x        (kid_busif_pending[i]),
    .kid_clk                    (kid_clk[i]),
    .kid_hreg_int_pulse_x       (kid_hreg_int_pulse[i]),
    .kid_sample_en              (kid_sample_en[i]),
    .kid_int_active_x           (kid_int_active[i]),
    .plicrst_b                  (plicrst_b)
);
end
endgenerate
// gate clk instance
assign kid_arb_int_pulse[0]           = 1'b0;
assign kid_arb_int_prio[0+:PRIO_BIT]  = {PRIO_BIT{1'b0}};
assign kid_arb_int_req[0]             = 1'b1;
assign kid_busif_int_prio[0]          = {PRIO_BIT{1'b0}};
assign kid_busif_pending[0]           = 1'b0;
assign kid_sample_en[0]               = 1'b0;
assign kid_hreg_int_pulse[0]          = 1'b0;
assign kid_int_active[0]              = 1'b0;

genvar gk;
generate
for(gk=0;gk<INT_NUM/32;gk=gk+1)
begin:KID_GATE_CLK
  pic_gated_clk_cell  x_kid_regs_gateclk (
    .clk_in               (plic_clk            ),
    .clk_out              (kids_regs_clk[gk]   ),
    .external_en          (1'b0                ),
    .local_en             (kids_regs_clk_en[gk]),
    .module_en            (ciu_plic_icg_en     ),
    .pad_yy_icg_scan_en (pad_yy_icg_scan_en)
  );
  assign kids_regs_clk_en[gk]  =    |kid_sample_en[gk*32+:32] 
                                 | (|busif_we_kid_prio[gk*32+:32])
                                 | ip_wrd_write_en[gk]
                                 | (|hreg_int_claim_kid[gk*32+:32])
                                 | (|hreg_kid_cmplt_vld[gk*32+:32]);
end
endgenerate

assign kid_clk[31:0]             = {{31{kids_regs_clk[0]}},1'b0};
assign kids_regs_clk[INT_NUM/32] = 1'b0; //to fix lint
genvar kc;
generate  
  for(kc=1;kc<INT_NUM/32+1;kc=kc+1)
    begin:KID_CLK_GEN
      assign kid_clk[kc*32+:32]    = {32{kids_regs_clk[kc]}};
    end
endgenerate

genvar add_idx;
generate
for(add_idx=0;add_idx<$signed(FILL_LEFT_INT);add_idx=add_idx+1)
begin:LFT_PRIO
assign kid_busif_int_prio[INT_NUM + add_idx][PRIO_BIT-1:0]  = {PRIO_BIT{1'b0}}; 
assign int_sec_infor_pack[INT_NUM + add_idx]                = 1'b1;
end
endgenerate
assign int_sec_infor_pack[INT_NUM-1:0]  = int_sec_infor[INT_NUM-1:0];
//**********************************************************************
//   priority  write and read interface
//   
//**********************************************************************

//**********************************************************************
//   apb matrix for prio write
//   first, prepare the base address for every slave port
//**********************************************************************

genvar j;
generate
for(j=0;j<PRIO_SLV_NUM;j=j+1)
begin:SLV_BASE_ADDR
  assign prio_split_base_addr[j*12+:12] = $unsigned(j<<<VALUE_9) & {12{1'b1}};
  assign prio_split_base_addr_msk[j*12+:12] = {{3{1'b1}},{9{1'b0}}};
end
endgenerate
pic_plic_apb_1tox_matrix #(.ADDR(12),
                       .SLAVE(PRIO_SLV_NUM)
                       )x_prio_1tox_matrix(
  //input
  .pclk         (plic_clk),
  .prst_b       (plicrst_b),
  .slv_paddr    (bus_mtx_prio_paddr),
  .slv_psel     (bus_mtx_prio_psel),
  .slv_pprot    (bus_mtx_prio_pprot),
  .slv_penable  (bus_mtx_prio_penable),
  .slv_pwrite   (bus_mtx_prio_pwrite),
  .slv_pwdata   (bus_mtx_prio_pwdata),
  .slv_psec     (bus_mtx_prio_psec ),
  .mst_pready   (prio_split_pready[PRIO_SLV_NUM-1:0]),
  .mst_prdata   (prio_split_prdata[PRIO_SLV_NUM*32-1:0]),
  .mst_pslverr  (prio_split_pslverr[PRIO_SLV_NUM-1:0]),
  .mst_base_addr(prio_split_base_addr[PRIO_SLV_NUM*12-1:0]),
  .mst_base_addr_msk(prio_split_base_addr_msk[PRIO_SLV_NUM*12-1:0]),
  .other_slv_sel({PRIO_SLV_NUM{1'b0}}),
  .ciu_plic_icg_en(ciu_plic_icg_en),
  .pad_yy_icg_scan_en(pad_yy_icg_scan_en),
  //.output(output)
  .mst_psel     (prio_split_psel[PRIO_SLV_NUM-1:0]),
  .mst_pprot    (prio_split_pprot[PRIO_SLV_NUM*2-1:0]),
  .mst_penable  (prio_split_penable[PRIO_SLV_NUM-1:0]),
  .mst_paddr    (prio_split_paddr[PRIO_SLV_NUM*12-1:0]),
  .mst_pwrite   (prio_split_pwrite[PRIO_SLV_NUM-1:0]),
  .mst_pwdata   (prio_split_pwdata[PRIO_SLV_NUM*32-1:0]),
  .mst_psec     (prio_split_psec[PRIO_SLV_NUM-1:0]),
  .slv_pready   (prio_bus_mtx_pready),
  .slv_prdata   (prio_bus_mtx_prdata),
  .slv_pslverr  (prio_bus_mtx_pslverr)
);
//****************************************************
//   generate the write/read signal
//   for each prio
//****************************************************
//*************************************
//  the int prio write en
//  the int prio write data
//  the read data collecting
//*************************************
genvar k,m;
generate
for(k=0;k<PRIO_SLV_NUM;k=k+1)
begin:WR_DATA
  assign prio_lst_read_tmp[k][PRIO_BIT-1:0] = {PRIO_BIT{1'b0}};
  for(m=0;m<128;m=m+1)
    begin:WR_DATA_IN
      assign prio_kid_sec_mask[k*128+m]  = prio_split_psec[k] | ~int_sec_infor_pack[k*128+m] | ~ctrl_xx_amp_mode ;
      assign busif_we_kid_prio[k*128+m] = prio_apb_write_en[k] & (prio_split_paddr[(2+12*k)+:7] == ($unsigned(m) & {7{1'b1}})) 
                                   & prio_kid_sec_mask[k*128+m];
      assign busif_rd_kid_prio[k*128+m] = prio_apb_read_en[k] & (prio_split_paddr[(2+12*k)+:7] == ($unsigned(m) & {7{1'b1}}))
                                   & prio_kid_sec_mask[k*128+m];
      assign busif_we_kid_prio_data[k*128+m][PRIO_BIT-1:0] 
                                 = prio_split_pwdata[32*k+:PRIO_BIT];
      assign prio_lst_read_tmp[k][PRIO_BIT*(m+1)+:PRIO_BIT]
                                        = prio_lst_read_tmp[k][PRIO_BIT*m+:PRIO_BIT]
                                          |({PRIO_BIT{busif_rd_kid_prio[k*128+m]}} 
                                            & kid_busif_int_prio[k*128+m]);
   end 
end
endgenerate


genvar slv_idx;
generate
for(slv_idx=0;slv_idx<PRIO_SLV_NUM;slv_idx=slv_idx+1)
begin:APB_SEL_EN
  assign prio_apb_write_en[slv_idx]   =  prio_apb_acc_en[slv_idx] 
                                         & prio_split_pwrite[slv_idx]
                                         & ~prio_split_pslverr_pre[slv_idx];
  assign prio_apb_read_en[slv_idx]    =  prio_apb_acc_en[slv_idx] 
                                         & ~prio_split_pwrite[slv_idx];
  assign prio_split_prdata_pre[slv_idx*PRIO_BIT+:PRIO_BIT] 
                                      = prio_split_pslverr_pre[slv_idx] ? {PRIO_BIT{1'b0}} : prio_lst_read_tmp[slv_idx][PRIO_BIT*128+:PRIO_BIT];
//*************************************
//  the prio split ready signal
//*************************************
  assign prio_apb_acc_en[slv_idx]   = prio_split_psel[slv_idx] & ~prio_split_penable[slv_idx];
  //pic_plic_instance_reg_flog #(.DATA(1)) x_prio_split_ready_ff(
  //  .clk      (prio_ready_clk[slv_idx]),
  //  .en       (prio_split_psel[slv_idx]),
  //  .rst_b    (plicrst_b),
  //  .data_in  (prio_apb_acc_en[slv_idx]),
  //  .data_out (prio_split_pready[slv_idx])
  //);
  always @(posedge prio_ready_clk[slv_idx] or negedge plicrst_b)
    begin
      if(~plicrst_b)
        prio_split_pready[slv_idx] <= 1'b0;
      else if(prio_split_psel[slv_idx])
        prio_split_pready[slv_idx] <= prio_apb_acc_en[slv_idx];
    end
//*************************************
//  the prio split rdata signal
//*************************************
  pic_plic_instance_reg_flog #(.DATA(PRIO_BIT)) x_prio_split_rdata_ff(
    .clk      (prio_ready_clk[slv_idx]),
    .en       (prio_apb_read_en[slv_idx]),
    .rst_b    (plicrst_b),
    .data_in  (prio_split_prdata_pre[slv_idx*PRIO_BIT+:PRIO_BIT]),
    .data_out (prio_split_prdata_flop[slv_idx*PRIO_BIT+:PRIO_BIT])
  ); 
  pic_gated_clk_cell  x_prio_split_ready_gateclk (
    .clk_in               (plic_clk            ),
    .clk_out              (prio_ready_clk[slv_idx]),
    .external_en          (1'b0                ),
    .local_en             (prio_ready_clk_en[slv_idx]),
    .module_en            (ciu_plic_icg_en     ),
    .pad_yy_icg_scan_en (pad_yy_icg_scan_en)
  );
  assign prio_ready_clk_en[slv_idx]           = prio_apb_acc_en[slv_idx] | prio_split_pready[slv_idx];
  assign prio_split_prdata[slv_idx*32+:32]    = {{(32-PRIO_BIT){1'b0}},
                                           prio_split_prdata_flop[slv_idx*PRIO_BIT+:PRIO_BIT]};
  assign prio_split_prv_vio[slv_idx]    = (prio_split_pprot[slv_idx*2+1] == 1'b0);
end
endgenerate
//****************************************************
//   generate the slverr signal
//   for each split apb bus
//****************************************************
//*************************************
//  for the 0-PRIO_SPLIT1, the access
//  response is OK,
//  for the PRIO_SPLIT1 < PRIO_SLV_NUM
//  the access in non-exist int will 
//  response with err
//*************************************
assign prio_lst_apb_acc_en = prio_split_psel[PRIO_SLV_NUM-1] 
                              & ~prio_split_penable[PRIO_SLV_NUM-1];
assign prio_lst_apb_addr_non = (prio_split_paddr[12*(PRIO_SLV_NUM-1)+:9] >=
                               $unsigned(LEFT_INT*VALUE_4)) & (LEFT_INT>0);
always @(posedge prio_ready_clk[PRIO_SLV_NUM-1] or negedge plicrst_b)
begin
  if(~plicrst_b)
    lst_apb_slverr <= 1'b0;
  else if(prio_lst_apb_acc_en)
    lst_apb_slverr <= prio_lst_apb_addr_non;
end

assign tmp_prio_split_pslverr_pre[9:0]           = {{9-PRIO_SLV_NUM{1'b0}},prio_split_prv_vio[PRIO_SLV_NUM-1:0],1'b0} |
                                                   {{9-PRIO_SLV_NUM{1'b0}},prio_lst_apb_addr_non,{PRIO_SLV_NUM{1'b0}}};
assign tmp_prio_split_pslverr[9:0]               = {{9-PRIO_SLV_NUM{1'b0}},prio_split_prv_vio[PRIO_SLV_NUM-1:0],1'b0} |
                                                   {{9-PRIO_SLV_NUM{1'b0}},lst_apb_slverr,{PRIO_SLV_NUM{1'b0}}};
assign prio_split_pslverr_pre[PRIO_SLV_NUM-1:0]  = tmp_prio_split_pslverr_pre[PRIO_SLV_NUM:1];
assign prio_split_pslverr[PRIO_SLV_NUM-1:0]      = tmp_prio_split_pslverr[PRIO_SLV_NUM:1];

//**********************************************************************
//   priority  write and read interface
//   
//**********************************************************************
assign ip_apb_acc_en   = bus_mtx_ip_psel & ~bus_mtx_ip_penable;
assign ip_apb_write_en = ip_apb_acc_en & bus_mtx_ip_pwrite & ~ip_bus_mtx_pslverr_pre;
assign ip_apb_read_en  = ip_apb_acc_en & ~bus_mtx_ip_pwrite;
assign ip_read_data_tmp[31:0] = {32{1'b0}};
 
genvar n;
generate
for(n=0;n<INT_NUM/32;n=n+1)
begin:IP_WR
  assign ip_kid_sec_mask[n*32+:32]  = {32{bus_mtx_ip_psec}} | ~int_sec_infor[n*32+:32] | {32{~ctrl_xx_amp_mode}} ;
  assign ip_wrd_write_en[n]         = ip_apb_write_en & (bus_mtx_ip_paddr[11:2] == ($unsigned(n) & {10{1'b1}}));
  assign ip_wrd_read_en[n]          = ip_apb_read_en & (bus_mtx_ip_paddr[11:2] == ($unsigned(n) & {10{1'b1}}));
  assign busif_set_kid_ip[n*32+:32] = {32{ip_wrd_write_en[n]}} & ((bus_mtx_ip_pwdata[31:0]     & ip_kid_sec_mask[n*32+:32]) |
                                                                  (kid_busif_pending[n*32+:32] & ~ip_kid_sec_mask[n*32+:32]));
  assign busif_clr_kid_ip[n*32+:32] = {32{ip_wrd_write_en[n]}} & ((~bus_mtx_ip_pwdata[31:0]     & ip_kid_sec_mask[n*32+:32]));
  assign ip_read_data_tmp[(n+1)*32+:32] = ip_read_data_tmp[n*32+:32] |
                                          ({32{ip_wrd_read_en[n]}}  
                                           & kid_busif_pending[n*32+:32]
                                           & ip_kid_sec_mask[n*32+:32]);
end
endgenerate
always @(posedge ip_ready_clk or negedge plicrst_b)
begin
  if(~plicrst_b)
    ip_bus_mtx_prdata_flop[31:0] <= {32{1'b0}};
  else if(ip_apb_read_en)
    ip_bus_mtx_prdata_flop[31:0] <= ip_bus_mtx_pslverr_pre ? {32{1'b0}} :ip_read_data_tmp[INT_NUM+:32];
end
always @(posedge ip_ready_clk or negedge plicrst_b)
begin
  if(~plicrst_b)
  begin
    ip_bus_mtx_pready_flop <= 1'b0;
    ip_bus_mtx_pslverr_flop<= 1'b0;
  end
  else 
  begin
    ip_bus_mtx_pready_flop <= ip_apb_acc_en;
    ip_bus_mtx_pslverr_flop<= ip_bus_mtx_pslverr_pre;
  end
end
assign ip_bus_mtx_pslverr_pre = (bus_mtx_ip_paddr[11:2] >= $unsigned(INT_NUM/VALUE_32)) 
                              | (bus_mtx_ip_pprot[1]== 1'b0);

pic_gated_clk_cell  x_ip_ready_gateclk (
  .clk_in               (plic_clk            ),
  .clk_out              (ip_ready_clk        ),
  .external_en          (1'b0                ),
  .local_en             (ip_ready_clk_en     ),
  .module_en            (ciu_plic_icg_en     ),
  .pad_yy_icg_scan_en (pad_yy_icg_scan_en)
);
assign ip_ready_clk_en          = ip_apb_acc_en | ip_bus_mtx_pready_flop;
assign ip_bus_mtx_pready        = ip_bus_mtx_pready_flop;
assign ip_bus_mtx_pslverr       = ip_bus_mtx_pslverr_flop;
assign ip_bus_mtx_prdata[31:0]  = ip_bus_mtx_prdata_flop[31:0];
//**********************************************************************
//   interface to Hreg
//   
//**********************************************************************
assign prio_apb_write_en[PRIO_SLV_NUM] = 1'b0; //add 1'b0 at top bit to fix lint
assign kid_hreg_new_int_pulse          = |kid_hreg_int_pulse[INT_NUM-1:0];
assign kid_hreg_ip_prio_reg_we         = |prio_apb_write_en[PRIO_SLV_NUM:0] | ip_apb_write_en;
                                  
//**********************************************************************
//   claim and complete from hreg
//   
//**********************************************************************
//generate
//genvar claim_idx;
//  for(claim_idx=0;claim_idx<INT_NUM;claim_idx=claim_idx+1)
//  begin:CLAIM_CMPLT
//    assign hreg_int_claim_kid[claim_idx] = hreg_kid_claim_vld 
//                                           & (hreg_kid_claim_id[ID_NUM-1:0] == claim_idx);
////    assign hreg_int_complete_kid[claim_idx] = hreg_kid_cmplt_vld 
////                                           & (hreg_kid_cmplt_id[ID_NUM-1:0] == claim_idx);
//  end
//endgenerate
assign hreg_int_claim_kid[INT_NUM-1:0]  = hreg_kid_claim_vld[INT_NUM-1:0];
//**********************************************************************
//   interface to arbitor
//   
//**********************************************************************
assign kid_yy_int_req[INT_NUM-1:0]           = kid_arb_int_req[INT_NUM-1:0];
assign kid_yy_int_prio[INT_NUM*PRIO_BIT-1:0] = {kid_arb_int_prio[INT_NUM*PRIO_BIT-1:PRIO_BIT],
                                                {PRIO_BIT{1'b0}}};

endmodule

// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : pic_plic_nor_sel.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-1
// FUNCTION        : pic_plic_nor_sel for pic_plic_32to1_stage1
//                    
// ******************************************************************************
module pic_plic_nor_sel(
  //input
  data_in,
  sel_in,
  //out
  data_out
);
parameter    SEL_BIT  = 5;
parameter    SEL_NUM  = 32;
parameter    DATA     = 10;

input   [SEL_NUM*DATA-1:0]        data_in;
input   [SEL_BIT-1:0]                 sel_in;

output  [DATA-1:0]                data_out;


//wire definition
wire [SEL_NUM-1:0]          sel_onehot;
wire [(SEL_NUM+1)*DATA-1:0] tmp_sel_out; 
//reg definition


assign tmp_sel_out[DATA-1:0]  = {DATA{1'b0}};

genvar i;
generate
for(i=0;i<SEL_NUM;i=i+1)
begin: SEL_OUT
  assign sel_onehot[i]                 = sel_in[SEL_BIT-1:0] == ($unsigned(i) & {SEL_BIT{1'b1}});
  assign tmp_sel_out[(i+1)*DATA+:DATA] = ({DATA{sel_onehot[i]}} & data_in[DATA*i+:DATA])
                                        | tmp_sel_out[DATA*i+:DATA];
end
endgenerate
assign data_out[DATA-1:0]             = tmp_sel_out[DATA*SEL_NUM+:DATA];

endmodule
// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : pic_plic_prio_sel.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-1
// FUNCTION        :  pic_plic_prio_sel for pic_plic_prio_sel
// ******************************************************************************
module pic_plic_prio_sel(
  //input
  data_in,
  sel_in,
  //out
  data_out,
  pos_out
);
parameter DATA    = 4;
parameter SEL     = 32;
parameter SEL_BIT = 5;

input   [DATA*SEL-1:0]  data_in;
input   [SEL-1:0]       sel_in;

output  [DATA-1:0]      data_out;
output  [SEL_BIT-1:0]   pos_out;

//wire definition

wire    [SEL-1:0]             tmp_sel; 
wire    [SEL:0]               tmp_sel2; 
wire    [SEL-1:0]             onehot_sel;
wire    [(SEL+1)*DATA-1:0]    tmp_out;
wire    [(SEL+1)*SEL_BIT-1:0] tmp_pos_out;
wire    [SEL:0]               sel_in_exp;

//**************************************
//  make the select to all ones
//  01100   -> 01111
//**************************************
assign sel_in_exp[SEL:0]  = {1'b0,sel_in[SEL-1:0]};
genvar k;
generate 
  for(k=0;k<SEL;k=k+1)
  begin:ALL_ONE_SEL
  assign tmp_sel[k] = |sel_in_exp[SEL:k];
  end
endgenerate
//**************************************
//  make the select to  one hot
//  01111   -> 01000
//**************************************

assign tmp_sel2[SEL:0] = {1'b0,tmp_sel[SEL-1:0]};
genvar m;
generate 
  for(m=0;m<SEL;m=m+1)
  begin:ONE_HOT_SEL
  assign onehot_sel[m] = tmp_sel[m] & ~tmp_sel2[m+1];
  end
endgenerate
assign tmp_out[DATA-1:0] = {DATA{1'b0}};
assign tmp_pos_out[SEL_BIT-1:0] = {SEL_BIT{1'b0}};
genvar n;
generate 
  for(n=0;n<SEL;n=n+1)
  begin:OUT_SEL
  assign tmp_out[(n+1)*DATA+:DATA] = ({DATA{onehot_sel[n]}} & data_in[n*DATA+:DATA])
                                    | tmp_out[n*DATA+:DATA];
  assign tmp_pos_out[(n+1)*SEL_BIT+:SEL_BIT] = ({SEL_BIT{onehot_sel[n]}} & ($unsigned(n) & {SEL_BIT{1'b1}}))
                                                | tmp_pos_out[n*SEL_BIT+:SEL_BIT];  
  end
endgenerate

assign data_out[DATA-1:0]   = tmp_out[(SEL+1)*DATA-1:SEL*DATA];
assign pos_out[SEL_BIT-1:0] = tmp_pos_out[(SEL+1)*SEL_BIT-1:SEL*SEL_BIT];
endmodule
// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : pic_plic_top.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-1
// FUNCTION        : PLIC top 
//                   1. including a apb matrix, 1to4
//                   2. parameterize the Interrupt number: 32-1024, 32 step
// ******************************************************************************

module pic_plic_top(
  plic_hartx_mint_req,
  plic_hartx_sint_req,
  ciu_plic_paddr,
  ciu_plic_penable,
  ciu_plic_psel,
  ciu_plic_pprot,
  ciu_plic_pwdata,
  ciu_plic_pwrite,
  `ifdef PIC_PLIC_SEC
  ciu_plic_psec,
  ciu_plic_core_sec,
  `endif
  ciu_plic_icg_en,
  pad_plic_int_vld,
  pad_plic_int_cfg,
  pad_yy_icg_scan_en,

  plic_ciu_prdata,
  plic_ciu_pready,
  plic_ciu_pslverr,
  plic_clk,
  plicrst_b
`ifdef PIC_TEE_EXTENSION
  ,
  clint_plic_reg_par_disable,
  plic_pad_reg_parity_error
`endif
);
parameter   CLUSTER_NUM           = 16;
parameter   HART_NUM_PER_CLUSTER = 16;
parameter   HART_EXIST           = 256'hffff;
parameter   INT_NUM              = 1024;
parameter   ID_NUM               = 10;
parameter   PRIO_BIT             = 5;

parameter   HART_NUM             = CLUSTER_NUM*HART_NUM_PER_CLUSTER;
parameter   CORE_ID              = 2;
//parameter   CORE_ONE_HOT = 4;
`ifdef PIC_PLIC_SEC
parameter   SLV_NUM      = 6;
`else
parameter   SLV_NUM      = 5;
`endif

input   [26  :0]                ciu_plic_paddr;           
input                           ciu_plic_penable;         
input                           ciu_plic_psel;            
input   [1:0]                   ciu_plic_pprot;            
input   [31  :0]                ciu_plic_pwdata;          
input                           ciu_plic_pwrite;    
`ifdef PIC_PLIC_SEC
input  [7:0]                    ciu_plic_psec;
input  [HART_NUM*8-1:0]         ciu_plic_core_sec;
`endif
input   [INT_NUM-1:0]           pad_plic_int_vld;         
input   [INT_NUM-1:0]           pad_plic_int_cfg;         
input                           plic_clk;                 
input                           plicrst_b;                
input                           pad_yy_icg_scan_en;
input                           ciu_plic_icg_en;
`ifdef PIC_TEE_EXTENSION
input                           clint_plic_reg_par_disable;
output                          plic_pad_reg_parity_error;
`endif

output  [HART_NUM-1:0]          plic_hartx_mint_req;      
output  [HART_NUM-1:0]          plic_hartx_sint_req;      
output  [31  :0]                plic_ciu_prdata;          
output                          plic_ciu_pready;          
output                          plic_ciu_pslverr;         

wire                              ciu_plic_icg_en;
wire    [HART_NUM-1:0]            plic_hartx_mint_req;      
wire    [HART_NUM-1:0]            plic_hartx_sint_req;      
wire    [HART_NUM-1   :0]         arbx_hreg_arb_start_ack;  
wire    [HART_NUM*ID_NUM-1  :0]   arbx_hreg_claim_id;       
wire    [HART_NUM-1   :0]         arbx_hreg_claim_mmode;    
wire    [HART_NUM-1   :0]         arbx_hreg_claim_reg_ready; 
wire    [25  :0]                  bus_mtx_ict_paddr;        
wire                              bus_mtx_ict_penable;      
wire                              bus_mtx_ict_psel;         
wire    [1:0]                     bus_mtx_ict_pprot;
wire    [31  :0]                  bus_mtx_ict_pwdata;       
wire                              bus_mtx_ict_pwrite; 
wire    [20  :0]                  bus_mtx_ie_paddr;         
wire                              bus_mtx_ie_penable;       
wire                              bus_mtx_ie_psel;     
wire    [1:0]                     bus_mtx_ie_pprot;
wire    [31  :0]                  bus_mtx_ie_pwdata;        
wire                              bus_mtx_ie_pwrite;        
wire    [11  :0]                  bus_mtx_ip_paddr;         
wire                              bus_mtx_ip_penable;       
wire                              bus_mtx_ip_psel;          
wire    [1:0]                     bus_mtx_ip_pprot;
wire    [31  :0]                  bus_mtx_ip_pwdata;        
wire                              bus_mtx_ip_pwrite;        
wire    [11  :0]                  bus_mtx_prio_paddr;       
wire                              bus_mtx_prio_penable;     
wire                              bus_mtx_prio_psel;        
wire    [1:0]                     bus_mtx_prio_pprot;
wire    [31  :0]                  bus_mtx_prio_pwdata;      
wire                              bus_mtx_prio_pwrite;      
wire    [26  :0]                  ciu_plic_paddr;           
wire                              ciu_plic_penable;         
wire                              ciu_plic_psel;            
wire    [31  :0]                  ciu_plic_pwdata;          
wire                              ciu_plic_pwrite;          
wire    [HART_NUM-1   :0]         hreg_arbx_arb_flush;      
wire    [HART_NUM-1   :0]         hreg_arbx_arb_start;      
wire    [HART_NUM-1   :0]         hreg_arbx_mint_claim;      
wire    [HART_NUM-1   :0]         hreg_arbx_sint_claim;      
wire    [INT_NUM*HART_NUM-1:0]    hreg_arbx_int_en;         
wire    [INT_NUM*HART_NUM-1:0]    hreg_arbx_int_mmode;      
wire    [HART_NUM*PRIO_BIT-1:0]   hreg_arbx_prio_mth;       
wire    [HART_NUM*PRIO_BIT-1:0]   hreg_arbx_prio_sth;       
//wire    [ID_NUM-1   :0]           hreg_kid_claim_id;        
wire    [INT_NUM-1:0]             hreg_kid_claim_vld;       
wire    [INT_NUM-1:0]             hreg_kid_cmplt_vld;       
wire    [31  :0]                  ict_bus_mtx_prdata;       
wire                              ict_bus_mtx_pready;       
wire                              ict_bus_mtx_pslverr;      
wire    [31  :0]                  ie_bus_mtx_prdata;        
wire                              ie_bus_mtx_pready;        
wire                              ie_bus_mtx_pslverr;       
wire    [31  :0]                  ip_bus_mtx_prdata;        
wire                              ip_bus_mtx_pready;        
wire                              ip_bus_mtx_pslverr;       
wire                              kid_hreg_new_int_pulse;   
wire    [INT_NUM*PRIO_BIT-1:0]    kid_yy_int_prio;          
wire    [INT_NUM-1:0]             kid_yy_int_req;           
wire    [SLV_NUM*27-1 :0]         mst_base_addr;            
wire    [SLV_NUM*27-1 :0]         mst_base_addr_msk;
wire    [SLV_NUM-1    :0]         other_slv_sel;
wire                              ie_addr_sel;
wire                              ict_addr_sel;
wire    [SLV_NUM*27-1 :0]         mst_paddr;                
wire    [SLV_NUM-1   :0]          mst_penable;              
wire    [SLV_NUM*32-1 :0]         mst_prdata;               
wire    [SLV_NUM-1   :0]          mst_pready;               
wire    [SLV_NUM-1   :0]          mst_psel;                 
wire    [SLV_NUM*2-1   :0]        mst_pprot;
wire    [SLV_NUM-1   :0]          mst_pslverr;              
wire    [SLV_NUM*32-1 :0]         mst_pwdata;               
wire    [SLV_NUM-1   :0]          mst_pwrite;               
wire    [INT_NUM-1:0]             pad_plic_int_vld;         
wire    [31  :0]                  plic_ciu_prdata;          
wire                              plic_ciu_pready;          
wire                              plic_ciu_pslverr;         
wire                              plic_clk;                 
wire                              plicrst_b;                
wire    [31  :0]                  prio_bus_mtx_prdata;      
wire                              prio_bus_mtx_pready;      
wire                              prio_bus_mtx_pslverr;     
wire                              kid_hreg_ip_prio_reg_we;
wire                              bus_mtx_plic_ctrl_psel;
wire                              bus_mtx_plic_ctrl_penable;
wire      [1:0]                   bus_mtx_plic_ctrl_pprot;
wire     [11:0]                   bus_mtx_plic_ctrl_paddr;
wire     [31:0]                   bus_mtx_plic_ctrl_pwdata;
wire                              bus_mtx_plic_ctrl_pwrite;
wire    [31:0]                    plic_ctrl_prdata;
wire                              plic_ctrl_pslverr;
wire                              plic_ctrl_pready;
wire                              ctrl_xx_s_permission_t;
wire                              ctrl_xx_s_permission_nt;
wire                              ctrl_xx_amp_mode;
  
wire                              bus_mtx_ict_psec;
wire                              bus_mtx_prio_psec;
wire                              bus_mtx_ip_psec;
wire                              bus_mtx_ie_psec;
`ifdef PIC_PLIC_SEC
wire    [11  :0]                  bus_mtx_sec_paddr;         
wire                              bus_mtx_sec_penable;       
wire                              bus_mtx_sec_psel;          
wire    [1:0]                     bus_mtx_sec_pprot;
wire    [31  :0]                  bus_mtx_sec_pwdata;        
wire                              bus_mtx_sec_pwrite;
wire                              bus_mtx_sec_psec;
wire    [31  :0]                  sec_bus_mtx_prdata;        
wire                              sec_bus_mtx_pready;        
wire                              sec_bus_mtx_pslverr;  
wire                              plic_core_sec_clk;
wire                              plic_core_sec_clk_en;
wire                              core_sec_chg_en;
reg     [HART_NUM-1:0]            ctrl_xx_core_sec;
wire    [HART_NUM-1:0]            ciu_plic_core_sec_bin;
wire    [HART_NUM:0]              core_sec_clk_chg;
wire    [HART_NUM:0]              core_sec_chg;
`else
wire     [HART_NUM-1:0]            ctrl_xx_core_sec;

`endif
wire    [INT_NUM-1:0]             int_sec_infor;
wire    [SLV_NUM-1:0]             mst_psec;
wire                              ciu_plic_psec_in;
wire                              ctrl_xx_amp_lock;
wire                              bus_mtx_plic_ctrl_psec;
`ifdef PIC_TEE_EXTENSION
wire                              clint_plic_reg_par_disable;
wire                              plic_pad_reg_parity_error;
`endif
//assign   ciu_plic_icg_en   = 1'b0;
pic_plic_apb_1tox_matrix   #(.ADDR(27),
                         .SLAVE(SLV_NUM))
                         x_apb_1tox_matrix (
  .mst_base_addr     (mst_base_addr    ),
  .mst_base_addr_msk (mst_base_addr_msk),
  .other_slv_sel     (other_slv_sel    ),
  .mst_paddr         (mst_paddr        ),
  .mst_penable       (mst_penable      ),
  .mst_prdata        (mst_prdata       ),
  .mst_pready        (mst_pready       ),
  .mst_psel          (mst_psel         ),
  .mst_pprot         (mst_pprot         ),
  .mst_pslverr       (mst_pslverr      ),
  .mst_pwdata        (mst_pwdata       ),
  .mst_pwrite        (mst_pwrite       ),
  .mst_psec          (mst_psec         ),
  .ciu_plic_icg_en   (ciu_plic_icg_en  ),
  .pad_yy_icg_scan_en(pad_yy_icg_scan_en),
  .pclk              (plic_clk         ),
  .prst_b            (plicrst_b        ),
  .slv_paddr         (ciu_plic_paddr   ),
  .slv_penable       (ciu_plic_penable ),
  .slv_prdata        (plic_ciu_prdata  ),
  .slv_pready        (plic_ciu_pready  ),
  .slv_psel          (ciu_plic_psel    ),
  .slv_pprot         (ciu_plic_pprot    ),
  .slv_pslverr       (plic_ciu_pslverr ),
  .slv_pwdata        (ciu_plic_pwdata  ),
  .slv_pwrite        (ciu_plic_pwrite  ),
  .slv_psec          (ciu_plic_psec_in    )
);



`ifdef PIC_PLIC_SEC

assign ciu_plic_psec_in = (ciu_plic_psec[7:0] == `TEE_VALID_VALUE) | ~ctrl_xx_amp_mode;
assign {bus_mtx_prio_psel,
        bus_mtx_ip_psel,
        bus_mtx_ie_psel,
        bus_mtx_sec_psel,
        bus_mtx_plic_ctrl_psel,
        bus_mtx_ict_psel}           = mst_psel[5:0];

assign  bus_mtx_plic_ctrl_pprot[1:0]= mst_pprot[3:2];
assign  bus_mtx_prio_pprot[1:0] = {mst_pprot[11] | ((mst_psec[5] ? ctrl_xx_s_permission_t : ctrl_xx_s_permission_nt) & mst_pprot[10]),
                                   mst_pprot[10]};
assign  bus_mtx_ip_pprot[1:0]   = {mst_pprot[9] | ((mst_psec[4] ? ctrl_xx_s_permission_t : ctrl_xx_s_permission_nt)& mst_pprot[8]),
                                   mst_pprot[8]};
assign  bus_mtx_ie_pprot[1:0]   = {mst_pprot[7] | ((mst_psec[3] ? ctrl_xx_s_permission_t : ctrl_xx_s_permission_nt)& mst_pprot[6]),
                                   mst_pprot[6]};  
assign  bus_mtx_sec_pprot[1:0]  = mst_pprot[5:4];
assign  bus_mtx_ict_pprot[1:0]  = {mst_pprot[1] | ((mst_psec[0] ? ctrl_xx_s_permission_t : ctrl_xx_s_permission_nt)& mst_pprot[0]),
                                   mst_pprot[0]};  
assign {bus_mtx_prio_penable,
        bus_mtx_ip_penable,
        bus_mtx_ie_penable,
        bus_mtx_sec_penable,
        bus_mtx_plic_ctrl_penable,
        bus_mtx_ict_penable}        = mst_penable[5:0];
assign {bus_mtx_prio_pwrite,
        bus_mtx_ip_pwrite,
        bus_mtx_ie_pwrite,
        bus_mtx_sec_pwrite,
        bus_mtx_plic_ctrl_pwrite,
        bus_mtx_ict_pwrite}         = mst_pwrite[5:0];
assign {bus_mtx_prio_pwdata[31:0],
        bus_mtx_ip_pwdata[31:0],
        bus_mtx_ie_pwdata[31:0],
        bus_mtx_sec_pwdata[31:0],
        bus_mtx_plic_ctrl_pwdata[31:0],
        bus_mtx_ict_pwdata[31:0]}   = mst_pwdata[191:0];
assign  bus_mtx_prio_paddr[11:0]    = mst_paddr[146:135];
assign  bus_mtx_ip_paddr[11:0]      = mst_paddr[119:108];
assign  bus_mtx_ie_paddr[20:0]      = mst_paddr[101:81];
assign  bus_mtx_sec_paddr[11:0]     = mst_paddr[65:54];
assign  bus_mtx_plic_ctrl_paddr[11:0]  = mst_paddr[38:27];
assign  bus_mtx_ict_paddr[25:0]     = mst_paddr[25:0];
assign  mst_prdata[191:0]           = { prio_bus_mtx_prdata[31:0],
                                        ip_bus_mtx_prdata[31:0],
                                        ie_bus_mtx_prdata[31:0],
                                        sec_bus_mtx_prdata[31:0],
                                        plic_ctrl_prdata[31:0],
                                        ict_bus_mtx_prdata[31:0]};
assign  mst_pready[5:0]             = { prio_bus_mtx_pready,
                                        ip_bus_mtx_pready,
                                        ie_bus_mtx_pready,
                                        sec_bus_mtx_pready,
                                        plic_ctrl_pready,
                                        ict_bus_mtx_pready};
assign  mst_pslverr[5:0]            = { prio_bus_mtx_pslverr,
                                        ip_bus_mtx_pslverr,
                                        ie_bus_mtx_pslverr,
                                        sec_bus_mtx_pslverr,
                                        plic_ctrl_pslverr,
                                        ict_bus_mtx_pslverr};
assign mst_base_addr[161:0]         = { 27'b0, // priority
                                        27'h0001000, // ip
                                        27'h0002000, // ie
                                        27'h01fe000, // sec
                                        27'h01ff000, // plic privilege ease(enable smode access)
                                        27'h0200000  // ict
                                        };
assign mst_base_addr_msk[161:0]     = { 27'h7fff000, // priority
                                        27'h7fff000, // ip
                                        27'h7fff000, // ie
                                        27'h7fff000, // sec
                                        27'h7fff000, // plic privilege ease(enable smode access)
                                        27'h7fc0000  //ict
                                        };
assign {bus_mtx_prio_psec,
        bus_mtx_ip_psec,
        bus_mtx_ie_psec,
        bus_mtx_sec_psec,
        bus_mtx_plic_ctrl_psec,
        bus_mtx_ict_psec}           = mst_psec[5:0];
pic_plic_sec_busif #(.INT_NUM(INT_NUM),
                      .ADDR(12)
                      ) x_pic_plic_sec_busif(
  .plic_clk            (plic_clk             ),
  .plicrst_b           (plicrst_b            ),
  .bus_mtx_sec_psel    (bus_mtx_sec_psel     ),
  .bus_mtx_sec_pprot   (bus_mtx_sec_pprot    ),
  .bus_mtx_sec_penable (bus_mtx_sec_penable  ),
  .bus_mtx_sec_paddr   (bus_mtx_sec_paddr    ),
  .bus_mtx_sec_pwrite  (bus_mtx_sec_pwrite   ),
  .bus_mtx_sec_pwdata  (bus_mtx_sec_pwdata   ),
  .bus_mtx_sec_psec    (bus_mtx_sec_psec     ),
  .ciu_plic_icg_en     (ciu_plic_icg_en      ),
  .pad_yy_icg_scan_en  (pad_yy_icg_scan_en   ),
  .ctrl_xx_amp_mode    (ctrl_xx_amp_mode     ),
  .ctrl_xx_amp_lock    (ctrl_xx_amp_lock     ),
  //output
  .sec_bus_mtx_pready  (sec_bus_mtx_pready   ),
  .sec_bus_mtx_prdata  (sec_bus_mtx_prdata   ),
  .sec_bus_mtx_pslverr (sec_bus_mtx_pslverr  ),
  .int_sec_infor       (int_sec_infor        )         
);
 
genvar j;
generate
for(j=0;j<HART_NUM;j=j+1)
begin: HART_SEC
assign ciu_plic_core_sec_bin[j] = ciu_plic_core_sec[j*8+:8] == `TEE_VALID_VALUE;
end
endgenerate

always @(posedge plic_core_sec_clk or negedge plicrst_b)
begin
    if(~plicrst_b)
        ctrl_xx_core_sec[HART_NUM-1:0] <= {HART_NUM{1'b0}};
    else if(core_sec_chg_en)
        ctrl_xx_core_sec[HART_NUM-1:0] <= ciu_plic_core_sec_bin[HART_NUM-1:0];
end
assign core_sec_chg[HART_NUM:0]  = {1'b0,ciu_plic_core_sec_bin[HART_NUM-1:0] ^ ctrl_xx_core_sec[HART_NUM-1:0]};
assign core_sec_chg_en  = |core_sec_chg[HART_NUM:0];  
pic_gated_clk_cell  x_core_sec_gateclk (
  .clk_in               (plic_clk            ),
  .clk_out              (plic_core_sec_clk   ),
  .external_en          (1'b0                ),
  .local_en             (plic_core_sec_clk_en),
  .module_en            (ciu_plic_icg_en     ),
  .pad_yy_icg_scan_en   (pad_yy_icg_scan_en  )
);
assign core_sec_clk_chg[HART_NUM:0]      = {1'b0,ctrl_xx_core_sec[HART_NUM-1:0] ^ ciu_plic_core_sec_bin[HART_NUM-1:0]};
assign plic_core_sec_clk_en              = |core_sec_clk_chg[HART_NUM:0];
`else
assign ciu_plic_psec_in   = 1'b1;
assign ctrl_xx_core_sec[HART_NUM-1:0] = {HART_NUM{1'b1}};
assign {bus_mtx_prio_psel,
        bus_mtx_ip_psel,
        bus_mtx_ie_psel,
        bus_mtx_plic_ctrl_psel,
        bus_mtx_ict_psel}           = mst_psel[4:0];

assign  bus_mtx_plic_ctrl_pprot[1:0]= mst_pprot[3:2];
assign  bus_mtx_prio_pprot[1:0] = {mst_pprot[9] | ((mst_psec[4] ? ctrl_xx_s_permission_t : ctrl_xx_s_permission_nt) & mst_pprot[8]),
                                   mst_pprot[8]};
assign  bus_mtx_ip_pprot[1:0]   = {mst_pprot[7] | ((mst_psec[3] ? ctrl_xx_s_permission_t : ctrl_xx_s_permission_nt) & mst_pprot[6]),
                                   mst_pprot[6]};
assign  bus_mtx_ie_pprot[1:0]   = {mst_pprot[5] | ((mst_psec[2] ? ctrl_xx_s_permission_t : ctrl_xx_s_permission_nt) & mst_pprot[4]),
                                   mst_pprot[4]};                                
assign  bus_mtx_ict_pprot[1:0]  = {mst_pprot[1] | ((mst_psec[1] ? ctrl_xx_s_permission_t : ctrl_xx_s_permission_nt) & mst_pprot[0]),
                                   mst_pprot[0]};                                
assign {bus_mtx_prio_penable,
        bus_mtx_ip_penable,
        bus_mtx_ie_penable,
        bus_mtx_plic_ctrl_penable,
        bus_mtx_ict_penable}        = mst_penable[4:0];
assign {bus_mtx_prio_pwrite,
        bus_mtx_ip_pwrite,
        bus_mtx_ie_pwrite,
        bus_mtx_plic_ctrl_pwrite,
        bus_mtx_ict_pwrite}         = mst_pwrite[4:0];
assign {bus_mtx_prio_pwdata[31:0],
        bus_mtx_ip_pwdata[31:0],
        bus_mtx_ie_pwdata[31:0],
        bus_mtx_plic_ctrl_pwdata[31:0],
        bus_mtx_ict_pwdata[31:0]}   = mst_pwdata[159:0];
assign  bus_mtx_prio_paddr[11:0]    = mst_paddr[119:108];
assign  bus_mtx_ip_paddr[11:0]      = mst_paddr[92:81];
assign  bus_mtx_ie_paddr[20:0]      = mst_paddr[74:54];
assign  bus_mtx_plic_ctrl_paddr[11:0]  = mst_paddr[38:27];
assign  bus_mtx_ict_paddr[25:0]     = mst_paddr[25:0];
assign  mst_prdata[159:0]           = { prio_bus_mtx_prdata[31:0],
                                        ip_bus_mtx_prdata[31:0],
                                        ie_bus_mtx_prdata[31:0],
                                        plic_ctrl_prdata[31:0],
                                        ict_bus_mtx_prdata[31:0]};
assign  mst_pready[4:0]             = { prio_bus_mtx_pready,
                                        ip_bus_mtx_pready,
                                        ie_bus_mtx_pready,
                                        plic_ctrl_pready,
                                        ict_bus_mtx_pready};
assign  mst_pslverr[4:0]            = { prio_bus_mtx_pslverr,
                                        ip_bus_mtx_pslverr,
                                        ie_bus_mtx_pslverr,
                                        plic_ctrl_pslverr,
                                        ict_bus_mtx_pslverr};
assign mst_base_addr[134:0]         = { {27{1'b0}}, // priority
                                        27'h0001000, // ip
                                        27'h0002000, // ie
                                        27'h01ff000, // plic privilege ease(enable smode access)
                                        27'h0200000  // ict
                                        };
assign mst_base_addr_msk[134:0]     = { 27'h7fff000, // priority
                                        27'h7fff000, // ip
                                        27'h7ffc000, // ie
                                        27'h7fff000, // plic privilege ease(enable smode access)
                                        27'h7fc0000  //ict
                                        };

assign ie_addr_sel  = ~(|ciu_plic_paddr[26:21]) & (|ciu_plic_paddr[20:13]) & ~(&ciu_plic_paddr[20:13]); 
       //high bits of ie addr.  27'h0002000 ~ 27'h01ffff8, here we use 27'h0002??? ~ 27'01fc???
assign ict_addr_sel = ~ciu_plic_paddr[26] & (|ciu_plic_paddr[25:21]) & ~(&ciu_plic_paddr[25:21]);
       //high bits of ict addr. 27'h0200000 ~ 27'h3fffffc, here we use 27'h02????? ~ 27'h3c?????

assign other_slv_sel[4:0]           = { 1'b0, //priority
                                        1'b0, //ip
                                        ie_addr_sel, //ie
                                        1'b0, //plic privilege ease(enable smode access)
                                        ict_addr_sel //ict
                                        };
assign {bus_mtx_prio_psec,
        bus_mtx_ip_psec,
        bus_mtx_ie_psec,
        bus_mtx_plic_ctrl_psec,
        bus_mtx_ict_psec}           = mst_psec[4:0];
assign int_sec_infor[INT_NUM-1:0]   = {INT_NUM{1'b1}};
`endif
pic_plic_ctrl    x_pic_plic_ctrl (
  .bus_mtx_plic_ctrl_psel(bus_mtx_plic_ctrl_psel),
  .bus_mtx_plic_ctrl_paddr(bus_mtx_plic_ctrl_paddr),
  .bus_mtx_plic_ctrl_penable(bus_mtx_plic_ctrl_penable),
  .bus_mtx_plic_ctrl_pprot(bus_mtx_plic_ctrl_pprot),
  .bus_mtx_plic_ctrl_pwdata(bus_mtx_plic_ctrl_pwdata),
  .bus_mtx_plic_ctrl_pwrite(bus_mtx_plic_ctrl_pwrite),
  .bus_mtx_plic_ctrl_psec(bus_mtx_plic_ctrl_psec),
  .ciu_plic_icg_en   (ciu_plic_icg_en  ),
  .pad_yy_icg_scan_en(pad_yy_icg_scan_en),
  .plic_ctrl_prdata(plic_ctrl_prdata),
  .plic_ctrl_pslverr(plic_ctrl_pslverr),
  .plic_ctrl_pready(plic_ctrl_pready),
  .plic_clk(plic_clk),
  .plicrst_b(plicrst_b),
  .ctrl_xx_s_permission_t(ctrl_xx_s_permission_t),
  .ctrl_xx_s_permission_nt(ctrl_xx_s_permission_nt),
  .ctrl_xx_amp_mode(ctrl_xx_amp_mode),
  .ctrl_xx_amp_lock(ctrl_xx_amp_lock)
`ifdef PIC_TEE_EXTENSION
  ,
  .reg_parity_disable(clint_plic_reg_par_disable),
  .plic_pad_reg_parity_error(plic_pad_reg_parity_error)
`endif
);
pic_plic_hreg_busif  #(.INT_NUM(INT_NUM),
                      .ID_NUM(ID_NUM),
                      .HART_NUM(HART_NUM),
                      .HART_EXIST(HART_EXIST),
                      .PRIO_BIT(PRIO_BIT),
                      .IE_ADDR(21),
                      .ICT_ADDR(26)
                      )x_pic_plic_hreg_busif (
  .arbx_hreg_arb_start_ack   (arbx_hreg_arb_start_ack  ),
  .arbx_hreg_claim_id        (arbx_hreg_claim_id       ),
  .arbx_hreg_claim_mmode     (arbx_hreg_claim_mmode    ),
  .arbx_hreg_claim_reg_ready (arbx_hreg_claim_reg_ready),
  .bus_mtx_ict_paddr         (bus_mtx_ict_paddr[25:0]  ),
  .bus_mtx_ict_penable       (bus_mtx_ict_penable      ),
  .bus_mtx_ict_psel          (bus_mtx_ict_psel         ),
  .bus_mtx_ict_pprot         (bus_mtx_ict_pprot        ),
  .bus_mtx_ict_pwdata        (bus_mtx_ict_pwdata       ),
  .bus_mtx_ict_pwrite        (bus_mtx_ict_pwrite       ),
  .bus_mtx_ict_psec          (bus_mtx_ict_psec         ),
  .bus_mtx_ie_paddr          (bus_mtx_ie_paddr[20:0]   ),
  .bus_mtx_ie_penable        (bus_mtx_ie_penable       ),
  .bus_mtx_ie_psel           (bus_mtx_ie_psel          ),
  .bus_mtx_ie_pprot          (bus_mtx_ie_pprot         ),
  .bus_mtx_ie_pwdata         (bus_mtx_ie_pwdata        ),
  .bus_mtx_ie_pwrite         (bus_mtx_ie_pwrite        ),
  .bus_mtx_ie_psec           (bus_mtx_ie_psec          ),
  .kid_hreg_ip_prio_reg_we   (kid_hreg_ip_prio_reg_we  ),
  .ciu_plic_icg_en           (ciu_plic_icg_en          ),
  .pad_yy_icg_scan_en        (pad_yy_icg_scan_en       ),
  .hreg_arbx_arb_flush       (hreg_arbx_arb_flush      ),
  .hreg_arbx_arb_start       (hreg_arbx_arb_start      ),
  .hreg_arbx_mint_claim      (hreg_arbx_mint_claim      ),
  .hreg_arbx_sint_claim      (hreg_arbx_sint_claim      ),
  .hreg_arbx_int_en          (hreg_arbx_int_en         ),
  .hreg_arbx_int_mmode       (hreg_arbx_int_mmode      ),
  .hreg_arbx_prio_mth        (hreg_arbx_prio_mth       ),
  .hreg_arbx_prio_sth        (hreg_arbx_prio_sth       ),
//  .hreg_kid_claim_id         (hreg_kid_claim_id        ),
  .hreg_kid_claim_vld        (hreg_kid_claim_vld       ),
  .hreg_kid_cmplt_vld        (hreg_kid_cmplt_vld       ),
  .ctrl_xx_amp_mode          (ctrl_xx_amp_mode         ),
  .ctrl_xx_core_sec          (ctrl_xx_core_sec         ),
  .int_sec_infor             (int_sec_infor            ),
  .ict_bus_mtx_prdata        (ict_bus_mtx_prdata       ),
  .ict_bus_mtx_pready        (ict_bus_mtx_pready       ),
  .ict_bus_mtx_pslverr       (ict_bus_mtx_pslverr      ),

  .ie_bus_mtx_prdata         (ie_bus_mtx_prdata        ),
  .ie_bus_mtx_pready         (ie_bus_mtx_pready        ),
  .ie_bus_mtx_pslverr        (ie_bus_mtx_pslverr       ),
  .kid_hreg_new_int_pulse    (kid_hreg_new_int_pulse   ),
  .plic_clk                  (plic_clk                 ),
  .plicrst_b                 (plicrst_b                )
);

pic_plic_kid_busif  #(.INT_NUM(INT_NUM),
                      .ID_NUM(ID_NUM),
                      .PRIO_BIT(PRIO_BIT),
                      .ADDR(12)
                      )x_pic_plic_kid_busif (
  .bus_mtx_ip_paddr       (bus_mtx_ip_paddr[11:0]      ),
  .bus_mtx_ip_penable     (bus_mtx_ip_penable    ),
  .bus_mtx_ip_psel        (bus_mtx_ip_psel       ),
  .bus_mtx_ip_pprot       (bus_mtx_ip_pprot      ),
  .bus_mtx_ip_pwdata      (bus_mtx_ip_pwdata     ),
  .bus_mtx_ip_pwrite      (bus_mtx_ip_pwrite     ),
  .bus_mtx_ip_psec        (bus_mtx_ip_psec       ),
  .bus_mtx_prio_paddr     (bus_mtx_prio_paddr[11:0]    ),
  .bus_mtx_prio_penable   (bus_mtx_prio_penable  ),
  .bus_mtx_prio_psel      (bus_mtx_prio_psel     ),
  .bus_mtx_prio_pprot     (bus_mtx_prio_pprot    ),
  .bus_mtx_prio_pwdata    (bus_mtx_prio_pwdata   ),
  .bus_mtx_prio_pwrite    (bus_mtx_prio_pwrite   ),
  .bus_mtx_prio_psec      (bus_mtx_prio_psec     ),
  .ciu_plic_icg_en        (ciu_plic_icg_en       ),
  .pad_yy_icg_scan_en     (pad_yy_icg_scan_en    ),
//  .hreg_kid_claim_id      (hreg_kid_claim_id     ),
  .hreg_kid_claim_vld     (hreg_kid_claim_vld    ),
  .hreg_kid_cmplt_vld     (hreg_kid_cmplt_vld    ),
  .ip_bus_mtx_prdata      (ip_bus_mtx_prdata     ),
  .ip_bus_mtx_pready      (ip_bus_mtx_pready     ),
  .ip_bus_mtx_pslverr     (ip_bus_mtx_pslverr    ),
  .kid_hreg_new_int_pulse (kid_hreg_new_int_pulse),
  .kid_hreg_ip_prio_reg_we   (kid_hreg_ip_prio_reg_we  ),
  .kid_yy_int_prio        (kid_yy_int_prio       ),
  .kid_yy_int_req         (kid_yy_int_req        ),
  .int_sec_infor          (int_sec_infor         ),
  .ctrl_xx_amp_mode       (ctrl_xx_amp_mode      ),
  .pad_plic_int_vld       (pad_plic_int_vld      ),
  .pad_plic_int_cfg       (pad_plic_int_cfg      ),
  .plic_clk               (plic_clk              ),
  .plicrst_b              (plicrst_b             ),
  .prio_bus_mtx_prdata    (prio_bus_mtx_prdata   ),
  .prio_bus_mtx_pready    (prio_bus_mtx_pready   ),
  .prio_bus_mtx_pslverr   (prio_bus_mtx_pslverr  )
);
 
genvar i;
generate
for(i=0;i<HART_NUM;i=i+1)
begin:HART_ARB
if(HART_EXIST[i])
  begin: HART_ARB_TURE
  pic_plic_hart_arb  #(.INT_NUM(INT_NUM),
                      .ID_NUM(ID_NUM),
                      .PRIO_BIT(PRIO_BIT),
                      .ECH_RD(32)
                        )x_pic_plic_hart_arb (
    .arbx_hartx_mint_req       (plic_hartx_mint_req[i]      ),
    .arbx_hartx_sint_req       (plic_hartx_sint_req[i]      ),
    .arbx_hreg_arb_start_ack   (arbx_hreg_arb_start_ack[i]  ),
    .arbx_hreg_claim_id        (arbx_hreg_claim_id[i*ID_NUM+:ID_NUM] ),
    .arbx_hreg_claim_mmode     (arbx_hreg_claim_mmode[i]    ),
    .arbx_hreg_claim_reg_ready (arbx_hreg_claim_reg_ready[i]),
    .hreg_arbx_arb_flush       (hreg_arbx_arb_flush[i]      ),
    .hreg_arbx_arb_start       (hreg_arbx_arb_start[i]      ),
    .hreg_arbx_mint_claim      (hreg_arbx_mint_claim[i]      ),
    .hreg_arbx_sint_claim      (hreg_arbx_sint_claim[i]      ),
    .hreg_arbx_int_en          (hreg_arbx_int_en[i*INT_NUM+:INT_NUM]),
    .hreg_arbx_int_mmode       (hreg_arbx_int_mmode[i*INT_NUM+:INT_NUM]),
    .hreg_arbx_prio_mth        (hreg_arbx_prio_mth[i*PRIO_BIT+:PRIO_BIT]),
    .hreg_arbx_prio_sth        (hreg_arbx_prio_sth[i*PRIO_BIT+:PRIO_BIT]),
    .ciu_plic_icg_en           (ciu_plic_icg_en            ),
    .pad_yy_icg_scan_en        (pad_yy_icg_scan_en         ),
    .ctrl_xx_amp_mode          (ctrl_xx_amp_mode           ),
    .ctrl_xx_core_sec          (ctrl_xx_core_sec[i]        ),
    .kid_yy_int_prio           (kid_yy_int_prio          ),
    .kid_yy_int_req            (kid_yy_int_req           ),
    .int_sec_infor             (int_sec_infor            ), 
    .plic_clk                  (plic_clk                 ),
    .plicrst_b                 (plicrst_b                )
  );
  end
else //if this hart is not exist
  begin: HART_ARB_DUMMY
      //the output of pic_plic_hart_arb
      assign plic_hartx_mint_req[i]               = 1'b0;
      assign plic_hartx_sint_req[i]               = 1'b0;
      assign arbx_hreg_arb_start_ack[i]           = 1'b0;
      assign arbx_hreg_claim_id[i*ID_NUM+:ID_NUM] = {ID_NUM{1'b0}};
      assign arbx_hreg_claim_mmode[i]             = 1'b0;
      assign arbx_hreg_claim_reg_ready[i]         = 1'b0;
  end
end
endgenerate

`ifdef PIC_ASSERTION
//======================================================
// 
//                     plic assertion
// 
//======================================================
reg reset_finish;
reg reset_finish_f;

always @(negedge plicrst_b)
begin
    reset_finish <= 1;
end

always @(posedge plic_clk or negedge plicrst_b)
begin
  if(!plicrst_b)
    reset_finish_f <= 0;
  else
    reset_finish_f <= reset_finish;
end
//======================================================
// mint req/sint req after arbter require:
// prio !=0 & int_id !=0 & int_prio > thes
//======================================================
wire [HART_NUM-1:0] mint_req;
wire [HART_NUM-1:0] sint_req;
wire [PRIO_BIT-1:0] int_prio[HART_NUM-1:0];
wire [ID_NUM-1:0]   int_id[HART_NUM-1:0];
wire [4:0]          mthres[HART_NUM-1:0];
wire [4:0]          sthres[HART_NUM-1:0];

generate
for(i=0;i<HART_NUM;i=i+1)
begin:INT_REQ_ASSEERTION
if(HART_EXIST[i])
  begin: INT_REQ_ASSERION_TURE
    assign mint_req[i] = HART_ARB[i].HART_ARB_TURE.x_pic_plic_hart_arb.x_pic_plic_arb_ctrl.arbx_core_mint_req_en;
    assign sint_req[i] = HART_ARB[i].HART_ARB_TURE.x_pic_plic_hart_arb.x_pic_plic_arb_ctrl.arbx_core_sint_req_en;
    assign int_prio[i] = HART_ARB[i].HART_ARB_TURE.x_pic_plic_hart_arb.x_pic_plic_arb_ctrl.arb_ctrl_int_prio[PRIO_BIT-1:0];
    assign int_id[i]   = HART_ARB[i].HART_ARB_TURE.x_pic_plic_hart_arb.arbx_hreg_claim_id[ID_NUM-1:0];
    assign mthres[i]   = HART_ARB[i].HART_ARB_TURE.x_pic_plic_hart_arb.x_pic_plic_arb_ctrl.hreg_arbx_prio_mth[4:0];
    assign sthres[i]   = HART_ARB[i].HART_ARB_TURE.x_pic_plic_hart_arb.x_pic_plic_arb_ctrl.hreg_arbx_prio_sth[4:0];

    property mint_req_id;
      @(posedge  plic_clk)
        reset_finish_f & mint_req[i] |-> (int_prio[i] !=0 )&& (int_id[i] != 0) && (int_prio[i][4:0] > mthres[i]);
    endproperty
    assert property(mint_req_id);

    property sint_req_id;
      @(posedge  plic_clk)
        reset_finish_f & sint_req[i] |-> (int_prio[i] !=0 )&& (int_id[i] != 0) && (int_prio[i][4:0] > sthres[i]);
    endproperty
    assert property(sint_req_id);
  end
else
  begin: INT_REQ_ASSERION_DUMMY
    
  end
end
endgenerate

//======================================================
// mint/sint to core cannot set at same time
//======================================================
wire [HART_NUM-1:0] mint_req_out;
wire [HART_NUM-1:0] sint_req_out;

generate
for(i=0;i<HART_NUM;i=i+1)
begin:INT_REQ_OUT_ASSEERTION
if(HART_EXIST[i])
  begin: INT_REQ_OUT_ASSERION_TURE
    assign mint_req_out[i] = plic_hartx_mint_req;
    assign sint_req_out[i] = plic_hartx_sint_req;

    property int_req_same;
      @(posedge  plic_clk)
        reset_finish_f |-> !(mint_req_out[i] && sint_req_out[i]);
    endproperty
    assert property(int_req_same);
  end
else
  begin: INT_REQ_OUT_ASSERION_DUMMY
    
  end
end
endgenerate

//======================================================
// mint/sint to core cannot set at same time
//======================================================
wire [ID_NUM-1:0] mclaim_id[HART_NUM-1:0];
wire [ID_NUM-1:0] sclaim_id[HART_NUM-1:0];

generate
for(i=0;i<HART_NUM;i=i+1)
begin:CLAIM_ASSEERTION
if(HART_EXIST[i])
  begin: CLAIM_ASSERION_TURE
    assign mclaim_id[i] = x_pic_plic_hreg_busif.hart_mclaim_flop[i];
    assign sclaim_id[i] = x_pic_plic_hreg_busif.hart_sclaim_flop[i];

    property claim_same;
      @(posedge  plic_clk)
        reset_finish_f |-> !(mclaim_id[i] == sclaim_id[i]) || (mclaim_id[i] ==0);
    endproperty
    assert property(claim_same);
  end
else
  begin: CLAIM_ASSERION_DUMMY
    
  end
end
endgenerate

//======================================================
// mint/sint clear by mclaim/sclaim
//======================================================
wire [HART_NUM-1:0] mclaim;
wire [HART_NUM-1:0] mint;
wire [HART_NUM-1:0] sclaim;
wire [HART_NUM-1:0] sint;
wire [HART_NUM-1:0] int_update;

generate
for(i=0;i<HART_NUM;i=i+1)
begin:INT_CLEAR_BY_CLAIM_ASSEERTION
if(HART_EXIST[i])
  begin: INT_CLEAR_BY_CLAIM_ASSERION_TURE
    assign mclaim[i]     = x_pic_plic_hreg_busif.busif_hart_mclaim_rd_en[i];
    assign mint[i]       = HART_ARB[i].HART_ARB_TURE.x_pic_plic_hart_arb.arbx_hartx_mint_req;
    assign sclaim[i]     = x_pic_plic_hreg_busif.busif_hart_sclaim_rd_en[i];
    assign sint[i]       = HART_ARB[i].HART_ARB_TURE.x_pic_plic_hart_arb.arbx_hartx_sint_req;
    assign int_update[i] = HART_ARB[i].HART_ARB_TURE.x_pic_plic_hart_arb.x_pic_plic_arb_ctrl.int_out_update;

    property mint_clear_by_mclaim;
      @(posedge  plic_clk)
        (mclaim[i] && mint[i]) |=> (!mint[i]);
    endproperty
    assert property(mint_clear_by_mclaim);
   
    property sint_clear_by_sclaim;
      @(posedge  plic_clk)
        (sclaim[i] && sint[i]) |=> (!sint[i]);
    endproperty
    assert property(sint_clear_by_sclaim);
  end
else
  begin: INT_CLEAR_BY_CLAIM_ASSERION_DUMMY
    
  end
end
endgenerate

//======================================================
// mclaim/sclaim can clear right mint/sint
//======================================================
wire [HART_NUM-1:0] corex_id_ready;
wire [HART_NUM-1:0] corex_claim_clk;
wire [ID_NUM-1:0] corex_mclaim_id[HART_NUM-1:0];
wire [ID_NUM-1:0] corex_sclaim_id[HART_NUM-1:0];
reg  [9:0]        corex_id[HART_NUM-1:0];

wire [INT_NUM-1:0] hartx_mie_1d_bus[HART_NUM-1:0];
wire [INT_NUM-1:0] hartx_sie_1d_bus[HART_NUM-1:0];
wire [INT_NUM-1:0] corex_int_req[HART_NUM-1:0];

generate
for(i=0;i<HART_NUM;i=i+1)
begin:CLEAR_RIGHT_INT_ASSEERTION
if(HART_EXIST[i])
  begin: CLEAR_RIGHT_INT_ASSERION_TURE
    assign corex_id_ready[i]   = x_pic_plic_hreg_busif.arbx_hreg_claim_reg_ready[i];
    assign corex_claim_clk[i]  = x_pic_plic_hreg_busif.claim_clk[i];
    assign corex_mclaim_id[i]  = x_pic_plic_hreg_busif.hart_mclaim_flop[i];
    assign corex_sclaim_id[i]  = x_pic_plic_hreg_busif.hart_sclaim_flop[i];

    assign hartx_mie_1d_bus[i] = x_pic_plic_hreg_busif.hart_mie_1d_bus[i*INT_NUM+:INT_NUM];
    assign hartx_sie_1d_bus[i] = x_pic_plic_hreg_busif.hart_sie_1d_bus[i*INT_NUM+:INT_NUM];
    assign corex_int_req[i]    = HART_ARB[i].HART_ARB_TURE.x_pic_plic_hart_arb.kid_yy_int_req[INT_NUM-1:0];

    always@(posedge corex_id_ready[i])
      begin
        @(posedge corex_claim_clk[i]);
        #1 
        if ((corex_mclaim_id[i] | corex_sclaim_id[i])!=0)
          corex_id[i] = corex_mclaim_id[i] | corex_sclaim_id[i];
        end

    property corex_right_mint_clear;
      @(posedge  plic_clk)
        (mclaim[i] && mint[i] && hartx_mie_1d_bus[i][corex_id[i]]) |=> (corex_int_req[i][corex_id[i]] ==0);
    endproperty
    assert property(corex_right_mint_clear);

    property corex_right_sint_clear;
      @(posedge  plic_clk)
        (sclaim[i] && sint[i] && hartx_sie_1d_bus[i][corex_id[i]]) |=> (corex_int_req[i][corex_id[i]] ==0);
    endproperty
    assert property(corex_right_sint_clear);
  end
else
  begin: CLEAR_RIGHT_INT_ASSERION_DUMMY
    
  end
end
endgenerate

//======================================================
// mclaim/sclaim is not 0 when mint/sint is 1
//======================================================
generate
for(i=0;i<HART_NUM;i=i+1)
begin:CLAIM_INT_ASSEERTION
if(HART_EXIST[i])
  begin: CLAIM_INT_ASSERION_TURE
    assign corex_mclaim_id[i]  = x_pic_plic_hreg_busif.hart_mclaim_flop[i];
    assign corex_sclaim_id[i]  = x_pic_plic_hreg_busif.hart_sclaim_flop[i];

    property mclaim_have_value_when_mint_is_1;
      @(posedge  plic_clk)
        mint[i] |-> corex_mclaim_id[i] != 0;
    endproperty
    assert property(mclaim_have_value_when_mint_is_1);

    property sclaim_have_value_when_sint_is_1;
      @(posedge  plic_clk)
        sint[i] |-> corex_sclaim_id[i] != 0;
    endproperty
    assert property(sclaim_have_value_when_sint_is_1);
  end
else
  begin: CLAIM_INT_ASSERION_DUMMY
    
  end
end
endgenerate



//======================================================
// mint/sint priority bigger than theroushold
//======================================================
wire [INT_NUM*PRIO_BIT-1:0] corex_all_int_prio[HART_NUM-1:0];
wire [INT_NUM*PRIO_BIT-1:0] corex_shift_int_prio[HART_NUM-1:0];
wire [4:0]                  corex_prio_mth[HART_NUM-1:0];
wire [4:0]                  corex_prio_sth[HART_NUM-1:0];

generate
for(i=0;i<HART_NUM;i=i+1)
begin:PRIO_BIGGER_THAN_THER_ASSEERTION
if(HART_EXIST[i])
  begin: PRIO_BIGGER_THAN_THER_ASSERION_TURE 
    assign corex_all_int_prio[i]   = HART_ARB[i].HART_ARB_TURE.x_pic_plic_hart_arb.kid_yy_int_prio[INT_NUM*PRIO_BIT-1:0];
    assign corex_shift_int_prio[i] = (corex_all_int_prio[i] >> (corex_id[i]*5));
    assign corex_prio_mth[i]       = HART_ARB[i].HART_ARB_TURE.x_pic_plic_hart_arb.hreg_arbx_prio_mth[4:0];
    assign corex_prio_sth[i]       = HART_ARB[i].HART_ARB_TURE.x_pic_plic_hart_arb.hreg_arbx_prio_sth[4:0];

    property corex_mint_piro_bigger_th;
      @(posedge  plic_clk)
        (mclaim[i] && mint[i]) |=> ((corex_shift_int_prio[i][4:0])>= (corex_prio_mth[i]));
    endproperty
    assert property(corex_mint_piro_bigger_th);

    property corex_sint_piro_bigger_th;
      @(posedge  plic_clk)
        (mclaim[i] && sint[i]) |=> ((corex_shift_int_prio[i][4:0])>= (corex_prio_sth[i]));
    endproperty
    assert property(corex_sint_piro_bigger_th);
  end
else
  begin: PRIO_BIGGER_THAN_THER_ASSERION_DUMMY
    
  end
end
endgenerate

//======================================================
// sclaim cannot claim the mint req
//======================================================
generate
for(i=0;i<HART_NUM;i=i+1)
begin:MINT_CLAIM_BY_S_ASSEERTION
if(HART_EXIST[i])
  begin: MINT_CLAIM_BY_S_ASSERION_TURE 
    property corex_mint_claim_by_s;
      @(posedge  plic_clk)
        (sclaim[i] && !mclaim[i] && mint_req_out[i] && (corex_mclaim_id[i]!=0)) |=> (corex_int_req[i][corex_id[i]] != 0);
    endproperty
    assert property(corex_mint_claim_by_s);
  end
else
  begin: MINT_CLAIM_BY_S_ASSERION_DUMMY
    
  end
end
endgenerate

`endif

`ifdef PIC_FOR_VERIFICATION
`ifdef PIC_COVERAGE


bind pic_plic_top pic_plic_cov x_pic_plic_cov(
    .apb_addr          (`PLIC_TOP.ciu_plic_paddr[26:0]),
    .apb_prot          (`PLIC_TOP.ciu_plic_pprot[1:0]),
    .apb_sel           (`PLIC_TOP.ciu_plic_psel),
    .apb_write         (`PLIC_TOP.ciu_plic_pwrite),
    .c0_mclaim_updt    (`PLIC_TOP.x_pic_plic_hreg_busif.arbx_hreg_claim_reg_ready[0]),
    .c0_mclaim_id      (`PLIC_TOP.x_pic_plic_hreg_busif.hart_mclaim_flop[0]),
    .c0_sclaim_id      (`PLIC_TOP.x_pic_plic_hreg_busif.hart_sclaim_flop[0]),
    .c0_mthres         (`PLIC_TOP.HART_ARB[0].x_pic_plic_hart_arb.x_pic_plic_arb_ctrl.hreg_arbx_prio_mth[4:0]),
    .c0_req_prio       (`PLIC_TOP.HART_ARB[0].x_pic_plic_hart_arb.x_pic_plic_arb_ctrl.arb_ctrl_int_prio[4:0]),
    .c0_sclaim_updt    (`PLIC_TOP.x_pic_plic_hreg_busif.arbx_hreg_claim_reg_ready[0]),
    .c0_sthres         (`PLIC_TOP.HART_ARB[0].x_pic_plic_hart_arb.x_pic_plic_arb_ctrl.hreg_arbx_prio_sth[4:0]),
`ifdef PIC_PROCESSOR_1
    .c1_mclaim_updt    (`PLIC_TOP.x_pic_plic_hreg_busif.arbx_hreg_claim_reg_ready[1]),
    .c1_mclaim_id      (`PLIC_TOP.x_pic_plic_hreg_busif.hart_mclaim_flop[1]),
    .c1_sclaim_id      (`PLIC_TOP.x_pic_plic_hreg_busif.hart_sclaim_flop[1]),
    .c1_mthres         (`PLIC_TOP.HART_ARB[1].x_pic_plic_hart_arb.x_pic_plic_arb_ctrl.hreg_arbx_prio_mth[4:0]),
    .c1_req_prio       (`PLIC_TOP.HART_ARB[1].x_pic_plic_hart_arb.x_pic_plic_arb_ctrl.arb_ctrl_int_prio[4:0]),
    .c1_sclaim_updt    (`PLIC_TOP.x_pic_plic_hreg_busif.arbx_hreg_claim_reg_ready[1]),
    .c1_sthres         (`PLIC_TOP.HART_ARB[1].x_pic_plic_hart_arb.x_pic_plic_arb_ctrl.hreg_arbx_prio_sth[4:0]),
`endif
`ifdef PIC_PROCESSOR_2
    .c2_mclaim_updt    (`PLIC_TOP.x_pic_plic_hreg_busif.arbx_hreg_claim_reg_ready[2]),
    .c2_mclaim_id      (`PLIC_TOP.x_pic_plic_hreg_busif.hart_mclaim_flop[2]),
    .c2_sclaim_id      (`PLIC_TOP.x_pic_plic_hreg_busif.hart_sclaim_flop[2]),
    .c2_mthres         (`PLIC_TOP.HART_ARB[2].x_pic_plic_hart_arb.x_pic_plic_arb_ctrl.hreg_arbx_prio_mth[4:0]),
    .c2_req_prio       (`PLIC_TOP.HART_ARB[2].x_pic_plic_hart_arb.x_pic_plic_arb_ctrl.arb_ctrl_int_prio[4:0]),
    .c2_sclaim_updt    (`PLIC_TOP.x_pic_plic_hreg_busif.arbx_hreg_claim_reg_ready[2]),
    .c2_sthres         (`PLIC_TOP.HART_ARB[2].x_pic_plic_hart_arb.x_pic_plic_arb_ctrl.hreg_arbx_prio_sth[4:0]),
`endif
`ifdef PIC_PROCESSOR_3
    .c3_mclaim_updt    (`PLIC_TOP.x_pic_plic_hreg_busif.arbx_hreg_claim_reg_ready[3]),
    .c3_mclaim_id      (`PLIC_TOP.x_pic_plic_hreg_busif.hart_mclaim_flop[3]),
    .c3_sclaim_id      (`PLIC_TOP.x_pic_plic_hreg_busif.hart_sclaim_flop[3]),
    .c3_mthres         (`PLIC_TOP.HART_ARB[3].x_pic_plic_hart_arb.x_pic_plic_arb_ctrl.hreg_arbx_prio_mth[4:0]),
    .c3_req_prio       (`PLIC_TOP.HART_ARB[3].x_pic_plic_hart_arb.x_pic_plic_arb_ctrl.arb_ctrl_int_prio[4:0]),
    .c3_sclaim_updt    (`PLIC_TOP.x_pic_plic_hreg_busif.arbx_hreg_claim_reg_ready[3]),
    .c3_sthres         (`PLIC_TOP.HART_ARB[3].x_pic_plic_hart_arb.x_pic_plic_arb_ctrl.hreg_arbx_prio_sth[4:0]),
`endif
    .clk               (`PLIC_TOP.plic_clk),
    .int_active        (`PLIC_TOP.x_pic_plic_kid_busif.kid_int_active[INT_NUM-1:0]),
    .int_cfg           (`PLIC_TOP.pad_plic_int_vld[INT_NUM-1:0]),
    .int_vld           (`PLIC_TOP.pad_plic_int_cfg[INT_NUM-1:0]),
    .int_ip            (`PLIC_TOP.x_pic_plic_kid_busif.kid_yy_int_req[INT_NUM-1:0]),
    .mint_req          (`PLIC_TOP.plic_hartx_mint_req[HART_NUM-1:0]),
    .reset             (`PLIC_TOP.plicrst_b),
    .s_per             (`PLIC_TOP.x_plic_ctrl.ctrl_xx_s_permission_t),
    .sint_req          (`PLIC_TOP.plic_hartx_sint_req[HART_NUM-1:0]),

.ciu_plic_paddr          (`PLIC_TOP.ciu_plic_paddr[26:0]),           
.ciu_plic_penable        (`PLIC_TOP.ciu_plic_penable),   
.ciu_plic_psel           (`PLIC_TOP.ciu_plic_psel), 
.ciu_plic_pprot          (`PLIC_TOP.ciu_plic_pprot[1:0]), 
.ciu_plic_pwrite         (`PLIC_TOP.ciu_plic_pwrite),
.ciu_plic_psec           (`PLIC_TOP.ciu_plic_psec[7:0]),
.ctrl_xx_core_sec        (`PLIC_TOP.ctrl_xx_core_sec[HART_NUM-1:0]),
.ctrl_xx_s_permission_t  (`PLIC_TOP.ctrl_xx_s_permission_t),
.ctrl_xx_s_permission_nt (`PLIC_TOP.ctrl_xx_s_permission_nt),
                         
.prio_bus_mtx_pslverr    (`PLIC_TOP.prio_bus_mtx_pslverr),
.ip_bus_mtx_pslverr      (`PLIC_TOP.ip_bus_mtx_pslverr),
.ie_bus_mtx_pslverr      (`PLIC_TOP.ie_bus_mtx_pslverr),
.sec_bus_mtx_pslverr     (`PLIC_TOP.sec_bus_mtx_pslverr),
.plic_ctrl_pslverr       (`PLIC_TOP.plic_ctrl_pslverr),
.ict_bus_mtx_pslverr     (`PLIC_TOP.ict_bus_mtx_pslverr),

.ctrl_xx_amp_mode         (`PLIC_TOP.ctrl_xx_amp_mode),
.ctrl_xx_amp_lock         (`PLIC_TOP.ctrl_xx_amp_lock),   
.bus_mtx_plic_ctrl_pwdata (`PLIC_TOP.x_plic_ctrl.bus_mtx_plic_ctrl_pwdata[30]),
.data_flop_32      (`PLIC_TOP.x_pic_plic_sec_busif.INT_SEC[0].x_int_sec_ff.data_flop[31:0]),
.data_in_32        (`PLIC_TOP.x_pic_plic_sec_busif.INT_SEC[0].x_int_sec_ff.data_in[31:0]),
.data_flop_64      (`PLIC_TOP.x_pic_plic_sec_busif.INT_SEC[1].x_int_sec_ff.data_flop[31:0]),
.data_in_64        (`PLIC_TOP.x_pic_plic_sec_busif.INT_SEC[1].x_int_sec_ff.data_in[31:0]),
.data_flop_96      (`PLIC_TOP.x_pic_plic_sec_busif.INT_SEC[2].x_int_sec_ff.data_flop[31:0]),
.data_in_96        (`PLIC_TOP.x_pic_plic_sec_busif.INT_SEC[2].x_int_sec_ff.data_in[31:0]),
.data_flop_128     (`PLIC_TOP.x_pic_plic_sec_busif.INT_SEC[3].x_int_sec_ff.data_flop[31:0]),
.data_in_128       (`PLIC_TOP.x_pic_plic_sec_busif.INT_SEC[3].x_int_sec_ff.data_in[31:0]),
.data_flop_160     (`PLIC_TOP.x_pic_plic_sec_busif.INT_SEC[4].x_int_sec_ff.data_flop[31:0]),
.data_in_160       (`PLIC_TOP.x_pic_plic_sec_busif.INT_SEC[4].x_int_sec_ff.data_in[31:0]),
.int_sec_infor     (`PLIC_TOP.int_sec_infor[INT_NUM-1:0]),
.kid_busif_pending (`PLIC_TOP.x_pic_plic_kid_busif.kid_busif_pending[INT_NUM-1:0]),
.kid_int_active    (`PLIC_TOP.x_pic_plic_kid_busif.kid_int_active[INT_NUM-1:0]),
.plic_ciu_pready   (`PLIC_TOP.plic_ciu_pready),
.plic_ciu_pslverr  (`PLIC_TOP.plic_ciu_pslverr),

.C0_arbx_hreg_claim_id       (`PLIC_TOP.HART_ARB[0].x_pic_plic_hart_arb.arbx_hreg_claim_id[ID_NUM-1:0]),          
.C0_hart_mie_1d_bus          (`PLIC_TOP.x_pic_plic_hreg_busif.hart_mie_1d_bus[INT_NUM-1:1]),
.C0_hart_sie_1d_bus          (`PLIC_TOP.x_pic_plic_hreg_busif.hart_sie_1d_bus[INT_NUM-1:1]),
.C0_hreg_arbx_mint_claim     (`PLIC_TOP.HART_ARB[0].x_pic_plic_hart_arb.hreg_arbx_mint_claim),
.C0_hreg_arbx_sint_claim     (`PLIC_TOP.HART_ARB[0].x_pic_plic_hart_arb.hreg_arbx_sint_claim),
.C0_arbx_hartx_mint_req      (`PLIC_TOP.HART_ARB[0].x_pic_plic_hart_arb.arbx_hartx_mint_req),
.C0_arbx_hartx_sint_req      (`PLIC_TOP.HART_ARB[0].x_pic_plic_hart_arb.arbx_hartx_sint_req),
.C0_busif_hart_mclaim_wr_en  (`PLIC_TOP.x_pic_plic_hreg_busif.busif_hart_mclaim_wr_en[0]),
.C0_busif_hart_sclaim_wr_en  (`PLIC_TOP.x_pic_plic_hreg_busif.busif_hart_sclaim_wr_en[0]),
.hreg_kid_cmplt_id           (`PLIC_TOP.x_pic_plic_hreg_busif.hreg_kid_cmplt_id[ID_NUM-1:0])
`ifdef PIC_PROCESSOR_1
,                             
.C1_arbx_hreg_claim_id       (`PLIC_TOP.HART_ARB[1].x_pic_plic_hart_arb.arbx_hreg_claim_id[ID_NUM-1:0]),
.C1_hart_mie_1d_bus          (`PLIC_TOP.x_pic_plic_hreg_busif.hart_mie_1d_bus[2*INT_NUM-1:INT_NUM]),
.C1_hart_sie_1d_bus          (`PLIC_TOP.x_pic_plic_hreg_busif.hart_sie_1d_bus[2*INT_NUM-1:INT_NUM]),
.C1_hreg_arbx_mint_claim     (`PLIC_TOP.HART_ARB[1].x_pic_plic_hart_arb.hreg_arbx_mint_claim),
.C1_hreg_arbx_sint_claim     (`PLIC_TOP.HART_ARB[1].x_pic_plic_hart_arb.hreg_arbx_sint_claim),
.C1_arbx_hartx_mint_req      (`PLIC_TOP.HART_ARB[1].x_pic_plic_hart_arb.arbx_hartx_mint_req),
.C1_arbx_hartx_sint_req      (`PLIC_TOP.HART_ARB[1].x_pic_plic_hart_arb.arbx_hartx_sint_req),
.C1_busif_hart_mclaim_wr_en  (`PLIC_TOP.x_pic_plic_hreg_busif.busif_hart_mclaim_wr_en[1]),
.C1_busif_hart_sclaim_wr_en  (`PLIC_TOP.x_pic_plic_hreg_busif.busif_hart_sclaim_wr_en[1])
`endif

`ifdef PIC_PROCESSOR_2
,
.C2_arbx_hreg_claim_id       (`PLIC_TOP.HART_ARB[2].x_pic_plic_hart_arb.arbx_hreg_claim_id[9:0]),
.C2_hart_mie_1d_bus          (`PLIC_TOP.x_pic_plic_hreg_busif.hart_mie_1d_bus[3*INT_NUM-1:2*INT_NUM]),
.C2_hart_sie_1d_bus          (`PLIC_TOP.x_pic_plic_hreg_busif.hart_sie_1d_bus[3*INT_NUM-1:2*INT_NUM]),
.C2_hreg_arbx_mint_claim     (`PLIC_TOP.HART_ARB[2].x_pic_plic_hart_arb.hreg_arbx_mint_claim),
.C2_hreg_arbx_sint_claim     (`PLIC_TOP.HART_ARB[2].x_pic_plic_hart_arb.hreg_arbx_sint_claim),
.C2_arbx_hartx_mint_req      (`PLIC_TOP.HART_ARB[2].x_pic_plic_hart_arb.arbx_hartx_mint_req),
.C2_arbx_hartx_sint_req      (`PLIC_TOP.HART_ARB[2].x_pic_plic_hart_arb.arbx_hartx_sint_req),
.C2_busif_hart_mclaim_wr_en  (`PLIC_TOP.x_pic_plic_hreg_busif.busif_hart_mclaim_wr_en[2]),
.C2_busif_hart_sclaim_wr_en  (`PLIC_TOP.x_pic_plic_hreg_busif.busif_hart_sclaim_wr_en[2])
`endif

`ifdef PIC_PROCESSOR_3
  ,
.C3_arbx_hreg_claim_id       (`PLIC_TOP.HART_ARB[3].x_pic_plic_hart_arb.arbx_hreg_claim_id[ID_NUM-1:0]),
.C3_hart_mie_1d_bus          (`PLIC_TOP.x_pic_plic_hreg_busif.hart_mie_1d_bus[4*INT_NUM-1:3*INT_NUM]),
.C3_hart_sie_1d_bus          (`PLIC_TOP.x_pic_plic_hreg_busif.hart_sie_1d_bus[4*INT_NUM-1:3*INT_NUM]),
.C3_hreg_arbx_mint_claim     (`PLIC_TOP.HART_ARB[3].x_pic_plic_hart_arb.hreg_arbx_mint_claim),
.C3_hreg_arbx_sint_claim     (`PLIC_TOP.HART_ARB[3].x_pic_plic_hart_arb.hreg_arbx_sint_claim),
.C3_arbx_hartx_mint_req      (`PLIC_TOP.HART_ARB[3].x_pic_plic_hart_arb.arbx_hartx_mint_req),
.C3_arbx_hartx_sint_req      (`PLIC_TOP.HART_ARB[3].x_pic_plic_hart_arb.arbx_hartx_sint_req),
.C3_busif_hart_mclaim_wr_en  (`PLIC_TOP.x_pic_plic_hreg_busif.busif_hart_mclaim_wr_en[3]),
.C3_busif_hart_sclaim_wr_en  (`PLIC_TOP.x_pic_plic_hreg_busif.busif_hart_sclaim_wr_en[3])
`endif
);

`endif
`endif

endmodule
// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : pic_pready_pulse_cdc.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-1
// FUNCTION        : pic pready pulse cdc
// ******************************************************************************

module pic_pready_pulse_cdc (
  src_clk,
  src_rst_b,
  src_pulse,
  dst_clk,
  dst_rst_b,
  dst_pulse,
  handshake_pulse
);

input              src_clk;
input              src_rst_b;
input              src_pulse;
input              dst_clk;
input              dst_rst_b;
output             dst_pulse;
output             handshake_pulse;

wire               src_clk;
wire               src_rst_b;
wire               src_pulse;
wire               dst_clk;
wire               dst_rst_b;
wire               dst_pulse;
wire               dst_lvl;
wire               handshake_pulse;
wire               handshake_lvl;

reg                src_lvl;
reg                dst_lvl_f;
reg                handshake_lvl_f;

//extend src_pulse to src_lvl
always @ (posedge src_clk or negedge src_rst_b) 
begin
  if(~src_rst_b)
    src_lvl <= 1'b0;
  else if (handshake_pulse)
    src_lvl <= 1'b0;    
  else if (src_pulse)
    src_lvl <= 1'b1;
end

//scr_lvl to dst_lvl cdc
  pic_sync_dff  x_pic_sync_dff (
        .clk     (dst_clk),
        .rst_b   (dst_rst_b),
        .sync_in      (src_lvl),
        .sync_out     (dst_lvl)
    );

//generate dst_pulse
always @ (posedge dst_clk or negedge dst_rst_b)
begin
  if(~dst_rst_b)
    dst_lvl_f <= 1'b0;
  else
    dst_lvl_f <= dst_lvl;
end

assign dst_pulse = dst_lvl & ~dst_lvl_f;

//dst_lvl to handshake_lvl cdc
//to ensure cluster can recive apb ack, use dst_lvl_f for handshake sync
  pic_sync_dff  x_pic_sync_dff_back (
        .clk     (src_clk),
        .rst_b   (src_rst_b),
        .sync_in      (dst_lvl_f),
        .sync_out     (handshake_lvl)
    );

//generate handshake_pulse
always @ (posedge src_clk or negedge src_rst_b)
begin
  if(~src_rst_b)
    handshake_lvl_f <= 1'b0;
  else
    handshake_lvl_f <= handshake_lvl;
end

assign handshake_pulse = handshake_lvl & ~handshake_lvl_f;

endmodule
// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : pic_psel_cdc.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-1
// FUNCTION        : pic pulse cdc
// ******************************************************************************

module pic_psel_cdc (
  src_clk,
  src_rst_b,
  src_pulse,
  dst_clk,
  dst_rst_b,
  clr_src_lvl,
  dst_pulse
);

input              src_clk;
input              src_rst_b;
input              src_pulse;
input              dst_clk;
input              dst_rst_b;
input              clr_src_lvl;
output             dst_pulse;

wire               src_clk;
wire               src_rst_b;
wire               src_pulse;
wire               dst_clk;
wire               dst_rst_b;
wire               dst_pulse;
wire               dst_lvl;
wire               handshake_lvl;
wire               handshake_pulse;

reg                src_lvl;
reg                dst_lvl_f;
reg                handshake_lvl_f;

//extend src_pulse to src_lvl
always @ (posedge src_clk or negedge src_rst_b) 
begin
  if(~src_rst_b)
    src_lvl <= 1'b0;
  else if (handshake_pulse)
    src_lvl <= 1'b0;    
  else if (src_pulse)
    src_lvl <= 1'b1;
end

  pic_sync_dff  x_pic_sync_dff (
        .clk     (dst_clk),
        .rst_b   (dst_rst_b),
        .sync_in      (src_lvl),
        .sync_out     (dst_lvl)
    );

//generate dst_pulse
always @ (posedge dst_clk or negedge dst_rst_b)
begin
  if(~dst_rst_b)
    dst_lvl_f <= 1'b0;
  else
    dst_lvl_f <= dst_lvl;
end

assign dst_pulse = dst_lvl & ~dst_lvl_f;

//dst_lvl to handshake_lvl cdc
//to ensure cluster can recive apb ack, use dst_lvl_f for handshake sync
  pic_sync_dff  x_pic_sync_dff_back (
        .clk     (src_clk),
        .rst_b   (src_rst_b),
        .sync_in      (dst_lvl_f),
        .sync_out     (handshake_lvl)
    );

//generate handshake_pulse
always @ (posedge src_clk or negedge src_rst_b)
begin
  if(~src_rst_b)
    handshake_lvl_f <= 1'b0;
  else
    handshake_lvl_f <= handshake_lvl;
end

assign handshake_pulse = handshake_lvl & ~handshake_lvl_f;

endmodule
// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : pic_rst_top.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-5-8
// FUNCTION        : pic rst top
// ******************************************************************************
module pic_rst_top (
  //input
  cluster_clk,
  cluster_rst_b,
  pad_yy_mbist_mode,
  pad_yy_scan_rst_b,
  pad_yy_scan_mode,
  //output
  sync_cluster_rst_b
);
parameter CLUSTER_NUM = 4;

//input
input [CLUSTER_NUM:0]  cluster_clk;
input [CLUSTER_NUM:0]  cluster_rst_b;
input                  pad_yy_mbist_mode;
input                  pad_yy_scan_rst_b;
input                  pad_yy_scan_mode;
//output
output [CLUSTER_NUM:0]  sync_cluster_rst_b;

wire [CLUSTER_NUM:0] async_cluster_rst_b;
wire                 value_zero;

reg [CLUSTER_NUM:0] cluster_rst_1ff;
reg [CLUSTER_NUM:0] cluster_rst_2ff;
reg [CLUSTER_NUM:0] cluster_rst_3ff;

assign value_zero = 1'b0;
always @ (*) //to fix lint
  begin
    cluster_rst_1ff[CLUSTER_NUM] = value_zero;
    cluster_rst_2ff[CLUSTER_NUM] = value_zero;
    cluster_rst_3ff[CLUSTER_NUM] = value_zero;
  end
assign sync_cluster_rst_b[CLUSTER_NUM]  = 1'b1; //to fix lint
assign async_cluster_rst_b[CLUSTER_NUM] = 1'b1; //to fix lint

genvar i;
generate
for(i=0;i<CLUSTER_NUM;i=i+1)
begin:RST_SYNC
   
assign async_cluster_rst_b[i] = cluster_rst_b[i] & ~pad_yy_mbist_mode;

always @(posedge cluster_clk[i] or negedge async_cluster_rst_b[i])
begin
  if (~async_cluster_rst_b[i])
  begin
    cluster_rst_1ff[i] <= 1'b0;
    cluster_rst_2ff[i] <= 1'b0;
    cluster_rst_3ff[i] <= 1'b0;
  end
  else
  begin
    cluster_rst_1ff[i] <= 1'b1;
    cluster_rst_2ff[i] <= cluster_rst_1ff[i];
    cluster_rst_3ff[i] <= cluster_rst_2ff[i];
  end
end

pic_mux_cell  x_sync_cluster_rst_mux (
  .I0                 (cluster_rst_3ff[i]),
  .I1                 (pad_yy_scan_rst_b ),
  .S                  (pad_yy_scan_mode  ),
  .Z                  (sync_cluster_rst_b[i]    )
); 
end
endgenerate

endmodule
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


// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : pic_top.v
// AUTHOR          : xiaty
// ORIGINAL DATE   : 2021-4-1
// FUNCTION        : pic top
//                   include plic, clint, apb_sync, apb_matrix 
// ******************************************************************************
// &Depend("pic_cfig.vh"); @16
// &Depend("pic_apb_sync.v"); @17
// &Depend("pic_pready_pulse_cdc.v"); @18
// &Depend("pic_psel_cdc.v"); @19
// &Depend("pic_sync_dff.v"); @20
// &Depend("pic_apb_matrix_n_to_n.v"); @21
// &Depend("pic_clint_func.v"); @22
// &Depend("pic_clint_top.v"); @23
// &Depend("pic_rst_top.v"); @24
// &Depend("pic_plic_top.v"); @26
// &Depend("pic_plic_ctrl.v"); @27
// &Depend("pic_plic_apb_1tox_matrix.v"); @28
// &Depend("pic_plic_apb_1tox_matrix_for_ie.v"); @29
// &Depend("pic_plic_kid_busif.v"); @30
// &Depend("pic_plic_int_kid.v"); @31
// &Depend("pic_plic_hreg_busif.v"); @32
// &Depend("pic_plic_hart_arb.v"); @33
// &Depend("pic_plic_arb_ctrl.v"); @34
// &Depend("pic_plic_32to1_arb.v"); @35
// &Depend("pic_plic_32to1_stage1.v"); @36
// &Depend("pic_plic_32to1_stage2.v"); @37
// &Depend("pic_plic_granu2_arb.v"); @38
// &Depend("pic_plic_granu_arb.v"); @39
// &Depend("pic_plic_instance_reg_flog.v"); @40
// &Depend("pic_plic_nor_sel.v"); @41
// &Depend("pic_plic_prio_sel.v"); @42
// &Depend("pic_plic_top_dummy.v"); @44
// &Depend("pic_gated_clk_cell.v"); @46
// &Depend("pic_gated_cell.v"); @47
// &Depend("pic_mux_cell.v"); @48

// &Depend("pic_top_golden_port.vp"); @50

// &ModuleBeg; @52
module pic_top(
  clint_hartx_ms_int,
  clint_hartx_mt_int,
  clint_hartx_ss_int,
  clint_hartx_st_int,
  cluster_clk,
  cluster_rst_b,
  clusterx_pic_paddr,
  clusterx_pic_penable,
  clusterx_pic_pprot,
  clusterx_pic_psel,
  clusterx_pic_pwdata,
  clusterx_pic_pwrite,
  pad_pic_plic_int_cfg,
  pad_pic_plic_int_vld,
  pad_pic_sys_cnt,
  pad_yy_icg_scan_en,
  pad_yy_mbist_mode,
  pad_yy_scan_mode,
  pad_yy_scan_rst_b,
  pic_clk,
  pic_clusterx_prdata,
  pic_clusterx_pready,
  pic_clusterx_pslverr,
  pic_pad_par_violation,
  pic_rst_b,
  plic_hartx_me_int,
  plic_hartx_se_int
);

// &Ports("compare", "pic_top_golden_port.v"); @53
input   [0 :0]  cluster_clk;             
input   [0 :0]  cluster_rst_b;           
input   [31:0]  clusterx_pic_paddr;      
input   [0 :0]  clusterx_pic_penable;    
input   [1 :0]  clusterx_pic_pprot;      
input   [0 :0]  clusterx_pic_psel;       
input   [31:0]  clusterx_pic_pwdata;     
input   [0 :0]  clusterx_pic_pwrite;     
input   [63:0]  pad_pic_plic_int_cfg;    
input   [63:0]  pad_pic_plic_int_vld;    
input   [63:0]  pad_pic_sys_cnt;         
input           pad_yy_icg_scan_en;      
input           pad_yy_mbist_mode;       
input           pad_yy_scan_mode;        
input           pad_yy_scan_rst_b;       
input           pic_clk;                 
input           pic_rst_b;               
output  [3 :0]  clint_hartx_ms_int;      
output  [3 :0]  clint_hartx_mt_int;      
output  [3 :0]  clint_hartx_ss_int;      
output  [3 :0]  clint_hartx_st_int;      
output  [31:0]  pic_clusterx_prdata;     
output  [0 :0]  pic_clusterx_pready;     
output  [0 :0]  pic_clusterx_pslverr;    
output          pic_pad_par_violation;   
output  [3 :0]  plic_hartx_me_int;       
output  [3 :0]  plic_hartx_se_int;       

// &Regs; @54

// &Wires; @55
wire    [31:0]  clint_base_addr;         
wire    [31:0]  clint_base_addr_mask;    
wire    [31:0]  pic_clusterx_prdata;     
wire    [32:0]  pic_clusterx_prdata_ext; 
wire    [0 :0]  pic_clusterx_pready;     
wire    [1 :0]  pic_clusterx_pready_ext; 
wire    [0 :0]  pic_clusterx_pslverr;    
wire    [1 :0]  pic_clusterx_pslverr_ext; 
wire    [31:0]  pilc_base_addr_mask;     
wire    [31:0]  plic_base_addr;          
wire    [63:0]  slvx_base_addr;          
wire    [63:0]  slvx_base_addr_mask;     


parameter CLUSTER_NUM      = `PIC_CLUSTER_NUM;
parameter HART_EXIST       = {256{1'b1}};
parameter INT_NUM          = `PIC_PLIC_INT_NUM;
parameter ID_NUM           = `PIC_PLIC_ID_NUM;
parameter PRIO_BIT         = `PIC_PLIC_PRIO_BIT;
parameter HART_NUM_PER_CLUSTER = 16;
parameter HART_NUM         = `PIC_HART_NUM;
parameter PIC_SLV_NUM      = 2;

//input
// &Force("input", "pic_clk"); @67
// &Force("input", "pic_rst_b"); @68
// &Force("input", "pad_yy_icg_scan_en"); @69
// &Force("input", "pad_yy_mbist_mode"); @70
// &Force("input", "pad_yy_scan_rst_b"); @71
// &Force("input", "pad_yy_scan_mode"); @72
// &Force("input", "cluster_clk");            &Force("bus","cluster_clk",CLUSTER_NUM-1,0); @73
// &Force("input", "cluster_rst_b");          &Force("bus","cluster_rst_b",CLUSTER_NUM-1,0); @74
// &Force("input", "pad_pic_plic_int_vld");   &Force("bus","pad_pic_plic_int_vld",INT_NUM-1,0); @76
// &Force("input", "pad_pic_plic_int_cfg");   &Force("bus","pad_pic_plic_int_cfg",INT_NUM-1,0); @77
// &Force("input", "pad_pic_sys_cnt");        &Force("bus","pad_pic_sys_cnt",63,0); @79
// &Force("input", "clusterx_pic_psel");      &Force("bus","clusterx_pic_psel",CLUSTER_NUM-1,0); @80
// &Force("input", "clusterx_pic_penable");   &Force("bus","clusterx_pic_penable",CLUSTER_NUM-1,0); @81
// &Force("input", "clusterx_pic_paddr");     &Force("bus","clusterx_pic_paddr",CLUSTER_NUM*32-1,0); @82
// &Force("input", "clusterx_pic_pwrite");    &Force("bus","clusterx_pic_pwrite",CLUSTER_NUM-1,0); @83
// &Force("input", "clusterx_pic_pwdata");    &Force("bus","clusterx_pic_pwdata",CLUSTER_NUM*32-1,0); @84
// &Force("input", "clusterx_pic_pprot");     &Force("bus","clusterx_pic_pprot",CLUSTER_NUM*2-1,0); @85
//output
// &Force("output", "pic_clusterx_pready");   &Force("bus","pic_clusterx_pready",CLUSTER_NUM-1,0); @87
// &Force("output", "pic_clusterx_prdata");   &Force("bus","pic_clusterx_prdata",CLUSTER_NUM*32-1,0); @88
// &Force("output", "pic_clusterx_pslverr");  &Force("bus","pic_clusterx_pslverr",CLUSTER_NUM-1,0); @89
// &Force("output", "plic_hartx_me_int");     &Force("bus","plic_hartx_me_int",HART_NUM-1,0); @90
// &Force("output", "plic_hartx_se_int");     &Force("bus","plic_hartx_se_int",HART_NUM-1,0); @91
// &Force("output", "clint_hartx_ms_int");    &Force("bus","clint_hartx_ms_int",HART_NUM-1,0); @92
// &Force("output", "clint_hartx_mt_int");    &Force("bus","clint_hartx_mt_int",HART_NUM-1,0); @93
// &Force("output", "clint_hartx_ss_int");    &Force("bus","clint_hartx_ss_int",HART_NUM-1,0); @94
// &Force("output", "clint_hartx_st_int");    &Force("bus","clint_hartx_st_int",HART_NUM-1,0); @95
// &Force("output", "pic_pad_par_violation"); @97

//csky vperl off
wire [CLUSTER_NUM:0]        sync_matrix_psel; //to fix lint, use [CLUSTER_NUM:0]
wire [CLUSTER_NUM*32:0]     sync_matrix_paddr;
wire [CLUSTER_NUM:0]        sync_matrix_pwrite;
wire [CLUSTER_NUM*32:0]     sync_matrix_pwdata;
wire [CLUSTER_NUM*2:0]      sync_matrix_pprot;
wire [CLUSTER_NUM:0]        matrix_sync_pready;
wire [CLUSTER_NUM*32:0]     matrix_sync_prdata;
wire [CLUSTER_NUM:0]        matrix_sync_pslverr;
wire [CLUSTER_NUM:0]        trans_cmplt;
wire [PIC_SLV_NUM-1:0]      matrix_slv_psel;
wire [PIC_SLV_NUM-1:0]      matrix_slv_penable;
wire [PIC_SLV_NUM*32-1:0]   matrix_slv_paddr;
wire [PIC_SLV_NUM-1:0]      matrix_slv_pwrite;
wire [PIC_SLV_NUM*32-1:0]   matrix_slv_pwdata;
wire [PIC_SLV_NUM*2-1:0]    matrix_slv_pprot;
wire [PIC_SLV_NUM-1:0]      slv_matrix_pready;
wire [PIC_SLV_NUM*32-1:0]   slv_matrix_prdata;
wire [PIC_SLV_NUM-1:0]      slv_matrix_pslverr;
wire                        plic_icg_en;
wire                        apb_icg_en;
wire [CLUSTER_NUM:0]        sync_cluster_rst_b;
wire                        clint_plic_reg_par_disable;
wire                        pic_pad_par_violation;
//csky vperl on
pic_rst_top #(.CLUSTER_NUM (CLUSTER_NUM))
x_pic_rst_top (
  //input
  .cluster_clk          ({1'b0,cluster_clk[CLUSTER_NUM-1:0]}),
  .cluster_rst_b        ({1'b0,cluster_rst_b[CLUSTER_NUM-1:0]}),
  .pad_yy_mbist_mode    (pad_yy_mbist_mode),
  .pad_yy_scan_rst_b    (pad_yy_scan_rst_b),
  .pad_yy_scan_mode     (pad_yy_scan_mode),
  //output
  .sync_cluster_rst_b   (sync_cluster_rst_b[CLUSTER_NUM:0])
);

pic_apb_sync #(.CLUSTER_NUM (CLUSTER_NUM))
x_pic_apb_sync (
  //input
  .pic_clk              (pic_clk),
  .pic_rst_b            (pic_rst_b),
  .cluster_clk          ({1'b0,cluster_clk[CLUSTER_NUM-1:0]}),
  .cluster_rst_b        (sync_cluster_rst_b[CLUSTER_NUM:0]),
  .psel_cluster         ({1'b0,clusterx_pic_psel[CLUSTER_NUM-1:0]}), //add 1'b0 on high bit to fix lint
  .penable_cluster      ({1'b0,clusterx_pic_penable[CLUSTER_NUM-1:0]}),
  .pwrite_cluster       ({1'b0,clusterx_pic_pwrite[CLUSTER_NUM-1:0]}),
  .paddr_cluster        ({1'b0,clusterx_pic_paddr[CLUSTER_NUM*32-1:0]}),
  .pwdata_cluster       ({1'b0,clusterx_pic_pwdata[CLUSTER_NUM*32-1:0]}),
  .pprot_cluster        ({1'b0,clusterx_pic_pprot[CLUSTER_NUM*2-1:0]}),
  .pready_pic           (matrix_sync_pready[CLUSTER_NUM:0]),
  .prdata_pic           (matrix_sync_prdata[CLUSTER_NUM*32:0]),
  .pslverr_pic          (matrix_sync_pslverr[CLUSTER_NUM:0]),
  //output
  .psel_pic             (sync_matrix_psel[CLUSTER_NUM:0]),  //no penable, only use psel for arbiter
  .pwrite_pic           (sync_matrix_pwrite[CLUSTER_NUM:0]), 
  .paddr_pic            (sync_matrix_paddr[CLUSTER_NUM*32:0]),
  .pwdata_pic           (sync_matrix_pwdata[CLUSTER_NUM*32:0]),
  .pprot_pic            (sync_matrix_pprot[CLUSTER_NUM*2:0]),
  .pready_cluster       (pic_clusterx_pready_ext[CLUSTER_NUM:0]),
  .prdata_cluster       (pic_clusterx_prdata_ext[CLUSTER_NUM*32:0]),
  .pslverr_cluster      (pic_clusterx_pslverr_ext[CLUSTER_NUM:0]),
  .trans_cmplt          (trans_cmplt[CLUSTER_NUM:0])
);
assign pic_clusterx_pready[CLUSTER_NUM-1:0] = pic_clusterx_pready_ext[CLUSTER_NUM-1:0];
assign pic_clusterx_prdata[CLUSTER_NUM*32-1:0] = pic_clusterx_prdata_ext[CLUSTER_NUM*32-1:0];
assign pic_clusterx_pslverr[CLUSTER_NUM-1:0] = pic_clusterx_pslverr_ext[CLUSTER_NUM-1:0];
// &Force("nonport", "pic_clusterx_pready_ext"); @169
// &Force("nonport", "pic_clusterx_prdata_ext"); @170
// &Force("nonport", "pic_clusterx_pslverr_ext"); @171

pic_apb_matrix_n_to_n #(.MST_NUM    (CLUSTER_NUM),
                        .SLV_NUM    (PIC_SLV_NUM),
                        .ADDR_WIDTH (32),
                        .DATA_WIDTH (32),
                        .PROT_WIDTH (2))
x_pic_apb_matrix_n_to_n (
  //input
  .apb_matrix_clk      (pic_clk),
  .apb_matrix_rst_b    (pic_rst_b),
  .pad_yy_icg_scan_en  (pad_yy_icg_scan_en),
  .apb_matrix_icg_en   (apb_icg_en),
  .slvx_base_addr      (slvx_base_addr[32*PIC_SLV_NUM-1:0]),
  .slvx_base_addr_mask (slvx_base_addr_mask[32*PIC_SLV_NUM-1:0]),
  .trans_cmplt         (trans_cmplt[CLUSTER_NUM:0]),
  .psel_slv            (sync_matrix_psel[CLUSTER_NUM:0]),
  .penable_slv         (sync_matrix_psel[CLUSTER_NUM:0]),
  .pwrite_slv          (sync_matrix_pwrite[CLUSTER_NUM:0]),
  .paddr_slv           (sync_matrix_paddr[CLUSTER_NUM*32:0]),
  .pwdata_slv          (sync_matrix_pwdata[CLUSTER_NUM*32:0]),
  .pprot_slv           (sync_matrix_pprot[CLUSTER_NUM*2:0]),
  .pready_mst          (slv_matrix_pready[PIC_SLV_NUM-1:0]),
  .prdata_mst          (slv_matrix_prdata[PIC_SLV_NUM*32-1:0]),
  .pslverr_mst         (slv_matrix_pslverr[PIC_SLV_NUM-1:0]),
  //output
  .pready_slv          (matrix_sync_pready[CLUSTER_NUM:0]),
  .prdata_slv          (matrix_sync_prdata[CLUSTER_NUM*32:0]),
  .pslverr_slv         (matrix_sync_pslverr[CLUSTER_NUM:0]),
  .psel_mst            (matrix_slv_psel[PIC_SLV_NUM-1:0]),
  .penable_mst         (matrix_slv_penable[PIC_SLV_NUM-1:0]),
  .pwrite_mst          (matrix_slv_pwrite[PIC_SLV_NUM-1:0]),
  .paddr_mst           (matrix_slv_paddr[PIC_SLV_NUM*32-1:0]),
  .pwdata_mst          (matrix_slv_pwdata[PIC_SLV_NUM*32-1:0]),
  .pprot_mst           (matrix_slv_pprot[PIC_SLV_NUM*2-1:0])
);
assign plic_base_addr[31:0]                    = { {5{1'b0}},1'b0,{26{1'b0}} }; //apb_addr[26] = 1'b0
assign pilc_base_addr_mask[31:0]               = { {5{1'b0}},1'b1,{26{1'b0}} };
assign clint_base_addr[31:0]                   = { {5{1'b0}},{11'h400},{16{1'b0}} };
assign clint_base_addr_mask[31:0]              = { {5{1'b0}},{11{1'b1}},{16{1'b0}} };
assign slvx_base_addr[32*PIC_SLV_NUM-1:0]      = {plic_base_addr[31:0],clint_base_addr[31:0]};
assign slvx_base_addr_mask[32*PIC_SLV_NUM-1:0] = {pilc_base_addr_mask[31:0],clint_base_addr_mask[31:0]};
// &Force("nonport", "slvx_base_addr"); @213
// &Force("nonport", "slvx_base_addr_mask"); @214

//salve0 is clint
pic_clint_top #(.CLUSTER_NUM          (CLUSTER_NUM),
            .HART_NUM_PER_CLUSTER (HART_NUM_PER_CLUSTER),
            .HART_EXIST           (HART_EXIST),
            .HART_NUM             (HART_NUM))
x_pic_clint_top (
  //input
  .forever_apbclk       (pic_clk),
  .cpurst_b             (pic_rst_b),
  .pad_yy_icg_scan_en   (pad_yy_icg_scan_en),
  .paddr                (matrix_slv_paddr[31:0]),
  .penable              (matrix_slv_penable[0]),
  .pprot                (matrix_slv_pprot[1:0]),
  .psel_clint           (matrix_slv_psel[0]),
  .pwdata               (matrix_slv_pwdata[31:0]),
  .pwrite               (matrix_slv_pwrite[0]),
  .sysio_clint_mtime    (pad_pic_sys_cnt[63:0]),
  //output
  .pready_clint         (slv_matrix_pready[0]),
  .perr_clint           (slv_matrix_pslverr[0]),
  .prdata_clint         (slv_matrix_prdata[31:0]),
  .clint_core_ms_int    (clint_hartx_ms_int[HART_NUM-1:0]),
  .clint_core_ss_int    (clint_hartx_ss_int[HART_NUM-1:0]),
  .clint_core_mt_int    (clint_hartx_mt_int[HART_NUM-1:0]),
  .clint_core_st_int    (clint_hartx_st_int[HART_NUM-1:0]),
  .plic_icg_en          (plic_icg_en),
  .apb_icg_en           (apb_icg_en)
  ,
  .clint_plic_reg_par_disable(clint_plic_reg_par_disable)
);

//slave1 is plic
pic_plic_top #(.CLUSTER_NUM          (CLUSTER_NUM),
           .HART_NUM_PER_CLUSTER (HART_NUM_PER_CLUSTER),
           .HART_EXIST           (HART_EXIST),
           .INT_NUM              (INT_NUM),
           .ID_NUM               (ID_NUM),
           .PRIO_BIT             (PRIO_BIT),
           .HART_NUM             (HART_NUM))

x_pic_plic_top (
  .plic_hartx_mint_req  (plic_hartx_me_int[HART_NUM-1:0]),
  .plic_hartx_sint_req  (plic_hartx_se_int[HART_NUM-1:0]),
  .ciu_plic_paddr       (matrix_slv_paddr[58:32]),
  .ciu_plic_penable     (matrix_slv_penable[1]),
  .ciu_plic_psel        (matrix_slv_psel[1]),
  .ciu_plic_pprot       (matrix_slv_pprot[3:2]),
  .ciu_plic_pwdata      (matrix_slv_pwdata[63:32]),
  .ciu_plic_pwrite      (matrix_slv_pwrite[1]),
  .ciu_plic_icg_en      (plic_icg_en),
  .pad_plic_int_vld     (pad_pic_plic_int_vld[INT_NUM-1:0]),
  .pad_plic_int_cfg     (pad_pic_plic_int_cfg[INT_NUM-1:0]),
  .pad_yy_icg_scan_en   (pad_yy_icg_scan_en),

  .plic_ciu_prdata      (slv_matrix_prdata[63:32]),
  .plic_ciu_pready      (slv_matrix_pready[1]),
  .plic_ciu_pslverr     (slv_matrix_pslverr[1]),
  .plic_clk             (pic_clk),
  .plicrst_b            (pic_rst_b)
   ,
  .clint_plic_reg_par_disable(clint_plic_reg_par_disable),
  .plic_pad_reg_parity_error(pic_pad_par_violation)
);

// &ModuleEnd; @315
endmodule


// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : pic_top_golden_port.vp
// AUTHOR          : Xia Tianyi
// ORIGINAL DATE   : 2021-5-6
// DESCRIPTION     : Golden port module for pic
// ******************************************************************************
// &Depend("pic_cfig.vh"); @15
// &ModuleBeg; @16








