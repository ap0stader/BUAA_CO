// Verified: 2024-08-28
`timescale 1ns / 1ps

`default_nettype none
module DM_RAM(
    input wire RESET,
    input wire clk,
    input wire WE,
    input wire [31:0] A,
    input wire [31:0] D,
    output wire [31:0] Q
    );

    // DM容量为12KiB
    // 3072 × 32bit
    reg [31:0] RAM [3071:0] ;

    // 数据的地址从0x00000000开始
    // 直接取出的数据固定为32bit即4byte，地址后两位是无效的
    // 2048 = 2^11，4096 = 2^12，故取地址的13:2位
    wire [11:0] RAM_address;
    assign RAM_address = A[13:2];

    // 消除不必要的因为RAM大小导致的读更高地址数据时出现的X
    assign Q = (A[13:12] == 2'b11) ? 32'h00000000 :
               RAM[RAM_address];

    integer i;

    always @(posedge clk) begin
        if (RESET) begin
            for (i = 0; i < 3072; i = i + 1) begin
                RAM[i] <= 32'h00000000;
            end
        end
        else if (WE) begin
            RAM[RAM_address] <= D;
        end
    end

endmodule
