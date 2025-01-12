// Verified: 2024-08-29
`timescale 1ns / 1ps

`default_nettype none

`include "Address_Map.v"
`include "Exception_Code.v"
module ECMUX_M(
    input wire [4:0] ExcCode_E,

    input wire [1:0] AdE,

    output wire [4:0] ExcCode_M
    );

    assign ExcCode_M = (ExcCode_E != `No_ExcCode) ? ExcCode_E :
                       (AdE == 2'b10) ? `ExcCode_AdEL :
                       (AdE == 2'b11) ? `ExcCode_AdES :
                        `No_ExcCode;

endmodule
