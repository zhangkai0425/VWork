/*#pragma once
#include <vector>
#ifdef Driver_ad
#else
#define Driver_ad extern "C" _declspec(dllimport)
#endif // Deiver_ad

Driver_ad bool config_ad();
Driver_ad std::vector<uint32_t> start_acq(int cycle, int length, int delay);*/