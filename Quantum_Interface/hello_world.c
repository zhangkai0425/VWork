#include "stdio.h"

int main (void)
{
  int d;
  d=0;
  // asm(
  //   "lui x13,0x2000\n"
  //   "li x14,9\n"
  //   "sw x14,16(x13)\n"
  //   :
  //   :
  //   :"x13","x14"
  //   );
  // asm(
  //   "lui x13,0x2000\n"
  //   "li x14,9\n"
  //   "sw x14,16(x13)\n"
  //   "lw %[d],16(x13)\n"
  //   "li x14,7\n"
  //   "sw x14,-16(x13)\n"
  //   "lw %[d],-16(x13)\n"
  //   "li x14,8\n"
  //   "sw x14,32(x13)\n"
  //   "lw %[d],32(x13)\n"
  //   "li x14,13\n"
  //   "sw x14,64(x13)\n"
  //   "lw %[d],64(x13)\n"
  //   :[d]"=r"(d)
  //   :
  //   :"x13","x14"
  //   );
  // 不连续的地址读写测试
  asm(
    "lui x13,0x2000\n"
    "li x14,9\n"
    "sd x14,8(x13)\n"
    "lw %[d],8(x13)\n"
    "li x14,7\n"
    "sw x14,15(x13)\n"
    "lw %[d],15(x13)\n"
    "li x14,8\n"
    "sw x14,32(x13)\n"
    "lw %[d],32(x13)\n"
    "li x14,13\n"
    "sw x14,64(x13)\n"
    "lw %[d],64(x13)\n"
    :[d]"=r"(d)
    :
    :"x13","x14"
    );
printf("Now d is %d!\n",d);
// //Section 1: Hello World!
//   printf("\nHello Friend!\n");
//   printf("Welcome to T-HEAD World!\n");

// //Section 2: Embeded ASM in C 
//   int a;
//   int b;
//   int c;
//   int d;
//   a=1;
//   b=2;
//   c=0;
//   d=0;
//   printf("\na is %d!\n",a);
//   printf("b is %d!\n",b);
//   printf("c is %d!\n",c);
//   printf("d is %d!\n",d);

// asm(
//     "li x0,0x3000000\n"
//     "li x1,9\n"
//     "sw x1,(x0)\n"
//     "mv  x5,%[a]\n"
//     "mv  x6,%[b]\n"
//     "label_add:"
//     "add  %[c],x5,x6\n"
//     "lw %[d],(x0)\n"
//     :[c]"=r"(c),[d]"=r"(d)
//     :[a]"r"(a),[b]"r"(b)
//     :"x0","x1","x5","x6"
//     );
  // printf("Now d is %d!\n",d);
// if(c == 3)
//   printf("!!! PASS !!!");
// else
//   printf("!!! FAIL !!!");
//   printf("after ASM c is changed to %d!\n",c);

  // return 0;
}

