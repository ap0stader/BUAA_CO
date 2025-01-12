// Verified: 2024-08-27
`timescale 1ns / 1ps

`default_nettype none
module IFU_PC(
    input wire RESET,
    input wire clk,
    input wire [31:0] D,
    output wire [31:0] Q
    );
    
    reg [31:0] PC;
    
    always @(posedge clk) begin
        // 复位值为代码起始地址0x00003000
        if(RESET) begin
            PC <= 32'h00003000;
        end
        else begin
            PC <= D;
        end
    end
    
    assign Q = PC;
    
endmodule
