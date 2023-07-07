#include "stdio.h"

int main (void)
{
  int d;
  d=0;
  asm(
    // qwait test
    "lui x13,0x2002\n"
    "li x12, 1\n"
    "li x11, 4\n"
    "loop_start:\n" 
    "li x14,0\n"     
    "addi x14, x14, 14\n" // awg_id
    "slli x14, x14, 4\n"
    "add x14, x14, x12\n"  // port_id
    "slli x14, x14, 24\n" 
    "addi x14, x14, 10\n" // delay
    "sw x14,0(x13)\n"
    "addi x12, x12, 1\n"
    "blt x12, x11, loop_start\n"
    "lw %[d],0(x13)\n"
    :[d]"=r"(d)
    :
    :"x11","x12","x13","x14"
    );
    printf("Now d is %d!\n",d);
}

