`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:22:24 10/06/2023 
// Design Name: 
// Module Name:    intcheck 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`default_nettype none

`define S00 5'd00
`define S01 5'd01
`define S02 5'd02
`define S03 5'd03
`define S04 5'd04
`define S05 5'd05
`define S06 5'd06
`define S07 5'd07
`define S08 5'd08
`define S09 5'd09
`define S10 5'd10
`define S99 5'd11

module intcheck(
    input wire clk,
    input wire reset,
    input wire [7:0] in,
    // debug
    // output wire [4:0] status_output,
    output wire out
    );
    
    // ASCII值转化
    // 大写字母
    parameter L_upperletter = 8'd65;
    parameter R_upperletter = 8'd90;
    // 小写字母
    parameter L_lowerletter = 8'd97;
    parameter R_lowerletter = 8'd122;
    // 数字
    parameter L_digit = 8'd48;
    parameter R_digit = 8'd57;
    // 下划线
    parameter C_underline = 8'd95;
    // 空白字符
    parameter C_space = 8'd32;
    parameter C_tab = 8'd9;
    // int三个字符
    parameter C_i = 8'd105;
    parameter C_n = 8'd110;
    parameter C_t = 8'd116;
    // 逗号和分号
    parameter C_dou = 8'd44;
    parameter C_fen = 8'd59;
    
    // 状态寄存器
    reg [4:0] status;
    
    // debug
    // assign status_output[4:0] = status[4:0];
    
    always @(posedge clk) begin
        if (reset) begin
            status <= `S00;
        end
        else begin
            case (status)
                `S00: begin
                    if (in == C_i)
                        status <= `S01;
                    else if (in == C_space || in == C_tab || in == C_fen)
                        status <= `S00;
                    else
                        status <= `S99;
                end
                `S01: begin
                    if (in == C_n)
                        status <= `S02;
                    else if (in == C_fen)
                        status <= `S00;
                    else
                        status <= `S99;
                end
                `S02: begin
                    if (in == C_t)
                        status <= `S03;
                    else if (in == C_fen)
                        status <= `S00;
                    else
                        status <= `S99;
                end
                `S03: begin
                    if (in == C_space || in == C_tab)
                        status <= `S04;
                    else if (in == C_fen)
                        status <= `S00;
                    else
                        status <= `S99;
                end
                `S04: begin
                    if (in == C_i)
                        status <= `S05;
                    else if ((in >= L_upperletter && in <= R_upperletter) ||
                             (in >= L_lowerletter && in <= R_lowerletter) ||
                              in == C_underline)
                        status <= `S08;
                    else if (in == C_space || in == C_tab)
                        status <= `S04;
                    else if (in == C_fen)
                        status <= `S00;
                    else
                        status <= `S99;
                end
                `S05: begin
                    if (in == C_n)
                        status <= `S06;
                    else if ((in >= L_upperletter && in <= R_upperletter) ||
                             (in >= L_lowerletter && in <= R_lowerletter) ||
                             (in >= L_digit && in <= R_digit) ||
                              in == C_underline)
                        status <= `S08;
                    else if (in == C_dou)
                        status <= `S04;
                    else if (in == C_space || in == C_tab)
                        status <= `S09;
                    else if (in == C_fen)
                        status <= `S10;
                    else
                        status <= `S99;
                end
                `S06: begin
                    if (in == C_t)
                        status <= `S07;
                    else if ((in >= L_upperletter && in <= R_upperletter) ||
                             (in >= L_lowerletter && in <= R_lowerletter) ||
                             (in >= L_digit && in <= R_digit) ||
                              in == C_underline)
                        status <= `S08;
                    else if (in == C_dou)
                        status <= `S04;
                    else if (in == C_space || in == C_tab)
                        status <= `S09;
                    else if (in == C_fen)
                        status <= `S10;
                    else
                        status <= `S99;
                end
                `S07: begin
                    if ((in >= L_upperletter && in <= R_upperletter) ||
                        (in >= L_lowerletter && in <= R_lowerletter) ||
                        (in >= L_digit && in <= R_digit) ||
                         in == C_underline)
                        status <= `S08;
                    else if (in == C_fen)
                        status <= `S00;
                    else
                        status <= `S99;
                end
                `S08: begin
                    if ((in >= L_upperletter && in <= R_upperletter) ||
                        (in >= L_lowerletter && in <= R_lowerletter) ||
                        (in >= L_digit && in <= R_digit) ||
                         in == C_underline)
                        status <= `S08;
                    else if (in == C_dou)
                        status <= `S04;
                    else if (in == C_space || in == C_tab)
                        status <= `S09;
                    else if (in == C_fen)
                        status <= `S10;
                    else
                        status <= `S99;
                end
                `S09: begin
                    if (in == C_dou)
                        status <= `S04;
                    else if (in == C_space || in == C_tab)
                        status <= `S09;
                    else if (in == C_fen)
                        status <= `S10;
                    else
                        status <= `S99;
                end
                `S10: begin
                    if (in == C_i)
                        status <= `S01;
                    else if (in == C_space || in == C_tab || in == C_fen)
                        status <= `S00;
                    else
                        status <= `S99;
                end
                `S99: begin
                    if (in == C_fen)
                        status <= `S00;
                    else
                        status <= `S99;
                end
            endcase
        end
    end
    
    assign out = (status == `S10) ? 1'b1 : 1'b0;
    
endmodule
