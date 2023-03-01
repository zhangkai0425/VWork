`include "CBB_define.v"
 
module unified_SPRAM #(
        parameter MEMORY_PRIMITIVE = "auto",   //"auto","block","distributed","ultra"
        parameter MEMORY_INIT_FILE = "none",      // String
        parameter BYTE_WRITE_EN = 0,      // DECIMAL
        parameter ADDR_WIDTH_A = 4,
        parameter READ_LATENCY_A = 1,
        parameter WRITE_DATA_WIDTH_A = 32,        // DECIMAL
        parameter READ_DATA_WIDTH_A  = 32
	)
(
      rsta     ,   clka     ,
      wea     ,  ena       ,addra     , dina      , douta      ,   parity_err  //at rd_clk
    );   
       
    
    //////////////////////////////////////////////
    
        localparam WE_WIDTH_A   = BYTE_WRITE_EN ? WRITE_DATA_WIDTH_A/8 : 1;
        
        input                            rsta     ; 
        input                            clka     ;
        input  [WE_WIDTH_A-1:0]          wea     ;
        input                            ena       ;
        input  [ADDR_WIDTH_A-1:0]        addra     ;
        input  [WRITE_DATA_WIDTH_A-1:0]  dina      ;
        output [READ_DATA_WIDTH_A-1:0]     douta      ;
        output                             parity_err ; //at rd_clk

`ifdef ASIC

`elsif INTEL

`else

XPM_SPRAM_odd  #(
        .MEMORY_PRIMITIVE(MEMORY_PRIMITIVE),   //"auto","block","distributed","ultra"
        .MEMORY_INIT_FILE(MEMORY_INIT_FILE),      // String
        .BYTE_WRITE_EN(BYTE_WRITE_EN),
        .ADDR_WIDTH_A(ADDR_WIDTH_A),
        .READ_LATENCY_A(READ_LATENCY_A),
        .WRITE_DATA_WIDTH_A(WRITE_DATA_WIDTH_A),        // DECIMAL
        .READ_DATA_WIDTH_A(READ_DATA_WIDTH_A)
	)XPM_SDPRAM_odd(
      .rsta     (rsta), 
      .clka     (clka),
      .wea      (wea),
      .ena      (ena),
      .addra    (addra),
      .dina     (dina),
      .douta         (douta),
      .parity_err    (parity_err)//at rd_clk
);   
      
`endif

endmodule