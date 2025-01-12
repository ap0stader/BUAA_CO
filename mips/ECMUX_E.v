// Verified: 2024-08-29
`timescale 1ns / 1ps

`default_nettype none

`include "Address_Map.v"
`include "Exception_Code.v"
module ECMUX_E(
    input wire [4:0] ExcCode_D,

    input wire [3:0] BridgeSel,
    input wire ISLOADSTORE,
    input wire Overflow,
    
    output wire [4:0] ExcCode_E
    );

    wire [4:0] AdE = BridgeSel[3] ? `ExcCode_AdES : `ExcCode_AdEL;

    assign ExcCode_E = (ExcCode_D != `No_ExcCode) ? ExcCode_D :
                        Overflow ? (ISLOADSTORE ? AdE : `ExcCode_Ov) :
                        `No_ExcCode;

endmodule
