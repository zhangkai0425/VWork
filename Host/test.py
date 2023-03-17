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
    print("Begin to set data from host pc!")
    # sin_data = tmp.ctypes.data_as(ctypes.c_char_p)
    DRIVER_ELEC = ctypes.cdll.LoadLibrary(r'C:\Users\aql_service\Desktop\Host\Driver_isa.dll')

    #card ID 
    TC_ID = '0006'
    DRIVER_ELEC.tc_trig(TC_ID)
    print("TC Trigger Succeed!")
