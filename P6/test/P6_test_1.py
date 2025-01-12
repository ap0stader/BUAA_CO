# ori、lui、sw指令

# 测试数据满足
# 寄存器数据方面：32 位数范围内的一些随机数
# 无符号立即数方面：16 位无符号数范围内的一些随机数
# sw 指令存入的 word 中，每个 byte 都不是零

import random

test_code_file = open("7_P6/test/test_code/P6_test_code_1.asm", encoding="utf-8", mode="w")
test_code_file.write(".text\n")

# 生成测试数据满足
# $base 寄存器中的值是正数、零
# offset 是正数、零、负数
generate_number_count = 900
i = 0
while (i < generate_number_count):
    # 生成非1的寄存器
    register = 1
    while (register == 1):
        register = random.randint(0, 31)

    # python有符号数自动算数右移，必须用正数以方便后续输出
    storenumber = random.randint(0, 0xffffffff)
    luinumber = storenumber >> 16
    orinumber = storenumber & 0x0000ffff

    # 避免offset加上之后超界限4
    addr = random.randint(20, 0x00002fff)
    # python有自动向double转换，必须先int
    addr = int(addr / 4) * 4

    offset = random.randint(-20, 20)
    offset = int(offset / 4) * 4

    test_code_file.write("lui ${:d}, 0x{:x}\n".format(register,luinumber))
    test_code_file.write("ori ${:d}, ${:d}, 0x{:x}\n".format(register, register, orinumber))
    test_code_file.write("ori $1, $0, 0x{:x}\n".format(addr))
    test_code_file.write("sw ${:d}, {:d}($1)\n".format(register, offset))

    i += 1

# 生成测试数据满足
# $base 寄存器中的值是负数
# offset 是正数
generate_number_count = 90
i = 0
while (i < generate_number_count):
    # 生成非1的寄存器
    register = 1
    while (register == 1):
        register = random.randint(0, 31)

    storenumber = random.randint(0, 0xffffffff)
    luinumber = storenumber >> 16
    orinumber = storenumber & 0x0000ffff

    addr = random.randint(0xa000, 0xffff)
    addr = int(addr / 4) * 4
    destaddr = random.randint(0, 0x00001fff)
    destaddr = int(destaddr / 4) * 4

    offset = (0xffff - addr + 1) + destaddr

    test_code_file.write("lui ${:d}, 0x{:x}\n".format(register,luinumber))
    test_code_file.write("ori ${:d}, ${:d}, 0x{:x}\n".format(register, register, orinumber))
    test_code_file.write("lui $1, 0xffff\n".format(addr))
    test_code_file.write("ori $1, $1, 0x{:x}\n".format(addr))
    test_code_file.write("sw ${:d}, {:d}($1)\n".format(register, offset))

    i += 1
