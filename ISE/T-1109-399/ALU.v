`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:10:04 08/26/2023 
// Design Name: 
// Module Name:    ALU 
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
module ALU(
    input [3:0] inA,
    input [3:0] inB,
    input [1:0] inC,
    input [1:0] op,
    output [3:0] ans
    );

    assign ans = (op == 2'b00) ? $signed($signed(inA) >>> inC) :
                 (op == 2'b01) ? $signed(inA >>inC) : 
                 (op == 2'b10) ? $signed(inA - inB) :
                 (op == 2'b11) ? $signed(inA + inB) :
                 4'b0000;


endmodule
