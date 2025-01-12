// Verified: 2024-08-28
`timescale 1ns / 1ps

`default_nettype none
module FR_M (
    // 评测需要输出
    input wire [31:0] D_Exam_InstrAddr,
    output reg [31:0] Q_Exam_InstrAddr,

    input wire RESET,
    input wire clk,

    input wire D_DMWE,
    input wire D_GRFWE,
    input wire [2:0] D_DMSel,
    input wire [1:0] D_GRF_WD_W_Sel,
    input wire [31:0] D_V2,
    input wire [31:0] D_OP,
    input wire [4:0] D_GRF_A3,
    input wire [31:0] D_ext32,
    input wire [31:0] D_pc8,
    input wire D_FMUX_DM_D_M_Sel,

    output reg Q_DMWE,
    output reg Q_GRFWE,
    output reg [2:0] Q_DMSel,
    output reg [1:0] Q_GRF_WD_W_Sel,
    output reg [31:0] Q_V2,
    output reg [31:0] Q_OP,
    output reg [4:0] Q_GRF_A3,
    output reg [31:0] Q_ext32,
    output reg [31:0] Q_pc8,
    output reg Q_FMUX_DM_D_M_Sel
    );
    
    always @(posedge clk) begin
        if (RESET) begin
            // 评测需要输出
            Q_Exam_InstrAddr <= 32'd0;

            Q_DMWE <= 1'b0;
            Q_GRFWE <= 1'b0;
            Q_DMSel <= 3'b0;
            Q_GRF_WD_W_Sel <= 2'b0;
            Q_V2 <= 32'b0;
            Q_OP <= 32'b0;
            Q_GRF_A3 <= 6'b0;
            Q_ext32 <= 32'b0;
            Q_pc8 <= 32'b0;
            Q_FMUX_DM_D_M_Sel <= 1'b0;
        end
        else begin
            // 评测需要输出
            Q_Exam_InstrAddr <= D_Exam_InstrAddr;

            Q_DMWE <= D_DMWE;
            Q_GRFWE <= D_GRFWE;
            Q_DMSel <= D_DMSel;
            Q_GRF_WD_W_Sel <= D_GRF_WD_W_Sel;
            Q_V2 <= D_V2;
            Q_OP <= D_OP;
            Q_GRF_A3 <= D_GRF_A3;
            Q_ext32 <= D_ext32;
            Q_pc8 <= D_pc8;
            Q_FMUX_DM_D_M_Sel <= D_FMUX_DM_D_M_Sel;
        end
    end
    
endmodule
