#include "stdio.h"

int main (void)
{
    // test Dual ports of SRAM
    int d=0;
    asm(
        "lui x1,0x2000\n"
        "lw x3,32(x1)\n"
        "lw x4,64(x1)\n"
        "add x7,x3,x4\n"
        "sw x7,48(x1)\n"
        "lw %[d],48(x1)\n"
        :[d]"=r"(d)
        :
        :"x1","x3","x4","x7"
        );
    printf("Now d is %d!\n",d);
}
