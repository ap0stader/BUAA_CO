// Verified: 2024-08-29
`timescale 1ns / 1ps

`default_nettype none
module mips(
    input  wire        clk,
    input  wire        reset,
    input  wire        interrupt,
    output wire [31:0] macroscopic_pc,

    output wire [31:0] i_inst_addr,
    input  wire [31:0] i_inst_rdata,

    output wire [31:0] m_data_addr,
    input  wire [31:0] m_data_rdata,
    output wire [31:0] m_data_wdata,
    output wire [ 3:0] m_data_byteen,

    output wire [31:0] m_int_addr,
    output wire [ 3:0] m_int_byteen,

    output wire [31:0] m_inst_addr,

    output wire        w_grf_we,
    output wire [ 4:0] w_grf_addr,
    output wire [31:0] w_grf_wdata,

    output wire [31:0] w_inst_addr
);

    // 接线

    // CPU
    wire [31:0] CPU_macroscopic_pc;
    wire [31:0] CPU_IFU_InstrAddr;
    wire        CPU_GRFWE_W;
    wire [ 4:0] CPU_GRF_A3_W;
    wire [31:0] CPU_GRF_WD_W;
    wire [31:0] CPU_Exam_InstrAddr_W;
    wire        CPU_Req;
    wire [ 3:0] CPU_BridgeSel_M;
    wire        CPU_ISLOADSTORE_M;
    wire [31:0] CPU_BRIDGE_A;
    wire [31:0] CPU_BRIDGE_D;


    // BRIDGE
    wire [31:0] BRIDGE_wdata;
    wire [ 3:0] BRIDGE_byteen_DM;
    wire [ 3:0] BRIDGE_byteen_0;
    wire [ 3:0] BRIDGE_byteen_1;
    wire [ 3:0] BRIDGE_byteen_2;
    wire [ 3:0] BRIDGE_byteen_3;
    wire [ 3:0] BRIDGE_byteen_4;
    wire [ 3:0] BRIDGE_byteen_5;
    wire [ 1:0] BRIDGE_AdE;
    wire [ 5:0] BRIDGE_HWInt_Hub;
    wire [31:0] BRIDGE_Q;


    // Timer0
    wire [31:0] TC0_rdata;
    wire        TC0_IRQ;


    // Timer1
    wire [31:0] TC1_rdata;
    wire        TC1_IRQ;


    // GROUND
    wire        GROUND_1bit  =  1'b0;
    wire [31:0] GROUND_32bit = 32'b0;


    // 各模块

    // CPU
    CPU CPU_instance (
    .CPU_RESET(reset),
    .CPU_clk(clk),
    .CPU_macroscopic_pc(CPU_macroscopic_pc),
    .CPU_IFU_InstrAddr(CPU_IFU_InstrAddr),
    .CPU_IFU_Instr(i_inst_rdata),
    .CPU_GRFWE_W(CPU_GRFWE_W),
    .CPU_GRF_A3_W(CPU_GRF_A3_W),
    .CPU_GRF_WD_W(CPU_GRF_WD_W),
    .CPU_Exam_InstrAddr_W(CPU_Exam_InstrAddr_W),
    .CPU_Req(CPU_Req),
    .CPU_BridgeSel_M(CPU_BridgeSel_M),
    .CPU_ISLOADSTORE_M(CPU_ISLOADSTORE_M),
    .CPU_BRIDGE_A(CPU_BRIDGE_A),
    .CPU_BRIDGE_D(CPU_BRIDGE_D),
    .CPU_BRIDGE_AdE(BRIDGE_AdE),
    .CPU_BRIDGE_HWInt(BRIDGE_HWInt_Hub),
    .CPU_BRIDGE_Q(BRIDGE_Q)
    );


    // BRIDGE
    BRIDGE BRIDGE_instance (
    .ISLOADSTORE(CPU_ISLOADSTORE_M),
    .BridgeSel(CPU_BridgeSel_M),
    .Req(CPU_Req),
    .A(CPU_BRIDGE_A),
    .D(CPU_BRIDGE_D),
    .rdata_DM(m_data_rdata),
    .rdata_0(TC0_rdata),
    .rdata_1(TC1_rdata),
    .rdata_2(GROUND_32bit),
    .rdata_3(GROUND_32bit),
    .rdata_4(GROUND_32bit),
    .rdata_5(GROUND_32bit),
    .HWInt_0(TC0_IRQ),
    .HWInt_1(TC1_IRQ),
    .HWInt_2(interrupt),
    .HWInt_3(GROUND_1bit),
    .HWInt_4(GROUND_1bit),
    .HWInt_5(GROUND_1bit),
    .wdata(BRIDGE_wdata),
    .byteen_DM(BRIDGE_byteen_DM),
    .byteen_0(BRIDGE_byteen_0),
    .byteen_1(BRIDGE_byteen_1),
    .byteen_2(BRIDGE_byteen_2),
    .byteen_3(BRIDGE_byteen_3),// Never used
    .byteen_4(BRIDGE_byteen_4),// Never used
    .byteen_5(BRIDGE_byteen_5),// Never used
    .AdE(BRIDGE_AdE),
    .HWInt_Hub(BRIDGE_HWInt_Hub),
    .Q(BRIDGE_Q)
    );


    // Timer0
    TC Timer0 (
    .RESET(reset),
    .clk(clk),
    .byteen(BRIDGE_byteen_0),
    .addr(CPU_BRIDGE_A),
    .wdata(BRIDGE_wdata),
    .rdata(TC0_rdata),
    .IRQ(TC0_IRQ)
    );


    // Timer1
    TC Timer1 (
    .RESET(reset),
    .clk(clk),
    .byteen(BRIDGE_byteen_1),
    .addr(CPU_BRIDGE_A),
    .wdata(BRIDGE_wdata),
    .rdata(TC1_rdata),
    .IRQ(TC1_IRQ)
    );


    // MIPS体系结构级接线


    assign macroscopic_pc = CPU_macroscopic_pc;

    assign i_inst_addr = CPU_IFU_InstrAddr;

    assign m_data_addr = CPU_BRIDGE_A;

    assign m_data_wdata = BRIDGE_wdata;

    assign m_data_byteen = BRIDGE_byteen_DM;

    assign m_int_addr = CPU_BRIDGE_A;

    assign m_int_byteen = BRIDGE_byteen_2;

    assign m_inst_addr = CPU_macroscopic_pc;

    assign w_grf_we = CPU_GRFWE_W;

    assign w_grf_addr = CPU_GRF_A3_W;

    assign w_grf_wdata = CPU_GRF_WD_W;

    assign w_inst_addr = CPU_Exam_InstrAddr_W;

endmodule
