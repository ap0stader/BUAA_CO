// Verified: 2024-08-28
`timescale 1ns / 1ps

`default_nettype none
module DM(
    input wire RESET,
    input wire clk,
    input wire WE,
    input wire [2:0] DMSel,
    input wire [31:0] A,
    input wire [31:0] D,
    output wire [31:0] Q,
    // 评测需要输出
    output wire [31:0] Exam_RAM_D
    );
    
    // RAM Input & Output
    wire [31:0] RAM_D;
    wire [31:0] RAM_Q;

    // 评测需要输出
    // 由于目前只要求实现sw，实验教程没有明确说明当针对半字或字节的操作时应当如何处理
    // 此处将处理后的32位数据进行输出
    assign Exam_RAM_D = RAM_D;

    // Splitter
    wire [1:0] A_byte;
    wire [15:0] D_half;
    wire [7:0] D_byte;

    assign A_byte = A[1:0];
    assign D_half = D[15:0];
    assign D_byte = D[7:0];


    // Handle D
    wire [31:0] RAM_D_byte;
    wire [31:0] RAM_D_half;

    assign RAM_D = (DMSel[1:0] == 2'b00) ? RAM_D_byte :
                   (DMSel[1:0] == 2'b01) ? RAM_D_half :
                   D; // DMSel[1:0] == 2'b10/2'b11

    assign RAM_D_byte = (A_byte == 2'b00) ?
                        {RAM_Q[31:24], RAM_Q[23:16], RAM_Q[15:8], D_byte} :
                        (A_byte == 2'b01) ?
                        {RAM_Q[31:24], RAM_Q[23:16], D_byte, RAM_Q[7:0]} :
                        (A_byte == 2'b10) ?
                        {RAM_Q[31:24], D_byte, RAM_Q[15:8], RAM_Q[7:0]} :
                        // A_byte == 2'b11
                        {D_byte, RAM_Q[23:16], RAM_Q[15:8], RAM_Q[7:0]};

    assign RAM_D_half = (A_byte[1] == 1'b0) ?
                        {RAM_Q[31:16], D_half} :
                        // A_byte[1] == 1'b1
                        {D_half, RAM_Q[15:0]};


    // Handle Q
    wire [7:0] Q_byte;
    wire [15:0] Q_half;
    wire [31:0] Q_byte_MUX;
    wire [31:0] Q_half_MUX;

    assign Q = (DMSel[1:0] == 2'b00) ? Q_byte_MUX :
               (DMSel[1:0] == 2'b01) ? Q_half_MUX :
               RAM_Q; // DMSel[1:0] == 2'b10/2'b11

    assign Q_byte = (A_byte == 2'b00) ? RAM_Q[7:0] :
                    (A_byte == 2'b01) ? RAM_Q[15:8] : 
                    (A_byte == 2'b10) ? RAM_Q[23:16] :
                    RAM_Q[31:24]; // A_byte == 2'b11

    assign Q_half = (A_byte[1] == 1'b0) ? RAM_Q[15:0] :
                    RAM_Q[31:16]; // A_byte[1] == 1'b1

    assign Q_byte_MUX = (DMSel[2] == 1'b0) ? 
                        {{24{Q_byte[7]}}, Q_byte} :
                        // DMSel[2] == 1'b1
                        {24'b0, Q_byte}; 
 
    assign Q_half_MUX = (DMSel[2] == 1'b0) ? 
                        {{16{Q_half[15]}}, Q_half} :
                        // DMSel[2] == 1'b1
                        {16'b0, Q_half}; 


    DM_RAM RAM_instance (.RESET(RESET),
                         .clk(clk),
                         .WE(WE),
                         .A(A),
                         .D(RAM_D),
                         .Q(RAM_Q)
    );

endmodule
