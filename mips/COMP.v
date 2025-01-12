// Verified: 2024-08-28
`timescale 1ns / 1ps

`default_nettype none
module COMP(
    input wire [2:0] CompSel,
    input wire [31:0] A,
    input wire [31:0] B,
    output wire BranchComp
    );

    // CompSel = 000
    wire s_lt;
    // CompSel = 001
    wire s_ge;
    // CompSel = 100
    wire u_eq;
    // CompSel = 101
    wire u_ne;
    // CompSel = 110
    wire s_le;
    // CompSel = 111
    wire s_gt;

    assign s_lt = $signed(A) < $signed(32'h0);

    assign s_ge = $signed(A) >= $signed(32'h0);

    assign u_eq = A == B;

    assign u_ne = A != B;

    assign s_le = $signed(A) <= $signed(32'h0);

    assign s_gt = $signed(A) > $signed(32'h0);

    assign BranchComp = (CompSel == 3'b000) ? s_lt :
                        (CompSel == 3'b001) ? s_ge :
                        (CompSel == 3'b100) ? u_eq :
                        (CompSel == 3'b101) ? u_ne :
                        (CompSel == 3'b110) ? s_le :
                        s_gt; // CompSel == 3'b111/3'b010/3'b011

endmodule
