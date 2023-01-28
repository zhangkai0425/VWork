问题1：

用AXI替换AHB协议，是否原来的AQE_AHB模块需要重写

问题2：

PXIE直接发送isa_data即instruction信号到CPU的IRAM里，但是似乎其他的data都是SRAM里，也就是写到AHB总线中，这个是为啥呢？我看E906同时有指令和数据接口，所以iram就是指令接口吗？数据接口为啥没用呢？AHB的系统接口又是什么意思呢？

问题3：

E906中的数据总线接口到底是什么作用呢？

问题4：没看懂CPU是怎么用iram的信息的？

问题5：AHB和CPU系统总线接口的关系？
