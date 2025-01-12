# lw、addu、subu指令

# 测试数据满足
# 寄存器数据方面：32 位数范围内的一些随机数
# sw 指令存入的 word 中，每个 byte 都不是零

import random

test_code_file = open("4_P3/Test_Tool/test_code/P3_test_code_2.asm", encoding="utf-8", mode="w")
test_code_file.write(".text\n")

# 生成内存数据
generate_number_count = 128
i = 0
while (i < generate_number_count):
    # python有符号数自动算数右移，必须用正数以方便后续输出
    storenumber = random.randint(0, 0xffffffff)
    luinumber = storenumber >> 16
    orinumber = storenumber & 0x0000ffff

    addr = random.randint(0, 0x00001fff)
    # python有自动向double转换，必须先int
    addr = int(addr / 4) * 4

    test_code_file.write("lui $1, 0x{:x}\n".format(luinumber))
    test_code_file.write("ori $1, $1, 0x{:x}\n".format(orinumber))
    test_code_file.write("sw $1, {:d}($0)\n".format(i * 4))

    i += 1

# 对直接产生结果的指令，将结果存入内存，同时增加维护存入内存位置的 “指针”
generate_number_count = 128
i = 0
while (i < generate_number_count):
    # 生成非1的寄存器
    register = 1
    while (register == 1):
        register = random.randint(0, 31)

    # lw指令的地址
    addr = random.randint(0x0000, 0x1fc)
    # python有自动向double转换，必须先int
    addr = int(addr / 4) * 4

    test_code_file.write("ori $1, $0, 0x{:x}\n".format(addr))
    test_code_file.write("lw ${:d}, 0($1)\n".format(register))
    test_code_file.write("sw ${:d}, {:d}($0)\n".format(register, 512 + i * 4))

    i += 1

generate_number_count = 40
i = 0
while (i < generate_number_count):
    # 生成非1的三个不同的寄存器
    register_1 = 1
    while (register_1 == 1):
        register_1 = random.randint(0, 31)

    register_2 = 1
    while (register_2 == 1 or register_2 == register_1):
        register_2 = random.randint(0, 31)

    register_3 = 1
    while (register_3 == 1 or register_3 == register_1 or register_3 == register_2):
        register_3 = random.randint(0, 31)

    # lw指令的地址
    addr_1 = random.randint(0x0000, 0x1fc)
    addr_1 = int(addr_1 / 4) * 4
    addr_2 = random.randint(0x0000, 0x1fc)
    addr_2 = int(addr_2 / 4) * 4

    test_code_file.write("ori $1, $0, 0x{:x}\n".format(addr_1))
    test_code_file.write("lw ${:d}, 0($1)\n".format(register_1))
    test_code_file.write("ori $1, $0, 0x{:x}\n".format(addr_2))
    test_code_file.write("lw ${:d}, 0($1)\n".format(register_2))

    if(random.randint(0, 1)):
        test_code_file.write("addu ${:d}, ${:d}, ${:d}\n".format(register_3, register_1, register_2))
    else:
        test_code_file.write("subu ${:d}, ${:d}, ${:d}\n".format(register_3, register_1, register_2))

    test_code_file.write("sw ${:d}, {:d}($0)\n".format(register_3, 1024 + i * 4))

    i += 1

# Logisim测试文件最后锁定
test_code_file.write("end_loop_beq: beq $0 $0, end_loop_beq\n")
test_code_file.close()
