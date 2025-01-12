// Verified: 2024-08-29
`timescale 1ns / 1ps

`default_nettype none

`include "Address_Map.v"

`define DMX_0  7'b0000001
`define DMX_1  7'b0000010
`define DMX_2  7'b0000100
`define DMX_3  7'b0001000
`define DMX_4  7'b0010000
`define DMX_5  7'b0100000
`define DMX_DM 7'b1000000

`define AdE_LOAD  2'b10
`define AdE_STORE 2'b11

module BRIDGE(
    input  wire        ISLOADSTORE,
    input  wire [ 3:0] BridgeSel,
    input  wire        Req,

    input  wire [31:0] A,
    input  wire [31:0] D,

    input  wire [31:0] rdata_DM,
    input  wire [31:0] rdata_0,
    input  wire [31:0] rdata_1,
    input  wire [31:0] rdata_2,
    input  wire [31:0] rdata_3,
    input  wire [31:0] rdata_4,
    input  wire [31:0] rdata_5,

    input  wire        HWInt_0,
    input  wire        HWInt_1,
    input  wire        HWInt_2,
    input  wire        HWInt_3,
    input  wire        HWInt_4,
    input  wire        HWInt_5,

    output wire [31:0] wdata,

    output wire [ 3:0] byteen_DM,
    output wire [ 3:0] byteen_0,
    output wire [ 3:0] byteen_1,
    output wire [ 3:0] byteen_2,
    output wire [ 3:0] byteen_3,
    output wire [ 3:0] byteen_4,
    output wire [ 3:0] byteen_5,

    output wire [ 1:0] AdE,
    output wire [ 5:0] HWInt_Hub,

    output wire [31:0] Q
    );

    // Splitter
    wire [ 1:0] A_byte = A[ 1:0];
    wire [15:0] D_half = D[15:0];
    wire [ 7:0] D_byte = D[ 7:0];
    
    // HWInt_Hub
    assign HWInt_Hub = {HWInt_5, HWInt_4, HWInt_3, HWInt_2, HWInt_1, HWInt_0};

    // Handle byteen
    wire [3:0] byteen_byte = (A_byte == 2'b00) ? 4'b0001 :
                             (A_byte == 2'b01) ? 4'b0010 : 
                             (A_byte == 2'b10) ? 4'b0100 :
                             4'b1000; // A_byte == 2'b11

    wire [3:0] byteen_half = (A_byte[1] == 1'b0) ? 4'b0011 :
                             4'b1100; // A_byte[1] == 1'b1

    wire [3:0] byteen_enable = (BridgeSel[1:0] == 2'b00) ? byteen_byte :
                               (BridgeSel[1:0] == 2'b01) ? byteen_half :
                               4'b1111; // BridgeSel[1:0] == 2'b10/2'b11

    wire [3:0] byteen = (ISLOADSTORE & BridgeSel[3] & ~Req) ? byteen_enable : 4'b0000;

    // 只激活对应的设备
    wire [6:0] byteen_DMX_Sel = (( `VALID_DM_START <= A) && (A <= `VALID_DM_END )) ? `DMX_DM :
                                ((`VALID_TC0_START <= A) && (A <= `VALID_TC0_END)) ? `DMX_0  :
                                ((`VALID_TC1_START <= A) && (A <= `VALID_TC1_END)) ? `DMX_1  :
                                (( `VALID_IG_START <= A) && (A <= `VALID_IG_END )) ? `DMX_2  :
                                7'b0000000;

    assign byteen_DM = (byteen_DMX_Sel == `DMX_DM) ? byteen : 4'b0000;

    assign byteen_0  = (byteen_DMX_Sel == `DMX_0 ) ? byteen : 4'b0000;

    assign byteen_1  = (byteen_DMX_Sel == `DMX_1 ) ? byteen : 4'b0000;

    assign byteen_2  = (byteen_DMX_Sel == `DMX_2 ) ? byteen : 4'b0000;

    assign byteen_3  = (byteen_DMX_Sel == `DMX_3 ) ? byteen : 4'b0000;

    assign byteen_4  = (byteen_DMX_Sel == `DMX_4 ) ? byteen : 4'b0000;

    assign byteen_5  = (byteen_DMX_Sel == `DMX_5 ) ? byteen : 4'b0000;

    // Handle AdE
    
    // 按字操作未字对齐
    wire AdE_1 = (BridgeSel[1:0] == 2'b11) && (A_byte    != 2'b00);
    // 按半字操作未按半字对齐
    wire AdE_2 = (BridgeSel[1:0] == 2'b01) && (A_byte[0] != 1'b0 );
    // 地址不在存取合法地址区段
    wire AdE_3 = ~ ((( `VALID_DM_START <= A) && (A <= `VALID_DM_END )) ||
                    ((`VALID_TC0_START <= A) && (A <= `VALID_TC0_END)) ||
                    ((`VALID_TC1_START <= A) && (A <= `VALID_TC1_END)) ||
                    (( `VALID_IG_START <= A) && (A <= `VALID_IG_END )));
    // 按字节或者半字操作TC
    wire AdE_4 = ((BridgeSel[1:0] == 2'b00) || (BridgeSel[1:0] == 2'b01)) &&
                 (((`VALID_TC0_START <= A) && (A <= `VALID_TC0_END)) ||
                  ((`VALID_TC1_START <= A) && (A <= `VALID_TC1_END)));
    // 尝试写入TC_Count
    wire AdE_5 = BridgeSel[3] &&
                 (((`VALID_TC0_COUNT_START <= A) && (A <= `VALID_TC0_COUNT_END)) ||
                  ((`VALID_TC1_COUNT_START <= A) && (A <= `VALID_TC1_COUNT_END)));

    wire AdE_Hub = AdE_1 | AdE_2 | AdE_3 | AdE_4 | AdE_5;

    assign AdE = (ISLOADSTORE & AdE_Hub) ? (BridgeSel[3] ? `AdE_STORE : `AdE_LOAD) : 2'b0;

    // Handle rdata

    // 只使用对应的设备
    wire [31:0] rdata = (( `VALID_DM_START <= A) && (A <= `VALID_DM_END )) ? rdata_DM :
                        ((`VALID_TC0_START <= A) && (A <= `VALID_TC0_END)) ? rdata_0 :
                        ((`VALID_TC1_START <= A) && (A <= `VALID_TC1_END)) ? rdata_1 :
                        (( `VALID_IG_START <= A) && (A <= `VALID_IG_END )) ? rdata_2 :
                        32'b0;

    wire [ 7:0] rdata_byte = (A_byte == 2'b00) ? rdata[ 7: 0] :
                             (A_byte == 2'b01) ? rdata[15: 8] : 
                             (A_byte == 2'b10) ? rdata[23:16] :
                             rdata[31:24]; // A_byte == 2'b11

    wire [15:0] rdata_half = (A_byte[1] == 1'b0) ? rdata[15:0] :
                             rdata[31:16]; // A_byte[1] == 1'b1

    wire [31:0] rdata_byte_MUX = (BridgeSel[2] == 1'b0) ? 
                                 {{24{rdata_byte[7]}}, rdata_byte} :
                                 // BridgeSel[2] == 1'b1
                                 {24'b0, rdata_byte}; 
 
    wire [31:0] rdata_half_MUX = (BridgeSel[2] == 1'b0) ? 
                                 {{16{rdata_half[15]}}, rdata_half} :
                                 // BridgeSel[2] == 1'b1
                                 {16'b0, rdata_half}; 

    assign Q = (BridgeSel[1:0] == 2'b00) ? rdata_byte_MUX :
               (BridgeSel[1:0] == 2'b01) ? rdata_half_MUX :
               rdata; // BridgeSel[1:0] == 2'b10/2'b11

    // Handle wdata
    wire [31:0] wdata_byte = (A_byte == 2'b00) ?
                             {8'b0, 8'b0, 8'b0, D_byte} :
                             (A_byte == 2'b01) ?
                             {8'b0, 8'b0, D_byte, 8'b0} :
                             (A_byte == 2'b10) ?
                             {8'b0, D_byte, 8'b0, 8'b0} :
                             // A_byte == 2'b11
                             {D_byte, 8'b0, 8'b0, 8'b0};

    wire [31:0] wdata_half = (A_byte[1] == 1'b0) ?
                             {16'b0, D_half} :
                             // A_byte[1] == 1'b1
                             {D_half, 16'b0};

    assign wdata = (BridgeSel[1:0] == 2'b00) ? wdata_byte :
                   (BridgeSel[1:0] == 2'b01) ? wdata_half :
                   D; // BridgeSel[1:0] == 2'b10/2'b11

endmodule
