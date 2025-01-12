// Verified: 2024-08-29
`timescale 1ns / 1ps

`default_nettype none

`include "Address_Map.v"
module IFU_PC(
    input wire RESET,
    input wire clk,
    input wire Req,
    input wire STALL_EN_N,
    input wire [31:0] D,
    output wire [31:0] Q
    );
    
    reg [31:0] PC;
    
    always @(posedge clk) begin
        if(RESET) begin
            PC <= `PC_INIT;
        end
        // 在暂停期间要进入中断处理程序也要更新PC
        else if(~ STALL_EN_N || Req) begin
            PC <= D;
        end
    end
    
    assign Q = PC;
    
endmodule
