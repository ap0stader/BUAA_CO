// Verified: 2024-08-27
`timescale 1ns / 1ps

`include "command.v"

`default_nettype none
module CTRL(
    input wire [5:0] opcode,
    input wire [5:0] funct,
    input wire [4:0] rt,
    output wire [1:0] OPSel,
    output wire [1:0] EXTSel,
    output wire [2:0] DMSel,
    output wire [1:0] NPCSel,
    output wire [2:0] FuncSel,
    output wire [2:0] CompSel,
    output wire GRFWE,
    output wire DMWE,
    output wire [1:0] GRFA3MUX,
    output wire [1:0] GRFWDMUX,
    output wire ALUrtMUX
    );
    
    // CTRL_AND

    wire R;
    wire IJ;
    
    assign R = (opcode == 6'b000000);
    assign IJ = ~R;

    // 算数与逻辑类
    // 1.算数类
    wire R_add;
    assign R_add = R & (funct == `R_add);
    // add指令不考虑溢出，实际上就是addu
    wire R_addu;
    assign R_addu = R_add | (R & (funct == `R_addu));   
    wire R_sub;
    assign R_sub = R & (funct == `R_sub);
    // sub指令不考虑溢出，实际上就是subu
    wire R_subu;
    assign R_subu = R_sub | (R & (funct == `R_subu));

    wire I_addiu;
    assign I_addiu = IJ & (opcode == `I_addiu);
    
    // 2.逻辑类
    wire R_and;
    assign R_and = R & (funct == `R_and);
    wire R_or;
    assign R_or = R & (funct == `R_or);
    wire R_xor;
    assign R_xor = R & (funct == `R_xor);
    wire R_nor;
    assign R_nor = R & (funct == `R_nor);
    wire R_sll;
    assign R_sll = R & (funct == `R_sll);
    wire R_srl;
    assign R_srl = R & (funct == `R_srl);
    wire R_sra;
    assign R_sra = R & (funct == `R_sra);
    wire R_sllv;
    assign R_sllv = R & (funct == `R_sllv);
    wire R_srlv;
    assign R_srlv = R & (funct == `R_srlv);
    wire R_srav;
    assign R_srav = R & (funct == `R_srav);

    wire I_andi;
    assign I_andi = IJ & (opcode == `I_andi);
    wire I_ori;
    assign I_ori = IJ & (opcode == `I_ori);
    wire I_xori;
    assign I_xori = IJ & (opcode == `I_xori);
    
    // 寄存器操作类
    wire R_slt;
    assign R_slt = R & (funct == `R_slt);
    wire R_sltu;
    assign R_sltu = R & (funct == `R_sltu);

    wire I_slti;
    assign I_slti = IJ & (opcode == `I_slti);
    wire I_sltiu;
    assign I_sltiu = IJ & (opcode == `I_sltiu);
    wire I_lui;
    assign I_lui = IJ & (opcode == `I_lui);

    // 分支与跳转类
    // 1.分支类
    wire I_regimm;
    assign I_regimm = IJ & (opcode == `I_regimm);
    wire I_beq;
    assign I_beq = IJ & (opcode == `I_beq);
    wire I_bne;
    assign I_bne = IJ & (opcode == `I_bne);
    wire I_blez;
    assign I_blez = IJ & (opcode == `I_blez);
    wire I_bgtz;
    assign I_bgtz = IJ & (opcode == `I_bgtz);

    wire rt_bltz;
    assign rt_bltz = I_regimm & (rt == `rt_bltz);
    wire rt_bgez;
    assign rt_bgez = I_regimm & (rt == `rt_bgez);

    // 2.跳转类
    wire R_jr;
    assign R_jr = R & (funct == `R_jr);
    wire R_jalr;
    assign R_jalr = R & (funct == `R_jalr);

    wire J_j;
    assign J_j = IJ & (opcode == `J_j);
    wire J_jal;
    assign J_jal = IJ & (opcode == `J_jal);

    // 内存操作类
    wire I_lb;
    assign I_lb = IJ & (opcode == `I_lb);
    wire I_lh;
    assign I_lh = IJ & (opcode == `I_lh);
    wire I_lw;
    assign I_lw = IJ & (opcode == `I_lw);
    wire I_lbu;
    assign I_lbu = IJ & (opcode == `I_lbu);
    wire I_lhu;
    assign I_lhu = IJ & (opcode == `I_lhu);
    wire I_sb;
    assign I_sb = IJ & (opcode == `I_sb);
    wire I_sh;
    assign I_sh = IJ & (opcode == `I_sh);
    wire I_sw;
    assign I_sw = IJ & (opcode == `I_sw);


    // CTRL_OR

    // P4要求实现指令：
    // add, sub, ori, lw, sw, beq, lui, jal, jr, nop

    assign OPSel = (I_ori) ? 2'b01 :
                   2'b00;

    assign EXTSel = (I_ori) ? 2'b01 :
                    (I_lui) ? 2'b10 :
                    2'b00;

    assign DMSel = opcode[2:0];

    assign NPCSel = (I_beq) ? 2'b01 :
                    (J_jal) ? 2'b10 :
                    (R_jr) ? 2'b11 :
                    2'b00;

    assign FuncSel = (OPSel == 2'b00) ? {2'b0, R_subu} :
                     (OPSel == 2'b01) ? (IJ ? opcode[2:0] : funct[2:0]) :
                     (OPSel == 2'b10) ? funct[2:0] :
                     3'b000; //OPSel == 2'b11
    
    assign CompSel = 3'b100; // Only beq. Fixed 3'b100
    
    assign GRFWE = (R & ~R_jr) | (I_ori) | (I_lui) | (I_lw) | (J_jal);

    assign DMWE = (I_sw);

    assign GRFA3MUX = (R) ? 2'b01 :
                      (IJ & ~J_jal) ? 2'b10 :
                      (J_jal) ? 2'b11 : // ATTENTION: jal is prior than IJ
                      2'b00;

    assign GRFWDMUX = (I_lui) ? 2'b01 :
                      (I_lw) ? 2'b10 :
                      (J_jal) ? 2'b11 :
                      2'b00;

    assign ALUrtMUX = IJ & ~(I_beq | J_jal);

endmodule
