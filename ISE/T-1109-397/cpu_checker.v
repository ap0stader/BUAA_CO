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
// Revision 0.01 - File 
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

`define E0 4'b0000

`define O_E1 4'b0001
`define O_E2 4'b0010
`define O_E3 4'b0100
`define O_E4 4'b1000

`define A_NE1 4'b1110
`define A_NE2 4'b1101
`define A_NE3 4'b1011
`define A_NE4 4'b0111

module cpu_checker(
    input wire clk,
    input wire reset,
    input wire [7:0] char,
    input wire [15:0] freq,
    output wire [1:0] format_type,
    output wire [3:0] error_code
    // debug
    // output wire [3:0] status_output,
    // output wire [3:0] error_output,
    // output wire [31:0] pc_store_output,
    // output wire [31:0] addr_store_output
    );

    // ASCII值转化
    parameter L_lowerletter = 8'd97;
    parameter R_lowerletter = 8'd102;
    parameter L_digit = 8'd48;
    parameter R_digit = 8'd57;
    parameter L_hex = 8'd87;

    // 范围检查变量
    parameter L_pc = 32'h00003000;
    parameter R_pc = 32'h00004fff;
    parameter L_addr = 32'h00000000;
    parameter R_addr = 32'h00002fff;
    parameter L_grf = 14'd0;
    parameter R_grf = 14'd31;

    // 寄存器
    // 状态
    reg [3:0] status;
    // 2'b01表示寄存器信息，2'b10表示数据存储器信息
    reg [1:0] judge;
    // 数字位数的计数器
    reg [3:0] counter;
    // 错误的保存器
    reg [3:0] error;

    // 存储读取到的值
    reg [15:0] time_store;
    reg [31:0] pc_store;
    reg [31:0] addr_store;
    reg [13:0] grf_store;
    
    // 循环变量
    integer i;

    // debug
    // assign status_output = status;
    // assign error_output = error;
    // assign pc_store_output = pc_store;
    // assign addr_store_output = addr_store;
    
    always @(posedge clk) begin
        if(reset) begin
            status <= `S0;
            judge <= 2'b00;
            counter <= 4'd0;
            error <= `E0;

            time_store <= 16'd0;
            pc_store <= 32'h0;
            addr_store <= 32'h0;
            grf_store <= 14'd0;
        end
        else begin
            case (status)
                // 非法状态
                `S0 : begin
                    if(char == "^") begin
                        status <= `S1;
                        counter <= 4'd0;
                        // 复位错误统计器
                        error <= `E0;
                        // 清空各内容计数器
                        time_store <= 16'd0;
                        pc_store <= 32'h0;
                        addr_store <= 32'h0;
                        grf_store <= 14'd0;
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
                            counter <= counter + 4'd1;
                            // 更新保存的数值
                            time_store <= time_store + time_store + 
                                          time_store + time_store + 
                                          time_store + time_store + 
                                          time_store + time_store + 
                                          time_store + time_store + 
                                          {{8{1'b0}}, char - L_digit};
                        end
                        else begin
                            status <= `S0;
                        end
                    end

                    else if(char == "@") begin
                        if(counter > 4'd0) begin
                            status <= `S2;
                            // 判断time是否合法
                            // 1.判断的地方之前有问题（没有理解非阻塞赋值）
                            // 2.&&使用错误了，跟C语言一样，只要两个数都是非0的就得到1
                            if(| (time_store & ((freq >> 1) - 16'b1)))begin
                                error <= error | `O_E1;
                            end
                            else begin
                                error <= error & `A_NE1;
                            end
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
                            counter <= counter + 4'd1;

                            // 赋值不能进行两次
                            // 移位和加新的数字
                            if(char >= L_digit & char <= R_digit) begin
                                pc_store <= (pc_store << 4) + {{24{1'b0}}, char - L_digit};
                            end
                            else begin
                                pc_store <= (pc_store << 4) + {{24{1'b0}}, char - L_hex};
                            end
                        end
                        else begin
                            status <= `S0;
                        end
                    end

                    else if(char == ":") begin
                        if(counter == 4'd8) begin
                            status <= `S3;
                            // 判断pc是否合法
                            if((pc_store >= L_pc & pc_store <= R_pc) & 
                               ~(|pc_store[1:0])) begin
                                error <= error & `A_NE2;
                            end
                            else begin
                                error <= error | `O_E2;
                            end
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
                        // 根据题目的要求进行修改的
                        8'd42: begin
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
                            counter <= counter + 4'd1;

                            grf_store <= grf_store + grf_store + 
                                         grf_store + grf_store + 
                                         grf_store + grf_store + 
                                         grf_store + grf_store + 
                                         grf_store + grf_store + 
                                         {{6{1'b0}}, char - L_digit};
                        end
                        else begin
                            status <= `S0;
                        end
                    end

                    else if(char == " ") begin
                        if(counter > 4'd0) begin
                            status <= `S6;
                            // 判断grf是否合法
                            if(grf_store >= L_grf & grf_store <= R_grf) begin
                                error <= error & `A_NE4;
                            end
                            else begin
                                error <= error | `O_E4;
                            end
                            counter <= 4'd0;
                        end
                        else begin
                            status <= `S0;
                        end
                    end

                    else if(char == "<") begin
                        if(counter > 4'd0) begin
                            status <= `S7;
                            // 判断grf是否合法
                            if(grf_store >= L_grf & grf_store <= R_grf) begin
                                error <= error & `A_NE4;
                            end
                            else begin
                                error <= error | `O_E4;
                            end
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
                            counter <= counter + 4'd1;

                            // 赋值不能进行两次
                            // 加新的数字
                            if(char >= L_digit & char <= R_digit) begin
                                addr_store <= (addr_store << 4) + {{24{1'b0}}, char - L_digit};
                            end
                            else begin
                                addr_store <= (addr_store << 4) + {{24{1'b0}}, char - L_hex};
                            end
                        end
                        else begin
                            status <= `S0;
                        end
                    end

                    else if(char == " ") begin
                        if(counter == 4'd8) begin
                            status <= `S6;
                            // 判断addr是否正确
                            if((addr_store >= L_addr & addr_store <= R_addr) & 
                               ~(|addr_store[1:0])) begin
                                error <= error & `A_NE3;
                            end
                            else begin
                                error <= error | `O_E3;
                            end
                            counter <= 4'd0;
                        end
                        else begin
                            status <= `S0;
                        end
                    end

                    else if(char == "<") begin
                        if(counter == 4'd8) begin
                            status <= `S7;
                            // 判断addr是否正确
                            if((addr_store >= L_addr & addr_store <= R_addr) & 
                               ~(|addr_store[1:0])) begin
                                error <= error & `A_NE3;
                            end
                            else begin
                                error <= error | `O_E3;
                            end
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

                // 十六进制读取状态（data）
                `S9 : begin
                    if(char >= L_digit & char <= R_digit |
                       char >= L_lowerletter & char <= R_lowerletter) begin
                        if(counter < 4'd8) begin
                            status <= `S9;
                            counter <= counter + 4'd1;
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

                // 输出结果状态
                `S10: begin
                    if(char == "^") begin
                        status <= `S1;
                        counter <= 4'd0;
                        // 复位错误统计器
                        error <= `E0;
                        // 清空各内容计数器
                        time_store <= 16'd0;
                        pc_store <= 32'h0;
                        addr_store <= 32'h0;
                        grf_store <= 14'd0;
                    end
                    else begin 
                        status <= `S0;
                    end
                end
            endcase
        end
    end

    assign format_type = (status == `S10) ? judge : 2'b00;

    assign error_code = (status == `S10) ? error : 4'b0000;

endmodule
