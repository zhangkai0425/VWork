// dllmain.cpp : Defines the entry point for the DLL application.
#include "pch.h"
#define Driver_ad extern "C" _declspec(dllexport)
#define Driver_awg extern "C" _declspec(dllexport)
#define Driver_tc extern "C" _declspec(dllexport)

BOOL APIENTRY DRIVER_ELEC( HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
                     )
{
    switch (ul_reason_for_call)
    {
    case DLL_PROCESS_ATTACH:
    case DLL_THREAD_ATTACH:
    case DLL_THREAD_DETACH:
    case DLL_PROCESS_DETACH:
        break;
    }
    return TRUE;
}

#include <array>
#include <algorithm>
#include <iostream>
#include <fstream>
#include <sstream>
#include <iomanip>
#include <numeric>
#include <string>
#include <system_error>
#include <thread>
#include <vector>
#include <map>
#include <bitset>
#include <time.h>
#include <future>   
#include <typeinfo> 
#include <atomic>
#include <condition_variable>
#include <chrono>
#define NOMINMAX
#include <Windows.h>
#include <SetupAPI.h>
#include <INITGUID.H>
#include "xdma_public.h"
//#include <float.h>
#pragma comment(lib, "setupapi.lib")

// ============= Static Utility Functions =====================================

static std::vector<std::string> get_device_paths(GUID guid) {

	auto device_info = SetupDiGetClassDevs((LPGUID)&guid, NULL, NULL, DIGCF_PRESENT | DIGCF_DEVICEINTERFACE);
	if (device_info == INVALID_HANDLE_VALUE) {
		throw std::runtime_error("GetDevices INVALID_HANDLE_VALUE");
	}

	SP_DEVICE_INTERFACE_DATA device_interface = { 0 };
	device_interface.cbSize = sizeof(SP_DEVICE_INTERFACE_DATA);

	// enumerate through devices

	std::vector<std::string> device_paths;

	for (unsigned index = 0;
		SetupDiEnumDeviceInterfaces(device_info, NULL, &guid, index, &device_interface);
		++index) {

		// get required buffer size
		unsigned long detailLength = 0;
		if (!SetupDiGetDeviceInterfaceDetail(device_info, &device_interface, NULL, 0, &detailLength, NULL) && GetLastError() != ERROR_INSUFFICIENT_BUFFER) {
			throw std::runtime_error("SetupDiGetDeviceInterfaceDetail - get length failed");
		}

		// allocate space for device interface detail
		auto dev_detail = reinterpret_cast<PSP_DEVICE_INTERFACE_DETAIL_DATA>(new char[detailLength]);
		dev_detail->cbSize = sizeof(SP_DEVICE_INTERFACE_DETAIL_DATA);

		// get device interface detail
		if (!SetupDiGetDeviceInterfaceDetail(device_info, &device_interface, dev_detail, detailLength, NULL, NULL)) {
			delete[] dev_detail;
			throw std::runtime_error("SetupDiGetDeviceInterfaceDetail - get detail failed");
		}
		device_paths.emplace_back(dev_detail->DevicePath);
		delete[] dev_detail;
	}

	SetupDiDestroyDeviceInfoList(device_info);

	return device_paths;
}

inline static uint32_t bit(uint32_t n) {
	return (1 << n);
}

inline static bool is_bit_set(uint32_t x, uint32_t n) {
	return (x & bit(n)) == bit(n);
}

// ============= windows device handle  =======================================
struct device_file {
	HANDLE h;
	device_file(const std::string& path, DWORD accessFlags);
	~device_file();

	void seek(long device_offset);
	size_t write(void* buffer, size_t size);
	size_t read(void* buffer, size_t size);
};

device_file::device_file(const std::string& path, DWORD accessFlags) {
	h = CreateFile(path.c_str(), accessFlags, 0, NULL, OPEN_EXISTING,
		FILE_ATTRIBUTE_NORMAL, NULL);
}

device_file::~device_file() {
	CloseHandle(h);
}

void device_file::seek(long device_offset) {
	if (INVALID_SET_FILE_POINTER == SetFilePointer(h, device_offset, NULL, FILE_BEGIN)) {
		throw std::runtime_error("SetFilePointer failed: " + std::to_string(GetLastError()));
	}
}

size_t device_file::write(void* buffer, size_t size) {
	unsigned long num_bytes_written;
	if (!WriteFile(h, buffer, (DWORD)size, &num_bytes_written, NULL)) {
		throw std::runtime_error("Failed to write to device! " + std::to_string(GetLastError()));
	}

	return num_bytes_written;
}

size_t device_file::read(void* buffer, size_t size) {
	unsigned long num_bytes_read;
	if (!ReadFile(h, buffer, (DWORD)size, &num_bytes_read, NULL)) {
		throw std::runtime_error("Failed to read from stream! " + std::to_string(GetLastError()));
	}
	return num_bytes_read;
}

// ============ XDMA device ===================================================

class xdma_device {
public:
	xdma_device(const std::string& device_path);
	bool is_axi_st();
	// transfer data from Host PC to FPGA Card using SGDMA engine
	size_t write_to_engine(void* buffer, size_t size);

	// transfer data from FPGA Card to Host PC using SGDMA engine
	size_t read_from_engine(void* buffer, size_t size);
private:
	device_file control;
	device_file h2c0;
	device_file c2h0;
	uint32_t read_register(long addr);

};

xdma_device::xdma_device(const std::string& device_path) :
	control(device_path + "\\control", GENERIC_READ | GENERIC_WRITE),
	h2c0(device_path + "\\h2c_0", GENERIC_WRITE),
	c2h0(device_path + "\\c2h_0", GENERIC_READ) {
	//std::cout << std::hex << "h2c_0=0x" << read_register(0x0) << ", c2h_0=0x" << read_register(0x1000) << "\n";

	if (!is_bit_set(read_register(0x0), 15) || !is_bit_set(read_register(0x1000), 15)) {
		throw std::runtime_error("XDMA engines h2c_0 and/or c2h_0 are not streaming engines!");
	}
}

uint32_t xdma_device::read_register(long addr) {
	uint32_t value = 0;
	size_t num_bytes_read;
	if (INVALID_SET_FILE_POINTER == SetFilePointer(control.h, addr, NULL, FILE_BEGIN)) {
		throw std::runtime_error("SetFilePointer failed: " + std::to_string(GetLastError()));
	}
	if (!ReadFile(control.h, (LPVOID)&value, 4, (LPDWORD)&num_bytes_read, NULL)) {
		throw std::runtime_error("ReadFile failed:" + std::to_string(GetLastError()));
	}
	return value;
}

size_t xdma_device::write_to_engine(void* buffer, size_t size) {
	unsigned long num_bytes_written;
	if (!WriteFile(h2c0.h, buffer, (DWORD)size, &num_bytes_written, NULL)) {
		throw std::runtime_error("Failed to write to stream! " + std::to_string(GetLastError()));
	}

	return num_bytes_written;
}

size_t xdma_device::read_from_engine(void* buffer, size_t size) {
	unsigned long num_bytes_read;	if (!ReadFile(c2h0.h, buffer, (DWORD)size, &num_bytes_read, NULL)) {
		std::cout << "throw from 'read from engine'" << std::endl;
		throw std::runtime_error("Failed to read from stream! " + std::to_string(GetLastError()));
	}
	return num_bytes_read;
}

bool xdma_device::is_axi_st() {
	return is_bit_set(read_register(0x0), 15);
}

// ======================= main ===============================================

static constexpr size_t dma_block_size = 0x4000 * 64; // 0x1000: 4Kb 
static constexpr size_t array_size = dma_block_size / sizeof(uint32_t);
static constexpr size_t cmd_size = 0x14000;
static constexpr size_t array_cmd_size = cmd_size / sizeof(uint32_t);
static bool err = false;
int flag = 0;
int flag_throw = 0;
uint64_t* rowdata;
std::thread* read_thread = NULL;
std::map< unsigned, xdma_device* > dev_map;

bool read(xdma_device& dev, void* buffer, const size_t size, const size_t block_size = 4096) {
	flag = 0;
	//std::cout << "flag throw: " << flag_throw << std::endl;
	size_t bytes_remaining = size;
	try {
		//std::cout << "started reading " << size << " bytes" << std::endl;
		while (bytes_remaining > 0) {
			if (flag_throw == 1) {
				if (rowdata != NULL) {
					free(rowdata);
					rowdata = NULL;
				}
				flag_throw = 0;
				return FALSE;
			}
			const size_t offset = size - bytes_remaining;
			const size_t bytes_to_read = bytes_remaining < block_size ? bytes_remaining : block_size;
			//std::cout << "bytes_to_read " << bytes_to_read << std::endl;
			bytes_remaining -= dev.read_from_engine((char*)buffer + offset, bytes_to_read);
			//std::cout << "finished reading " << size - bytes_remaining << " bytes" << std::endl;
		}
	}
	catch (const std::exception & e) {
		err = true;
		std::cout << e.what();
	}
	//std::cout << "finished reading " << size - bytes_remaining << " bytes" << std::endl;
	flag = 1;
	return TRUE;
}

void write(xdma_device& dev, void* buffer, const size_t size, const size_t chunks = 1) {

	const size_t chunk_size = size / chunks;

	if (size % chunks != 0) {
		throw std::runtime_error("size not evenly divisible by chunks!");
	}

	size_t bytes_written = 0;
	try {
		for (unsigned i = 0; i < chunks; ++i) {
			bytes_written += dev.write_to_engine((char*)buffer + (i * chunk_size), chunk_size);

		}
	}
	catch (const std::exception & e) {
		err = true;
		std::cout << e.what();
	}
	//std::cout << "finished writing " << bytes_written << " bytes" << std::endl;
}

void do_transfers_in_parallel(unsigned index, device_file& h2c, device_file& c2h,
	std::vector<uint32_t>& h2c_data,
	std::vector<uint32_t>& c2h_data) {

	std::cout << "    Initiating H2C_" << index << " transfer of " << h2c_data.size() * sizeof(uint32_t) << " bytes...\r\n";
	std::thread read_thread(&device_file::write, &h2c, (void*)h2c_data.data(),
		h2c_data.size() * sizeof(uint32_t));
	std::cout << "    Initiating C2H_" << index << " transfer of " << c2h_data.size() * sizeof(uint32_t) << " bytes...\r\n";
	std::thread write_thread(&device_file::read, &c2h, (void*)c2h_data.data(),
		c2h_data.size() * sizeof(uint32_t));
	read_thread.join();
	write_thread.join();
}

void do_transfers_in_sequence(unsigned index, device_file& h2c, device_file& c2h,
	std::array<uint32_t, array_size>& h2c_data,
	std::array<uint32_t, array_size>& c2h_data) {

	std::cout << "    Initiating H2C_" << index << " transfer of " << h2c_data.size() * sizeof(uint32_t) << " bytes...\r\n";
	h2c.write(h2c_data.data(), h2c_data.size() * sizeof(uint32_t));
	std::cout << "    Initiating C2H_" << index << " transfer of " << c2h_data.size() * sizeof(uint32_t) << " bytes...\r\n";
	c2h.read(c2h_data.data(), c2h_data.size() * sizeof(uint32_t));
}

void H2C_in_parallel(unsigned index, device_file& h2c, std::vector<uint32_t>& h2c_data)
{
	std::cout << "    Initiating H2C_" << index << " transfer of " << h2c_data.size() * sizeof(uint32_t) << " bytes...\r\n";
	std::thread read_thread(&device_file::write, &h2c, (void*)h2c_data.data(), h2c_data.size() * sizeof(uint32_t));
	read_thread.join();
}

void C2H_in_parallel(unsigned index, device_file& c2h, std::vector<uint32_t>& c2h_data)
{
	std::cout << "    Initiating C2H_" << index << " transfer of " << c2h_data.size() * sizeof(uint32_t) << " bytes...\r\n";
	std::thread write_thread(&device_file::read, &c2h, (void*)c2h_data.data(), c2h_data.size() * sizeof(uint32_t));
	write_thread.join();
}

bool h2c_pcie(std::vector<uint32_t> h2c_data,std::string ven_id, std::string dev_id, std::string sub_id) {
	size_t device_num;
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("Failed to find XDMA device!\r\n");
		}
		device_num = sizeof(device_paths);

		unsigned SN_id;
		unsigned SN_found = 0;
		for (unsigned i = 0; i < device_num; i++)
		{
			std::string::size_type if_venid = device_paths[i].find(ven_id);
			std::string::size_type if_devid = device_paths[i].find(dev_id);
			std::string::size_type if_subid = device_paths[i].find(sub_id);
			if (if_venid != std::string::npos && if_devid != std::string::npos && if_subid != std::string::npos)
			{
				SN_id = i;
				SN_found++;
				break;
			}
		}
		if (SN_found == 0)
		{
			throw std::runtime_error("Failure! Please check SN or PXIe device!\r\n");
		}
		else
		{
			xdma_device dev(device_paths[SN_id]);
			std::thread write_thread(write, std::ref(dev), (void*)h2c_data.data(), h2c_data.size() * sizeof(uint32_t), 1);
			write_thread.join();
		}
	}
	catch (const std::exception & e)
	{
		std::cout << e.what();
	}
	return true;
}

Driver_ad std::vector<std::string> device_id()
{
	size_t device_num;
	std::vector<std::string> device_paths;
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("device_id: Failed to find XDMA device!\r\n");
		}
		device_num =  sizeof(device_paths);
	}
	catch (const std::exception & e)
	{
		std::cout << e.what();
	}
	return device_paths;
}

Driver_ad bool ad_cfg(int cycle, int length, int delay, char* subid)
{
	size_t device_num;
	size_t length_t = length; //2048
	alignas(128) std::vector<uint32_t> write_data(128);
	alignas(128) std::vector<uint32_t> start_data(128);
	write_data[0] = (length_t << 14) + cycle + 0x40000000;
	write_data[1] = 0xa0000000;
	write_data[2] = { 0x00000000 };
	write_data[3] = { 0x00000000 };
	write_data[4] = delay + 0xa0000000;
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("ad_cfg: Failed to find XDMA device!\r\n");
		}
		device_num = sizeof(device_paths);
		std::string ven_id = "ven_10ee";
		std::string dev_id = "dev_7024";
		std::string sub_id = "subsys_";
		char* id_num = new char[5];
		for (int i = 0; i<4; i++)
		{
			id_num[i] = subid[i*2];
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
				SN_id = i;
				SN_found++;
				break;
			}
		}
		if (SN_found == 0)
		{
			throw std::runtime_error("ad_cfg: Failure! Please check SN or PXIe device!\r\n");
		}
		else
		{
			xdma_device dev(device_paths[SN_id]);
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint32_t), 1);
			write_thread.join();
			Sleep(1);
		}
	}
	catch (const std::exception & e)
	{
		std::cout << e.what();
	}
	return true;
}

Driver_ad bool switch_cfg(int length, int delay, char* subid)
{
	size_t device_num;
	size_t length_t = length; //2048
	alignas(128) std::vector<uint32_t> write_data(128);
	alignas(128) std::vector<uint32_t> start_data(128);
	write_data[0] = length + 0xa0000000 + (0b10 << 20);
	write_data[1] = { 0x00000000 };
	write_data[2] = { 0x00000000 };
	write_data[3] = { 0x00000000 };
	write_data[4] = delay + 0xa0000000 + (0b01<<20);
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("ad_cfg: Failed to find XDMA device!\r\n");
		}
		device_num = sizeof(device_paths);
		std::string ven_id = "ven_10ee";
		std::string dev_id = "dev_7024";
		std::string sub_id = "subsys_";
		char* id_num = new char[5];
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
				SN_id = i;
				SN_found++;
				break;
			}
		}
		if (SN_found == 0)
		{
			throw std::runtime_error("ad_cfg: Failure! Please check SN or PXIe device!\r\n");
		}
		else
		{
			xdma_device dev(device_paths[SN_id]);
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint32_t), 1);
			write_thread.join();
			Sleep(1);
		}
	}
	catch (const std::exception & e)
	{
		std::cout << e.what();
	}
	return true;
}

Driver_ad bool ad_IQ(UINT32 I0, UINT32 Q0, UINT32 I1, UINT32 Q1, char* subid)
{
	size_t device_num;
	alignas(128) std::vector<uint32_t> write_data(128);
	write_data[0] = 0x50000000 + (I0 & 0x0000ffff);
	write_data[1] = 0x50010000 + (I0 >> 16);
	write_data[2] = 0x50020000 + (Q0 & 0x0000ffff);
	write_data[3] = 0x50030000 + (Q0 >> 16);
	write_data[4] = 0x50040000 + (I1 & 0x0000ffff);
	write_data[5] = 0x50050000 + (I1 >> 16);
	write_data[6] = 0x50060000 + (Q1 & 0x0000ffff);
	write_data[7] = 0x50070000 + (Q1 >> 16);
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("ad_cfg: Failed to find XDMA device!\r\n");
		}
		device_num = sizeof(device_paths);
		std::string ven_id = "ven_10ee";
		std::string dev_id = "dev_7024";
		std::string sub_id = "subsys_";
		char* id_num = new char[5];
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
				SN_id = i;
				SN_found++;
				break;
			}
		}
		if (SN_found == 0)
		{
			throw std::runtime_error("ad_cfg: Failure! Please check SN or PXIe device!\r\n");
		}
		else
		{
			xdma_device dev(device_paths[SN_id]);
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint32_t), 1);
			write_thread.join();
			Sleep(1);
		}
	}
	catch (const std::exception & e)
	{
		std::cout << e.what();
	}
	return true;
}

Driver_ad bool ad_cal(int ch1_offset, int ch2_offset, int ch3_offset, int ch4_offset, char* subid)
{
	size_t device_num;
	alignas(128) std::vector<uint32_t> write_data(128);
	write_data[0] = 0x60020000+ ch1_offset;
	write_data[1] = 0x600a0000+ ch2_offset;
	write_data[2] = 0x70020000+ ch3_offset;
	write_data[3] = 0x70020000+ ch4_offset;
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("ad_cfg: Failed to find XDMA device!\r\n");
		}
		device_num = sizeof(device_paths);
		std::string ven_id = "ven_10ee";
		std::string dev_id = "dev_7024";
		std::string sub_id = "subsys_";
		char* id_num = new char[5];
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
				SN_id = i;
				SN_found++;
				break;
			}
		}
		if (SN_found == 0)
		{
			throw std::runtime_error("ad_cfg: Failure! Please check SN or PXIe device!\r\n");
		}
		else
		{
			xdma_device dev(device_paths[SN_id]);
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint32_t), 1);
			write_thread.join();
			Sleep(1);
		}
	}
	catch (const std::exception & e)
	{
		std::cout << e.what();
	}
	return true;
}

Driver_ad bool ad_mode(int datamode,char* subid,int fre,int isa_vld=0)
{
	//mode=0:rowdata; mode=1:modulation
	size_t device_num;
	alignas(128) std::vector<uint32_t> write_data(128);
	write_data[0] = datamode + 0xe0000000 + (isa_vld<<8);
	write_data[1] = ceil(fre/1e5) + 0x80000000;
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("ad_mode: Failed to find XDMA device!\r\n");
		}
		if (datamode != 0 && datamode != 1)
		{
			throw std::runtime_error("Datamode is out of range! 0:rowdata 1:IQdata\r\n");
		}
		device_num = sizeof(device_paths);
		std::string ven_id = "ven_10ee";
		std::string dev_id = "dev_7024";
		std::string sub_id = "subsys_";
		char* id_num = new char[5];
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
				SN_id = i;
				SN_found++;
				break;
			}
		}

		if (SN_found == 0)
		{
			throw std::runtime_error("ad_mode: Failure! Please check SN or PXIe device!\r\n");
		}
		else
		{
			xdma_device dev(device_paths[SN_id]);
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint32_t), 1);
			write_thread.join();
			//Sleep(1);
		}
	}
	catch (const std::exception & e)
	{
		std::cout << e.what();
	}
	return true;
}

// debug api
Driver_ad bool ad_testmode(char* subid)
{
	size_t device_num;
	alignas(128) std::vector<uint32_t> write_data(128);
	write_data[0] = 0x60003010;
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("Failed to find XDMA device!\r\n");
		}
		device_num = sizeof(device_paths);
		std::cout << "Find " << device_num << "XDMA devices! " << std::endl;
		std::string ven_id = "ven_10ee";
		std::string dev_id = "dev_7024";
		std::string sub_id = "subsys_";
		char* id_num = new char[5];
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
				std::cout << "Find device of SN: " << ven_id << dev_id << sub_id << std::endl;
				SN_id = i;
				SN_found++;
				break;
			}
		}

		if (SN_found == 0)
		{
			throw std::runtime_error("Failure! No SN found!\r\n");
		}
		else
		{
			xdma_device dev(device_paths[SN_id]);
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint32_t), 1);
			write_thread.join();
			Sleep(1);
		}
	}
	catch (const std::exception & e)
	{
		std::cout << e.what();
	}
	return true;
}
// debug api
Driver_ad bool ad_pllrst(char* subid)
{
	size_t device_num;
	alignas(128) std::vector<uint32_t> write_data(128);
	write_data[0] = 0xc0000000;
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("Failed to find XDMA device!\r\n");
		}
		device_num = sizeof(device_paths);
		std::cout << "Find " << device_num << "XDMA devices! " << std::endl;
		std::string ven_id = "ven_10ee";
		std::string dev_id = "dev_7024";
		std::string sub_id = "subsys_";
		char* id_num = new char[5];
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
				std::cout << "Find device of SN: " << ven_id << dev_id << sub_id << std::endl;
				SN_id = i;
				SN_found++;
				break;
			}
		}

		if (SN_found == 0)
		{
			throw std::runtime_error("Failure! No SN found!\r\n");
		}
		else
		{
			xdma_device dev(device_paths[SN_id]);
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint32_t), 1);
			write_thread.join();
			Sleep(1);
		}
	}
	catch (const std::exception & e)
	{
		std::cout << e.what();
	}
	return true;
}
// debug api
Driver_ad bool ad_normalmode(char* subid)
{
	size_t device_num;
	alignas(128) std::vector<uint32_t> write_data(128);
	write_data[0] = 0x60002010;
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("Failed to find XDMA device!\r\n");
		}
		device_num = sizeof(device_paths);
		std::cout << "Find " << device_num << "XDMA devices! " << std::endl;
		std::string ven_id = "ven_10ee";
		std::string dev_id = "dev_7024";
		std::string sub_id = "subsys_";
		char* id_num = new char[5];
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
				std::cout << "Find device of SN: " << ven_id << dev_id << sub_id << std::endl;
				SN_id = i;
				SN_found++;
				break;
			}
		}

		if (SN_found == 0)
		{
			throw std::runtime_error("Failure! No SN found!\r\n");
		}
		else
		{
			xdma_device dev(device_paths[SN_id]);
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint32_t), 1);
			write_thread.join();
			Sleep(1);
		}
	}
	catch (const std::exception & e)
	{
		std::cout << e.what();
	}
	return true;
}

Driver_ad uint64_t*ad_malloc(int cycle, int length)
{
	rowdata = (uint64_t*)malloc(length * 8 * cycle);
	return rowdata;
}

Driver_ad bool ad_free(uint64_t* addr)
{
	if (rowdata != NULL) {
		free(rowdata);
		rowdata = NULL;
	}
	//std::cout << "cache free. " << std::endl;
	return true;
}

Driver_ad bool ad_start(int cycle, int length, char* subid, uint64_t* addr, int mode)
{
	size_t device_num;
	size_t array_size;
	size_t block_num;
	if (mode == 1)
	{
		array_size = 64 * cycle / sizeof(uint32_t);
		block_num = 64;
	}
	else
	{
		array_size = length * 8 * cycle / sizeof(uint32_t);
		block_num = length * 8 * 32;
	}
	alignas(128) std::vector<uint32_t> start_data(128);
	start_data[0] = { 0x30000001 };
	UINT32 nId;
	const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
	if (device_paths.empty())
	{
		throw std::runtime_error("ad_start: Failed to find XDMA device!\r\n");
	}
	device_num = sizeof(device_paths);

	std::string ven_id = "ven_10ee";
	std::string dev_id = "dev_7024";
	std::string sub_id = "subsys_";
	char* id_num = new char[5];
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
			SN_id = i;
			SN_found++;
			break;
		}
	}
	try
	{
		if (SN_found == 0)
		{
			throw std::runtime_error("ad_start: Failure! Please check SN or PXIe device!\r\n");
		}
		else
		{
			xdma_device* dev;
			dev = new xdma_device(device_paths[SN_id]);

			std::thread start_thread(write, std::ref(*dev), (void*)start_data.data(), start_data.size() * sizeof(uint32_t), 1);
			start_thread.join();
			
			read_thread = new std::thread(read, std::ref(*dev), (void*)addr, array_size * sizeof(uint32_t), block_num);
			read_thread->detach();
		}
	}
	catch (const std::exception & e)
	{
		std::cout << "Exception:" << e.what();
	}
	return true;
}

Driver_ad bool ad_done(int timeout)
{
	time_t time_inil, time_now;
	time_inil = clock();
	bool err = FALSE;
	while (flag == 0)   
	{
		std::this_thread::sleep_for(std::chrono::milliseconds(20));
		time_now = clock();
		if ((time_now - time_inil) / CLOCKS_PER_SEC >= timeout / 1000) {
			return err;
		}
	}
	err = TRUE;
	return err;
}

Driver_ad void ad_stop()
{
	flag_throw = 0;
	if (flag == 0)
	{
		flag_throw = 1;
	}
}

Driver_ad unsigned long int* ad_readout(int cycle, int length, int timeout, char* subid)
{
	size_t device_num;
	size_t array_size = length * cycle * 8 / sizeof(uint32_t);
	alignas(128) std::vector<uint32_t> start_data(128);
	start_data[0] = { 0x30000001 };
	unsigned long int* rowdata;
	rowdata = (unsigned long int*)malloc(length * cycle * 8); //length=2048 cycle=2000 repeat=4
	const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
	if (device_paths.empty())
	{
		throw std::runtime_error("ad_readout: Failed to find XDMA device!\r\n");
	}
	device_num = sizeof(device_paths);

	std::string ven_id = "ven_10ee";
	std::string dev_id = "dev_7024";
	std::string sub_id = "subsys_";
	char* id_num = new char[5];
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
			SN_id = i;
			SN_found++;
			break;
		}
	}

	if (SN_found == 0)
	{
		throw std::runtime_error("ad_readout: Failure! Please check SN or PXIe device!\r\n");
	}
	else
	{

		xdma_device dev(device_paths[SN_id]);
		std::thread read_thread(read, std::ref(dev), (void*)rowdata, array_size * sizeof(uint32_t), length * 8 * 32);
		std::thread start_thread(write, std::ref(dev), (void*)start_data.data(), start_data.size() * sizeof(uint32_t), 1);
		start_thread.join();
		read_thread.join();
		//TODO�� timeout
		auto future = std::async(std::launch::async, &std::thread::join, &read_thread);
		if (future.wait_for(std::chrono::milliseconds(timeout)) == std::future_status::timeout) {
			/* --- Do something, if thread has not terminated within 2 s. --- */
			std::cout << "Time out! " << std::endl;
			exit(1);
		}
	}
	return rowdata;
}

Driver_ad bool ad_offsetcali(int ch1_cali, int ch2_cali, int ch3_cali, int ch4_cali, char* subid)
{
	size_t device_num;
	alignas(128) std::vector<uint32_t> cali_add_1(128);
	alignas(128) std::vector<uint32_t> cali_minus_1(128);
	alignas(128) std::vector<uint32_t> cali_add_2(128);
	alignas(128) std::vector<uint32_t> cali_minus_2(128);
	alignas(128) std::vector<uint32_t> cali_add_3(128);
	alignas(128) std::vector<uint32_t> cali_minus_3(128);
	alignas(128) std::vector<uint32_t> cali_add_4(128);
	alignas(128) std::vector<uint32_t> cali_minus_4(128);
	cali_add_1[0] = 0x60020000+abs(ch1_cali);
	cali_add_2[0] = 0x600a0000+ abs(ch2_cali);
	cali_add_3[0] = 0x70020000+ abs(ch3_cali);
	cali_add_4[0] = 0x700a0000+ abs(ch4_cali);
	cali_minus_1[0] = 0x60021000 + abs(ch1_cali);
	cali_minus_2[0] = 0x600a1000 + abs(ch2_cali);
	cali_minus_3[0] = 0x70021000 + abs(ch3_cali);
	cali_minus_4[0] = 0x700a1000 + abs(ch4_cali);
	
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("ad_offsetcali: Failed to find XDMA device!\r\n");
		}
		device_num = sizeof(device_paths);
		std::string ven_id = "ven_10ee";
		std::string dev_id = "dev_7024";
		std::string sub_id = "subsys_";
		char* id_num = new char[5];
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
				SN_id = i;
				SN_found++;
				break;
			}
		}

		if (SN_found == 0)
		{
			throw std::runtime_error("ad_offsetcali: Failure! Please check SN or PXIe device!\r\n");
		}
		else
		{
			xdma_device dev(device_paths[SN_id]);
			if (ch1_cali >=0)
			{
				std::thread addoffset_thread(write, std::ref(dev), (void*)cali_add_1.data(), cali_add_1.size() * sizeof(uint32_t), 1);
				addoffset_thread.join();
			}
			if (ch1_cali <0)
			{
				std::thread minusoffset_thread(write, std::ref(dev), (void*)cali_minus_1.data(), cali_minus_1.size() * sizeof(uint32_t), 1);
				minusoffset_thread.join();
			}
			if (ch2_cali < 0)
			{
				std::thread addoffset_thread(write, std::ref(dev), (void*)cali_add_2.data(), cali_add_2.size() * sizeof(uint32_t), 1);
				addoffset_thread.join();
			}
			if (ch2_cali >= 0)
			{
				std::thread minusoffset_thread(write, std::ref(dev), (void*)cali_minus_2.data(), cali_minus_2.size() * sizeof(uint32_t), 1);
				minusoffset_thread.join();
			}
			if (ch3_cali >= 0)
			{
				std::thread addoffset_thread(write, std::ref(dev), (void*)cali_add_3.data(), cali_add_3.size() * sizeof(uint32_t), 1);
				addoffset_thread.join();
			}
			if (ch3_cali < 0)
			{
				std::thread minusoffset_thread(write, std::ref(dev), (void*)cali_minus_3.data(), cali_minus_3.size() * sizeof(uint32_t), 1);
				minusoffset_thread.join();
			}
			if (ch4_cali < 0)
			{
				std::thread addoffset_thread(write, std::ref(dev), (void*)cali_add_4.data(), cali_add_4.size() * sizeof(uint32_t), 1);
				addoffset_thread.join();
			}
			if (ch4_cali >= 0)
			{
				std::thread minusoffset_thread(write, std::ref(dev), (void*)cali_minus_4.data(), cali_minus_4.size() * sizeof(uint32_t), 1);
				minusoffset_thread.join();
			}
		}
	}
	catch (const std::exception & e)
	{
		std::cout << e.what();
	}
	return true;
}

std::vector<uint32_t> read_file(char* config_path) {
	std::vector<uint32_t> cmd(array_cmd_size);
	for (int j = 0; j < array_cmd_size; j++) {
		cmd[j] = 0;
	}
	std::string line;
	int i = 0;
	const char* config_file_buff;
	std::ifstream config_file_fd(config_path);
	if (config_file_fd) {
		while (getline(config_file_fd, line)) {
			config_file_buff = line.data();
			sscanf_s(config_file_buff, "%X", &cmd[i]);
			i++;
		}
	}
	return cmd;
}

Driver_tc bool tc_stop(char* subid)
{
	alignas(64) std::vector<uint64_t> write_data;
	write_data = { 0xeb9c000000000001 };
	size_t device_num;
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("tc_stop: Failed to find XDMA device!\r\n");
		}

		device_num = sizeof(device_paths);
		std::string ven_id = "ven_10ee";
		std::string dev_id = "dev_7014";
		std::string sub_id = "subsys_";
		char* id_num = new char[5];
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
				//std::cout << "Find device of SN:" << ven_id << dev_id << sub_id << std::endl;
				SN_id = i;
				SN_found++;
				break;
			}
		}

		if (SN_found == 0)
		{
			throw std::runtime_error("tc_stop: Failure! No SN found!\r\n");

		}
		else

		{
			xdma_device dev(device_paths[SN_id]);
			//std::cout << device_paths[SN_id] << std::endl;
			//std::cout << write_data.size() * sizeof(uint64_t) << write_data.size() << "yyc" << std::endl;
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint64_t), 1);
			write_thread.join();
		}
	}
	catch (const std::exception & e)
	{
		std::cout << e.what();
	}
	return true;
}

Driver_tc bool tc_trig(char* subid)
{
	alignas(64) std::vector<uint64_t> write_data;
	write_data = { 0xeb9c000000000002 };
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
		char* id_num = new char[5];
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
				//std::cout << "Find device of SN:" << ven_id << dev_id << sub_id << std::endl;
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
			//std::cout << device_paths[SN_id] << std::endl;
			//std::cout << write_data.size() * sizeof(uint64_t) << write_data.size() << "yyc" << std::endl;
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint64_t), 1);
			write_thread.join();
		}
	}
	catch (const std::exception & e)
	{
		std::cout << e.what();
	}
	return true;
}

Driver_tc bool tc_trig128(char* subid)
{
	alignas(128) std::vector<uint64_t> write_data(2);
	write_data[0] = { 0xeb9c000000000002 };
	write_data[1] = { 0xeb9c000000000002 };
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
		char* id_num = new char[5];
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
				//std::cout << "Find device of SN:" << ven_id << dev_id << sub_id << std::endl;
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
			//std::cout << device_paths[SN_id] << std::endl;
			//std::cout << write_data.size() * sizeof(uint64_t) << write_data.size() << "yyc" << std::endl;
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint64_t), 1);
			write_thread.join();
		}
	}
	catch (const std::exception & e)
	{
		std::cout << e.what();
	}
	return true;
}

Driver_tc bool tc_cfg(INT32 step, INT32 num, char* subid)
{
	alignas(64) std::vector<uint64_t> write_data(2);
	//write_data = { 0xeb9c000300000000 + step + (num << 16) };
	write_data[0] = { 0xeb9c000300000000 + num};
	write_data[1] = { 0xeb9c000400000000 + step };
	size_t device_num;
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("tc_cfg: Failed to find XDMA device!\r\n");
		}
		device_num = sizeof(device_paths);
		std::string ven_id = "ven_10ee";
		std::string dev_id = "dev_7014";
		std::string sub_id = "subsys_";
		char* id_num = new char[5];
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
				//std::cout << "Find device of SN:" << ven_id << dev_id << sub_id << std::endl;
				SN_id = i;
				SN_found++;
				break;
			}
		}

		if (SN_found == 0)
		{
			throw std::runtime_error("tc_cfg: Failure! No SN found!\r\n");

		}
		else
		{

			xdma_device dev(device_paths[SN_id]);
			//std::cout << device_paths[SN_id] << std::endl;
			//std::cout << write_data.size() * sizeof(uint64_t) << write_data.size() << "yyc" << std::endl;
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint64_t), 1);
			write_thread.join();
		}
	}
	catch (const std::exception & e)
	{
		std::cout << e.what();
	}
	return true;
}

Driver_tc bool tc_sram(INT32* data, INT16 num, char* subid)
{
	alignas(128) std::vector<uint32_t> write_data(8);
	write_data[0] = { 0x00000000 };
	write_data[1] = { 0x00000000 };
	write_data[2] = { 0x00000000 }; //00000006
	write_data[3] = { 0xeb010000 + (int)ceil(num / 2) };
	write_data[4] = { 0x00000000 };
	write_data[5] = { 0x00000000 };
	write_data[6] = { 0x00001001 };
	write_data[7] = { 0xeb9c0000 };

	std::cout << "num = " << num << std::endl;
	std::cout << "data3 = " << write_data[3] << std::endl;
	write_data.insert(write_data.begin() + 8, data, data + num);
	std::cout << "data3 = " << write_data[8] << std::endl;
	std::cout << "data3 = " << write_data[9] << std::endl;
	std::cout << "data3 = " << write_data[10] << std::endl;


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
		char* id_num = new char[5];
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
				//std::cout << "Find device of SN:" << ven_id << dev_id << sub_id << std::endl;
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
			//std::cout << device_paths[SN_id] << std::endl;
			//std::cout << write_data.size() * sizeof(uint64_t) << write_data.size() << "yyc" << std::endl;
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint32_t), 1);
			write_thread.join();
		}
	}
	catch (const std::exception & e)
	{
		std::cout << e.what();
	}
	return true;
}

Driver_tc uint64_t* tc_malloc(int length)
{
	rowdata = (uint64_t*)malloc(length * 32);
	return rowdata;
}

Driver_tc bool tc_free(uint64_t* addr)
{
	if (rowdata != NULL) {
		free(rowdata);
		rowdata = NULL;
	}
	std::cout << "cache free. " << std::endl;
	return true;
}

Driver_tc bool tc_fetch(INT16 addr, INT16 length, uint64_t* xdma_addr, char* subid)
{
	alignas(128) std::vector<uint32_t> write_data(8);
	write_data[0] = { 0x00000000 };
	write_data[1] = { 0x00000000 };
	write_data[2] = addr + (length << 16);
	write_data[3] = { 0xeb020000 };
	write_data[4] = { 0x00000000 };
	write_data[5] = { 0x00000000 };
	write_data[6] = { 0x00001010 };
	write_data[7] = { 0xeb9c0000 };
	std::cout << "addr+length<<16 = " << write_data[2] << std::endl;
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
		char* id_num = new char[5];
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
				//std::cout << "Find device of SN:" << ven_id << dev_id << sub_id << std::endl;
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

			read_thread = new std::thread(read, std::ref(dev), (void*)xdma_addr, length * sizeof(uint32_t), 1024);
			read_thread->detach();
			std::cout << "xdma addr= " << xdma_addr << std::endl;
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint32_t), 1);
			write_thread.join();
			

		}
	}
	catch (const std::exception & e)
	{
		std::cout << e.what();
	}
	return true;
}

Driver_tc bool tc_isa(INT32* data, INT16 num, char* subid)
{
	alignas(128) std::vector<uint32_t> write_data(8);
	write_data[0] = { 0x00000000 };
	write_data[1] = { 0x00000000 };
	write_data[2] = { 0x00000005 }; //00000005 0000000a
	write_data[3] = { 0xeb000000 + (int)ceil(num/2)};
	write_data[4] = { 0x00000000 };
	write_data[5] = { 0x00000000 };
	write_data[6] = { 0x00001000 };
	write_data[7] = { 0xeb9c0000 };

	std::cout << "num = "<< num << std::endl;
	std::cout << "data3 = " << write_data[3] << std::endl;
	write_data.insert(write_data.begin() + 8, data, data + num);
	std::cout << "data3 = " << write_data[8] << std::endl;
	std::cout << "data3 = " << write_data[9] << std::endl;
	std::cout << "data3 = " << write_data[10] << std::endl;


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
		char* id_num = new char[5];
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
				//std::cout << "Find device of SN:" << ven_id << dev_id << sub_id << std::endl;
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
			//std::cout << device_paths[SN_id] << std::endl;
			//std::cout << write_data.size() * sizeof(uint64_t) << write_data.size() << "yyc" << std::endl;
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint32_t), 1);
			write_thread.join();
		}
	}
	catch (const std::exception & e)
	{
		std::cout << e.what();
	}
	return true;
}

Driver_tc bool tc_isa_run(char* subid)
{
	alignas(64) std::vector<uint64_t> write_data;
	write_data = { 0xeb9c000000001100 };
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
		char* id_num = new char[5];
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
				//std::cout << "Find device of SN:" << ven_id << dev_id << sub_id << std::endl;
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
			//std::cout << device_paths[SN_id] << std::endl;
			//std::cout << write_data.size() * sizeof(uint64_t) << write_data.size() << "yyc" << std::endl;
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint64_t), 1);
			write_thread.join();
		}
	}
	catch (const std::exception & e)
	{
		std::cout << e.what();
	}
	return true;
}

Driver_awg bool awg_delay(INT32 delay, INT16 port, char* subid)
{
	alignas(128) std::vector<uint32_t> write_data(4);
	write_data[0] = delay;
	write_data[1] = { 0x00000000 };
	write_data[2] = 0x00000000 + (port << 16);
	write_data[3] = { 0xcceb0000 };
	size_t device_num;
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("awg_delay: Failed to find XDMA device!\r\n");
		}
		device_num = sizeof(device_paths);
		std::string ven_id = "ven_10ee";
		std::string dev_id = "dev_8024";
		std::string sub_id = "subsys_";
		char* id_num = new char[5];
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
				//std::cout << "Find device of SN:" << ven_id << dev_id << sub_id << std::endl;
				SN_id = i;
				SN_found++;
				break;
			}
		}

		if (SN_found == 0)
		{
			throw std::runtime_error("awg_delay: Failure! No SN found!\r\n");

		}
		else
		{

			xdma_device dev(device_paths[SN_id]);
			//std::cout << device_paths[SN_id] << std::endl;
			//std::cout << write_data.size() * sizeof(uint64_t) << write_data.size() << "yyc" << std::endl;
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint32_t), 1);
			write_thread.join();
		}
	}
	catch (const std::exception & e)
	{
		std::cout << e.what();
	}
	return true;
}


Driver_awg bool awg_multi_IIR_coefficient(INT32* coefficient_1x, INT32* coefficient_2x, INT32* coefficient_3x, INT32* coefficient_4x, INT32* coefficient_5x, int port, char* subid)
{
	alignas(128) std::vector<uint32_t> write_data(80);

	int count = 0;

	for (int j = 0; j <= 3; j++) {
		write_data[0 + count] = 0x00000000 + (coefficient_1x[1 + 4 * j] << 16) + (coefficient_1x[0 + 4 * j]);
		write_data[1 + count] = 0x00000000 + (coefficient_1x[3 + 4 * j] << 16) + (coefficient_1x[2 + 4 * j]);
		write_data[2 + count] = 0x00000000 + (j);
		write_data[3 + count] = 0x12bc0000 + (1 << 8) + (port);
		count = count + 4;
	}

	for (int j = 0; j <= 3; j++) {
		write_data[0 + count] = 0x00000000 + (coefficient_2x[1 + 4 * j] << 16) + (coefficient_2x[0 + 4 * j]);
		write_data[1 + count] = 0x00000000 + (coefficient_2x[3 + 4 * j] << 16) + (coefficient_2x[2 + 4 * j]);
		write_data[2 + count] = 0x00000000 + (j);
		write_data[3 + count] = 0x12bc0000 + (2 << 8) + (port);
		count = count + 4;
	}

	for (int j = 0; j <= 3; j++) {
		write_data[0 + count] = 0x00000000 + (coefficient_3x[1 + 4 * j] << 16) + (coefficient_3x[0 + 4 * j]);
		write_data[1 + count] = 0x00000000 + (coefficient_3x[3 + 4 * j] << 16) + (coefficient_3x[2 + 4 * j]);
		write_data[2 + count] = 0x00000000 + (j);
		write_data[3 + count] = 0x12bc0000 + (3 << 8) + (port);
		count = count + 4;
	}

	for (int j = 0; j <= 3; j++) {
		write_data[0 + count] = 0x00000000 + (coefficient_4x[1 + 4 * j] << 16) + (coefficient_4x[0 + 4 * j]);
		write_data[1 + count] = 0x00000000 + (coefficient_4x[3 + 4 * j] << 16) + (coefficient_4x[2 + 4 * j]);
		write_data[2 + count] = 0x00000000 + (j);
		write_data[3 + count] = 0x12bc0000 + (4 << 8) + (port);
		count = count + 4;
	}

	for (int j = 0; j <= 3; j++) {
		write_data[0 + count] = 0x00000000 + (coefficient_5x[1 + 4 * j] << 16) + (coefficient_5x[0 + 4 * j]);
		write_data[1 + count] = 0x00000000 + (coefficient_5x[3 + 4 * j] << 16) + (coefficient_5x[2 + 4 * j]);
		write_data[2 + count] = 0x00000000 + (j);
		write_data[3 + count] = 0x12bc0000 + (5 << 8) + (port);
		count = count + 4;
	}

	size_t device_num;
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("awg_sendwavedata: Failed to find XDMA device!\r\n");
		}
		device_num = sizeof(device_paths);
		std::string ven_id = "ven_10ee";
		std::string dev_id = "dev_8024";
		std::string sub_id = "subsys_";
		char* id_num = new char[5];
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
				//std::cout << "Find device of SN:" << ven_id << dev_id << sub_id << std::endl;
				SN_id = i;
				SN_found++;
				break;
			}
		}

		if (SN_found == 0)
		{
			throw std::runtime_error("awg_sendwavedata: Failure! No SN found!\r\n");

		}
		else
		{

			xdma_device dev(device_paths[SN_id]);
			//std::cout << device_paths[SN_id] << std::endl;
			//std::cout << write_data.size() * sizeof(uint64_t) << write_data.size() << "yyc" << std::endl;
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint32_t), 1);
			write_thread.join();
		}
	}
	catch (const std::exception& e)
	{
		std::cout << e.what();
	}
	return true;
}



Driver_awg bool awg_trig_mask(char* subid, INT16 ch1_trig, INT16 ch2_trig, INT16 ch3_trig, INT16 ch4_trig)
{
	alignas(128) std::vector<uint32_t> write_data(4);
	write_data[0] = 0x00000000 + (ch1_trig)+(ch2_trig << 1) + (ch3_trig << 2) + (ch4_trig << 3);
	write_data[1] = { 0x00000000 };
	write_data[2] = { 0x00000000 };
	write_data[3] = { 0xbc670000 };
	size_t device_num;
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("awg_delay: Failed to find XDMA device!\r\n");
		}
		device_num = sizeof(device_paths);
		std::string ven_id = "ven_10ee";
		std::string dev_id = "dev_8024";
		std::string sub_id = "subsys_";
		char* id_num = new char[5];
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
				//std::cout << "Find device of SN:" << ven_id << dev_id << sub_id << std::endl;
				SN_id = i;
				SN_found++;
				break;
			}
		}

		if (SN_found == 0)
		{
			throw std::runtime_error("awg_delay: Failure! No SN found!\r\n");

		}
		else
		{

			xdma_device dev(device_paths[SN_id]);
			//std::cout << device_paths[SN_id] << std::endl;
			//std::cout << write_data.size() * sizeof(uint64_t) << write_data.size() << "yyc" << std::endl;
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint32_t), 1);
			write_thread.join();
		}
	}
	catch (const std::exception& e)
	{
		std::cout << e.what();
	}
	return true;
}


Driver_awg bool awg_offset(INT16 v_offset, INT16 port, char* subid)
{
	alignas(128) std::vector<uint32_t> write_data(4);
	write_data[0] = v_offset;
	write_data[1] = { 0x00000000 };
	write_data[2] = { 0x00000000 };

	if (port == 1)
	{
		write_data[3] = { 0x1ceb0000 };
	}
	else if (port == 2)
	{
		write_data[3] = { 0x2ceb0000 };
	}
	else if (port == 3)
	{
		write_data[3] = { 0x3ceb0000 };
	}
	else if (port == 4)
	{
		write_data[3] = { 0x4ceb0000 };
	}
	else
	{
		write_data[3] = { 0x1ceb0000 };
	}

	size_t device_num;
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("awg_offset: Failed to find XDMA device!\r\n");
		}
		device_num = sizeof(device_paths);
		std::string ven_id = "ven_10ee";
		std::string dev_id = "dev_8024";
		std::string sub_id = "subsys_";
		char* id_num = new char[5];
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
				//std::cout << "Find device of SN:" << ven_id << dev_id << sub_id << std::endl;
				SN_id = i;
				SN_found++;
				break;
			}
		}

		if (SN_found == 0)
		{
			throw std::runtime_error("awg_offset: Failure! No SN found!\r\n");

		}
		else
		{

			xdma_device dev(device_paths[SN_id]);
			//std::cout << device_paths[SN_id] << std::endl;
			//std::cout << write_data.size() * sizeof(uint64_t) << write_data.size() << "yyc" << std::endl;
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint32_t), 1);
			write_thread.join();
		}
	}
	catch (const std::exception& e)
	{
		std::cout << e.what();
	}
	return true;
}


Driver_awg bool awg_multi_Channel_Delay(INT32 PXIE_Value_Delay_Dci1, INT32 PXIE_Value_Delay_Dci2, INT32 PXIE_Value_Delay_Dci3, INT32 PXIE_Value_Delay_Dci4, char* subid)
{
	alignas(128) std::vector<uint32_t> write_data(4);
	write_data[0] = 0x00000000 + (PXIE_Value_Delay_Dci1);
	write_data[1] = 0x00000000 + (PXIE_Value_Delay_Dci2);
	write_data[2] = 0x00000000 + (PXIE_Value_Delay_Dci3);
	write_data[3] = 0xac460000 + (PXIE_Value_Delay_Dci4);

	size_t device_num;
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("awg_delay: Failed to find XDMA device!\r\n");
		}
		device_num = sizeof(device_paths);
		std::string ven_id = "ven_10ee";
		std::string dev_id = "dev_8024";
		std::string sub_id = "subsys_";
		char* id_num = new char[5];
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
				//std::cout << "Find device of SN:" << ven_id << dev_id << sub_id << std::endl;
				SN_id = i;
				SN_found++;
				break;
			}
		}

		if (SN_found == 0)
		{
			throw std::runtime_error("awg_delay: Failure! No SN found!\r\n");

		}
		else
		{

			xdma_device dev(device_paths[SN_id]);
			//std::cout << device_paths[SN_id] << std::endl;
			//std::cout << write_data.size() * sizeof(uint64_t) << write_data.size() << "yyc" << std::endl;
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint32_t), 1);
			write_thread.join();
		}
	}
	catch (const std::exception& e)
	{
		std::cout << e.what();
	}
	return true;
}


Driver_awg bool awg_multi_Channel_Delay_Set(char* subid)
{
	alignas(128) std::vector<uint32_t> write_data(4);
	write_data[0] = { 0x00000000 };
	write_data[1] = { 0x00000000 };
	write_data[2] = { 0x00000000 };
	write_data[3] = { 0xcc460000 };

	size_t device_num;
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("awg_delay: Failed to find XDMA device!\r\n");
		}
		device_num = sizeof(device_paths);
		std::string ven_id = "ven_10ee";
		std::string dev_id = "dev_8024";
		std::string sub_id = "subsys_";
		char* id_num = new char[5];
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
				//std::cout << "Find device of SN:" << ven_id << dev_id << sub_id << std::endl;
				SN_id = i;
				SN_found++;
				break;
			}
		}

		if (SN_found == 0)
		{
			throw std::runtime_error("awg_delay: Failure! No SN found!\r\n");

		}
		else
		{

			xdma_device dev(device_paths[SN_id]);
			//std::cout << device_paths[SN_id] << std::endl;
			//std::cout << write_data.size() * sizeof(uint64_t) << write_data.size() << "yyc" << std::endl;
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint32_t), 1);
			write_thread.join();
		}
	}
	catch (const std::exception& e)
	{
		std::cout << e.what();
	}
	return true;
}

Driver_awg bool awg_multi_mixer_config(INT32 group, INT16 mixer, INT32* ram, INT32* port, char* subid)
{
	alignas(128) std::vector<uint32_t> write_data(4);
	write_data[0] = 0x00000000 + (mixer << 31) + (ram[0] << 12) + (ram[1] << 8) + (port[0] << 4) + (port[1]);
	write_data[1] = { 0x00000000 };
	write_data[2] = { 0x00000000 };
	write_data[3] = 0x16cb0000 + group;
	/*
	std::cout << "awg_multi_mixer_config_info begin" << std::endl;
	std::cout << "   write_data[3]: " << "0x" << std::setfill('0') << std::setw(8) << std::setbase(16) << write_data[3] << std::endl;
	std::cout << "   write_data[2]: " << "0x" << std::setfill('0') << std::setw(8) << std::setbase(16) << write_data[2] << std::endl;
	std::cout << "   write_data[1]: " << "0x" << std::setfill('0') << std::setw(8) << std::setbase(16) << write_data[1] << std::endl;
	std::cout << "   write_data[0]: " << "0x" << std::setfill('0') << std::setw(8) << std::setbase(16) << write_data[0] << std::endl;
	std::cout << "awg_multi_mixer_config_info end" << std::endl;
	*/
	size_t device_num;
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("awg_delay: Failed to find XDMA device!\r\n");
		}
		device_num = sizeof(device_paths);
		std::string ven_id = "ven_10ee";
		std::string dev_id = "dev_8024";
		std::string sub_id = "subsys_";
		char* id_num = new char[5];
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
				//std::cout << "Find device of SN:" << ven_id << dev_id << sub_id << std::endl;
				SN_id = i;
				SN_found++;
				break;
			}
		}

		if (SN_found == 0)
		{
			throw std::runtime_error("awg_delay: Failure! No SN found!\r\n");

		}
		else
		{

			xdma_device dev(device_paths[SN_id]);
			//std::cout << device_paths[SN_id] << std::endl;
			//std::cout << write_data.size() * sizeof(uint64_t) << write_data.size() << "yyc" << std::endl;
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint32_t), 1);
			write_thread.join();
		}
	}
	catch (const std::exception& e)
	{
		std::cout << e.what();
	}
	return true;
}


Driver_awg bool awg_multi_delay(INT32 delay, INT16 port, INT16 wave_id, char* subid)
{
	alignas(128) std::vector<uint32_t> write_data(4);
	write_data[0] = delay;
	write_data[1] = { 0x00000000 };
	write_data[2] = 0x00000000 + (wave_id << 16);
	write_data[3] = 0xcceb0000 + port;
	/*
	std::cout << "awg_multi_delay_info begin" << std::endl;
	std::cout << "   write_data[3]: " << "0x" << std::setfill('0') << std::setw(8) << std::setbase(16) << write_data[3] << std::endl;
	std::cout << "   write_data[2]: " << "0x" << std::setfill('0') << std::setw(8) << std::setbase(16) << write_data[2] << std::endl;
	std::cout << "   write_data[1]: " << "0x" << std::setfill('0') << std::setw(8) << std::setbase(16) << write_data[1] << std::endl;
	std::cout << "   write_data[0]: " << "0x" << std::setfill('0') << std::setw(8) << std::setbase(16) << write_data[0] << std::endl;
	std::cout << "awg_multi_delay_info end" << std::endl;
	*/
	size_t device_num;
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("awg_delay: Failed to find XDMA device!\r\n");
		}
		device_num = sizeof(device_paths);
		std::string ven_id = "ven_10ee";
		std::string dev_id = "dev_8024";
		std::string sub_id = "subsys_";
		char* id_num = new char[5];
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
				//std::cout << "Find device of SN:" << ven_id << dev_id << sub_id << std::endl;
				SN_id = i;
				SN_found++;
				break;
			}
		}

		if (SN_found == 0)
		{
			throw std::runtime_error("awg_delay: Failure! No SN found!\r\n");

		}
		else
		{

			xdma_device dev(device_paths[SN_id]);
			//std::cout << device_paths[SN_id] << std::endl;
			//std::cout << write_data.size() * sizeof(uint64_t) << write_data.size() << "yyc" << std::endl;
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint32_t), 1);
			write_thread.join();
		}
	}
	catch (const std::exception& e)
	{
		std::cout << e.what();
	}
	return true;
}

Driver_awg bool awg_multi_length(INT32 length, INT16 port, INT16 wave_id, char* subid)
{
	alignas(128) std::vector<uint32_t> write_data(4);
	write_data[0] = length;
	write_data[1] = { 0x00000000 };
	write_data[2] = 0x00000000 + (wave_id << 16);
	write_data[3] = 0xd1eb0000 + port;
	/*
	std::cout << "awg_multi_length_info begin" << std::endl;
	std::cout << "   write_data[3]: " << "0x" << std::setfill('0') << std::setw(8) << std::setbase(16) << write_data[3] << std::endl;
	std::cout << "   write_data[2]: " << "0x" << std::setfill('0') << std::setw(8) << std::setbase(16) << write_data[2] << std::endl;
	std::cout << "   write_data[1]: " << "0x" << std::setfill('0') << std::setw(8) << std::setbase(16) << write_data[1] << std::endl;
	std::cout << "   write_data[0]: " << "0x" << std::setfill('0') << std::setw(8) << std::setbase(16) << write_data[0] << std::endl;
	std::cout << "awg_multi_length_info end" << std::endl;
	*/
	size_t device_num;
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("awg_delay: Failed to find XDMA device!\r\n");
		}
		device_num = sizeof(device_paths);
		std::string ven_id = "ven_10ee";
		std::string dev_id = "dev_8024";
		std::string sub_id = "subsys_";
		char* id_num = new char[5];
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
				//std::cout << "Find device of SN:" << ven_id << dev_id << sub_id << std::endl;
				SN_id = i;
				SN_found++;
				break;
			}
		}

		if (SN_found == 0)
		{
			throw std::runtime_error("awg_delay: Failure! No SN found!\r\n");

		}
		else
		{

			xdma_device dev(device_paths[SN_id]);
			//std::cout << device_paths[SN_id] << std::endl;
			//std::cout << write_data.size() * sizeof(uint64_t) << write_data.size() << "yyc" << std::endl;
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint32_t), 1);
			write_thread.join();
		}
	}
	catch (const std::exception& e)
	{
		std::cout << e.what();
	}
	return true;
}

Driver_awg bool awg_multi_addr(INT32 addr, INT16 port, INT16 wave_id, char* subid)
{
	alignas(128) std::vector<uint32_t> write_data(4);
	write_data[0] = addr;
	write_data[1] = { 0x00000000 };
	write_data[2] = 0x00000000 + (wave_id << 16);
	write_data[3] = 0xf1eb0000 + port;
	/*
	std::cout << "awg_multi_addr_info begin" << std::endl;
	std::cout << "   write_data[3]: " << "0x" << std::setfill('0') << std::setw(8) << std::setbase(16) << write_data[3] << std::endl;
	std::cout << "   write_data[2]: " << "0x" << std::setfill('0') << std::setw(8) << std::setbase(16) << write_data[2] << std::endl;
	std::cout << "   write_data[1]: " << "0x" << std::setfill('0') << std::setw(8) << std::setbase(16) << write_data[1] << std::endl;
	std::cout << "   write_data[0]: " << "0x" << std::setfill('0') << std::setw(8) << std::setbase(16) << write_data[0] << std::endl;
	std::cout << "awg_multi_addr_info end" << std::endl;
	*/
	size_t device_num;
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("awg_delay: Failed to find XDMA device!\r\n");
		}
		device_num = sizeof(device_paths);
		std::string ven_id = "ven_10ee";
		std::string dev_id = "dev_8024";
		std::string sub_id = "subsys_";
		char* id_num = new char[5];
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
				//std::cout << "Find device of SN:" << ven_id << dev_id << sub_id << std::endl;
				SN_id = i;
				SN_found++;
				break;
			}
		}

		if (SN_found == 0)
		{
			throw std::runtime_error("awg_delay: Failure! No SN found!\r\n");

		}
		else
		{

			xdma_device dev(device_paths[SN_id]);
			//std::cout << device_paths[SN_id] << std::endl;
			//std::cout << write_data.size() * sizeof(uint64_t) << write_data.size() << "yyc" << std::endl;
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint32_t), 1);
			write_thread.join();
		}
	}
	catch (const std::exception& e)
	{
		std::cout << e.what();
	}
	return true;
}


Driver_awg bool awg_multi_wavenum(INT32 wavenum, INT16 port, char* subid)
{
	alignas(128) std::vector<uint32_t> write_data(4);
	write_data[0] = wavenum;
	write_data[1] = { 0x00000000 };
	write_data[2] = { 0x00000000 };
	write_data[3] = 0xa21b0000 + port;
	/*
	std::cout << "awg_multi_wavenum_info begin" << std::endl;
	std::cout << "   write_data[3]: " << "0x" << std::setfill('0') << std::setw(8) << std::setbase(16) << write_data[3] << std::endl;
	std::cout << "   write_data[2]: " << "0x" << std::setfill('0') << std::setw(8) << std::setbase(16) << write_data[2] << std::endl;
	std::cout << "   write_data[1]: " << "0x" << std::setfill('0') << std::setw(8) << std::setbase(16) << write_data[1] << std::endl;
	std::cout << "   write_data[0]: " << "0x" << std::setfill('0') << std::setw(8) << std::setbase(16) << write_data[0] << std::endl;
	std::cout << "awg_multi_wavenum_info end" << std::endl;
	*/
	size_t device_num;
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("awg_delay: Failed to find XDMA device!\r\n");
		}
		device_num = sizeof(device_paths);
		std::string ven_id = "ven_10ee";
		std::string dev_id = "dev_8024";
		std::string sub_id = "subsys_";
		char* id_num = new char[5];
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
				//std::cout << "Find device of SN:" << ven_id << dev_id << sub_id << std::endl;
				SN_id = i;
				SN_found++;
				break;
			}
		}

		if (SN_found == 0)
		{
			throw std::runtime_error("awg_delay: Failure! No SN found!\r\n");

		}
		else
		{

			xdma_device dev(device_paths[SN_id]);
			//std::cout << device_paths[SN_id] << std::endl;
			//std::cout << write_data.size() * sizeof(uint64_t) << write_data.size() << "yyc" << std::endl;
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint32_t), 1);
			write_thread.join();
		}
	}
	catch (const std::exception& e)
	{
		std::cout << e.what();
	}
	return true;
}


Driver_awg bool awg_multi_IQ_Correction_Amp(INT32 group, INT32 Epsilon_Amp_I, INT32 Epsilon_Amp_Q, char* subid)
{
	alignas(128) std::vector<uint32_t> write_data(4);
	write_data[0] = 0x00000000 + (Epsilon_Amp_I);
	write_data[1] = 0x00000000 + (Epsilon_Amp_Q);
	write_data[2] = { 0x00000000 };
	write_data[3] = 0x12ab0000 + group;

	size_t device_num;
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("awg_delay: Failed to find XDMA device!\r\n");
		}
		device_num = sizeof(device_paths);
		std::string ven_id = "ven_10ee";
		std::string dev_id = "dev_8024";
		std::string sub_id = "subsys_";
		char* id_num = new char[5];
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
				//std::cout << "Find device of SN:" << ven_id << dev_id << sub_id << std::endl;
				SN_id = i;
				SN_found++;
				break;
			}
		}

		if (SN_found == 0)
		{
			throw std::runtime_error("awg_delay: Failure! No SN found!\r\n");

		}
		else
		{

			xdma_device dev(device_paths[SN_id]);
			//std::cout << device_paths[SN_id] << std::endl;
			//std::cout << write_data.size() * sizeof(uint64_t) << write_data.size() << "yyc" << std::endl;
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint32_t), 1);
			write_thread.join();
		}
	}
	catch (const std::exception& e)
	{
		std::cout << e.what();
	}
	return true;
}


Driver_awg bool awg_multi_IQ_Correction_Phase(INT32 group, INT32 Delta_Phase_I, INT32 Delta_Phase_Q, char* subid)
{
	alignas(128) std::vector<uint32_t> write_data(4);
	write_data[0] = 0x00000000 + (Delta_Phase_I);
	write_data[1] = 0x00000000 + (Delta_Phase_Q);
	write_data[2] = { 0x00000000 };
	write_data[3] = 0x45ab0000 + group;

	size_t device_num;
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("awg_delay: Failed to find XDMA device!\r\n");
		}
		device_num = sizeof(device_paths);
		std::string ven_id = "ven_10ee";
		std::string dev_id = "dev_8024";
		std::string sub_id = "subsys_";
		char* id_num = new char[5];
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
				//std::cout << "Find device of SN:" << ven_id << dev_id << sub_id << std::endl;
				SN_id = i;
				SN_found++;
				break;
			}
		}

		if (SN_found == 0)
		{
			throw std::runtime_error("awg_delay: Failure! No SN found!\r\n");

		}
		else
		{

			xdma_device dev(device_paths[SN_id]);
			//std::cout << device_paths[SN_id] << std::endl;
			//std::cout << write_data.size() * sizeof(uint64_t) << write_data.size() << "yyc" << std::endl;
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint32_t), 1);
			write_thread.join();
		}
	}
	catch (const std::exception& e)
	{
		std::cout << e.what();
	}
	return true;
}


//Driver_awg bool awg_multi_frequency(INT32 frequency, INT16 port, char* subid)
Driver_awg bool awg_multi_frequency(INT32 frequency, INT16 port, char* subid)
{
	//�����Ƶ�ʵ�λΪ��MHz
	//�����Ƶ��Ҫת��ΪDDS���Խ����PINC
	INT32 PINC = (int)((frequency / 250000000.0) * pow(2.0, 24.0));
	alignas(128) std::vector<uint32_t> write_data(4);
	write_data[0] = 0x00000000 + PINC;
	write_data[1] = { 0x00000000 };
	write_data[2] = { 0x00000000 };
	write_data[3] = 0x31ef0000 + port;
	/*
	std::cout << "awg_multi_frequency_info begin" << std::endl;
	std::cout << "   write_data[3]: " << "0x" << std::setfill('0') << std::setw(8) << std::setbase(16) << write_data[3] << std::endl;
	std::cout << "   write_data[2]: " << "0x" << std::setfill('0') << std::setw(8) << std::setbase(16) << write_data[2] << std::endl;
	std::cout << "   write_data[1]: " << "0x" << std::setfill('0') << std::setw(8) << std::setbase(16) << write_data[1] << std::endl;
	std::cout << "   write_data[0]: " << "0x" << std::setfill('0') << std::setw(8) << std::setbase(16) << write_data[0] << std::endl;
	std::cout << "awg_multi_frequency_info end" << std::endl;
	*/
	size_t device_num;
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("awg_delay: Failed to find XDMA device!\r\n");
		}
		device_num = sizeof(device_paths);
		std::string ven_id = "ven_10ee";
		std::string dev_id = "dev_8024";
		std::string sub_id = "subsys_";
		char* id_num = new char[5];
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
				//std::cout << "Find device of SN:" << ven_id << dev_id << sub_id << std::endl;
				SN_id = i;
				SN_found++;
				break;
			}
		}

		if (SN_found == 0)
		{
			throw std::runtime_error("awg_delay: Failure! No SN found!\r\n");

		}
		else
		{

			xdma_device dev(device_paths[SN_id]);
			//std::cout << device_paths[SN_id] << std::endl;
			//std::cout << write_data.size() * sizeof(uint64_t) << write_data.size() << "yyc" << std::endl;
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint32_t), 1);
			write_thread.join();
		}
	}
	catch (const std::exception& e)
	{
		std::cout << e.what();
	}
	return true;
}


Driver_awg bool send_waveform_data(INT32* data, INT32 length, INT32 addr, INT16 port, char* subid)
{
	alignas(128) std::vector<uint32_t> write_data((length * 4) + 4);
	write_data[0] = length;
	write_data[1] = addr;
	write_data[2] = { 0x00000000 };
	write_data[3] = 0x9ceb0000 + port;

	//std::cout << "wave0=" << write_data[0] << std::endl;
	//std::cout << "wave1=" << write_data[2] << std::endl;


	for (int i = 0; i < length; i++)
	{
		write_data[4 * (i + 1) + 3] = data[8 * i + 7] + (data[8 * i + 6] << 16);
		write_data[4 * (i + 1) + 2] = data[8 * i + 5] + (data[8 * i + 4] << 16);
		write_data[4 * (i + 1) + 1] = data[8 * i + 3] + (data[8 * i + 2] << 16);
		write_data[4 * (i + 1)] = data[8 * i + 1] + (data[8 * i] << 16);
		//std::cout << "data=" << data[8 * i + 6] << std::endl;
		//std::cout << "data2i=" << data[8 * i + 7] << 16 << std::endl;
		//std::cout << "data2i=" << write_data[4 * (i + 1)] << std::endl;

	}
	//std::cout << "wave2=" << write_data[4] << std::endl;


	size_t device_num;
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("awg_sendwavedata: Failed to find XDMA device!\r\n");
		}
		device_num = sizeof(device_paths);
		std::string ven_id = "ven_10ee";
		std::string dev_id = "dev_8024";
		std::string sub_id = "subsys_";
		char* id_num = new char[5];
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
				//std::cout << "Find device of SN:" << ven_id << dev_id << sub_id << std::endl;
				SN_id = i;
				SN_found++;
				break;
			}
		}

		if (SN_found == 0)
		{
			throw std::runtime_error("awg_sendwavedata: Failure! No SN found!\r\n");

		}
		else
		{

			xdma_device dev(device_paths[SN_id]);
			//std::cout << device_paths[SN_id] << std::endl;
			//std::cout << write_data.size() * sizeof(uint64_t) << write_data.size() << "yyc" << std::endl;
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint32_t), 1);
			write_thread.join();
		}

	}
	catch (const std::exception& e)
	{
		std::cout << e.what();
	}
	return true;
}


Driver_awg bool awg_multi_trig(char* subid)
{
	alignas(128) std::vector<uint32_t> write_data(4);
	write_data[0] = { 0x00000000 };
	write_data[1] = { 0x00000000 };
	write_data[2] = { 0x00000000 };
	write_data[3] = { 0x76cb0000 };
	/*
	std::cout << "awg_multi_length_trig begin" << std::endl;
	std::cout << "   write_data[3]: " << "0x" << std::setfill('0') << std::setw(8) << std::setbase(16) << write_data[3] << std::endl;
	std::cout << "   write_data[2]: " << "0x" << std::setfill('0') << std::setw(8) << std::setbase(16) << write_data[2] << std::endl;
	std::cout << "   write_data[1]: " << "0x" << std::setfill('0') << std::setw(8) << std::setbase(16) << write_data[1] << std::endl;
	std::cout << "   write_data[0]: " << "0x" << std::setfill('0') << std::setw(8) << std::setbase(16) << write_data[0] << std::endl;
	std::cout << "awg_multi_length_trig end" << std::endl;
	*/
	size_t device_num;
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("awg_delay: Failed to find XDMA device!\r\n");
		}
		device_num = sizeof(device_paths);
		std::string ven_id = "ven_10ee";
		std::string dev_id = "dev_8024";
		std::string sub_id = "subsys_";
		char* id_num = new char[5];
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
				//std::cout << "Find device of SN:" << ven_id << dev_id << sub_id << std::endl;
				SN_id = i;
				SN_found++;
				break;
			}
		}

		if (SN_found == 0)
		{
			throw std::runtime_error("awg_delay: Failure! No SN found!\r\n");

		}
		else
		{

			xdma_device dev(device_paths[SN_id]);
			//std::cout << device_paths[SN_id] << std::endl;
			//std::cout << write_data.size() * sizeof(uint64_t) << write_data.size() << "yyc" << std::endl;
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint32_t), 1);
			write_thread.join();
		}
	}
	catch (const std::exception& e)
	{
		std::cout << e.what();
	}
	return true;
}



Driver_awg bool awg_multi_IIR_on(INT32 IIR_on, char* subid)
{
	alignas(128) std::vector<uint32_t> write_data(4);
	write_data[0] = 0x00000000 + IIR_on;
	write_data[1] = { 0x00000000 };
	write_data[2] = { 0x00000000 };
	write_data[3] = 0xbcff0000;
	size_t device_num;
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("awg_delay: Failed to find XDMA device!\r\n");
		}
		device_num = sizeof(device_paths);
		std::string ven_id = "ven_10ee";
		std::string dev_id = "dev_8024";
		std::string sub_id = "subsys_";
		char* id_num = new char[5];
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
				//std::cout << "Find device of SN:" << ven_id << dev_id << sub_id << std::endl;
				SN_id = i;
				SN_found++;
				break;
			}
		}

		if (SN_found == 0)
		{
			throw std::runtime_error("awg_delay: Failure! No SN found!\r\n");

		}
		else
		{

			xdma_device dev(device_paths[SN_id]);
			//std::cout << device_paths[SN_id] << std::endl;
			//std::cout << write_data.size() * sizeof(uint64_t) << write_data.size() << "yyc" << std::endl;
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint32_t), 1);
			write_thread.join();
		}
	}
	catch (const std::exception& e)
	{
		std::cout << e.what();
	}
	return true;
}

Driver_awg bool awg_multi_reset_IIR(INT32 reset_IIR, char* subid)
{
	alignas(128) std::vector<uint32_t> write_data(4);
	write_data[0] = 0x00000000 + reset_IIR;
	write_data[1] = { 0x00000000 };
	write_data[2] = { 0x00000000 };
	write_data[3] = 0xbcfe0000;
	size_t device_num;
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("awg_delay: Failed to find XDMA device!\r\n");
		}
		device_num = sizeof(device_paths);
		std::string ven_id = "ven_10ee";
		std::string dev_id = "dev_8024";
		std::string sub_id = "subsys_";
		char* id_num = new char[5];
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
				//std::cout << "Find device of SN:" << ven_id << dev_id << sub_id << std::endl;
				SN_id = i;
				SN_found++;
				break;
			}
		}

		if (SN_found == 0)
		{
			throw std::runtime_error("awg_delay: Failure! No SN found!\r\n");

		}
		else
		{

			xdma_device dev(device_paths[SN_id]);
			//std::cout << device_paths[SN_id] << std::endl;
			//std::cout << write_data.size() * sizeof(uint64_t) << write_data.size() << "yyc" << std::endl;
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint32_t), 1);
			write_thread.join();
		}
	}
	catch (const std::exception& e)
	{
		std::cout << e.what();
	}
	return true;
}


Driver_awg bool awg_cw_mode(INT16 mode, char* subid)
{
	alignas(128) std::vector<uint32_t> write_data(4);
	write_data[0] = mode;
	write_data[1] = { 0x00000000 };
	write_data[1] = { 0x00000000 };
	write_data[3] = { 0xaceb0000 };
	size_t device_num;
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("awg_cw_mode: Failed to find XDMA device!\r\n");
		}
		device_num = sizeof(device_paths);
		std::string ven_id = "ven_10ee";
		std::string dev_id = "dev_8024";
		std::string sub_id = "subsys_";
		char* id_num = new char[5];
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
				//std::cout << "Find device of SN:" << ven_id << dev_id << sub_id << std::endl;
				SN_id = i;
				SN_found++;
				break;
			}
		}

		if (SN_found == 0)
		{
			throw std::runtime_error("awg_cw_mode: Failure! No SN found!\r\n");

		}
		else
		{

			xdma_device dev(device_paths[SN_id]);
			//std::cout << device_paths[SN_id] << std::endl;
			//std::cout << write_data.size() * sizeof(uint64_t) << write_data.size() << "yyc" << std::endl;
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint32_t), 1);
			write_thread.join();
		}
	}
	catch (const std::exception & e)
	{
		std::cout << e.what();
	}
	return true;
}

Driver_awg bool awg_sync(char* subid)
{
	alignas(128) std::vector<uint32_t> write_data(4);
	write_data[0] = { 0x00000000 };
	write_data[1] = { 0x00000000 };
	write_data[2] = { 0xffff0000 };
	write_data[3] = { 0x9ceb0000 };
	size_t device_num;
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("awg_cw_mode: Failed to find XDMA device!\r\n");
		}
		device_num = sizeof(device_paths);
		std::string ven_id = "ven_10ee";
		std::string dev_id = "dev_8024";
		std::string sub_id = "subsys_";
		char* id_num = new char[5];
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
				//std::cout << "Find device of SN:" << ven_id << dev_id << sub_id << std::endl;
				SN_id = i;
				SN_found++;
				break;
			}
		}

		if (SN_found == 0)
		{
			throw std::runtime_error("awg_cw_mode: Failure! No SN found!\r\n");

		}
		else
		{

			xdma_device dev(device_paths[SN_id]);
			//std::cout << device_paths[SN_id] << std::endl;
			//std::cout << write_data.size() * sizeof(uint64_t) << write_data.size() << "yyc" << std::endl;
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint32_t), 1);
			write_thread.join();
		}
	}
	catch (const std::exception & e)
	{
		std::cout << e.what();
	}
	return true;
}

Driver_awg bool send_wave_data(INT32* data, INT16 length, INT16 port, char* subid)
{
	alignas(128) std::vector<uint32_t> write_data((length/2)+4);
	write_data[0] = { 0x00000000 };
	write_data[1] = { 0x00000000 };
	if (port == 1)
	{
		write_data[2] = { 0x01000000 };
	}
	else if (port == 2)
	{
		write_data[2] = { 0x02000000 };
	}
	else if (port == 3)
	{
		write_data[2] = { 0x03000000 };
	}
	else if (port == 4)
	{
		write_data[2] = { 0x04000000 };
	}

	write_data[3] = { 0x9ceb0000 };

	//std::cout << "wave0=" << write_data[0] << std::endl;
	//std::cout << "wave1=" << write_data[2] << std::endl;


	for (int i = 0; i < length / 8; i++)
	{
		write_data[4 * (i + 1)+3] = data[8 * i  + 7] + (data[8 * i +6] << 16);
		write_data[4 * (i + 1) + 2] = data[8 * i  + 5] + (data[8 * i +4] << 16);
		write_data[4 * (i + 1) + 1] = data[8 * i  + 3] + (data[8 * i  +2] << 16);
		write_data[4 * (i + 1) ] = data[8 * i+1] + (data[8 * i ] << 16);
		//std::cout << "data=" << data[8 * i + 6] << std::endl;
		//std::cout << "data2i=" << data[8 * i + 7] << 16 << std::endl;
		//std::cout << "data2i=" << write_data[4 * (i + 1)] << std::endl;

	}
	//std::cout << "wave2=" << write_data[4] << std::endl;


	size_t device_num;
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("awg_sendwavedata: Failed to find XDMA device!\r\n");
		}
		device_num = sizeof(device_paths);
		std::string ven_id = "ven_10ee";
		std::string dev_id = "dev_8024";
		std::string sub_id = "subsys_";
		char* id_num = new char[5];
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
				//std::cout << "Find device of SN:" << ven_id << dev_id << sub_id << std::endl;
				SN_id = i;
				SN_found++;
				break;
			}
		}

		if (SN_found == 0)
		{
			throw std::runtime_error("awg_sendwavedata: Failure! No SN found!\r\n");

		}
		else
		{

			xdma_device dev(device_paths[SN_id]);
			//std::cout << device_paths[SN_id] << std::endl;
			//std::cout << write_data.size() * sizeof(uint64_t) << write_data.size() << "yyc" << std::endl;
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint32_t), 1);
			write_thread.join();
		}
	}
	catch (const std::exception & e)
	{
		std::cout << e.what();
	}
	return true;
}

Driver_awg bool awg_load_length(INT32 load_length, INT16 port, char* subid)
{
	alignas(128) std::vector<uint32_t> write_data(4);
	write_data[0] = load_length;
	write_data[1] = { 0x00000000 };
	if (port == 1)
	{
		write_data[2] = { 0x00010000 };
	}
	else if (port == 2)
	{
		write_data[2] = { 0x00020000 };
	}
	else if (port == 3)
	{
		write_data[2] = { 0x00030000 };
	}
	else if (port == 4)
	{
		write_data[2] = { 0x00040000 };
	}
	else
	{
		write_data[2] = { 0x00000000 };
	}
	write_data[3] = { 0xeceb0000 };

	size_t device_num;
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("awg_load_length: Failed to find XDMA device!\r\n");
		}
		device_num = sizeof(device_paths);
		std::string ven_id = "ven_10ee";
		std::string dev_id = "dev_8024";
		std::string sub_id = "subsys_";
		char* id_num = new char[5];
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
				//std::cout << "Find device of SN:" << ven_id << dev_id << sub_id << std::endl;
				SN_id = i;
				SN_found++;
				break;
			}
		}

		if (SN_found == 0)
		{
			throw std::runtime_error("awg_load_length: Failure! No SN found!\r\n");

		}
		else
		{

			xdma_device dev(device_paths[SN_id]);
			//std::cout << device_paths[SN_id] << std::endl;
			//std::cout << write_data.size() * sizeof(uint64_t) << write_data.size() << "yyc" << std::endl;
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint32_t), 1);
			write_thread.join();
		}
	}
	catch (const std::exception & e)
	{
		std::cout << e.what();
	}
	return true;
}

Driver_awg bool awg_load_addr(INT32 load_addr, INT16 port, char* subid)
{
	alignas(128) std::vector<uint32_t> write_data(4);
	write_data[0] = load_addr;
	write_data[1] = { 0x00000000 };
	if (port == 1)
	{
		write_data[2] = { 0x00010000 };
	}
	else if (port == 2)
	{
		write_data[2] = { 0x00020000 };
	}
	else if (port == 3)
	{
		write_data[2] = { 0x00030000 };
	}
	else if (port == 4)
	{
		write_data[2] = { 0x00040000 };
	}
	else
	{
		write_data[2] = { 0x00000000 };
	}
	write_data[3] = { 0xfceb0000 };

	size_t device_num;
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("awg_load_addr: Failed to find XDMA device!\r\n");
		}
		device_num = sizeof(device_paths);
		std::string ven_id = "ven_10ee";
		std::string dev_id = "dev_8024";
		std::string sub_id = "subsys_";
		char* id_num = new char[5];
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
				//std::cout << "Find device of SN:" << ven_id << dev_id << sub_id << std::endl;
				SN_id = i;
				SN_found++;
				break;
			}
		}

		if (SN_found == 0)
		{
			throw std::runtime_error("awg_load_addr: Failure! No SN found!\r\n");

		}
		else
		{

			xdma_device dev(device_paths[SN_id]);
			//std::cout << device_paths[SN_id] << std::endl;
			//std::cout << write_data.size() * sizeof(uint64_t) << write_data.size() << "yyc" << std::endl;
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint32_t), 1);
			write_thread.join();
		}
	}
	catch (const std::exception & e)
	{
		std::cout << e.what();
	}
	return true;
}

Driver_awg bool awg_sequence_delay(INT32 delay1, INT32 delay2, INT32 delay3, INT16 port, char* subid)
{
	alignas(128) std::vector<uint32_t> write_data(4);
	write_data[0] = delay1;
	write_data[1] = delay2;
	write_data[2] = delay3;
	write_data[3] = 0xcceb0000 + port;
	size_t device_num;
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("awg_delay: Failed to find XDMA device!\r\n");
		}
		device_num = sizeof(device_paths);
		std::string ven_id = "ven_10ee";
		std::string dev_id = "dev_8024";
		std::string sub_id = "subsys_";
		char* id_num = new char[5];
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
				//std::cout << "Find device of SN:" << ven_id << dev_id << sub_id << std::endl;
				SN_id = i;
				SN_found++;
				break;
			}
		}

		if (SN_found == 0)
		{
			throw std::runtime_error("awg_delay: Failure! No SN found!\r\n");

		}
		else
		{

			xdma_device dev(device_paths[SN_id]);
			//std::cout << device_paths[SN_id] << std::endl;
			//std::cout << write_data.size() * sizeof(uint64_t) << write_data.size() << "yyc" << std::endl;
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint32_t), 1);
			write_thread.join();
		}
	}
	catch (const std::exception & e)
	{
		std::cout << e.what();
	}
	return true;
}

Driver_awg bool awg_sequence_addr(INT32 addr1, INT32 addr2, INT32 addr3, INT16 port, char* subid)
{
	alignas(128) std::vector<uint32_t> write_data(4);
	write_data[0] = addr1;
	write_data[1] = addr2;
	write_data[2] = addr3;
	write_data[3] = 0xf1eb0000 + port;
	size_t device_num;
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("awg_delay: Failed to find XDMA device!\r\n");
		}
		device_num = sizeof(device_paths);
		std::string ven_id = "ven_10ee";
		std::string dev_id = "dev_8024";
		std::string sub_id = "subsys_";
		char* id_num = new char[5];
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
				//std::cout << "Find device of SN:" << ven_id << dev_id << sub_id << std::endl;
				SN_id = i;
				SN_found++;
				break;
			}
		}

		if (SN_found == 0)
		{
			throw std::runtime_error("awg_delay: Failure! No SN found!\r\n");

		}
		else
		{

			xdma_device dev(device_paths[SN_id]);
			//std::cout << device_paths[SN_id] << std::endl;
			//std::cout << write_data.size() * sizeof(uint64_t) << write_data.size() << "yyc" << std::endl;
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint32_t), 1);
			write_thread.join();
		}
	}
	catch (const std::exception & e)
	{
		std::cout << e.what();
	}
	return true;
}

Driver_awg bool awg_sequence_length(INT32 len1, INT32 len2, INT32 len3, INT16 port, char* subid)
{
	alignas(128) std::vector<uint32_t> write_data(4);
	write_data[0] = len1;
	write_data[1] = len2;
	write_data[2] = len3;
	write_data[3] = 0xd1eb0000 + port;
	size_t device_num;
	try
	{
		const auto device_paths = get_device_paths(GUID_DEVINTERFACE_XDMA);
		if (device_paths.empty())
		{
			throw std::runtime_error("awg_delay: Failed to find XDMA device!\r\n");
		}
		device_num = sizeof(device_paths);
		std::string ven_id = "ven_10ee";
		std::string dev_id = "dev_8024";
		std::string sub_id = "subsys_";
		char* id_num = new char[5];
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
				//std::cout << "Find device of SN:" << ven_id << dev_id << sub_id << std::endl;
				SN_id = i;
				SN_found++;
				break;
			}
		}

		if (SN_found == 0)
		{
			throw std::runtime_error("awg_delay: Failure! No SN found!\r\n");

		}
		else
		{

			xdma_device dev(device_paths[SN_id]);
			//std::cout << device_paths[SN_id] << std::endl;
			//std::cout << write_data.size() * sizeof(uint64_t) << write_data.size() << "yyc" << std::endl;
			std::thread write_thread(write, std::ref(dev), (void*)write_data.data(), write_data.size() * sizeof(uint32_t), 1);
			write_thread.join();
		}
	}
	catch (const std::exception & e)
	{
		std::cout << e.what();
	}
	return true;
}

Driver_awg bool awg_reset(char* subid)
{
	INT32 length = 8;
	alignas(128) std::vector<uint32_t> write_data((length*8 / 2) + 4);
	write_data[3] = { 0x9ceb0000 };

	std::string ven_id = "ven_10ee";
	std::string dev_id = "dev_8024";
	std::string sub_id = "subsys_";
	char* id_num = new char[5];
	for (int i = 0; i < 4; i++)
	{
		id_num[i] = subid[i * 2];
	}
	id_num[4] = NULL;
	sub_id.append(id_num);
	sub_id.append("10ee");

	awg_cw_mode(0, subid);
	bool flag;
	for (INT16 port_id = 1; port_id < 5; port_id++)
	{
		write_data[2] = { uint32_t(port_id << 24)};
		flag=awg_load_addr(0, port_id, subid);
		flag=awg_load_length(length, port_id, subid);
		flag=h2c_pcie(write_data, ven_id, dev_id, sub_id);
		flag=awg_sequence_delay(0, 0, 0, port_id, subid);
		flag=awg_sequence_addr(0, 0, 0, port_id, subid);
		flag=awg_sequence_length(length, 0, 0, port_id, subid);
	}
	return true;
}