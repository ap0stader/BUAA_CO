`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:53:53 10/11/2023 
// Design Name: 
// Module Name:    ext 
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
module ext(
    input wire [15:0] imm,
    input wire [1:0] EOp,
    output reg [31:0] ext
    );
    
    always @(*) begin
        case (EOp)
            2'b00:
                ext = imm[15] ? {16'hffff, imm} : {16'h0000, imm};
            2'b01:
                ext = {16'b0, imm};
            2'b10:
                ext = {imm, 16'b0};
            2'b11:
                ext = (imm[15] ? {16'hffff, imm} : {16'h0000, imm}) << 2'd2;
        endcase
    end

endmodule
