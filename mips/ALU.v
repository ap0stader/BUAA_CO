// Verified: 2024-08-27
`timescale 1ns / 1ps

`default_nettype none
module ALU(
    input wire [1:0] OPSel,
    input wire [2:0] FuncSel,
    input wire [2:0] CompSel,
    input wire [31:0] rs,
    input wire [31:0] rt,
    input wire [4:0] shamt,
    output wire [31:0] OP,
    output wire Comp
    );

    // Arithmetic
    // OPSel = 00

    wire [31:0] Arithmetic;
    // FuncSel = XX0
    wire [31:0] Arithmetic_add;
    // FuncSel = XX1
    wire [31:0] Arithmetic_sub;

    assign Arithmetic = (FuncSel[0] == 1'b0) ? Arithmetic_add :
                        Arithmetic_sub; // FuncSel[0] == 1'b1
    
    assign Arithmetic_add = rs + rt;
    
    assign Arithmetic_sub = rs - rt;


    // Logical
    // OPSel = 01

    wire [31:0] Logical;
    // FuncSel = X00
    wire [31:0] Logical_and;
    // FuncSel = X01
    wire [31:0] Logical_or;
    // FuncSel = X10
    wire [31:0] Logical_xor;
    // FuncSel = X11
    wire [31:0] Logical_nor;

    assign Logical = (FuncSel[1:0] == 2'b00) ? Logical_and :
                     (FuncSel[1:0] == 2'b01) ? Logical_or :
                     (FuncSel[1:0] == 2'b10) ? Logical_xor :
                     Logical_nor; // FuncSel[1:0] == 2'b11

    assign Logical_and = rs & rt;

    assign Logical_or = rs | rt;

    assign Logical_xor = rs ^ rt;

    assign Logical_nor = ~Logical_or;
    

    // Shift
    // OPSel = 10

    wire [31:0] Shift;
    // Decided by FuncSel[2]
    wire [5:0] Shift_shamt;
    // FuncSel = X00/X01
    wire [31:0] Shift_logical_left;
    // FuncSel = X10
    wire [31:0] Shift_logical_right;
    // FuncSel = X11
    wire [31:0] Shift_arithmetic_right;

    assign Shift = (FuncSel[1:0] == 2'b00) ? Shift_logical_left :
                   (FuncSel[1:0] == 2'b01) ? Shift_logical_left :
                   (FuncSel[1:0] == 2'b10) ? Shift_logical_right :
                   Shift_arithmetic_right; // FuncSel[1:0] == 2'b11

    assign Shift_shamt = (FuncSel[2] == 1'b0) ? shamt :
                         rs[4:0]; // // FuncSel[2] == 1'b1

    assign Shift_logical_left = rt << shamt;

    assign Shift_logical_right = rt >> shamt;

    assign Shift_arithmetic_right = $signed(rt) >>> shamt;


    // Compare
    // OPSel = 11 (zero_extended to 32 bits)

    wire [31:0] Compare;
    // Decided by CompSel[2:1]
    wire [31:0] Compare_rt;
    // CompSel = 000/010
    wire Compare_slt;
    // CompSel = 001
    wire Compare_sget;
    // CompSel = 011
    wire Compare_ult;
    // CompSel = 100
    wire Compare_eq;
    // CompSel = 101
    wire Compare_neq;
    // CompSel = 110
    wire Compare_slet;
    // CompSel = 111
    wire Compare_sgt;

    assign Comp = (CompSel == 3'b000) ? Compare_slt :
                  (CompSel == 3'b001) ? Compare_sget :
                  (CompSel == 3'b010) ? Compare_slt :
                  (CompSel == 3'b011) ? Compare_ult :
                  (CompSel == 3'b100) ? Compare_eq :
                  (CompSel == 3'b101) ? Compare_neq :
                  (CompSel == 3'b110) ? Compare_slet :
                  Compare_sgt; // CompSel == 3'b111

    assign Compare = {31'b0, Comp};

    assign Compare_rt = (CompSel[2:1] == 2'b01 || CompSel[2:1] == 2'b10) ? rt :
                        32'h00000000; // CompSel[2:1] == 2'b00/2'b11

    assign Compare_slt = $signed(rs) < $signed(Compare_rt);

    assign Compare_sget = $signed(rs) >= $signed(Compare_rt);

    assign Compare_ult = rs < rt;

    assign Compare_eq = rs == rt;

    assign Compare_neq = rs != rt;

    assign Compare_slet = $signed(rs) <= $signed(Compare_rt);

    assign Compare_sgt = $signed(rs) > $signed(Compare_rt);


    assign OP = (OPSel == 2'b00) ? Arithmetic :
                (OPSel == 2'b01) ? Logical :
                (OPSel == 2'b10) ? Shift :
                Compare; // OPSel == 2'b11

endmodule
