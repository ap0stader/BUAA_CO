// Verified: 2024-08-29
`timescale 1ns / 1ps

`default_nettype none

`include "Exception_Code.v"

`define A_SR    5'd12
`define A_Cause 5'd13
`define A_EPC   5'd14

module CP0 (
    input wire RESET,
    input wire clk,
    input wire WE,
    input wire [4:0] A,
    input wire [31:0] D,
    input wire D_BD,
    input wire [31:0] D_VPC,
    input wire [4:0] D_ExcCode,
    input wire [5:0] D_HWInt,
    input wire EXL_CLR,

    output wire Req,
    output wire [31:0] Q,
    output wire [31:0] Q_EPC,
    output wire Q_EXL
);
    // SR
    reg [5:0] SR_IM;
    reg SR_EXL;
    reg SR_IE;

    // Cause
    reg Cause_BD;
    reg [5:0] Cause_IP;
    reg [4:0] Cause_ExcCode;

    // EPC
    reg [31:0] EPC;

    wire [31:0] SR    = {16'b0, SR_IM, 8'b0, SR_EXL, SR_IE};
    wire [31:0] Cause = {Cause_BD, 15'b0, Cause_IP, 3'b0, Cause_ExcCode, 2'b0};

    // 是否有设备请求中断
    wire Req_Int = | (D_HWInt & SR_IM);

    // 是否进入中断处理程序
    assign Req = ((~SR_EXL) & SR_IE & Req_Int) || (D_ExcCode != `No_ExcCode);

    assign Q = (A == `A_SR)    ? SR :
               (A == `A_Cause) ? Cause:
               (A == `A_EPC)   ? EPC :
               32'h0;
    
    // 内部转发
    assign Q_EPC = (WE && A == `A_EPC) ? D : EPC;

    assign Q_EXL = SR_EXL;

    always @(posedge clk) begin
        if(RESET) begin
            SR_IM <= 6'b0;
            SR_EXL <= 1'b0;
            SR_IE <= 1'b0;

            Cause_BD <= 1'b0;
            Cause_IP <= 6'b0;
            Cause_ExcCode <= 5'b0;

            EPC <= 32'b0;
        end
        else begin
            Cause_IP <= D_HWInt;
            if(Req) begin
                // 进入中断处理程序
                SR_EXL <= 1'b1;
                Cause_BD <= D_BD;
                Cause_ExcCode <= Req_Int ? `ExcCode_Int : D_ExcCode;
                // 根据指令情况正确设置EPC
                EPC <= D_BD ? (D_VPC - 32'd4) : D_VPC;        
            end
            else begin
                // 一个只能由eret引发，一个只能由mtc0引发，二者不会产生冲突
                if(EXL_CLR) begin
                    SR_EXL <= 1'b0;
                end
                else if(WE) begin
                    if(A == `A_SR) begin
                        SR_IM <= D[15:10];
                        SR_EXL <= D[1];
                        SR_IE <= D[0];
                    end
                    else if(A == `A_EPC) begin
                        EPC <= D;
                    end
                end
            end
        end
    end
    
endmodule
