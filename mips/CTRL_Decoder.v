// Verified: 2024-08-29
`timescale 1ns / 1ps

`default_nettype none

`include "CTRL_command.v"
module CTRL_Decoder(
    input wire [5:0] opcode,
    input wire [5:0] funct,
    input wire [4:0] rs,
    input wire [4:0] rt,

    input wire CP0_Q_EXL,

    output wire SYSCALL,
    output wire UNKNOWN,
    output wire ISNEXTBD,
    output wire ERET,
    
    output wire [2:0] CompSel,
    output wire [1:0] EXTSel,
    output wire [1:0] NPCSel,

    output wire [1:0] OPSel,
    output wire [1:0] FuncSel,
    output wire [2:0] MULTSel,
    output wire ISMULTDIV,

    output wire ISLOADSTORE,
    output wire [3:0] BridgeSel,
    output wire CP0WE,

    output wire GRFWE,

    output wire [1:0] GRF_A3_D_Sel,
    output wire ALU_B_E_Sel,
    output wire E_RES_E_Sel,
    output wire [1:0] GRF_WD_W_Sel,

    output wire [1:0] Tuse_rs,
    output wire [1:0] Tuse_rt
    );
    
    // CTRL_AND

    wire R  = (opcode == 6'b000000);
    wire IJ = ~R;

    // 算数与逻辑运算类
    // 1.算数类
    wire R_add  = R & (funct == `R_add);
    wire R_addu = R & (funct == `R_addu);   
    wire R_sub  = R & (funct == `R_sub);
    wire R_subu = R & (funct == `R_subu);

    wire I_addi  = IJ & (opcode == `I_addi);
    wire I_addiu = IJ & (opcode == `I_addiu);
    
    // 2.逻辑类
    wire R_and = R & (funct == `R_and);
    wire R_or  = R & (funct == `R_or);
    wire R_xor = R & (funct == `R_xor);
    wire R_nor = R & (funct == `R_nor);
    wire R_sll = R & (funct == `R_sll);
    wire R_srl = R & (funct == `R_srl);
    wire R_sra = R & (funct == `R_sra);
    wire R_sllv = R & (funct == `R_sllv);
    wire R_srlv = R & (funct == `R_srlv);
    wire R_srav = R & (funct == `R_srav);

    wire I_andi = IJ & (opcode == `I_andi);
    wire I_ori  = IJ & (opcode == `I_ori);
    wire I_xori = IJ & (opcode == `I_xori);

    // 3.乘除法类
    wire R_mult  = R & (funct == `R_mult);
    wire R_multu = R & (funct == `R_multu);
    wire R_div   = R & (funct == `R_div);
    wire R_divu  = R & (funct == `R_divu);
    wire R_mfhi  = R & (funct == `R_mfhi);
    wire R_mthi  = R & (funct == `R_mthi);
    wire R_mflo  = R & (funct == `R_mflo);
    wire R_mtlo  = R & (funct == `R_mtlo);
    

    // 寄存器操作类
    wire R_slt  = R & (funct == `R_slt);
    wire R_sltu = R & (funct == `R_sltu);

    wire I_slti  = IJ & (opcode == `I_slti);
    wire I_sltiu = IJ & (opcode == `I_sltiu);
    wire I_lui   = IJ & (opcode == `I_lui);


    // 分支与跳转类
    // 1.分支类
    wire I_regimm = IJ & (opcode == `I_regimm);
    wire I_beq    = IJ & (opcode == `I_beq);
    wire I_bne    = IJ & (opcode == `I_bne);
    wire I_blez   = IJ & (opcode == `I_blez);
    wire I_bgtz   = IJ & (opcode == `I_bgtz);

    wire rt_bltz = I_regimm & (rt == `rt_bltz);
    wire rt_bgez = I_regimm & (rt == `rt_bgez);

    // 2.跳转类
    wire R_jr   = R & (funct == `R_jr);
    wire R_jalr = R & (funct == `R_jalr);

    wire J_j   = IJ & (opcode == `J_j);
    wire J_jal = IJ & (opcode == `J_jal);


    // 系统桥操作类
    wire I_lb  = IJ & (opcode == `I_lb);
    wire I_lh  = IJ & (opcode == `I_lh);
    wire I_lw  = IJ & (opcode == `I_lw);
    wire I_lbu = IJ & (opcode == `I_lbu);
    wire I_lhu = IJ & (opcode == `I_lhu);
    wire I_sb  = IJ & (opcode == `I_sb);
    wire I_sh  = IJ & (opcode == `I_sh);
    wire I_sw  = IJ & (opcode == `I_sw);

    
    // 异常处理类
    wire COP0    = opcode == `COP0;

    wire rs_mfc0 = COP0 & (rs == `rs_mfc0);
    wire rs_mtc0 = COP0 & (rs == `rs_mtc0);
    wire rs_eret = COP0 & (rs == `rs_eret) & (funct == `funct_eret);

    wire R_syscall = R & (funct == `R_syscall);


    // 指令分类信号

    wire ALREG = R_add | R_addu | R_sub | R_subu |
                 R_and | R_or   | R_xor | R_nor  | 
                 R_sll | R_srl  | R_sra | R_sllv | R_srlv | R_srav |
                 R_slt | R_sltu;

    wire ALIMM = I_addi | I_addiu | I_slti | I_sltiu |
                 I_andi | I_ori | I_xori;

    wire MULTDIV = R_mult | R_multu | R_div | R_divu;

    wire MLFROM = R_mfhi | R_mflo;

    wire MLTO = R_mthi | R_mtlo;

    wire EXTLUI = I_lui;

    wire BRANCHE = I_beq | I_bne;
                  
    wire BRANCHZ = rt_bltz | rt_bgez |
                   I_blez | I_bgtz;

    wire JUMPR = R_jr;

    wire JUMPW = J_jal;

    wire JUMPRW = R_jalr;

    wire LOAD = I_lb | I_lh | I_lw | I_lbu | I_lhu;

    wire STORE = I_sb | I_sh | I_sw;

    wire MFCOP = rs_mfc0;

    wire MTCOP = rs_mtc0;


    // CTRL_OR

    assign SYSCALL = R_syscall;

    assign UNKNOWN = ~ (ALREG   | ALIMM   | 
                        MULTDIV | MLFROM  | MLTO | 
                        EXTLUI  | 
                        BRANCHE | BRANCHZ |
                        JUMPR   | JUMPW   | JUMPRW | 
                        LOAD    | STORE   | 
                        MFCOP   | MTCOP   | 
                        J_j     | rs_eret | R_syscall);
    
    assign ISNEXTBD = BRANCHE | BRANCHZ |
                      JUMPR   | JUMPW   | JUMPRW;
    
    assign ERET = rs_eret & CP0_Q_EXL;


    assign CompSel = (rt_bltz) ? 3'b000 :
                     (rt_bgez) ? 3'b001 : 
                     (I_beq)   ? 3'b100 :
                     (I_bne)   ? 3'b101 :
                     (I_blez)  ? 3'b110 :
                     3'b111; // I_bgtz和其他

    assign EXTSel = (I_andi | I_ori | I_xori) ? 2'b01 :
                    (I_lui) ? 2'b10 :
                    2'b00; // 其他

    assign NPCSel = (BRANCHE | BRANCHZ) ? 2'b01 :
                    (J_j  | J_jal)      ? 2'b10 :
                    (R_jr | R_jalr)     ? 2'b11 :
                    2'b00; // 其他


    assign OPSel = (R_and  | R_or   | R_xor | R_nor |
                    I_andi | I_ori  | I_xori) ? 2'b01 : 
                   (R_sll  | R_srl  | R_sra |
                    R_sllv | R_srlv | R_srav) ? 2'b10 :
                   (R_slt  | R_sltu |
                    I_slti | I_sltiu)         ? 2'b11 : 
                   2'b00; // 其他（算数运算）

    wire [1:0] FuncSel_arith =  R_subu          ? 2'b01 :
                               (R_add | I_addi) ? 2'b10 :
                               (LOAD  | STORE)  ? 2'b10 :
                               (R_sub)          ? 2'b11 :
                               2'b00; // 默认值为00即不考虑算数溢出加法，避免意外触发算数溢出异常

    assign FuncSel = (OPSel == 2'b00) ? 
                     FuncSel_arith :
                     (OPSel == 2'b01) ? 
                     (IJ ? opcode[1:0] : funct[1:0]) :
                     (OPSel == 2'b10) ? 
                     funct[1:0] : 
                     (OPSel == 2'b11) ? 
                     {1'b0, R_sltu | I_sltiu} : 
                     2'b00; // 其他特殊情况

    assign MULTSel = {funct[3], funct[1:0]};

    assign ISMULTDIV = MULTDIV | MLTO | MLFROM;


    assign ISLOADSTORE = LOAD | STORE;

    assign BridgeSel = opcode[3:0];

    assign CP0WE = MTCOP;


    assign GRFWE = ALREG  | ALIMM  | EXTLUI |
                   MLFROM | 
                   LOAD   | 
                   JUMPW  | JUMPRW | 
                   MFCOP;


    assign GRF_A3_D_Sel = (ALIMM | EXTLUI ) ? 2'b10 :
                          (LOAD  | MFCOP)   ? 2'b10 :
                          (JUMPW)           ? 2'b11 :
                          2'b00; // 其他

    assign ALU_B_E_Sel = ALIMM | LOAD | STORE;

    assign E_RES_E_Sel = MLFROM;

    assign GRF_WD_W_Sel = (LOAD  | MFCOP)  ? 2'b01 :
                          (EXTLUI)         ? 2'b10 :
                          (JUMPW | JUMPRW) ? 2'b11 :
                          2'b00;


    assign Tuse_rs = (BRANCHE | BRANCHZ | JUMPR | JUMPRW)            ? 2'd0 :
                     (ALREG | ALIMM | MULTDIV | MLTO | LOAD | STORE) ? 2'd1 :
                     2'd3;

    assign Tuse_rt = (BRANCHE)         ? 2'd0 :
                     (ALREG | MULTDIV) ? 2'd1 :
                     (STORE | MTCOP)   ? 2'd2 :
                     2'd3;

endmodule
