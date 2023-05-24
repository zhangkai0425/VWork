#include "stdio.h"

// test CPU Basic Function
int main (void)
{
    int a = 1;
    int b = 2;
    int c = 0;
    int d = 0;
    printf("a is %d!\n",a);
    printf("b is %d!\n",b);
    printf("c is %d!\n",c);
    printf("d is %d!\n",d);
    asm(
      "li x0,0x9000\n"
      "li x1,9\n"
      "sw x1,(x0)\n"
      "mv x5,%[a]\n"
      "mv x6,%[b]\n"
      "label_add:"
      "add %[c],x5,x6\n"
      "lw %[d],(x0)\n"
      :[c]"=r"(c),[d]"=r"(d)
      :[a]"r"(a),[b]"r"(b)
      :"x0","x1","x5","x6"
    );
    printf("Now d is %d!\n",d);
    if(c == 3)
        printf("!!! PASS !!!");
    else
        printf("!!! FAIL !!!");
        printf("after ASM c is changed to %d!\n",c);
    return 0;
}

