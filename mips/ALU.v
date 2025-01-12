// Verified: 2024-08-29
`timescale 1ns / 1ps

`default_nettype none
module ALU(
    input wire [1:0] OPSel,
    input wire [1:0] FuncSel,
    input wire [31:0] A,
    input wire [31:0] B,
    input wire [4:0] shamt,
    output wire [31:0] OP,
    output wire Overflow
    );

    // Arithmetic
    // OPSel = 00

    wire [31:0] Arithmetic;
    // FuncSel = 00
    wire [31:0] Arithmetic_add;
    // FuncSel = 01
    wire [31:0] Arithmetic_sub;
    // FuncSel = 10
    wire [32:0] Overflow_Arithmetic_add;
    // FuncSel = 11
    wire [32:0] Overflow_Arithmetic_sub;

    assign Arithmetic = (FuncSel == 2'b01) ? Arithmetic_sub :
                        (FuncSel == 2'b10) ? Overflow_Arithmetic_add[31:0] :
                        (FuncSel == 2'b11) ? Overflow_Arithmetic_sub[31:0] : 
                        Arithmetic_add; // FuncSel == 2'b00
    
    assign Overflow = (OPSel == 2'b00) ? 
                      ((FuncSel == 2'b10) ? (Overflow_Arithmetic_add[32] != Overflow_Arithmetic_add[31]) :
                       (FuncSel == 2'b11) ? (Overflow_Arithmetic_sub[32] != Overflow_Arithmetic_sub[31]) :
                       1'b0) 
                      : 1'b0;

    assign Arithmetic_add = A + B;
    
    assign Arithmetic_sub = A - B;

    assign Overflow_Arithmetic_add = {A[31], A} + {B[31], B};

    assign Overflow_Arithmetic_sub = {A[31], A} - {B[31], B};


    // Logical
    // OPSel = 01

    wire [31:0] Logical;
    // FuncSel = 00
    wire [31:0] Logical_and;
    // FuncSel = 01
    wire [31:0] Logical_or;
    // FuncSel = 10
    wire [31:0] Logical_xor;
    // FuncSel = 11
    wire [31:0] Logical_nor;

    assign Logical = (FuncSel == 2'b00) ? Logical_and :
                     (FuncSel == 2'b01) ? Logical_or :
                     (FuncSel == 2'b10) ? Logical_xor :
                     Logical_nor; // FuncSel == 2'b11

    assign Logical_and = A & B;

    assign Logical_or = A | B;

    assign Logical_xor = A ^ B;

    assign Logical_nor = ~Logical_or;
    

    // Shift
    // OPSel = 10

    wire [31:0] Shift;
    wire [5:0] Shift_shamt;
    // FuncSel = 00/01
    wire [31:0] Shift_logical_left;
    // FuncSel = 10
    wire [31:0] Shift_logical_right;
    // FuncSel = 11
    wire [31:0] Shift_arithmetic_right;

    assign Shift = (FuncSel[1] == 1'b0) ? Shift_logical_left :
                   (FuncSel == 2'b10) ? Shift_logical_right :
                   Shift_arithmetic_right; // FuncSel == 2'b11

    assign Shift_shamt = A[4:0] + shamt;

    assign Shift_logical_left = B << Shift_shamt;

    assign Shift_logical_right = B >> Shift_shamt;

    assign Shift_arithmetic_right = $signed(B) >>> Shift_shamt;


    // Compare
    // OPSel = 11
    
    wire [31:0] Compare;
    // FuncSel = X0
    wire Compare_s_lt;
    // FuncSel = X1
    wire Compare_u_lt;

    assign Compare = (FuncSel[0] == 1'b0) ? {31'b0, Compare_s_lt} :
                     {31'b0, Compare_u_lt}; // FuncSel[0] == 1'b1

    assign Compare_s_lt = $signed(A) < $signed(B);

    assign Compare_u_lt = A < B;


    assign OP = (OPSel == 2'b00) ? Arithmetic :
                (OPSel == 2'b01) ? Logical :
                (OPSel == 2'b10) ? Shift :
                Compare; // OPSel == 2'b11

endmodule
