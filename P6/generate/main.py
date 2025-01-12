import random


def to_signed(unsigned):
    if unsigned >= 0x80000000:
        return unsigned - 0x100000000
    else:
        return unsigned


def to_unsigned(signed):
    return signed & 0xffffffff


def cut_lower32(signed):
    return signed & 0xffffffff


def cut_lower16(signed):
    return signed & 0xffff


# 常量
C_READY_DATA_START = 15
C_READY_STORE_START = 10

# 结果寄存器
RESULT_REGISTER = 9

# 指定冲突寄存器
CRASH_REGISTER = 31

# 模拟寄存器状态
# 均要保持有符号状态
registerStatus = {0: 0x00000000}
HIStatus = 0x00000000
LOStatus = 0x00000000
memoryStatus = {}

# 准备阶段寄存器数据寄存器从21号到30号
readyDataList = []
# 准备阶段内存数据
readyStoreList = []

commandList = []
cleanRegisterList = []

# 跳转标签计数器
branchLabelCounter = 0


def init_status_list():
    global registerStatus
    global readyDataList
    global commandList
    global cleanRegisterList

    registerStatus = {0: 0x00000000}
    readyDataList = []
    commandList = []
    cleanRegisterList = []


def add_ready_data_list(method, method_para=()):
    # 0x80000000 - 0x7fffffff
    rand_data = random.randint(-2147483648, 2147483647)
    if method == "NONZERO":
        if method_para[0] == 0:
            # 0xff800000 - 0x007fffff
            rand_data = random.randint(-8388608, 8388607)

    elif method == "ALREG":
        link_data = registerStatus[method_para[1]]
        if method_para[0] == "add":
            while cut_lower32(rand_data + link_data) == 0x0:
                rand_data = random.randint(-2147483648, 2147483647)

        elif method_para[0] == "sub":
            if method_para[2] == 1:
                while cut_lower32(rand_data - link_data) == 0x0:
                    rand_data = random.randint(-2147483648, 2147483647)
            elif method_para[2] == 2:
                while cut_lower32(link_data - rand_data) == 0x0:
                    rand_data = random.randint(-2147483648, 2147483647)

        elif method_para[0] == "and":
            while cut_lower32(link_data) & cut_lower32(rand_data) == 0x0:
                rand_data = random.randint(-2147483648, 2147483647)

        elif method_para[0] == "or":
            while cut_lower32(link_data) | cut_lower32(rand_data) == 0x0:
                rand_data = random.randint(-2147483648, 2147483647)

        elif method_para[0] == "slt":
            if method_para[2] == 1:
                rand_data = random.randint(-2147483648, link_data)
            elif method_para[2] == 2:
                rand_data = random.randint(link_data, 2147483647)

        elif method_para[0] == "sltu":
            if method_para[2] == 1:
                rand_data = to_signed(random.randint(0x00000000, to_unsigned(link_data)))
            elif method_para[2] == 2:
                rand_data = to_signed(random.randint(to_unsigned(link_data), 0xffffffff))

    elif method == "BRANCHE":
        rand_data = method_para[1]

    elif method == "STORE":
        rand_data = rand_data & 0x0ffc

    new_register = len(readyDataList) + C_READY_DATA_START
    readyDataList.append(rand_data)
    registerStatus[new_register] = rand_data
    cleanRegisterList.append(new_register)
    return new_register


def add_ready_store_list(method):
    rand_address = random.randint(0x0000, 0x2fff)
    if method == "lh":
        rand_address = rand_address & 0xfffe
    elif method == "lw":
        rand_address = rand_address & 0xfffc
    rand_data_register = add_ready_data_list(method="NONZERO", method_para=(1, ))

    rand_address_register = len(readyStoreList) + C_READY_STORE_START
    readyStoreList.append((rand_data_register, rand_address))
    registerStatus[rand_address_register] = rand_address
    memoryStatus[rand_address] = registerStatus[rand_data_register]
    cleanRegisterList.append(rand_address_register)
    return rand_address_register


def generate_imm(method, method_para=()):
    rand_imm = random.randint(0x0000, 0xffff)
    if method == "ALIMM":
        link_data = registerStatus[method_para[1]]
        if method_para[0] == "addi":
            rand_imm = random.randint(-32768, 32767)
            while cut_lower32(rand_imm + link_data) == 0x0:
                rand_imm = random.randint(-32768, 32767)
        elif method_para[0] == "andi":
            while rand_imm & cut_lower32(link_data) == 0x0:
                rand_imm = random.randint(0x0000, 0xffff)
        elif method_para[0] == "ori":
            while rand_imm | cut_lower32(link_data) == 0x0:
                rand_imm = random.randint(0x0000, 0xffff)
    elif method == "EXTLUI":
        while rand_imm == 0x0:
            rand_imm = random.randint(0x0000, 0xffff)
    return rand_imm


def append_and_execute(para_command):
    commandList.append(para_command)
    para_command.execute()


class NOP:
    def __repr__(self):
        return "nop"

    def execute(self):
        registerStatus[0] = 0x0000


class ALREG:
    __used_instruction = ("add", "sub", "and", "or", "slt", "sltu")

    __instruction = ""

    __rd = 0
    __rs = 0
    __rt = 0

    def __init__(self, rd, rs=-1, rt=-1, specific_instruction=""):
        if specific_instruction == "":
            self.__instruction = self.__used_instruction[random.randint(0, len(self.__used_instruction) - 1)]
        else:
            self.__instruction = specific_instruction

        self.__rd = rd

        if rs == -1 and rt == -1:
            self.__rs = add_ready_data_list(method="NONZERO", method_para=(0,))
            self.__rt = add_ready_data_list(method="ALREG", method_para=(self.__instruction, self.__rs, 2))
        elif rs == -1 and rt != -1:
            self.__rs = add_ready_data_list(method="ALREG", method_para=(self.__instruction, rt, 1))
            self.__rt = rt
        elif rs != -1 and rt == -1:
            self.__rs = rs
            self.__rt = add_ready_data_list(method="ALREG", method_para=(self.__instruction, rs, 2))
        elif rs != -1 and rt != -1:
            self.__rs = rs
            self.__rt = rt

    def __repr__(self):
        return (self.__instruction +
                " $" + self.__rd.__str__() +
                ", $" + self.__rs.__str__() +
                ", $" + self.__rt.__str__())

    def execute(self):
        if self.__instruction == "add":
            registerStatus[self.__rd] = to_signed(cut_lower32(registerStatus[self.__rs]
                                                              + registerStatus[self.__rt]))
        elif self.__instruction == "sub":
            registerStatus[self.__rd] = to_signed(cut_lower32(registerStatus[self.__rs]
                                                              - registerStatus[self.__rt]))
        elif self.__instruction == "and":
            registerStatus[self.__rd] = to_signed(cut_lower32(registerStatus[self.__rs])
                                                  & cut_lower32(registerStatus[self.__rt]))
        elif self.__instruction == "or":
            registerStatus[self.__rd] = to_signed(cut_lower32(registerStatus[self.__rs])
                                                  | cut_lower32(registerStatus[self.__rt]))
        elif self.__instruction == "slt" or self.__instruction == "sltu":
            # 经过了调整之后一定是满足小于的
            registerStatus[self.__rd] = 1
        print("# ${:02d} <= {:08x}".format(self.__rd, to_unsigned(registerStatus[self.__rd])))


class ALIMM:
    __used_instruction = ("addi", "andi", "ori")

    __instruction = ""

    __rd = 0
    __rs = 0

    __imm16 = 0

    def __init__(self, rd, rs=-1, imm16=0, specific_instruction=""):
        if specific_instruction == "":
            self.__instruction = self.__used_instruction[random.randint(0, len(self.__used_instruction) - 1)]
        else:
            self.__instruction = specific_instruction

        self.__rd = rd

        if rs == -1:
            self.__rs = add_ready_data_list(method="NONZERO", method_para=(1,))
        else:
            self.__rs = rs

        if imm16 == 0:
            self.__imm16 = generate_imm(method="ALIMM", method_para=(self.__instruction, self.__rs))
        else:
            self.__imm16 = imm16

    def __repr__(self):
        if self.__instruction == "addi":
            return (self.__instruction +
                    " $" + self.__rd.__str__() +
                    ", $" + self.__rs.__str__() +
                    ", {:d}".format(self.__imm16))
        else:
            return (self.__instruction +
                    " $" + self.__rd.__str__() +
                    ", $" + self.__rs.__str__() +
                    ", 0x{:04x}".format(cut_lower16(self.__imm16)))

    def execute(self):
        if self.__instruction == "addi":
            registerStatus[self.__rd] = to_signed(cut_lower32(registerStatus[self.__rs]
                                                              + self.__imm16))
        elif self.__instruction == "andi":
            registerStatus[self.__rd] = to_signed(cut_lower32(registerStatus[self.__rs])
                                                  & self.__imm16)
        elif self.__instruction == "ori":
            registerStatus[self.__rd] = to_signed(cut_lower32(registerStatus[self.__rs])
                                                  | self.__imm16)
        print("# ${:02d} <= {:08x}".format(self.__rd, to_unsigned(registerStatus[self.__rd])))


class EXTLUI:
    __instruction = "lui"

    __rd = 0

    def __init__(self, rd, imm16=0):
        self.__rd = rd

        if imm16 == 0:
            self.__imm16 = generate_imm(method="EXTLUI")
        else:
            self.__imm16 = imm16

    def __repr__(self):
        return (self.__instruction +
                " $" + self.__rd.__str__() +
                ", 0x{:04x}".format(self.__imm16))

    def execute(self):
        registerStatus[self.__rd] = self.__imm16 << 16
        print("# ${:02d} <= {:08x}".format(self.__rd, to_unsigned(registerStatus[self.__rd])))


class BRANCHE:
    __used_instruction = ("beq", "bne")

    __instruction = ""

    __rs = 0
    __rt = 0

    __label = ""

    # beq执行不跳转
    # bne执行跳转

    # beq rs, rt, branch_label
    # ori $1, $0, 0x0001
    # ori $1, $0, 0x0002
    # branch_label: ori $1, 0x0003

    def __init__(self, link_data, rs=-1, rt=-1, specific_instruction=""):
        if specific_instruction == "":
            self.__instruction = self.__used_instruction[random.randint(0, len(self.__used_instruction) - 1)]
        else:
            self.__instruction = specific_instruction

        if rs == -1 and rt == -1:
            self.__rs = add_ready_data_list(method="NONZERO", method_para=(1,))
            self.__rt = add_ready_data_list(method="BRANCHE",
                                            method_para=(self.__instruction, registerStatus[self.__rs]))
        elif rs == -1 and rt != -1:
            self.__rs = add_ready_data_list(method="BRANCHE", method_para=(self.__instruction, link_data))
            self.__rt = rt
        elif rs != -1 and rt == -1:
            self.__rs = rs
            self.__rt = add_ready_data_list(method="BRANCHE", method_para=(self.__instruction, link_data))
        elif rs != -1 and rt != -1:
            self.__rs = rs
            self.__rt = rt

        self.__label = "branchlabel_" + branchLabelCounter.__str__()

    def __repr__(self):
        return (self.__instruction +
                " $" + self.__rs.__str__() +
                ", $" + self.__rt.__str__() +
                ", " + self.__label +
                "\nori $1, $0, 0x0001" +
                "\nori $1, $0, 0x0002\n" +
                self.__label + ": ori $1, 0x0003")


class MULTDIV:
    __used_instruction = ("mult", "multu", "div", "divu")

    __instruction = ""

    __rs = 0
    __rt = 0

    def __init__(self, rs=-1, rt=-1, specific_instruction=""):
        if specific_instruction == "":
            self.__instruction = self.__used_instruction[random.randint(0, len(self.__used_instruction) - 1)]
        else:
            self.__instruction = specific_instruction

        if rs == -1:
            self.__rs = add_ready_data_list(method="NONZERO", method_para=(1,))
        else:
            self.__rs = rs

        if rt == -1:
            self.__rt = add_ready_data_list(method="NONZERO", method_para=(0,))
        else:
            self.__rt = rt

    def __repr__(self):
        return (self.__instruction +
                " $" + self.__rs.__str__() +
                ", $" + self.__rt.__str__() +
                "\nmfhi $2" +
                "\nmflo $3")


class MLTO:
    __used_instruction = ("mthi", "mtlo")

    __instruction = ""

    __rs = 0

    def __init__(self, rs=-1, specific_instruction=""):
        if specific_instruction == "":
            self.__instruction = self.__used_instruction[random.randint(0, len(self.__used_instruction) - 1)]
        else:
            self.__instruction = specific_instruction

        if rs == -1:
            self.__rs = add_ready_data_list(method="NONZERO", method_para=(0,))
        else:
            self.__rs = rs

    def __repr__(self):
        return (self.__instruction +
                " $" + self.__rs.__str__() +
                "\nmfhi $2" +
                "\nmflo $3")


class MLFROM:
    __used_instruction = ("mfhi", "mflo")

    __instruction = ""

    __rd = 0

    def __init__(self, rd=-1, specific_instruction=""):
        if specific_instruction == "":
            self.__instruction = self.__used_instruction[random.randint(0, len(self.__used_instruction) - 1)]
        else:
            self.__instruction = specific_instruction

        self.__rd = rd

    def __repr__(self):
        return (self.__instruction +
                " $" + self.__rd.__str__())

    def execute(self):
        global HIStatus
        global LOStatus
        if self.__instruction == "mfhi":
            registerStatus[self.__rd] = HIStatus
        elif self.__instruction == "mflo":
            registerStatus[self.__rd] = LOStatus
        print("# ${:02d} <= {:08x}".format(self.__rd, to_unsigned(registerStatus[self.__rd])))


class LOAD:
    __used_instruction = ("lb", "lh", "lw")

    __instruction = ""

    __rd = 0
    __base = 0

    __offset = 0

    def __init__(self, rd, base=-1, offset=-4, specific_instruction=""):
        if specific_instruction == "":
            self.__instruction = self.__used_instruction[random.randint(0, len(self.__used_instruction) - 1)]
        else:
            self.__instruction = specific_instruction

        self.__rd = rd

        if base == -1:
            self.__base = add_ready_store_list(method=self.__instruction)
        else:
            # 这里一定要考虑地址的合法性！
            self.__base = base

        if offset == -4:
            if self.__instruction == "lb":
                self.__offset = random.randint(0, 3)
            elif self.__instruction == "lh":
                self.__offset = random.randint(0, 1) * 2
            elif self.__instruction == "lw":
                self.__offset = 0
        else:
            self.__offset = offset

    def __repr__(self):
        return (self.__instruction +
                " $" + self.__rd.__str__() +
                ", {:d}(${:d})".format(self.__offset, self.__base))

    def execute(self):
        address = (registerStatus[self.__base] + self.__offset) & 0xfffc
        data = memoryStatus[address]
        byte = address & 0x0003
        half = (address & 0x0002) >> 1
        if self.__instruction == "lb":
            registerStatus[self.__rd] = (data & (0xff << (8 * byte))) >> (8 * byte)
        elif self.__instruction == "lh":
            registerStatus[self.__rd] = (data & (0xffff << (16 * half))) >> (16 * half)
        elif self.__instruction == "lw":
            registerStatus[self.__rd] = memoryStatus[address]


class STORE:
    __used_instruction = ("sb", "sh", "sw")

    __instruction = ""

    __rd = 0
    __base = 0

    __offset = 0

    def __init__(self, rd, base=-1, offset=-4, specific_instruction=""):
        if specific_instruction == "":
            self.__instruction = self.__used_instruction[random.randint(0, len(self.__used_instruction) - 1)]
        else:
            self.__instruction = specific_instruction

        self.__rd = rd

        if base == -1:
            self.__base = add_ready_store_list(method=self.__instruction)
        else:
            # 这里一定要考虑地址的合法性！
            self.__base = base

        if offset == -4:
            if self.__instruction == "sb":
                self.__offset = random.randint(0, 3)
            elif self.__instruction == "sh":
                self.__offset = random.randint(0, 1) * 2
            elif self.__instruction == "sw":
                self.__offset = 0
        else:
            self.__offset = offset

    def __repr__(self):
        return (self.__instruction +
                " $" + self.__rd.__str__() +
                ", {:d}(${:d})".format(self.__offset, self.__base))


need_ready_store = 1
need_ready_mult = 1

for i in range(1):
    init_status_list()
    cleanRegisterList.append(CRASH_REGISTER)
    if need_ready_mult:
        HIStatus = 0xff8c11ac
        LOStatus = 0xf31cf4bf

    append_and_execute(ALREG(rd=CRASH_REGISTER))
    append_and_execute(ALIMM(rd=CRASH_REGISTER, rs=CRASH_REGISTER))
    append_and_execute(MLFROM(rd=CRASH_REGISTER))

    commandList.append(LOAD(rd=CRASH_REGISTER))

    print("# ===== READY =====")
    readyDataRegister = C_READY_DATA_START
    for ready_data in readyDataList:
        luiNumber = (ready_data & 0xffff0000) >> 16
        oriNumber = ready_data & 0x0000ffff
        print("lui ${:d}, 0x{:04x}".format(readyDataRegister, luiNumber))
        print("ori ${:d}, ${:d}, 0x{:04x}".format(readyDataRegister, readyDataRegister, oriNumber))
        readyDataRegister = readyDataRegister + 1

    readyStoreRegister = C_READY_STORE_START
    for ready_store in readyStoreList:
        print("ori ${:d}, $0, 0x{:04x}".format(readyStoreRegister, ready_store[1]))
        print("sw ${:d}, 0(${:d})".format(ready_store[0], readyStoreRegister))
        readyStoreRegister = readyStoreRegister + 1

    if need_ready_mult:
        # 采用固定值
        print("lui $2, 0xfd89\n" +
              "ori $2, $2, 0xe97f\n" +
              "lui $3, 0x2f1a\n" +
              "ori $3, $3, 0x14c1\n" +
              "mult $2, $3")
    else:
        print("nop\n"
              "nop\n"
              "nop")

    print("# ===== START =====")
    for command in commandList:
        print(command)

    print("# ===== CLEAN =====")
    for clean_register in cleanRegisterList:
        print("sub ${:d}, ${:d}, ${:d}".format(clean_register, clean_register, clean_register))
