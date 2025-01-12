// Verified: 2024-08-28
`timescale 1ns / 1ps

`default_nettype none
module FR_D (
    input wire RESET,
    input wire clk,
    input wire STALL_EN_N,

    input wire [31:0] D_Instr,
    input wire [31:0] D_InstrAddr,

    output reg [31:0] Q_Instr,
    output reg [31:0] Q_InstrAddr
    );
    
    always @(posedge clk) begin
        if(RESET) begin
            Q_Instr <= 32'h0;
            Q_InstrAddr <= 32'h0;
        end
        else if(~ STALL_EN_N) begin
            Q_Instr <= D_Instr;
            Q_InstrAddr <= D_InstrAddr;
        end
    end

endmodule