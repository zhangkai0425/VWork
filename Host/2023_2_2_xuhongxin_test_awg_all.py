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



class AQLAD:
    def readout(self, cycle, length, addr):
        ch_wave_0 = {}
        ch_wave_1 = {}
        ch_wave = {}
        base = [2048, 2048, 2048, 2048]
        amp = [6000, 6000, 6000, 6000]
        # amp = [1755, 1755, 1755, 1755]
        data_byte = ctypes.string_at(addr, 8*length*cycle)
        data_hex = np.array(bytearray(data_byte))
        data_row_1 = data_hex.reshape((2, -1), order="F")
        data_row_2 = (data_row_1[0]+256*data_row_1[1])
        sign = (data_row_2 >> 15) & 1
        wave_row_1 = data_row_2 - sign*2**16 + 2**15
        wave_row_2 = np.array(wave_row_1 >> 4, dtype=float)
        wave_row = wave_row_2.reshape((32, -1), order="F")

        for i in range(0, 4):
            self.new_method(ch_wave_0, base, amp, wave_row, i)
            ch_wave_1[i+1] = np.ravel(ch_wave_0[i+1], order='F')
            ch_wave[i+1] = np.zeros([cycle, 1, length])
        for n in range(0, 4):
            for m in range(0, cycle):
                delta = int((m)*length)
                ch_wave[n+1][m][0] = ch_wave_1[n+1][delta:delta+length]
        ch_wave[2] = -ch_wave[2]
        ch_wave[4] = -ch_wave[4]
        #release memory in DLL
        return ch_wave

    def new_method(self, ch_wave_0, base, amp, wave_row, i):
        ch_wave_0[i+1] = (base[i]-np.vstack((wave_row[3+8*i], wave_row[7+8*i], wave_row[2+8*i], wave_row[6+8*i], wave_row[1+8*i], wave_row[5+8*i], wave_row[0+8*i], wave_row[4+8*i])))/amp[i]

    def offset_calibration(self, AWG_ID):
        cali = {}
        offset_cal = {}
        ch_average = {}
        offset = 2032*0.0005
        DRIVER_ELEC.ad_cfg(1, 2048, 0, AWG_ID)
        DRIVER_ELEC.ad_mode(0, AWG_ID)
        time.sleep(1)
        DRIVER_ELEC.ad_readout.restype = ctypes.c_uint64
        AD = AQLAD()
        cali = [1, 1, 1, 1]
        offset_cal = [58, 111, 76, 10]
        while(cali != [0, 0, 0, 0]):
            DRIVER_ELEC.tc_trig(AWG_ID)
            addr = DRIVER_ELEC.ad_readout(1, 2048, 3000, AWG_ID)
            ch_wave = AD.readout(1, 2048, addr)
            for i in range(0, 4):
                ch_average[i] = np.sum(ch_wave[i+1][0][0])
                if ch_average[i] > offset:
                    offset_cal[i] = offset_cal[i]-1
                    cali[i] = 1
                else:
                    if ch_average[i] < -offset:
                        offset_cal[i] = offset_cal[i]+1
                        cali[i] = -1
                    else:
                        cali[i] = 0
            DRIVER_ELEC.ad_offsetcali(offset_cal[0], offset_cal[1], offset_cal[2], offset_cal[3], AWG_ID)
        return True

def volt_awg(volt):
    awg = np.asarray(volt)
    # for n in range(0, awg.size):
    #     if awg[n] >= 0:
    #         awg[n] = math.ceil(2**16-awg[n]/625*1000*(2**13-1))
    #     else:
    #         awg[n] = math.ceil(-awg[n]/625*1000*(2**13-1))

    for n in range(0,awg.size):
        if awg[n]>=0 :
            awg[n] = math.ceil(awg[n]/625*1000*(2**13-1))
        else:
            awg[n] = math.ceil(2**16+awg[n]/625*1000*(2**13-1))
    awg = awg.astype(int)
    return awg


def Get_Coefficient(amp, tau, f_sample, IIR_on):

    g = amp
    if(IIR_on == 1):
        #填入计算alpha和k值的方法
        alpha = 1 - np.exp(-1 / (f_sample * (10**6) * tau * (10**(-9)) * (1 + g)))
        if g >= 0.0:
            k = g / (1 - alpha + g)
        else:
            k = g / (1 - alpha) / (1 + g)
    else:
        alpha = 1
        k = 0

    alpha_in = int(alpha * (2**15)) & 0xffff

    complement_alpha_0 = np.arange(7)
    alpha_complement_alpha_0 = np.arange(7)

    for i in range(0, 7):
        complement_alpha_0[i] = int(((1 - alpha)**i) * (2**15)) & 0xffff

    complement_alpha_0[0] = 0x7fff & 0xffff

    for i in range(0, 7):
        alpha_complement_alpha_0[i] = int(((1 - alpha)**i) * (2**15) * alpha) & 0xffff

    k_in = int(k * (2**15)) & 0xffff

    complement_k_in = ((int((1-k) * (2**15))) >> 3) & 0xffff

    temp = np.array([alpha_in,
                     complement_alpha_0[6],
                     complement_alpha_0[5],
                     complement_alpha_0[4],
                     complement_alpha_0[3],
                     complement_alpha_0[2],
                     complement_alpha_0[1],
                     complement_alpha_0[0],
                     alpha_complement_alpha_0[5],
                     alpha_complement_alpha_0[4],
                     alpha_complement_alpha_0[3],
                     alpha_complement_alpha_0[2],
                     alpha_complement_alpha_0[1],
                     alpha_complement_alpha_0[0],
                     k_in,
                     complement_k_in]).astype(int)
    Coefficient = temp.ctypes.data_as(ctypes.c_char_p)
    return Coefficient


def Sin_function(t, A, freq, phi_0):
    return(A*math.sin(2*np.pi*freq/2000*t+phi_0))


def Cos_function(t, A, freq, phi_0):
    return(A*math.cos(2*np.pi*freq/2000*t+phi_0))


def Square_function(t, A, sigma):
    return (A)


def Guass_Square_function(awg_data_length, high, amplitude):
    u = 0  # 均值μ
    u01 = 6
    sig = math.sqrt(0.1)  # 标准差δ
    sig_u01 = math.sqrt(1)
    x_01 = np.linspace(u - 5 * sig, u + 20 * sig, 100)
    x_u01 = np.linspace(u - 10 * sig, u + 40 * sig, 100)
    y_sig_u01 = np.exp(-(x_u01 - u01) ** 2 / (2 * sig_u01 ** 2)) / (math.sqrt(2 * math.pi) * sig_u01)
    y_sig_u01 = y_sig_u01*2.5

    b = np.zeros(awg_data_length)
    pos = 100
    neg = pos+high
    for i in range(0, awg_data_length):
        if(pos < i < neg):
            b[i] = 1

    for i in range(0, 100):
        if(i < 58):
            b[pos+i-57] = y_sig_u01[i]
        else:
            b[neg+i-58] = y_sig_u01[i]

    # b = b 
    A = b*(amplitude)
    return(A)


def awg_mode_iir5(iir_amp, iir_tau, iir_on, port):
    
    coefficient1x = Get_Coefficient(iir_amp[0], iir_tau[0], 500.0, 1)
    coefficient2x = Get_Coefficient(iir_amp[1], iir_tau[1], 500.0, 1)
    coefficient3x = Get_Coefficient(iir_amp[2], iir_tau[2], 500.0, 1)
    coefficient4x = Get_Coefficient(iir_amp[3], iir_tau[3], 500.0, 1)
    coefficient5x = Get_Coefficient(iir_amp[4], iir_tau[4], 500.0, 1)
    iir_en = awg_multi_IIR_on(iir_on, port)
    
    DRIVER_ELEC.awg_multi_IIR_on(iir_en, AWG_ID)
    DRIVER_ELEC.awg_multi_reset_IIR(0b1111, AWG_ID)
    DRIVER_ELEC.awg_multi_IIR_coefficient(coefficient1x, coefficient2x, coefficient3x, coefficient4x, coefficient5x, port, AWG_ID)
    return 0

def awg_multi_IIR_on(iir_on, port):
    global dac1_iir_en
    global dac2_iir_en
    global dac3_iir_en
    global dac4_iir_en

    if(port == 1):
        if(iir_on == 1):
            dac1_iir_en = 1
        else:
            dac1_iir_en = 0
            
    if(port == 2):
        if(iir_on == 1):
            dac2_iir_en = 2
        else:
            dac2_iir_en = 0
            
    if(port == 3):
        if(iir_on == 1):
            dac3_iir_en = 4
        else:
            dac3_iir_en = 0
            
    if(port == 4):
        if(iir_on == 1):
            dac4_iir_en = 8
        else:
            dac4_iir_en = 0

    iir_data = dac1_iir_en + dac2_iir_en + dac3_iir_en + dac4_iir_en

    print("", iir_data)
    return iir_data


def awg_data_zero(wave_length, en, port):
    if(en == 1):
        if(wave_length > 10000):
            print("Error : over length ,please use continue mode ! ")
            return 0
        awg_data_length = wave_length*2
        wave = np.zeros(awg_data_length)
        tmp = volt_awg(wave)
        zero_data = tmp.ctypes.data_as(ctypes.c_char_p)
        awg_send_single_wave(zero_data, awg_data_length, port)
    else:
        return 0
    return 0 


def awg_data_sin(wave_length, frequency, amplitude, en, port):
    if(en == 1):
        if(wave_length > 10000):
            print("Error : over length ,please use continue mode ! ")
            return 0
        awg_data_length = wave_length*2
        wave = np.zeros(awg_data_length)
        for i in range(0, awg_data_length-8):
            wave[i] = Sin_function(i, amplitude, frequency, 0)
        tmp = volt_awg(wave)
        sin_data = tmp.ctypes.data_as(ctypes.c_char_p)
        awg_send_single_wave(sin_data, awg_data_length, port)
    else:
        return 0
    return 0


def awg_data_cos(wave_length, frequency, amplitude, en, port):

    if(en == 1):
        if(wave_length > 10000):
            print("Error : over length ,please use continue mode ! ")
            return 0
        awg_data_length = wave_length*2
        wave = np.zeros(awg_data_length)
        for i in range(0, awg_data_length-8):
            wave[i] = Cos_function(i, amplitude, frequency, 0)
        tmp = volt_awg(wave)
        cos_data = tmp.ctypes.data_as(ctypes.c_char_p)
        awg_send_single_wave(cos_data, awg_data_length, port)
    else:
        return 0
    return 0


def awg_data_customized_definition(data, en, port):
    if(en == 1):
        tmp = volt_awg(data)
        user_data = tmp.ctypes.data_as(ctypes.c_char_p)
        awg_send_single_wave(user_data, len(data), port)
    else:
        return 0
    return 0


def awg_data_square(wave_length, high_length, amplitude, en, port):

    if(en == 1):
        if(wave_length > 10000):
            print("Error : over length ,please combine waveform ! ")
            return 0
        awg_data_length = wave_length*2
        high_length = high_length*2
        wave = np.zeros(awg_data_length)
        for i in range(0, high_length-8):
            wave[i] = Square_function(i, amplitude , 30)
        tmp = volt_awg(wave)
        square_data = tmp.ctypes.data_as(ctypes.c_char_p)
        awg_send_single_wave(square_data, awg_data_length, port)
    else:
        return 0
    return 0


def awg_data_guass_square(wave_length, high_length, amplitude, en, port):
    
    if(en == 1):
        if(wave_length > 10000):
            print("Error : over length ,please combine waveform ! ")
            return 0
        awg_data_length = wave_length*2
        high_length = high_length*2
        wave = Guass_Square_function(awg_data_length, high_length, amplitude)
        tmp = volt_awg(wave)
        square_data = tmp.ctypes.data_as(ctypes.c_char_p)
        awg_send_single_wave(square_data, awg_data_length, port)
    else:
        return 0
    return 0


def awg_send_single_wave(awg_data, awg_data_length, port):
    wr_depth = int(awg_data_length/8)
    rd_depth = int(awg_data_length/8)

    DRIVER_ELEC.awg_load_addr(0, port, AWG_ID)
    DRIVER_ELEC.awg_load_length(wr_depth, port, AWG_ID)
    DRIVER_ELEC.send_wave_data(awg_data, awg_data_length, port, AWG_ID)

    DRIVER_ELEC.awg_sequence_delay(awg_delay, awg_delay, awg_delay, port, AWG_ID)
    DRIVER_ELEC.awg_sequence_addr(0, 0, 0, port, AWG_ID)
    DRIVER_ELEC.awg_sequence_length(rd_depth, rd_depth, rd_depth, port, AWG_ID)
    return 0


def awg_mode_N_pulse(wave_length, high_length, amplitude, en, port):
    if (en == 1):
        b = Guass_Square_function(wave_length, high_length, amplitude)
        pos = 100
        neg = pos+high_length
        pos_wave = np.zeros(200)
        high_wave = np.zeros(200)
        neg_wave = np.zeros(200)
        for i in range(0, 200):
            pos_wave[i] = b[pos+i-100]
        for i in range(0, 200):
            neg_wave[i] = b[neg+i-100]
        for i in range(0, 200):
            high_wave[i] = b[pos+i+100]
        x9 = np.asarray(pos_wave)
        x10 = np.asarray(neg_wave)
        x11 = np.asarray(high_wave)
        tmp9 = volt_awg(x9)
        gauss_pos = tmp9.ctypes.data_as(ctypes.c_char_p)
        tmp10 = volt_awg(x10)
        gauss_neg = tmp10.ctypes.data_as(ctypes.c_char_p)
        tmp11 = volt_awg(x11)
        gauss_high = tmp11.ctypes.data_as(ctypes.c_char_p)
        awg_data1 = gauss_pos
        awg_data2 = gauss_high
        awg_data3 = gauss_neg
        awg_data_length1 = 200
        awg_data_length2 = 200
        awg_data_length3 = 200
        wr_depth1 = int(awg_data_length1/8)
        rd_depth1 = int(awg_data_length1/8)
        wr_depth2 = int(awg_data_length2/8)
        rd_depth2 = int(awg_data_length2/8)
        wr_depth3 = int(awg_data_length3/8)
        rd_depth3 = int(awg_data_length3/8)
        awg_delay1 = 0  # 250 = 1us  /    25000 = 100us
        awg_delay2 = 125
        awg_delay3 = 250
        
        # load wave 
        DRIVER_ELEC.awg_load_addr(0, port, AWG_ID)
        DRIVER_ELEC.awg_load_length(wr_depth1, port, AWG_ID)
        DRIVER_ELEC.send_wave_data(awg_data1, awg_data_length1, port, AWG_ID)

        DRIVER_ELEC.awg_load_addr(300, port, AWG_ID)
        DRIVER_ELEC.awg_load_length(wr_depth2, port, AWG_ID)
        DRIVER_ELEC.send_wave_data(awg_data2, awg_data_length2, port, AWG_ID)

        DRIVER_ELEC.awg_load_addr(600, port, AWG_ID)
        DRIVER_ELEC.awg_load_length(wr_depth3, port, AWG_ID)
        DRIVER_ELEC.send_wave_data(awg_data3, awg_data_length3, port, AWG_ID)
        #send wave
        DRIVER_ELEC.awg_sequence_delay(awg_delay1+awg_delay, awg_delay2+awg_delay, awg_delay3+awg_delay, port, AWG_ID)
        DRIVER_ELEC.awg_sequence_addr(0, 300, 600, port, AWG_ID)
        DRIVER_ELEC.awg_sequence_length(rd_depth1, rd_depth2, rd_depth3, port, AWG_ID)
    else:
        return 0
    return 0

def Gauss_function(t, A, sigma):
    return ( A * math.exp(- (t * t) / (2 * sigma * sigma)))

def awg_mode_mixer(en):
    if(en == 1):
        xzero = np.zeros(2000)
        tmp = volt_awg(xzero)
        Zerodata = tmp.ctypes.data_as(ctypes.c_char_p)
        
        Wave1 = np.zeros(2000)
        for i in range(0, 1992):
            Wave1[i] = Square_function(i, 0.2, 30)
        tmpWave1 = volt_awg(Wave1)
        Wave1data = tmpWave1.ctypes.data_as(ctypes.c_char_p)

        Wave4 = np.zeros(2000)
        for i in range(0, 2000):
            Wave4[i] = Square_function(i, 0.2, 30)
        tmpWave4 = volt_awg(Wave4)
        Wave4data = tmpWave4.ctypes.data_as(ctypes.c_char_p)

        Wave2 = np.zeros(2000)
        for i in range(0, 1992):
            Wave2[i] = Sin_function(i, 0.2, 100, 0)
        tmpWave2 = volt_awg(Wave2)
        Wave2data = tmpWave2.ctypes.data_as(ctypes.c_char_p)

        Wave3 = np.zeros(2000)
        for i in range(0, 1992):
            Wave3[i] = Gauss_function((i-996.0)/2000, 0.3, 0.2)
        tmpWave3 = volt_awg(Wave3)
        Wave3data = tmpWave3.ctypes.data_as(ctypes.c_char_p)
        
        
        length = 250
        addr_begin = 0
        DRIVER_ELEC.send_waveform_data(Wave2data,  length, addr_begin + 0, 1, AWG_ID)

        DRIVER_ELEC.send_waveform_data(Wave2data,  length, addr_begin + 0, 2, AWG_ID)

        DRIVER_ELEC.send_waveform_data(Wave2data,  length, addr_begin + 0, 3, AWG_ID)

        DRIVER_ELEC.send_waveform_data(Wave2data,  length, addr_begin + 0, 4, AWG_ID)
        efficient_wavenum = 100
        DRIVER_ELEC.awg_multi_wavenum(efficient_wavenum, 1, AWG_ID)
        DRIVER_ELEC.awg_multi_wavenum(efficient_wavenum, 2, AWG_ID)
        DRIVER_ELEC.awg_multi_wavenum(efficient_wavenum, 3, AWG_ID)
        DRIVER_ELEC.awg_multi_wavenum(efficient_wavenum, 4, AWG_ID)
        delay = 300
        length = 250
        addr = 250
        for i in range(0, efficient_wavenum):
            DRIVER_ELEC.awg_multi_delay(i*delay, 1, i, AWG_ID)
            DRIVER_ELEC.awg_multi_length(250,     1, i, AWG_ID)
            DRIVER_ELEC.awg_multi_addr(0,     1, i, AWG_ID)

            DRIVER_ELEC.awg_multi_delay(i*delay, 2, i, AWG_ID)
            DRIVER_ELEC.awg_multi_length(250,     2, i, AWG_ID)
            DRIVER_ELEC.awg_multi_addr(0,     2, i, AWG_ID)

            DRIVER_ELEC.awg_multi_delay(i*delay, 3, i, AWG_ID)
            DRIVER_ELEC.awg_multi_length(250,     3, i, AWG_ID)
            DRIVER_ELEC.awg_multi_addr(0,     3, i, AWG_ID)

            DRIVER_ELEC.awg_multi_delay(i*delay, 4, i, AWG_ID)
            DRIVER_ELEC.awg_multi_length(250,     4, i, AWG_ID)
            DRIVER_ELEC.awg_multi_addr(0,     4, i, AWG_ID)
        DRIVER_ELEC.awg_multi_IQ_Correction_Amp(1, 0, 0, AWG_ID)
        DRIVER_ELEC.awg_multi_IQ_Correction_Amp(2, 0, 0, AWG_ID)
        DRIVER_ELEC.awg_multi_IQ_Correction_Phase(1, 0, 0, AWG_ID)
        DRIVER_ELEC.awg_multi_IQ_Correction_Phase(2, 0, 0, AWG_ID)

        DRIVER_ELEC.awg_multi_frequency(100, 1, AWG_ID)  # dds产生的时钟频率为20Mhz
        DRIVER_ELEC.awg_multi_frequency(100, 2, AWG_ID)  # dds产生的时钟频率为20Mhz
        tmpGroup1_ram = np.array([1, 2]).astype(int)
        Group1_ram = tmpGroup1_ram.ctypes.data_as(ctypes.c_char_p)

        tmpGroup1_port = np.array([3, 3]).astype(int)
        Group1_port = tmpGroup1_port.ctypes.data_as(ctypes.c_char_p)

        Group1 = 1  # 使用第Group1组dds

        Group1_mixer_on = 0  # 开启混频

        tmpGroup2_ram = np.array([3, 4]).astype(int)
        Group2_ram = tmpGroup2_ram.ctypes.data_as(ctypes.c_char_p)

        tmpGroup2_port = np.array([3, 3]).astype(int)
        Group2_port = tmpGroup2_port.ctypes.data_as(ctypes.c_char_p)

        Group2 = 2  # 使用第Group2组dds

        Group2_mixer_on = 0  # 开启混频

        DRIVER_ELEC.awg_multi_mixer_config(Group1, Group1_mixer_on, Group1_ram, Group1_port, AWG_ID)
        DRIVER_ELEC.awg_multi_mixer_config(Group2, Group2_mixer_on, Group2_ram, Group2_port, AWG_ID)
        DRIVER_ELEC.awg_trig_mask(AWG_ID, 1, 1, 1, 1)
        
        offset_cal = [0, 0, 0, 0]
        DRIVER_ELEC.awg_offset(offset_cal[0], 1, AWG_ID)
        DRIVER_ELEC.awg_offset(offset_cal[1], 2, AWG_ID)
        DRIVER_ELEC.awg_offset(offset_cal[2], 3, AWG_ID)
        DRIVER_ELEC.awg_offset(offset_cal[3], 4, AWG_ID)

        DRIVER_ELEC.awg_multi_Channel_Delay(0, 136, 443, 163, AWG_ID)
        DRIVER_ELEC.awg_multi_Channel_Delay_Set(AWG_ID)

        time.sleep(1)
    else:
        return 0
    return 0


def awg_mode_continue(en):
    if(en == 1):
        DRIVER_ELEC.awg_cw_mode(1, AWG_ID)
    else:
        DRIVER_ELEC.awg_cw_mode(0, AWG_ID)
    return 0

def awg_jitter(en):
    if (en == 1):
        wave_length = 1000
        frequency = 10 
        amplitude = 0.2 
        awg_data_length = wave_length*2
        wave = np.zeros(awg_data_length)
        for i in range(0, awg_data_length-8):
            wave[i] = Sin_function(i, amplitude, frequency, 0)
        tmp = volt_awg(wave)
        sin_data = tmp.ctypes.data_as(ctypes.c_char_p)
        awg_send_single_wave(sin_data, awg_data_length, port)

        data=tc_trig(1)

        coe_A = {}
        coe_f = {}
        coe_phi = {}
        coe_jitter = {}
        coe_c = {}
        fitted_P = {}
        xtime = np.array([i for i in range(500)])

        def fitsine(x, A, f, phi, c):
            return A*np.cos(2*np.pi*f*x+phi) + c
        A_g = 0.5
        f_g = 1/100
        phi_g = 0  # np.pi/2
        c_g = 0
        a_guess = [A_g, f_g, phi_g, c_g]
        fig, axs = plt.subplots(2, 2)
        for port in range(1, 5):

            if port == 1:
                x = 0
                y = 0
            if port == 2:
                x = 1
                y = 0
            if port == 3:
                x = 0
                y = 1
            if port == 4:
                x = 1
                y = 1

            for m in range(0, cycle):
                fit_opt, fit_cov = curve_fit(fitsine, xtime, data[port][m][0][250:750], p0=a_guess)
                coe_A[m] = fit_opt[0]
                coe_f[m] = fit_opt[1]
                coe_phi[m] = fit_opt[2]
                coe_jitter[m] = fit_opt[2]*100/(2*np.pi)
                coe_c[m] = fit_opt[3]
                fitted_P[m] = fitsine(xtime, coe_A[m], coe_f[m], coe_phi[m], coe_c[m])

            histdata = np.array(tuple(coe_jitter.values()))
            n, bins, patches = axs[x, y].hist(histdata, 30)
            (mu, sigma) = norm.fit(histdata)
            best_fit_line = sp.stats.norm.pdf(bins, mu, sigma)
            axs[x, y].plot(bins, best_fit_line)
            axs[x, y].set_xlabel('jitter(ns)')
            axs[x, y].set_ylabel('count(a.u.)')
            axs[x, y].set_title(r'$\mathrm{Histogram\ of\ Ch%d \ jitter:}\ \mu=%.3f,\ \sigma=%.3f$' % (port, mu, sigma))
        ad_print(data, cycle, 1)
    else:
        return 0
    return 0


def ad_print(data, cycle, en):
    if(en == 1):
        fig, axs = plt.subplots(2, 2)
        axs[0, 0].plot(data[1][0][0], "r-")
        axs[0, 0].set_title('AD ch1')
        axs[0, 0].set_xlabel('time(ns)')
        axs[0, 0].set_ylabel('amplitude(V)')

        axs[1, 0].plot(data[2][0][0], "b-")
        axs[1, 0].set_title('AD ch2 ')
        axs[1, 0].set_xlabel('time(ns)')
        axs[1, 0].set_ylabel('amplitude(V)')

        axs[0, 1].plot(data[3][0][0], "g-")
        axs[0, 1].set_title('AD ch3 ')
        axs[0, 1].set_xlabel('time(ns)')
        axs[0, 1].set_ylabel('amplitude(V)')

        axs[1, 1].plot(data[4][0][0], "y-")
        axs[1, 1].set_title('AD ch4 ')
        axs[1, 1].set_xlabel('time(ns)')
        axs[1, 1].set_ylabel('amplitude(V)')

        for m in range(0, cycle):
            axs[0, 0].plot(data[1][m][0], "r-")
            axs[1, 0].plot(data[2][m][0], "b-")
            axs[0, 1].plot(data[3][m][0], "g-")
            axs[1, 1].plot(data[4][m][0], "y-")
        plt.show()
    else:
        return 0
    return 0


def ad_print_1(data, cycle, en):
    if(en == 1):
        plt.figure(1)
        plt.plot(data[1][0][0], "r-", label='ch1')
        plt.plot(data[2][0][0], "b-", label='ch2')
        plt.plot(data[3][0][0], "g-", label='ch3')
        plt.plot(data[4][0][0], "y-", label='ch4')
        plt.xlabel('time(ns)')
        plt.ylabel('amplitude(V)')
        plt.legend()
        plt.title(r'Freq %dMhz' % (freq))

        for m in range(0, cycle):
            plt.figure(1)
            plt.plot(data[1][m][0], "r-")
            plt.plot(data[2][m][0], "b-")
            plt.plot(data[3][m][0], "g-")
            plt.plot(data[4][m][0], "y-")
        plt.show()
    else:
        return 0
    return 0

def tc_trig(en):
    if(en == 1):
        # ad and tc config
        length = 2048
        timeout = 3000
        DRIVER_ELEC.ad_cfg(cycle, length, ad_delay, AD_ID)
        DRIVER_ELEC.ad_mode(0, AD_ID, int(1e7))
        time.sleep(1)
        DRIVER_ELEC.tc_cfg(tc_delay, cycle, TC_ID)
        DRIVER_ELEC.ad_malloc.restype = ctypes.c_uint64
        addr = DRIVER_ELEC.ad_malloc(cycle, length)
        DRIVER_ELEC.ad_start.argtypes = [ctypes.c_int, ctypes.c_int, ctypes.c_wchar_p, ctypes.c_uint64]
        DRIVER_ELEC.ad_start(cycle, length, AD_ID, addr)
        DRIVER_ELEC.tc_trig(TC_ID)
        time.sleep(1)
        readdone = DRIVER_ELEC.ad_done(timeout)
        print("read done")
        AD = AQLAD()
        data = AD.readout(cycle, length, addr)
        DRIVER_ELEC.ad_free.argtypes = [ctypes.c_uint64]
        DRIVER_ELEC.ad_free(addr)
        ad_print_1(data, cycle, 1)
        return data
    else:
        return 0

DRIVER_ELEC = ctypes.cdll.LoadLibrary(r'D:\work_file_xuhongxin\2_AQAWG\1_FPGA\new faction design\xhx_LO_IIR5\2022_12_28_AQL.dll')

if __name__ == "__main__":
    
    dac1_iir_en = 0
    dac2_iir_en = 0
    dac3_iir_en = 0
    dac4_iir_en = 0
    
    #card ID 
    TC_ID = '0017'
    AD_ID = '0020'
    AWG_ID = '0026'
    
    #card delay
    cycle = 100
    awg_delay = 0       # 250 = 1us  /    25000 = 100us
    tc_delay = 12500*3  # 125 = 1us  / 12500 = 100us
    ad_delay = 0        # 1 = 8 ns  /  125 = 1us
    
    # AWG Work Mode
    ch1_amp = [-0.2, 0, 0, 0, 0]  # [iir_1x,iir_2x,iir_3x,iir_4x,iir_5x]
    ch1_tau = [400, 450, 1300, 700, 20.58456271]  # [iir_1x,iir_2x,iir_3x,iir_4x,iir_5x]
    ch2_amp = [0.2, 0, 0, 0, 0]
    ch2_tau = [400, 450, 1300, 700, 20.58456271]
    ch3_amp = [0.2, 0, 0, 0, 0]
    ch3_tau = [400, 450, 1300, 700, 20.58456271]
    ch4_amp = [-0.2, 0, 0, 0, 0]
    ch4_tau = [400, 450, 1300, 700, 20.58456271]

    awg_mode_iir5(ch1_amp, ch1_tau, 0, 1)  # awg_mode_iir5(iir_amp, iir_tau, iir_on, port)
    awg_mode_iir5(ch2_amp, ch2_tau, 0, 2)
    awg_mode_iir5(ch3_amp, ch3_tau, 0, 3)
    awg_mode_iir5(ch4_amp, ch4_tau, 0, 4)
    
    awg_mode_mixer(0)   # awg_mode_mixer(en)
    awg_mode_continue(0)  # awg_mode_continue(en)

    # AWG Send Data
    wave_leg = 1000
    freq = 100
    amp = -0.1
    high_leg = 400

    awg_mode_N_pulse(wave_leg, high_leg, amp, 0, 1)  # awg_mode_N_pulse(wave_length(ns), high_length(ns), amplitude(v), en, port)
    awg_mode_N_pulse(wave_leg, high_leg, amp, 0, 2)  # awg_mode_N_pulse(wave_length(ns), high_length(ns), amplitude(v), en, port)
    awg_mode_N_pulse(wave_leg, high_leg, amp, 0, 3)  # awg_mode_N_pulse(wave_length(ns), high_length(ns), amplitude(v), en, port)
    awg_mode_N_pulse(wave_leg, high_leg, amp, 0, 4)  # awg_mode_N_pulse(wave_length(ns), high_length(ns), amplitude(v), en, port)
    
    # awg_data_zero(wave_leg, 0, 1)  # awg_data_zero(wave_length(ns), en, port)
    # awg_data_zero(wave_leg, 0, 2)  # awg_data_zero(wave_length(ns), en, port)
    # awg_data_zero(wave_leg, 0, 3)  # awg_data_zero(wave_length(ns), en, port)
    # awg_data_zero(wave_leg, 0, 4)  # awg_data_zero(wave_length(ns), en, port)
    
    awg_data_sin(wave_leg, freq, amp, 1, 1)  # awg_data_sin(wave_length(ns), frequency(Mhz), amplitude(v), en, port)
    awg_data_sin(wave_leg, freq, amp, 1, 2)  # awg_data_sin(wave_length(ns), frequency(Mhz), amplitude(v), en, port)
    awg_data_sin(wave_leg, freq, amp, 1, 3)  # awg_data_sin(wave_length(ns), frequency(Mhz), amplitude(v), en, port)
    awg_data_sin(wave_leg, freq, amp, 1, 4)  # awg_data_sin(wave_length(ns), frequency(Mhz), amplitude(v), en, port)
    
    awg_data_cos(wave_leg, freq, amp, 0, 1)  # awg_data_cos(wave_length(ns), frequency(Mhz), amplitude(v), en, port)
    awg_data_cos(wave_leg, freq, amp, 0, 2)  # awg_data_cos(wave_length(ns), frequency(Mhz), amplitude(v), en, port)
    awg_data_cos(wave_leg, freq, amp, 0, 3)  # awg_data_cos(wave_length(ns), frequency(Mhz), amplitude(v), en, port)
    awg_data_cos(wave_leg, freq, amp, 0, 4)  # awg_data_cos(wave_length(ns), frequency(Mhz), amplitude(v), en, port)
    
    awg_data_guass_square(wave_leg, high_leg, amp, 0, 1)   # awg_data_guass_square(wave_length(ns), high_length(ns), amplitude(v), en, port)
    awg_data_guass_square(wave_leg, high_leg, amp, 0, 2)   # awg_data_guass_square(wave_length(ns), high_length(ns), amplitude(v), en, port)
    awg_data_guass_square(wave_leg, high_leg, amp, 0, 3)   # awg_data_guass_square(wave_length(ns), high_length(ns), amplitude(v), en, port)
    awg_data_guass_square(wave_leg, high_leg, amp, 0, 4)   # awg_data_guass_square(wave_length(ns), high_length(ns), amplitude(v), en, port)
    
    awg_data_square(wave_leg, high_leg, amp, 0, 1)  # awg_data_square(wave_length(ns), high_length(ns), amplitude(v), en, port)
    awg_data_square(wave_leg, high_leg, amp, 0, 2)  # awg_data_square(wave_length(ns), high_length(ns), amplitude(v), en, port)
    awg_data_square(wave_leg, high_leg, amp, 0, 3)  # awg_data_square(wave_length(ns), high_length(ns), amplitude(v), en, port)
    awg_data_square(wave_leg, high_leg, amp, 0, 4)  # awg_data_square(wave_length(ns), high_length(ns), amplitude(v), en, port)

    awg_data_customized_definition(0, 0, 1)  # awg_data_customized_definition(data, en, port)
    awg_data_customized_definition(0, 0, 2)  # awg_data_customized_definition(data, en, port)
    awg_data_customized_definition(0, 0, 3)  # awg_data_customized_definition(data, en, port)
    awg_data_customized_definition(0, 0, 4)  # awg_data_customized_definition(data, en, port)

    
    #AWG Test jitter
    awg_jitter(0)# awg_jitter(en)
    
    #AQL board en
    tc_trig(1)


    

