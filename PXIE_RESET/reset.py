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

    print('Begin to reset cpu!')
    DRIVER_ELEC.tc_cpu_pause(TC_ID,0)
    time.sleep(3)
    DRIVER_ELEC.tc_cpu_pause(TC_ID,1)
    print('Reset cpu succeed!')