// Verified: 2024-08-29

// 算数与逻辑运算类
// 1.算数类
`define R_add 6'b100000
`define R_addu 6'b100001
`define R_sub 6'b100010
`define R_subu 6'b100011

`define I_addi 6'b001000
`define I_addiu 6'b001001

// 2.逻辑类
`define R_and 6'b100100
`define R_or 6'b100101
`define R_xor 6'b100110
`define R_nor 6'b100111
`define R_sll 6'b000000
`define R_srl 6'b000010
`define R_sra 6'b000011
`define R_sllv 6'b000100
`define R_srlv 6'b000110
`define R_srav 6'b000111

`define I_andi 6'b001100
`define I_ori 6'b001101
`define I_xori 6'b001110

// 3.乘除法类
`define R_mult 6'b011000
`define R_multu 6'b011001
`define R_div 6'b011010
`define R_divu 6'b011011
`define R_mfhi 6'b010000
`define R_mthi 6'b010001
`define R_mflo 6'b010010
`define R_mtlo 6'b010011

// 寄存器操作类
`define R_slt 6'b101010
`define R_sltu 6'b101011

`define I_slti 6'b001010
`define I_sltiu 6'b001011
`define I_lui 6'b001111


// 分支与跳转类
// 1.分支类
`define I_regimm 6'b000001
`define I_beq 6'b000100
`define I_bne 6'b000101
`define I_blez 6'b000110
`define I_bgtz 6'b000111

`define rt_bltz 5'b00000
`define rt_bgez 5'b00001

// 2.跳转类
`define R_jr 6'b001000
`define R_jalr 6'b001001

`define J_j 6'b000010
`define J_jal 6'b000011


// 系统桥操作类
`define I_lb 6'b100000
`define I_lh 6'b100001
`define I_lw 6'b100011
`define I_lbu 6'b100100
`define I_lhu 6'b100101
`define I_sb 6'b101000
`define I_sh 6'b101001
`define I_sw 6'b101011


// 异常处理类
`define COP0 6'b010000

`define rs_mfc0 5'b00000
`define rs_mtc0 5'b00100
`define rs_eret 5'b10000
`define funct_eret 6'b011000

`define R_syscall 6'b001100
