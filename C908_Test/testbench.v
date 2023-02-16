`timescale 1ns/100ps

module cpu_tb();
reg cpu_clk;
reg cpu_rst;

always #5 cpu_clk = ~cpu_clk;

initial begin
    cpu_clk <= 0;
    cpu_rst <= 0;
    # 20; //异步复位
    cpu_rst <= 1;
    # 200
    $finish;
end

soc inst_cpu(
    .b_pad_gpio_porta(),
    .i_pad_clk(cpu_clk),
    .i_pad_jtg_tclk(),
    .i_pad_jtg_tdi(),
    .i_pad_jtg_tms(),
    .i_pad_jtg_trst_b(),
    .i_pad_rst_b(cpu_rst),
    .i_pad_uart0_sin(),
    .o_pad_jtg_tdo(),
    .o_pad_uart0_sout()
);

endmodule