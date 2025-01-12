// Verified: 2024-08-28
`timescale 1ns / 1ps

`default_nettype none
module DM(
    input wire WE,
    input wire [2:0] DMSel,
    input wire [31:0] A,
    input wire [31:0] D,
    input wire [31:0] rdata,
    output wire [31:0] wdata,
    output wire [3:0] byteen,
    output wire [31:0] Q
    );
    
    // Splitter
    wire [1:0] A_byte;
    wire [15:0] D_half;
    wire [7:0] D_byte;

    assign A_byte = A[1:0];
    assign D_half = D[15:0];
    assign D_byte = D[7:0];

    // Handle rdata
    wire [7:0] rdata_byte;
    wire [15:0] rdata_half;
    wire [31:0] rdata_byte_MUX;
    wire [31:0] rdata_half_MUX;

    assign Q = (DMSel[1:0] == 2'b00) ? rdata_byte_MUX :
               (DMSel[1:0] == 2'b01) ? rdata_half_MUX :
               rdata; // DMSel[1:0] == 2'b10/2'b11

    assign rdata_byte = (A_byte == 2'b00) ? rdata[7:0] :
                        (A_byte == 2'b01) ? rdata[15:8] : 
                        (A_byte == 2'b10) ? rdata[23:16] :
                        rdata[31:24]; // A_byte == 2'b11

    assign rdata_half = (A_byte[1] == 1'b0) ? rdata[15:0] :
                        rdata[31:16]; // A_byte[1] == 1'b1

    assign rdata_byte_MUX = (DMSel[2] == 1'b0) ? 
                            {{24{rdata_byte[7]}}, rdata_byte} :
                            // DMSel[2] == 1'b1
                            {24'b0, rdata_byte}; 
 
    assign rdata_half_MUX = (DMSel[2] == 1'b0) ? 
                            {{16{rdata_half[15]}}, rdata_half} :
                            // DMSel[2] == 1'b1
                            {16'b0, rdata_half}; 

    // Handle wdata
    wire [31:0] wdata_byte;
    wire [31:0] wdata_half;

    assign wdata = (DMSel[1:0] == 2'b00) ? wdata_byte :
                   (DMSel[1:0] == 2'b01) ? wdata_half :
                   D; // DMSel[1:0] == 2'b10/2'b11

    assign wdata_byte = (A_byte == 2'b00) ?
                        {8'b0, 8'b0, 8'b0, D_byte} :
                        (A_byte == 2'b01) ?
                        {8'b0, 8'b0, D_byte, 8'b0} :
                        (A_byte == 2'b10) ?
                        {8'b0, D_byte, 8'b0, 8'b0} :
                        // A_byte == 2'b11
                        {D_byte, 8'b0, 8'b0, 8'b0};

    assign wdata_half = (A_byte[1] == 1'b0) ?
                        {16'b0, D_half} :
                        // A_byte[1] == 1'b1
                        {D_half, 16'b0};

    // Handle byteen
    wire [3:0] byteen_enable;
    wire [3:0] byteen_byte;
    wire [3:0] byteen_half;

    assign byteen = (WE) ? byteen_enable : 4'b0000;

    assign byteen_enable = (DMSel[1:0] == 2'b00) ? byteen_byte :
                           (DMSel[1:0] == 2'b01) ? byteen_half :
                           4'b1111; // DMSel[1:0] == 2'b10/2'b11

    assign byteen_byte = (A_byte == 2'b00) ? 4'b0001 :
                         (A_byte == 2'b01) ? 4'b0010 : 
                         (A_byte == 2'b10) ? 4'b0100 :
                         4'b1000; // A_byte == 2'b11

    assign byteen_half = (A_byte[1] == 1'b0) ? 4'b0011 :
                         4'b1100; // A_byte[1] == 1'b1
    
endmodule
