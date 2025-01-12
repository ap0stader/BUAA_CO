// Verified: 2024-08-29
`timescale 1ns / 1ps

`default_nettype none
module FR_M (
    input wire RESET,
    input wire clk,
    input wire Req,

    input wire D_ISLOADSTORE,
    input wire D_GRFWE,
    input wire [3:0] D_BridgeSel,
    input wire [1:0] D_GRF_WD_W_Sel,
    input wire D_CP0WE,
    input wire D_ERET,

    input wire [31:0] D_V2,
    input wire [4:0] D_rd,
    input wire [31:0] D_E_RES,
    input wire [4:0] D_GRF_A3,
    input wire [31:0] D_ext32,
    input wire [31:0] D_pc8,
    input wire D_FMUX_V2_M_Sel,

    output reg Q_ISLOADSTORE,
    output reg Q_GRFWE,
    output reg [3:0] Q_BridgeSel,
    output reg [1:0] Q_GRF_WD_W_Sel,
    output reg Q_CP0WE,
    output reg Q_ERET,

    output reg [31:0] Q_V2,
    output reg [4:0] Q_rd,
    output reg [31:0] Q_E_RES,
    output reg [4:0] Q_GRF_A3,
    output reg [31:0] Q_ext32,
    output reg [31:0] Q_pc8,
    output reg Q_FMUX_V2_M_Sel
    );
    
    always @(posedge clk) begin
        if (RESET || Req) begin
            Q_ISLOADSTORE <= 1'b0;
            Q_GRFWE <= 1'b0;
            Q_BridgeSel <= 4'b0;
            Q_GRF_WD_W_Sel <= 2'b0;
            Q_CP0WE <= 1'b0;
            Q_ERET <= 1'b0;

            Q_V2 <= 32'b0;
            Q_rd <= 5'b0;
            Q_E_RES <= 32'b0;
            Q_GRF_A3 <= 6'b0;
            Q_ext32 <= 32'b0;
            Q_pc8 <= 32'b0;
            Q_FMUX_V2_M_Sel <= 1'b0;
        end
        else begin
            Q_ISLOADSTORE <= D_ISLOADSTORE;
            Q_GRFWE <= D_GRFWE;
            Q_BridgeSel <= D_BridgeSel;
            Q_GRF_WD_W_Sel <= D_GRF_WD_W_Sel;
            Q_CP0WE <= D_CP0WE;
            Q_ERET <= D_ERET;

            Q_V2 <= D_V2;
            Q_rd <= D_rd;
            Q_E_RES <= D_E_RES;
            Q_GRF_A3 <= D_GRF_A3;
            Q_ext32 <= D_ext32;
            Q_pc8 <= D_pc8;
            Q_FMUX_V2_M_Sel <= D_FMUX_V2_M_Sel;
        end
    end
    
endmodule
