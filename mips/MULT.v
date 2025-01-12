// Verified: 2024-08-29
`timescale 1ns / 1ps

`default_nettype none

`define signed_mult 2'b00
`define unsigned_mult 2'b01
`define signed_div 2'b10
`define unsigned_div 2'b11

module MULT(
    input wire RESET,
    input wire clk,
    input wire Req, 

    input wire ISMULTDIV,
    input wire [2:0] MULTSel,
    
    input wire [31:0] A,
    input wire [31:0] B,

    output wire Start,
    output reg Busy,

    output wire [31:0] HILO
    );
    
    reg [31:0] HI;
    reg [31:0] LO;
    
    reg [1:0] calculation_method;
    reg [31:0] stored_A;
    reg [31:0] stored_B;

    reg [3:0] simulation_counter;
    
    assign Start = ISMULTDIV & MULTSel[2];
    
    always @(posedge clk) begin
        // 初始化
        if (RESET) begin
            Busy <= 1'b0;

            HI <= 32'b0;
            LO <= 32'b0;

            calculation_method <= 2'b0;
            stored_A <= 32'h0;
            stored_B <= 32'h0;

            simulation_counter <= 4'd0;
        end
        // 准备计算乘法和除法
        // 如果即将进入中断处理程序，不得开始乘法除法操作
        else if (Start & ~Req) begin
            Busy <= 1'b1;
            calculation_method <= MULTSel[1:0];
            stored_A <= A;
            stored_B <= B;
            simulation_counter <= (MULTSel[1] == 1'b0) ? 4'd5 : 4'd10;
        end
        // 乘法和除法计算过程
        else if (Busy) begin
            // 已经在进行的乘法和除法操作则继续正常进行
            if (simulation_counter == 4'd1) begin
                Busy <= 1'b0;

                // 准备输出结果
                case (calculation_method)
                    `signed_mult: begin
                        {HI, LO} <= $signed(stored_A) * $signed(stored_B);
                    end
                    `unsigned_mult: begin
                        {HI, LO} <= stored_A * stored_B;
                    end
                    `signed_div: begin
                        LO <= $signed(stored_A) / $signed(stored_B);
                        HI <= $signed(stored_A) % $signed(stored_B);
                    end
                    `unsigned_div: begin
                        LO <= stored_A / stored_B;
                        HI <= stored_A % stored_B;
                    end
                endcase
            end

            simulation_counter <= simulation_counter - 4'd1;
        end
        // 写入HI或者LO
        else if (ISMULTDIV & ~MULTSel[2] & MULTSel[0] & ~Req) begin
            if(MULTSel[1] == 1'b0) begin
                HI <= A;
            end
            else begin
                LO <= A;
            end
        end
    end
    
    assign HILO = (MULTSel[1] == 1'b0) ? HI : LO;

endmodule
