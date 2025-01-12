import os
import re

step = 2
test_file_number = "4"

# 生成测试代码的十六进制文件

# 生成的文件的地址前面加上5_P4/test/
# VSCode中运行Python的工作目录和VSCode的工作目录是相同的
os.system("java -jar test/mars.jar a mc CompactLargeText nc dump .text HexText mips/code.txt test/test_code/P4_test_code_" + test_file_number + ".asm")

# 在最后补充1000ffff，使仿真时保持最后状态
hexfile = open("mips/code.txt", mode="a+")
hexfile.write("1000ffff\n")
hexfile.close()

# 使用MARS运行，得到标准结果
os.system("java -jar test/mars.jar 10000 mc CompactLargeText nc coL1 ig test/test_code/P4_test_code_" + test_file_number + ".asm > test/test_code/P4_mars_result_" + test_file_number + ".txt")

# 先设置step == 1，检查MARS的文件是否正确生成，再进行下一步测试

if (step == 2):
    # 使用ISE运行
    # ！！！应先仿真运行一次，生成.prj文件和.exe文件

    # 运行前需要先设置环境变量
    os.system('export XILINX="/opt/Xilinx/14.7/ISE_DS/ISE/"')

    # ！！！由于ISE限制，仿真必须在编译的文件夹中运行
    os.system("cd mips/; ./RUN_CPU_isim_beh.exe -nolog -tclbatch RUN_CPU.tcl > ../test/test_code/P4_ise_result_" + test_file_number + ".txt")

    # 对比
    marsresultfile = open("./test/test_code/P4_mars_result_" + test_file_number + ".txt", mode="r")
    iseresultfile = open("./test/test_code/P4_ise_result_" + test_file_number + ".txt", mode="r")

    # 跳过ISE无法关闭的默认输出信息
    iseresultfile.seek(iseresultfile.read().index("@"))

    iseresultlines = iseresultfile.readlines()
    marsresultlines = marsresultfile.readlines()
    
    iselen = iseresultlines.__len__()
    # MARS的输出比ISE多一行
    marslen = marsresultlines.__len__() - 1
    
    for i in range(min(iselen, marslen)):
        if(iseresultlines[i] == marsresultlines[i]):
            print("\033[0;32mLine:{:>5d} Accepted: ".format(i + 1) + iseresultlines[i] + "\033[0m", end="")
        else:
            codelinehex = re.match("@([0-9a-f]{8}):", marsresultlines[i]).group(1)
            # 再+1是考虑到.text占用一行
            codeline = int((int(codelinehex, 16) - 0x00003000) / 4) + 1 + 1

            print("\033[0;31mLine:{:>5d} Hex Line:{:>5d} Wrong!\nGot: ".format(i + 1, codeline) + iseresultlines[i] + "Exptected: " + marsresultlines[i] + "\033[0m")
            break

    if(iselen == marslen):
        print("\033[0;32mLines match!\n ISE Lines: {:>5d} ".format(iselen) + "\nMARS Lines: {:>5d}".format(marslen) + "\033[0m")
    else:
        print("\033[0;31mLines mismatch!\n ISE Lines: {:>5d} ".format(iselen) + "\nMARS Lines: {:>5d}".format(marslen) + "\033[0m")

    marsresultfile.close()
    iseresultfile.close()
    exit()
