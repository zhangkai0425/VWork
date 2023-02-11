### C908 Test Code File List

```bash
+ DW
+ PIC
--------pic_top.v			# top file for pic
--------pic_gated_clk_cell.v
--------pic_mux_cell.v
--------pic_sync_dff.v
+ TDT
--------tdt_dmi_top.v              	# top file for tdt_dmi
--------tdt_dmi_gated_clk_cell.v
--------tdt_dmi_mux_cell.v
--------tdt_dmi_sync_dff.v
soc.v                              	# top file for CPU soc
###
module soc{
	module tdt_dmi_top;
		// TDT/tdt_dmi_top.v
	module pic_top;
		// PIC/pic_top.v
	module C908_sub_system;
		// C908_sub_system.v
		// -------- pc_mp_top.v
 		// -------- pc_mp_top.v
	module axi_interconnect128;
	module axi_fifo;
	module IRAM;
	module axi_err128(1);
	module axi2ahb;
	module axi_err128(2);
	module ahb;
	module mem_ctrl;
	module apb;
	module err_gen;
}
###




```
