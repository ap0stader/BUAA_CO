`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:33:29 10/11/2023 
// Design Name: 
// Module Name:    alu 
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
module alu(
    input wire [31:0] A,
    input wire [31:0] B,
    input wire [2:0] ALUOp,
    output reg [31:0] C
    );
   
    always @(*) begin
        case (ALUOp)
            // 第一次提交的问题：没有指定数字的类型，应该是默认按照十进制来处理了
            3'b000:
                C = A + B;
            3'b001:
                C = A - B;
            3'b010:
                C = A & B;
            3'b011:
                C = A | B;
            3'b100:
                C = A >> B;
            3'b101:
                C = $signed(A) >>> B;
            // 没有写default语句，错误的计算会保持上一次的结果。
            default:
               C = 32'b0;
        endcase
   end

endmodule
