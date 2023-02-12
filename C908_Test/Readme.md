### C908 Test Code File List

#### File List

```bash
+ CPU_FPGA
--------pc_mp_top.v			# top file for C908
--------pc_sysmap.vh
--------DW02_multp.v
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
+ uart
--------uart.v				# top file for uart
--------uart_apb_reg.v
--------uart_baud_gen.v
--------uart_ctrl.v
--------uart_receive.v
--------uart_trans.v
+ gpio
--------gpio.v
--------gpio_apbif.v
--------gpio_ctrl.v
+ pmu
--------pmu.v
--------px_had_sync.v
--------sync.v
--------tap2_sm.v
soc.v                              	# top file for CPU 
ahb.v
ahb2apb.v
apb_bridge.v
apb.v
axi_err128.v
axi_fifo_entry.v
axi_fifo.v
axi_interconnect128.v
axi2ahb.v
C908_sub_system.v
err_gen.v
f_spsram_32768x128.v
f_spsram_large.v
fifo_counter.v
IRAM.v
mem_ctrl.v
ram.v
timer.v
wid_entry.v
wid_for_axi4.v
unified_SPRAM.v
XPM_SPRAM_odd.v
Readme.md				# file list and architechture
```

#### Architechture

```
########
module soc{
	soc.v
	module tdt_dmi_top;
		// ./TDT
	module pic_top;
		// ./PIC
	module C908_sub_system;
		// C908_sub_system.v
		// -------- ./CPU_FPGA
 		// -------- wid_for_axi4.v
		// -------- wid_entry.v
	module axi_interconnect128;
		// axi_interconnect128.v
	module axi_fifo;
		// axi_fifo.v
		// -------- fifo_counter.v
		// -------- axi_fifo_entry.v
	module IRAM;
		// IRAM.v
		// -------- f_spsram_large.v
		// -------- ram.v
		// -------- unified_SPRAM.v
		// -------- XPM_SPRAM_odd.v
	module axi_err128(1);
	module axi_err128(2);
		// axi_err128.v
		// -------- f_spsram_32768x128.v
	module axi2ahb;
		// axi2ahb.v
	module ahb;
		// ahb.v
	module mem_ctrl;
		// mem_ctrl.v 
	module apb;
		// apb.v
		// -------- ahb2apb.v
		// -------- apb_bridge.v
		// -------- ./uart
		// -------- timer.v
		// -------- ./gpio
		// -------- ./pmu
	module err_gen;
		// err_gen.v
}
########
```
