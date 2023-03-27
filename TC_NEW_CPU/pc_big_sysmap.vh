// ******************************************************************************
// * T-Head Semiconductor Co., Ltd. Confidential                                *
// * -------------------------------                                            *
// * This file and all its contents are properties of T-Head Semiconductor      *
// * Co., Ltd.. The information contained herein is confidential and            *
// * proprietary and is not to be disclosed outside of T-Head Semiconductor     *
// *  Co., Ltd. except under a Non-Disclosure Agreement (NDA).                  *
// *                                                                            *
// ******************************************************************************
// FILE NAME       : ct_mmu_sysmap.vp
// AUTHOR          : Ziyi Hao
// ORIGINAL TIME   :
// FUNCTION        : I-uTLB:
//                 : 1. 16-entry utlb 
//                 : 2. translate Va to PA
//                 : 3. visit jTLB when uTLB miss
//                 : 4. refill uTLB with PLRU algorithm
// RESET           : 
// DFT             :
// DFP             :
// VERIFICATION    :
// RELEASE HISTORY :
// $Id: sysmap.h,v 1.4 2020/10/19 01:03:12 sunc Exp $
// *****************************************************************************

// RELEASE_SYSMAP_START

// ADDR is 28-bit, 4K address
// Flag includes: Strong Order, Cacheable, Bufferable, Shareable, Security

  `define PC_BIG_SYSMAP_BASE_ADDR0  28'h008ffff
  `define PC_BIG_SYSMAP_FLG0        5'b01111
  
  `define PC_BIG_SYSMAP_BASE_ADDR1  28'h00bffff
  `define PC_BIG_SYSMAP_FLG1        5'b10011
  
  `define PC_BIG_SYSMAP_BASE_ADDR2  28'h00cffff
  `define PC_BIG_SYSMAP_FLG2        5'b00011
  
  `define PC_BIG_SYSMAP_BASE_ADDR3  28'h00effff
  `define PC_BIG_SYSMAP_FLG3        5'b01101
  
  `define PC_BIG_SYSMAP_BASE_ADDR4  28'h00fffff
  `define PC_BIG_SYSMAP_FLG4        5'b01111
  
  `define PC_BIG_SYSMAP_BASE_ADDR5  28'h1000000
  `define PC_BIG_SYSMAP_FLG5        5'b01111
  
  `define PC_BIG_SYSMAP_BASE_ADDR6  28'h1300000 
  `define PC_BIG_SYSMAP_FLG6        5'b10000

  `define PC_BIG_SYSMAP_BASE_ADDR7  28'hfffffff 
  `define PC_BIG_SYSMAP_FLG7        5'b01111

// RELEASE_SYSMAP_END
