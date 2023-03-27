`include "CBB_define.v"

 
module unified_TDPRAM #(
        parameter MEMORY_PRIMITIVE = "auto",   //"auto","block","distributed","ultra"
        parameter CLOCKING_MODE = "common_clock",  
        parameter MEMORY_INIT_FILE = "none",      // String
        parameter BYTE_WRITE_EN = 0,      // DECIMAL
        parameter READ_LATENCY_A = 1,
        parameter READ_LATENCY_B = 1,
        parameter ADDR_WIDTH_A = 32,
        parameter ADDR_WIDTH_B = 32,
        parameter WRITE_DATA_WIDTH_A = 32,        // DECIMAL
        parameter WRITE_DATA_WIDTH_B = 32,        // DECIMAL
        parameter READ_DATA_WIDTH_A  = 32,
        parameter READ_DATA_WIDTH_B  = 32
	)
   (
          rsta     , rstb     , clka,
          wea,  
          ena,   
          addra,
          dina      , douta      , clkb     ,   addrb     , dinb      ,
          web     ,
          enb       ,  doutb      ,  parity_err  
    );   
       
       
       
       localparam WE_WIDTH_A   = BYTE_WRITE_EN ? WRITE_DATA_WIDTH_A/8 : 1;
       localparam WE_WIDTH_B   = BYTE_WRITE_EN ? WRITE_DATA_WIDTH_B/8 : 1;
    
          input                            rsta     ; 
          input                            rstb     ; 
          input                            clka     ;
          input  [WE_WIDTH_A-1:0]          wea      ;
          input                            ena       ;
          input  [ADDR_WIDTH_A-1:0]        addra     ;
          input  [WRITE_DATA_WIDTH_A-1:0]  dina      ;
          output [READ_DATA_WIDTH_A-1:0]   douta     ;
         
          input                            clkb     ;
          input  [ADDR_WIDTH_B-1:0]        addrb     ;
          input  [WRITE_DATA_WIDTH_B-1:0]  dinb      ;
          input  [WE_WIDTH_B-1:0]          web     ;
          input                            enb       ;
          output [READ_DATA_WIDTH_B-1:0]   doutb      ;
          output                           parity_err ;//at rd_clk

`ifdef ASIC

`elsif INTEL

`else   
XPM_TDPRAM_odd  #(
        .MEMORY_PRIMITIVE(MEMORY_PRIMITIVE),   //"auto","block","distributed","ultra"
        .CLOCKING_MODE(CLOCKING_MODE),  
        .MEMORY_INIT_FILE(MEMORY_INIT_FILE),      // String
        .BYTE_WRITE_EN(BYTE_WRITE_EN),
        .READ_LATENCY_A(READ_LATENCY_A),
        .READ_LATENCY_B(READ_LATENCY_B),
        .ADDR_WIDTH_A(ADDR_WIDTH_A),
        .ADDR_WIDTH_B(ADDR_WIDTH_B),
        .WRITE_DATA_WIDTH_A(WRITE_DATA_WIDTH_A),        // DECIMAL
        .WRITE_DATA_WIDTH_B(WRITE_DATA_WIDTH_B),        // DECIMAL
        .READ_DATA_WIDTH_A(READ_DATA_WIDTH_A),
        .READ_DATA_WIDTH_B(READ_DATA_WIDTH_B)
	)
    XPM_TDPRAM_odd(
      .rsta     (rsta), 
      .rstb     (rstb), 
      .clka     (clka),
      .wea      (wea),
      .ena      (ena),
      .addra    (addra),
      .dina     (dina),
      .douta    (douta),
      .clkb     (clkb),
      .addrb    (addrb),
      .dinb     (dinb),
      .web      (web),
      .enb      (enb),
      .doutb     (doutb),
      .parity_err  (parity_err)//at rd_clk
); 
`endif

endmodule