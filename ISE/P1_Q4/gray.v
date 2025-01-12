`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:59:25 10/11/2023 
// Design Name: 
// Module Name:    gray 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`default_nettype none
module gray(
    input wire Clk,
    input wire Reset,
    input wire En,
    output reg [2:0] Output,
    output reg Overflow
    );
    
    reg [2:0] Counter;
    
    always @(posedge Clk) begin
        if (Reset) begin
            Counter <= 3'b000;
            Overflow <= 0;
        end
        else begin
            // 第一次提交的问题：忘记了使能信号了
            if (En) begin 
                if (Counter == 3'b111) begin
                    Counter <= 3'b000;
                    Overflow <= 1;
                end
                else begin
                    Counter <= Counter + 3'b001;
                end
            end
        end
    end
    
    always @(*) begin
        case (Counter)
            3'b000:
                Output = 3'b000;
            3'b001:
                Output = 3'b001;
            3'b010:
                Output = 3'b011;
            3'b011:
                Output = 3'b010;
            3'b100:
                Output = 3'b110;
            3'b101:
                Output = 3'b111;
            3'b110:
                Output = 3'b101;
            3'b111:
                Output = 3'b100;
        endcase
    end

endmodule
