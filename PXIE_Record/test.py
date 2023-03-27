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
    isa_data = [0x77771234,0x77775678,0x7777ffff,0x77771111,0x7777ffff,0x7777ffff,0x7777ffff,0x7777ffff,0x7777ffff,0x7777ffff
                ,0x7777ffff,0x7777ffff,0x7777ffff,0x7777ffff,0x7777ffff,0x7777ffff,0x7777ffff,0x7777ffff,0x7777ffff,0x7777ffff
                ,0x7777ffff,0x7777ffff,0x7777ffff,0x7777ffff,0x7777ffff,0x7777ffff,0x7777ffff,0x7777ffff,0x7777ffff,0x7777ffff,
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
    DRIVER_ELEC.tc_isa(isa_data_ptr,1,TC_ID)
    # time.sleep(1)
    # DRIVER_ELEC.tc_isa(isa_data_ptr,1,TC_ID)
    # time.sleep(1)
    # DRIVER_ELEC.tc_isa(isa_data_ptr,1,TC_ID)
    # DRIVER_ELEC.tc_trig(TC_ID)
    print("TC Trigger Succeed!")
   


    
    DRIVER_ELEC.tc_cfg(tc_delay, cycle, TC_ID)
    print("TC Config Succeed!")