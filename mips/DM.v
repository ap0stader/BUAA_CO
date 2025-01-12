// Verified: 2024-08-27
`timescale 1ns / 1ps

`default_nettype none
module DM(
    input wire RESET,
    input wire clk,
    input wire WE,
    input wire [2:0] DMSel,
    input wire [31:0] A,
    input wire [31:0] D_write,
    output wire [31:0] D_read,
    // 输入PC是因为评测需要输出
    input wire [31:0] PC
    );
    
    // RAM Input & Output
    wire [31:0] RAM_D_write;
    wire [31:0] RAM_D_read;

    // Splitter
    wire [1:0] A_byte;
    wire [15:0] D_write_half;
    wire [7:0] D_write_byte;

    assign A_byte = A[1:0];
    assign D_write_half = D_write[15:0];
    assign D_write_byte = D_write[7:0];


    // Handle D-write
    wire [31:0] RAM_D_write_byte;
    wire [31:0] RAM_D_write_half;

    assign RAM_D_write = (DMSel[1:0] == 2'b00) ? RAM_D_write_byte :
                         (DMSel[1:0] == 2'b01) ? RAM_D_write_half :
                         D_write; // DMSel[1:0] == 2'b10/2'b11

    assign RAM_D_write_byte = (A_byte == 2'b00) ? 
                              {RAM_D_read[31:24], RAM_D_read[23:16], RAM_D_read[15:8], D_write_byte} : 
                              (A_byte == 2'b01) ? 
                              {RAM_D_read[31:24], RAM_D_read[23:16], D_write_byte, RAM_D_read[7:0]} : 
                              (A_byte == 2'b10) ? 
                              {RAM_D_read[31:24], D_write_byte, RAM_D_read[15:8], RAM_D_read[7:0]} : 
                              // A_byte == 2'b11
                              {D_write_byte, RAM_D_read[23:16], RAM_D_read[15:8], RAM_D_read[7:0]}; 

    assign RAM_D_write_half = (A_byte[1] == 1'b0) ? {RAM_D_read[31:16], D_write_half} :
                              {D_write_half, RAM_D_read[15:0]}; // A_byte[1] == 1'b1


    // Handle D-read
    wire [7:0] D_read_byte;
    wire [15:0] D_read_half;
    wire [31:0] D_read_byte_MUX;
    wire [31:0] D_read_half_MUX;

    assign D_read = (DMSel[1:0] == 2'b00) ? D_read_byte_MUX :
                    (DMSel[1:0] == 2'b01) ? D_read_half_MUX :
                    RAM_D_read; // DMSel[1:0] == 2'b10/2'b11

    assign D_read_byte = (A_byte == 2'b00) ? RAM_D_read[7:0] :
                         (A_byte == 2'b01) ? RAM_D_read[15:8] : 
                         (A_byte == 2'b10) ? RAM_D_read[23:16] :
                         RAM_D_read[31:24]; // A_byte == 2'b11

    assign D_read_half = (A_byte[1] == 1'b0) ? RAM_D_read[15:0] :
                         RAM_D_read[31:16]; // A_byte[1] == 1'b1

    assign D_read_byte_MUX = (DMSel[2] == 1'b0) ? {{24{D_read_byte[7]}}, D_read_byte} :
                             {24'b0, D_read_byte}; // DMSel[2] == 1'b1
 
    assign D_read_half_MUX = (DMSel[2] == 1'b0) ? {{16{D_read_half[15]}}, D_read_half} :
                             {16'b0, D_read_half}; // DMSel[2] == 1'b1


    DM_RAM RAM_instance (.RESET(RESET),
                         .clk(clk),
                         .WE(WE),
                         .A(A),
                         .D_write(RAM_D_write),
                         .D_read(RAM_D_read),
                         .PC(PC)
    );

endmodule
