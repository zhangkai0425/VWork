# CPU Reset 代码详解

#### 1.C++ API接口

`Driver/Driver_isa.cpp`代码修改自Line:1700-1919

主要增加了以下函数接口：

- `tc_cpu_pause`

发送数据给PXIE，实际转化成`pad_cpu_rst_b`信号操作，`pad_cpu_rst_b`低位时CPU暂停

```cpp
// CPU_PAUSE
// CPU_PAUSE = 0 / 1
Driver_tc bool tc_cpu_pause(char *subid, INT32 CPU_PAUSE)
{
	alignas(64) std::vector<uint64_t> write_data;
	write_data = {0xeb03000000000000 + CPU_PAUSE};
	size_t device_num;
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("tc_trig: Failed to find XDMA device!\r\n");
		}
		device_num = sizeof(device_paths);
		std::string ven_id = "ven_10ee";
		std::string dev_id = "dev_7014";
		std::string sub_id = "subsys_";
		char *id_num = new char[5];
		for (int i = 0; i < 4; i++)
		{
			id_num[i] = subid[i * 2];
		}
		id_num[4] = NULL;
		sub_id.append(id_num);
		sub_id.append("10ee");

		unsigned SN_id;
		unsigned SN_found = 0;
		for (unsigned i = 0; i < device_num; i++)
		{
			std::string::size_type if_venid = device_paths[i].find(ven_id);
			std::string::size_type if_devid = device_paths[i].find(dev_id);
			std::string::size_type if_subid = device_paths[i].find(sub_id);
			if (if_venid != std::string::npos && if_devid != std::string::npos && if_subid != std::string::npos)
			{
				// std::cout << "Find device of SN:" << ven_id << dev_id << sub_id << std::endl;
				SN_id = i;
				SN_found++;
				break;
			}
		}

		if (SN_found == 0)
		{
			throw std::runtime_error("tc_trig: Failure! No SN found!\r\n");
		}
		else
		{

			xdma_device dev(device_paths[SN_id]);
			// std::cout << device_paths[SN_id] << std::endl;
			// std::cout << write_data.size() * sizeof(uint64_t) << write_data.size() << "yyc" << std::endl;
			std::thread write_thread(write, std::ref(dev), (void *)write_data.data(), write_data.size() * sizeof(uint64_t), 1);
			write_thread.join();
		}
	}
	catch (const std::exception &e)
	{
		std::cout << e.what();
	}
	return true;
}
```

- `tc_isa_zero`

重写IRAM的函数，与之前重写地址相区分，从Address 0开始写

<!--此处不确定地址起始是否正确-->

```cpp
// ALL CHANGES HERE:
// function of tc_iram,but write data from addr = 0
Driver_tc bool tc_isa_zero(INT32 *data, INT16 num, char *subid)
{
	alignas(128) std::vector<uint32_t> write_data(8);
	write_data[0] = {0x00000000};
	write_data[1] = {0x00000000};
	write_data[2] = {0x00000000}; // 00000005 0000000a TODO:From Address 0?
	write_data[3] = {0xeb000000 + (int)ceil(num / 2)};
	write_data[4] = {0x00000000};
	write_data[5] = {0x00000000};
	write_data[6] = {0x00001000};
	write_data[7] = {0xeb9c0000};

	std::cout << "num = " << num << std::endl;
	std::cout << "data3 = " << write_data[3] << std::endl;
	write_data.insert(write_data.begin() + 8, data, data + num);
	std::cout << "data8 = " << write_data[8] << std::endl;
	std::cout << "data9 = " << write_data[9] << std::endl;
	std::cout << "data10 = " << write_data[10] << std::endl;

	size_t device_num;
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("tc_isa: Failed to find XDMA device!\r\n");
		}
		device_num = sizeof(device_paths);
		std::string ven_id = "ven_10ee";
		std::string dev_id = "dev_7014";
		std::string sub_id = "subsys_";
		char *id_num = new char[5];
		for (int i = 0; i < 4; i++)
		{
			id_num[i] = subid[i * 2];
		}
		id_num[4] = NULL;
		sub_id.append(id_num);
		sub_id.append("10ee");

		unsigned SN_id;
		unsigned SN_found = 0;
		for (unsigned i = 0; i < device_num; i++)
		{
			std::string::size_type if_venid = device_paths[i].find(ven_id);
			std::string::size_type if_devid = device_paths[i].find(dev_id);
			std::string::size_type if_subid = device_paths[i].find(sub_id);
			if (if_venid != std::string::npos && if_devid != std::string::npos && if_subid != std::string::npos)
			{
				// std::cout << "Find device of SN:" << ven_id << dev_id << sub_id << std::endl;
				SN_id = i;
				SN_found++;
				break;
			}
		}

		if (SN_found == 0)
		{
			throw std::runtime_error("tc_isa: Failure! No SN found!\r\n");
		}
		else
		{

			xdma_device dev(device_paths[SN_id]);
			// std::cout << device_paths[SN_id] << std::endl;
			// std::cout << write_data.size() * sizeof(uint64_t) << write_data.size() << "yyc" << std::endl;
			std::thread write_thread(write, std::ref(dev), (void *)write_data.data(), write_data.size() * sizeof(uint32_t), 1);
			write_thread.join();
		}
	}
	catch (const std::exception &e)
	{
		std::cout << e.what();
	}
	return true;
}
```

- `tc_iram_reset`

调用`tc_isa_zero`函数重写IRAM

```cpp
//function of tc_iram_reset()
Driver_tc bool tc_iram_reset(char* subid)
{
	//iram reset data:num = 30
	INT32 data[] = {
		0x40000337,
		0x00130313,
		0x00100E13,
		0x00032383,
		0xFFC398E3,
		0x00010001,
		0x00010001,
		0x00010001,
		0x00010001,
		0x00010001,
		0x00010001,
		0x00010001,
		0x00010001,
		0x00010001,
		0x00010001,
		0x00010001,
		0x00010001,
		0x00010001,
		0x00010001,
		0x00010001,
		0x00010001,
		0x00010001,
		0x00010001,
		0x00010001,
		0x00010001,
		0x00010001,
		0x00010001,
		0x00010001,
		0x00010001,
		0x00010001
	};
	//Call function tc_isa() to write iram
	auto complete = tc_isa_zero(data,sizeof(data)/sizeof(data[0]),subid);
	//completed
	return complete;
}
```

- `tc_sram_reset`

重写SRAM的函数

```cpp
// function of tc_sram_reset()
Driver_tc bool tc_sram_reset(char* subid){
	//sram reset data:num = 12
	INT32 data[] = {
		0x00000000,
		0x00000000,
		0x00000000,
		0x00000000,
		0x00000000,
		0x00000000,
		0x00000000,
		0x00000000,
		0x00000000,
		0x00000000,
		0x00000000,
		0x00000000
	};
	//Call function tc_sram() to write sram
	auto complete = tc_sram(data,sizeof(data)/sizeof(data[0]),subid);
	//completed
	return complete;
}
```

- `tc_cpu_rst`

总的函数，负责暂停CPU，重写IRAM和SRAM，恢复CPU运行

```cpp
Driver_tc bool tc_cpu_rst(char* subid){
	//Call function tc_cpu_pause to pause CPU
	auto complete0 = tc_cpu_pause(subid,1);
	//reset iram
	auto complete1 = tc_iram_reset(subid);
	//reset sram
	auto complete2 = tc_sram_reset(subid);
	//sleep for 1 seconds
	sleep(1000);
	//Call function tc_cpu_pause to begin CPU
	auto complete4 = tc_cpu_pause(subid, 0);
	return complete0 && complete1 && complete2 && complete4;
}
```



#### 2.PXIE_RX_DATA模块修改

修改主要用于支持C++ API接口向PXIE发送`pad_cpu_rst_b`对应的信号

具体修改见：

Line 42-44	Line 100-101	Line 251-253	Line 279	Line 293-300	Line 325	Line 348	Line 420	Line 437



#### 3.top.v模块修改

修改主要用于支持VIO测试：Line 218-22

PXIE输出：Line 245-247

跨区域时钟同步：Line 359-407

CPU模块reset信号：Line 413

AQE_AHB模块修改：Line 474

