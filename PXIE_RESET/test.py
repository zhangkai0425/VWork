import ctypes,os
from operator import length_hint
import chardet
import binascii
from sys import getsizeof
import numpy as np
import math
import time
import matplotlib.pyplot as plt
import scipy as sp
from scipy.optimize import curve_fit
from scipy.fftpack import fft,ifft
from scipy import signal
import librosa
import numpy.ctypeslib as npct
from scipy.stats import norm


if __name__ == "__main__":
    isa_data = [0x77772222,0x77771234,0x77771111,0x77775678,0x77772222,0x77772222,0x77772222,0x77772222,0x77773333,0x77773333
                ,0x77773333,0x77773333,0x77774444,0x77774444,0x77774444,0x77774444,0x77775555,0x77775555,0x77775555,0x77775555
                ,0x77776666,0x77776666,0x77776666,0x77776666,0x77777777,0x77777777,0x77777777,0x77777777,0x7777ffff,0x7777ffff,
                0x7777ffff,0x7777ffff]
    isa_data = np.asarray(isa_data)
    isa_data_ptr = isa_data.ctypes.data_as(ctypes.c_char_p)
    print(isa_data_ptr)
    
    print("Begin to send data from host pc!")

    DRIVER_ELEC = ctypes.cdll.LoadLibrary(r'C:\Users\aql_service\Desktop\Host\Driver_isa.dll')

    

    #card ID 
    TC_ID = '0006'

    #card delay
    cycle = 100
    tc_delay = 12500*3  # 125 = 1us  / 12500 = 100us
    # DRIVER_ELEC.tc_isa(isa_data_ptr,5,TC_ID)
    time.sleep(1)
    # DRIVER_ELEC.tc_cfg(tc_delay, cycle, TC_ID)
    DRIVER_ELEC.tc_cfg(tc_delay, cycle, TC_ID)
    time.sleep(1)
    T1 = time.time()
    DRIVER_ELEC.tc_isa(isa_data_ptr,7,TC_ID)
    T2 = time.time()
    # time.sleep(1)
    # DRIVER_ELEC.tc_isa(isa_data_ptr,1,TC_ID)
    # time.sleep(1)
    # DRIVER_ELEC.tc_isa(isa_data_ptr,1,TC_ID)
    # DRIVER_ELEC.tc_trig(TC_ID)
    print("TC Trigger Succeed!")
   

    DRIVER_ELEC.tc_cfg(tc_delay, cycle, TC_ID)
    print("TC Config Succeed!")

    
    print('程序运行时间:%s毫秒' % ((T2 - T1)*1000))
    print('Begin to reset cpu!')
    DRIVER_ELEC.tc_cpu_pause(TC_ID,0)
    time.sleep(10)
    DRIVER_ELEC.tc_cpu_pause(TC_ID,0)
    time.sleep(10)
    print('Reset cpu succeed!')