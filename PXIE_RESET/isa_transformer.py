import os

isa_data = []
with open('isa.txt', 'r') as f:
    lines = f.readlines()    # 将文件内容逐行读取到列表lines中
    for line in lines:
        inst = line.split(' ')
        new_inst = [i for i in inst if i.strip()]
        rdata = [   new_inst[3][6:8]+new_inst[3][4:6]+new_inst[3][2:4]+new_inst[3][0:2],
                    new_inst[2][6:8]+new_inst[2][4:6]+new_inst[2][2:4]+new_inst[2][0:2],
                    new_inst[1][6:8]+new_inst[1][4:6]+new_inst[1][2:4]+new_inst[1][0:2],
                    new_inst[0][6:8]+new_inst[0][4:6]+new_inst[0][2:4]+new_inst[0][0:2],
                ]
        isa_data.append('0x' + rdata[3])
        isa_data.append('0x' + rdata[2])
        isa_data.append('0x' + rdata[1])
        isa_data.append('0x' + rdata[0])
        print(isa_data)  # 删除每行前后的空格和换行符，并打印出来
PXIE_data = isa_data[3]+isa_data[2]+isa_data[1]+isa_data[0]
print("PXIE_DATA = ",PXIE_data)
