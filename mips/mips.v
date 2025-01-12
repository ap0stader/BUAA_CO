// Verified: 2024-08-28
`timescale 1ns / 1ps

`default_nettype none
module mips(
    input wire clk,
    input wire reset
    );

    // 接线

    // 控制器
    // CTRL_Decoder
    wire [2:0] CTRL_D_CompSel;
    wire [1:0] CTRL_D_EXTSel;
    wire [1:0] CTRL_D_NPCSel;
    wire [1:0] CTRL_D_OPSel;
    wire [1:0] CTRL_D_FuncSel;
    wire [2:0] CTRL_D_DMSel;
    wire CTRL_D_DMWE;
    wire CTRL_D_GRFWE;
    wire [1:0] CTRL_D_GRF_A3_D_Sel;
    wire [1:0] CTRL_D_GRF_WD_W_Sel;
    wire CTRL_D_ALU_B_E_Sel;
    wire [1:0] CTRL_D_Tuse_rs;
    wire [1:0] CTRL_D_Tuse_rt;

    // CTRL_Stall
    wire CTRL_S_IFU_EN_N;
    wire CTRL_S_FR_D_EN_N;
    wire CTRL_S_FR_E_RESET;

    // CTRL_Forward
    wire [2:0] CTRL_F_FMUX_V1_D_Sel;
    wire [2:0] CTRL_F_FMUX_V2_D_Sel;
    wire [1:0] CTRL_F_FMUX_V1_E_Sel;
    wire [1:0] CTRL_F_FMUX_V2_E_Sel;
    wire CTRL_F_FMUX_DM_D_M_Sel;


    // F级
    // IFU
    wire [31:0] IFU_Instr;
    wire [31:0] IFU_InstrAddr;


    // D级
    // FR_D
    wire [31:0] Instr_D;
    wire [31:0] InstrAddr_D;

    // SPL
    wire [5:0] SPL_opcode;
    wire [4:0] SPL_rs;
    wire [4:0] SPL_rt;
    wire [4:0] SPL_rd;
    wire [4:0] SPL_shamt;
    wire [5:0] SPL_funct;
    wire [15:0] SPL_imm16;
    wire [25:0] SPL_instr_index;

    // GRF_R
    wire [31:0] GRF_V1;
    wire [31:0] GRF_V2;

    // EXT
    wire [31:0] EXT_ext32;

    // COMP
    wire COMP_BranchComp;

    // pc8
    wire [31:0] pc8_D;

    // MUX
    wire [4:0] MUX_GRF_A3_D;

    // FMUX
    wire [31:0] FMUX_V1_D;
    wire [31:0] FMUX_V2_D;


    // E级
    // FR_E
    wire DMWE_E;
    wire GRFWE_E;
    wire [2:0] DMSel_E;
    wire [1:0] FuncSel_E;
    wire [1:0] OPSel_E;
    wire [1:0] GRF_WD_W_Sel_E;
    wire ALU_B_E_Sel_E;
    wire [31:0] V1_E;
    wire [31:0] V2_E;
    wire [4:0] shamt_E;
    wire [4:0] GRF_A3_E;
    wire [31:0] ext32_E;
    wire [31:0] pc8_E;
    wire [1:0] FMUX_V1_E_Sel_E;
    wire [1:0] FMUX_V2_E_Sel_E;
    wire FMUX_DM_D_M_Sel_E;

    // ALU
    wire [31:0] ALU_OP;

    // MUX
    wire [31:0] MUX_ALU_B_E;

    // FMUX
    wire [31:0] FMUX_V1_E;
    wire [31:0] FMUX_V2_E;


    // M级
    // FR_M
    wire DMWE_M;
    wire GRFWE_M;
    wire [2:0] DMSel_M;
    wire [1:0] GRF_WD_W_Sel_M;
    wire [31:0] V2_M;
    wire [31:0] OP_M;
    wire [4:0] GRF_A3_M;
    wire [31:0] ext32_M;
    wire [31:0] pc8_M;
    wire FMUX_DM_D_M_Sel_M;

    // DM
    wire [31:0] DM_Q;

    // FMUX
    wire [31:0] FMUX_DM_D_M;


    // W级
    // FR_W
    wire GRFWE_W;
    wire [1:0] GRF_WD_W_Sel_W;
    wire [31:0] OP_W;
    wire [31:0] DM_Q_W;
    wire [4:0] GRF_A3_W;
    wire [31:0] ext32_W;
    wire [31:0] pc8_W;

    // MUX
    wire [31:0] MUX_GRF_WD_W;


    // 评测需要输出
    wire [31:0] Exam_InstrAddr_E;
    wire [31:0] Exam_InstrAddr_M;
    wire [31:0] Exam_InstrAddr_W;
    wire [31:0] Exam_RAM_D;


    // 各模块
    
    // 控制器
    CTRL_Decoder CTRL_Decoder_instance (
    .opcode(SPL_opcode),
    .funct(SPL_funct),
    .rt(SPL_rt),

    .CompSel(CTRL_D_CompSel),
    .EXTSel(CTRL_D_EXTSel),
    .NPCSel(CTRL_D_NPCSel),
    .OPSel(CTRL_D_OPSel),
    .FuncSel(CTRL_D_FuncSel),
    .DMSel(CTRL_D_DMSel),
    .DMWE(CTRL_D_DMWE),
    .GRFWE(CTRL_D_GRFWE),
    .GRF_A3_D_Sel(CTRL_D_GRF_A3_D_Sel),
    .GRF_WD_W_Sel(CTRL_D_GRF_WD_W_Sel),
    .ALU_B_E_Sel(CTRL_D_ALU_B_E_Sel),
    .Tuse_rs(CTRL_D_Tuse_rs),
    .Tuse_rt(CTRL_D_Tuse_rt)
    );

    CTRL_Stall CTRL_Stall_instance (
    .Tuse_rs(CTRL_D_Tuse_rs),
    .Tuse_rt(CTRL_D_Tuse_rt),
    .SPL_rs(SPL_rs),
    .SPL_rt(SPL_rt),

    .GRFWE_E(GRFWE_E),
    .GRFWE_M(GRFWE_M),
    .GRF_WD_W_Sel_E(GRF_WD_W_Sel_E),
    .GRF_WD_W_Sel_M(GRF_WD_W_Sel_M),
    .GRF_A3_E(GRF_A3_E),
    .GRF_A3_M(GRF_A3_M),

    .IFU_EN_N(CTRL_S_IFU_EN_N),
    .FR_D_EN_N(CTRL_S_FR_D_EN_N),
    .FR_E_RESET(CTRL_S_FR_E_RESET)
    );

    CTRL_Forward CTRL_Forward_instance (
    .Tuse_rs(CTRL_D_Tuse_rs),
    .Tuse_rt(CTRL_D_Tuse_rt),
    .SPL_rs(SPL_rs),
    .SPL_rt(SPL_rt),

    .GRFWE_E(GRFWE_E),
    .GRFWE_M(GRFWE_M),
    .GRF_WD_W_Sel_E(GRF_WD_W_Sel_E),
    .GRF_WD_W_Sel_M(GRF_WD_W_Sel_M),
    .GRF_A3_E(GRF_A3_E),
    .GRF_A3_M(GRF_A3_M),

    .FMUX_V1_D_Sel(CTRL_F_FMUX_V1_D_Sel),
    .FMUX_V2_D_Sel(CTRL_F_FMUX_V2_D_Sel),
    .FMUX_V1_E_Sel(CTRL_F_FMUX_V1_E_Sel),
    .FMUX_V2_E_Sel(CTRL_F_FMUX_V2_E_Sel),
    .FMUX_DM_D_M_Sel(CTRL_F_FMUX_DM_D_M_Sel)
    );


    // F级


    IFU IFU_instance (
    .RESET(reset),
    .clk(clk),
    .STALL_EN_N(CTRL_S_IFU_EN_N),

    .NPCSel(CTRL_D_NPCSel),
    .BranchComp(COMP_BranchComp),
    .offset(SPL_imm16),
    .instr_index(SPL_instr_index),
    .instr_register(FMUX_V1_D),

    .Instr(IFU_Instr),
    .InstrAddr(IFU_InstrAddr)
    );


    // D级


    FR_D FR_D_instance (
    .RESET(reset),
    .clk(clk),
    .STALL_EN_N(CTRL_S_FR_D_EN_N),

    .D_Instr(IFU_Instr),
    .D_InstrAddr(IFU_InstrAddr),

    .Q_Instr(Instr_D),
    .Q_InstrAddr(InstrAddr_D)
    );

    SPL SPL_instance (
    .Instr(Instr_D),

    .opcode(SPL_opcode),
    .rs(SPL_rs),
    .rt(SPL_rt),
    .rd(SPL_rd),
    .shamt(SPL_shamt),
    .funct(SPL_funct),
    .imm16(SPL_imm16),
    .instr_index(SPL_instr_index)
    );

    GRF GRF_instance (
    .RESET(reset),
    .clk(clk),

    // _W
    .WE(GRFWE_W),

    // _R
    .A1(SPL_rs),
    .A2(SPL_rt),

    // _W
    .A3(GRF_A3_W),
    .D(MUX_GRF_WD_W),

    // _R
    .V1(GRF_V1),
    .V2(GRF_V2)
    );

    EXT EXT_instance (
    .EXTSel(CTRL_D_EXTSel),
    .imm16(SPL_imm16),
    .ext32(EXT_ext32)
    );

    COMP COMP_instance (
    .CompSel(CTRL_D_CompSel),
    .A(FMUX_V1_D),
    .B(FMUX_V2_D),
    .BranchComp(COMP_BranchComp)
    );

    assign pc8_D = InstrAddr_D + 32'd8;


    assign MUX_GRF_A3_D = (CTRL_D_GRF_A3_D_Sel == 2'b10) ? SPL_rt :
                          (CTRL_D_GRF_A3_D_Sel == 2'b11) ? 5'd31 :
                          SPL_rd ; // CTRL_D_GRF_A3_D_Sel == 2'b00

    assign FMUX_V1_D = (CTRL_F_FMUX_V1_D_Sel == 3'b011) ? OP_M :
                       (CTRL_F_FMUX_V1_D_Sel == 3'b100) ? ext32_M :
                       (CTRL_F_FMUX_V1_D_Sel == 3'b101) ? pc8_M :
                       (CTRL_F_FMUX_V1_D_Sel == 3'b110) ? ext32_E :
                       (CTRL_F_FMUX_V1_D_Sel == 3'b111) ? pc8_E :
                       GRF_V1;

    assign FMUX_V2_D = (CTRL_F_FMUX_V2_D_Sel == 3'b011) ? OP_M :
                       (CTRL_F_FMUX_V2_D_Sel == 3'b100) ? ext32_M :
                       (CTRL_F_FMUX_V2_D_Sel == 3'b101) ? pc8_M :
                       (CTRL_F_FMUX_V2_D_Sel == 3'b110) ? ext32_E :
                       (CTRL_F_FMUX_V2_D_Sel == 3'b111) ? pc8_E :
                       GRF_V2;


    // E级


    FR_E FR_E_instance (
    // 评测需要输出
    .D_Exam_InstrAddr(InstrAddr_D),
    .Q_Exam_InstrAddr(Exam_InstrAddr_E),

    .RESET(reset),
    .clk(clk),
    .STALL_RESET(CTRL_S_FR_E_RESET),

    .D_DMWE(CTRL_D_DMWE),
    .D_GRFWE(CTRL_D_GRFWE),
    .D_DMSel(CTRL_D_DMSel),
    .D_FuncSel(CTRL_D_FuncSel),
    .D_OPSel(CTRL_D_OPSel),
    .D_GRF_WD_W_Sel(CTRL_D_GRF_WD_W_Sel),
    .D_ALU_B_E_Sel(CTRL_D_ALU_B_E_Sel),
    .D_V1(FMUX_V1_D),
    .D_V2(FMUX_V2_D),
    .D_shamt(SPL_shamt),
    .D_GRF_A3(MUX_GRF_A3_D),
    .D_ext32(EXT_ext32),
    .D_pc8(pc8_D),
    .D_FMUX_V1_E_Sel(CTRL_F_FMUX_V1_E_Sel),
    .D_FMUX_V2_E_Sel(CTRL_F_FMUX_V2_E_Sel),
    .D_FMUX_DM_D_M_Sel(CTRL_F_FMUX_DM_D_M_Sel),

    .Q_DMWE(DMWE_E),
    .Q_GRFWE(GRFWE_E),
    .Q_DMSel(DMSel_E),
    .Q_FuncSel(FuncSel_E),
    .Q_OPSel(OPSel_E),
    .Q_GRF_WD_W_Sel(GRF_WD_W_Sel_E),
    .Q_ALU_B_E_Sel(ALU_B_E_Sel_E),
    .Q_V1(V1_E),
    .Q_V2(V2_E),
    .Q_shamt(shamt_E),
    .Q_GRF_A3(GRF_A3_E),
    .Q_ext32(ext32_E),
    .Q_pc8(pc8_E),
    .Q_FMUX_V1_E_Sel(FMUX_V1_E_Sel_E),
    .Q_FMUX_V2_E_Sel(FMUX_V2_E_Sel_E),
    .Q_FMUX_DM_D_M_Sel(FMUX_DM_D_M_Sel_E)
    );

    ALU ALU_instance (
    .OPSel(OPSel_E),
    .FuncSel(FuncSel_E),
    .A(FMUX_V1_E),
    .B(MUX_ALU_B_E),
    .shamt(shamt_E),
    .OP(ALU_OP)
    );


    assign MUX_ALU_B_E = ALU_B_E_Sel_E ? ext32_E : FMUX_V2_E;

    assign FMUX_V1_E = (FMUX_V1_E_Sel_E == 2'b10) ? DM_Q_W :
                       (FMUX_V1_E_Sel_E == 2'b11) ? OP_M : 
                       V1_E;

    assign FMUX_V2_E = (FMUX_V2_E_Sel_E == 2'b10) ? DM_Q_W :
                       (FMUX_V2_E_Sel_E == 2'b11) ? OP_M : 
                       V2_E;


    // M级


    FR_M FR_M_instance (
    // 评测需要输出
    .D_Exam_InstrAddr(Exam_InstrAddr_E),
    .Q_Exam_InstrAddr(Exam_InstrAddr_M),

    .RESET(reset),
    .clk(clk),

    .D_DMWE(DMWE_E),
    .D_GRFWE(GRFWE_E),
    .D_DMSel(DMSel_E),
    .D_GRF_WD_W_Sel(GRF_WD_W_Sel_E),
    .D_V2(FMUX_V2_E),
    .D_OP(ALU_OP),
    .D_GRF_A3(GRF_A3_E),
    .D_ext32(ext32_E),
    .D_pc8(pc8_E),
    .D_FMUX_DM_D_M_Sel(FMUX_DM_D_M_Sel_E),

    .Q_DMWE(DMWE_M),
    .Q_GRFWE(GRFWE_M),
    .Q_DMSel(DMSel_M),
    .Q_GRF_WD_W_Sel(GRF_WD_W_Sel_M),
    .Q_V2(V2_M),
    .Q_OP(OP_M),
    .Q_GRF_A3(GRF_A3_M),
    .Q_ext32(ext32_M),
    .Q_pc8(pc8_M),
    .Q_FMUX_DM_D_M_Sel(FMUX_DM_D_M_Sel_M)
    );

    DM DM_instance (
    .RESET(reset),
    .clk(clk),

    .WE(DMWE_M),
    .DMSel(DMSel_M),
    .A(OP_M),
    .D(FMUX_DM_D_M),
    .Q(DM_Q),
    .Exam_RAM_D(Exam_RAM_D)
    );


    assign FMUX_DM_D_M = (FMUX_DM_D_M_Sel_M == 1'b1) ? DM_Q_W :
                         V2_M;


    // W级


    FR_W FR_W_instance (
    // 评测需要输出
    .D_Exam_InstrAddr(Exam_InstrAddr_M),
    .Q_Exam_InstrAddr(Exam_InstrAddr_W),

    .RESET(reset),
    .clk(clk),

    .D_GRFWE(GRFWE_M),
    .D_GRF_WD_W_Sel(GRF_WD_W_Sel_M),
    .D_OP(OP_M),
    .D_DM_Q(DM_Q),
    .D_GRF_A3(GRF_A3_M),
    .D_ext32(ext32_M),
    .D_pc8(pc8_M),

    .Q_GRFWE(GRFWE_W),
    .Q_GRF_WD_W_Sel(GRF_WD_W_Sel_W),
    .Q_OP(OP_W),
    .Q_DM_Q(DM_Q_W),
    .Q_GRF_A3(GRF_A3_W),
    .Q_ext32(ext32_W),
    .Q_pc8(pc8_W)
    );

    assign MUX_GRF_WD_W = (GRF_WD_W_Sel_W == 2'b01) ? DM_Q_W :
                          (GRF_WD_W_Sel_W == 2'b10) ? ext32_W :
                          (GRF_WD_W_Sel_W == 2'b11) ? pc8_W :
                          OP_W;

    // 评测输出内容
    always @(posedge clk) begin
        if(GRFWE_W && GRF_A3_W != 5'd0) begin
            $display("%d@%h: $%d <= %h",$time, Exam_InstrAddr_W, GRF_A3_W, MUX_GRF_WD_W);
        end
        if(DMWE_M) begin
            $display("%d@%h: *%h <= %h",$time, Exam_InstrAddr_M, OP_M, Exam_RAM_D);
        end
    end
endmodule
