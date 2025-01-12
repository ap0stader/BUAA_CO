// Verified: 2024-08-28
`timescale 1ns / 1ps

`default_nettype none
module IFU_PC(
    input wire RESET,
    input wire clk,
    input wire STALL_EN_N,
    input wire [31:0] D,
    output wire [31:0] Q
    );
    
    reg [31:0] PC;
    
    always @(posedge clk) begin
        if(RESET) begin
            PC <= 32'h00003000;
        end
        else if(~ STALL_EN_N) begin
            PC <= D;
        end
    end
    
    assign Q = PC;
    
endmodule
