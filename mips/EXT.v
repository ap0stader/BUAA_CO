// Verified: 2024-08-29
`timescale 1ns / 1ps

`default_nettype none
module EXT(
    input wire [1:0] EXTSel,
    input wire [15:0] imm16,
    output wire [31:0] ext32
    );

    assign ext32 = (EXTSel == 2'b00) ? {{16{imm16[15]}}, imm16} :
                   (EXTSel == 2'b01) ? {16'b0, imm16} :
                   {imm16, 16'b0}; // EXTSel == 2'b10/2'b11

endmodule
