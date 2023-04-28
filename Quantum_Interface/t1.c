#include "stdio.h"
volatile int *const ADDR_TRIGGER = (int *)0x40001000,
                    *const ADDR_WAIT = (int *)0x40002000,
                    *const ADDR_FMR = (int *)0x40003000,
                    *const ADDR_PCIE = (int *)0x40120000;
volatile unsigned char *const ADDR_FMR_READY = (unsigned char *)0x40002FFF,
                              *const ADDR_PLAY = (unsigned char *)0x40008000;
volatile double (*const ADDR_PARAMS)[4] = (double (*)[4])0x40010000;
volatile double (*const ADDR_FMR_IQ)[2] = (double (*)[2])0x40004000;
volatile double *const ADDR_SRAM = (double *)0x40100000;
volatile int *const ADDR_TRIGGER_INTERVAL = ADDR_TRIGGER + 1,
                    *const ADDR_TRIGGER_BITMASK = ADDR_TRIGGER + 2,
                    *const ADDR_OFFSET = ADDR_WAIT + 1;
volatile unsigned short *const ADDR_ENVELOPE = (unsigned short *)0x40002400;
volatile int *const ADDR_WAVE_LEN = (int *)0x400023F8;
volatile unsigned short *const ADDR_WAVE_CHANNEL = (unsigned short *)0x400023FC;
volatile unsigned char *const ADDR_WAVE_INDEX = (unsigned char *)0x400023FE;

static inline int CHANNEL_1Q(int k) { return k; }
static inline int CHANNEL_2Q(int k) { return 0x400 + k; }
static inline int CHANNEL_PHYS(int k) { return 0x2000 + k; }

const unsigned char WAVEFORM_ZXZ = 0, WAVEFORM_ZXZ_90 = 1,
                    WAVEFORM_SQUARE_UP = 2, WAVEFORM_SQUARE_DOWN = 3,
                    WAVEFORM_Z_UP = 64, WAVEFORM_Z_DOWN = 65,
                    WAVEFORM_RESET = 127, WAVEFORM_MEAS = 128;
const unsigned char WAVEFORM_PI = WAVEFORM_ZXZ, WAVEFORM_PI_2 = WAVEFORM_ZXZ_90;
const unsigned char WAVEFORM_CZ = 0, WAVEFORM_IS = 1;

// TODO(fang.z): Don't know how to set or implement this
const int BITMASK = 0xffffffff;

static inline void trigger(int trigger_repeat) {
  *ADDR_TRIGGER = trigger_repeat;
  while (!*ADDR_FMR_READY) {
  }
}
/* Identical to `t1.cpp` except that all params are hardcoded to remove
dependency to the `params.txt`. Serves as a demo program.
 */
const int DELAY_RESET = 100, DELAY_X = 100, TRIGGER_INTERVAL = 1000;

int main() {
  int result;
  *ADDR_TRIGGER_BITMASK = BITMASK;
  *ADDR_TRIGGER_INTERVAL = TRIGGER_INTERVAL;
  *ADDR_OFFSET = 0;
  ADDR_PARAMS[CHANNEL_1Q(0)][0] = 0.0;
  ADDR_PARAMS[CHANNEL_1Q(0)][2] = 1.0;
  int t1_delay_max = 500;
  int t1_delay_step = 50;
  int t1_repeat = 1000;
  for (int t1_delay = 0; t1_delay < t1_delay_max; t1_delay += t1_delay_step) {
    ADDR_PLAY[CHANNEL_1Q(0)] = WAVEFORM_RESET;
    *ADDR_WAIT = DELAY_RESET;
    ADDR_PLAY[CHANNEL_1Q(0)] = WAVEFORM_ZXZ;
    *ADDR_WAIT = DELAY_X;
    *ADDR_WAIT = t1_delay;
    ADDR_PLAY[CHANNEL_1Q(0)] = WAVEFORM_MEAS;
    trigger(t1_repeat);
    result = ADDR_FMR[0];
    *ADDR_PCIE = t1_delay;
    *ADDR_PCIE = result;
  }
  return 0;
}