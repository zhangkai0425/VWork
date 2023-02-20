### CPU仿真运行

1.运行hello_world case，得到inst.pat和data.pat内存文件，因为vivado打不开.pat，将其内容粘贴为.mem文件，可正常读取

2.testbench.v文件选择 `smart_run\logical\tb`下的 `tb.v`，原文件为system verilog，不能直接在vivado上运行，因此修改 `bit`数据类型为 `reg`，且 `static integer` 改为 `integer`

3.其他RTL文件按模块组织整理

4.运行行为前仿，得到仿真波形
