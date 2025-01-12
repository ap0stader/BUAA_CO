# ori、lui、sw指令

# 测试数据满足
# 寄存器数据方面：32 位数范围内的一些随机数
# 无符号立即数方面：16 位无符号数范围内的一些随机数
# sw 指令存入的 word 中，每个 byte 都不是零

import random

test_code_file = open("4_P3/Test_Tool/test_code/P3_test_code_1.asm", encoding="utf-8", mode="w")
test_code_file.write(".text\n")

# 生成测试数据满足
# $base 寄存器中的值是正数、零
# offset 是正数、零、负数
generate_number_count = 200
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

    addr = random.randint(0, 0x00002fff)
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
generate_number_count = 40
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

    addr = random.randint(0xa200, 0xffff)
    # python有自动向double转换，必须先int
    addr = int(addr / 4) * 4

    offset = (0xffff - addr + 1) + 4

    test_code_file.write("lui ${:d}, 0x{:x}\n".format(register,luinumber))
    test_code_file.write("ori ${:d}, ${:d}, 0x{:x}\n".format(register, register, orinumber))
    test_code_file.write("lui $1, 0xffff\n".format(addr))
    test_code_file.write("ori $1, $1, 0x{:x}\n".format(addr))
    test_code_file.write("sw ${:d}, {:d}($1)\n".format(register, offset))

    i += 1

# Logisim测试文件最后锁定
test_code_file.write("end_loop_beq: beq $0 $0, end_loop_beq\n")
test_code_file.close()
