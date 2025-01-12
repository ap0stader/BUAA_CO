// Verified: 2024-08-29
`timescale 1ns / 1ps

`default_nettype none

`include "Address_Map.v"
module ER_E_M(
    input wire RESET,
    input wire clk,
    input wire Req,

    input wire D_BD,
    input wire [31:0] D_VPC,
    input wire [4:0] D_ExcCode,

    output reg Q_BD,
    output reg [31:0] Q_VPC,
    output reg [4:0] Q_ExcCode
    );

    always @(posedge clk) begin
        if(RESET) begin
            Q_BD <= 1'b0;
            Q_VPC <= `PC_INIT;
            Q_ExcCode <= 5'd0;
        end
        else if(Req) begin
            Q_BD <= 1'b0;
            Q_VPC <= `HANDLE_START;
            Q_ExcCode <= 5'd0;
        end
        else begin
            Q_BD <= D_BD;
            Q_VPC <= D_VPC;
            Q_ExcCode <= D_ExcCode;
        end
    end

endmodule
