import os
import re

step = 1
test_file_number = "3"

if (step == 1):
    # 生成测试的代码

    # 生成的文件的地址前面加上4_P3/Test_Tool/
    # VSCode中运行Python的工作目录和VSCode的工作目录是相同的
    os.system("java -jar 4_P3/Test_Tool/mars.jar a mc CompactDataAtZero nc dump .text HexText 4_P3/Test_Tool/test_code/P3_test_hex_" + test_file_number + ".hex 4_P3/Test_Tool/test_code/P3_test_code_" + test_file_number + ".asm")

    # 打开两个文件
    hexcode = open("4_P3/Test_Tool/test_code/P3_test_hex_" + test_file_number + ".hex", encoding="utf-8", mode="r").read()
    origincirc = open("4_P3/P3_Full.circ", encoding="utf-8", mode="r").read()

    # 这一正则表达式对测试的电路文件编写有要求
    # 这一条正则用到了在.circ文件中</a>标签很少出现的特性
    # 要求在替换的ROM的</a>标签后不能再出现</a>标签，否则将因为正则的贪心匹配而破坏电路文件
    # （可以用仅允许出现一块ROM来限制）
    # 对于文件开头<lib desc="#Memory" name="4">中的</a>，要求使用addr/data: 8 8中的两个数字不同于实际使用的
    # （可以用设置ROM的默认值为不同于实际使用的来限制）
    replacestring = re.sub(r'<a name="contents">addr/data: 12 32([\s\S]*)</a>', '<a name="contents">addr/data: 12 32\n' + hexcode + '</a>', origincirc)

    # 写入替换后的电路
    replacecirc = open("4_P3/Test_Tool/P3_replace.circ", encoding="utf-8", mode="w")
    replacecirc.write(replacestring)
    replacecirc.close()

    # 因为测试文件最后的指令是1000ffff，MARS不会停止，限制其执行1024步（同tester中使用的计数器）
    os.system("java -jar 4_P3/Test_Tool/mars.jar 1024 mc CompactDataAtZero nc dump 0x00000000-0x00002ffc HexText 4_P3/Test_Tool/test_code/P3_test_marsdump_" + test_file_number + ".hex 4_P3/Test_Tool/test_code/P3_test_code_" + test_file_number + ".asm")

# if(step == 2):
# 因为Logisim限制无法通过命令行导出所有的RAM数据
# 故应使用Logisim打开tester，运行电路，手动点击Save Image然后再进行对比手动进行检查

if(step == 3):
    # 最后RAM状态对比
    marsdump = open("4_P3/Test_Tool/test_code/P3_test_marsdump_" + test_file_number + ".hex", mode="r")
    logisimdump = open("4_P3/Test_Tool/test_code/P3_test_logisimdump_" + test_file_number + ".hex", mode="r")
    
    # 跳过第一行v2.0 raw
    logisimdump.readline()

    check_address = -4

    # 使用正则表达式进行判断，正确和错误均输出相关信息
    for logisimsegment in re.findall(r'[0-9a-f*]+', logisimdump.read()):
        if (str.find(logisimsegment, "*") != -1) :
            repeatetime = int(re.match(r'([0-9]+)\*([0-9a-f]+)', logisimsegment).group(1))
            repeatehex = int(re.match(r'([0-9]+)\*([0-9a-f]+)', logisimsegment).group(2))
            haverepeatetime = 0
            while (haverepeatetime < repeatetime):
                marshex = int(marsdump.readline(), 16)
                check_address += 4
                if (repeatehex == marshex):
                    print("\033[0;32mData Address 0x{:0>8x} Accepted!\033[0m".format(check_address))
                else:
                    print("\033[0;31mData Address 0x{:0>8x} Wrong!\nExpected: 0x{:0>8x} Got: 0x{:0>8x}\033[0m".format(check_address, marshex, repeatehex))
                    exit()
                haverepeatetime += 1
        else:
            logisimhex = int(logisimsegment, 16)
            marshex = int(marsdump.readline(), 16)
            check_address += 4
            if (logisimhex == marshex):
                print("\033[0;32mData Address 0x{:0>8x} Accepted!\033[0m".format(check_address))
            else:
                print("\033[0;31mData Address 0x{:0>8x} Wrong!\nExpected: 0x{:0>8x} Got: 0x{:0>8x}\033[0m".format(check_address, marshex, logisimhex))
                exit()

    # 判断剩余部分是否全部为0
    marssegment = marsdump.readline()

    while (marssegment != ""):
        marshex = int(marssegment, 16)
        check_address += 4
        if (marshex != 0):
            print("\033[0;31mData Address 0x{:0>8x} Wrong!\nExpected: 0x{:0>8x} Got: 0x00000000\033[0m".format(check_address, marshex))
            exit()
        marssegment = marsdump.readline()

    print("\033[0;32mThe remaining data are all 0x00000000\033[0m")
