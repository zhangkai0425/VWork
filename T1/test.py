import ctypes
import os
import chardet
import binascii
from sys import getsizeof
import numpy as np
import math
import time
import matplotlib.pyplot as plt
import scipy as sp
from scipy.optimize import curve_fit
from scipy.fftpack import fft, ifft
from scipy import signal
import librosa
import numpy.ctypeslib as npct
from scipy.stats import norm
from scipy.stats.stats import SpearmanrResult


class AQLAD:
    def readout(self, cycle, length, addr, mode):
        ch_wave_0 = {}
        ch_wave_1 = {}
        ch_wave = {}
        ch_iq = {}
        base = [2048*16, 2048*16, 2048*16, 2048*16]
        # base=[0,0,0,0]
        amp = [1755*16, 1755*16, 1755*16, 1755*16]
        if mode == 0:
            data_byte = ctypes.string_at(addr, 8*length*cycle)
        else:
            data_byte = ctypes.string_at(addr, 64*cycle)
        data_hex = np.array(bytearray(data_byte))
        data_row_1 = data_hex.reshape((2, -1), order="F")
        data_row_2 = (data_row_1[0]+256*data_row_1[1])
        sign = (data_row_2 >> 15) & 1
        wave_row_1 = data_row_2 - sign*2**16 + 2**15
        wave_row_2 = np.array(wave_row_1, dtype=float)
        wave_row = wave_row_2.reshape((32, -1), order="F")
        #b,a=signal.butter(8,0.86,'lowpass')

        for i in range(0, 4):
            if mode == 0:
                ch_wave_0[i+1] = (base[i]-np.vstack((wave_row[3+8*i], wave_row[7+8*i], wave_row[2+8*i], wave_row[6+8*i], wave_row[1+8*i], wave_row[5+8*i], wave_row[0+8*i], wave_row[4+8*i])))/amp[i]
                ch_wave_1[i+1] = np.ravel(ch_wave_0[i+1], order='F')
                ch_wave[i+1] = np.zeros([cycle, 1, length])
                ch_iq[i+1] = np.zeros([cycle, 1, 1])
            else:
                ch_iq[i+1] = np.zeros([cycle, 1, 1])
        for n in range(0, 4):
            for m in range(0, cycle):
                delta = int((m)*length)
                if mode == 0:
                    ch_wave[n+1][m][0] = ch_wave_1[n+1][delta:delta+length]
                    ch_iq_1 = data_row_2[length*4*(m+1)-16+(3-n)*2]+data_row_2[length*4*(m+1)-16+1+(3-n)*2]*2**16
                    sign_iq = (ch_iq_1 >> 31) & 1
                    ch_iq_2 = (ch_iq_1 - 0*2**32 + 2**31)
                    ch_iq[n+1][m][0] = (2**31-ch_iq_2)/(length-16)/amp[i]
                else:
                    ch_iq_1 = data_row_2[32*m+16+(3-n)*2]+data_row_2[32*m+16+1+(3-n)*2]*2**16
                    # sign_iq = (ch_iq_1>>31)&1
                    ch_iq_2 = ch_iq_1 - 0*(2**32)+2**31
                    # ch_iq[n+1][m][0] = ch_iq_2#/(length-16)/amp[i]/4
                    ch_iq[n+1][m][0] = (2**31-ch_iq_2)/(length-16)/amp[i]/4
                    # ch_iq_1 = int(ch_iq_1,32)
                    # if (ch_iq_1&0x80000000==0x80000000):
                    #     ch_iq_1 = -(ch_iq_1-1)^0xffffffff
                    # ch_iq[n+1][m][0] = ch_iq_1

        if mode == 0:
            ch_wave[2] = -ch_wave[2]
            ch_wave[4] = -ch_wave[4]
            # return ch_wave, ch_iq
            return ch_wave
        else:
            ch_iq[2] = ch_iq[2]
            ch_iq[4] = ch_iq[4]
            return ch_iq

    def offset_calibration(self, sn_id_tc):
        cali = {}
        offset_cal = {}
        ch_average = {}
        offset = 2032*0.0005
        DRIVER_ELEC.ad_cfg(1, 2048, 0, sn_id_tc)
        DRIVER_ELEC.ad_mode(0, sn_id_tc)
        time.sleep(1)
        DRIVER_ELEC.ad_readout.restype = ctypes.c_uint64
        AD = AQLAD()
        cali = [1, 1, 1, 1]
        offset_cal = [58, 111, 76, 10]
        while(cali != [0, 0, 0, 0]):
            DRIVER_ELEC.tc_trig(sn_id_tc)
            addr = DRIVER_ELEC.ad_readout(1, 2048, 3000, sn_id_tc)
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
            DRIVER_ELEC.ad_offsetcali(offset_cal[0], offset_cal[1], offset_cal[2], offset_cal[3], sn_id_tc)
        return True


def volt2code(volt):
    if volt >= 0:
        cod = math.ceil(volt/5*(2**19-1)+2**20)
    else:
        cod = math.ceil(2**21+volt/5*(2**19-1))
    return cod


def volt_awg(volt):
    tmp = np.asarray(volt)
    '''
    for n in range(0,tmp.size):
        if tmp[n]>=0 :
            tmp[n] = math.ceil(tmp[n]/625*1000*(2**13-1))
        else:
            tmp[n] = math.ceil(2**16+tmp[n]/625*1000*(2**13-1))
    '''
    for n in range(0, tmp.size):
        if tmp[n] > 0:
            tmp[n] = math.ceil(2**16-tmp[n]/625*1000*(2**13-1))
        else:
            tmp[n] = math.ceil(-tmp[n]/625*1000*(2**13-1))

    tmp = tmp.astype(int)
    return tmp


def volt2offset(volt):
    if volt >= 0:
        cod = math.ceil(volt/625*(2**13-1))
    else:
        cod = math.ceil(2**14+volt/625*(2**13-1))
    return cod


def RadianToPoff(Radian):
    return(math.ceil((Radian/(2*math.pi))*(2**24)))


def Gauss_function(t, A, sigma):
    return (A * math.exp(- (t * t) / (2 * sigma * sigma)))


def Triple_function(t, A, freq, phi_0):
    return (math.fabs((t)*0.2/2000))


def Square_function(t, A, sigma):
    return (A)


def Sin_function(t, A, freq, phi_0):
    return(A*math.sin(2*np.pi*freq/2000*t+phi_0))


def Cos_function(t, A, freq, phi_0):
    return(A*math.cos(2*np.pi*freq/2000*t+phi_0))


def Phase_To_Digital(phase):
    poff = math.ceil((phase/(2*math.pi))*(2**24)) & 0xffffff
    return poff


def Epsilon_To_Digital(epsilon):
    digital = math.ceil((epsilon)*(2**15)) & 0xffff
    return digital


def awg_IQ_Correction_Amp(mixer_id, i_amp, q_amp):
    i_amp_digital = Epsilon_To_Digital(i_amp)
    q_amp_digital = Epsilon_To_Digital(q_amp)
    DRIVER_ELEC.awg_multi_IQ_Correction_Amp(mixer_id, i_amp_digital, q_amp_digital, AWG_ID)
    return 0


def awg_IQ_Correction_Phase(mixer_id, i_phase, q_phase):
    i_phase_digital = Phase_To_Digital(i_phase)
    q_phase_digital = Phase_To_Digital(q_phase)
    DRIVER_ELEC.awg_multi_IQ_Correction_Phase(mixer_id, i_phase_digital, q_phase_digital, AWG_ID)
    return 0


def awg_mixer_freq(mixer_id, frequency):
    # DRIVER_ELEC.awg_multi_frequency(frequency, mixer_id, AWG_ID)
    # frequency = int(frequency*1000000)
    DRIVER_ELEC.awg_multi_frequency(int(frequency*1000000), mixer_id, AWG_ID)
    print("Hw Mixer%d freq [%.2fMhz]" % (mixer_id, frequency))
    return 0


def awg_mixer_config(mixer_id, port_comb, mixer_on):
    if(mixer_on):
        print("Hw Mixer%d {ON}" % (mixer_id))
    else:
        print("Hw Mixer%d {OFF}" % (mixer_id))
    tmp_ram = np.array(port_comb).astype(int)
    mixer_ram = tmp_ram.ctypes.data_as(ctypes.c_char_p)
    tmp_port = np.array(port_comb).astype(int)
    mixer_port = tmp_port.ctypes.data_as(ctypes.c_char_p)
    DRIVER_ELEC.awg_multi_mixer_config(mixer_id, mixer_on, mixer_ram, mixer_port, AWG_ID)
    return 0


def awg_mode_continue(en):
    if(en == 1):
        DRIVER_ELEC.awg_cw_mode(1, AWG_ID)
        print("AWG CW {ON}")
    else:
        DRIVER_ELEC.awg_cw_mode(0, AWG_ID)
        print("AWG CW {OFF}")
    return 0


def awg_send_wave(data, length, addr_begin, port):
    DRIVER_ELEC.send_waveform_data(data, length, addr_begin, port, AWG_ID)
    return 0


def awg_play_wave(delay, length, addr_begin, number, port):
    DRIVER_ELEC.awg_multi_delay(delay, port, number, AWG_ID)
    DRIVER_ELEC.awg_multi_length(length, port, number, AWG_ID)
    DRIVER_ELEC.awg_multi_addr(addr_begin, port, number, AWG_ID)
    return 0


def awg_wave_number(efficient_wavenum, port):
    DRIVER_ELEC.awg_multi_wavenum(efficient_wavenum, port, AWG_ID)
    return 0


def zero_data(awg_wave_length):
    point_num = awg_wave_length*2
    wave = np.zeros(point_num)
    tmp = volt_awg(wave)
    tmp.ctypes.data_as(ctypes.c_char_p)
    data = tmp.ctypes.data_as(ctypes.c_char_p)
    return data


def one_data(awg_wave_length, amplitude):
    point_num = awg_wave_length*2
    wave = np.zeros(point_num)
    for i in range(0, point_num-8):
        wave[i] = amplitude
    # plt.figure(1)
    # plt.plot(wave)
    # plt.show()

    tmp = volt_awg(wave)
    data = tmp.ctypes.data_as(ctypes.c_char_p)
    return data


def sin_data(awg_wave_length, amplitude, frequency):
    point_num = awg_wave_length*2
    wave = np.zeros(point_num)
    for i in range(0, point_num-8):
        wave[i] = Sin_function(i, amplitude, frequency, 0)
    tmp = volt_awg(wave)
    data = tmp.ctypes.data_as(ctypes.c_char_p)
    return data


def square_pos_data(wave_length, pos_length, amplitude):
    leg = wave_length*2
    pos_leg = pos_length*2
    square_wave1 = np.zeros(leg)
    square_wave1_pos = np.zeros(pos_leg)
    square_wave1_neg = np.zeros(pos_leg)
    for i in range(100, leg-100):
        square_wave1[i] = Square_function(i, amplitude, 30)
    for i in range(0, pos_leg):
        square_wave1_pos[i] = square_wave1[i]
    for i in range(0, pos_leg):
        square_wave1_neg[i] = square_wave1[i+leg-pos_leg]

    # plt.figure(1)
    # plt.plot(square_wave1_pos)
    # plt.show()

    tmp_square_wave1_pos = volt_awg(square_wave1_pos)
    Wave1data_5us_pos = tmp_square_wave1_pos.ctypes.data_as(ctypes.c_char_p)

    return Wave1data_5us_pos


def square_neg_data(wave_length, neg_length, amplitude):
    leg = wave_length*2
    neg_leg = neg_length*2
    square_wave1 = np.zeros(leg)
    square_wave1_pos = np.zeros(neg_leg)
    square_wave1_neg = np.zeros(neg_leg)
    for i in range(100, leg-100):
        square_wave1[i] = Square_function(i, amplitude, 30)
    for i in range(0, neg_leg):
        square_wave1_pos[i] = square_wave1[i]
    for i in range(0, neg_leg):
        square_wave1_neg[i] = square_wave1[i+leg-neg_leg]

    # plt.figure(1)
    # plt.plot(square_wave1_neg)
    # plt.show()

    tmp_square_wave1_neg = volt_awg(square_wave1_neg)
    Wave1data_5us_neg = tmp_square_wave1_neg.ctypes.data_as(ctypes.c_char_p)
    return Wave1data_5us_neg


def guass_square_data(wave_length, high_length, amplitude):

    awg_data_length = wave_length*2
    high_length = high_length*2
    wave = Guass_Square_function(awg_data_length, high_length, amplitude)
    tmp = volt_awg(wave)
    square_data = tmp.ctypes.data_as(ctypes.c_char_p)
    return square_data


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


def square_data(awg_wave_length, amplitude):
    point_num = awg_wave_length*2
    wave = np.zeros(point_num)
    for i in range(0, point_num-8):
        wave[i] = Square_function(i, amplitude, 30)

    # plt.plot(wave)
    # plt.figure(1)
    # plt.show()

    tmp = volt_awg(wave)
    data = tmp.ctypes.data_as(ctypes.c_char_p)
    return data


def guass_pos_data(wave_length, pos_length, amplitude):

    awg_data_length = wave_length*2
    pos_leg = pos_length*2
    neg_leg = pos_length*2
    u = 0  # 均值μ
    u01 = 6
    sig = math.sqrt(0.1)  # 标准差δ
    sig_u01 = math.sqrt(1)
    x_01 = np.linspace(u - 5 * sig, u + 20 * sig, 100)
    x_u01 = np.linspace(u - 10 * sig, u + 40 * sig, 100)
    y_sig_u01 = np.exp(-(x_u01 - u01) ** 2 / (2 * sig_u01 ** 2)) / (math.sqrt(2 * math.pi) * sig_u01)
    y_sig_u01 = y_sig_u01*2.5

    b = np.zeros(awg_data_length)
    pos = int(pos_leg/2)
    neg = pos+wave_length
    for i in range(0, awg_data_length):
        if(pos < i < neg):
            b[i] = 1

    for i in range(0, 100):
        if(i < 58):
            b[pos+i-57] = y_sig_u01[i]
        else:
            b[neg+i-58] = y_sig_u01[i]

    A = b*(amplitude)

    pos_data = np.zeros(pos_leg)
    neg_data = np.zeros(neg_leg)

    for i in range(0, pos_leg):
        pos_data[i] = A[i]
    for i in range(0, neg_leg):
        neg_data[i] = A[i+neg-pos]

    # plt.plot(pos_data, label='square_neg')
    # plt.figure(1)
    # plt.legend()
    # plt.show()

    tmp_pos_data = volt_awg(pos_data)
    pos_1us = tmp_pos_data.ctypes.data_as(ctypes.c_char_p)

    return pos_1us


def guass_neg_data(wave_length, pos_length, amplitude):

    awg_data_length = wave_length*2
    pos_leg = pos_length*2
    neg_leg = pos_length*2
    u = 0  # 均值μ
    u01 = 6
    sig = math.sqrt(0.1)  # 标准差δ
    sig_u01 = math.sqrt(1)
    x_01 = np.linspace(u - 5 * sig, u + 20 * sig, 100)
    x_u01 = np.linspace(u - 10 * sig, u + 40 * sig, 100)
    y_sig_u01 = np.exp(-(x_u01 - u01) ** 2 / (2 * sig_u01 ** 2)) / (math.sqrt(2 * math.pi) * sig_u01)
    y_sig_u01 = y_sig_u01*2.5

    b = np.zeros(awg_data_length)
    pos = int(pos_leg/2)
    neg = pos+wave_length
    for i in range(0, awg_data_length):
        if(pos < i < neg):
            b[i] = 1

    for i in range(0, 100):
        if(i < 58):
            b[pos+i-57] = y_sig_u01[i]
        else:
            b[neg+i-58] = y_sig_u01[i]

    A = b*(amplitude)

    pos_data = np.zeros(pos_leg)
    neg_data = np.zeros(neg_leg)

    for i in range(0, pos_leg):
        pos_data[i] = A[i]
    for i in range(0, neg_leg):
        neg_data[i] = A[i+neg-pos]

    # plt.plot(neg_data, label='square_neg')
    # plt.figure(1)
    # plt.legend()
    # plt.show()

    tmp_neg_data = volt_awg(neg_data)
    neg_1us = tmp_neg_data.ctypes.data_as(ctypes.c_char_p)

    return neg_1us


def tb_awg_N_pulse(en):
    if(en):
        print("-----------------------")
        print("'TEST N PULSE'")
        number = 4
        print("pulse number [%d]" % number)
        awg_wave_length = 8  # ns

        # data1 = square_data(awg_wave_length, 0.1)
        # data2 = square_data(awg_wave_length, 0.2)
        # data3 = square_data(awg_wave_length, 0.1)
        # data4 = square_data(awg_wave_length, 0.2)

        data1 = sin_data(awg_wave_length, 0.1, 125)
        data2 = sin_data(awg_wave_length, 0.2, 125)
        data3 = sin_data(awg_wave_length, 0.1, 125)
        data4 = sin_data(awg_wave_length, 0.2, 125)

        awg_wave_number(number, 1)  # awg_wave_number(efficient_wavenum, port)
        awg_wave_number(number, 2)
        awg_wave_number(number, 3)
        awg_wave_number(number, 4)

        length1 = int(awg_wave_length/4)
        length2 = int(awg_wave_length/4)
        length3 = int(awg_wave_length/4)
        length4 = int(awg_wave_length/4)

        addr_begin1 = 0
        addr_begin2 = addr_begin1 + length1
        addr_begin3 = addr_begin2 + length2
        addr_begin4 = addr_begin3 + length3

        awg_send_wave(data1, length1, addr_begin1, 1)
        awg_send_wave(data1, length1, addr_begin1, 2)
        awg_send_wave(data1, length1, addr_begin1, 3)
        awg_send_wave(data1, length1, addr_begin1, 4)

        awg_send_wave(data2, length2, addr_begin2, 1)
        awg_send_wave(data2, length2, addr_begin2, 2)
        awg_send_wave(data2, length2, addr_begin2, 3)
        awg_send_wave(data2, length2, addr_begin2, 4)

        awg_send_wave(data3, length3, addr_begin3, 1)
        awg_send_wave(data3, length3, addr_begin3, 2)
        awg_send_wave(data3, length3, addr_begin3, 3)
        awg_send_wave(data3, length3, addr_begin3, 4)

        awg_send_wave(data4, length4, addr_begin4, 1)
        awg_send_wave(data4, length4, addr_begin4, 2)
        awg_send_wave(data4, length4, addr_begin4, 3)
        awg_send_wave(data4, length4, addr_begin4, 4)

        delay1 = 0
        delay2 = delay1 + length1 - 1
        delay3 = delay2 + length2 - 1
        delay4 = delay3 + length3 - 1

        awg_play_wave(delay1, length1, addr_begin1, 0, 1)
        awg_play_wave(delay1, length1, addr_begin1, 0, 2)
        awg_play_wave(delay1, length1, addr_begin1, 0, 3)
        awg_play_wave(delay1, length1, addr_begin1, 0, 4)

        awg_play_wave(delay2, length2, addr_begin2, 1, 1)
        awg_play_wave(delay2, length2, addr_begin2, 1, 2)
        awg_play_wave(delay2, length2, addr_begin2, 1, 3)
        awg_play_wave(delay2, length2, addr_begin2, 1, 4)

        awg_play_wave(delay3, length3, addr_begin3, 2, 1)
        awg_play_wave(delay3, length3, addr_begin3, 2, 2)
        awg_play_wave(delay3, length3, addr_begin3, 2, 3)
        awg_play_wave(delay3, length3, addr_begin3, 2, 4)

        awg_play_wave(delay4, length4, addr_begin4, 3, 1)
        awg_play_wave(delay4, length4, addr_begin4, 3, 2)
        awg_play_wave(delay4, length4, addr_begin4, 3, 3)
        awg_play_wave(delay4, length4, addr_begin4, 3, 4)

        amp = (0)  # (-1.0 ~ +1.0)
        awg_IQ_Correction_Amp(1, amp, amp)  # awg_IQ_Correction_Amp(mixer_id, i_amp, q_amp)
        awg_IQ_Correction_Amp(2, amp, amp)
        phase = (0)*(math.pi)  # (-2kπ ~ +2kπ)
        awg_IQ_Correction_Phase(1, phase, phase)  # awg_IQ_Correction_Phase(mixer_id, i_phase(π), q_phase(π))
        awg_IQ_Correction_Phase(2, phase, phase)
        awg_mixer_freq(1, 10)  # awg_mixer_freq(mixer_id, frequency(Mhz))
        awg_mixer_freq(2, 10)
        awg_mixer_config(1, [1, 2], 0)  # awg_mixer_config(mixer_id, port_comb, mixer_on)
        awg_mixer_config(2, [3, 4], 0)

        awg_mode_continue(0)  # awg_mode_continue(en)

        offset_cal = [0, 0, 0, 0]
        DRIVER_ELEC.awg_offset(offset_cal[0], 1, AWG_ID)
        DRIVER_ELEC.awg_offset(offset_cal[1], 2, AWG_ID)
        DRIVER_ELEC.awg_offset(offset_cal[2], 3, AWG_ID)
        DRIVER_ELEC.awg_offset(offset_cal[3], 4, AWG_ID)
        DRIVER_ELEC.awg_multi_Channel_Delay(160, 330, 180, 330, AWG_ID)  # AWG_XY
        DRIVER_ELEC.awg_multi_Channel_Delay_Set(AWG_ID)
        DRIVER_ELEC.awg_trig_mask(AWG_ID, 1, 1, 1, 1)  # awg_trig_mask(AWG_ID, port1, port2, port3, port4)

        DRIVER_ELEC.awg_multi_trig(AWG_ID)

        time.sleep(1)
    else:
        return 0


def initial_awg(en):
    if(en):
        print("-----------------------")
        print("'Power On Initial Config'")
        awg_wave_length = 10000  # ns
        zero_wave = zero_data(awg_wave_length)  # zero_data(awg_wave_length(ns))
        awg_wave_number(1, 1)  # awg_wave_number(efficient_wavenum, port)
        awg_wave_number(1, 2)
        awg_wave_number(1, 3)
        awg_wave_number(1, 4)
        length1 = int(awg_wave_length/4)
        awg_send_wave(zero_wave, length1, 0, 1)  # awg_send_wave(data, length, addr_begin, port)
        awg_send_wave(zero_wave, length1, 0, 2)
        awg_send_wave(zero_wave, length1, 0, 3)
        awg_send_wave(zero_wave, length1, 0, 4)
        awg_play_wave(0, length1, 0, 0, 1)  # awg_play_wave(delay, length, addr_begin, number, port)
        awg_play_wave(0, length1, 0, 0, 2)
        awg_play_wave(0, length1, 0, 0, 3)
        awg_play_wave(0, length1, 0, 0, 4)

        amp = (0)  # (-1.0 ~ +1.0)
        awg_IQ_Correction_Amp(1, amp, amp)  # awg_IQ_Correction_Amp(mixer_id, i_amp, q_amp)
        awg_IQ_Correction_Amp(2, amp, amp)
        phase = (0)*(math.pi)  # (-2kπ ~ +2kπ)
        awg_IQ_Correction_Phase(1, phase, phase)  # awg_IQ_Correction_Phase(mixer_id, i_phase(π), q_phase(π))
        awg_IQ_Correction_Phase(2, phase, phase)
        awg_mixer_freq(1, 10)  # awg_mixer_freq(mixer_id, frequency(Mhz))
        awg_mixer_freq(2, 10)
        awg_mixer_config(1, [1, 2], 0)  # awg_mixer_config(mixer_id, port_comb, mixer_on)
        awg_mixer_config(2, [3, 4], 0)

        awg_mode_continue(0)  # awg_mode_continue(en)

        offset_cal = [0, 0, 0, 0]
        DRIVER_ELEC.awg_offset(offset_cal[0], 1, AWG_ID)
        DRIVER_ELEC.awg_offset(offset_cal[1], 2, AWG_ID)
        DRIVER_ELEC.awg_offset(offset_cal[2], 3, AWG_ID)
        DRIVER_ELEC.awg_offset(offset_cal[3], 4, AWG_ID)
        DRIVER_ELEC.awg_multi_Channel_Delay(160, 330, 180, 330, AWG_ID)  # AWG_XY
        DRIVER_ELEC.awg_multi_Channel_Delay_Set(AWG_ID)
        DRIVER_ELEC.awg_trig_mask(AWG_ID, 1, 1, 1, 1)  # awg_trig_mask(AWG_ID, port1, port2, port3, port4)

        DRIVER_ELEC.awg_multi_trig(AWG_ID)
        time.sleep(1)
    else:
        return 0


def tb_awg_DDS(en):
    # def tb_awg_DDS(freq, set, en):
    if(en == 1):
        print("-----------------------")
        print("TEST DDS")
        freq = [0, 260]
        set = 20
        awg_wave_length = 10000  # ns
        high_length = awg_wave_length-1000  # ns
        amplitude = 0.4  # v

        dds_data = guass_square_data(awg_wave_length, high_length, amplitude)
        print("pulse number [1]")
        awg_wave_number(1, 1)
        awg_wave_number(1, 2)
        awg_wave_number(1, 3)
        awg_wave_number(1, 4)
        dds_length = int(awg_wave_length/4)
        awg_send_wave(dds_data, dds_length, 0, 1)  # awg_send_wave(data, length, addr_begin, port)
        awg_send_wave(dds_data, dds_length, 0, 2)
        awg_send_wave(dds_data, dds_length, 0, 3)
        awg_send_wave(dds_data, dds_length, 0, 4)
        awg_play_wave(0, dds_length, 0, 0, 1)  # awg_play_wave(delay, length, addr_begin, number, port)
        awg_play_wave(0, dds_length, 0, 0, 2)
        awg_play_wave(0, dds_length, 0, 0, 3)
        awg_play_wave(0, dds_length, 0, 0, 4)
        offset_cal = [0, 0, 0, 0]
        DRIVER_ELEC.awg_offset(offset_cal[0], 1, AWG_ID)
        DRIVER_ELEC.awg_offset(offset_cal[1], 2, AWG_ID)
        DRIVER_ELEC.awg_offset(offset_cal[2], 3, AWG_ID)
        DRIVER_ELEC.awg_offset(offset_cal[3], 4, AWG_ID)
        DRIVER_ELEC.awg_multi_Channel_Delay(160, 330, 180, 330, AWG_ID)  # AWG_XY
        DRIVER_ELEC.awg_multi_Channel_Delay_Set(AWG_ID)
        DRIVER_ELEC.awg_trig_mask(AWG_ID, 1, 1, 1, 1)  # awg_trig_mask(AWG_ID, port1, port2, port3, port4)
        DRIVER_ELEC.awg_multi_trig(AWG_ID)
        awg_mixer_config(1, [1, 2], 1)  # awg_mixer_config(mixer_id, port_comb, mixer_on)
        awg_mixer_config(2, [3, 4], 1)
        awg_mode_continue(0)  # awg_mode_continue(en)
        print("")
        for i in range(1, 2):
            for i in range(freq[0], freq[1], set):
                DDS_freq = i
                awg_mixer_freq(1, DDS_freq)  # awg_mixer_freq(mixer_id, frequency(Mhz))
                awg_mixer_freq(2, DDS_freq)

                # DRIVER_ELEC.awg_multi_trig(AWG_ID)
                tc_trig(1)

                print("")
                time.sleep(2)

        awg_mixer_config(1, [1, 2], 0)  # awg_mixer_config(mixer_id, port_comb, mixer_on)
        awg_mixer_config(2, [3, 4], 0)
        awg_mode_continue(0)  # awg_mode_continue(en)
        # DRIVER_ELEC.awg_multi_trig(AWG_ID)
        tc_trig(1)
    else:
        return 0


def tb_awg_CW(en):
    # def tb_awg_CW(freq, set, en):
    if(en == 1):
        print("-----------------------")
        print("TEST CONTINUE")
        print("pulse number [1]")
        freq = [0, 220]
        set = 20
        awg_wave_length = 10000  # ns
        amplitude = 0.4  # v

        cw_data = one_data(awg_wave_length, amplitude)
        awg_wave_number(1, 1)  # awg_wave_number(efficient_wavenum, port)
        awg_wave_number(1, 2)
        awg_wave_number(1, 3)
        awg_wave_number(1, 4)
        cw_length = int(awg_wave_length/4)
        awg_send_wave(cw_data, cw_length, 0, 1)  # awg_send_wave(data, length, addr_begin, port)
        awg_send_wave(cw_data, cw_length, 0, 2)
        awg_send_wave(cw_data, cw_length, 0, 3)
        awg_send_wave(cw_data, cw_length, 0, 4)
        awg_play_wave(0, cw_length, 0, 0, 1)  # awg_play_wave(delay, length, addr_begin, number, port)
        awg_play_wave(0, cw_length, 0, 0, 2)
        awg_play_wave(0, cw_length, 0, 0, 3)
        awg_play_wave(0, cw_length, 0, 0, 4)
        offset_cal = [0, 0, 0, 0]
        DRIVER_ELEC.awg_offset(offset_cal[0], 1, AWG_ID)
        DRIVER_ELEC.awg_offset(offset_cal[1], 2, AWG_ID)
        DRIVER_ELEC.awg_offset(offset_cal[2], 3, AWG_ID)
        DRIVER_ELEC.awg_offset(offset_cal[3], 4, AWG_ID)
        DRIVER_ELEC.awg_multi_Channel_Delay(160, 330, 180, 330, AWG_ID)  # AWG_XY
        DRIVER_ELEC.awg_multi_Channel_Delay_Set(AWG_ID)
        DRIVER_ELEC.awg_trig_mask(AWG_ID, 1, 1, 1, 1)  # awg_trig_mask(AWG_ID, port1, port2, port3, port4)
        DRIVER_ELEC.awg_multi_trig(AWG_ID)
        awg_mixer_config(1, [1, 2], 1)  # awg_mixer_config(mixer_id, port_comb, mixer_on)
        awg_mixer_config(2, [3, 4], 1)
        print("")
        for i in range(1, 2):
            for i in range(freq[0], freq[1], set):
                awg_mode_continue(0)  # awg_mode_continue(en)
                DRIVER_ELEC.awg_multi_trig(AWG_ID)
                time.sleep(1)
                DDS_freq = i
                awg_mixer_freq(1, DDS_freq)  # awg_mixer_freq(mixer_id, frequency(Mhz))
                awg_mixer_freq(2, DDS_freq)
                awg_mode_continue(1)  # awg_mode_continue(en)

                # DRIVER_ELEC.awg_multi_trig(AWG_ID)
                tc_trig(1)

                print("")
                time.sleep(5)

        awg_mixer_config(1, [1, 2], 0)  # awg_mixer_config(mixer_id, port_comb, mixer_on)
        awg_mixer_config(2, [3, 4], 0)
        awg_mode_continue(0)  # awg_mode_continue(en)

        # DRIVER_ELEC.awg_multi_trig(AWG_ID)
        tc_trig(1)

    else:
        return 0


def test_dac1_dci_delay(en):
    if(en == 1):
        for i in range(0, 500, 10):
            DRIVER_ELEC.awg_multi_Channel_Delay(i, 330, 180, 330, AWG_ID)
            DRIVER_ELEC.awg_multi_Channel_Delay_Set(AWG_ID)
            DRIVER_ELEC.awg_multi_trig(AWG_ID)
            print("dac1_dci_delay = %d." % (i))
            time.sleep(5)
    else:
        return 0


def test_dac2_dci_delay(en):
    if(en == 1):
        for i in range(0, 500, 10):
            DRIVER_ELEC.awg_multi_Channel_Delay(160, i, 180, 330, AWG_ID)
            DRIVER_ELEC.awg_multi_Channel_Delay_Set(AWG_ID)
            DRIVER_ELEC.awg_multi_trig(AWG_ID)
            print("dac2_dci_delay = %d." % (i))
            time.sleep(5)
    else:
        return 0


def test_dac3_dci_delay(en):
    if(en == 1):
        for i in range(120, 210, 10):
            DRIVER_ELEC.awg_multi_Channel_Delay(160, 330, i, 330, AWG_ID)
            DRIVER_ELEC.awg_multi_Channel_Delay_Set(AWG_ID)
            DRIVER_ELEC.awg_multi_trig(AWG_ID)
            print("dac3_dci_delay = %d." % (i))
            time.sleep(5)
    else:
        return 0


def test_dac4_dci_delay(en):
    if(en == 1):
        for i in range(0, 500, 10):
            DRIVER_ELEC.awg_multi_Channel_Delay(160, 330, 180, i, AWG_ID)
            DRIVER_ELEC.awg_multi_Channel_Delay_Set(AWG_ID)
            DRIVER_ELEC.awg_multi_trig(AWG_ID)
            print("dac4_dci_delay = %d." % (i))
            time.sleep(5)
    else:
        return 0


def print_config():
    # if(en):
    print("-----------------------")
    print("TC_ID  '%s'" % (TC_ID))
    print("AD_ID  '%s'" % (AD_ID))
    print("AWG_ID '%s'" % (AWG_ID))
    print("Cycle        [%d]" % (cycle))
    print("Cycle Length [%dus]" % (tc_delay/125))
    print("AWG_delay %dns" % (awg_delay*4))
    print("AD_delay  %dns" % (ad_delay*8))
    # else:
    #     return 0


def ad_print_1(data, cycle, en):
    if(en == 1):
        plt.figure(1)
        plt.plot(data[1][0][0], "r-", label='ch1')
        plt.plot(data[2][0][0], "b-", label='ch2')
        plt.plot(data[3][0][0], "g-", label='ch3')
        plt.plot(data[4][0][0], "y-", label='ch4')
        plt.title('AD[%s] 1234' % (AD_ID))
        plt.xlabel('time(ns)')
        plt.ylabel('amplitude(V)')
        plt.legend()
        # plt.title('AD ch1~ch4')
        # plt.title(r'AD DDS_freq %dMhz' % (DDS_freq))
        # plt.title(r'AD frequency %dMhz' % (frequency))
        for m in range(0, cycle):
            plt.figure(1)
            plt.plot(data[1][m][0], "r-")
            plt.plot(data[2][m][0], "b-")
            plt.plot(data[3][m][0], "g-")
            plt.plot(data[4][m][0], "y-")
        plt.show()
    else:
        return 0


def ad_print_2(data, cycle, en):
    if(en == 1):
        plt.figure(1)
        plt.plot(data[1][0][0], "r-", label='ch1')
        plt.plot(data[2][0][0], "b-", label='ch2')
        plt.title('AD[%s] 12' % (AD_ID))
        plt.xlabel('time(ns)')
        plt.ylabel('amplitude(V)')
        plt.legend()
        plt.figure(2)
        plt.plot(data[3][0][0], "g-", label='ch3')
        plt.plot(data[4][0][0], "y-", label='ch4')
        plt.title('AD[%s] 34' % (AD_ID))
        plt.xlabel('time(ns)')
        plt.ylabel('amplitude(V)')
        plt.legend()
        for m in range(0, cycle):
            plt.figure(1)
            plt.plot(data[1][m][0], "r-")
            plt.plot(data[2][m][0], "b-")
            plt.figure(2)
            plt.plot(data[3][m][0], "g-")
            plt.plot(data[4][m][0], "y-")
        plt.show()
    else:
        return 0
    return 0


def ad_print_4(data, cycle, en):
    if(en == 1):
        fig, axs = plt.subplots(2, 2)
        axs[0, 0].plot(data[1][0][0], "r-")
        axs[0, 0].set_title('AD[%s] ch1' % (AD_ID))
        axs[0, 0].set_xlabel('time(ns)')
        axs[0, 0].set_ylabel('amplitude(V)')

        axs[1, 0].plot(data[2][0][0], "b-")
        axs[1, 0].set_title('AD[%s] ch2' % (AD_ID))
        axs[1, 0].set_xlabel('time(ns)')
        axs[1, 0].set_ylabel('amplitude(V)')

        axs[0, 1].plot(data[3][0][0], "g-")
        axs[0, 1].set_title('AD[%s] ch3' % (AD_ID))
        axs[0, 1].set_xlabel('time(ns)')
        axs[0, 1].set_ylabel('amplitude(V)')

        axs[1, 1].plot(data[4][0][0], "y-")
        axs[1, 1].set_title('AD[%s] ch4' % (AD_ID))
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


def tc_trig(en):
    if(en == 1):
        # ad and tc config
        length = 2048
        timeout = 3000
        ad_mode = 0
        DRIVER_ELEC.switch_cfg(0x10, 0x10, AD_ID)
        DRIVER_ELEC.ad_cfg(cycle, length, ad_delay, AD_ID)
        DRIVER_ELEC.ad_mode(ad_mode, AD_ID, int(100*1e6), 0)
        time.sleep(1)
        DRIVER_ELEC.tc_cfg(tc_delay, cycle, TC_ID)
        DRIVER_ELEC.ad_malloc.restype = ctypes.c_uint64
        addr = DRIVER_ELEC.ad_malloc(cycle, length)
        DRIVER_ELEC.ad_start.argtypes = [ctypes.c_int, ctypes.c_int, ctypes.c_wchar_p, ctypes.c_uint64]
        DRIVER_ELEC.ad_start(cycle, length, AD_ID, addr, ad_mode)
        DRIVER_ELEC.tc_trig(TC_ID)
        time.sleep(1)
        readdone = DRIVER_ELEC.ad_done(timeout)
        AD = AQLAD()
        data = AD.readout(cycle, length, addr, ad_mode)
        DRIVER_ELEC.ad_free.argtypes = [ctypes.c_uint64]
        DRIVER_ELEC.ad_free(addr)
        # ad_print_1(data, cycle, 1)
        return data
    else:
        return 0


def tb_ad_switch_out(en):
    if(en):
        print("-----------------------")
        print("TEST AD switch out")
        hold = 800  # ns
        delay = 10  # ns
        DRIVER_ELEC.switch_cfg(int(hold/8), int(delay/8), AD_ID)  # hold 1=8ns, delay 1=8ns, hold + delay < tc_delay
        DRIVER_ELEC.tc_trig(TC_ID)
        print("switch length [%dns]" % (hold))
        print("switch delay  [%dns]" % (delay))
    else:
        return 0


def tb_ad_jitter(en):
    if(en == 1):
        print("-----------------------")
        print("TEST AWG Jitter")
        print("pulse number [1]")
        awg_wave_length = 1000  # ns
        amplitude = 0.3  # v
        frequency = 10
        DDS_freq = 10

        sin_wave = sin_data(awg_wave_length, amplitude, frequency)
        awg_wave_number(1, 1)  # awg_wave_number(efficient_wavenum, port)
        awg_wave_number(1, 2)
        awg_wave_number(1, 3)
        awg_wave_number(1, 4)
        cw_length = int(awg_wave_length/4)
        awg_send_wave(sin_wave, cw_length, 0, 1)  # awg_send_wave(data, length, addr_begin, port)
        awg_send_wave(sin_wave, cw_length, 0, 2)
        awg_send_wave(sin_wave, cw_length, 0, 3)
        awg_send_wave(sin_wave, cw_length, 0, 4)
        awg_play_wave(0, cw_length, 0, 0, 1)  # awg_play_wave(delay, length, addr_begin, number, port)
        awg_play_wave(0, cw_length, 0, 0, 2)
        awg_play_wave(0, cw_length, 0, 0, 3)
        awg_play_wave(0, cw_length, 0, 0, 4)

        amp = (0)  # (-1.0 ~ +1.0)
        awg_IQ_Correction_Amp(1, amp, amp)  # awg_IQ_Correction_Amp(mixer_id, i_amp, q_amp)
        awg_IQ_Correction_Amp(2, amp, amp)
        phase = (0)*(math.pi)  # (-2kπ ~ +2kπ)
        awg_IQ_Correction_Phase(1, phase, phase)  # awg_IQ_Correction_Phase(mixer_id, i_phase(π), q_phase(π))
        awg_IQ_Correction_Phase(2, phase, phase)
        awg_mixer_freq(1, DDS_freq)  # awg_mixer_freq(mixer_id, frequency(Mhz))
        awg_mixer_freq(2, DDS_freq)
        awg_mixer_config(1, [1, 2], 0)  # awg_mixer_config(mixer_id, port_comb, mixer_on)
        awg_mixer_config(2, [3, 4], 0)

        awg_mode_continue(0)  # awg_mode_continue(en)

        offset_cal = [0, 0, 0, 0]
        DRIVER_ELEC.awg_offset(offset_cal[0], 1, AWG_ID)
        DRIVER_ELEC.awg_offset(offset_cal[1], 2, AWG_ID)
        DRIVER_ELEC.awg_offset(offset_cal[2], 3, AWG_ID)
        DRIVER_ELEC.awg_offset(offset_cal[3], 4, AWG_ID)
        DRIVER_ELEC.awg_multi_Channel_Delay(160, 330, 180, 330, AWG_ID)  # AWG_XY
        DRIVER_ELEC.awg_multi_Channel_Delay_Set(AWG_ID)
        DRIVER_ELEC.awg_trig_mask(AWG_ID, 1, 1, 1, 1)  # awg_trig_mask(AWG_ID, port1, port2, port3, port4)

        data = tc_trig(1)
        print("waiting...")
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
        plt.show()
        # ad_print_4(data, cycle, 1)
    else:
        return 0


def tb_AD_collect(en):
    if(en == 1):
        print("-----------------------")
        print("TEST AD Collect")
        number = 3
        print("pulse number [%d]" % number)
        awg_wave_length = 100  # ns
        DDS_freq = 10

        # guass_wave = guass_square_data(awg_wave_length, high_length, amplitude)
        data1 = square_data(awg_wave_length, 0.1)
        data2 = square_data(awg_wave_length, 0.2)
        data3 = square_data(awg_wave_length, 0.3)

        awg_wave_number(number, 1)  # awg_wave_number(efficient_wavenum, port)
        awg_wave_number(number, 2)
        awg_wave_number(number, 3)
        awg_wave_number(number, 4)

        length1 = int(awg_wave_length/4)
        length2 = int(awg_wave_length/4)
        length3 = int(awg_wave_length/4)

        addr_begin1 = 0
        addr_begin2 = addr_begin1 + length1
        addr_begin3 = addr_begin2 + length2

        awg_send_wave(data1, length1, addr_begin1, 1)
        awg_send_wave(data1, length1, addr_begin1, 2)
        awg_send_wave(data1, length1, addr_begin1, 3)
        awg_send_wave(data1, length1, addr_begin1, 4)

        awg_send_wave(data2, length2, addr_begin2, 1)
        awg_send_wave(data2, length2, addr_begin2, 2)
        awg_send_wave(data2, length2, addr_begin2, 3)
        awg_send_wave(data2, length2, addr_begin2, 4)

        awg_send_wave(data3, length3, addr_begin3, 1)
        awg_send_wave(data3, length3, addr_begin3, 2)
        awg_send_wave(data3, length3, addr_begin3, 3)
        awg_send_wave(data3, length3, addr_begin3, 4)

        delay1 = 0
        delay2 = delay1 + length1 + int(200/4)
        delay3 = delay2 + length2 + int(200/4)

        awg_play_wave(delay1, length1, addr_begin1, 0, 1)
        awg_play_wave(delay1, length1, addr_begin1, 0, 2)
        awg_play_wave(delay1, length1, addr_begin1, 0, 3)
        awg_play_wave(delay1, length1, addr_begin1, 0, 4)

        awg_play_wave(delay2, length2, addr_begin2, 1, 1)
        awg_play_wave(delay2, length2, addr_begin2, 1, 2)
        awg_play_wave(delay2, length2, addr_begin2, 1, 3)
        awg_play_wave(delay2, length2, addr_begin2, 1, 4)

        awg_play_wave(delay3, length3, addr_begin3, 2, 1)
        awg_play_wave(delay3, length3, addr_begin3, 2, 2)
        awg_play_wave(delay3, length3, addr_begin3, 2, 3)
        awg_play_wave(delay3, length3, addr_begin3, 2, 4)

        amp = (0)  # (-1.0 ~ +1.0)
        awg_IQ_Correction_Amp(1, amp, amp)  # awg_IQ_Correction_Amp(mixer_id, i_amp, q_amp)
        awg_IQ_Correction_Amp(2, amp, amp)
        phase = (0)*(math.pi)  # (-2kπ ~ +2kπ)
        awg_IQ_Correction_Phase(1, phase, phase)  # awg_IQ_Correction_Phase(mixer_id, i_phase(π), q_phase(π))
        awg_IQ_Correction_Phase(2, phase, phase)
        awg_mixer_freq(1, DDS_freq)  # awg_mixer_freq(mixer_id, frequency(Mhz))
        awg_mixer_freq(2, DDS_freq)
        awg_mixer_config(1, [1, 2], 0)  # awg_mixer_config(mixer_id, port_comb, mixer_on)
        awg_mixer_config(2, [3, 4], 0)

        awg_mode_continue(0)  # awg_mode_continue(en)

        offset_cal = [0, 0, 0, 0]
        DRIVER_ELEC.awg_offset(offset_cal[0], 1, AWG_ID)
        DRIVER_ELEC.awg_offset(offset_cal[1], 2, AWG_ID)
        DRIVER_ELEC.awg_offset(offset_cal[2], 3, AWG_ID)
        DRIVER_ELEC.awg_offset(offset_cal[3], 4, AWG_ID)
        DRIVER_ELEC.awg_multi_Channel_Delay(160, 330, 180, 330, AWG_ID)  # AWG_XY
        DRIVER_ELEC.awg_multi_Channel_Delay_Set(AWG_ID)
        DRIVER_ELEC.awg_trig_mask(AWG_ID, 1, 1, 1, 1)  # awg_trig_mask(AWG_ID, port1, port2, port3, port4)
        # tc_trig(1)
        data = tc_trig(1)
        ad_print_4(data, cycle, 1)
    else:
        return 0


def tb_AD_demodultion(en):
    if(en):
        print("-----------------------")
        print("TEST AD Demodultion")
        print("pulse number [1]")

        cycle = 500
        awg_mode = 1  # 0 software modulation / 1 hardware modulation
        ad_mode = 1   # 0 software demodulation(src) / 1 hardware demodulation

        DDS_freq = 200

        n = np.arange(0, 1992)
        if ad_mode == 0:
            nn = 1
            repeat_num = 1
        else:
            nn = 8
            repeat_num = 1

        ad_length = 2048
        awg_wave_length = 1000  # ns
        amplitude = 0.3  # v

        awg_wave_number(1, 1)  # awg_wave_number(efficient_wavenum, port)
        awg_wave_number(1, 2)
        awg_wave_number(1, 3)
        awg_wave_number(1, 4)
        DRIVER_ELEC.tc_cfg(tc_delay, cycle, TC_ID)
        DRIVER_ELEC.switch_cfg(0x1, 0x1, AD_ID)

        X = np.zeros(nn*repeat_num)
        Y = np.zeros(nn*repeat_num)
        XX = np.zeros(nn*repeat_num)
        YY = np.zeros(nn*repeat_num)

        for mm in range(0, repeat_num):
            print("-----------------------")
            print("Repeat [%d]" % mm)
            print("-----------------------")
            for ii in range(0, nn):  # n
                print("nn [%d]" % (ii))
                if(awg_mode == 0):  # software modulation
                    pha_env = ii/nn*2*np.pi  # nn
                    env = amplitude * np.exp(-1j * pha_env)
                    B = np.imag(env)
                    A = np.real(env)

                    DRIVER_ELEC.ad_cfg(cycle, ad_length, ad_delay, AD_ID)
                    DRIVER_ELEC.ad_mode(ad_mode, AD_ID, int(-DDS_freq*1e6), 0)  # *2**16/125
                    # AD_RAM
                    # Q = (A*np.cos(DDS_freq/2000*2*math.pi*n) + B*np.sin(DDS_freq/2000*2*math.pi*n))
                    # I = -(B*np.cos(DDS_freq/2000*2*math.pi*n) - A*np.sin(DDS_freq/2000*2*math.pi*n))
                    # AD_DDS
                    I = (A*np.cos(DDS_freq/2000*2*math.pi*n) + B*np.sin(DDS_freq/2000*2*math.pi*n))
                    # Q = -(B*np.cos(DDS_freq/2000*2*math.pi*n) - A*np.sin(DDS_freq/2000*2*math.pi*n))
                    Q = (B*np.cos(DDS_freq/2000*2*math.pi*n+pha_env/10*2*math.pi/100) - A*np.sin(DDS_freq/2000*2*math.pi*n+pha_env/10*2*math.pi/100))

                    I = np.insert(I, 1992, [0, 0, 0, 0, 0, 0, 0, 0])
                    Q = np.insert(Q, 1992, [0, 0, 0, 0, 0, 0, 0, 0])

                    tmpi = volt_awg(I)
                    idata = tmpi.ctypes.data_as(ctypes.c_char_p)
                    tmpq = volt_awg(Q)
                    qdata = tmpq.ctypes.data_as(ctypes.c_char_p)

                    cw_length = int(1000/4)
                    awg_send_wave(idata, cw_length, 0, 1)  # awg_send_wave(data, length, addr_begin, port)
                    awg_send_wave(qdata, cw_length, 0, 2)
                    awg_send_wave(idata, cw_length, 0, 3)
                    awg_send_wave(qdata, cw_length, 0, 4)

                    awg_play_wave(awg_delay, cw_length, 0, 0, 1)  # awg_play_wave(delay, length, addr_begin, number, port)
                    awg_play_wave(awg_delay, cw_length, 0, 0, 2)
                    awg_play_wave(awg_delay, cw_length, 0, 0, 3)
                    awg_play_wave(awg_delay, cw_length, 0, 0, 4)

                    amp = 0
                    awg_IQ_Correction_Amp(1, amp, amp)  # awg_IQ_Correction_Amp(mixer_id, i_amp, q_amp)
                    awg_IQ_Correction_Amp(2, amp, amp)

                    phase = 0
                    awg_IQ_Correction_Phase(1, phase, phase)  # awg_IQ_Correction_Phase(mixer_id, i_phase(π), q_phase(π))
                    awg_IQ_Correction_Phase(2, phase, phase)

                    awg_mixer_freq(1, DDS_freq)  # awg_mixer_freq(mixer_id, frequency(Mhz))
                    awg_mixer_freq(2, DDS_freq)
                    awg_mixer_config(1, [1, 2], 0)  # awg_mixer_config(mixer_id, port_comb, mixer_on)
                    awg_mixer_config(2, [3, 4], 0)

                    awg_mode_continue(0)  # awg_mode_continue(en)

                elif(awg_mode == 1):  # hardware modulation

                    DRIVER_ELEC.ad_cfg(cycle, ad_length, ad_delay, AD_ID)
                    DRIVER_ELEC.ad_mode(ad_mode, AD_ID, int(-DDS_freq*1e6), 0)  # *2**16/125
                    # print('AD freq = %d ' % (int(-DDS_freq*1e6)))
                    data1 = square_data(awg_wave_length, amplitude)
                    data2 = square_data(awg_wave_length, amplitude)
                    data3 = square_data(awg_wave_length, amplitude)
                    data4 = square_data(awg_wave_length, amplitude)

                    cw_length = int(awg_wave_length/4)
                    awg_send_wave(data1, cw_length, 0, 1)  # awg_send_wave(data, length, addr_begin, port)
                    awg_send_wave(data2, cw_length, 0, 2)
                    awg_send_wave(data3, cw_length, 0, 3)
                    awg_send_wave(data4, cw_length, 0, 4)

                    awg_play_wave(awg_delay, cw_length, 0, 0, 1)  # awg_play_wave(delay, length, addr_begin, number, port)
                    awg_play_wave(awg_delay, cw_length, 0, 0, 2)
                    awg_play_wave(awg_delay, cw_length, 0, 0, 3)
                    awg_play_wave(awg_delay, cw_length, 0, 0, 4)

                    phase = ii/nn*2*np.pi  # (-2kπ ~ +2kπ)
                    awg_IQ_Correction_Phase(1, phase, phase)  # awg_IQ_Correction_Phase(mixer_id, i_phase(π), q_phase(π))
                    awg_IQ_Correction_Phase(2, phase, phase)

                    amp = 0
                    awg_IQ_Correction_Amp(1, amp, amp)  # awg_IQ_Correction_Amp(mixer_id, i_amp, q_amp)
                    awg_IQ_Correction_Amp(2, amp, amp)

                    awg_mixer_freq(1, DDS_freq)  # awg_mixer_freq(mixer_id, frequency(Mhz))
                    awg_mixer_freq(2, DDS_freq)
                    awg_mixer_config(1, [1, 2], 1)  # awg_mixer_config(mixer_id, port_comb, mixer_on)
                    awg_mixer_config(2, [3, 4], 1)

                    awg_mode_continue(0)  # awg_mode_continue(en)
                else:
                    return 0

                # time.sleep(1)
                offset_cal = [0, 0, 0, 0]
                DRIVER_ELEC.awg_offset(offset_cal[0], 1, AWG_ID)
                DRIVER_ELEC.awg_offset(offset_cal[1], 2, AWG_ID)
                DRIVER_ELEC.awg_offset(offset_cal[2], 3, AWG_ID)
                DRIVER_ELEC.awg_offset(offset_cal[3], 4, AWG_ID)
                DRIVER_ELEC.awg_multi_Channel_Delay(160, 330, 180, 330, AWG_ID)  # AWG_XY
                DRIVER_ELEC.awg_multi_Channel_Delay_Set(AWG_ID)
                DRIVER_ELEC.awg_trig_mask(AWG_ID, 1, 1, 1, 1)  # awg_trig_mask(AWG_ID, port1, port2, port3, port4)

                DRIVER_ELEC.ad_malloc.restype = ctypes.c_uint64
                addr = DRIVER_ELEC.ad_malloc(cycle, ad_length)
                DRIVER_ELEC.ad_start.argtypes = [ctypes.c_int, ctypes.c_int, ctypes.c_wchar_p, ctypes.c_uint64, ctypes.c_int]
                DRIVER_ELEC.ad_start(cycle, ad_length, AD_ID, addr, ad_mode)

                DRIVER_ELEC.tc_trig(TC_ID)
                time.sleep(1)

                readdone = DRIVER_ELEC.ad_done(3000)

                AD = AQLAD()
                if ad_mode == 0:
                    ch_wave = AD.readout(cycle, ad_length, addr, ad_mode)
                else:
                    ch_iq = AD.readout(cycle, ad_length, addr, ad_mode)
                DRIVER_ELEC.ad_free.argtypes = [ctypes.c_uint64]
                DRIVER_ELEC.ad_free(addr)

                if ad_mode == 0:
                    XX[ii*repeat_num+mm] = np.average(ch_wave[1][0:cycle][8:2040])
                    YY[ii*repeat_num+mm] = np.average(ch_wave[2][0:cycle][8:2040])
                    # X[ii*repeat_num+mm] = np.average(ch_iq[1][0:cycle][0])
                    # Y[ii*repeat_num+mm] = np.average(ch_iq[2][0:cycle][0])
                else:
                    X[ii*repeat_num+mm] = np.average(ch_iq[1][0:cycle][0])
                    Y[ii*repeat_num+mm] = np.average(ch_iq[2][0:cycle][0])
                    XX[ii*repeat_num+mm] = np.average(ch_iq[3][0:cycle][0])
                    YY[ii*repeat_num+mm] = np.average(ch_iq[4][0:cycle][0])

        if(ad_mode == 1):
            plt.figure(1)
            plt.axis('equal')
            plt.title('AD[%s] mode[%d] %dMhz 1234' % (AD_ID, ad_mode, DDS_freq))
            plt.scatter(X, Y)
            plt.scatter(XX, YY)
            plt.legend(["ch1&ch2", "ch3&ch4"], loc='upper right')

            # plt.figure(2)
            # plt.axis('equal')
            # plt.title('AD[%s] mode[%d] %dMhz 12' % (AD_ID, ad_mode, DDS_freq))
            # plt.scatter(X, Y)
            # plt.legend(["ch1&ch2"], loc='upper right')

            # plt.figure(3)
            # plt.axis('equal')
            # plt.title('AD[%s] mode[%d] %dMhz 34' % (AD_ID, ad_mode, DDS_freq))
            # plt.scatter(XX, YY)
            # plt.legend(["ch3&ch4"], loc='upper right')

            plt.show()
        else:
            plt.figure(1)
            plt.plot(ch_wave[1][0][0], "r-", label='ch1')
            plt.plot(ch_wave[2][0][0], "b-", label='ch2')
            plt.legend()
            plt.xlabel('time(ns)')
            plt.ylabel('amplitude(V)')
            plt.title('AD[%s] mode[%d] %dMhz' % (AD_ID, ad_mode, DDS_freq))

            plt.figure(2)
            plt.plot(ch_wave[3][0][0], "g-", label='ch3')
            plt.plot(ch_wave[4][0][0], "y-", label='ch4')
            plt.legend()
            plt.xlabel('time(ns)')
            plt.ylabel('amplitude(V)')
            plt.title('AD[%s] mode[%d] %dMhz' % (AD_ID, ad_mode, DDS_freq))

            for m in range(0, cycle):
                plt.figure(1)
                plt.plot(ch_wave[1][m][0], "r-")
                plt.plot(ch_wave[2][m][0], "b-")
                plt.figure(2)
                plt.plot(ch_wave[3][m][0], "g-")
                plt.plot(ch_wave[4][m][0], "y-")
            plt.show()

    else:
        return 0


DRIVER_ELEC = ctypes.cdll.LoadLibrary(r'D:\work_file_xuhongxin\6_Others_people_tb\2023_7_3_zhangkai\AD_2.0 & AWG_RD_1.0\Python\2023_5_31_AWG_AD_2.0.dll')


if __name__ == "__main__":

    #card ID
    TC_ID = '0021'
    AD_ID = '0014'
    AWG_ID = '0010'

    #card delay
    cycle = 5000
    awg_delay = 200  # 1 = 4 ns / 250 = 1 us / 250000 = 1 ms / AQE MAX:20 ms (67,108,864 ns)
    tc_delay = 12500*3  # 1 = 8 ns / 125 = 1 us / 125000 = 1 ms / AQE MAX:20 ms (42,949,672,960 ns)
    ad_delay = int(awg_delay/2)  # 1 = 8 ns / 125 = 1 us / 125000 = 1 ms / AQE MAX: 8 ms (8,388,608 ns)
    print_config()

    initial_awg(0)      # 上电初始化配置
    tb_awg_N_pulse(0)   # 测试 6pulse拼接 + 长方波
    tb_awg_DDS(0)       # 测试 混频模式
    tb_awg_CW(0)        # 测试 连续波模式

    tb_ad_switch_out(0)     # 测试 AD Switch out
    tb_ad_jitter(0)         # 测试 AWG jitter
    tb_AD_demodultion(1)    # 测试 AD demodulation
    tb_AD_collect(0)        # 测试 AD collect

    print("-----------------------")
    print("Test Finish")

    #电子学固件内测 校准dac delay
    # test_dac1_dci_delay(0)
    # test_dac2_dci_delay(0)
    # test_dac3_dci_delay(0)
    # test_dac4_dci_delay(0)
