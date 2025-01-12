// Verified: 2024-08-29
`timescale 1ns / 1ps

`default_nettype none

`include "Address_Map.v"
`include "Exception_Code.v"
module ECMUX_F(
    input wire [31:0] InstrAddr,

    output wire [4:0] ExcCode_F,
    output wire AdEL_F
    );

    wire AdEL_F_1 = | InstrAddr[1:0];

    wire AdEL_F_2 = ~(`VALID_PC_START <= InstrAddr && InstrAddr <= `VALID_PC_END);

    assign AdEL_F = AdEL_F_1 | AdEL_F_2;

    assign ExcCode_F = AdEL_F ? `ExcCode_AdEL : `No_ExcCode;

endmodule
