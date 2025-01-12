// Verified: 2024-08-27
`timescale 1ns / 1ps

`default_nettype none
module GRF(
    input wire RESET,
    input wire clk,
    input wire WE,
    input wire [4:0] A1,
    input wire [4:0] A2,
    input wire [4:0] A3,
    input wire [31:0] WD,
    output wire [31:0] RD1,
    output wire [31:0] RD2,
    // 输入PC是因为评测需要输出
    input wire [31:0] PC
    );
    
    reg [31:0] RF [31:1];
    
    // 保持0号寄存器为0
    assign RD1 = (A1 == 5'd0) ? 32'h00000000 : RF[A1];
    
    assign RD2 = (A2 == 5'd0) ? 32'h00000000 : RF[A2];
    
    integer i;
    
    always @(posedge clk) begin
        if (RESET) begin
            for(i = 1; i < 32; i = i + 1) begin
                RF[i] <= 32'h00000000;
            end
        end
        else if (WE) begin
            // 对0号寄存器的写入操作不进行输出
            if (A3 != 5'd0) begin
                $display("@%h: $%d <= %h", PC, A3, WD);
                RF[A3] <= WD;
            end
        end
    end

endmodule
