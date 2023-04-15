import ctypes,os
from operator import length_hint
import chardet
import binascii
from sys import getsizeof
import numpy as np
import math
import time
import matplotlib.pyplot as plt
import numpy.ctypeslib as npct

if __name__ == "__main__":
    DRIVER_ELEC = ctypes.cdll.LoadLibrary(r'C:\Users\aql_service\Desktop\Host\Driver_isa.dll')
    #card ID 
    TC_ID = '0006'
    # w_data =    [0x77771111,0x77771111,0x77771111,0x77771111,0x77772222,0x77772222,0x77772222,0x77772222,
    #              0x77773333,0x77773333,0x77773333,0x77773333,0x77774444,0x77774444,0x77774444,0x77774444,
    #              0x77775555,0x77775555,0x77775555,0x77775555,0x77776666,0x77776666,0x77776666,0x77776666,
    #              0x77777777,0x77777777,0x77777777,0x77777777,0x7777ffff,0x7777ffff,0x7777ffff,0x7777ffff]
    # w_data = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32]
    K = 512
    S = K // 4  # 32->128
    w_data = range(K)
    w_data = np.asarray(w_data,dtype=np.uint32)
    w_data_ptr = w_data.ctypes.data_as(ctypes.c_char_p)
    sram_data = [0]*K
    sram_data = np.asarray(sram_data,dtype=np.uint32)
    sram_data_ptr = sram_data.ctypes.data_as(ctypes.c_char_p)
    print('Begin to write SRAM:')
    DRIVER_ELEC.tc_sram(w_data_ptr,S,TC_ID)
    print('Write succeed!')
    time.sleep(5)
    print('Begin to fetch data from SRAM!')
    # DRIVER_ELEC.tc_cpu_pause(TC_ID,0)
    DRIVER_ELEC.tc_fetch(64,10,sram_data_ptr,TC_ID)
    print('Fetch data succeed! SRAM Data is ',sram_data)
