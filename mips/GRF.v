// Verified: 2024-08-28
`timescale 1ns / 1ps

`default_nettype none
module GRF(
    input wire RESET,
    input wire clk,
    input wire WE,
    input wire [4:0] A1,
    input wire [4:0] A2,
    input wire [4:0] A3,
    input wire [31:0] D,
    output wire [31:0] V1,
    output wire [31:0] V2
    );
    
    reg [31:0] RF [31:1];
    
    wire [31:0] RD1;
    wire [31:0] RD2;

    assign RD1 = (A1 == 5'd0) ? 32'h00000000 : RF[A1];
    
    assign RD2 = (A2 == 5'd0) ? 32'h00000000 : RF[A2];

    // 内部转发
    assign V1 = (A1 != 5'd0 && WE && A3 == A1) ? D : RD1;

    assign V2 = (A2 != 5'd0 && WE && A3 == A2) ? D : RD2;

    integer i;
    
    always @(posedge clk) begin
        if (RESET) begin
            for(i = 1; i < 32; i = i + 1) begin
                RF[i] <= 32'h00000000;
            end
        end
        else if (WE) begin
            if (A3 != 5'd0) begin
                RF[A3] <= D;
            end
        end
    end

endmodule
