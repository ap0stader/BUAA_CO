# lw、addu、subu指令

# 测试数据满足
# 寄存器数据方面：32 位数范围内的一些随机数
# sw 指令存入的 word 中，每个 byte 都不是零

import random

test_code_file = open("5_P4/test/test_code/P4_test_code_2.asm", encoding="utf-8", mode="w")
test_code_file.write(".text\n")

# 生成内存数据
generate_number_count = 256
i = 0
while (i < generate_number_count):
    storenumber = random.randint(0, 0xffffffff)
    luinumber = storenumber >> 16
    orinumber = storenumber & 0x0000ffff

    test_code_file.write("lui $1, 0x{:x}\n".format(luinumber))
    test_code_file.write("ori $1, $1, 0x{:x}\n".format(orinumber))
    test_code_file.write("sw $1, {:d}($0)\n".format(i * 4))

    i += 1

generate_number_count = 512
i = 0
while (i < generate_number_count):
    # 生成非1的寄存器
    register = 1
    while (register == 1):
        register = random.randint(0, 31)

    # lw指令的地址（从0000到03fc(1020)
    addr = random.randint(0x0000, 0x03fc)
    addr = int(addr / 4) * 4

    test_code_file.write("ori $1, $0, 0x{:x}\n".format(addr))
    test_code_file.write("lw ${:d}, 0($1)\n".format(register))
    test_code_file.write("sw ${:d}, {:d}($0)\n".format(register, 256 * 4 + i * 4))

    i += 1

generate_number_count = 300
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
    addr_1 = random.randint(0x0000, 0xbfc)
    addr_1 = int(addr_1 / 4) * 4
    addr_2 = random.randint(0x0000, 0xbfc)
    addr_2 = int(addr_2 / 4) * 4

    test_code_file.write("ori $1, $0, 0x{:x}\n".format(addr_1))
    test_code_file.write("lw ${:d}, 0($1)\n".format(register_1))
    test_code_file.write("ori $1, $0, 0x{:x}\n".format(addr_2))
    test_code_file.write("lw ${:d}, 0($1)\n".format(register_2))

    if(random.randint(0, 1)):
        test_code_file.write("addu ${:d}, ${:d}, ${:d}\n".format(register_3, register_1, register_2))
    else:
        test_code_file.write("subu ${:d}, ${:d}, ${:d}\n".format(register_3, register_1, register_2))

    i += 1
