`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:43:37 10/11/2023 
// Design Name: 
// Module Name:    BlockChecker 
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
`define S0 4'b0000
`define S1 4'b0001
`define S2 4'b0010
`define S3 4'b0011
`define S4 4'b0100
`define S5 4'b0101
`define S6 4'b0110
`define S7 4'b0111
`define S8 4'b1000
`define S9 4'b1001
`define S10 4'b1010

module BlockChecker(
    input wire clk,
    input wire reset,
    input wire [7:0] in,
    output wire result
    );

    // 空格
    parameter C_space = 8'd32;
    // 大写字母
    parameter L_upperletter = 8'd65;
    parameter R_upperletter = 8'd90;
    // 小写字母
    parameter L_lowerletter = 8'd97;
    parameter R_lowerletter = 8'd122;
    // begin和end
    parameter C_b = 8'd98;
    parameter C_d = 8'd100;
    parameter C_e = 8'd101;
    parameter C_g = 8'd103;
    parameter C_i = 8'd105;
    parameter C_n = 8'd110;
    
    // 将大写字母统一到小写字母
    wire [7:0] process_in;
    assign process_in = (L_upperletter <= in && in <= R_upperletter) ? (in + 8'd32) : in;
    
    reg [31:0] mismatch;
    reg overflow;
    
    reg [3:0] status;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            mismatch <= 32'b0;
            overflow <= 1'b0;
            
            status <= 4'b0;
        end
        else begin
            case (status)
                // 大教训：case语句移动要有begin-end
                `S0: begin
                    if (process_in == C_b) begin
                        status <= `S1;
                    end
                    else if (process_in == C_e) begin
                        status <= `S6;
                    end
                    else if (L_lowerletter <= process_in && process_in <= R_lowerletter) begin
                        status <= `S9;
                    end
                    else begin
                        status <= `S0;
                    end
                end
                `S1: begin
                    if (process_in == C_e) begin
                        status <= `S2;
                    end
                    else if (L_lowerletter <= process_in && process_in <= R_lowerletter) begin
                        status <= `S9;
                    end
                    else begin
                        status <= `S0;
                    end
                end
                `S2: begin
                    if (process_in == C_g) begin
                        status <= `S3;
                    end
                    else if (L_lowerletter <= process_in && process_in <= R_lowerletter) begin
                        status <= `S9;
                    end
                    else begin
                        status <= `S0;
                    end
                end
                `S3: begin
                    if (process_in == C_i) begin
                        status <= `S4;
                    end
                    else if (L_lowerletter <= process_in && process_in <= R_lowerletter) begin
                        status <= `S9;
                    end
                    else begin
                        status <= `S0;
                    end
                end
                `S4: begin
                    // 第一次提交的问题：时序理解错误
                    if (process_in == C_n) begin
                        status <= `S5;
                        mismatch <= mismatch + 32'b1;
                    end
                    else if (L_lowerletter <= process_in && process_in <= R_lowerletter) begin
                        status <= `S9;
                    end
                    else begin
                        status <= `S0;
                    end
                end
                `S5: begin
                    if (L_lowerletter <= process_in && process_in <= R_lowerletter) begin
                        status <= `S9;
                        mismatch <= mismatch - 32'b1;
                    end
                    else begin
                        status <= `S0;
                    end
                end
                `S6: begin
                    if (process_in == C_n) begin
                        status <= `S7;
                    end
                    else if (L_lowerletter <= process_in && process_in <= R_lowerletter) begin
                        status <= `S9;
                    end
                    else begin
                        status <= `S0;
                    end
                end
                `S7: begin
                    if (process_in == C_d) begin
                        status <= `S8;
                        if (mismatch == 32'b0) begin
                            overflow <= 1'b1;
                        end
                        else begin
                            mismatch <= mismatch - 32'b1;
                        end
                    end
                    else if (L_lowerletter <= process_in && process_in <= R_lowerletter) begin
                        status <= `S9;
                    end
                    else begin
                        status <= `S0;
                    end
                end
                `S8: begin
                    if (L_lowerletter <= process_in && process_in <= R_lowerletter) begin
                        status <= `S9;
                        if (overflow) begin
                            overflow <= 1'b0;
                        end
                        else begin
                            mismatch <= mismatch + 32'b1;
                        end
                    end
                    else if (process_in == C_space) begin
                        if (overflow) begin
                            status <= `S10;
                        end
                        else begin
                            status <= `S0;
                        end
                    end
                    else begin
                        status <= `S0;
                    end
                end
                `S9: begin
                    if (L_lowerletter <= process_in && process_in <= R_lowerletter) begin
                        status <= `S9;
                    end
                    else begin
                        status <= `S0;
                    end
                end
                `S10 : begin
                    status <= `S10;
                end
            endcase
        end
    end

    assign result = (overflow) ? 1'b0 : ((mismatch == 32'b0) ? 1'b1 : 1'b0);

endmodule
