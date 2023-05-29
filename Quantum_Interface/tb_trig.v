
`timescale 1ns/100ps

`define CLK_PERIOD          10
`define TCLK_PERIOD         40
`define MAX_RUN_TIME        32'h3000000

`define CPU_TOP             tb_trig.x_tc.system_c908_inst.x_cpu_sub_system
`define tb_retire0          `CPU_TOP.core0_pad_retire0
`define retire0_pc          `CPU_TOP.core0_pad_retire0_pc[39:0]
`define tb_retire1          `CPU_TOP.core0_pad_retire1
`define retire1_pc          `CPU_TOP.core0_pad_retire1_pc[39:0]
`define CPU_CLK             `CPU_TOP.pll_cpu_clk
`define CPU_RST             `CPU_TOP.pad_cpu_rst_b
`define clk_en              `CPU_TOP.axim_clk_en

// `define APB_BASE_ADDR       40'h4000000000
`define APB_BASE_ADDR       40'hb0000000

`define SYS_CLK_PERIOD          20
`define LOC_CLK_PERIOD          10

module tb_trig();
  reg clk;
  reg sys_clk;
  reg loc_clk;
  wire sys_clk_p;
  wire sys_clk_n;
  // CLK generate
  initial
  begin
    clk =0;
    forever begin
      #(`CLK_PERIOD/2) clk = ~clk;
    end
  end
  initial
  begin
    sys_clk =0;
    forever begin
      #(`SYS_CLK_PERIOD/2) sys_clk = ~sys_clk;
    end
  end
  initial
  begin
    loc_clk =0;
    forever begin
      #(`LOC_CLK_PERIOD/2) loc_clk = ~loc_clk;
    end
  end
  reg cpu_rst;
  // CPU reset signal
  initial
  begin
    cpu_rst = 1;
    #100;
    cpu_rst = 0;
    #100;
    cpu_rst = 1;
  end
  integer FILE;
  initial
  begin
  #(`MAX_RUN_TIME * `CLK_PERIOD);
    $display("**********************************************");
    $display("*   meeting max simulation time, stop!       *");
    $display("**********************************************");
    FILE = $fopen("run_case.report","w");
    $fwrite(FILE,"TEST FAIL");   
  $finish;
  end
  // generate clk signal

  OBUFDS #(
          .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
          .SLEW("SLOW")           // Specify the output slew rate
  ) OBUFDS_inst (
          .O(sys_clk_p),     // Diff_p output (connect directly to top-level port)
          .OB(sys_clk_n),   // Diff_n output (connect directly to top-level port)
          .I(sys_clk)      // Buffer input
  );
  wire [16:0] O_star;
  AQTC_top x_tc(
    .I_PXIE_Rxp     (                   ),
    .I_PXIE_Rxn     (                   ),
    .I_PXIE_Rst_n   (                   ),
    .O_PXIE_Txp     (                   ),
    .O_PXIE_Txn     (                   ),
    .O_Dstarb_p     (                   ),
    .O_Dstarb_n     (                   ),
    .O_star         (O_star             ),
    .I_Dstarc_p     (                   ),
    .I_Dstarc_n     (                   ),
    // clk      
    .I_SYS_50mhz_p  ( sys_clk_p         ),
    .I_SYS_50mhz_n  ( sys_clk_n         ),
    .I_LOC_100mhz   ( loc_clk           ),
    .cpu_rst        ( cpu_rst           ),
    // PLL
    .O_lmk_resetn   (                   ),
    .O_lmk_sel      (                   ),
    .O_lmk_sclk     (                   ),
    .O_lmk_scs      (                   ),
    .O_lmk_sdio     (                   ),
    .O_lmk_sync     (                   ),
    .I_lmk_st0      (                   ),
    .I_lmk_st1      (                   )
  );

endmodule