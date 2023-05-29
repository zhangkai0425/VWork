#include "stdio.h"

int main (void)
{
  int d;
  d=0;
  asm(
    // trigger test
    "lui x13,0x2001\n"
    "li x14,1000\n"  // trigger 1000 times
    "sw x14,0(x13)\n"
    "li x14,1250\n"
    "sw x14,4(x13)\n" // trigger step = 10 us
    // qwait test
    "lui x13,0x2002\n"
    "li x14,1250\n"   // qwait 10 us
    "sw x14,0(x13)\n"
    // pulse test
    "li x13,0x20023f0\n" // wave length = 100
    "li x14,100\n"
    "sw x14,8(x13)\n"
    // play test
    "lui x13,0x2008\n" // 1Q Channel
    "li x14,9\n"     // wave id = 9
    "sw x14,32(x13)\n"
    // fmr test
    "lui x13,0x2003\n" // fmr addr
    "li x14,1\n"     // flag = 1
    "sw x14,0(x13)\n"
    "lw %[d],0(x13)\n"
    :[d]"=r"(d)
    :
    :"x13","x14"
    );
  // 不连续的地址读写测试
printf("Now d is %d!\n",d);
}

