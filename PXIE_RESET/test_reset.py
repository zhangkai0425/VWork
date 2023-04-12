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
    isa_data = []
    with open('isa_2.txt', 'r') as f:
        lines = f.readlines()    # 将文件内容逐行读取到列表lines中
        for line in lines:
            inst = line.split(' ')
            new_inst = [i for i in inst if i.strip()]
            rdata = [   new_inst[3],
                        new_inst[2],
                        new_inst[1],
                        new_inst[0],
                    ]
            isa_data.append(int('0x' + rdata[0],16))
            isa_data.append(int('0x' + rdata[1],16))
            isa_data.append(int('0x' + rdata[2],16))
            isa_data.append(int('0x' + rdata[3],16))

    # isa_data = [0x004001b7,0x1111a073,0x11116189,0x11113001]
    # isa_data = [0x004001b7,0x7c01a073,0xa0736189,0x01933001]
    # isa_data = [0x77772222,0x77771234,0x77771111,0x77775678]
    
    # print(isa_data)
    # isa_data = [0x77772222,0x77771234,0x77771111,0x77775678,0x77772222,0x77772222,0x77772222,0x77772222,0x77773333,0x77773333
    #             ,0x77773333,0x77773333,0x77774444,0x77774444,0x77774444,0x77774444,0x77775555,0x77775555,0x77775555,0x77775555
    #             ,0x77776666,0x77776666,0x77776666,0x77776666,0x77777777,0x77777777,0x77777777,0x77777777,0x7777ffff,0x7777ffff,
    #             0x7777ffff,0x7777ffff]
    isa_data = np.asarray(isa_data,dtype=np.uint32)
    print(isa_data.shape)
    print(isa_data.dtype)
    isa_data_ptr = isa_data.ctypes.data_as(ctypes.c_char_p)
    print(isa_data_ptr)
    
    print("Begin to send data from host pc!")

    DRIVER_ELEC = ctypes.cdll.LoadLibrary(r'C:\Users\aql_service\Desktop\Host\Driver_isa.dll')

    #card ID 
    TC_ID = '0006'
    print('Begin to reset cpu!')
    DRIVER_ELEC.tc_cpu_pause(TC_ID,0)
    time.sleep(1)
    DRIVER_ELEC.tc_isa(isa_data_ptr,1570,TC_ID)
    print('Reset cpu succeed!')