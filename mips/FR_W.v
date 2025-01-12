// Verified: 2024-08-29
`timescale 1ns / 1ps

`default_nettype none
module FR_W (
    // 评测需要使用
    input wire [31:0] D_Exam_InstrAddr,
    output reg [31:0] Q_Exam_InstrAddr,

    input wire RESET,
    input wire clk,
    input wire Req,

    input wire D_GRFWE,
    input wire [1:0] D_GRF_WD_W_Sel,
    
    input wire [31:0] D_E_RES,
    input wire [31:0] D_M_RES,
    input wire [4:0] D_GRF_A3,
    input wire [31:0] D_ext32,
    input wire [31:0] D_pc8,
    
    output reg Q_GRFWE,
    output reg [1:0] Q_GRF_WD_W_Sel,

    output reg [31:0] Q_E_RES,
    output reg [31:0] Q_M_RES,
    output reg [4:0] Q_GRF_A3,
    output reg [31:0] Q_ext32,
    output reg [31:0] Q_pc8
    );

    always @(posedge clk) begin
        if(RESET || Req) begin
            // 评测需要使用
            Q_Exam_InstrAddr <= 32'd0;

            Q_GRFWE <= 1'b0;
            Q_GRF_WD_W_Sel <= 2'b0;

            Q_E_RES <= 32'b0;
            Q_M_RES <= 32'b0;
            Q_GRF_A3 <= 6'b0;
            Q_ext32 <= 32'b0;
            Q_pc8 <= 32'b0;
        end
        else begin
            // 评测需要使用
            Q_Exam_InstrAddr <= D_Exam_InstrAddr;

            Q_GRFWE <= D_GRFWE;
            Q_GRF_WD_W_Sel <= D_GRF_WD_W_Sel;

            Q_E_RES <= D_E_RES;
            Q_M_RES <= D_M_RES;
            Q_GRF_A3 <= D_GRF_A3;
            Q_ext32 <= D_ext32;
            Q_pc8 <= D_pc8;            
        end
    end

endmodule
