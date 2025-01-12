`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:18:29 10/11/2023 
// Design Name: 
// Module Name:    expr 
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

`define S0 2'b00
`define S1 2'b01
`define S2 2'b10
`define S3 2'b11

module expr(
    input wire clk,
    input wire clr,
    input wire [7:0] in,
    // 第一次提交时的问题，对于reg使用assign，无法得到正确的输出
    output wire out
    );

    parameter L_digit = 8'd48;
    parameter R_digit = 8'd57;
    parameter C_plus = 8'd43;
    parameter C_multiple = 8'd42;
    
    reg [1:0] status;
    
    always @(posedge clk, posedge clr) begin
        if (clr) begin
            status <= `S0;
        end
        else begin
            case (status)
                `S0:
                    if (L_digit <= in && in <= R_digit) begin
                        status <= `S1;
                    end
                    else begin
                        status <= `S3;
                    end
                `S1:
                    if (in == C_plus || in == C_multiple) begin
                        status <= `S0;
                    end
                    else begin
                        status <= `S3;
                    end
                `S2:
                    status <= `S0;
                `S3:
                    status <= `S3;
            endcase
        end
    end
    
    // 第二次提交的问题：输出逻辑弄错了
    assign out = (status == `S1) ? 1'b1 : 1'b0; 

endmodule
