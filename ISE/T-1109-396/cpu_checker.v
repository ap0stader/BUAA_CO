`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:06:00 08/26/2023 
// Design Name: 
// Module Name:    cpu_checker 
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

`define S0 4'd0
`define S1 4'd1
`define S2 4'd2
`define S3 4'd3
`define S4 4'd4
`define S5 4'd5
`define S6 4'd6
`define S7 4'd7
`define S8 4'd8
`define S9 4'd9
`define S10 4'd10

module cpu_checker(
    input wire clk,
    input wire reset,
    input wire [7:0] char,
    output wire [1:0] format_type
    );

    parameter L_lowerletter = 8'd97;
    parameter R_lowerletter = 8'd102;
    parameter L_digit = 8'd48;
    parameter R_digit = 8'd57;

    reg [3:0] status;
    // 2'b01表示寄存器信息，2'b10表示数据存储器信息
    reg [1:0] judge;
    // 数字位数的计数器
    reg [3:0] counter;

    initial begin
        status <= `S0;
        judge <= 2'b00;
        counter <= 4'd0;
    end

    always @(posedge clk) begin
        if(reset) begin
            status <= `S0;
            judge <= 2'b00;
            counter <= 4'd0;
        end
        else begin
            case (status)
                // 非法状态
                `S0 : begin
                    if(char == "^") begin
                        status <= `S1;
                        counter <= 4'd0;
                    end
                    else begin 
                        status <= `S0;
                    end
                end
                
                // 十进制读取状态（time）
                `S1 : begin
                    if(char >= L_digit & char <= R_digit) begin
                        if(counter < 4'd4) begin
                            status <= `S1;
                            counter <= counter + 1;
                        end
                        else begin
                            status <= `S0;
                        end
                    end

                    else if(char == "@") begin
                        if(counter > 4'd0) begin
                            status <= `S2;
                            counter <= 4'd0;
                        end
                        else begin
                            status <= `S0;
                        end
                    end

                    else begin
                        status <= `S0;
                    end
                end
                
                // 十六进制读取状态（pc）
                `S2 : begin
                    if(char >= L_digit & char <= R_digit |
                       char >= L_lowerletter & char <= R_lowerletter) begin
                        if(counter < 4'd8) begin
                            status <= `S2;
                            counter <= counter + 1;
                        end
                        else begin
                            status <= `S0;
                        end
                    end

                    else if(char == ":") begin
                        if(counter == 4'd8) begin
                            status <= `S3;
                        end
                        else begin
                            status <= `S0;
                        end
                    end

                    else begin
                        status <= `S0;
                    end
                end
                
                // 空格判断状态（A）
                `S3 : begin
                    case(char)
                        " ": status <= `S3;
                        "$": begin
                            status <= `S4;
                            counter <= 4'd0;
                            judge <= 2'b01;
                        end
                        "*": begin
                            status <= `S5;
                            counter <= 4'd0;
                            judge <= 2'b10;
                        end
                        default: status <= `S0;
                    endcase
                end
                
                // 十进制读取状态（grf）
                `S4 : begin
                    if(char >= L_digit & char <= R_digit) begin
                        if(counter < 4'd4) begin
                            status <= `S4;
                            counter <= counter + 1;
                        end
                        else begin
                            status <= `S0;
                        end
                    end

                    else if(char == " ") begin
                        if(counter > 4'd0) begin
                            status <= `S6;
                            counter <= 4'd0;
                        end
                        else begin
                            status <= `S0;
                        end
                    end

                    else if(char == "<") begin
                        if(counter > 4'd0) begin
                            status <= `S7;
                            counter <= 4'd0;
                        end
                        else begin
                            status <= `S0;
                        end
                    end

                    else begin
                        status <= `S0;
                    end
                end
                
                // 十六进制读取状态（addr）
                `S5 : begin
                    if(char >= L_digit & char <= R_digit |
                       char >= L_lowerletter & char <= R_lowerletter) begin
                        if(counter < 4'd8) begin
                            status <= `S5;
                            counter <= counter + 1;
                        end
                        else begin
                            status <= `S0;
                        end
                    end

                    else if(char == " ") begin
                        if(counter == 4'd8) begin
                            status <= `S6;
                            counter <= 4'd0;
                        end
                        else begin
                            status <= `S0;
                        end
                    end

                    else if(char == "<") begin
                        if(counter == 4'd8) begin
                            status <= `S7;
                            counter <= 4'd0;
                        end
                        else begin
                            status <= `S0;
                        end
                    end

                    else begin
                        status <= `S0;
                    end
                end

                // 空格判断状态（B）
                `S6 : begin
                    case(char)
                        " ": status <= `S6;
                        "<": status <= `S7;
                        default: status <= `S0;
                    endcase
                end

                // <过渡状态
                `S7 : begin
                    case(char)
                        "=": status <= `S8;
                        default: status <= `S0;
                    endcase
                end

                // 空格判断状态（C）
                `S8 : begin
                    if(char >= L_digit & char <= R_digit |
                       char >= L_lowerletter & char <= R_lowerletter) begin
                        status <= `S9;
                        counter <= 4'd1;
                    end
                    else if(char == " ") begin
                        status <= `S8;
                    end
                    else begin
                        status <= `S0;
                    end
                end

                // 十六进制读取状态（addr）
                `S9 : begin
                    if(char >= L_digit & char <= R_digit |
                       char >= L_lowerletter & char <= R_lowerletter) begin
                        if(counter < 4'd8) begin
                            status <= `S9;
                            counter <= counter + 1;
                        end
                        else begin
                            status <= `S0;
                        end
                    end

                    else if(char == "#") begin
                        if(counter == 4'd8) begin
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

                `S10: begin
                    if(char == "^") begin
                        status <= `S1;
                        counter <= 4'd0;
                    end
                    else begin 
                        status <= `S0;
                    end
                end
            endcase
        end
    end

    assign format_type = (status == `S10) ? judge : 2'b00;

endmodule
