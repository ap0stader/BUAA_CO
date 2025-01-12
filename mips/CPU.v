// Verified: 2024-08-29
`timescale 1ns / 1ps

`default_nettype none

`define nop 32'h0000_0000
`define A_EPC 5'd14

module CPU(
    input  wire        CPU_RESET,
    input  wire        CPU_clk,

    output wire [31:0] CPU_macroscopic_pc,

    output wire [31:0] CPU_IFU_InstrAddr,
    input  wire [31:0] CPU_IFU_Instr,

    output wire        CPU_GRFWE_W,
    output wire [ 4:0] CPU_GRF_A3_W,
    output wire [31:0] CPU_GRF_WD_W,
    // 评测需要输出
    output wire [31:0] CPU_Exam_InstrAddr_W,

    output wire        CPU_Req,
    output wire [ 3:0] CPU_BridgeSel_M,
    output wire        CPU_ISLOADSTORE_M,
    output wire [31:0] CPU_BRIDGE_A,
    output wire [31:0] CPU_BRIDGE_D,
    input  wire [ 1:0] CPU_BRIDGE_AdE,
    input  wire [ 5:0] CPU_BRIDGE_HWInt,
    input  wire [31:0] CPU_BRIDGE_Q
);
    
    // 接线

    // 控制器
    // CTRL_Decoder
    wire       CTRL_D_SYSCALL;
    wire       CTRL_D_UNKNOWN;
    wire       CTRL_D_ISNEXTBD;
    wire       CTRL_D_ERET;
    wire [2:0] CTRL_D_CompSel;
    wire [1:0] CTRL_D_EXTSel;
    wire [1:0] CTRL_D_NPCSel;
    wire [1:0] CTRL_D_OPSel;
    wire [1:0] CTRL_D_FuncSel;
    wire [2:0] CTRL_D_MULTSel;
    wire       CTRL_D_ISMULTDIV;
    wire       CTRL_D_ISLOADSTORE;
    wire [3:0] CTRL_D_BridgeSel;
    wire       CTRL_D_CP0WE;
    wire       CTRL_D_GRFWE;
    wire [1:0] CTRL_D_GRF_A3_D_Sel;
    wire       CTRL_D_ALU_B_E_Sel;
    wire       CTRL_D_E_RES_E_Sel;
    wire [1:0] CTRL_D_GRF_WD_W_Sel;
    wire [1:0] CTRL_D_Tuse_rs;
    wire [1:0] CTRL_D_Tuse_rt;

    // CTRL_Stall
    wire CTRL_S_IFU_EN_N;
    wire CTRL_S_D_EN_N;
    wire CTRL_S_FR_E_RESET;

    // CTRL_Forward
    wire [2:0] CTRL_F_FMUX_V1_D_Sel;
    wire [2:0] CTRL_F_FMUX_V2_D_Sel;
    wire [1:0] CTRL_F_FMUX_V1_E_Sel;
    wire [1:0] CTRL_F_FMUX_V2_E_Sel;
    wire       CTRL_F_FMUX_V2_M_Sel;


    // F级
    // IFU
    wire [31:0] IFU_InstrAddr;

    // ECMUX_F
    wire [4:0] ECMUX_F_ExcCode_F;
    wire       ECMUX_F_AdEL_F;

    // EMUX
    wire [31:0] EMUX_Instr;

    // FMUX
    wire [31:0] FMUX_EPC_F;


    // D级
    // ER_D
    wire        ER_D_BD;
    wire [31:0] ER_D_VPC;
    wire [ 4:0] ER_D_ExcCode;

    // FR_D
    wire [31:0] Instr_D;
    wire [31:0] InstrAddr_D;

    // SPL
    wire [ 5:0] SPL_O_opcode;
    wire [ 5:0] SPL_O_funct;
    wire [ 4:0] SPL_O_rs;
    wire [ 4:0] SPL_O_rt;
    wire [ 4:0] SPL_rs;
    wire [ 4:0] SPL_rt;
    wire [ 4:0] SPL_rd;
    wire [ 4:0] SPL_shamt;
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

    // ECMUX_D
    wire [4:0] ECMUX_D_ExcCode_D;

    // MUX
    wire [ 4:0] MUX_GRF_A3_D;

    // FMUX
    wire [31:0] FMUX_V1_D;
    wire [31:0] FMUX_V2_D;


    // E级
    // ER_E
    wire        ER_E_BD;
    wire [31:0] ER_E_VPC;
    wire [ 4:0] ER_E_ExcCode;

    // FR_E
    wire        ISLOADSTORE_E;
    wire        GRFWE_E;
    wire [ 3:0] BridgeSel_E;
    wire [ 1:0] FuncSel_E;
    wire [ 1:0] OPSel_E;
    wire [ 1:0] GRF_WD_W_Sel_E;
    wire        ALU_B_E_Sel_E;
    wire        E_RES_E_Sel_E;
    wire [ 2:0] MULTSel_E;
    wire        ISMULTDIV_E;
    wire        CP0WE_E;
    wire        ERET_E;
    wire [31:0] V1_E;
    wire [31:0] V2_E;
    wire [ 4:0] rd_E;
    wire [ 4:0] shamt_E;
    wire [ 4:0] GRF_A3_E;
    wire [31:0] ext32_E;
    wire [31:0] pc8_E;
    wire [ 1:0] FMUX_V1_E_Sel_E;
    wire [ 1:0] FMUX_V2_E_Sel_E;
    wire        FMUX_V2_M_Sel_E;

    // ALU
    wire [31:0] ALU_OP;
    wire        ALU_Overflow;

    // MULT
    wire        MULT_Start;
    wire        MULT_Busy;
    wire [31:0] MULT_HILO;

    // ECMUX_E
    wire [4:0] ECMUX_E_ExcCode_E;

    // MUX
    wire [31:0] MUX_ALU_B_E;
    wire [31:0] MUX_E_RES_E;

    // FMUX
    wire [31:0] FMUX_V1_E;
    wire [31:0] FMUX_V2_E;


    // M级
    // ER_M
    wire        ER_M_BD;
    wire [31:0] ER_M_VPC;
    wire [ 4:0] ER_M_ExcCode;

    // FR_M
    wire        ISLOADSTORE_M;
    wire        GRFWE_M;
    wire [ 3:0] BridgeSel_M;
    wire [ 1:0] GRF_WD_W_Sel_M;
    wire        CP0WE_M;
    wire        ERET_M;
    wire [31:0] V2_M;
    wire [ 4:0] rd_M;
    wire [31:0] E_RES_M;
    wire [ 4:0] GRF_A3_M;
    wire [31:0] ext32_M;
    wire [31:0] pc8_M;
    wire        FMUX_V2_M_Sel_M;

    // ECMUX_M
    wire [4:0] ECMUX_M_ExcCode_M;

    // CP0
    wire        CP0_Req;
    wire [31:0] CP0_Q;
    wire [31:0] CP0_Q_EPC;
    wire        CP0_Q_EXL;

    // MUX
    wire [31:0] MUX_M_RES_M;

    // FMUX
    wire [31:0] FMUX_V2_M;

    // W级
    // FR_W
    wire        GRFWE_W;
    wire [ 1:0] GRF_WD_W_Sel_W;
    wire [31:0] E_RES_W;
    wire [31:0] M_RES_W;
    wire [ 4:0] GRF_A3_W;
    wire [31:0] ext32_W;
    wire [31:0] pc8_W;

    // MUX
    wire [31:0] MUX_GRF_WD_W;


    // 评测需要输出
    wire [31:0] Exam_InstrAddr_W;


    // 各模块
    
    // 控制器
    CTRL_Decoder CTRL_Decoder_instance (
    .opcode(SPL_O_opcode),
    .funct(SPL_O_funct),
    .rs(SPL_O_rs),
    .rt(SPL_O_rt),
    .CP0_Q_EXL(CP0_Q_EXL),

    .SYSCALL(CTRL_D_SYSCALL),
    .UNKNOWN(CTRL_D_UNKNOWN),
    .ISNEXTBD(CTRL_D_ISNEXTBD),
    .ERET(CTRL_D_ERET),
    .CompSel(CTRL_D_CompSel),
    .EXTSel(CTRL_D_EXTSel),
    .NPCSel(CTRL_D_NPCSel),
    .OPSel(CTRL_D_OPSel),
    .FuncSel(CTRL_D_FuncSel),
    .MULTSel(CTRL_D_MULTSel),
    .ISMULTDIV(CTRL_D_ISMULTDIV),
    .ISLOADSTORE(CTRL_D_ISLOADSTORE),
    .BridgeSel(CTRL_D_BridgeSel),
    .CP0WE(CTRL_D_CP0WE),
    .GRFWE(CTRL_D_GRFWE),
    .GRF_A3_D_Sel(CTRL_D_GRF_A3_D_Sel),
    .ALU_B_E_Sel(CTRL_D_ALU_B_E_Sel),
    .E_RES_E_Sel(CTRL_D_E_RES_E_Sel),
    .GRF_WD_W_Sel(CTRL_D_GRF_WD_W_Sel),
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
    .ISMULTDIV(CTRL_D_ISMULTDIV),
    .MULT_Start(MULT_Start),
    .MULT_Busy(MULT_Busy),

    .IFU_EN_N(CTRL_S_IFU_EN_N),
    .D_EN_N(CTRL_S_D_EN_N),
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
    .FMUX_V2_M_Sel(CTRL_F_FMUX_V2_M_Sel)
    );


    // F级


    IFU IFU_instance (
    .RESET(CPU_RESET),
    .clk(CPU_clk),
    .STALL_EN_N(CTRL_S_IFU_EN_N),
    .Req(CP0_Req),
    .ERET(CTRL_D_ERET),

    .NPCSel(CTRL_D_NPCSel),
    .BranchComp(COMP_BranchComp),
    .offset(SPL_imm16),
    .instr_index(SPL_instr_index),
    .instr_register(FMUX_V1_D),
    .EPC(FMUX_EPC_F),

    .InstrAddr(IFU_InstrAddr)
    );

    ECMUX_F ECMUX_F_instance (
    .InstrAddr(IFU_InstrAddr),
    .ExcCode_F(ECMUX_F_ExcCode_F),
    .AdEL_F(ECMUX_F_AdEL_F)
    );


    assign EMUX_Instr = ECMUX_F_AdEL_F ? `nop : CPU_IFU_Instr;

    assign FMUX_EPC_F = (CP0WE_E && rd_E == `A_EPC) ? FMUX_V2_E : CP0_Q_EPC;


    // D级


    ER_D ER_D_instance (
    .RESET(CPU_RESET),
    .clk(CPU_clk),
    .Req(CP0_Req),
    .STALL_EN_N(CTRL_S_D_EN_N),
    .ERET(CTRL_D_ERET),

    .EPC(FMUX_EPC_F),
    .D_BD(CTRL_D_ISNEXTBD),
    .D_VPC(IFU_InstrAddr),
    .D_ExcCode(ECMUX_F_ExcCode_F),

    .Q_BD(ER_D_BD),
    .Q_VPC(ER_D_VPC),
    .Q_ExcCode(ER_D_ExcCode)
    );

    FR_D FR_D_instance (
    .RESET(CPU_RESET),
    .clk(CPU_clk),
    .Req(CP0_Req),
    .STALL_EN_N(CTRL_S_D_EN_N),
    .ERET(CTRL_D_ERET),

    .D_Instr(EMUX_Instr),
    .D_InstrAddr(IFU_InstrAddr),

    .Q_Instr(Instr_D),
    .Q_InstrAddr(InstrAddr_D)
    );

    SPL SPL_instance (
    .Instr(Instr_D),
    .force_nop(CTRL_D_UNKNOWN),
    .O_opcode(SPL_O_opcode),
    .O_funct(SPL_O_funct),
    .O_rs(SPL_O_rs),
    .O_rt(SPL_O_rt),
    .rs(SPL_rs),
    .rt(SPL_rt),
    .rd(SPL_rd),
    .shamt(SPL_shamt),
    .imm16(SPL_imm16),
    .instr_index(SPL_instr_index)
    );

    GRF GRF_instance (
    .RESET(CPU_RESET),
    .clk(CPU_clk),

    // _W
    .WE(GRFWE_W),

    // _R
    .A1(SPL_rs),
    .A2(SPL_rt),

    // _W
    .A3(GRF_A3_W),
    .WD(MUX_GRF_WD_W),

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

    ECMUX_D ECMUX_D_instance (
    .ExcCode_F(ER_D_ExcCode),
    .SYSCALL(CTRL_D_SYSCALL),
    .UNKNOWN(CTRL_D_UNKNOWN),
    .ExcCode_D(ECMUX_D_ExcCode_D)
    );


    assign MUX_GRF_A3_D = (CTRL_D_GRF_A3_D_Sel == 2'b10) ? SPL_rt :
                          (CTRL_D_GRF_A3_D_Sel == 2'b11) ? 5'd31 :
                          SPL_rd ; // CTRL_D_GRF_A3_D_Sel == 2'b00/2'b01

    assign FMUX_V1_D = (CTRL_F_FMUX_V1_D_Sel == 3'b011) ? E_RES_M :
                       (CTRL_F_FMUX_V1_D_Sel == 3'b100) ? ext32_M :
                       (CTRL_F_FMUX_V1_D_Sel == 3'b101) ? pc8_M :
                       (CTRL_F_FMUX_V1_D_Sel == 3'b110) ? ext32_E :
                       (CTRL_F_FMUX_V1_D_Sel == 3'b111) ? pc8_E :
                       GRF_V1;

    assign FMUX_V2_D = (CTRL_F_FMUX_V2_D_Sel == 3'b011) ? E_RES_M :
                       (CTRL_F_FMUX_V2_D_Sel == 3'b100) ? ext32_M :
                       (CTRL_F_FMUX_V2_D_Sel == 3'b101) ? pc8_M :
                       (CTRL_F_FMUX_V2_D_Sel == 3'b110) ? ext32_E :
                       (CTRL_F_FMUX_V2_D_Sel == 3'b111) ? pc8_E :
                       GRF_V2;


    // E级


    ER_E_M ER_E_instance (
    .RESET(CPU_RESET),
    .clk(CPU_clk),
    .Req(CP0_Req),
    .D_BD(ER_D_BD),
    .D_VPC(ER_D_VPC),
    .D_ExcCode(ECMUX_D_ExcCode_D),
    .Q_BD(ER_E_BD),
    .Q_VPC(ER_E_VPC),
    .Q_ExcCode(ER_E_ExcCode)
    );

    FR_E FR_E_instance (
    .RESET(CPU_RESET),
    .clk(CPU_clk),
    .Req(CP0_Req),
    .STALL_RESET(CTRL_S_FR_E_RESET),

    .D_ISLOADSTORE(CTRL_D_ISLOADSTORE),
    .D_GRFWE(CTRL_D_GRFWE),
    .D_BridgeSel(CTRL_D_BridgeSel),
    .D_FuncSel(CTRL_D_FuncSel),
    .D_OPSel(CTRL_D_OPSel),
    .D_GRF_WD_W_Sel(CTRL_D_GRF_WD_W_Sel),
    .D_ALU_B_E_Sel(CTRL_D_ALU_B_E_Sel),
    .D_E_RES_E_Sel(CTRL_D_E_RES_E_Sel),
    .D_MULTSel(CTRL_D_MULTSel),
    .D_ISMULTDIV(CTRL_D_ISMULTDIV),
    .D_CP0WE(CTRL_D_CP0WE),
    .D_ERET(CTRL_D_ERET),
    .D_V1(FMUX_V1_D),
    .D_V2(FMUX_V2_D),
    .D_rd(SPL_rd),
    .D_shamt(SPL_shamt),
    .D_GRF_A3(MUX_GRF_A3_D),
    .D_ext32(EXT_ext32),
    .D_pc8(pc8_D),
    .D_FMUX_V1_E_Sel(CTRL_F_FMUX_V1_E_Sel),
    .D_FMUX_V2_E_Sel(CTRL_F_FMUX_V2_E_Sel),
    .D_FMUX_V2_M_Sel(CTRL_F_FMUX_V2_M_Sel),

    .Q_ISLOADSTORE(ISLOADSTORE_E),
    .Q_GRFWE(GRFWE_E),
    .Q_BridgeSel(BridgeSel_E),
    .Q_FuncSel(FuncSel_E),
    .Q_OPSel(OPSel_E),
    .Q_GRF_WD_W_Sel(GRF_WD_W_Sel_E),
    .Q_ALU_B_E_Sel(ALU_B_E_Sel_E),
    .Q_E_RES_E_Sel(E_RES_E_Sel_E),
    .Q_MULTSel(MULTSel_E),
    .Q_ISMULTDIV(ISMULTDIV_E),
    .Q_CP0WE(CP0WE_E),
    .Q_ERET(ERET_E),
    .Q_V1(V1_E),
    .Q_V2(V2_E),
    .Q_rd(rd_E),
    .Q_shamt(shamt_E),
    .Q_GRF_A3(GRF_A3_E),
    .Q_ext32(ext32_E),
    .Q_pc8(pc8_E),
    .Q_FMUX_V1_E_Sel(FMUX_V1_E_Sel_E),
    .Q_FMUX_V2_E_Sel(FMUX_V2_E_Sel_E),
    .Q_FMUX_V2_M_Sel(FMUX_V2_M_Sel_E)
    );

    ALU ALU_instance (
    .OPSel(OPSel_E),
    .FuncSel(FuncSel_E),
    .A(FMUX_V1_E),
    .B(MUX_ALU_B_E),
    .shamt(shamt_E),
    .OP(ALU_OP),
    .Overflow(ALU_Overflow)
    );

    MULT MULT_instance (
    .RESET(CPU_RESET),
    .clk(CPU_clk),
    .Req(CP0_Req),
    .ISMULTDIV(ISMULTDIV_E),
    .MULTSel(MULTSel_E),
    .A(FMUX_V1_E),
    .B(MUX_ALU_B_E),
    .Start(MULT_Start),
    .Busy(MULT_Busy),
    .HILO(MULT_HILO)
    );

    ECMUX_E instance_name (
    .ExcCode_D(ER_E_ExcCode),
    .BridgeSel(BridgeSel_E),
    .ISLOADSTORE(ISLOADSTORE_E),
    .Overflow(ALU_Overflow),
    .ExcCode_E(ECMUX_E_ExcCode_E)
    );


    assign MUX_ALU_B_E = ALU_B_E_Sel_E ? ext32_E : FMUX_V2_E;

    assign MUX_E_RES_E = E_RES_E_Sel_E ? MULT_HILO : ALU_OP;

    assign FMUX_V1_E = (FMUX_V1_E_Sel_E == 2'b10) ? M_RES_W :
                       (FMUX_V1_E_Sel_E == 2'b11) ? E_RES_M : 
                       V1_E;

    assign FMUX_V2_E = (FMUX_V2_E_Sel_E == 2'b10) ? M_RES_W :
                       (FMUX_V2_E_Sel_E == 2'b11) ? E_RES_M : 
                       V2_E;


    // M级


    ER_E_M ER_M_instance (
    .RESET(CPU_RESET),
    .clk(CPU_clk),
    .Req(CP0_Req),
    .D_BD(ER_E_BD),
    .D_VPC(ER_E_VPC),
    .D_ExcCode(ECMUX_E_ExcCode_E),
    .Q_BD(ER_M_BD),
    .Q_VPC(ER_M_VPC),
    .Q_ExcCode(ER_M_ExcCode)
    );

    FR_M FR_M_instance (
    .RESET(CPU_RESET),
    .clk(CPU_clk),
    .Req(CP0_Req),

    .D_ISLOADSTORE(ISLOADSTORE_E),
    .D_GRFWE(GRFWE_E),
    .D_BridgeSel(BridgeSel_E),
    .D_GRF_WD_W_Sel(GRF_WD_W_Sel_E),
    .D_CP0WE(CP0WE_E),
    .D_ERET(ERET_E),
    .D_V2(FMUX_V2_E),
    .D_rd(rd_E),
    .D_E_RES(MUX_E_RES_E),
    .D_GRF_A3(GRF_A3_E),
    .D_ext32(ext32_E),
    .D_pc8(pc8_E),
    .D_FMUX_V2_M_Sel(FMUX_V2_M_Sel_E),

    .Q_ISLOADSTORE(ISLOADSTORE_M),
    .Q_GRFWE(GRFWE_M),
    .Q_BridgeSel(BridgeSel_M),
    .Q_GRF_WD_W_Sel(GRF_WD_W_Sel_M),
    .Q_CP0WE(CP0WE_M),
    .Q_ERET(ERET_M),
    .Q_V2(V2_M),
    .Q_rd(rd_M),
    .Q_E_RES(E_RES_M),
    .Q_GRF_A3(GRF_A3_M),
    .Q_ext32(ext32_M),
    .Q_pc8(pc8_M),
    .Q_FMUX_V2_M_Sel(FMUX_V2_M_Sel_M)
    );

    ECMUX_M ECMUX_M_instance (
    .ExcCode_E(ER_M_ExcCode),
    .AdE(CPU_BRIDGE_AdE),
    .ExcCode_M(ECMUX_M_ExcCode_M)
    );

    CP0 CP0_instance (
    .RESET(CPU_RESET),
    .clk(CPU_clk),
    .WE(CP0WE_M),
    .A(rd_M),
    .D(FMUX_V2_M),
    .D_BD(ER_M_BD),
    .D_VPC(ER_M_VPC),
    .D_ExcCode(ECMUX_M_ExcCode_M),
    .D_HWInt(CPU_BRIDGE_HWInt),
    .EXL_CLR(ERET_M),
    .Req(CP0_Req),
    .Q(CP0_Q),
    .Q_EPC(CP0_Q_EPC),
    .Q_EXL(CP0_Q_EXL)
    );

    
    assign MUX_M_RES_M = ISLOADSTORE_M ? CPU_BRIDGE_Q : CP0_Q;

    assign FMUX_V2_M = (FMUX_V2_M_Sel_M == 1'b1) ? M_RES_W :
                         V2_M;


    // W级


    FR_W FR_W_instance (
    // 评测需要输出
    .D_Exam_InstrAddr(ER_M_VPC),
    .Q_Exam_InstrAddr(Exam_InstrAddr_W),

    .RESET(CPU_RESET),
    .clk(CPU_clk),
    .Req(CP0_Req),

    .D_GRFWE(GRFWE_M),
    .D_GRF_WD_W_Sel(GRF_WD_W_Sel_M),
    .D_E_RES(E_RES_M),
    .D_M_RES(MUX_M_RES_M),
    .D_GRF_A3(GRF_A3_M),
    .D_ext32(ext32_M),
    .D_pc8(pc8_M),

    .Q_GRFWE(GRFWE_W),
    .Q_GRF_WD_W_Sel(GRF_WD_W_Sel_W),
    .Q_E_RES(E_RES_W),
    .Q_M_RES(M_RES_W),
    .Q_GRF_A3(GRF_A3_W),
    .Q_ext32(ext32_W),
    .Q_pc8(pc8_W)
    );


    assign MUX_GRF_WD_W = (GRF_WD_W_Sel_W == 2'b01) ? M_RES_W :
                          (GRF_WD_W_Sel_W == 2'b10) ? ext32_W :
                          (GRF_WD_W_Sel_W == 2'b11) ? pc8_W :
                          E_RES_W;


    // CPU级接线


    assign CPU_macroscopic_pc = ER_M_VPC;

    assign CPU_IFU_InstrAddr = IFU_InstrAddr;

    assign CPU_GRFWE_W = GRFWE_W;

    assign CPU_GRF_A3_W = GRF_A3_W;

    assign CPU_GRF_WD_W = MUX_GRF_WD_W;

    assign CPU_Exam_InstrAddr_W = Exam_InstrAddr_W;

    assign CPU_Req = CP0_Req;

    assign CPU_BridgeSel_M = BridgeSel_M;

    assign CPU_ISLOADSTORE_M = ISLOADSTORE_M;

    assign CPU_BRIDGE_A = E_RES_M;

    assign CPU_BRIDGE_D = FMUX_V2_M;

endmodule
