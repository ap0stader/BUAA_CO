// Verified: 2024-08-29
`timescale 1ns / 1ps

`default_nettype none

`include "Address_Map.v"
`include "Exception_Code.v"
module ECMUX_D(
    input wire [4:0] ExcCode_F,
    
    input wire SYSCALL,
    input wire UNKNOWN,

    output wire [4:0] ExcCode_D
    );

    assign ExcCode_D = (ExcCode_F != `No_ExcCode) ? ExcCode_F :
                        SYSCALL ? `ExcCode_Syscall :
                        UNKNOWN ? `ExcCode_RI :
                        `No_ExcCode;

endmodule
