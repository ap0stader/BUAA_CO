# lw、lh、lb、addu、subu指令

# 测试数据满足
# 寄存器数据方面：32 位数范围内的一些随机数
# sw 指令存入的 word 中，每个 byte 都不是零

import random

test_code_file = open("7_P6/test/test_code/P6_test_code_2.asm", encoding="utf-8", mode="w")
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
    addr = random.randint(0x0000, 0x03f8)
    addr = int(addr / 4) * 4

    method = random.randint(0, 2)
    offset_h = random.randint(0, 1)
    offset_b = random.randint(0, 3)

    test_code_file.write("ori $1, $0, 0x{:x}\n".format(addr))
    match (method):
        case 0:
            test_code_file.write("lw ${:d}, 0($1)\n".format(register))
        case 1:
            test_code_file.write("lh ${:d}, {:d}($1)\n".format(register, offset_h * 2))
        case 2:
            test_code_file.write("lb ${:d}, {:d}($1)\n".format(register, offset_b))
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
    addr_1 = random.randint(0x0000, 0xbf8)
    addr_1 = int(addr_1 / 4) * 4
    addr_2 = random.randint(0x0000, 0xbf8)
    addr_2 = int(addr_2 / 4) * 4

    method = random.randint(0, 2)
    offset_h = random.randint(0, 1)
    offset_b = random.randint(0, 3)

    test_code_file.write("ori $1, $0, 0x{:x}\n".format(addr_1))
    match (method):
        case 0:
            test_code_file.write("lw ${:d}, 0($1)\n".format(register_1))
        case 1:
            test_code_file.write("lh ${:d}, {:d}($1)\n".format(register_1, offset_h * 2))
        case 2:
            test_code_file.write("lb ${:d}, {:d}($1)\n".format(register_1, offset_b))
    test_code_file.write("ori $1, $0, 0x{:x}\n".format(addr_2))
    match (method):
        case 0:
            test_code_file.write("lw ${:d}, 0($1)\n".format(register_2))
        case 1:
            test_code_file.write("lh ${:d}, {:d}($1)\n".format(register_2, offset_h * 2))
        case 2:
            test_code_file.write("lb ${:d}, {:d}($1)\n".format(register_2, offset_b))

    if(random.randint(0, 1)):
        test_code_file.write("addu ${:d}, ${:d}, ${:d}\n".format(register_3, register_1, register_2))
    else:
        test_code_file.write("subu ${:d}, ${:d}, ${:d}\n".format(register_3, register_1, register_2))

    i += 1
